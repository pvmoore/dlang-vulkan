module vulkan.gui.GUIEvent;

import vulkan.gui;

// Frame events

enum GUIFrameEventType {
    KEYPRESS,
    MOUSEBUTTON,
    MOUSEMOVE,
    MOUSEWHEEL,
    MOUSEENTER,
    ICONIFY,
    FOCUS
}

struct GUIFrameEvent {
    GUIFrameEventType type;
    Widget widget;
    int2 data1;
    int4 data2;

    static GUIFrameEvent keyPress(Widget w, uint keyCode, uint scanCode, KeyAction action, uint mods) {
        GUIFrameEvent e = {
            type: GUIFrameEventType.KEYPRESS,
            widget: w,
            data1: int2(keyCode, scanCode),
            data2: int4(action,0, mods,0)
        };
        return e;
    }
    static GUIFrameEvent mouseMove(Widget w, int x, int y) {
        GUIFrameEvent e = {
            type: GUIFrameEventType.MOUSEMOVE,
            widget: w,
            data1: int2(x,y)
        };
        return e;
    }
    static GUIFrameEvent mouseButton(Widget w, int x, int y, uint button, bool down, uint mods) {
        GUIFrameEvent e = {
            type: GUIFrameEventType.MOUSEBUTTON,
            widget: w,
            data1: int2(x,y),
            data2: int4(button, down, mods, 0)
        };
        return e;
    }
    static GUIFrameEvent mouseWheel(Widget w, int x, int y, float xdelta, float ydelta) {
        GUIFrameEvent e = {
            type: GUIFrameEventType.MOUSEWHEEL,
            widget: w,
            data1: int2(x,y),
            data2: int4(xdelta.as!int, ydelta.as!int, 0, 0)
        };
        return e;
    }
    static GUIFrameEvent mouseEnter(Widget w, int x, int y, bool isEnter) {
        GUIFrameEvent e = {
            type: GUIFrameEventType.MOUSEENTER,
            widget: w,
            data1: int2(x,y),
            data2: int4(isEnter,0,0,0)
        };
        return e;
    }
    static GUIFrameEvent iconify(Widget w, bool flag) {
        GUIFrameEvent e = {
            type: GUIFrameEventType.ICONIFY,
            widget: w,
            data1: int2(0,0),
            data2: int4(flag,0,0,0)
        };
        return e;
    }
    static GUIFrameEvent focus(Widget w, bool flag) {
        GUIFrameEvent e = {
            type: GUIFrameEventType.FOCUS,
            widget: w,
            data1: int2(0,0),
            data2: int4(flag,0,0,0)
        };
        return e;
    }
    int2 absMousePos() { return data1; }
    int2 relMousePos() { return data1 - widget.getAbsPos(); }
    KeyMod keyMods() { return data2.z.as!KeyMod; }
    bool isPress() { return data2.y!=0; }
    uint button() { return data2.x; }
    uint keyCode() { return data1.x; }
    uint scanCode() { return data1.y; }
    KeyAction keyAction() { return data2.x.as!KeyAction; }
    int wheelX() { return data2.x; }
    int wheelY() { return data2.y; }
    bool isEnter() { return data2.x!=0; }
    bool isIconified() { return data2.x!=0; }
    bool isFocussed() { return data2.x!=0; }
}
