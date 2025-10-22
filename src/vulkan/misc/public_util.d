module vulkan.misc.public_util;

import vulkan.all;

string getVulkanSDKBinDirectory() {
    import std.process : environment;
    import std.path    : buildNormalizedPath;

    if(auto p = environment.get("VULKAN_SDK")) {
        return buildNormalizedPath(p ~ "/Bin/");
    }
    log("public_util", "Unable to find the Vulkan SDK bin directory. VULKAN_SDK environment variable not set");
    return "";
}

enum VK_API_VERSION_1_0 = VK_MAKE_API_VERSION(0, 1, 0, 0);
enum VK_API_VERSION_1_1 = VK_MAKE_API_VERSION(0, 1, 1, 0);
enum VK_API_VERSION_1_2 = VK_MAKE_API_VERSION(0, 1, 2, 0);
enum VK_API_VERSION_1_3 = VK_MAKE_API_VERSION(0, 1, 3, 0);
enum VK_API_VERSION_1_4 = VK_MAKE_API_VERSION(0, 1, 4, 0);

uint VK_MAKE_API_VERSION(uint variant, uint major, uint minor, uint patch) {
    return (variant << 29U) | (major << 22U) | (minor << 12U) | patch;
}

ulong GB(ulong v) {
    return v*1024*1024*1024;
}
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
VkClearValue depthStencilClearColour(float depth, uint stencil) {
    VkClearValue value;
    value.depthStencil = VkClearDepthStencilValue(depth, stencil);
    return value;
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
        throwIf(true);
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

        info.loadOp        = VK_ATTACHMENT_LOAD_OP_CLEAR;
        info.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
        info.finalLayout   = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
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
