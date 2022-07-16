module vulkan.api.sampler;
/**
 * https://www.khronos.org/registry/vulkan/specs/1.0/man/html/VkSamplerCreateInfo.html
 */
import vulkan.all;

auto samplerCreateInfo(void delegate(VkSamplerCreateInfo*) call=null) {
    VkSamplerCreateInfo info;
    info.sType  = VkStructureType.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO;
    info.flags  = 0; //reserved

    info.magFilter     = VK_FILTER_LINEAR;
    info.minFilter     = VK_FILTER_LINEAR;
    info.mipmapMode    = VK_SAMPLER_MIPMAP_MODE_LINEAR;
    info.addressModeU  = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
    info.addressModeV  = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
    info.addressModeW  = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
    info.compareEnable = VK_FALSE;
    info.compareOp     = VkCompareOp.VK_COMPARE_OP_ALWAYS;
    info.mipLodBias    = 0;
    info.minLod        = 0;
    info.maxLod        = 0;
    info.borderColor   = VkBorderColor.VK_BORDER_COLOR_INT_OPAQUE_BLACK;
    info.anisotropyEnable = VK_FALSE;
    info.maxAnisotropy    = 1;
    info.unnormalizedCoordinates = VK_FALSE;

    if(call) call(&info);
    return info;
}
VkSampler createSampler(VkDevice device, VkSamplerCreateInfo info) {
    VkSampler handle;
    check(vkCreateSampler(
        device,
        &info,
        null,
        &handle
    ));
    return handle;
}
