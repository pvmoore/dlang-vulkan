module vulkan.pipelines.raytracing_pipeline;

import vulkan.all;

private struct None { int a; }

final class RayTracingPipeline {
private:
    @Borrowed VulkanContext context;
    @Borrowed VkDevice device;

    struct ShaderInfo {
        VkShaderStageFlagBits stage;
        VkShaderModule shader;
        VkSpecializationInfo specInfo;
    }

    VkDescriptorSetLayout[] dsLayouts;
    VkPushConstantRange[] pcRanges;

    ShaderInfo[] shaders;
    VkRayTracingShaderGroupCreateInfoKHR[] shaderGroups;
public:
    VkPipeline pipeline;
    VkPipelineLayout layout;

    uint getNumShaderGroups() { return shaderGroups.length.as!uint; }

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
    auto withPushConstantRange(T)(VkShaderStageFlags stages, uint offset = 0) {
        auto pcRange = VkPushConstantRange(
            stages,
            offset,
            T.sizeof
        );
        pcRanges ~= pcRange;
        return this;
    }
    auto withShader(T=None)(VkShaderStageFlagBits stage, VkShaderModule shader, T* specInfo=null) {
        throwIf(!stage.isOneOf(
            VK_SHADER_STAGE_RAYGEN_BIT_KHR,
            VK_SHADER_STAGE_MISS_BIT_KHR,
            VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR,
            VK_SHADER_STAGE_ANY_HIT_BIT_KHR,
            VK_SHADER_STAGE_INTERSECTION_BIT_KHR,
            VK_SHADER_STAGE_CALLABLE_BIT_KHR
        ), "Unsupported stage %s", stage);

        this.shaders ~= ShaderInfo(stage, shader);
        if(specInfo) {
            shaders[$-1].specInfo = .specialisationInfo!T(specInfo);
        }
        return this;
    }
    /**
     * For raygen, miss or callable shaders
     */
    auto withGeneralGroup(uint shaderIndex) {
        VkRayTracingShaderGroupCreateInfoKHR group = {
            sType: VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_KHR,
            type: VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_KHR,
            generalShader: shaderIndex,
            closestHitShader: VK_SHADER_UNUSED_KHR,
            anyHitShader: VK_SHADER_UNUSED_KHR,
            intersectionShader: VK_SHADER_UNUSED_KHR
        };
        shaderGroups ~= group;
        return this;
    }
    /**
     * For closestHit, anyHit or intersection shaders
     */
    auto withHitGroup(VkRayTracingShaderGroupTypeKHR type,
                      uint closestHitIndex,
                      uint anyHitIndex,
                      uint intersectionIndex)
    {
        throwIf(!type.isOneOf(VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_KHR,
                              VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR));

        VkRayTracingShaderGroupCreateInfoKHR group = {
            sType: VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_KHR,
            type: type,
            generalShader: VK_SHADER_UNUSED_KHR,
            closestHitShader: closestHitIndex,
            anyHitShader: anyHitIndex,
            intersectionShader: intersectionIndex
        };
        shaderGroups ~= group;
        return this;
    }
    auto build() {
        throwIf(dsLayouts.length == 0);
        throwIf(shaders.length == 0);
        throwIf(shaderGroups.length == 0);

        VkPipelineShaderStageCreateInfo[] stageInfos =
            shaders.map!(it=>shaderStage(it.stage, it.shader, "main", it.specInfo.dataSize == 0 ? null : &it.specInfo))
                   .array;

        this.layout = createPipelineLayout(
            device,
            dsLayouts,
            pcRanges
        );

        this.pipeline = createRayTracingPipeline(
            device,
            layout,
            stageInfos,
            shaderGroups
        );

        return this;
    }
}