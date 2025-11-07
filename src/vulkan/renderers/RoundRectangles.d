module vulkan.renderers.RoundRectangles;

import vulkan.all;

final class RoundRectangles {
public:
    this(VulkanContext context, uint maxRects) {
        this.context  = context;
        this.maxRects = maxRects;
        this.numRectsToDraw = 0;
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
    UUID add(float2 pos, float2 size, float cornerRadius) {
        return add(pos, size, colour, colour, colour, colour, cornerRadius);
    }
    UUID add(float2 pos, float2 size,
             RGBA c1, RGBA c2, RGBA c3, RGBA c4,
             float cornerRadius)
    {
        auto a = alloc();
        auto uuid = a[0];
        auto index = a[1];

        rectangles.write((r) {
            *r = Rectangle(pos, size, c1, c2, c3, c4, cornerRadius);
        }, index);

        return uuid;
    }
    auto update(UUID uuid, vec2 pos, vec2 size,
                RGBA c1, RGBA c2, RGBA c3, RGBA c4,
                float cornerRadius)
    {
        auto index = uuid2Index[uuid];

        rectangles.write((r) {
            *r = Rectangle(pos, size, c1, c2, c3, c4, cornerRadius);
        }, index);

        return this;
    }
    auto updateColour(UUID uuid, RGBA c1, RGBA c2, RGBA c3, RGBA c4) {
        auto index = uuid2Index[uuid];

        rectangles.write((r) {
            r.c1 = c1;
            r.c2 = c2;
            r.c3 = c3;
            r.c4 = c4;
        }, index);

        return this;
    }
    auto remove(UUID uuid) {
        uint index = dealloc(uuid);

        rectangles.write((r) { r.radius = 0; }, index);
        uuid2Index.remove(uuid);

        return this;
    }
    auto clear() {
        rectangles.memset(0, maxRects);
        uuid2Index.clear();
        freeList.reset();
        numRectsToDraw = 0;
        return this;
    }
    void beforeRenderPass(Frame frame) {
        auto res = frame.resource;

        rectangles.upload(res.adhocCB);
        ubo.upload(res.adhocCB);
    }
    void insideRenderPass(Frame frame) {
        if(numRectsToDraw==0) return;

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
        b.draw(numRectsToDraw, 1, 0, 0);
    }
private:
    static struct Rectangle {
        vec2 pos;
        vec2 size;
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

    uint[UUID] uuid2Index;
    FreeList freeList;
    uint numRectsToDraw;

    RGBA colour = WHITE;

    auto alloc() {
        throwIf(freeList.numFree() == 0);
        UUID uuid = randomUUID();
        uint index = freeList.acquire();
        uuid2Index[uuid] = index;
        numRectsToDraw = maxOf(numRectsToDraw, index+1);
        return tuple(uuid, index);
    }
    uint dealloc(UUID uuid) {
        uint index = uuid2Index[uuid];
        uuid2Index.remove(uuid);
        freeList.release(index);
        if(index+1==numRectsToDraw) {
            numRectsToDraw = uuid2Index.values().maxElement()+1;
        }
        return index;
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
            .withVertexShader(context.shaders.getModule("vulkan/geom2d/round_rectangles.vert"))
            .withGeometryShader(context.shaders.getModule("vulkan/geom2d/round_rectangles.geom"))
            .withFragmentShader(context.shaders.getModule("vulkan/geom2d/round_rectangles.frag"))
            .build();
    }
}
