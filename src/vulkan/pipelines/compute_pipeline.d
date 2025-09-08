module vulkan.pipelines.compute_pipeline;
/**
 *
 */
import vulkan.all;

private struct None { int a; }

final class ComputePipeline {
private:
    @Borrowed VulkanContext context;
    @Borrowed VkDevice device;

    VkDescriptorSetLayout[] dsLayouts;
    VkPushConstantRange[] pcRanges;

    VkSpecializationInfo specialisationInfo;
    VkPipelineShaderStageCreateInfo shaderStage = {
        sType: VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
        stage: VK_SHADER_STAGE_COMPUTE_BIT,
        pName: "main".ptr
    };
public:
    string name;
    VkPipeline pipeline;
    VkPipelineLayout layout;

    this(VulkanContext context, string name = null) {
        this.context = context;
        this.device = context.device;
        this.name = name;
    }
    void destroy() {
        if(layout) device.destroyPipelineLayout(layout);
        if(pipeline) device.destroyPipeline(pipeline);
    }
    auto withDSLayouts(VkDescriptorSetLayout[] dsLayouts) {
        this.dsLayouts = dsLayouts;
        return this;
    }
    auto withShader(T=None)(VkShaderModule shader, T* specInfo = null, string entry = "main") {
        shaderStage.module_ = shader;
        shaderStage.pName = entry.toStringz();
        if(specInfo) {
            specialisationInfo = .specialisationInfo!T(specInfo);
            shaderStage.pSpecializationInfo = &specialisationInfo;
        }
        return this;
    }
    auto withPushConstantRange(T)(uint offset = 0) {
        auto pcRange = VkPushConstantRange(
            VK_SHADER_STAGE_COMPUTE_BIT,
            offset,
            T.sizeof    // size
        );
        pcRanges ~= pcRange;
        return this;
    }
    auto build() {
        throwIf(shaderStage.module_ is null);
        throwIf(dsLayouts.length == 0);

        layout = createPipelineLayout(
            device,
            dsLayouts,
            pcRanges
        );

        VkComputePipelineCreateInfo info = {
            sType: VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO,
            // eg.
            // VK_PIPELINE_CREATE_DISABLE_OPTIMIZATION_BIT
            // VK_PIPELINE_CREATE_ALLOW_DERIVATIVES_BIT
            // VK_PIPELINE_CREATE_DERIVATIVE_BIT
            // VK_PIPELINE_CREATE_LINK_TIME_OPTIMIZATION_BIT_EXT
            flags               : 0,
            stage               : shaderStage,     
            layout              : layout,             
            basePipelineHandle  : null,
            basePipelineIndex   : -1
        };

        check(vkCreateComputePipelines(
            device,
            null,   // VkPipelineCache
            1,
            &info,
            null,   // VkAllocationCallbacks
            &pipeline
        ));

        if(name) {
            setObjectDebugName!VK_OBJECT_TYPE_PIPELINE(device, pipeline, name);
        }

        return this;
    }
}

