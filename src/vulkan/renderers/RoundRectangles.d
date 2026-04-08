module vulkan.renderers.RoundRectangles;

import vulkan.all;

final class RoundRectangles {
public:
    this(VulkanContext context, uint maxRects) {
        this.context  = context;
        this.maxRects = maxRects;

        createObjects();
    }
    void destroy() {
        if(ubo) ubo.destroy();
        if(rectangles) rectangles.destroy();
        if(pipeline) pipeline.destroy();
        if(descriptors) descriptors.destroy();
    }
    auto initialise() {
        assert(!isInitialised, "initialise() has already been called");
        pipeline.build();
        isInitialised = true;
        return this;
    }
    auto camera(Camera2D camera) {
        ubo.write((u) {
            u.viewProj = camera.VP();
        });
        return this;
    }
    auto setScissors(VkRect2D[] scissors) {
        assert(hasDynamicScissors, "Call withDynamicScissors() before initialise() to use dynamic scissors");
        this.dynamicScissors = scissors;
        return this;
    }
    /** Use this to adjust the GraphicsPipeline before calling initialise() */
    GraphicsPipeline withPipeline() {
        return pipeline;
    }
    /** Enable dynamic scissors */
    auto withDynamicScissors(VkRect2D[] initialScissors) {
        assert(!isInitialised);
        this.hasDynamicScissors = true;
        this.dynamicScissors = initialScissors;
        pipeline.addDynamicStates([VK_DYNAMIC_STATE_SCISSOR]);
        return this;
    }
    auto setColour(RGBA c) {
        this.colour = c;
        return this;
    }
    uint add(float2 pos, float2 size, float cornerRadius) {
        return add(pos, size, colour, colour, colour, colour, cornerRadius);
    }
    uint add(float2 pos, float2 size,
             RGBA c1, RGBA c2, RGBA c3, RGBA c4,
             float cornerRadius)
    {
        uint id = freeList.acquire();
        freeList.setViaId(id, Rectangle(pos, size, c1, c2, c3, c4, cornerRadius));
        return id;
    }
    auto update(uint id, float2 pos, float2 size,
                RGBA c1, RGBA c2, RGBA c3, RGBA c4,
                float cornerRadius)
    {
        freeList.setViaId(id, Rectangle(pos, size, c1, c2, c3, c4, cornerRadius));
        return this;
    }
    /** Update the position and size of an existing rectangle */ 
    void update(uint id, float2 pos, float2 size) {
        auto ptr = freeList.mapViaId(id);
        ptr.pos = pos;
        ptr.size = size;
    }
    auto updateColour(uint id, RGBA c1, RGBA c2, RGBA c3, RGBA c4) {
        auto ptr = freeList.mapViaId(id);
        ptr.c1 = c1;
        ptr.c2 = c2;
        ptr.c3 = c3;
        ptr.c4 = c4;
        return this;
    }
    auto remove(uint id) {
        freeList.release(id);
        return this;
    }
    auto clear() {
        rectangles.memset(0, maxRects);
        freeList.reset();
        return this;
    }
    void beforeRenderPass(Frame frame) {
        assert(isInitialised, "initialise() has not been called");
        auto res = frame.resource;

        rectangles.upload(res.adhocCB);
        ubo.upload(res.adhocCB);
    }
    void insideRenderPass(Frame frame) {
        if(freeList.numUsed()==0) return;

        auto res = frame.resource;
        auto b = res.adhocCB;

        b.bindPipeline(pipeline);

        if(hasDynamicScissors) {
            assert(dynamicScissors.length > 0, "No scissors have been set");
            b.setScissor(0, dynamicScissors);
        }
        
        b.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_GRAPHICS,
            pipeline.layout,
            0,                          // first set
            [descriptors.getSet(0,0)],  // descriptor sets
            null                        // dynamicOffsets
        );
        b.bindVertexBuffers(
            0,                                      // first binding
            [rectangles.getDeviceBuffer().handle],  // buffers
            [rectangles.getDeviceBuffer().offset]); // offsets

        // Draw rectangles
        b.draw(freeList.numUsed(), 1, 0, 0);
    }
private:
    static struct Rectangle {
        float2 pos;
        float2 size;
        RGBA c1,c2,c3,c4;
        float radius;
    }
    static struct UBO {
        mat4 viewProj;
    }

    @Borrowed VulkanContext context;
    GraphicsPipeline pipeline;
    Descriptors descriptors;

    const uint maxRects;
    GPUData!UBO ubo;
    GPUData!Rectangle rectangles;
    GPUDataFreeList!Rectangle freeList;
    bool isInitialised;

    RGBA colour = WHITE;

    // Dynamic state (optional)
    bool hasDynamicScissors;
    VkRect2D[] dynamicScissors;

    void createObjects() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true).initialise();
        this.rectangles = new GPUData!Rectangle(context, BufID.VERTEX, true, maxRects)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .initialise();

        this.freeList = new GPUDataFreeList!Rectangle(rectangles);    

        descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VK_SHADER_STAGE_GEOMETRY_BIT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(ubo)
                   .write();

        pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Rectangle(VK_PRIMITIVE_TOPOLOGY_POINT_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withStdColorBlendState()
            .withVertexShader(context.shaders.getModule("vulkan/rectangles/round_rectangles.vert"))
            .withGeometryShader(context.shaders.getModule("vulkan/rectangles/round_rectangles.geom"))
            .withFragmentShader(context.shaders.getModule("vulkan/rectangles/round_rectangles.frag"));

        // Zero all rectangle data
        clear();
    }
}
