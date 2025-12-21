module vulkan.renderers.Quads;

/**
 *  Render multiple coloured, textured quads.
 */
import vulkan.all;

final class Quads {
public:
    this(VulkanContext context, ImageMeta imageMeta, VkSampler sampler, uint maxQuads) {
        throwIf(sampler is null);
        this.context         = context;
        this.imageMeta       = imageMeta;
        this.sampler         = sampler;
        this.maxQuads        = maxQuads;
        this.currentColour   = float4(1,1,1,1);
        this.currentUV       = float4(0,0,1,1);
        this.currentSize     = float2(16,16);
        this.currentRotation = 0;
        this.freeList        = new FreeList(maxQuads);

        initialise();
    }
    void destroy() {
        if(ubo) ubo.destroy();
        if(vertices) vertices.destroy();
        if(pipeline) pipeline.destroy();
        if(descriptors) descriptors.destroy();
    }
    auto camera(Camera2D cam) {
        ubo.write((u) {
            u.viewProj = cam.VP();
        });
        return this;
    }
    auto setColour(float4 c) {
        this.currentColour = c;
        return this;
    }
    auto setUV(float4 uv) {
        this.currentUV = uv;
        return this;
    }
    auto setSize(float2 s) {
        this.currentSize = s;
        return this;
    }
    auto setRotation(float rads) {
        this.currentRotation = rads;
        return this;
    }
    uint add(float2 pos) {
        return add(pos, currentSize, currentUV, currentColour, currentRotation);
    }
    uint add(float2 pos, float2 size, float4 uv, float4 colour, float rotation) {
        throwIf(freeList.numFree() == 0, "No free quads");

        uint i = freeList.acquire();

        vertices.write((v) {
            v.pos = pos;
            v.size = size;
            v.uv = uv;
            v.colour = colour;
            v.rotation = rotation;
            v.enabled = 1;
        }, i);

        return i;
    }
    void remove(uint index) {
        vertices.write((v) {
            v.enabled = 0;
        }, index);

        freeList.release(index);
    }
    auto setPos(uint index, float2 p) {
        vertices.write((v) {
            v.pos = p;
        }, index);
        return this;
    }
    auto setSize(uint index, float2 s) {
        vertices.write((v) {
            v.size = s;
        }, index);
        return this;
    }
    auto setEnabled(uint index, bool enabled) {
        vertices.write((v) {
            v.enabled = enabled ? 1 : 0;
        }, index);
        return this;
    }
    auto setColour(uint index, float4 colour) {
        vertices.write((v) {
            v.colour = colour;
        }, index);
        return this;
    }
    auto setUV(uint index, float4 uv) {
        vertices.write((v) {
            v.uv = uv;
        }, index);
        return this;
    }
    auto setRotation(uint index, float r) {
        vertices.write((v) {
            v.rotation = r;
        }, index);
        return this;
    }
    void beforeRenderPass(Frame frame) {
        auto cmd = frame.resource.adhocCB;
        ubo.upload(cmd);
        vertices.upload(cmd);
    }
    void insideRenderPass(Frame frame) {
        if(freeList.numUsed()==0) return;

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
            0,                                    // first binding
            [vertices.getDeviceBuffer().handle],  // buffers
            [vertices.getDeviceBuffer().offset]); // offsets

        b.draw(maxQuads, 1, 0, 0);
    }
private:
    static struct Vertex { align(1):
        float2 pos;
        float2 size;
        float4 uv;          // top-left, bottom-right
        float4 colour;
        float rotation;
        float enabled;
    }
    static struct UBO {
        mat4 viewProj;
    }
    @Borrowed VulkanContext context;
    @Borrowed ImageMeta imageMeta;
    @Borrowed VkSampler sampler;
    const uint maxQuads;

    GraphicsPipeline pipeline;
    Descriptors descriptors;
    GPUData!UBO ubo;
    GPUData!Vertex vertices;
    FreeList freeList;

    float4 currentColour;
    float4 currentUV;   // top-left, bottom-right
    float2 currentSize;
    float currentRotation;

    void initialise() {
        createBuffers();
        createDescriptors();
        createPipeline();
    }
    void createBuffers() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true).initialise();
        this.vertices = new GPUData!Vertex(context, BufID.VERTEX, true, maxQuads).initialise();

        this.vertices.memset(0, maxQuads);
    }
    void createDescriptors() {
        /*
         * 0 - UBO
         * 1 - sampler
         */
        this.descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VK_SHADER_STAGE_GEOMETRY_BIT)
                .combinedImageSampler(VK_SHADER_STAGE_FRAGMENT_BIT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
                   .add(ubo)
                   .add(sampler,
                        imageMeta.image.view(imageMeta.format, VK_IMAGE_VIEW_TYPE_2D),
                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
                   .write();
    }
    void createPipeline() {
        this.pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VK_PRIMITIVE_TOPOLOGY_POINT_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withVertexShader(context.shaders.getModule("vulkan/quads/Quads.vert"))
            .withGeometryShader(context.shaders.getModule("vulkan/quads/Quads.geom"))
            .withFragmentShader(context.shaders.getModule("vulkan/quads/Quads.frag"))
            .withStdColorBlendState()
            .build();
    }
}

