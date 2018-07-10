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
    Vulkan vk;
    VkDevice device;

    GraphicsPipeline pipeline;
    Descriptors descriptors;

    VkDescriptorSet descriptorSet;
    SubBuffer vertexBuffer, indexBuffer, uniformBuffer;
    DeviceImage image;
    VkRenderPass renderPass;
    VkSampler sampler;

    UBO ubo;

    this(Vulkan vk,
         VkRenderPass renderPass,
         DeviceImage image,
         VkSampler sampler)
    {
        this.vk         = vk;
        this.device     = vk.device;
        this.renderPass = renderPass;
        this.image      = image;
        this.sampler    = sampler;
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
        vk.memory.copyToDevice(uniformBuffer, &ubo);
    }
    void setColour(RGBA c) {
        foreach(ref v; vertices) {
            v.colour = c;
        }
        vk.memory.copyToDevice(vertexBuffer, vertices.ptr);
    }
    void setUV(UV topLeft, UV bottomRight) {
        vertices[0].uv = topLeft;
        vertices[1].uv = UV(bottomRight.x, topLeft.y);
        vertices[2].uv = bottomRight;
        vertices[3].uv = UV(topLeft.x, bottomRight.y);
        vk.memory.copyToDevice(vertexBuffer, vertices.ptr);
    }
    void insideRenderPass(PerFrameResource res) {

        auto b = res.adhocCB;

        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VPipelineBindPoint.GRAPHICS,
            pipeline.layout,
            0,      // first set
            [descriptorSet],
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
        vertexBuffer = vk.memory.createVertexBuffer(verticesSize);
        vk.memory.copyToDevice(vertexBuffer, vertices.ptr);

        ulong indicesSize = ushort.sizeof * indices.length;
        indexBuffer = vk.memory.createIndexBuffer(indicesSize);
        vk.memory.copyToDevice(indexBuffer, indices.ptr);

        ulong uniformSize = ubo.sizeof;
        uniformBuffer = vk.memory.createUniformBuffer(uniformSize);
        vk.memory.copyToDevice(uniformBuffer, &ubo);
    }
    void createDescriptorSets() {
        descriptors = new Descriptors(vk)
            .createLayout()
                .uniformBuffer(VShaderStage.VERTEX)
                .combinedImageSampler(VShaderStage.FRAGMENT)
                .sets(1)
            .build();

        descriptorSet = descriptors
           .createSetFromLayout(0)
               .add(uniformBuffer.handle, uniformBuffer.offset, ubo.sizeof)
               .add(sampler,
                    image.view(VFormat.R8G8B8A8_UNORM,VImageViewType._2D),
                    VImageLayout.SHADER_READ_ONLY_OPTIMAL)
               .write();
    }
    void createPipeline() {
        pipeline = new GraphicsPipeline(vk, renderPass)
            .withVertexInputState!Vertex(VPrimitiveTopology.TRIANGLE_LIST)
            .withDSLayouts(descriptors.layouts)
            .withVertexShader(vk.vprops.shaderDirectory~"quad/quad1_vert.spv")
            .withFragmentShader(vk.vprops.shaderDirectory~"quad/quad2_frag.spv")
            .build();
    }
}

