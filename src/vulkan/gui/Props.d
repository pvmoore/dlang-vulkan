module vulkan.gui.Props;

import vulkan.gui;

final class GUIProps {
private:
    GUIProps parent;

    Opt!RGBA bgColour;
    Opt!RGBA fgColour;
    string fontName;
    Opt!float fontSize;
    Opt!uint borderSize;
    Opt!uint padding;

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
        this.fgColour = opt(c);
        this.isModified = true;
        return this;
    }
    auto getBgColour() {
        return firstOrElse([bgColour, parent.bgColour], RGBA(0.3, 0.25, 0.18, 1.0));
    }
    auto setBgColour(RGBA c) {
        this.bgColour = opt(c);
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
        return firstOrElse([fontSize, parent.fontSize], 16);
    }
    auto setFontSize(float size) {
        this.fontSize = opt(size);
        this.isModified = true;
        return this;
    }
    auto getBorderSize() {
        return firstOrElse([borderSize, parent.borderSize], 1);
    }
    auto setBorderSize(uint size) {
        this.borderSize = opt(size);
        this.isModified = true;
        return this;
    }
    auto getPadding() {
        return firstOrElse([padding, parent.padding], 2);
    }
    auto setPadding(uint p) {
        this.padding = opt(p);
        this.isModified = true;
        return this;
    }
}