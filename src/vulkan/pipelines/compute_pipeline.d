module vulkan.pipelines.compute_pipeline;
/**
 *
 */
import vulkan.all;

private struct None { int a; }

final class ComputePipeline {
private:
    Vulkan vk;
    VkDevice device;
    VkDescriptorSetLayout[] dsLayouts;
    VkPushConstantRange[] pcRanges;
    VkShaderModule shaderModule;
    bool hasSpecialisationInfo;
    VkSpecializationInfo specialisationInfo;
public:
    VkPipeline pipeline;
    VkPipelineLayout layout;

    this(Vulkan vk) {
        this.vk     = vk;
        this.device = vk.device;
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
            VShaderStage.COMPUTE,
            offset,
            T.sizeof    // size
        );
        pcRanges ~= pcRange;
        return this;
    }
    auto build() {
        expect(shaderModule !is null);
        expect(dsLayouts.length>0);

        layout = createPipelineLayout(
            device,
            dsLayouts,
            pcRanges
        );

        auto shaderStage = shaderStage(
            VShaderStage.COMPUTE,
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

