module vulkan.imgui.imgui_overloads;

import vulkan.all;

bool igCollapsingHeader(const (char)* label, ImGuiTreeNodeFlags flags = 0) {
    return igCollapsingHeaderTreeNodeFlags(label, flags);
}

ImColor HSV(float h, float s, float v, float a = 1.0f) {
    float r, g, b;
    igColorConvertHSVtoRGB(h, s, v, &r, &g, &b);
    return ImColor(ImVec4(r, g, b, a));
}

bool igCombo(string label, string[] items, int* currentItem, int maxHeightInItems = 3) {

    char*[] array = items.map!(it=>toStringz(it))
                         .map!(it=>it.as!(char*))
                         .array;

    return igComboStr_arr(
        toStringz(label),
        currentItem,
        cast(const(char)**)array.ptr,
        items.length.as!int,
        maxHeightInItems
    );
}

bool igListBox(string label, string[] items, int* currentItem, int maxHeightInItems = 3) {

    char*[] array = items.map!(it=>toStringz(it))
                         .map!(it=>it.as!(char*))
                         .array;

    return igListBoxStr_arr(
        toStringz(label),
        currentItem,
        cast(const(char)**)array.ptr,
        items.length.as!int,
        maxHeightInItems);
}

bool igMenuItem(const (char)* label, const (char)* shortcut, bool selected=false) {
    return igMenuItemBool(label, shortcut, selected, true);
}

// Helper to display a little (?) mark which shows a tooltip when hovered.
// In your own code you may want to display an actual icon if you are using a merged icon fonts (see docs/FONTS.md)
void igHelpMarker(const (char)* desc)
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

ImVec2 igoCalcTextSize(const (char)* text) {
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
uint igGetColorU32(ImGuiCol idx, float alpha_mul = 1.0) {
    return igGetColorU32Col(idx, alpha_mul);
}


void igPushStyleVar(ImGuiStyleVar var, float f) {
    igPushStyleVarFloat(var, f);
}
void igPushStyleVar(ImGuiStyleVar var, ImVec2 vec) {
    igPushStyleVarVec2(var, vec);
}

bool igoIsKeyPressed(int key) {
    return igIsKeyPressed(key, false);
}