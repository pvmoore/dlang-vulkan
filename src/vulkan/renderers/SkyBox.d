module vulkan.renderers.SkyBox;

/**
 *  Note that I had to rotate the top image 90 degrees
 *  counter-clockwise to make it look right.
 */
import vulkan.all;

final class SkyBox {
private:
    VulkanContext context;
    GraphicsPipeline pipeline;
    Descriptors descriptors;
    VkSampler sampler;
    SubBuffer vertexBuffer;
    SubBuffer uniformBuffer, stagingUniformBuffer;

    ImageMeta cubemap;
    UBO ubo;
    bool uboModified = true;
    Vertex[] vertices;

    static struct Vertex {
        float3 pos;
    }

    static struct UBO { static assert(UBO.sizeof == 64 + 64);
        mat4 view;
        mat4 proj;
    }
public:
    this(VulkanContext context, ImageMeta cubemap) {
        this.context = context;
        this.cubemap = cubemap;
        initialise();
    }
    void destroy() {
        if(pipeline) pipeline.destroy();
        if(descriptors) descriptors.destroy();
        if(vertexBuffer) vertexBuffer.free();
        if(uniformBuffer) uniformBuffer.free();
        if(stagingUniformBuffer) stagingUniformBuffer.free();
        if(sampler) context.device.destroySampler(sampler);
    }
    SkyBox camera(Camera3D camera) {
        ubo.view = camera.V();
        ubo.proj = camera.P();
        uboModified = true;
        return this;
    }
    void beforeRenderPass(Frame frame) {
        if(uboModified) {
            auto res = frame.resource;
            uploadUBO(res.adhocCB);
        }
    }
    void insideRenderPass(Frame frame) {
        auto res = frame.resource;
        auto b = res.adhocCB;

        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VPipelineBindPoint.GRAPHICS,
            pipeline.layout,
            0,                          // first set
            [descriptors.getSet(0,0)],  // sets
            null                        // dynamic offsets
        );
        b.bindVertexBuffers(
            0,                      // first binding
            [vertexBuffer.handle],  // buffers
            [vertexBuffer.offset]); // offsets

        b.draw(
            vertices.length.as!int,  // num vertices
            1,                       // num instances
            0,                       // first vertex
            0);                      // firstInstance
    }
private:
    void initialise() {
        this.log("Initialising SkyBox");
        this.uniformBuffer = context.buffer(BufID.UNIFORM).alloc(UBO.sizeof);
        this.stagingUniformBuffer = context.buffer(BufID.STAGING).alloc(UBO.sizeof);

        uploadVertices();
        createSampler();
        createDescriptors();
        createPipeline();
}
    void createSampler() {
        this.sampler = context.device.createSampler(samplerCreateInfo());
    }
    void createDescriptors() {
        this.log("Creating descriptors");
        this.descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VShaderStage.VERTEX)
                .combinedImageSampler(VShaderStage.FRAGMENT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(uniformBuffer.handle, uniformBuffer.offset, UBO.sizeof)
                   .add(sampler,
                        cubemap.image.view(cubemap.format, VImageViewType.CUBE),
                        VImageLayout.SHADER_READ_ONLY_OPTIMAL)
                   .write();
    }
    void createPipeline() {
        this.log("Creating pipeline");
        this.pipeline = new GraphicsPipeline(context, true)
            .withVertexInputState!Vertex(VPrimitiveTopology.TRIANGLE_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withVertexShader(context.vk.shaderCompiler.getModule("skybox/skybox_vert.spv"))
            .withFragmentShader(context.vk.shaderCompiler.getModule("skybox/skybox_frag.spv"))
            .build();
    }
    void uploadUBO(VkCommandBuffer cmd) {
        stagingUniformBuffer.mapAndWrite(&ubo, 0, UBO.sizeof);
        cmd.copyBuffer(stagingUniformBuffer, uniformBuffer);
        uboModified = false;
    }
    void uploadVertices() {
        this.log("Uploading vertices");

        const float s = 100.0;

        /*
                    +y
                     |
                     | /
                     |/
            ----------------- +x
                    /|
                   / |
                  /  |
                 /
                +z
          out of screen


            0-----1
            |    /|
            |   / |
            |  /  |
            | /   |
            |/    |
            2-----3
        */

        this.vertices = [
            // right
            Vertex(float3( s, -s, -s)), // +x
            Vertex(float3( s, -s,  s)),
            Vertex(float3( s,  s,  s)),
            Vertex(float3( s,  s,  s)),
            Vertex(float3( s,  s, -s)),
            Vertex(float3( s, -s, -s)),

            // left
            Vertex(float3(-s, -s,  s)), // -x
            Vertex(float3(-s, -s, -s)),
            Vertex(float3(-s,  s, -s)),
            Vertex(float3(-s,  s, -s)),
            Vertex(float3(-s,  s,  s)),
            Vertex(float3(-s, -s,  s)),

            // top
            Vertex(float3( s,  s,  s)), // +y
            Vertex(float3(-s,  s,  s)),
            Vertex(float3(-s,  s, -s)),
            Vertex(float3(-s,  s, -s)),
            Vertex(float3( s,  s, -s)),
            Vertex(float3( s,  s,  s)),

            // bottom
            Vertex(float3(-s, -s, -s)), // -y
            Vertex(float3(-s, -s,  s)),
            Vertex(float3( s, -s, -s)),
            Vertex(float3( s, -s, -s)),
            Vertex(float3(-s, -s,  s)),
            Vertex(float3( s, -s,  s)),

            // back
            Vertex(float3(-s,  s, -s)),
            Vertex(float3(-s, -s, -s)),
            Vertex(float3( s,  s, -s)),
            Vertex(float3( s,  s, -s)),
            Vertex(float3(-s, -s, -s)),
            Vertex(float3( s, -s, -s)),

            // front
            Vertex(float3(-s,  s,  s)),
            Vertex(float3(-s, -s,  s)),
            Vertex(float3( s,  s,  s)),
            Vertex(float3( s,  s,  s)),
            Vertex(float3(-s, -s,  s)),
            Vertex(float3( s, -s,  s)),
        ];

        auto size = vertices.length * Vertex.sizeof;

        this.vertexBuffer = context.buffer(BufID.VERTEX).alloc(size);

        context.transfer().from(vertices.ptr).to(vertexBuffer).size(size);
    }
}

