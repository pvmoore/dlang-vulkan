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
public:
    this(VulkanContext context,
        string fontName="arial",
        string suffix="fps",
        RGBA colour=RGBA(1,1,0.7,1),
        int x=-1,
        int y=-1)
    {
        this.context = context;
        this.camera = Camera2D.forVulkan(context.vk.windowSize);
        this.suffix = suffix;
        this.text   = new Text(context, context.fonts.get(fontName), true, 100);

        if(x==-1 || y==-1) {
            x = context.vk.windowSize.width-155;
            y = 5;
        }
        text.setCamera(camera);
        text.setColour(colour);
        text.setSize(28);
        text.appendText(".....", x,y);
    }
    void destroy() {
        text.destroy();
    }
    void beforeRenderPass(PerFrameResource res, float value) {
        text.replaceText("%.2f %s".format(value, suffix));
        text.beforeRenderPass(res);
    }
    void insideRenderPass(PerFrameResource res) {
        text.insideRenderPass(res);
    }
}

