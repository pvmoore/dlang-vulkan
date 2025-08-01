module vulkan.imgui.components.imgui_memory_editor;

import vulkan.all;

/**
 * D lang conversion (with changes and removals) of the following ImGui utility:
 *
 * https://github.com/ocornut/imgui_club/blob/master/imgui_memory_editor/imgui_memory_editor.h
 *
 * 2024-31-08
 */

// Mini memory editor for Dear ImGui (to embed in your game/tools)
// Get latest version at http://www.github.com/ocornut/imgui_club
// Licensed under The MIT License (MIT)

// Right-click anywhere to access the Options menu!
// You can adjust the keyboard repeat delay/rate in ImGuiIO.
// The code assume a mono-space font for simplicity!
// If you don't use the default font, use ImGui::PushFont()/PopFont() to switch to a mono-space font before calling this.
//
// Usage:
//   // Create a window and draw memory editor inside it:
//   static MemoryEditor mem_edit_1;
//   static char data[0x10000];
//   size_t data_size = 0x10000;
//   mem_edit_1.DrawWindow("Memory Editor", data, data_size);
//
// Usage:
//   // If you already have a window, use DrawContents() instead:
//   static MemoryEditor mem_edit_2;
//   ImGui::Begin("MyWindow")
//   mem_edit_2.DrawContents(this, sizeof(*this), (size_t)this);
//   ImGui::End();
//
// Changelog:
// - v0.10: initial version
// - v0.23 (2017/08/17): added to github. fixed right-arrow triggering a byte write.
// - v0.24 (2018/06/02): changed DragInt("Rows" to use a %d data format (which is desirable since imgui 1.61).
// - v0.25 (2018/07/11): fixed wording: all occurrences of "Rows" renamed to "Columns".
// - v0.26 (2018/08/02): fixed clicking on hex region
// - v0.30 (2018/08/02): added data preview for common data types
// - v0.31 (2018/10/10): added OptUpperCaseHex option to select lower/upper casing display [@samhocevar]
// - v0.32 (2018/10/10): changed signatures to use void* instead of unsigned char*
// - v0.33 (2018/10/10): added OptShowOptions option to hide all the interactive option setting.
// - v0.34 (2019/05/07): binary preview now applies endianness setting [@nicolasnoble]
// - v0.35 (2020/01/29): using ImGuiDataType available since Dear ImGui 1.69.
// - v0.36 (2020/05/05): minor tweaks, minor refactor.
// - v0.40 (2020/10/04): fix misuse of ImGuiListClipper API, broke with Dear ImGui 1.79. made cursor position appears on left-side of edit box. option popup appears on mouse release. fix MSVC warnings where _CRT_SECURE_NO_WARNINGS wasn't working in recent versions.
// - v0.41 (2020/10/05): fix when using with keyboard/gamepad navigation enabled.
// - v0.42 (2020/10/14): fix for . character in ASCII view always being greyed out.
// - v0.43 (2021/03/12): added OptFooterExtraHeight to allow for custom drawing at the bottom of the editor [@leiradel]
// - v0.44 (2021/03/12): use ImGuiInputTextFlags_AlwaysOverwrite in 1.82 + fix hardcoded width.
// - v0.50 (2021/11/12): various fixes for recent dear imgui versions (fixed misuse of clipper, relying on SetKeyboardFocusHere() handling scrolling from 1.85). added default size.
// - v0.51 (2024/02/22): fix for layout change in 1.89 when using IMGUI_DISABLE_OBSOLETE_FUNCTIONS. (#34)
// - v0.52 (2024/03/08): removed unnecessary GetKeyIndex() calls, they are a no-op since 1.87.
// - v0.53 (2024/05/27): fixed right-click popup from not appearing when using DrawContents(). warning fixes. (#35)
// - v0.54 (2024/07/29): allow ReadOnly mode to still select and preview data. (#46) [@DeltaGW2])
// - v0.55 (2024/08/19): added BgColorFn to allow setting background colors independently from highlighted selection. (#27) [@StrikerX3]
//                       added MouseHoveredAddr public readable field. (#47, #27) [@StrikerX3]
//                       fixed a data preview crash with 1.91.0 WIP. fixed contiguous highlight color when using data preview.
//                       *BREAKING* added UserData field passed to all optional function handlers: ReadFn, WriteFn, HighlightFn, BgColorFn. (#50) [@silverweed]
//
// TODO:
// - This is generally old/crappy code, it should work but isn't very good.. to be rewritten some day.
// - PageUp/PageDown are not supported because we use _NoNav. This is a good test scenario for working out idioms of how to mix natural nav and our own...
// - Arrows are being sent to the InputText() about to disappear which for LeftArrow makes the text cursor appear at position 1 for one frame.
// - Using InputText() is awkward and maybe overkill here, consider implementing something custom.

// #pragma once

import core.stdc.stdio : sprintf, snprintf, scanf, sscanf;

//enum _PRISizeT = "I";
enum _PRISizeT = "z";

final class MemoryEditor {
private:
    enum DataFormat
    {
        Bin = 0,
        Dec = 1,
        Hex = 2,
        COUNT
    }
    enum 
    {
        DataFormat_Bin = 0,
        DataFormat_Dec = 1,
        DataFormat_Hex = 2,
        DataFormat_COUNT
    }
    struct Sizes {
        int     AddrDigitsCount;
        float   LineHeight = 0;
        float   GlyphWidth = 0;
        float   HexCellWidth = 0;
        float   SpacingBetweenMidCols = 0;
        float   PosHexStart = 0;
        float   PosHexEnd = 0;
        float   PosAsciiStart = 0;
        float   PosAsciiEnd = 0;
        float   WindowWidth = 0;
    }

    ImFont* font; // pvmoore
public:
    // Settings
    bool            Open = true;                                // = true   // set to false when DrawWindow() was closed. ignore if not using DrawWindow().
    bool            ReadOnly;                                   // = false  // disable any editing.
    int             Cols = 16;                                  // = 16     // number of columns to display.
    bool            OptShowOptions = true;                      // = true   // display options button/context menu. when disabled, options will be locked unless you provide your own UI for them.
    bool            OptShowDataPreview;                         // = false  // display a footer previewing the decimal/binary/hex/float representation of the currently selected bytes.
    bool            OptShowHexII;                               // = false  // display values in HexII representation instead of regular hexadecimal: hide null/zero bytes, ascii values as ".X".
    bool            OptShowAscii = true;                        // = true   // display ASCII representation on the right side.
    bool            OptGreyOutZeroes = true;                    // = true   // display null/zero bytes using the TextDisabled color.
    bool            OptUpperCaseHex = true;                     // = true   // display hexadecimal values as "FF" instead of "ff".
    int             OptMidColsCount = 8;                        // = 8      // set to 0 to disable extra spacing between every mid-cols.
    int             OptAddrDigitsCount;                         // = 0      // number of addr digits to display (default calculated based on maximum displayed addr).
    float           OptFooterExtraHeight = 0;                   // = 0      // space to reserve at the bottom of the widget to add custom widgets
    ImU32           HighlightColor = IM_COL32(255, 128, 255, 128);//          // background color of highlighted bytes.

    // Function handlers
    ImU8            delegate(ImU8* data, size_t off, void* user_data) ReadFn;           // = 0      // optional handler to read bytes.
    void            delegate(ImU8* data, size_t off, ImU8 d, void* user_data) WriteFn;  // = 0      // optional handler to write bytes.
    bool            delegate(ImU8* data, size_t off, void* user_data) HighlightFn;      // = 0      // optional handler to return Highlight property (to support non-contiguous highlighting).
    ImU32           delegate(ImU8* data, size_t off, void* user_data) BgColorFn;        // = 0      // optional handler to return custom background color of individual bytes.
    void*           UserData;                                                           // = NULL   // user data forwarded to the function handlers

    // Public read-only data
    bool            MouseHovered;                               // set when mouse is hovering a value.
    size_t          MouseHoveredAddr;                           // the address currently being hovered if MouseHovered is set.

    // [Internal State]
    bool            ContentsWidthChanged;
    size_t          DataPreviewAddr = cast(ulong)-1;
    size_t          DataEditingAddr = cast(ulong)-1;
    bool            DataEditingTakeFocus;
    char[32]        DataInputBuf;
    char[32]        AddrInputBuf;
    size_t          GotoAddr = cast(ulong)-1;
    size_t          HighlightMin = cast(ulong)-1, HighlightMax = cast(ulong)-1;
    int             PreviewEndianness;
    ImGuiDataType   PreviewDataType = ImGuiDataType_S32;

    this() {
        DataInputBuf[] = 0;
        AddrInputBuf[] = 0;
    }
    auto withFont(ImFont* font) {
        this.font = font;
        return this;
    }

    void scrollToAddress(ulong addr) {
        GotoAddrAndHighlight(addr, addr);
    }

    // Draw window and contents
    void DrawWindow(string title, void* mem_data, ulong memSize, ulong baseDisplayAddr = 0) {
        Sizes s;
        CalcSizes(&s, memSize, baseDisplayAddr);
        igSetNextWindowSize(ImVec2(s.WindowWidth, s.WindowWidth * 0.60f), ImGuiCond_FirstUseEver);
        igSetNextWindowSizeConstraints(ImVec2(0.0f, 0.0f), ImVec2(s.WindowWidth, float.max), null, null);

        auto windowTitle = getTitle(title, memSize, baseDisplayAddr, s);

        Open = true;
        if (igBegin(windowTitle, &Open, ImGuiWindowFlags_NoScrollbar))
        {
            DrawContents(mem_data, memSize, baseDisplayAddr);

            if(ContentsWidthChanged) {
                CalcSizes(&s, memSize, baseDisplayAddr);
                igSetWindowSize_Vec2(ImVec2(s.WindowWidth, igoGetWindowSize().y), ImGuiCond_None);
            }
        }
        igEnd();
    }

    // Draw contents only
    void DrawContents(void* mem_data_void, ulong mem_size, ulong base_display_addr = 0x0000)
    {
        if (Cols < 1) Cols = 1;

        ImU8* mem_data = cast(ImU8*)mem_data_void;
        Sizes s;
        CalcSizes(&s, mem_size, base_display_addr);
        ImGuiStyle* style = igGetStyle();

        ImVec2 contents_pos_start;
        igGetCursorScreenPos(&contents_pos_start);

        // We begin into our scrolling region with the 'ImGuiWindowFlags_NoMove' in order to prevent click from moving the window.
        // This is used as a facility since our main click detection code doesn't assign an ActiveId so the click would normally be caught as a window-move.
        const float height_separator = style.ItemSpacing.y;
        float footer_height = OptFooterExtraHeight;
        if (OptShowOptions)
            footer_height += height_separator + igGetFrameHeightWithSpacing() * 1;
        if (OptShowDataPreview)
            footer_height += height_separator + igGetFrameHeightWithSpacing() * 1 + igGetTextLineHeightWithSpacing() * 3;

        igBeginChild_Str("##scrolling", ImVec2(0, -footer_height), ImGuiWindowFlags_None, ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoNav);

        ImDrawList* draw_list = igGetWindowDrawList();

        igPushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(0, 0));
        igPushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(0, 0));

        // We are not really using the clipper API correctly here,
        // because we rely on visible_start_addr/visible_end_addr for our scrolling function.
        int line_total_count = cast(int)((mem_size + Cols - 1) / Cols);

        ImGuiListClipper clipper;
        ImGuiListClipper_Begin(&clipper, line_total_count, s.LineHeight);

        bool data_next = false;
        
        if (DataEditingAddr >= mem_size)
            DataEditingAddr = cast(size_t)-1;
        if (DataPreviewAddr >= mem_size)
            DataPreviewAddr = cast(size_t)-1;

        ulong preview_data_type_size = OptShowDataPreview ? DataTypeGetSize(PreviewDataType) : 0;

        //ulong data_editing_addr_backup = DataEditingAddr;
        ulong data_editing_addr_next = cast(ulong)-1;

        if (DataEditingAddr != cast(ulong)-1)
        {
            // Move cursor but only apply on next frame so scrolling with be synchronized (because currently we can't change the scrolling while the window is being rendered)
            if (igoIsKeyPressed((ImGuiKey_UpArrow)) && DataEditingAddr >= cast(ulong)Cols)       { data_editing_addr_next = DataEditingAddr - Cols; }
            else if (igoIsKeyPressed((ImGuiKey_DownArrow)) && DataEditingAddr < mem_size - Cols) { data_editing_addr_next = DataEditingAddr + Cols; }
            else if (igoIsKeyPressed((ImGuiKey_LeftArrow)) && DataEditingAddr > 0)               { data_editing_addr_next = DataEditingAddr - 1; }
            else if (igoIsKeyPressed((ImGuiKey_RightArrow)) && DataEditingAddr < mem_size - 1)   { data_editing_addr_next = DataEditingAddr + 1; }
        }

        // Draw vertical separator
        auto window_pos = igoGetWindowPos();
        if (OptShowAscii) {
            ImDrawList_AddLine(draw_list,
                ImVec2(window_pos.x + s.PosAsciiStart - s.GlyphWidth, window_pos.y),
                ImVec2(window_pos.x + s.PosAsciiStart - s.GlyphWidth, window_pos.y + 9999),
                igGetColorU32(ImGuiCol_Border), 1.0f);
        }

        ImU32 color_text = igGetColorU32(ImGuiCol_Text);
        ImU32 color_disabled = OptGreyOutZeroes ? igGetColorU32(ImGuiCol_TextDisabled) : color_text;

        immutable(char)* format_address = OptUpperCaseHex ? "%0*" ~ _PRISizeT ~ "X: " : "%0*" ~ _PRISizeT ~ "x: ";
        immutable(char)* format_data = OptUpperCaseHex ? "%0*" ~ _PRISizeT ~ "X" : "%0*" ~ _PRISizeT ~ "x";
        immutable(char)* format_byte = OptUpperCaseHex ? "%02X" : "%02x";
        immutable(char)* format_byte_space = OptUpperCaseHex ? "%02X " : "%02x ";

        MouseHovered = false;
        MouseHoveredAddr = 0;
        
        if(font)
            igPushFont(font, 0);

        while(ImGuiListClipper_Step(&clipper))
        for (int line_i = clipper.DisplayStart; line_i < clipper.DisplayEnd; line_i++) // display only visible lines
        {
            ulong addr = cast(ulong)(line_i * Cols);
            igText(format_address, s.AddrDigitsCount, base_display_addr + addr);

            // Draw Hexadecimal
            for (int n = 0; n < Cols && addr < mem_size; n++, addr++)
            {
                float byte_pos_x = s.PosHexStart + s.HexCellWidth * n;
                if (OptMidColsCount > 0) {
                    byte_pos_x += cast(float)(n / OptMidColsCount) * s.SpacingBetweenMidCols;
                }
                igSameLine(byte_pos_x, 0);

                // Draw highlight or custom background color
                bool is_highlight_from_user_range = (addr >= HighlightMin && addr < HighlightMax);
                bool is_highlight_from_user_func = (HighlightFn && HighlightFn(mem_data, addr, UserData));
                bool is_highlight_from_preview = (addr >= DataPreviewAddr && addr < DataPreviewAddr + preview_data_type_size);

                ImU32 bg_color = 0;
                bool is_next_byte_highlighted = false;

                if (is_highlight_from_user_range || is_highlight_from_user_func || is_highlight_from_preview)
                {
                    is_next_byte_highlighted = (addr + 1 < mem_size) && ((HighlightMax != cast(size_t)-1 && addr + 1 < HighlightMax) || (HighlightFn && HighlightFn(mem_data, addr + 1, UserData)) || (addr + 1 < DataPreviewAddr + preview_data_type_size));
                    bg_color = HighlightColor;
                } 
                else if (BgColorFn !is null)
                {
                    is_next_byte_highlighted = (addr + 1 < mem_size) && ((BgColorFn(mem_data, addr + 1, UserData) & IM_COL32_A_MASK) != 0);
                    bg_color = BgColorFn(mem_data, addr, UserData);
                }
                if (bg_color != 0)
                {
                    float bg_width = s.GlyphWidth * 2;
                    if (is_next_byte_highlighted || (n + 1 == Cols))
                    {
                        bg_width = s.HexCellWidth;
                        if (OptMidColsCount > 0 && n > 0 && (n + 1) < Cols && ((n + 1) % OptMidColsCount) == 0)
                            bg_width += s.SpacingBetweenMidCols;
                    }
                    ImVec2 pos;
                    igGetCursorScreenPos(&pos);
                    ImDrawList_AddRectFilled(draw_list, pos, ImVec2(pos.x + bg_width, pos.y + s.LineHeight), bg_color, 0, ImDrawFlags_None);
                }

                if (DataEditingAddr == addr) 
                {
                    // Display text input on current byte
                    bool data_write = false;
                    igPushID_Ptr(cast(void*)addr);
                    if (DataEditingTakeFocus)
                    {
                        igSetKeyboardFocusHere(0);
                        sprintf(AddrInputBuf.ptr, format_data, s.AddrDigitsCount, base_display_addr + addr);
                        sprintf(DataInputBuf.ptr, format_byte, ReadFn ? ReadFn(mem_data, addr, UserData) : mem_data[addr]);
                    }
                    struct InputTextUserData
                    {
                        // FIXME: We should have a way to retrieve the text edit cursor position more easily in the API, this is rather tedious. This is such a ugly mess we may be better off not using InputText() at all here.
                        extern(C)
                        static int Callback(ImGuiInputTextCallbackData* data) nothrow
                        {
                            InputTextUserData* user_data = cast(InputTextUserData*)data.UserData;
                            if (!ImGuiInputTextCallbackData_HasSelection(data))
                                user_data.CursorPos = data.CursorPos;
                            static if(IMGUI_VERSION_NUM < 19102) {
                                if (data.Flags & ImGuiInputTextFlags_ReadOnly)
                                    return 0;
                            }    
                            if (data.SelectionStart == 0 && data.SelectionEnd == data.BufTextLen)
                            {
                                // When not editing a byte, always refresh its InputText content pulled from underlying memory data
                                // (this is a bit tricky, since InputText technically "owns" the master copy of the buffer we edit it in there)
                                ImGuiInputTextCallbackData_DeleteChars(data, 0, data.BufTextLen);
                                ImGuiInputTextCallbackData_InsertChars(data, 0, cast(immutable(char)*)user_data.CurrentBufOverwrite.ptr, null);
                                data.SelectionStart = 0;
                                data.SelectionEnd = 2;
                                data.CursorPos = 0;
                            }
                            return 0;
                        }
                        char[3] CurrentBufOverwrite;  // Input
                        int     CursorPos;            // Output
                    }

                    InputTextUserData input_text_user_data;
                    input_text_user_data.CursorPos = -1;
                    sprintf(input_text_user_data.CurrentBufOverwrite.ptr, format_byte, ReadFn ? ReadFn(mem_data, addr, UserData) : mem_data[addr]);
                    ImGuiInputTextFlags flags = ImGuiInputTextFlags_CharsHexadecimal | ImGuiInputTextFlags_EnterReturnsTrue | ImGuiInputTextFlags_AutoSelectAll | ImGuiInputTextFlags_NoHorizontalScroll | ImGuiInputTextFlags_CallbackAlways;
                    if (ReadOnly)
                        flags |= ImGuiInputTextFlags_ReadOnly;
                    flags |= ImGuiInputTextFlags_AlwaysOverwrite; // was ImGuiInputTextFlags_AlwaysInsertMode

                    igSetNextItemWidth(s.GlyphWidth * 2);

                    if (igInputText("##data", cast(immutable(char)*)DataInputBuf.ptr, DataInputBuf.length, flags, &InputTextUserData.Callback, &input_text_user_data)) {
                        data_write = data_next = true;
                    } else if (!DataEditingTakeFocus && !igIsItemActive()) {
                        DataEditingAddr = data_editing_addr_next = cast(ulong)-1;
                    }

                    DataEditingTakeFocus = false;
                    if (input_text_user_data.CursorPos >= 2)
                        data_write = data_next = true;
                    if (data_editing_addr_next != cast(ulong)-1)
                        data_write = data_next = false;
                    uint data_input_value = 0;

                    if (!ReadOnly && data_write && sscanf(DataInputBuf.ptr, "%X", &data_input_value) == 1)
                    {
                        if (WriteFn) {
                            WriteFn(mem_data, addr, cast(ImU8)data_input_value, UserData);
                        } else {
                            mem_data[addr] = cast(ImU8)data_input_value;
                        }
                    }
                    igPopID();
                }
                else
                {
                    // NB: The trailing space is not visible but ensure there's no gap that the mouse cannot click on.
                    ImU8 b = ReadFn ? ReadFn(mem_data, addr, UserData) : mem_data[addr];

                    if (OptShowHexII)
                    {
                        if (b >= 32 && b < 128)
                            igText(".%c ", b);
                        else if (b == 0xFF && OptGreyOutZeroes)
                            igTextDisabled("## ");
                        else if (b == 0x00)
                            igText("   ");
                        else
                            igText(format_byte_space, b);
                    }
                    else
                    {
                        if (b == 0 && OptGreyOutZeroes)
                            igTextDisabled("00 ");
                        else
                            igText(format_byte_space, b);
                    }
                    if (igIsItemHovered(ImGuiHoveredFlags_None))
                    {
                        MouseHovered = true;
                        MouseHoveredAddr = addr;
                        if (igIsMouseClicked_Bool(0, false))
                        {
                            DataEditingTakeFocus = true;
                            data_editing_addr_next = addr;
                        }
                    }
                }
            }

            if (OptShowAscii)
            {
                // Draw ASCII values
                igSameLine(s.PosAsciiStart, 0);
                ImVec2 pos = igoGetCursorScreenPos();
                addr = line_i * Cols;

                float mouse_off_x = igGetIO().MousePos.x - pos.x;
                size_t mouse_addr = (mouse_off_x >= 0.0f && mouse_off_x < s.PosAsciiEnd - s.PosAsciiStart) ? addr + cast(size_t)(mouse_off_x / s.GlyphWidth) : cast(size_t)-1;

                igPushID_Int(line_i);
                if (igInvisibleButton("ascii", ImVec2(s.PosAsciiEnd - s.PosAsciiStart, s.LineHeight), ImGuiButtonFlags_None))
                {
                    DataEditingAddr = DataPreviewAddr = mouse_addr;
                    DataEditingTakeFocus = true;
                }
                if (igIsItemHovered(ImGuiHoveredFlags_None))
                {
                    MouseHovered = true;
                    MouseHoveredAddr = mouse_addr;
                }
                igPopID();
                for (int n = 0; n < Cols && addr < mem_size; n++, addr++)
                {
                    if (addr == DataEditingAddr)
                    {
                        ImDrawList_AddRectFilled(draw_list, pos, ImVec2(pos.x + s.GlyphWidth, pos.y + s.LineHeight), igGetColorU32(ImGuiCol_FrameBg), 1.0f, ImDrawFlags_RoundCornersNone);
                        ImDrawList_AddRectFilled(draw_list, pos, ImVec2(pos.x + s.GlyphWidth, pos.y + s.LineHeight), igGetColorU32(ImGuiCol_TextSelectedBg), 1.0f, ImDrawFlags_RoundCornersNone);
                    }
                    else if (BgColorFn)
                    {
                        ImDrawList_AddRectFilled(draw_list, pos, ImVec2(pos.x + s.GlyphWidth, pos.y + s.LineHeight), BgColorFn(mem_data, addr, UserData), 1.0f, ImDrawFlags_RoundCornersNone);
                    }
                    ubyte c = ReadFn ? ReadFn(mem_data, addr, UserData) : mem_data[addr];
                    char display_c = (c < 32 || c >= 128) ? '.' : c;
                    ImDrawList_AddText_Vec2(draw_list, pos, (display_c == c) ? color_text : color_disabled,
                        cast(immutable(char)*)&display_c, cast(immutable(char)*)&display_c + 1);
                    pos.x += s.GlyphWidth;
                }
            }
        }

        if(font)
            igPopFont();

        igPopStyleVar(2);
        float child_width = igoGetWindowSize().x;
        igEndChild();

        // Notify the main window of our ideal child content size (FIXME: we are missing an API to get the contents size from the child)
        igSetCursorPosX(s.WindowWidth);
        igDummy(ImVec2(0.0f, 0.0f));

        if (data_next && DataEditingAddr + 1 < mem_size)
        {
            DataEditingAddr = DataPreviewAddr = DataEditingAddr + 1;
            DataEditingTakeFocus = true;
        }
        else if (data_editing_addr_next != cast(ulong)-1)
        {
            DataEditingAddr = DataPreviewAddr = data_editing_addr_next;
            DataEditingTakeFocus = true;
        }

        bool lock_show_data_preview = OptShowDataPreview;
        if (OptShowOptions)
        {
            igSeparator();
            DrawOptionsLine(&s, mem_size, base_display_addr);
        }

        if (lock_show_data_preview)
        {
            igSeparator();
            DrawPreviewLine(&s, mem_data, mem_size, base_display_addr);
        }

        ImVec2 contents_pos_end = ImVec2(contents_pos_start.x + child_width, igoGetCursorScreenPos().y);
        //ImGui::GetForegroundDrawList()->AddRect(contents_pos_start, contents_pos_end, IM_COL32(255, 0, 0, 255));
        if (OptShowOptions)
            if (igIsMouseHoveringRect(contents_pos_start, contents_pos_end, true))
                if (igIsWindowHovered(ImGuiHoveredFlags_ChildWindows) && igIsMouseReleased_Nil(ImGuiMouseButton_Right))
                    igOpenPopup_Str("OptionsPopup", ImGuiPopupFlags_None);

        if (igBeginPopup("OptionsPopup", ImGuiWindowFlags_None))
        {
            igSetNextItemWidth(s.GlyphWidth * 7 + style.FramePadding.x * 2.0f);
            if (igDragInt("##cols", &Cols, 0.2f, 4, 32, "%d cols", ImGuiSliderFlags_None)) { ContentsWidthChanged = true; if (Cols < 1) Cols = 1; }
            igCheckbox("Show Data Preview", &OptShowDataPreview);
            igCheckbox("Show HexII", &OptShowHexII);
            if (igCheckbox("Show Ascii", &OptShowAscii)) { ContentsWidthChanged = true; }
            igCheckbox("Grey out zeroes", &OptGreyOutZeroes);
            igCheckbox("Uppercase Hex", &OptUpperCaseHex);

            igEndPopup();
        }
    }

private:
    immutable(char)* getTitle(string userTitle, ulong memSize, ulong baseDisplayAddr, ref Sizes s) {
        string fmt = "%%s [%%0%sx to %%0%sx]".format(s.AddrDigitsCount, s.AddrDigitsCount);
        string title = fmt.format(userTitle, baseDisplayAddr, baseDisplayAddr + memSize - 1);
        return toStringz(title);
    }
    void GotoAddrAndHighlight(ulong addr_min, ulong addr_max) {
        GotoAddr = addr_min;
        HighlightMin = addr_min;
        HighlightMax = addr_max;
    }

    void CalcSizes(Sizes* s, ulong mem_size, ulong base_display_addr)
    {
        ImGuiStyle* style = igGetStyle();
        s.AddrDigitsCount = OptAddrDigitsCount;
        if (s.AddrDigitsCount == 0)
            for (ulong n = base_display_addr + mem_size - 1; n > 0; n >>= 4)
                s.AddrDigitsCount++;
        s.LineHeight = igGetTextLineHeight();
        s.GlyphWidth = igoCalcTextSize("F").x + 1;                      // We assume the font is mono-space
        s.HexCellWidth = cast(float)cast(int)(s.GlyphWidth * 2.0f);             // "FF " we include trailing space in the width to easily catch clicks everywhere
        s.SpacingBetweenMidCols = cast(float)cast(int)(s.HexCellWidth * 0.25f); // Every OptMidColsCount columns we add a bit of extra spacing
        s.PosHexStart = (s.AddrDigitsCount + 2) * s.GlyphWidth;
        s.PosHexEnd = s.PosHexStart + (s.HexCellWidth * Cols);
        s.PosAsciiStart = s.PosAsciiEnd = s.PosHexEnd;
        if (OptShowAscii)
        {
            s.PosAsciiStart = s.PosHexEnd + s.GlyphWidth * 1;
            if (OptMidColsCount > 0)
                s.PosAsciiStart += cast(float)((Cols + OptMidColsCount - 1) / OptMidColsCount) * s.SpacingBetweenMidCols;
            s.PosAsciiEnd = s.PosAsciiStart + Cols * s.GlyphWidth;
        }
        s.WindowWidth = s.PosAsciiEnd + style.ScrollbarSize + style.WindowPadding.x * 2 + s.GlyphWidth;
    }

    void DrawOptionsLine(Sizes* s, ulong mem_size, ulong base_display_addr)
    {
        ImGuiStyle* style = igGetStyle();
        immutable(char)* format_range = OptUpperCaseHex ? 
            "Range %0*" ~ _PRISizeT ~ "X..%0*" ~ _PRISizeT ~ "X" : 
            "Range %0*" ~ _PRISizeT ~ "x..%0*" ~ _PRISizeT ~ "x";


        // Options menu
        if (igButton("Options", ImVec2(0,0))) {
            igOpenPopup_Str("OptionsPopup", ImGuiPopupFlags_None);
        }

        igSameLine(0, 0);
        igText(format_range, s.AddrDigitsCount, base_display_addr, s.AddrDigitsCount, base_display_addr + mem_size - 1);
        igSameLine(0, 0);
        igSetNextItemWidth((s.AddrDigitsCount + 1) * s.GlyphWidth + style.FramePadding.x * 2.0f);

        if (igInputText("##addr", cast(immutable(char)*)AddrInputBuf.ptr, AddrInputBuf.length, ImGuiInputTextFlags_CharsHexadecimal | ImGuiInputTextFlags_EnterReturnsTrue, null, null))
        {
            ulong goto_addr;
            if (sscanf(AddrInputBuf.ptr, "%" ~ _PRISizeT ~ "X", &goto_addr) == 1)
            {
                GotoAddr = goto_addr - base_display_addr;
                HighlightMin = HighlightMax = cast(ulong)-1;
            }
        }

        if (GotoAddr != cast(ulong)-1)
        {
            if (GotoAddr < mem_size)
            {
                igBeginChild_Str("##scrolling", ImVec2(0,0), true, ImGuiWindowFlags_None);
                auto y = ((GotoAddr / Cols) + 1) * igGetTextLineHeight();
                igSetScrollFromPosY_Float(igoGetCursorStartPos().y + y, 1.0f);
                igEndChild();

                DataEditingAddr = DataPreviewAddr = GotoAddr;
                DataEditingTakeFocus = true;
            }
            GotoAddr = cast(ulong)-1;
        }
    }

    void DrawPreviewLine(Sizes* s, void* mem_data_void, ulong mem_size, ulong base_display_addr)
    {
        ImU8* mem_data = cast(ImU8*)mem_data_void;
        ImGuiStyle* style = igGetStyle();
        igAlignTextToFramePadding();
        igText("Preview as:");
        igSameLine(0,0);
        igSetNextItemWidth((s.GlyphWidth * 10.0f) + style.FramePadding.x * 2.0f + style.ItemInnerSpacing.x);

        ImGuiDataType[] supported_data_types = [ ImGuiDataType_S8, ImGuiDataType_U8, ImGuiDataType_S16, ImGuiDataType_U16, ImGuiDataType_S32, ImGuiDataType_U32, ImGuiDataType_S64, ImGuiDataType_U64, ImGuiDataType_Float, ImGuiDataType_Double ];
        
        if (igBeginCombo("##combo_type", DataTypeGetDesc(PreviewDataType), ImGuiComboFlags_HeightLargest))
        {
            for (int n = 0; n < supported_data_types.length; n++) {
                ImGuiDataType data_type = supported_data_types[n];
                bool isSelected = PreviewDataType == data_type;
                if (igSelectable_Bool(DataTypeGetDesc(data_type), isSelected, ImGuiSelectableFlags_None, ImVec2(0,0))) {
                    PreviewDataType = data_type;
                }
                if(isSelected) {
                    igSetItemDefaultFocus();
                }
            }
            igEndCombo();
        } 
        igSameLine(0,0);
        igSetNextItemWidth((s.GlyphWidth * 6.0f) + style.FramePadding.x * 2.0f + style.ItemInnerSpacing.x);
        igCombo_Str("##combo_endianess", &PreviewEndianness, "LE\0BE\0\0", 2);

        string buf;
        float x = s.GlyphWidth * 6.0f;
        bool has_value = DataPreviewAddr != cast(ulong)-1;

        if (has_value) {
            buf = DrawPreviewData(DataPreviewAddr, mem_data, mem_size, PreviewDataType, DataFormat.Dec);
        }
        igText("Dec"); igSameLine(x,0); igTextUnformatted(has_value ? toStringz(buf) : "N/A", null);

        if (has_value) {
            buf = DrawPreviewData(DataPreviewAddr, mem_data, mem_size, PreviewDataType, DataFormat.Hex);
        }
        igText("Hex"); igSameLine(x,0); igTextUnformatted(has_value ? toStringz(buf) : "N/A", null);

        if (has_value) {
            buf = DrawPreviewData(DataPreviewAddr, mem_data, mem_size, PreviewDataType, DataFormat.Bin);
        }
        igText("Bin"); igSameLine(x,0); igTextUnformatted(has_value ? toStringz(buf) : "N/A", null);
    }

    // ┌─────────────────────────────────┐
    // │ Utilities for Data Preview      │
    // └─────────────────────────────────┘

    immutable(char)* DataTypeGetDesc(ImGuiDataType data_type)
    {
        immutable(char)*[] descs = [
            "byte", "ubyte", "short", "ushort", "int", "uint", "long", "ulong", "float", "double" ];
        throwIf(data_type < 0 || data_type >= ImGuiDataType_COUNT);
        return descs[data_type];
    }

    int DataTypeGetSize(ImGuiDataType data_type)
    {
        int[] sizes = [ 1, 1, 2, 2, 4, 4, 8, 8, float.sizeof, double.sizeof ];
        throwIf(data_type < 0 || data_type >= ImGuiDataType_COUNT);
        return sizes[data_type];
    }

    const(char)* DataFormatGetDesc(DataFormat data_format)
    {
        const char*[] descs = [ "Bin", "Dec", "Hex" ];
        throwIf(data_format < 0 || data_format >= DataFormat_COUNT);
        return descs[data_format];
    }

    T convertEndianess(T)(T value, ulong size = 0) {
        import core.bitop: bswap;
        if(PreviewEndianness == 0) {
            return value;
        }

        value = bswap(value);
        value >>= ((8-size)*8);
        return value;
    }

    ulong readDataLE(ulong addr, ImU8* mem_data, ulong size) {
        import core.bitop: bswap;
        ulong value;
        foreach(i; 0..size) {
            ubyte v;
            if (ReadFn) {
                v = ReadFn(mem_data, addr + i, UserData);
            } else {
                v = mem_data[addr+i];
            }
            value <<=8;
            value |= v;
        }
        value = bswap(value);
        value >>= ((8-size)*8);
        return value;
    }

    string DrawPreviewData(ulong addr, ImU8* mem_data, ulong mem_size, ImGuiDataType data_type, DataFormat data_format)
    {
        int elem_size = DataTypeGetSize(data_type);
        ulong size = addr + elem_size > mem_size ? mem_size - addr : elem_size;

        // Copy the data value
        ulong data = readDataLE(addr, mem_data, size);
        ulong dataE = convertEndianess(data, size);

        // Handle binary format
        if (data_format == DataFormat.Bin) {
            string s;
            foreach(j; 0..size) {
                s ~= "%08b ".format(dataE & 0xff);
                dataE >>= 8;
            }
            return s;
        }

        // Handle decimal and hexadecimal formats
        string result;
        final switch (data_type)
        {
            case ImGuiDataType_S8:
            {
                byte int8 = dataE.as!byte;

                if (data_format == DataFormat.Dec) result = "%s".format(int8);
                if (data_format == DataFormat.Hex) result = "%02x".format(int8 & 0xFF);
                break;
            }
            case ImGuiDataType_U8:
            {
                ubyte uint8 = dataE.as!ubyte;
                if (data_format == DataFormat.Dec) result = "%s".format(uint8);
                if (data_format == DataFormat.Hex) result = "%02x".format(uint8 & 0XFF);
                break;
            }
            case ImGuiDataType_S16:
            {
                short int16 = dataE.as!short;
                if (data_format == DataFormat.Dec) result = "%s".format(int16);
                if (data_format == DataFormat.Hex) result = "%04x".format(int16 & 0xFFFF);
                break;
            }
            case ImGuiDataType_U16:
            {
                ushort uint16 = dataE.as!ushort;
                if (data_format == DataFormat.Dec) result = "%s".format(uint16);
                if (data_format == DataFormat.Hex) result = "%04x".format(uint16 & 0xFFFF);
                break;
            }
            case ImGuiDataType_S32:
            {
                int32_t int32 = dataE.as!int;
                if (data_format == DataFormat.Dec) result = "%s".format(int32);
                if (data_format == DataFormat.Hex) result = "%08x".format(int32);
                break;
            }
            case ImGuiDataType_U32:
            {
                uint32_t uint32 = dataE.as!uint;
                if (data_format == DataFormat.Dec) result = "%u".format(uint32);
                if (data_format == DataFormat.Hex) result = "%08x".format(uint32);
                break;
            }
            case ImGuiDataType_S64:
            {
                long int64 = dataE.as!long;
                if (data_format == DataFormat.Dec) result = "%s".format(int64);
                if (data_format == DataFormat.Hex) result = "%016x".format(int64);
                break;
            }
            case ImGuiDataType_U64:
            {
                ulong uint64 = dataE.as!ulong;
                if (data_format == DataFormat.Dec) result = "%s".format(uint64);
                if (data_format == DataFormat.Hex) result = "%016x".format(uint64);
                break;
            }
            case ImGuiDataType_Float:
            {
                float float32 = dataE.as!float;
                if (data_format == DataFormat.Dec) result = "%f".format(float32);
                if (data_format == DataFormat.Hex) result = "%a".format(float32);
                break;
            }
            case ImGuiDataType_Double:
            {
                double float64 = dataE.as!double;
                if (data_format == DataFormat.Dec) result = "%f".format(float64);
                if (data_format == DataFormat.Hex) result = "%a".format(float64);
                break;
            }
        }
        return result;
    }
}
