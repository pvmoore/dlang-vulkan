module vulkan.renderers.LinesMS;

import vulkan.all;

/**
 * Line renderer using task and mesh shader.
 */
final class LinesMeshShaderImpl {
public:
    this(VulkanContext context, uint maxLines) {
        this.context = context;
        this.maxLines = maxLines;
        initialise();
    }
    void destroy() {
        if(descriptors) descriptors.destroy();
        if(pipeline) pipeline.destroy();
        if(ubo) ubo.destroy();
        if(lineData) lineData.destroy();
        if(meshlets) meshlets.destroy();
    }
    auto camera(Camera2D camera) {
        ubo.write((u) {
            u.viewProj = camera.VP();
        });
        this.ready = true;
        return this;
    }
    auto add(float2 from, float2 to) {
        throwIf(numLines >= maxLines, "Too many lines: %s > %s", numLines, maxLines);
        vertexTemplate.from = from;
        vertexTemplate.to = to;

        lineData.write((v) {
            *v = vertexTemplate;
        }, numLines);

        // Update meshlets
        auto m = numLines / LINES_PER_MESHLET;
        Meshlet* meshlet = meshlets.map().as!(Meshlet*) + m;
        meshlet.numLines++;
        meshlet.lineDataOffset = m * LINES_PER_MESHLET;

        meshlets.setDirtyRange(m, m+1);

        numMeshlets = m+1;
        ubo.write((u) {
            u.numMeshlets = numMeshlets;
        });

        numLines++;
        return this;
    }
    auto colour(float4 fromColour, float4 toColour) {
        vertexTemplate.fromCol = fromColour;
        vertexTemplate.toCol = toColour;
        return this;
    }
    auto thickness(float fromThickness, float toThickness) {
        vertexTemplate.fromThickness = fromThickness;
        vertexTemplate.toThickness = toThickness;
        return this;
    }
    void update(Frame frame) {
        assert(ready, "camera() has not been called");
        auto res = frame.resource;
        auto cmd = res.adhocCB;

        ubo.upload(cmd);
        meshlets.upload(cmd);
        lineData.upload(cmd);
    }
    void render(Frame frame) {
        if(numLines==0) return;

        auto res = frame.resource;
        auto cmd = res.adhocCB;

        cmd.bindPipeline(pipeline);
        cmd.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_GRAPHICS,
            pipeline.layout,
            0,      // first set
            [descriptors.getSet(0,0)],
            null    // dynamic offsets
        );

        // Spawn a single task group
        vkCmdDrawMeshTasksEXT(cmd, 1, 1, 1);
    }
private:
    enum LINES_PER_MESHLET = 32;

    static struct UBO {
        mat4 viewProj;
        uint numMeshlets;
    }
    static struct Meshlet {
        uint numLines;
        uint lineDataOffset;
    }
    static struct LineInput { 
        float2 from;
        float2 to;
        float4 fromCol;
        float4 toCol;
        float fromThickness;
        float toThickness;
    }

    @Borrowed VulkanContext context;
    const uint maxLines;
    Descriptors descriptors;
    GraphicsPipeline pipeline;
    GPUData!UBO ubo;
    GPUData!Meshlet meshlets;
    GPUData!LineInput lineData;
    uint numLines;
    uint numMeshlets;
    bool ready;

    LineInput vertexTemplate = {
        fromCol: float4(1),
        toCol: float4(1),
        fromThickness: 1,
        toThickness: 1,
    };

    void initialise() {
        this.ubo = new GPUData!UBO(context, BufID.UNIFORM, true)
            .initialise();
        this.lineData = new GPUData!LineInput(context, BufID.STORAGE, true, maxLines)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                    VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                    VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_MESH_SHADER_BIT_EXT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_MESH_SHADER_BIT_EXT
                ))    
            .initialise();
        this.meshlets = new GPUData!Meshlet(context, BufID.STORAGE, true, maxLines / LINES_PER_MESHLET + 1)
            .withUploadStrategy(GPUDataUploadStrategy.RANGE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                    VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                    VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_MESH_SHADER_BIT_EXT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_MESH_SHADER_BIT_EXT
                ))
            .initialise();

        createDescriptors();
        createPipeline();
    }
    void createDescriptors() {
        /**
         * Bindings:
         *    0     uniform buffer
         *    1     meshlet data buffer
         *    2     line data buffer
         */
        this.descriptors = new Descriptors(context)
            .createLayout()
                .uniformBuffer(VK_SHADER_STAGE_MESH_BIT_EXT | VK_SHADER_STAGE_TASK_BIT_EXT)
                .storageBuffer(VK_SHADER_STAGE_MESH_BIT_EXT)
                .storageBuffer(VK_SHADER_STAGE_MESH_BIT_EXT)
                .sets(1)
            .build();

        descriptors.createSetFromLayout(0)
            .add(ubo)
            .add(meshlets)
            .add(lineData)
            .write();
    }
    void createPipeline() {
        auto shader = context.shaders.getModule("vulkan/lines/lines_ms.slang");

        this.pipeline = new GraphicsPipeline(context)
            .withDSLayouts(descriptors.getAllLayouts())
            .withShader(VK_SHADER_STAGE_TASK_BIT_EXT, shader, null, "taskmain")
            .withShader(VK_SHADER_STAGE_MESH_BIT_EXT, shader, null, "meshmain")
            .withShader(VK_SHADER_STAGE_FRAGMENT_BIT, shader, null, "fsmain")
            .withStdColorBlendState()
            .build();
    }
}
