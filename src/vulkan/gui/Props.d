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
    this(GUIProps parent) {
        this.parent = parent.orElse(new GUIProps());
    }
    void setParent(GUIProps parent) {
        this.parent = parent;
    }
    auto getFgColour() {
        return firstOrElse([fgColour, parent.fgColour], WHITE);
    }
    void setFgColour(RGBA c) {
        this.fgColour = opt(c);
    }
    auto getBgColour() {
        return firstOrElse([bgColour, parent.bgColour], RGBA(0.3, 0.25, 0.18, 1.0));
    }
    void setBgColour(RGBA c) {
        this.bgColour = opt(c);
    }
    auto getFontName() {
        return firstOrElse([fontName, parent.fontName], "roboto-regular");
    }
    void setFontName(string fontName) {
        this.fontName = fontName;
    }
    auto getFontSize() {
        return firstOrElse([fontSize, parent.fontSize], 16);
    }
    void setFontSize(float size) {
        this.fontSize = opt(size);
    }
    auto getBorderSize() {
        return firstOrElse([borderSize, parent.borderSize], 1);
    }
    void setBorderSize(uint size) {
        this.borderSize = opt(size);
    }
    auto getPadding() {
        return firstOrElse([padding, parent.padding], 2);
    }
    void setPadding(uint p) {
        this.padding = opt(p);
    }
}