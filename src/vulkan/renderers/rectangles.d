module vulkan.renderers.Rectangles;

import vulkan.all;

final class Rectangles {
private:
    VulkanContext context;

    GraphicsPipeline pipeline;
    Descriptors descriptors;
    int maxRects;
    RGBA colour = WHITE;

    GPUData!UBO ubo;
    GPUData!Vertex vertices;
    uint[UUID] uuid2Index;

    static struct Vertex { static assert(Vertex.sizeof==24);
        vec2 pos;
        RGBA colour;
    }
    static struct UBO {
        mat4 viewProj;
    }
public:
    this(VulkanContext context, int maxRects) {
        this.context  = context;
        this.maxRects = maxRects;
        initialise();
    }
    void destroy() {
        if(ubo) ubo.destroy();
        if(vertices) vertices.destroy();
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
    auto add(float2 p1, float2 p2, float2 p3, float2 p4) {
        return add(p1,p2,p3,p4, colour, colour, colour, colour);
    }
    auto add(float2 p1, float2 p2, float2 p3, float2 p4,
             RGBA c1, RGBA c2, RGBA c3, RGBA c4)
    {
        vkassert(numRectangles() < maxRects);
        auto uuid = randomUUID();
        uuid2Index[uuid] = uuid2Index.length.as!uint;
        return updateRect(uuid, p1,p2,p3,p4, c1,c2,c3,c4);
    }
    UUID updateRect(return UUID uuid,
                    float2 p1, float2 p2, float2 p3, float2 p4,
                    RGBA c1, RGBA c2, RGBA c3, RGBA c4)
    {
        auto index = uuid2Index[uuid];
        index*=6;
        // 1-2  (124), (234)
        // |/|
        // 4-3
        vertices.write((v) { *v = Vertex(p1,c1); }, index);
        vertices.write((v) { *v = Vertex(p2,c2); }, index+1);
        vertices.write((v) { *v = Vertex(p4,c4); }, index+2);

        vertices.write((v) { *v = Vertex(p2,c2); }, index+3);
        vertices.write((v) { *v = Vertex(p3,c3); }, index+4);
        vertices.write((v) { *v = Vertex(p4,c4); }, index+5);

        return uuid;
    }
    auto remove(UUID uuid) {
        uint index = uuid2Index[uuid];
        uuid2Index.remove(uuid);

        auto count = uuid2Index.length - index;
        if(count > 0) {
            auto dest = vertices.map();
            auto src = dest+1;

            memmove(dest, src, Vertex.sizeof*count);
        }

        return this;
    }
    uint numRectangles() {
        return uuid2Index.length.as!uint;
    }
    auto clear() {
        vertices.memset(0, numRectangles());
        uuid2Index.clear();
        return this;
    }
    void beforeRenderPass(Frame frame) {
        auto res = frame.resource;

        ubo.upload(res.adhocCB);
        vertices.upload(res.adhocCB);
    }
    void insideRenderPass(Frame frame) {
        if(numRectangles()==0) return;

        auto res = frame.resource;
        auto b = res.adhocCB;

        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VPipelineBindPoint.GRAPHICS,
            pipeline.layout,
            0,                          // first set
            [descriptors.getSet(0,0)],  // descriptor sets
            null                        // dynamicOffsets
        );
        b.bindVertexBuffers(
            0,                      // first binding
            [vertices.getDeviceBuffer().handle],  // buffers
            [vertices.getDeviceBuffer().offset]); // offsets
        b.draw(numRectangles()*6, 1, 0, 0);
    }
private:
    void initialise() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true).initialise();
        this.vertices = new GPUData!Vertex(context, BufID.VERTEX, true, maxRects*6)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .initialise();

        descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VShaderStage.VERTEX)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(ubo)
                   .write();

        pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VPrimitiveTopology.TRIANGLE_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withVertexShader(context.vk.shaderCompiler.getModule("geom2d/rectangles_vert.spv"))
            .withFragmentShader(context.vk.shaderCompiler.getModule("geom2d/rectangles_frag.spv"))
            .withStdColorBlendState()
            .build();
    }
}
