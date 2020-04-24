module vulkan.api.render_pass;
/**
 * https://www.khronos.org/registry/vulkan/specs/1.0/man/html/VkRenderPassCreateInfo.html
 */
import vulkan.all;

VkRenderPass createRenderPass(VkDevice device,
                              VkAttachmentDescription[] attachmentDescriptions,
                              VkSubpassDescription[] subpassDescriptions,
                              VkSubpassDependency[] subpassDependencies)
{
    VkRenderPass renderPass;
    VkRenderPassCreateInfo info;
    info.sType           = VkStructureType.VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
    info.flags           = 0;

    info.attachmentCount = cast(uint)attachmentDescriptions.length;
    info.pAttachments    = attachmentDescriptions.ptr;

    info.subpassCount    = cast(uint)subpassDescriptions.length;
    info.pSubpasses      = subpassDescriptions.ptr;

    info.dependencyCount = cast(uint)subpassDependencies.length;
    info.pDependencies   = subpassDependencies.ptr;

    check(vkCreateRenderPass(
        device,
        &info,
        null,
        &renderPass
    ));

    return renderPass;
}
VkExtent2D getRenderAreaGranularity(VkDevice device, VkRenderPass renderPass) {
    VkExtent2D granularity;
    vkGetRenderAreaGranularity(device, renderPass, &granularity);
    return granularity;
}
auto attachmentDescription(
    VkFormat format,
    void delegate(VkAttachmentDescription*) call=null)
{
    VkAttachmentDescription a;

    // VK_ATTACHMENT_DESCRIPTION_MAY_ALIAS_BIT
    a.flags = 0;

    a.format         = format;
    a.samples        = VkSampleCountFlagBits.VK_SAMPLE_COUNT_1_BIT;

    a.loadOp         = VAttachmentLoadOp.CLEAR;
    a.storeOp        = VAttachmentStoreOp.STORE;

    a.stencilLoadOp  = VAttachmentLoadOp.DONT_CARE;
    a.stencilStoreOp = VAttachmentStoreOp.DONT_CARE;

    a.initialLayout  = VImageLayout.UNDEFINED;
    a.finalLayout    = VImageLayout.PRESENT_SRC_KHR;

    if(call) call(&a);
    return a;
}
auto attachmentReference(
    uint index,
    void delegate(VkAttachmentReference*) call=null)
{
    VkAttachmentReference r;
    r.attachment = index; // index into VkAttachmentDescription array
    r.layout     = VImageLayout.COLOR_ATTACHMENT_OPTIMAL;
    if(call) call(&r);
    return r;
}
auto subpassDescription(void delegate(VkSubpassDescription*) call=null) {
    VkSubpassDescription s;
    s.pipelineBindPoint = VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS;
    if(call) call(&s);
    return s;
}
auto subpassDependency(void delegate(VkSubpassDependency*) call=null) {
    VkSubpassDependency d = {
        srcSubpass: VK_SUBPASS_EXTERNAL,
        dstSubpass: 0,
        srcStageMask: VPipelineStage.COLOR_ATTACHMENT_OUTPUT,
        srcAccessMask: 0,
        dstStageMask: VPipelineStage.COLOR_ATTACHMENT_OUTPUT,
        dstAccessMask: VAccess.COLOR_ATTACHMENT_READ |
                       VAccess.COLOR_ATTACHMENT_WRITE,
        dependencyFlags: VkDependencyFlagBits.VK_DEPENDENCY_BY_REGION_BIT
    };

    if(call) call(&d);
    return d;
}
auto subpassDependency2() {
    VkSubpassDependency d = {
        srcSubpass: VK_SUBPASS_EXTERNAL,
        dstSubpass: 0,
        srcStageMask: VPipelineStage.BOTTOM_OF_PIPE,
        srcAccessMask: VAccess.MEMORY_READ,
        dstStageMask: VPipelineStage.COLOR_ATTACHMENT_OUTPUT,
        dstAccessMask: VAccess.COLOR_ATTACHMENT_READ |
                       VAccess.COLOR_ATTACHMENT_WRITE,
        dependencyFlags: VkDependencyFlagBits.VK_DEPENDENCY_BY_REGION_BIT
    };
    VkSubpassDependency d2 = {
        srcSubpass: 0,
        dstSubpass: VK_SUBPASS_EXTERNAL,
        srcStageMask: VPipelineStage.COLOR_ATTACHMENT_OUTPUT,
        srcAccessMask: VAccess.COLOR_ATTACHMENT_READ |
                       VAccess.COLOR_ATTACHMENT_WRITE,
        dstStageMask: VPipelineStage.BOTTOM_OF_PIPE,
        dstAccessMask: VAccess.MEMORY_READ,
        dependencyFlags: VkDependencyFlagBits.VK_DEPENDENCY_BY_REGION_BIT
    };
    return [d,d2];
}

