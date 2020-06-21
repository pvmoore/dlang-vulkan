module vulkan.renderers.quad;
/**
 *  A simple coloured, textured quad.
 *
 *  TODO - Make this work for multiple quads of the same image.
 */
import vulkan.all;

private align(1) struct Vertex { align(1):
    vec2 pos;
    vec4 colour;
    vec2 uv;
}
private struct UBO {
    Matrix4 model;
    Matrix4 view;
    Matrix4 proj;
}
static assert(Vertex.sizeof==8*float.sizeof);
static assert(UBO.sizeof==3*16*4);

//static struct QuadData {
//    uvec2 pos;
//    vec2 uv;
//    vec2 size;
//    RGBA colour;
//}

final class Quad {
    VulkanContext context;

    GraphicsPipeline pipeline;
    Descriptors descriptors;

    SubBuffer vertexBuffer, indexBuffer, uniformBuffer;
    ImageMeta imageMeta;
    VkSampler sampler;
    VFormat format;

    UBO ubo;

    this(VulkanContext context, ImageMeta imageMeta, VkSampler sampler, VFormat format = VFormat.R8G8B8A8_UNORM) {
        this.context   = context;
        this.imageMeta = imageMeta;
        this.sampler   = sampler;
        this.format    = format;

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
    void insideRenderPass(PerFrameResource res) {

        auto b = res.adhocCB;

        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VPipelineBindPoint.GRAPHICS,
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
            Vertex(vec2(0,0), vec4(1), vec2(0,0)),
            Vertex(vec2(1,0), vec4(1), vec2(1,0)),
            Vertex(vec2(1,1), vec4(1), vec2(1,1)),
            Vertex(vec2(0,1), vec4(1), vec2(0,1)),
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
                .uniformBuffer(VShaderStage.VERTEX)
                .combinedImageSampler(VShaderStage.FRAGMENT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(uniformBuffer.handle, uniformBuffer.offset, ubo.sizeof)
                   .add(sampler,
                        imageMeta.image.view(imageMeta.format, VImageViewType._2D),
                        VImageLayout.SHADER_READ_ONLY_OPTIMAL)
                   .write();
    }
    void createPipeline() {
        pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VPrimitiveTopology.TRIANGLE_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withVertexShader(context.vk.shaderCompiler.getModule("quad/quad1_vert.spv"))
            .withFragmentShader(context.vk.shaderCompiler.getModule("quad/quad2_frag.spv"))
            .build();
    }
}

