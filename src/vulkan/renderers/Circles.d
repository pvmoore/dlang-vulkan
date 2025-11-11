module vulkan.renderers.Circles;

import vulkan.all;

final class Circles {
public:
    this(VulkanContext context, uint maxCircles) {
        this.context = context;
        this.maxCircles = maxCircles;
        this.freeList = new FreeList(maxCircles);
        initialise();
    }
    void destroy() {
        if(ubo) ubo.destroy();
        if(vertices) vertices.destroy();
        if(descriptors) descriptors.destroy();
        if(pipeline) pipeline.destroy();
    }
    auto colour(RGBA c) {
        this.tempColour = c;
        return this;
    }
    auto borderColour(RGBA c) {
        this.tempBorderColour = c;
        return this;
    }
    auto radius(float r) {
        this.tempRadius = r;
        return this;
    }
    auto borderRadius(float r) {
        this.tempBorderRadius = r;
        return this;
    }
    uint add(float2 pos, float radius = 0) {
        return add(pos, radius==0 ? tempRadius : radius, tempBorderRadius, tempColour, tempBorderColour);
    }
    uint add(float2 pos, float radius, float borderRadius, RGBA colour, RGBA borderColour) {
        auto i = freeList.acquire();
        numCircles++;

        vertices.write((v) {
            v.posRadiusBorderRadius = float4(pos, radius, borderRadius);
            v.colour = colour;
            v.borderColour = borderColour;
        }, i);
        return i;
    }
    auto removeAt(uint index) {
        throwIf(index >= maxCircles);
        freeList.release(index);
        numCircles--;

        vertices.write((v) {
            v.posRadiusBorderRadius = float4(0);
        }, index);
        return this;
    }
    auto camera(Camera2D camera) {
        ubo.write((u) {
            u.viewProj = camera.VP();
        });
        return this;
    }
    void beforeRenderPass(Frame frame) {
        auto res = frame.resource;
        ubo.upload(res.adhocCB);
        vertices.upload(res.adhocCB);
    }
    void insideRenderPass(Frame frame) {
        if(numCircles==0) return;

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
            0,                           // first binding
            [vertices.getDeviceBuffer().handle],  // buffers
            [vertices.getDeviceBuffer().offset]); // offsets

        b.draw(maxCircles, 1, 0, 0);
    }
private:
    @Borrowed VulkanContext context;
    const uint maxCircles;
    GraphicsPipeline pipeline;
    Descriptors descriptors;
    FreeList freeList;
    uint numCircles;

    GPUData!UBO ubo;

    // Sparsely populated array of Vertexes. If radius==0 then that circle
    // will not be rendered and that space can be re-used.
    GPUData!Vertex vertices;

    float tempRadius = 0;
    float tempBorderRadius = 0;
    RGBA tempColour = RGBA(1,1,1,1);
    RGBA tempBorderColour = RGBA(1,1,1,1);

    static struct Vertex { static assert(Vertex.sizeof == float.sizeof*12);
        float4 posRadiusBorderRadius; // xy, radius, borderRadius
        RGBA colour;
        RGBA borderColour;
    }
    static struct UBO { static assert(UBO.sizeof == 64);
        mat4 viewProj;
    }

    void initialise() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .initialise();
        this.vertices = new GPUData!Vertex(context, BufID.VERTEX, true, maxCircles)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .initialise();

        this.vertices.memset(0, maxCircles);

        createDescriptors();
        createPipeline();
    }
    void createDescriptors() {
        /**
         * Bindings:
         *    0     uniform buffer
         */
        this.descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VK_SHADER_STAGE_GEOMETRY_BIT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
            .add(ubo)
            .write();
    }
    void createPipeline() {

        enum USE_SLANG = true;

        static if(USE_SLANG) {
            auto shader = context.shaders.getModule("vulkan/circles/circles.slang");

            this.pipeline = new GraphicsPipeline(context)
                .withVertexInputState!Vertex(VK_PRIMITIVE_TOPOLOGY_POINT_LIST)
                .withDSLayouts(descriptors.getAllLayouts())
                .withVertexShader(shader, null, "vsmain")
                .withGeometryShader(shader, null, "gsmain")
                .withFragmentShader(shader, null, "fsmain")
                .withStdColorBlendState()
                .build();
        } else {
            this.pipeline = new GraphicsPipeline(context)
                .withVertexInputState!Vertex(VK_PRIMITIVE_TOPOLOGY_POINT_LIST)
                .withDSLayouts(descriptors.getAllLayouts())
                .withVertexShader(context.shaders.getModule("vulkan/circles/Circles.vert"))
                .withGeometryShader(context.shaders.getModule("vulkan/circles/Circles.geom"))
                .withFragmentShader(context.shaders.getModule("vulkan/circles/Circles.frag"))
                .withStdColorBlendState()
                .build();
        }
    }
}
