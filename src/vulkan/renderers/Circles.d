module vulkan.renderers.Circles;

import vulkan.all;

final class Circles {
private:
    VulkanContext context;
    GraphicsPipeline pipeline;
    Descriptors descriptors;
    const uint maxCircles;
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
        float4 posRadiusBorderRadius;
        RGBA colour;
        RGBA borderColour;
    }
    static struct UBO { static assert(UBO.sizeof == 64);
        mat4 viewProj;
    }
public:
    this(VulkanContext context, uint maxCircles) {
        this.context = context;
        this.maxCircles = maxCircles;
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
        auto index = numCircles;
        auto i = findNextFreeVertex();

        vertices.write((v) {
            v.posRadiusBorderRadius = float4(pos, radius, borderRadius);
            v.colour = colour;
            v.borderColour = borderColour;
        }, i);
        return index;
    }
    auto removeAt(uint index) {
        assert(index<maxCircles);
        vertices.write((v) { v.posRadiusBorderRadius.y = 0; }, index);
        numCircles--;
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
            VPipelineBindPoint.GRAPHICS,
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
                .uniformBuffer(VShaderStage.GEOMETRY)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
            .add(ubo)
            .write();
    }
    void createPipeline() {
        this.pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VPrimitiveTopology.POINT_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withVertexShader(context.vk.shaderCompiler.getModule("geom2d/Circles_vert.spv"))
            .withGeometryShader(context.vk.shaderCompiler.getModule("geom2d/Circles_geom.spv"))
            .withFragmentShader(context.vk.shaderCompiler.getModule("geom2d/Circles_frag.spv"))
            .withStdColorBlendState()
            .build();
    }
    uint findNextFreeVertex() {
        auto ptr = vertices.map();

        for(auto i = 0; i<maxCircles; i++) {
            if(ptr[i].posRadiusBorderRadius.y == 0) {
                numCircles++;
                return i;
            }
        }
        throw new Error("Max number circles reached");
    }
}
