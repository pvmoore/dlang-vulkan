module vulkan.api.cmd_barriers;

import vulkan.all;

struct AccessAndStageMasks {
    VkAccessFlagBits srcAccessMask = VkAccessFlagBits.VK_ACCESS_NONE;
    VkAccessFlagBits dstAccessMask;
    VkPipelineStageFlags srcStageMask;
    VkPipelineStageFlags dstStageMask;
}

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

/**
 * Inserts a memory write transfer barrier.
 *
 * Params: 
 *  srcAccessAndStageMasks = The source access and stage masks before the barrier
 */
void beforeTransferBarrier(VkCommandBuffer cmd, AccessAndStageMasks srcAccessAndStageMasks) {
    
    VkAccessFlagBits srcAccessMask = srcAccessAndStageMasks.srcAccessMask;
    VkPipelineStageFlags srcStageMask = srcAccessAndStageMasks.srcStageMask;

    if(srcAccessMask == 0) {
        srcAccessMask = VkAccessFlagBits.VK_ACCESS_MEMORY_READ_BIT;
    }
    if(srcStageMask == 0) {
        srcStageMask = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
    }
    
    VkMemoryBarrier memoryBarrier = {
        sType: VkStructureType.VK_STRUCTURE_TYPE_MEMORY_BARRIER,
        srcAccessMask: srcAccessMask,
        dstAccessMask: VkAccessFlagBits.VK_ACCESS_TRANSFER_WRITE_BIT
    };
    vkCmdPipelineBarrier(
        cmd, 
        srcStageMask,
        VkPipelineStageFlagBits.VK_PIPELINE_STAGE_TRANSFER_BIT,
        VkDependencyFlagBits.VK_DEPENDENCY_BY_REGION_BIT, 
        1, 
        &memoryBarrier, 
        0,
        null,
        0, 
        null);
}
/**
 * Inserts a buffer read transfer barrier.
 *
 * Params: 
 *  dstAccessAndStageMasks = The destination access and stage masks after the barrier
 */
void afterTransferBarrier(VkCommandBuffer cmd, AccessAndStageMasks dstAccessAndStageMasks) {
    
    VkAccessFlagBits dstAccessMask = dstAccessAndStageMasks.dstAccessMask;
    VkPipelineStageFlags dstStageMask = dstAccessAndStageMasks.dstStageMask;

    if(dstAccessMask == 0) {
        dstAccessMask = VkAccessFlagBits.VK_ACCESS_MEMORY_READ_BIT;
    }
    if(dstStageMask == 0) {
        dstStageMask = VkPipelineStageFlagBits.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
    }
    
    VkMemoryBarrier memoryBarrier = {
        sType: VkStructureType.VK_STRUCTURE_TYPE_MEMORY_BARRIER,
        srcAccessMask: VkAccessFlagBits.VK_ACCESS_TRANSFER_WRITE_BIT,
        dstAccessMask: dstAccessMask
    };
    vkCmdPipelineBarrier(
        cmd, 
        VkPipelineStageFlagBits.VK_PIPELINE_STAGE_TRANSFER_BIT,
        dstStageMask,
        VkDependencyFlagBits.VK_DEPENDENCY_BY_REGION_BIT, 
        1, 
        &memoryBarrier, 
        0, 
        null,
        0,
        null);
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
//──────────────────────────────────────────────────────────────────────────────────────────────────
struct WholeImageBarrierData {
    VkImage image;
    VkImageAspectFlags aspectMask;
    VkImageLayout srcLayout;
    VkImageLayout dstLayout;
    VkAccessFlags srcAccessMask;
    VkAccessFlags dstAccessMask;
    VkPipelineStageFlags srcStageFlags;
    VkPipelineStageFlags dstStageFlags;
    uint srcQueue = VK_QUEUE_FAMILY_IGNORED;
    uint dstQueue = VK_QUEUE_FAMILY_IGNORED;
}

void imageBarrier(VkCommandBuffer commandBuffer, WholeImageBarrierData data) { 
    VkImageSubresourceRange range = {
        aspectMask     : data.aspectMask,
        baseMipLevel   : 0,
        levelCount     : VK_REMAINING_MIP_LEVELS,
        baseArrayLayer : 0,
        layerCount     : VK_REMAINING_ARRAY_LAYERS
    };
    VkImageMemoryBarrier barrier = {
        sType               : VkStructureType.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
        srcAccessMask       : data.srcAccessMask, 
        dstAccessMask       : data.dstAccessMask,
        oldLayout           : data.srcLayout,
        newLayout           : data.dstLayout,
        srcQueueFamilyIndex : data.srcQueue,
        dstQueueFamilyIndex : data.dstQueue,
        image               : data.image,
        subresourceRange    : range                        
    };
    verbose(__FILE__, "adding image barrier for 0x%x %s", data.image, data);

    vkCmdPipelineBarrier(commandBuffer,
                         data.srcStageFlags,
                         data.dstStageFlags,
                         0,               // dependencyFlags

                         0,               // memoryBarrierCount
                         null,
                         0,              // bufferMemoryBarrierCount
                         null,
                         1,              // imageMemoryBarrierCount
                         &barrier);
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
void setImageLayout(VkCommandBuffer commandBuffer,
                    VkImage image,
                    VkImageAspectFlags aspectMask,
                    VkImageLayout oldLayout,
                    VkImageLayout newLayout,
                    uint srcQueue = VK_QUEUE_FAMILY_IGNORED,
                    uint dstQueue = VK_QUEUE_FAMILY_IGNORED)
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
    if(oldLayout==VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL &&
       newLayout==VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL)
    {
        barrier.srcAccessMask = VK_ACCESS_SHADER_READ_BIT;
        barrier.dstAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        srcStageMask = VK_PIPELINE_STAGE_ALL_COMMANDS_BIT;
        dstStageMask = VK_PIPELINE_STAGE_TRANSFER_BIT;
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

    verbose(__FILE__, "adding barrier for 0x%x from %s to %s, access: %s to %s,from queue %s to %s", image, oldLayout, newLayout, barrier.srcAccessMask, barrier.dstAccessMask, srcQueue, dstQueue);

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
