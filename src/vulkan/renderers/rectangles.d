module vulkan.renderers.Rectangles;

import vulkan.all;

final class Rectangles {
public:
    this(VulkanContext context, int maxRects) {
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
    /**
     *  Vertices are assumed to be clockwise eg.
     *  1-2
     *  | |
     *  4-3
     */
    uint add(float2 p1, float2 p2, float2 p3, float2 p4) {
        return add(p1,p2,p3,p4, colour, colour, colour, colour);
    }
    uint add(float2 p1, float2 p2, float2 p3, float2 p4,
             RGBA c1, RGBA c2, RGBA c3, RGBA c4)
    {
        throwIf(freeList.numFree() == 0, "No free rectangles");
        
        uint id = freeList.acquire();
        return updateRect(id, p1,p2,p3,p4, c1,c2,c3,c4);
    }
    uint updateRect(uint id,
                    float2 p1, float2 p2, float2 p3, float2 p4,
                    RGBA c1, RGBA c2, RGBA c3, RGBA c4)
    {
        // 1-2  (124), (234)
        // |/|
        // 4-3

        freeList.setViaId(id, Rectangle([
            Vertex(p1,c1), Vertex(p2,c2), Vertex(p4,c4),
            Vertex(p2,c2), Vertex(p3,c3), Vertex(p4,c4)
        ]));

        return id;
    }
    void updateRect(uint id, float2 p1, float2 p2, float2 p3, float2 p4) {
        auto ptr = freeList.mapViaId(id);
        ptr.vertices[0].pos = p1;
        ptr.vertices[1].pos = p2;
        ptr.vertices[2].pos = p4;
        ptr.vertices[3].pos = p2;
        ptr.vertices[4].pos = p3;
        ptr.vertices[5].pos = p4;
    }
    void updatePosition(uint id, float2 pos) {
        auto ptr = freeList.mapViaId(id);
        float2 p = ptr.vertices[0].pos;
        ptr.vertices[0].pos = pos;
        ptr.vertices[1].pos = pos + (ptr.vertices[1].pos - p);
        ptr.vertices[2].pos = pos + (ptr.vertices[2].pos - p);
        ptr.vertices[3].pos = pos + (ptr.vertices[3].pos - p);
        ptr.vertices[4].pos = pos + (ptr.vertices[4].pos - p);
        ptr.vertices[5].pos = pos + (ptr.vertices[5].pos - p);
    }
    auto remove(uint id) {
        freeList.release(id);
        return this;
    }
    auto clear() {
        rectangles.memset(0);
        freeList.reset();
        return this;
    }
    void beforeRenderPass(Frame frame) {
        auto res = frame.resource;

        ubo.upload(res.adhocCB);
        rectangles.upload(res.adhocCB);
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
            0,                      // first binding
            [rectangles.getDeviceBuffer().handle],  // buffers
            [rectangles.getDeviceBuffer().offset]); // offsets
   
        // Draw 6 vertices per rect
        b.draw(freeList.numUsed()*6, 1, 0, 0);
    }
private:
    @Borrowed VulkanContext context;
    const int maxRects;
    GraphicsPipeline pipeline;
    Descriptors descriptors;
    RGBA colour = WHITE;

    GPUData!UBO ubo;
    GPUData!Rectangle rectangles;
    GPUDataFreeList!Rectangle freeList;

    struct Vertex { static assert(Vertex.sizeof == 24);
        float2 pos;
        RGBA colour;
    }
    struct Rectangle { static assert(Rectangle.sizeof == Vertex.sizeof*6);
        Vertex[6] vertices;
    }
    struct UBO {
        mat4 viewProj;
    }

    void createObjects() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true).initialise();
        this.rectangles = new GPUData!Rectangle(context, BufID.VERTEX, true, maxRects)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .initialise();

        this.freeList = new GPUDataFreeList!Rectangle(rectangles);   

        descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VK_SHADER_STAGE_VERTEX_BIT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(ubo)
                   .write();

        pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withVertexShader(context.shaders.getModule("vulkan/rectangles/rectangles.vert"))
            .withFragmentShader(context.shaders.getModule("vulkan/rectangles/rectangles.frag"))
            .withStdColorBlendState()
            .build();

        // Zero all rectangle data
        clear();
    }
}
