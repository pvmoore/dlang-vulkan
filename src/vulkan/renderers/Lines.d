module vulkan.renderers.Lines;

import vulkan.all;

final class Lines {
private:
    const uint maxLines;
    VulkanContext context;
    Descriptors descriptors;
    GraphicsPipeline pipeline;

    GPUData!UBO ubo;
    GPUData!Vertex vertices;
    uint numLines;

    float tempFromThickness = 1f;
    float tempToThickness = 1f;
    RGBA tempFromCol = WHITE;
    RGBA tempToCol = WHITE;

    static struct Vertex {
        float4 fromTo;
        RGBA fromCol;
        RGBA toCol;
        float fromThickness;
        float toThickness;
    }
    static struct UBO {
        mat4 viewProj;
    }
public:
    this(VulkanContext context, uint maxLines) {
        this.context = context;
        this.maxLines = maxLines;
        initialise();
    }
    void destroy() {
        if(vertices) vertices.destroy();
        if(ubo) ubo.destroy();
        if(pipeline) pipeline.destroy();
        if(descriptors) descriptors.destroy();
    }
    auto camera(Camera2D camera) {
        ubo.write((u) {
            u.viewProj = camera.VP();
        });
        return this;
    }
    auto fromColour(RGBA c) {
        this.tempFromCol = c;
        return this;
    }
    auto toColour(RGBA c) {
        this.tempToCol = c;
        return this;
    }
    auto thickness(float t) {
        this.tempFromThickness = t;
        this.tempToThickness = t;
        return this;
    }
    auto fromThickness(float t) {
        this.tempFromThickness = t;
        return this;
    }
    auto toThickness(float t) {
        this.tempToThickness = t;
        return this;
    }
    uint add(float2 fromPos, float2 toPos) {
        return add(fromPos, toPos, tempFromCol, tempToCol, tempFromThickness, tempToThickness);
    }
    uint add(float2 fromPos, float2 toPos, RGBA fromCol, RGBA toCol, float fromThickness, float toThickness) {
        auto index = numLines;
        auto i = findNextFreeVertex();
        vertices.write((v){
            v[i].fromTo = float4(fromPos, toPos);
            v[i].fromCol = fromCol;
            v[i].toCol = toCol;
            v[i].fromThickness = fromThickness;
            v[i].toThickness = toThickness;
        });
        return index;
    }
    auto removeAt(uint index) {
        vkassert(index<maxLines);
        vertices.write((v){
            v[index].fromThickness = 0;
            v[index].toThickness = 0;
        });
        numLines--;
        return this;
    }
    void beforeRenderPass(Frame frame) {
        auto res = frame.resource;
        ubo.upload(res.adhocCB);
        vertices.upload(res.adhocCB);
    }
    void insideRenderPass(Frame frame) {
        if(numLines==0) return;

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

        b.draw(maxLines, 1, 0, 0);
    }
private:
    void initialise() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .initialise();
        this.vertices = new GPUData!Vertex(context, BufID.VERTEX, true, maxLines)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .initialise();

        this.vertices.write((v) {
            memset(v, 0, Vertex.sizeof*maxLines);
        });

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
        this.pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VK_PRIMITIVE_TOPOLOGY_POINT_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withVertexShader(context.vk.shaderCompiler.getModule("geom2d/Lines_vert.spv"))
            .withGeometryShader(context.vk.shaderCompiler.getModule("geom2d/Lines_geom.spv"))
            .withFragmentShader(context.vk.shaderCompiler.getModule("geom2d/Lines_frag.spv"))
            .withStdColorBlendState()
            .build();
    }
    uint findNextFreeVertex() {
        auto ptr = vertices.map();

        for(auto i = 0; i<maxLines; i++) {
            if(ptr[i].fromThickness == 0 && ptr[i].toThickness == 0) {
                numLines++;
                return i;
            }
        }
        throw new Error("Max number circles reached");
    }
}