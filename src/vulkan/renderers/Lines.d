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

    float tempThickness = 1f;
    RGBA tempFromCol = WHITE;
    RGBA tempToCol = WHITE;

    static struct Vertex {
        float4 fromTo;
        RGBA fromCol;
        RGBA toCol;
        float thickness;
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
        this.tempThickness = t;
        return this;
    }
    uint add(float2 fromPos, float2 toPos) {
        return add(fromPos, toPos, tempFromCol, tempToCol, tempThickness);
    }
    uint add(float2 fromPos, float2 toPos, RGBA fromCol, RGBA toCol, float thickness = 0) {
        auto index = numLines;
        auto i = findNextFreeVertex();
        vertices.write((v){
            v[i].fromTo = float4(fromPos, toPos);
            v[i].fromCol = fromCol;
            v[i].toCol = toCol;
            v[i].thickness = thickness == 0 ? tempThickness : thickness;
        });
        return index;
    }
    auto removeAt(uint index) {
        assert(index<maxLines);
        vertices.write((v){ v[index].thickness = 0; });
        numLines--;
        return this;
    }
    void beforeRenderPass(PerFrameResource res) {
        ubo.upload(res.adhocCB);
        vertices.upload(res.adhocCB);
    }
    void insideRenderPass(PerFrameResource res) {
        if(numLines==0) return;

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
            [vertices.upBuffer.handle],  // buffers
            [vertices.upBuffer.offset]); // offsets

        b.draw(maxLines, 1, 0, 0);
    }
private:
    void initialise() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true, false);
        this.vertices = new GPUData!Vertex(context, BufID.VERTEX, true, false, maxLines);

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
                .uniformBuffer(VShaderStage.GEOMETRY)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
            .add(ubo, true)
            .write();
    }
    void createPipeline() {
        this.pipeline = new GraphicsPipeline(context)
            .withVertexInputState!Vertex(VPrimitiveTopology.POINT_LIST)
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
            if(ptr[i].thickness == 0) {
                numLines++;
                return i;
            }
        }
        throw new Error("Max number circles reached");
    }
}