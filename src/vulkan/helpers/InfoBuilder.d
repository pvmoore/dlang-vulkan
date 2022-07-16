module vulkan.helpers.InfoBuilder;

import vulkan.all;

final class InfoBuilder {
private:
    @Borrowed VulkanContext context;
    @Borrowed VkDevice device;
public:
    this(VulkanContext context) {
        this.context = context;
        this.device = context.device;
    }
    /**
     *  Create a standard VkSampler with linear filtering and no anisotropy.
     */
    VkSampler sampler(void delegate(ref VkSamplerCreateInfo) modify = null) {
        VkSamplerCreateInfo info = {
            sType: VkStructureType.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
            flags: 0, //reserved

            magFilter: VK_FILTER_LINEAR,
            minFilter: VK_FILTER_LINEAR,
            mipmapMode: VK_SAMPLER_MIPMAP_MODE_LINEAR,
            addressModeU: VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
            addressModeV: VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
            addressModeW: VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
            compareEnable: VK_FALSE,
            compareOp: VkCompareOp.VK_COMPARE_OP_ALWAYS,
            mipLodBias: 0,
            minLod: 0,
            maxLod: 0,
            borderColor: VkBorderColor.VK_BORDER_COLOR_INT_OPAQUE_BLACK,
            anisotropyEnable: VK_FALSE,
            maxAnisotropy: 1,
            unnormalizedCoordinates: VK_FALSE
        };
        if(modify) modify(info);
        return device.createSampler(info);
    }
}