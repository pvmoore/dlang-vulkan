module vulkan.renderers.CartesianCoordinates;

 import vulkan.all;

/**
 * Display Cartesian coordinates axes.
 * 
 *  - Draw X, Y and Z lines
 *  - Draw 'X', 'Y' and 'Z' labels using billboard projection
 */
final class CartesianCoordinates {
public:
    this(VulkanContext context, float lineWidth) {
        this.context = context;
        this.lineWidth = lineWidth;
        initialise();
    }
    void destroy() {
        if(ubo) ubo.destroy();
        if(lines) lines.destroy();
        if(text) text.destroy();
        if(pipeline) pipeline.destroy();
        if(descriptors) descriptors.destroy();
    }
    auto camera(Camera3D camera, float scale) {
        ubo.write((u) {
            u.model = mat4.scale(float3(scale));
            u.viewProj = camera.VP();
        });

        // Update text positions
        auto xpos = camera.worldToScreen(float3(1,0,0) * scale, false);
        auto ypos = camera.worldToScreen(float3(0,1,0) * scale, false);
        auto zpos = camera.worldToScreen(float3(0,0,1) * scale, false);

        text.moveTo(textIds[0], (xpos.x+2).as!int, (xpos.y-9).as!int);
        text.moveTo(textIds[1], (ypos.x-7).as!int, (ypos.y-21).as!int);
        text.moveTo(textIds[2], (zpos.x-7).as!int, (zpos.y-9).as!int);
        return this;
    }
    void beforeRenderPass(Frame frame) {
        auto res = frame.resource;
        ubo.upload(res.adhocCB);
        lines.upload(res.adhocCB);
        text.beforeRenderPass(frame);
    }
    void insideRenderPass(Frame frame) {
        auto res = frame.resource;
        auto b = res.adhocCB;

        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_GRAPHICS,
            pipeline.layout,
            0,                          // first set
            [descriptors.getSet(0,0)],  // descriptor sets
            null                        // dynamicOffsets
        );
        b.bindVertexBuffers(
            0,                                  // first binding
            [lines.getDeviceBuffer().handle],   // buffers
            [lines.getDeviceBuffer().offset]);  // offsets
        b.draw(6, 1, 0, 0);

        text.insideRenderPass(frame);
    }
private:
    @Borrowed VulkanContext context;
    const float lineWidth;
    Descriptors descriptors;
    GraphicsPipeline pipeline;
    GPUData!UBO ubo;
    GPUData!LineVertex lines;
    Text text;
    uint[] textIds;

    static struct LineVertex {
        float3 pos;
        float3 colour;
    }
    static struct UBO {
        mat4 model;
        mat4 viewProj;
    }

    void initialise() {
        createText();
        createUBO();
        createLines();
        createDescriptors();
        createPipeline();
    }
    void createText() {
        this.text = new Text(context, context.fonts().get("arial"), true, 100);
        text.camera(Camera2D.forVulkan(context.vk.windowSize));
        text.setColour(WHITE);
        text.setSize(20);

        textIds ~= text.add("X", 0, 0);
        textIds ~= text.add("Y", 0, 0);
        textIds ~= text.add("Z", 0, 0);
    }
    void createUBO() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true)
            .initialise();

        ubo.write((u) {
            u.model = mat4.identity();
        });
    }
    void createLines() {
        this.lines = new GPUData!LineVertex(context, BufID.VERTEX, true, 6)
            .initialise();

        // Create 3 lines
        //
        // y   z
        // |  /
        // | /
        // |/
        // 0------x

        lines.write((v) {
            // X (red)
            v[0] = LineVertex(float3(0,0,0), float3(1,0,0));
            v[1] = LineVertex(float3(1,0,0), float3(1,0,0));

            // Y (green)
            v[2] = LineVertex(float3(0,0,0), float3(0,1,0));
            v[3] = LineVertex(float3(0,1,0), float3(0,1,0));

            // Z (blue)
            v[4] = LineVertex(float3(0,0,0), float3(0,0,1));
            v[5] = LineVertex(float3(0,0,1), float3(0,0,1));
        });
    }
    void createDescriptors() {
        /**
         * Bindings:
         *    0 - uniform buffer
         */
        this.descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VK_SHADER_STAGE_VERTEX_BIT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
            .add(ubo)
            .write();
    }
    void createPipeline() {
        this.pipeline = new GraphicsPipeline(context)
            .withVertexInputState!LineVertex(VK_PRIMITIVE_TOPOLOGY_LINE_LIST)
            .withDSLayouts(descriptors.getAllLayouts())
            .withVertexShader(context.shaders.getModule("vulkan/cartesian/lines.slang"), null, "vsmain")
            .withFragmentShader(context.shaders.getModule("vulkan/cartesian/lines.slang"), null, "fsmain")
            .withStdColorBlendState()
            .withRasterisationState((info) {
                info.lineWidth = lineWidth;
            })
            .build();
    }
}
