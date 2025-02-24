module vulkan.api.cmd_barriers;

import vulkan.all;

void pipelineBarrier(VkCommandBuffer buffer, 
                     VkPipelineStageFlags srcStageMask, 
                     VkPipelineStageFlags dstStageMask, 
                     VkDependencyFlags dependencyFlags, 
                     VkMemoryBarrier[] memoryBarriers, 
                     VkBufferMemoryBarrier[] bufferMemoryBarriers, 
                     VkImageMemoryBarrier[] imageMemoryBarriers) 
{
    vkCmdPipelineBarrier(buffer, srcStageMask, dstStageMask, dependencyFlags, cast(uint)memoryBarriers.length, memoryBarriers.ptr, cast(uint)bufferMemoryBarriers.length, bufferMemoryBarriers.ptr, cast(uint)imageMemoryBarriers.length, imageMemoryBarriers.ptr);
}

VkImageMemoryBarrier imageMemoryBarrier(VkImage image,
                                        VkAccessFlags srcAccess,
                                        VkAccessFlags dstAccess,
                                        VkImageLayout fromLayout,
                                        VkImageLayout toLayout,
                                        uint fromQueue = VK_QUEUE_FAMILY_IGNORED,
                                        uint toQueue = VK_QUEUE_FAMILY_IGNORED)
{
    VkImageSubresourceRange range = {
        aspectMask: VK_IMAGE_ASPECT_COLOR_BIT,
        baseMipLevel: 0,
        levelCount: VK_REMAINING_MIP_LEVELS,
        baseArrayLayer: 0,
        layerCount: VK_REMAINING_ARRAY_LAYERS
    };
    VkImageMemoryBarrier barrier = {
        sType: VkStructureType.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
        srcAccessMask: srcAccess,
        dstAccessMask: dstAccess,
        oldLayout: fromLayout,
        newLayout: toLayout,
        srcQueueFamilyIndex: fromQueue,
        dstQueueFamilyIndex: toQueue,
        image: image,
        subresourceRange: range
    };
    return barrier;
}

VkBufferMemoryBarrier bufferMemoryBarrier(VkBuffer buffer,
                                          ulong offset,
                                          ulong size,
                                          VkAccessFlags srcAccess,
                                          VkAccessFlags dstAccess,
                                          uint srcQueue = VK_QUEUE_FAMILY_IGNORED,
                                          uint dstQueue = VK_QUEUE_FAMILY_IGNORED)
{
    VkBufferMemoryBarrier barrier = {
        sType: VkStructureType.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
        srcAccessMask: srcAccess,
        dstAccessMask: dstAccess,
        srcQueueFamilyIndex: srcQueue,
        dstQueueFamilyIndex: dstQueue,
        buffer: buffer,
        offset: offset,
        size: size
    };
    return barrier;
}


void setImageLayout(VkCommandBuffer commandBuffer,
                    VkImage image,
                    VkImageAspectFlags aspectMask,
                    VkImageLayout oldLayout,
                    VkImageLayout newLayout,
                    uint srcQueue=VK_QUEUE_FAMILY_IGNORED,
                    uint dstQueue=VK_QUEUE_FAMILY_IGNORED)
{
    VkImageSubresourceRange range = {
        aspectMask     : aspectMask,
        baseMipLevel   : 0,
        levelCount     : VK_REMAINING_MIP_LEVELS,
        baseArrayLayer : 0,
        layerCount     : VK_REMAINING_ARRAY_LAYERS
    };
    VkImageMemoryBarrier barrier = {
        sType               : VkStructureType.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
        oldLayout           : oldLayout,
        newLayout           : newLayout,
        srcQueueFamilyIndex : srcQueue,
        dstQueueFamilyIndex : dstQueue,
        image               : image,
        subresourceRange    : range                        
    };

    auto srcStageMask = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
    auto dstStageMask = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;

    // VPipelineStage.HOST

    // Undefined layout:
    //   Note: Only allowed as initial layout!
    //   Note: Make sure any writes to the image have been finished
//    if(oldImageLayout == VkImageLayout.VK_VImageLayout.UNDEFINED)
//        barrier.srcAccessMask = VkAccessFlagBits.VK_ACCESS_HOST_WRITE_BIT |
//                                VkAccessFlagBits.VK_ACCESS_TRANSFER_WRITE_BIT;

    if(oldLayout==VK_IMAGE_LAYOUT_PREINITIALIZED &&
       newLayout==VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL)
    {
        barrier.srcAccessMask = VK_ACCESS_HOST_WRITE_BIT;
        barrier.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
        srcStageMask = VK_PIPELINE_STAGE_HOST_BIT;
        dstStageMask = VK_PIPELINE_STAGE_TRANSFER_BIT;
    }
    if(oldLayout==VK_IMAGE_LAYOUT_PREINITIALIZED &&
       newLayout==VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL)
    {
        barrier.srcAccessMask = VK_ACCESS_HOST_WRITE_BIT;
        barrier.dstAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        srcStageMask = VK_PIPELINE_STAGE_HOST_BIT;
        dstStageMask = VK_PIPELINE_STAGE_TRANSFER_BIT;
    }
    if(oldLayout==VK_IMAGE_LAYOUT_UNDEFINED &&
       newLayout==VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL)
    {
        barrier.srcAccessMask = 0;
        barrier.dstAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        srcStageMask = VK_PIPELINE_STAGE_HOST_BIT;
        dstStageMask = VK_PIPELINE_STAGE_TRANSFER_BIT;
    }
    if(oldLayout==VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL &&
       newLayout==VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
    {
        barrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        barrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT;
        srcStageMask = VK_PIPELINE_STAGE_TRANSFER_BIT;
        dstStageMask = VK_PIPELINE_STAGE_ALL_COMMANDS_BIT;
    }
/*
    // Old layout is color attachment:
    //   Note: Make sure any writes to the color buffer have been finished
    if(oldImageLayout == VkImageLayout.VK_VImageLayout.COLOR_ATTACHMENT_OPTIMAL)
        barrier.srcAccessMask = VkAccessFlagBits.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;

    // Old layout is transfer source:
    //   Note: Make sure any reads from the image have been finished
    if(oldImageLayout == VkImageLayout.VK_VImageLayout.TRANSFER_SRC_OPTIMAL)
        barrier.srcAccessMask = VkAccessFlagBits.VK_ACCESS_TRANSFER_READ_BIT;

    // Old layout is shader read (sampler, input attachment):
    //   Note: Make sure any shader reads from the image have been finished
    if(oldImageLayout == VkImageLayout.VK_VImageLayout.SHADER_READ_ONLY_OPTIMAL)
        barrier.srcAccessMask = VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT;


    // New layout is transfer destination (copy, blit):
    //   Note: Make sure any copyies to the image have been finished
    if(newImageLayout == VkImageLayout.VK_VImageLayout.TRANSFER_DST_OPTIMAL)
        barrier.dstAccessMask = VkAccessFlagBits.VK_ACCESS_TRANSFER_WRITE_BIT;

    // New layout is transfer source (copy, blit):
    //   Note: Make sure any reads from and writes to the image have been finished
    if(newImageLayout == VkImageLayout.VK_VImageLayout.TRANSFER_SRC_OPTIMAL) {
        barrier.srcAccessMask = barrier.srcAccessMask |
                                VkAccessFlagBits.VK_ACCESS_TRANSFER_READ_BIT;
        barrier.dstAccessMask = VkAccessFlagBits.VK_ACCESS_TRANSFER_READ_BIT;
    }

    // New layout is color attachment:
    //   Note: Make sure any writes to the color buffer hav been finished
    if(newImageLayout == VkImageLayout.VK_VImageLayout.COLOR_ATTACHMENT_OPTIMAL) {
        barrier.dstAccessMask = VkAccessFlagBits.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
        barrier.srcAccessMask = VkAccessFlagBits.VK_ACCESS_TRANSFER_READ_BIT;
    }

    // New layout is depth attachment:
    //   Note: Make sure any writes to depth/stencil buffer have been finished
    if(newImageLayout == VkImageLayout.VK_VImageLayout.DEPTH_STENCIL_ATTACHMENT_OPTIMAL)
        barrier.dstAccessMask = barrier.dstAccessMask |
                                VkAccessFlagBits.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;

    // New layout is shader read (sampler, input attachment):
    //   Note: Make sure any writes to the image have been finished
    if(newImageLayout == VkImageLayout.VK_VImageLayout.SHADER_READ_ONLY_OPTIMAL) {
        barrier.srcAccessMask = VkAccessFlagBits.VK_ACCESS_HOST_WRITE_BIT |
                                VkAccessFlagBits.VK_ACCESS_TRANSFER_WRITE_BIT;
        barrier.dstAccessMask = VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT;
    }
*/

    vkCmdPipelineBarrier(commandBuffer,
                         srcStageMask,
                         dstStageMask,
                         0,               // dependencyFlags

                         0,               // memoryBarrierCount
                         null,
                         0,              // bufferMemoryBarrierCount
                         null,
                         1,              // imageMemoryBarrierCount
                         &barrier);
}
