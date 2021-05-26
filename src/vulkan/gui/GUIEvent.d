module vulkan.gui.GUIEvent;

import vulkan.gui;

enum GUIEventType : uint {
    CLICK,
    PRESS,
}

interface GUIEvent {
    GUIEventType getType();
    Widget getWidget();
}

alias GUIEventListener = void delegate(GUIEvent e);

final class OnClick : GUIEvent {
private:
    Widget widget;
    int2 mousePos;
    int button;
public:
    this(Widget widget, int2 mousePos, int button) {
        this.widget = widget;
        this.mousePos = mousePos;
        this.button = button;
    }
    override GUIEventType getType() {
        return GUIEventType.CLICK;
    }
    override Widget getWidget() {
        return widget;
    }
    int getButton() {
        return button;
    }
    int2 getMousePos() {
        return mousePos;
    }
}

final class OnPress : GUIEvent {
private:
    Widget widget;
    bool _isPressed;
public:
    this(Widget widget, bool isPressed) {
        this.widget = widget;
        this._isPressed = isPressed;
    }
    override GUIEventType getType() {
        return GUIEventType.PRESS;
    }
    override Widget getWidget() {
        return widget;
    }
    bool isPressed() {
        return _isPressed;
    }
}

