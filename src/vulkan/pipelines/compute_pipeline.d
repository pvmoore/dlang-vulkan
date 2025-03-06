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
    VkShaderModule shaderModule;
    bool hasSpecialisationInfo;
    VkSpecializationInfo specialisationInfo;
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
    auto withShader(T=None)(VkShaderModule shader, T* specInfo=null) {
        this.shaderModule = shader;
        if(specInfo) {
            this.specialisationInfo    = .specialisationInfo!T(specInfo);
            this.hasSpecialisationInfo = true;
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
        throwIf(shaderModule is null);
        throwIf(dsLayouts.length == 0);

        layout = createPipelineLayout(
            device,
            dsLayouts,
            pcRanges
        );

        auto shaderStage = .shaderStage(
            VK_SHADER_STAGE_COMPUTE_BIT,
            shaderModule,
            "main",
            hasSpecialisationInfo ? &specialisationInfo : null
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

