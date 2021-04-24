module vulkan.renderers.fps;
/**
 *
 */
import vulkan.all;

final class FPS {
private:
    VulkanContext context;
    Camera2D camera;
    Text text;
    string suffix;
    uint x,y;
public:
    this(VulkanContext context,
        string fontName = "arial",
        string suffix   = " fps",
        RGBA colour     = RGBA(1,1,0.7,1),
        int x           = -1,
        int y           = -1)
    {
        this.context = context;
        this.camera = Camera2D.forVulkan(context.vk.windowSize);
        this.suffix = suffix;
        this.text   = new Text(context, context.fonts.get(fontName), true, 100);

        if(x==-1 || y==-1) {
            x = context.vk.windowSize.width-155;
            y = 5;
        }
        this.x = x;
        this.y = y;
        text.camera(camera);
        text.setColour(colour);
        text.setSize(28);
        position(x,y);
    }
    auto size(float size) {
        text.setSize(size)
            .clear()
            .appendText("", x,y);
        return this;
    }
    auto position(uint x, uint y) {
        this.x = x;
        this.y = y;
        text.clear()
            .appendText("", x,y);
        return this;
    }
    auto colour(RGBA colour) {
        text.clear()
            .setColour(colour)
            .appendText("", x,y);
        return this;
    }
    void destroy() {
        text.destroy();
    }
    void beforeRenderPass(Frame frame, float value) {
        text.replaceText("%.2f%s".format(value, suffix));
        text.beforeRenderPass(frame);
    }
    void insideRenderPass(Frame frame) {
        text.insideRenderPass(frame);
    }
}

