module vulkan.api.cmd_rendering;

import vulkan.all;

// union VkClearValue {
//     VkClearColorValue           color;
//     VkClearDepthStencilValue    depthStencil;
// }
//union VkClearColorValue {
//    float       float32[4];
//    int32_t     int32[4];
//    uint32_t    uint32[4];
//}
//struct VkClearDepthStencilValue {
//    float       depth;
//    uint32_t    stencil;
//}

/**
 *  Functions related to rendering with a VkRenderPass
 */
 void beginRenderPass(VkCommandBuffer buffer,
                      VkRenderPass renderPass,
                      VkFramebuffer frameBuffer,
                      VkRect2D renderArea,
                      VkClearValue[] clearValues,
                      VkSubpassContents contents)
{
    VkRenderPassBeginInfo info = {
        sType: VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
        renderPass: renderPass,
        framebuffer: frameBuffer,
        renderArea: renderArea,
        clearValueCount: cast(uint)clearValues.length,
        pClearValues: clearValues.ptr
    };

    //VkSubpassContents.VK_SUBPASS_CONTENTS_INLINE = 0,
    //VkSubpassContents.VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS = 1,

    vkCmdBeginRenderPass(buffer, &info, contents);
}
void nextSubpass(VkCommandBuffer buffer, VkSubpassContents contents) {
    vkCmdNextSubpass(buffer, contents);
}
void endRenderPass(VkCommandBuffer buffer) {
    vkCmdEndRenderPass(buffer);
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
/**
 * Functions related to dynamic rendering.
 *
 * Either Vulkan 1.3 or VK_KHR_dynamic_rendering must be enabled.
 *
 * This function assumes a single colour attachment and no depth or stencil.
 */
void beginDynamicRendering(VkCommandBuffer buffer,
                           VkImageView imageView,
                           VkRect2D renderArea,
                           VkClearValue clearValue,
                           void delegate(VkRenderingInfo*) callback = null) 
{
    VkRenderingAttachmentInfo colourAttachment = {
        sType:              VK_STRUCTURE_TYPE_RENDERING_ATTACHMENT_INFO,
        imageView:          imageView,
        imageLayout:        VK_IMAGE_LAYOUT_ATTACHMENT_OPTIMAL,
        resolveMode:        VK_RESOLVE_MODE_NONE,
        resolveImageView:   null,
        resolveImageLayout: VK_IMAGE_LAYOUT_ATTACHMENT_OPTIMAL,
        loadOp:             VK_ATTACHMENT_LOAD_OP_CLEAR,
        storeOp:            VK_ATTACHMENT_STORE_OP_STORE,
        clearValue:         clearValue
    };

    VkRenderingInfo renderingInfo = {
        sType:                VK_STRUCTURE_TYPE_RENDERING_INFO,
        renderArea:           renderArea,
        flags:                0,   // VkRenderingFlagBits
        layerCount:           1,
        viewMask:             0,
        colorAttachmentCount: 1,
        pColorAttachments:    &colourAttachment,
        pDepthAttachment:     null,
        pStencilAttachment:   null
    };

    // Possible pNext chain structs:
    //  - VkDeviceGroupRenderPassBeginInfo 

    // allow the caller to add/edit fields in the renderingInfo struct
    if(callback) callback(&renderingInfo);     

    vkCmdBeginRendering(buffer, &renderingInfo);
}

void endDynamicRendering(VkCommandBuffer buffer) {
    vkCmdEndRendering(buffer);
}
