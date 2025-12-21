module vulkan.gui.widgets.tabs.Tab;

import vulkan.gui;

/**
 * ┌───┐
 * |xxx└───┐
 * |       |
 * |       |
 * └───────┘
 */
final class Tab : Widget {
private:
    @Borrowed RoundRectangles roundRectangles ;
    @Borrowed Rectangles rectangles;
    string labelText;

    uint[] ids;
public:
    this(string label) {
        this.labelText = label;
        this.props = new GUIProps(null);
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
private:
    void initialise() {
        auto stage = getStage();
        throwIf(context !is null);
        throwIf(!parent.isA!TabBar);

        this.context = stage.getContext();
        this.props.setParent(stage.props);
        this.roundRectangles = stage.getRoundRectangles(layer-1);
        this.rectangles = stage.getRectangles(layer-1);

        auto pos = getAbsPos();

        // Create label
        auto label = new Label(labelText);
        label.setSize(uint2(60, 20))
             .setRelPos(int2(0, 0));

        // transparent
        label.props.setBgColour(RGBA(1,1,1,0));

        // Background
        auto c = RGBA(0.4,0.6,0.25,1) * RGBA(0.75,0.75,0.75,1);


        auto p = pos.to!float;
        auto p2 = p + float2(0, 20);  // top left of larger rectangle
        auto p3 = p + float2(0, 10);  // top left of bottom section of tab label

        ids ~= roundRectangles.add(p, float2(100,20), c, c, c, c, 10);
        ids ~= roundRectangles.add(p2, float2(300,300), c, c, c, c, 10);

        rectangles.setColour(c);

        ids ~= rectangles.add(p3, p3 + float2(100, 0), p3 + float2(100, 20), p3 + float2(0, 20));

        add(label);
    }
    void update() {
        auto stage = getStage();
        todo();
    }
}
