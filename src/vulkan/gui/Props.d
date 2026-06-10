module vulkan.gui.Props;

import vulkan.gui;

final class GUIProps {
private:
    GUIProps parent;

    string fontName;
    optional!RGBA bgColour;
    optional!RGBA fgColour;
    optional!float fontSize;
    optional!uint borderSize;
    optional!uint padding;

    this() {}
public:
    bool isModified = true;

    this(GUIProps parent) {
        this.parent = parent.orElse(new GUIProps());
    }
    void setParent(GUIProps parent) {
        this.parent = parent;
        this.isModified = true;
    }
    //======================================================================================
    auto getFgColour() {
        return firstOrElse([fgColour, parent.fgColour], WHITE);
    }
    auto setFgColour(RGBA c) {
        this.fgColour = optional!RGBA(c);
        this.isModified = true;
        return this;
    }
    auto getBgColour() {
        return firstOrElse([bgColour, parent.bgColour], RGBA(0.3, 0.25, 0.18, 1.0));
    }
    auto setBgColour(RGBA c) {
        this.bgColour = optional!RGBA(c);
        this.isModified = true;
        return this;
    }
    auto getFontName() {
        return firstOrElse([fontName, parent.fontName], "roboto-regular");
    }
    auto setFontName(string fontName) {
        this.fontName = fontName;
        this.isModified = true;
        return this;
    }
    auto getFontSize() {
        return firstOrElse([fontSize, parent.fontSize], 16f);
    }
    auto setFontSize(float size) {
        this.fontSize = optional!float(size);
        this.isModified = true;
        return this;
    }
    auto getBorderSize() {
        return firstOrElse([borderSize, parent.borderSize], 1u);
    }
    auto setBorderSize(uint size) {
        this.borderSize = optional!uint(size);
        this.isModified = true;
        return this;
    }
    auto getPadding() {
        return firstOrElse([padding, parent.padding], 2u);
    }
    auto setPadding(uint p) {
        this.padding = optional!uint(p);
        this.isModified = true;
        return this;
    }
}
