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
    VkPipeline pipeline;
    VkPipelineLayout layout;

    this(VulkanContext context) {
        this.context = context;
        this.device = context.device;
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

        pipeline = createComputePipeline(
            device,
            layout,
            shaderStage
        );

        return this;
    }
}

