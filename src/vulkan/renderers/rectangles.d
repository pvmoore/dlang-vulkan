module vulkan.renderers.rectangles;
/**
 *
 */
import vulkan.all;

final class Rectangles {
private:
    VulkanContext context;

    GraphicsPipeline pipeline;
    Descriptors descriptors;
    int maxRects;
    RGBA colour = WHITE;

    uint numRects;
    GPUData!UBO ubo;
    GPUData!Vertex vertices;

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
    auto setCamera(Camera2D camera) {
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
    auto addRect(vec2 p1, vec2 p2, vec2 p3, vec2 p4) {
        return addRect(p1,p2,p3,p4, colour, colour, colour, colour);
    }
    auto addRect(vec2 p1, vec2 p2, vec2 p3, vec2 p4,
                 RGBA c1, RGBA c2, RGBA c3, RGBA c4)
    {
        expect(++numRects <= maxRects);
        return updateRect(numRects-1, p1,p2,p3,p4, c1,c2,c3,c4);
    }
    auto updateRect(uint index, vec2 p1, vec2 p2, vec2 p3, vec2 p4,
                                RGBA c1, RGBA c2, RGBA c3, RGBA c4)
    {
        expect(index<numRects);
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

        return this;
    }
    auto clear() {
        vertices.memset(0, numRects);
        return this;
    }
    void beforeRenderPass(Frame frame) {
        auto res = frame.resource;

        ubo.upload(res.adhocCB);
        vertices.upload(res.adhocCB);
    }
    void insideRenderPass(Frame frame) {
        if(numRects==0) return;

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
        b.draw(numRects*6, 1, 0, 0);
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

