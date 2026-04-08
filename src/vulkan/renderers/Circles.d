module vulkan.renderers.Circles;

import vulkan.all;

final class Circles {
public:
    this(VulkanContext context, uint maxCircles) {
        this.context = context;
        this.maxCircles = maxCircles;
        createObjects();
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
    /** Add a circle using the current settings. Return the id that can be used later to remove or update the circle. */
    uint add(float2 pos, float radius = 0) {
        return add(pos, radius==0 ? tempRadius : radius, tempBorderRadius, tempColour, tempBorderColour);
    }
    /** Add a circle with specific parameters. Return the id that can be used later to remove or update the circle. */
    uint add(float2 pos, float radius, float borderRadius, RGBA colour, RGBA borderColour) {
        assert(freeList.numFree() > 0, "Maximum circles reached");

        auto id = freeList.acquire();
        freeList.setViaId(id, Vertex(float4(pos, radius, borderRadius), colour, borderColour));
        return id;
    }
    /** Update the position, radius and border radius of an existing circle */
    void update(uint id, float2 pos, float radius) {
        auto ptr = freeList.mapViaId(id);
        ptr.posRadiusBorderRadius = float4(pos, radius, ptr.posRadiusBorderRadius.w);
    }
    /** Update the colour of an existing circle */
    void updateColour(uint id, RGBA colour, RGBA borderColour) {
        auto ptr = freeList.mapViaId(id);
        ptr.colour = colour;
        ptr.borderColour = borderColour;
    }
    auto removeAt(uint id) {
        freeList.release(id);
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
            0,                           // first binding
            [vertices.getDeviceBuffer().handle],  // buffers
            [vertices.getDeviceBuffer().offset]); // offsets

        b.draw(freeList.numUsed(), 1, 0, 0);
    }
private:
    @Borrowed VulkanContext context;
    const uint maxCircles;
    GraphicsPipeline pipeline;
    Descriptors descriptors;
    GPUDataFreeList!Vertex freeList;

    GPUData!UBO ubo;
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

    void createObjects() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .initialise();
        this.vertices = new GPUData!Vertex(context, BufID.VERTEX, true, maxCircles)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .initialise();

        this.vertices.memset(0, maxCircles);

        this.freeList = new GPUDataFreeList!Vertex(vertices);

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
