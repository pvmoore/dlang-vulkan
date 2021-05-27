module vulkan.gui.Stage;

import vulkan.all;
import vulkan.gui;

final class Stage : Widget {
private:
    @Borrowed Vulkan vk;
    @Borrowed VkDevice device;
    @Borrowed VulkanContext context;
    @Borrowed Camera2D _camera;
    //Animations animations = new Animations();
    Hook[] afterUpdateHooks;
    VkSampler sampler;
    RendererFactory canvas;
public:
    alias Hook = void delegate();
    Camera2D getCamera() { return _camera; }
    //Animations getAnimations() { return animations; }

    VulkanContext getContext() {
        return context;
    }
    auto getSampler() {
        if(!sampler) {
            sampler = device.createSampler(samplerCreateInfo());
        }
        return sampler;
    }
    auto getTextRenderer(string fontName, int layer) {
        return canvas.layer(layer).getText(fontName);
    }
    auto getImageRenderer(string imageName, int layer) {
        return canvas.layer(layer).getQuads(imageName);
    }
    auto getRoundRectangles(int layer) {
        return canvas.layer(layer).getRoundRectangles();
    }
    auto getRectangles(int layer) {
        return canvas.layer(layer).getRectangles();
    }
    int getMaxDepth() {
        todo();
        return 0;
    }
    int getMinDepth() {
        todo();
        return 0;
    }

    void addAfterUpdateHook(Hook h) { afterUpdateHooks ~= h; }

    this(VulkanContext context, GUIProps props) {
        this.context = context;
        this.vk = context.vk;
        this.device = context.device;
        this.props = props;
        this.canvas = new RendererFactory(context )
            .withMaxLines(200)
            .withMaxCircles(200)
            .withMaxRectangles(200)
            .withMaxRoundRectangles(200)
            .withMaxPoints(200)
            .withMaxQuads(200)
            .withMaxCharacters(2000)
            .camera(_camera);
    }
    override void destroy() {
        foreach(c; children) {
            c.fireDestroy();
        }
        if(canvas) canvas.destroy();
        if(sampler) device.destroySampler(sampler);
    }
    void camera(Camera2D camera) {
        this._camera = camera;
        this.canvas.camera(camera);
    }
    override void update(Frame frame) {
        assert(_camera);

        //animations.update(frame.delta);

        canvas.beforeRenderPass(frame);

        // Update children in reverse order
        foreach_reverse(c; children) {
            c.fireUpdate(frame);
        }

        if(afterUpdateHooks.length > 0) {
            foreach(hook; afterUpdateHooks) {
                hook();
            }
            afterUpdateHooks.length = 0;
        }
    }
    override void render(Frame frame) {

        canvas.insideRenderPass(frame);

        foreach(c; children) {
            c.fireRender(frame);
        }
    }
}