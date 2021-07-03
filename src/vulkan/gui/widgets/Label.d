module vulkan.gui.widgets.Label;

import vulkan.gui;

class Label : Widget, IHAlignVAlign {
protected:
    @Borrowed Text textRenderer;
    @Borrowed RoundRectangles roundRectangles;
    @Borrowed Rectangles rectangles;
    @Borrowed Font font;

    string text;
    HAlign halign = HAlign.CENTRE;
    VAlign valign = VAlign.CENTRE;

    Text.Formatter textFormatter;
    UUID rectId;
    uint textId;
public:
    this(string text) {
        this.text = text;
        this.props = new GUIProps(null);
    }
    @Implements("IHAlignVAlign") override
    IHAlignVAlign setHAlign(HAlign alignment) {
        this.halign = alignment;
        return this;
    }
    @Implements("IHAlignVAlign") override
    IHAlignVAlign setVAlign(VAlign alignment) {
        this.valign = alignment;
        return this;
    }
    auto setText(string text) {
        todo("handle text change");
        return this;
    }
    auto setTextFormatter(Text.Formatter formatter) {
        this.textFormatter = formatter;
        return this;
    }
    override void destroy() {

    }
    override void onUpdate(Frame frame, UpdateState state) {
        switch(state) with(UpdateState) {
            case INIT: initialise(); break;
            case UPDATE: update(); break;
            default:
                break;
        }
    }
protected:

private:
    void update() {
        auto stage = getStage();
        todo();
    }
    void initialise() {
        auto stage = getStage();
        this.context = stage.getContext();
        this.props.setParent(stage.props);
        this.textRenderer = stage.getTextRenderer(props.getFontName(), layer);
        this.roundRectangles = stage.getRoundRectangles(layer);
        this.rectangles = stage.getRectangles(layer);
        this.font = context.fonts().get(props.getFontName());

        auto textRect = font.sdf.getRect(text, props.getFontSize()).to!int;

        auto pos  = getAbsPos();
        auto size = this.size.max(textRect.dimension().to!uint);
        this.setSize(size);

        auto tl   = pos;
        auto tr   = pos+int2(size.x,0);
        auto br   = pos+size.to!int;
        auto bl   = pos+int2(0,size.y);

        uint x,y;
        if(halign == HAlign.CENTRE) {
            x = pos.x + size.x/2 - textRect.width/2;
        } else if(halign == HAlign.LEFT) {
            x = pos.x + props.getPadding();
        } else {
            x = tr.x - props.getPadding() - textRect.width;
        }
        if(valign == VAlign.CENTRE) {
            y = pos.y + size.y/2 - (textRect.height)/2;
        } else if(valign == VAlign.TOP) {
            y = pos.y + props.getPadding();
        } else {
            y = bl.y - props.getPadding() - textRect.height;
        }

        rectangles.setColour(props.getBgColour());
        this.rectId = rectangles.add(tl.to!float, tr.to!float, br.to!float, bl.to!float);

        textRenderer
            .setSize(props.getFontSize())
            .setColour(props.getFgColour());

        this.textId = textRenderer.add(text, textFormatter, x, y);
    }
}