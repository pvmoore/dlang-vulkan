module vulkan.renderers.RoundRectangles;

import vulkan.all;

final class RoundRectangles {
public:
    this(VulkanContext context, uint maxRects) {
        this.context  = context;
        this.maxRects = maxRects;
        this.freeList = new FreeList(maxRects);

        initialise();
    }
    void destroy() {
        if(ubo) ubo.destroy();
        if(rectangles) rectangles.destroy();
        if(pipeline) pipeline.destroy();
        if(descriptors) descriptors.destroy();
    }
    auto camera(Camera2D camera) {
        ubo.write((u) {
            u.viewProj = camera.VP();
        });
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
        uint index = alloc();

        rectangles.write((r) {
            *r = Rectangle(pos, size, c1, c2, c3, c4, cornerRadius);
        }, index);

        return index;
    }
    auto update(uint index, float2 pos, float2 size,
                RGBA c1, RGBA c2, RGBA c3, RGBA c4,
                float cornerRadius)
    {
        rectangles.write((r) {
            *r = Rectangle(pos, size, c1, c2, c3, c4, cornerRadius);
        }, index);

        return this;
    }
    /** Update the position and size of an existing rectangle */ 
    void update(uint index, float2 pos, float2 size) {
        rectangles.write((r) {
            r.pos = pos;
            r.size = size;
        }, index);
    }
    auto updateColour(uint index, RGBA c1, RGBA c2, RGBA c3, RGBA c4) {

        rectangles.write((r) {
            r.c1 = c1;
            r.c2 = c2;
            r.c3 = c3;
            r.c4 = c4;
        }, index);

        return this;
    }
    auto remove(uint index) {
        // Zero the radius so the rectangle is not drawn
        rectangles.write((r) { r.radius = 0; }, index);
        dealloc(index);
        return this;
    }
    auto clear() {
        rectangles.memset(0, maxRects);
        freeList.reset();
        return this;
    }
    void beforeRenderPass(Frame frame) {
        auto res = frame.resource;

        rectangles.upload(res.adhocCB);
        ubo.upload(res.adhocCB);
    }
    void insideRenderPass(Frame frame) {
        if(freeList.numUsed()==0) return;

        auto res = frame.resource;
        auto b = res.adhocCB;

        b.bindPipeline(pipeline);
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

        // Draw all rectangles even if they are not active (inactive rectangles will have radius of 0)
        b.draw(maxRects, 1, 0, 0);
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
    FreeList freeList;

    RGBA colour = WHITE;

    uint alloc() {
        throwIf(freeList.numFree() == 0);
        return freeList.acquire();
    }
    void dealloc(uint index) {
        freeList.release(index);
    }
    void initialise() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true).initialise();
        this.rectangles = new GPUData!Rectangle(context, BufID.VERTEX, true, maxRects)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .initialise();

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
            .withFragmentShader(context.shaders.getModule("vulkan/rectangles/round_rectangles.frag"))
            .build();

        // Zero all rectangle data
        clear();
    }
}
