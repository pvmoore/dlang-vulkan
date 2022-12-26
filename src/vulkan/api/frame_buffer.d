module vulkan.api.frame_buffer;

import vulkan.all;

VkFramebuffer createFrameBuffer(VkDevice device,
                                VkRenderPass renderPass,
                                VkImageView[] views,
                                uint width,
                                uint height,
                                uint layers)
{
    VkFramebuffer frameBuffer;
    VkFramebufferCreateInfo info;
    info.sType           = VkStructureType.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
    info.flags           = 0;
    info.renderPass      = renderPass;
    info.attachmentCount = cast(uint)views.length;
    info.pAttachments    = views.ptr;
    info.width           = width;
    info.height          = height;
    info.layers          = layers;

    check(vkCreateFramebuffer(
        device,
        &info,
        null,
        &frameBuffer
    ));

    return frameBuffer;
}
