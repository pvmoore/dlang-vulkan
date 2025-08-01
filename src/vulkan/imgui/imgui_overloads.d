module vulkan.imgui.imgui_overloads;

import vulkan.all;

bool igCollapsingHeader(immutable(char)* label, ImGuiTreeNodeFlags flags = 0) {
    return igCollapsingHeader_TreeNodeFlags(label, flags);
}

ImColor HSV(float h, float s, float v, float a = 1.0f) {
    float r, g, b;
    igColorConvertHSVtoRGB(h, s, v, &r, &g, &b);
    return ImColor(ImVec4(r, g, b, a));
}

bool igCombo(string label, string[] items, int* currentItem, int maxHeightInItems = 3) {

    immutable(char)*[] array = items.map!(it=>toStringz(it))
                         .map!(it=>it.as!(immutable(char)*))
                         .array;

    return igCombo_Str_arr(
        toStringz(label),
        currentItem,
        array.ptr,
        items.length.as!int,
        maxHeightInItems
    );
}
void igoCombo(string label, string previewString, string[] items, uint selectedIndex, void delegate(int index, string item) onChange) {
    if(igBeginCombo(label.toStringz(), previewString.toStringz(), ImGuiComboFlags_HeightLargest)) {
        foreach(i, it; items) {
            bool isSelected = i == selectedIndex;
            if(igSelectable_Bool(it.toStringz(), isSelected, ImGuiSelectableFlags_None, ImVec2(0,0))) {
                onChange(i.as!uint, it);
            }
        
            if(isSelected) {
                igSetItemDefaultFocus();
            }
        }
        igEndCombo();
    }
}

bool igListBox(string label, string[] items, int* currentItem, int maxHeightInItems = 3) {

    immutable(char)*[] array = items.map!(it=>toStringz(it))
                         .map!(it=>it.as!(immutable(char)*))
                         .array;

    return igListBox_Str_arr(
        toStringz(label),
        currentItem,
        array.ptr,
        items.length.as!int,
        maxHeightInItems);
}

bool igMenuItem(immutable(char)* label, immutable(char)* shortcut = null, bool selected=false) {
    return igMenuItem_Bool(label, shortcut, selected, true);
}

// Helper to display a little (?) mark which shows a tooltip when hovered.
// In your own code you may want to display an actual icon if you are using a merged icon fonts (see docs/FONTS.md)
void igHelpMarker(immutable(char)* desc)
{
    igTextDisabled("(?)");
    if (igIsItemHovered(0))
    {
        igBeginTooltip();
        igPushTextWrapPos(igGetFontSize() * 35.0f);
        igTextUnformatted(desc, null);
        igPopTextWrapPos();
        igEndTooltip();
    }
}

ImVec2 igoCalcTextSize(immutable(char)* text) {
    //  ImVec2 CalcTextSize(ImVec2* vout, const char* text, const char* text_end = NULL,
    //                      bool hide_text_after_double_hash = false, float wrap_width = -1.0f);
    ImVec2 v;
    igCalcTextSize(&v, text, null, false, -1f);
    return v;
}

ImVec2 igoGetWindowSize() {
    ImVec2 v;
    igGetWindowSize(&v);
    return v;
}
ImVec2 igoGetWindowPos() {
    ImVec2 v;
    igGetWindowPos(&v);
    return v;
}
ImVec2 igoGetCursorPos() {
    ImVec2 v;
    igGetCursorPos(&v);
    return v;
}
ImVec2 igoGetCursorStartPos() {
    ImVec2 v;
    igGetCursorStartPos(&v);
    return v;
}
ImVec2 igoGetCursorScreenPos() {
    ImVec2 v;
    igGetCursorScreenPos(&v);
    return v;
}
ImVec2 igoGetMousePos() {
    ImVec2 v;
    igGetMousePos(&v);
    return v;
}
ImVec2 igoGetRelMousePos(ImVec2 origin) {
    ImVec2 v;
    igGetMousePos(&v);
    return ImVec2(v.x-origin.x, v.y-origin.y);
}
ImVec2 igoGetItemRectMin() {
    ImVec2 v;
    igGetItemRectMin(&v);
    return v;
}
ImVec2 igoGetItemRectMax() {
    ImVec2 v;
    igGetItemRectMax(&v);
    return v;
}
uint igGetColorU32(ImGuiCol idx, float alpha_mul = 1.0) {
    return igGetColorU32_Col(idx, alpha_mul);
}


void igPushStyleVar(ImGuiStyleVar var, float f) {
    igPushStyleVar_Float(var, f);
}
void igPushStyleVar(ImGuiStyleVar var, ImVec2 vec) {
    igPushStyleVar_Vec2(var, vec);
}
// eg. igPushStyleColor(ImGuiCol_Text, float4(1,0,0,1));
//     ...
//     igPopStyleColor(1);
void igPushStyleColor(ImGuiCol idx, float4 col) {
    igPushStyleColor_Vec4(idx, col.as!ImVec4);
}

bool igoIsKeyPressed(int key) {
    return igIsKeyPressed_Bool(cast(ImGuiKey)key, false);
}

// Align right:
// igSetCursorPosX(igGetCursorPosX() + igGetColumnWidth(0) -
            //     igoCalcTextSize(t).x -
            //     igGetScrollX() - 1 * igGetStyle().ItemSpacing.x);
