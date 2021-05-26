module vulkan.gui.GUI;

import vulkan.all;
import vulkan.gui;

final class GUI {
private:
    @Borrowed Vulkan vk;
    @Borrowed VkDevice device;
    @Borrowed VulkanContext context;
    Stage stage;
    GUIProps props;
public:
    Stage getStage() { return stage; }
    auto getProps()  { return props; }

    this(VulkanContext context) {
        this.context = context;
        this.vk      = context.vk;
        this.device  = context.device;
        this.props   = initProps();
        this.stage   = new Stage(context, props);
        stage.setRelPos(int2(0,0));
        stage.setSize(vk.windowSize().to!int);
    }
    void destroy() {
        if(stage) stage.destroy();
    }
    void camera(Camera2D camera) {
        stage.camera(camera);
    }
    void beforeRenderPass(Frame frame) {
        stage.update(frame);
    }
    void insideRenderPass(Frame frame) {
        stage.render(frame);
    }
private:
    GUIProps initProps() {
        auto p = new GUIProps(null);
        return p;
    }
}