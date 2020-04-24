module vulkan.api.sampler;
/**
 * https://www.khronos.org/registry/vulkan/specs/1.0/man/html/VkSamplerCreateInfo.html
 */
import vulkan.all;

auto samplerCreateInfo(void delegate(VkSamplerCreateInfo*) call=null) {
    VkSamplerCreateInfo info;
    info.sType  = VkStructureType.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO;
    info.flags  = 0; //reserved

    info.magFilter     = VFilter.LINEAR;
    info.minFilter     = VFilter.LINEAR;
    info.mipmapMode    = VSamplerMipmapMode.LINEAR;
    info.addressModeU  = VSamplerAddressMode.CLAMP_TO_EDGE;
    info.addressModeV  = VSamplerAddressMode.CLAMP_TO_EDGE;
    info.addressModeW  = VSamplerAddressMode.CLAMP_TO_EDGE;
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
