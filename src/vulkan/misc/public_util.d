module vulkan.misc.public_util;

import vulkan.all;

ulong MB(ulong v) {
    return v*1024*1024;
}
ulong KB(ulong v) {
    return v*1024;
}

VkBool32 toVkBool32(bool b) {
    return b ? VK_TRUE : VK_FALSE;
}
VkExtent2D toVkExtent2D(uvec2 d) {
    return VkExtent2D(d.width, d.height);
}
VkRect2D toVkRect2D(int x, int y, uint w, uint h) {
    return VkRect2D(VkOffset2D(x,y), VkExtent2D(w,h));
}
VkRect2D toVkRect2D(int x, int y, VkExtent2D e) {
    return VkRect2D(VkOffset2D(x,y), e);
}
VkClearValue clearColour(float r, float g, float b, float a) {
    VkClearColorValue value;
    value.float32 = [r,g,b,a];
    return cast(VkClearValue)value;
}
uvec2 toUvec2(VkExtent2D e) {
    return uvec2(e.width, e.height);
}
VkExtent3D toVkExtent3D(uint[] dims) {
    if(dims.length==1) return VkExtent3D(dims[0], 1, 1);
    if(dims.length==2) return VkExtent3D(dims[0], dims[1], 1);
    return VkExtent3D(dims[0], dims[1], dims[2]);
}
/// eg.  componentMapping!"rgba";
VkComponentMapping componentMapping(string s)() {
    static assert(s.length==4);
    VkComponentSwizzle get(char c) {
        if(c=='r') return VkComponentSwizzle.VK_COMPONENT_SWIZZLE_R;
        if(c=='g') return VkComponentSwizzle.VK_COMPONENT_SWIZZLE_G;
        if(c=='b') return VkComponentSwizzle.VK_COMPONENT_SWIZZLE_B;
        if(c=='a') return VkComponentSwizzle.VK_COMPONENT_SWIZZLE_A;
        assert(false);
    }
    return VkComponentMapping(get(s[0]),get(s[1]),get(s[2]),get(s[3]));
}
/**
 *  Create the standard renderPass.
 */
VkRenderPass createStandardRenderPass(Vulkan vk, VkDevice device) {
    auto colorAttachment = attachmentDescription(
        vk.swapchain.colorFormat, (info) {

        info.loadOp        = VAttachmentLoadOp.CLEAR;
        info.initialLayout = VImageLayout.UNDEFINED;
        info.finalLayout   = VImageLayout.PRESENT_SRC_KHR;
    });
    auto colorAttachmentRef = attachmentReference(0);

    auto subpass = subpassDescription((info) {
        info.colorAttachmentCount = 1;
        info.pColorAttachments    = &colorAttachmentRef;
    });

    auto dependency = subpassDependency();

    return .createRenderPass(
        device,
        [colorAttachment],
        [subpass],
        [dependency]);
}