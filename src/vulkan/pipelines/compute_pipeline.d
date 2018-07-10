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
    string shaderFilename;
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
        if(layout) device.destroy(layout);
        if(pipeline) device.destroy(pipeline);
    }
    auto withDSLayouts(VkDescriptorSetLayout[] dsLayouts) {
        this.dsLayouts = dsLayouts;
        return this;
    }
    auto withShader(T=None)(string filename, T* specInfo=null) {
        this.shaderFilename = filename;
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
        expect(shaderFilename !is null);
        expect(dsLayouts.length>0);

        layout = createPipelineLayout(
            device,
            dsLayouts,
            pcRanges
        );

        auto shader = createShaderModule(device, shaderFilename);

        auto shaderStage = shaderStage(
            VShaderStage.COMPUTE,
            shader,
            "main",
            hasSpecialisationInfo ? &specialisationInfo : null
        );

        pipeline = createComputePipeline(
            device,
            layout,
            shaderStage
        );

        device.destroy(shader);
        return this;
    }
}

