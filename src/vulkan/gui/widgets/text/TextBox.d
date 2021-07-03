module vulkan.gui.widgets.text.TextBox;

import vulkan.gui;

final class TextBox : Label {
private:
    @Borrowed Text textRenderer;
    @Borrowed Font font;

    string text;
public:
    this() {
        super("");
    }
private:
    void initialise() {
        auto stage = getStage();
        auto context = stage.getContext();
        this.props.setParent(stage.props);
        this.textRenderer = stage.getTextRenderer(props.getFontName(), layer);
        this.font = context.fonts().get(props.getFontName());

        auto textRect = font.sdf.getRect(text, props.getFontSize()).to!int;

        auto pos  = getAbsPos();
        auto size = this.size.max(textRect.dimension().to!uint);
        this.setSize(size);

        textRenderer
            .setSize(props.getFontSize())
            .setColour(props.getFgColour());

        uint x,y;

        this.textId = textRenderer.add(text, x, y);
    }
    void update() {
        auto stage = getStage();
        todo();
    }
}