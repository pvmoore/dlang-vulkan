module vulkan.renderers.fps;
/**
 *
 */
import vulkan.all;

final class FPS {
    Vulkan vk;
    VkDevice device;
    Camera2D camera;
    Text text;
    string suffix;

    this(Vulkan vk,
         VkRenderPass renderPass,
         string suffix="fps",
         RGBA colour=RGBA(1,1,0.7,1),
         int x=-1,
         int y=-1)
    {
        this.vk     = vk;
        this.device = vk.device;
        this.camera = Camera2D.forVulkan(vk.windowSize);
        this.suffix = suffix;
        this.text   = new Text(
            vk,
            renderPass,
            vk.fonts.get("arial"),
            true,
            100
        );
        if(x==-1 || y==-1) {
            x = vk.windowSize.width-155;
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

