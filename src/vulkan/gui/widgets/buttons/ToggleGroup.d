module vulkan.gui.widgets.buttons.ToggleGroup;

import vulkan.gui;

final class ToggleGroup {
private:
    Set!ToggleButton buttons;
    ToggleCallback[] callbacks;
public:
    alias ToggleCallback = void delegate(ToggleButton button);

    this() {
        this.buttons = new Set!ToggleButton;
    }
    auto add(Widget b) {
        auto tb = b.as!ToggleButton;
        throwIf(tb is null);

        this.buttons.add(tb);
        tb.setToggleGroup(this);
        return this;
    }
    auto setToggled(Widget button) {
        throwIf(!button.isA!ToggleButton);
        button.as!ToggleButton.toggle();
        return this;
    }
    /**
     * @return true if the toggle should proceed
     */
    bool toggleRequested(ToggleButton button) {
        // Untoggle other buttons
        foreach(b; buttons.keys()) {
            if(b !is button) {
                b.untoggle();
            }
        }
        // Call listeners
        foreach(c; callbacks) {
            c(button);
        }

        return !button.isClicked;
    }
    auto onToggle(ToggleCallback d) {
        this.callbacks ~= d;
        return this;
    }
}
