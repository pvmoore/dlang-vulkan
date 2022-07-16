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

    a.loadOp         = VK_ATTACHMENT_LOAD_OP_CLEAR;
    a.storeOp        = VK_ATTACHMENT_STORE_OP_STORE;

    a.stencilLoadOp  = VK_ATTACHMENT_LOAD_OP_DONT_CARE;
    a.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;

    a.initialLayout  = VK_IMAGE_LAYOUT_UNDEFINED;
    a.finalLayout    = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;

    if(call) call(&a);
    return a;
}
auto depthAttachmentDescription(VkFormat format, void delegate(VkAttachmentDescription*) call=null) {
    VkAttachmentDescription a;

    // VK_ATTACHMENT_DESCRIPTION_MAY_ALIAS_BIT
    a.flags = 0;

    a.format         = format;
    a.samples        = VkSampleCountFlagBits.VK_SAMPLE_COUNT_1_BIT;

    a.loadOp         = VK_ATTACHMENT_LOAD_OP_CLEAR;
    a.storeOp        = VK_ATTACHMENT_STORE_OP_DONT_CARE;

    a.stencilLoadOp  = VK_ATTACHMENT_LOAD_OP_DONT_CARE;
    a.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;

    a.initialLayout  = VK_IMAGE_LAYOUT_UNDEFINED;
    a.finalLayout    = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;

    if(call) call(&a);
    return a;
}
auto attachmentReference(
    uint index,
    void delegate(VkAttachmentReference*) call=null)
{
    VkAttachmentReference r;
    r.attachment = index; // index into VkAttachmentDescription array
    r.layout     = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
    if(call) call(&r);
    return r;
}
auto attachmentReference(uint index, VkImageLayout layout) {
    VkAttachmentReference r = {
        attachment: index,
        layout: layout
    };
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
        srcStageMask: VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
        srcAccessMask: 0,
        dstStageMask: VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
        dstAccessMask: VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
        dependencyFlags: VkDependencyFlagBits.VK_DEPENDENCY_BY_REGION_BIT
    };

    if(call) call(&d);
    return d;
}
auto subpassDependency2() {
    VkSubpassDependency d = {
        srcSubpass: VK_SUBPASS_EXTERNAL,
        dstSubpass: 0,
        srcStageMask: VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
        srcAccessMask: VK_ACCESS_MEMORY_READ_BIT,
        dstStageMask: VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
        dstAccessMask: VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
        dependencyFlags: VkDependencyFlagBits.VK_DEPENDENCY_BY_REGION_BIT
    };
    VkSubpassDependency d2 = {
        srcSubpass: 0,
        dstSubpass: VK_SUBPASS_EXTERNAL,
        srcStageMask: VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
        srcAccessMask: VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
        dstStageMask: VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
        dstAccessMask: VK_ACCESS_MEMORY_READ_BIT,
        dependencyFlags: VkDependencyFlagBits.VK_DEPENDENCY_BY_REGION_BIT
    };
    return [d,d2];
}

