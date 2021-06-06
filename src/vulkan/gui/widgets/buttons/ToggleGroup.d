module vulkan.gui.widgets.buttons.ToggleGroup;

import vulkan.gui;

final class ToggleGroup {
private:
    Set!ToggleButton buttons;
    ToggleDelegate[] callbacks;
public:
    alias ToggleDelegate = void delegate(ToggleButton button);

    this() {
        this.buttons = new Set!ToggleButton;
    }
    auto add(Widget b) {
        auto tb = b.as!ToggleButton;
        assert(tb !is null);

        this.buttons.add(tb);
        tb.setToggleGroup(this);
        return this;
    }
    auto setToggled(Widget button) {
        assert(button.isA!ToggleButton);
        button.as!ToggleButton.toggle();
        return this;
    }
    /**
     * @return true if the toggle should proceed
     */
    bool toggleRequested(ToggleButton button) {
        // Untoggle other buttons
        foreach(b; buttons.values()) {
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
    auto onToggle(ToggleDelegate d) {
        this.callbacks ~= d;
        return this;
    }
}