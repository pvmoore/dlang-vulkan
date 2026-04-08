module vulkan.renderers.Lines;

import vulkan.all;

/**
 * Line renderer using geometry shader.
 */
final class Lines {
public:
    this(VulkanContext context, uint maxLines) {
        this.context = context;
        this.maxLines = maxLines;
        createObjects();
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
//──────────────────────────────────────────────────────────────────────────────────────────────────    
    /** Add a line using the current settings. Return the id that can be used later to remove or update the line. */
    uint add(float2 fromPos, float2 toPos) {
        return add(fromPos, toPos, tempFromCol, tempToCol, tempFromThickness, tempToThickness);
    }
    /** Add a line with specific colour and thickness. Return the id that can be used later to remove or update the line. */
    uint add(float2 fromPos, float2 toPos, RGBA fromCol, RGBA toCol, float fromThickness, float toThickness) {
        assert(freeList.numFree() > 0, "Maximum lines reached");

        auto id = freeList.acquire();

        Vertex v = {
            fromTo: float4(fromPos, toPos),
            fromCol: fromCol,
            toCol: toCol,
            fromThickness: fromThickness,
            toThickness: toThickness
        };

        freeList.setViaId(id, v);

        return id;
    }
    /** Update the from/to position of a line */
    void update(uint id, float2 fromPos, float2 toPos) {
        auto ptr = freeList.mapViaId(id);
        ptr.fromTo = float4(fromPos, toPos);
    }
    /** Update the colour of an existing line */
    void updateColour(uint id, RGBA fromCol, RGBA toCol) {
        auto ptr = freeList.mapViaId(id);
        ptr.fromCol = fromCol;
        ptr.toCol = toCol;
    }
    /** Update the thickness of an existing line */
    void updateThickness(uint id, float fromThickness, float toThickness) {
        auto ptr = freeList.mapViaId(id);
        ptr.fromThickness = fromThickness;
        ptr.toThickness = toThickness;
    }
    auto removeAt(uint id) {
        freeList.release(id);
        return this;
    }
    auto clear() {
        freeList.reset();
        return this;
    }
//──────────────────────────────────────────────────────────────────────────────────────────────────    
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

        // One vertex point per line
        b.draw(freeList.numUsed(), 1, 0, 0);
    }
private:
    @Borrowed VulkanContext context;
    const uint maxLines;
    Descriptors descriptors;
    GraphicsPipeline pipeline;
    GPUData!UBO ubo;
    GPUData!Vertex vertices;
    GPUDataFreeList!Vertex freeList;

    float tempFromThickness = 1f;
    float tempToThickness   = 1f;
    RGBA tempFromCol        = WHITE;
    RGBA tempToCol          = WHITE;

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

    void createObjects() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .initialise();
        this.vertices = new GPUData!Vertex(context, BufID.VERTEX, true, maxLines)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .initialise();

        this.freeList = new GPUDataFreeList!Vertex(vertices);  

        // Clear all vertices to zero
        vertices.memset(0);  

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
            .withVertexShader(context.shaders.getModule("vulkan/lines/Lines.vert"))
            .withGeometryShader(context.shaders.getModule("vulkan/lines/Lines.geom"))
            .withFragmentShader(context.shaders.getModule("vulkan/lines/Lines.frag"))
            .withStdColorBlendState()
            .build();
    }
}
