module vulkan.renderers.Sprite;

import vulkan.all;

/**
 * Sprite represents an animated quad using a spritesheet.
 */
final class Sprite {
public:
    enum EndAction {
        REPEAT, NEXT
    }
    static struct Animation {
        string id;
        AnimationFrame[] frames;
        EndAction endAction = EndAction.NEXT;
        string nextAnimationId;
    }
    static struct AnimationFrame {
        float2 topLeftUV;
        float2 bottomRightUV;
        float durationSeconds;
        //RGBA colour = WHITE;
    }

    this(VulkanContext context, ImageMeta spriteSheet, uint startFrame = 0) {
        this.context = context;
        this.device = context.device;
        this.spriteSheet = spriteSheet;
        initialise();
    }
    void destroy() {
        if(sampler) device.destroySampler(sampler);
        if(quad) quad.destroy();
    }
    auto camera(Camera2D camera) {
        this.camera2d = camera;
        this.quad.setVP(modelMatrix, camera2d.V(), camera.P());
        return this;
    }
    auto model(mat4 model) {
        this.modelMatrix = model;
        this.quad.setVP(model, camera2d.V(), camera2d.P());
        return this;
    }
    auto addAnimation(Animation animation) {
        this.animations[animation.id] = animation;
        return this;
    }
    auto changeState(string state, uint startIndex, void delegate(Sprite) whenComplete = null) {
        throwIf(state !in animations);
        throwIf(startIndex >= animations[state].frames.length);

        this.state = state;
        this.frameIndex = startIndex;
        this.whenComplete = whenComplete;
        this.currentFrame = animations[state].frames[startIndex];
        return this;
    }
    void beforeRenderPass(Frame frame) {
        // Wait for animations to be set
        if(state is null) return;


        while(lastChangeTime+currentFrame.durationSeconds <= frame.seconds) {
            lastChangeTime += currentFrame.durationSeconds;
            updateAnimationFrame();
        }

    }
    void insideRenderPass(Frame frame) {
        if(state is null) return;

        quad.insideRenderPass(frame);
    }
private:
    @Borrowed VulkanContext context;
    @Borrowed VkDevice device;
    @Borrowed ImageMeta spriteSheet;
    @Borrowed Camera2D camera2d;
    Quad quad;
    mat4 modelMatrix;
    VkSampler sampler;

    Animation[string] animations;
    Animation animation;
    AnimationFrame currentFrame;
    uint frameIndex;
    double lastChangeTime = 0; // frame.seconds when last animationFrame was selected
    string state;

    void delegate(Sprite) whenComplete;

    void initialise() {
        modelMatrix = mat4.identity();
        createSampler();
        createQuad();
    }
    void createSampler() {

    }
    void createQuad() {

    }
    void updateAnimationFrame() {
        frameIndex++;
        if(frameIndex >= animation.frames.length) {
            frameIndex = 0;
            
            if(whenComplete) {
                whenComplete(this);
                whenComplete = null;
            }

            final switch(animation.endAction) with(EndAction) {
                case REPEAT:
                    break;
                case NEXT:
                    state = animation.nextAnimationId;
                    if(state is null) return;

                    animation = animations[state];
                    currentFrame = animation.frames[frameIndex];
                    break;
            }
        }
        currentFrame = animations[state].frames[frameIndex];

        // change quad.uv here
    }
}