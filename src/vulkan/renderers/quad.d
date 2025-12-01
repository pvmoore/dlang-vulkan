module vulkan.renderers.Quad;
/**
 *  A simple coloured, textured quad.
 *
 *  TODO - Make this work for multiple quads of the same image.
 */
import vulkan.all;

//static struct QuadData {
//    ufloat2 pos;
//    float2 uv;
//    float2 size;
//    RGBA colour;
//}

final class Quad {
private:
    struct Vertex { static assert(Vertex.sizeof==8*float.sizeof);
        float2 pos;
        float4 colour;
        float2 uv;
    }
    struct UBO { static assert(UBO.sizeof==3*16*4);
        mat4 model;
        mat4 view;
        mat4 proj;
    }
    @Borrowed VulkanContext context;
    @Borrowed ImageMeta imageMeta;
    @Borrowed VkSampler sampler;

    GraphicsPipeline pipeline;
    Descriptors descriptors;
    UBO ubo;
    SubBuffer vertexBuffer, indexBuffer, uniformBuffer;
public:

    this(VulkanContext context, ImageMeta imageMeta, VkSampler sampler) {
        throwIf(sampler is null);
        this.context   = context;
        this.imageMeta = imageMeta;
        this.sampler   = sampler;

        createBuffers();
        createDescriptorSets();
        createPipeline();
    }
    void destroy() {
        if(vertexBuffer) vertexBuffer.free();
        if(indexBuffer) indexBuffer.free();
        if(uniformBuffer) uniformBuffer.free();
        if(pipeline) pipeline.destroy();
        if(descriptors) descriptors.destroy();
    }
    void setVP(Matrix4 model, Matrix4 view, Matrix4 proj) {
        ubo.model = model;
        ubo.view  = view;
        ubo.proj  = proj;
        uploadUBO();
    }
    void setColour(RGBA c) {
        foreach(ref v; vertices) {
            v.colour = c;
        }
        uploadVertices();
    }
    void setUV(UV topLeft, UV bottomRight) {
        vertices[0].uv = topLeft;
        vertices[1].uv = UV(bottomRight.x, topLeft.y);
        vertices[2].uv = bottomRight;
        vertices[3].uv = UV(topLeft.x, bottomRight.y);
        uploadVertices();
    }
    void updateVP(Matrix4 view, Matrix4 proj) {
        ubo.view = view;
        ubo.proj = proj;
        uploadUBO();
    }
    void insideRenderPass(Frame frame) {
        auto res = frame.resource;
        auto b = res.adhocCB;

        b.bindPipeline(pipeline);

        b.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_GRAPHICS,
            pipeline.layout,
            0,      // first set
            [descriptors.getSet(0,0)],
            null    // dynamic offsets
        );
        b.bindVertexBuffers(
            0,                      // first binding
            [vertexBuffer.handle],  // buffers
            [vertexBuffer.offset]); // offsets
        b.bindIndexBuffer(
            indexBuffer.handle,
            indexBuffer.offset);

        // todo - draw many quads using the same image
        b.drawIndexed(6, 1, 0,0,0);
    }
private:
    ushort[] indices;
    Vertex[] vertices;

    void uploadUBO() {
        context.transfer().from(&ubo).to(uniformBuffer).size(UBO.sizeof);
    }
    void uploadVertices() {
        context.transfer().from(vertices.ptr).to(vertexBuffer).size(Vertex.sizeof * vertices.length);
    }
    void uploadIndices() {
        context.transfer().from(indices.ptr).to(indexBuffer).size(ushort.sizeof * indices.length);
    }

    void createBuffers() {
        vertices = [
            Vertex(float2(0,0), float4(1), float2(0,0)),
            Vertex(float2(1,0), float4(1), float2(1,0)),
            Vertex(float2(1,1), float4(1), float2(1,1)),
            Vertex(float2(0,1), float4(1), float2(0,1)),
        ];
        indices = [
            0,1,2,
            2,3,0
        ];

        ulong verticesSize = Vertex.sizeof * vertices.length;
        vertexBuffer = context.buffer(BufID.VERTEX).alloc(verticesSize);

        ulong indicesSize = ushort.sizeof * indices.length;
        indexBuffer = context.buffer(BufID.INDEX).alloc(indicesSize);

        uniformBuffer = context.buffer(BufID.UNIFORM).alloc(ubo.sizeof);

        uploadVertices();
        uploadIndices();
        uploadUBO();
    }
    void createDescriptorSets() {
        descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VK_SHADER_STAGE_VERTEX_BIT)
                .combinedImageSampler(VK_SHADER_STAGE_FRAGMENT_BIT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(uniformBuffer.handle, uniformBuffer.offset, ubo.sizeof)
                   .add(sampler,
                        imageMeta.image.view(imageMeta.format, VK_IMAGE_VIEW_TYPE_2D),
                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
                   .write();
    }
    void createPipeline() {
        pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withStdColorBlendState();

        enum USE_SLANG_SHADER = true;

        static if(USE_SLANG_SHADER) {        
            pipeline.withVertexShader(context.shaders().getModule("vulkan/quad/quad.slang"), null, "vsmain")
                    .withFragmentShader(context.shaders().getModule("vulkan/quad/quad.slang"), null, "fsmain");
        } else {
            pipeline.withVertexShader(context.shaders().getModule("vulkan/quad/quad1.vert"))
                    .withFragmentShader(context.shaders().getModule("vulkan/quad/quad2.frag"));
        }
        pipeline.build();
    }
}

