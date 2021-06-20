module vulkan.gui.widgets.buttons.ToggleButton;

import vulkan.gui;

final class ToggleButton : Button {
private:
    string pressText, unpressText;
    ToggleGroup group;
public:
    this(string text, string text2) {
        this.pressText = text;
        this.unpressText = text2;
        super(text.length > text2.length ? text : text2);
    }
    auto setToggleGroup(ToggleGroup group) {
        this.group = group;
        return this;
    }
    void toggle() {
        if(!isClicked()) {
            doPress();
        }
    }
    void untoggle() {
        if(isClicked()) {
            doPress();
        }
    }
protected:
    override void handleMousePress() {
        if(group && !group.toggleRequested(this)) return;
        doPress();
    }
    override void handleMouseRelease() {
        // do nothing
    }
private:
    void doPress() {
        setText(isClicked() ? pressText : unpressText);
        super.handleMousePress();
    }
}