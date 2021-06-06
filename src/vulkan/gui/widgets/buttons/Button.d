module vulkan.gui.widgets.buttons.Button;

import vulkan.gui;

class Button : Widget {
protected:
    @Borrowed VulkanContext context;
    @Borrowed RoundRectangles roundRects;
    @Borrowed Text textRenderer;
    @Borrowed Font font;

    string text;
    bool _isClicked;

    UUID rrId1, rrId2, textId;
    bool mouseIsInside;
    Text.Formatter fmt;
    int textX, textY;
    bool lmbHandled;
public:
    bool isClicked() {
        return _isClicked;
    }
    string getText() {
        return text;
    }
    auto setText(string text) {
        if(text != this.text) {
            this.text = text;
            if(isOnStage()) {
                textRenderer.replaceText(textId, text);
                textChanged(false);
                uiChanged();
            }
        }
        return this;
    }

    this(string text) {
        this.text = text;
        this.props = new GUIProps(null);
        this.fmt = (ref chunk, uint index) {
            return Text.CharFormat(
                props.getFgColour()+(mouseIsInside ? 0.3 : 0),
                props.getFontSize());
        };
    }
    override Button setLayer(int layer) {
        auto oldLayer = this.layer;
        super.setLayer(layer);

        // update renderers if layer has changed
        if(oldLayer != layer && !rrId1.empty) {
            roundRects.remove(rrId1);
            roundRects.remove(rrId2);
            textRenderer.remove(textId);
            initialiseRenderers();
        }

        return this;
    }
    override void destroy() {

    }
    override void update(Frame frame) {
        if(!isEnabled) return;

        MouseState m = context.vk.getMouseState();
        if(enclosesPoint(m.pos)) {
            if(!mouseIsInside) {
                hover(true);
            }
            mouseIsInside = true;
            bool lmb = context.vk.isMouseButtonPressed(0);

            if(lmb && !lmbHandled) {
                lmbHandled = true;
                handleMousePress();
            }
            if(!lmb && lmbHandled) {
                lmbHandled = false;
                handleMouseRelease();
            }
        } else {
            if(mouseIsInside) {
                hover(false);
            }
            mouseIsInside = false;
        }
    }
    override void render(Frame frame) {

    }
    override void onAddedToStage(Stage stage) {
        assert(!context);

        this.context = stage.getContext();
        this.props.setParent(stage.props);

        this.font = context.fonts().get(props.getFontName());

        initialiseRenderers();
    }
protected:
    void handleMousePress() {
        _isClicked = !_isClicked;
        if(isOnStage()) {
            uiChanged();
            fireEvent(new OnPress(this, _isClicked));
        }
    }
    void handleMouseRelease() {
        _isClicked = !_isClicked;
        uiChanged();
    }
    auto getBorderColours(bool hovering) {
        return hovering ?
        [
            props.getBgColour()+0.3,
            props.getBgColour()+0.8,
            props.getBgColour()+0.3,
            props.getBgColour()-0.1
        ] : [
            props.getBgColour()+0.1,
            props.getBgColour()+0.6,
            props.getBgColour()+0.1,
            props.getBgColour()-0.3
        ];
    }
    auto getBGColours() {
        return _isClicked ? [
            props.getBgColour()-0.0,
            props.getBgColour()-0.3,
            props.getBgColour()-0.0,
            props.getBgColour()+0.3
        ] : [
            props.getBgColour()+0.0,
            props.getBgColour()+0.3,
            props.getBgColour()+0.0,
            props.getBgColour()-0.3
        ];
    }
    void hover(bool flag) {
        auto c = getBorderColours(flag);
        roundRects.updateRectColour(rrId1, c[0], c[1], c[2], c[3]);
    }
    void textChanged(bool setSize) {
        auto textRect = font.sdf.getRect(text, props.getFontSize()).to!int;

        auto pos  = getAbsPos();
        uint2 size;
        if(setSize) {
            size = this.size.max(textRect.dimension().to!uint);
            this.setSize(size);
        } else {
            size = getSize();
        }

        this.textX = pos.x + size.x/2 - textRect.width/2;
        this.textY = pos.y + size.y/2 - (textRect.height)/2;
    }
    void uiChanged() {
        auto c = getBGColours();
        roundRects.updateRectColour(rrId2, c[0], c[1], c[2], c[3]);
        textRenderer.moveText(textId, textX, textY + (_isClicked ? 1 : 0));
    }
private:
    void initialiseRenderers() {
        auto stage = getStage();
        this.textRenderer = stage.getTextRenderer(props.getFontName(), layer);
        this.roundRects = stage.getRoundRectangles(layer);

        textChanged(true);

        uint bs = props.getBorderSize();
        auto bc = getBorderColours(false);
        auto bc2 = getBGColours();

        this.rrId1 = roundRects
            .add(pos.to!float, size.to!float, bc[0],bc[1],bc[2],bc[3], size.y/5);

        this.rrId2 = roundRects
            .add(pos.to!float+bs, size.to!float-bs*2, bc2[0],bc2[1],bc2[2],bc2[3], size.y/5);

        textRenderer
            .setSize(props.getFontSize())
            .setColour(props.getFgColour());

        this.textId = textRenderer.appendText(text, textX, textY);

        uiChanged();
    }
}