module vulkan.api.image;
/**
 * https://www.khronos.org/registry/vulkan/specs/1.0/man/html/VkImageCreateInfo.html
 * https://www.khronos.org/registry/vulkan/specs/1.0/man/html/VkFormat.html
 */
import vulkan.all;

VkImage createImage(
    VkDevice device,
    VkFormat format,
    uint[] dimensions,
    void delegate(VkImageCreateInfo*) call=null)
{
    VkImage image;
    VkImageCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO;
    with(VkImageCreateFlagBits) {
        // VK_IMAGE_CREATE_SPARSE_BINDING_BIT
        // VK_IMAGE_CREATE_SPARSE_RESIDENCY_BIT
        // VK_IMAGE_CREATE_SPARSE_ALIASED_BIT
        // VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT
        // VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT
        info.flags = 0;
    }
    // VK_IMAGE_TYPE_1D = 0,
    // VK_IMAGE_TYPE_2D = 1,
    // VK_IMAGE_TYPE_3D = 2,
    info.imageType = cast(VkImageType)(dimensions.length-1);
    info.format         = format;
    info.extent         = toVkExtent3D(dimensions);
    info.mipLevels      = 1;
    info.arrayLayers    = 1;

    // VK_SAMPLE_COUNT_1_BIT
    // VK_SAMPLE_COUNT_2_BIT
    // VK_SAMPLE_COUNT_4_BIT
    // VK_SAMPLE_COUNT_8_BIT
    // VK_SAMPLE_COUNT_16_BIT
    // VK_SAMPLE_COUNT_32_BIT
    // VK_SAMPLE_COUNT_64_BIT
    info.samples = VkSampleCountFlagBits.VK_SAMPLE_COUNT_1_BIT;

    // VImageTiling.OPTIMAL
    // VImageTiling.LINEAR
    info.tiling = VImageTiling.LINEAR;

    with(VkImageUsageFlagBits) {
        // VK_IMAGE_USAGE_TRANSFER_SRC_BIT
        // VK_IMAGE_USAGE_TRANSFER_DST_BIT
        // VK_IMAGE_USAGE_SAMPLED_BIT
        // VK_IMAGE_USAGE_STORAGE_BIT
        // VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT
        // VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT
        // VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT
        // VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT
        info.usage = VImageUsage.COLOR_ATTACHMENT;
    }
    //if(queueFamilies.length==0) {
        info.sharingMode = VSharingMode.EXCLUSIVE;
//    } else {
//        info.sharingMode           = VkSharingMode.VK_SHARING_MODE_CONCURRENT;
//        info.queueFamilyIndexCount = cast(uint)queueFamilies.length;
//        info.pQueueFamilyIndices   = queueFamilies.ptr;
//    }


    // UNDEFINED
    // GENERAL
    // COLOR_ATTACHMENT_OPTIMAL
    // DEPTH_STENCIL_ATTACHMENT_OPTIMAL
    // ayout.DEPTH_STENCIL_READ_ONLY_OPTIMAL
    // SHADER_READ_ONLY_OPTIMAL
    // TRANSFER_SRC_OPTIMAL
    // TRANSFER_DST_OPTIMAL
    // PREINITIALIZED
    info.initialLayout = VImageLayout.PREINITIALIZED;

    if(call) call(&info);

    //log("createImage format: %s dims: %s", format, dimensions);

    check(vkCreateImage(
        device,
        &info,
        null,
        &image
    ));
    return image;
}
auto imageViewCreateInfo(
    VkImage image,
    VkFormat format,
    VImageViewType type,
    void delegate(VkImageViewCreateInfo*) call=null)
{
    VkImageViewCreateInfo info = {
        sType: VkStructureType.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
        flags: 0,   // reserved
        image: image,
        viewType: type,
        format: format,
        components: componentMapping!"rgba",
        subresourceRange: VkImageSubresourceRange(
            VImageAspect.COLOR, // aspectMask
            0,  // baseMipLevel
            1,  // levelCount
            0,  // baseArrayLayer
            1   // layerCount
        )
    };
    return info;
}
VkImageView createImageView(
    VkDevice device,
    VkImageViewCreateInfo info)
{
    VkImageView view;
    check(vkCreateImageView(
        device,
        &info,
        null,
        &view
    ));
    return view;
}
auto getImageMemoryRequirements(VkDevice device, VkImage image) {
    VkMemoryRequirements m;
    vkGetImageMemoryRequirements(device, image, &m);
    return m;
}
auto getSparseMemoryRequirements(VkDevice device, VkImage image) {
    VkSparseImageMemoryRequirements[] requirements;
    uint count;
    vkGetImageSparseMemoryRequirements(device, image, &count, null);
    requirements.length = count;
    vkGetImageSparseMemoryRequirements(device, image, &count, requirements.ptr);
    return requirements;
}
auto getSubresourceLayout(VkDevice device, VkImage image, VkImageAspectFlagBits aspect) {
    VkSubresourceLayout layout;
    VkImageSubresource s;
    s.aspectMask = aspect;
    s.mipLevel   = 0;
    s.arrayLayer = 0;
    device.vkGetImageSubresourceLayout(image, &s, &layout);
    return layout;
}
auto imageMemoryBarrier(
    VkImage image,
    VAccess srcAccess,
    VAccess dstAccess,
    VImageLayout fromLayout,
    VImageLayout toLayout,
    uint fromQueue=VK_QUEUE_FAMILY_IGNORED,
    uint toQueue=VK_QUEUE_FAMILY_IGNORED)
{
    VkImageMemoryBarrier barrier;
    barrier.sType     = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
    barrier.srcAccessMask = srcAccess;
    barrier.dstAccessMask = dstAccess;
    barrier.oldLayout = fromLayout;
    barrier.newLayout = toLayout;
    barrier.image     = image;
    barrier.subresourceRange.aspectMask     = VImageAspect.COLOR;
    barrier.subresourceRange.baseMipLevel   = 0;
    barrier.subresourceRange.levelCount     = VK_REMAINING_MIP_LEVELS;
    barrier.subresourceRange.baseArrayLayer = 0;
    barrier.subresourceRange.layerCount     = VK_REMAINING_ARRAY_LAYERS;
    barrier.srcQueueFamilyIndex             = fromQueue;
    barrier.dstQueueFamilyIndex             = toQueue;
    return barrier;
}
void setImageLayout(VkCommandBuffer commandBuffer,
                    VkImage image,
                    VkImageAspectFlags aspectMask,
                    VImageLayout oldLayout,
                    VImageLayout newLayout,
                    uint srcQueue=VK_QUEUE_FAMILY_IGNORED,
                    uint dstQueue=VK_QUEUE_FAMILY_IGNORED)
{
    VkImageMemoryBarrier barrier;
    barrier.sType     = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
    barrier.oldLayout = oldLayout;
    barrier.newLayout = newLayout;
    barrier.image     = image;
    barrier.subresourceRange.aspectMask     = aspectMask;
    barrier.subresourceRange.baseMipLevel   = 0;
    barrier.subresourceRange.levelCount     = VK_REMAINING_MIP_LEVELS;
    barrier.subresourceRange.baseArrayLayer = 0;
    barrier.subresourceRange.layerCount     = VK_REMAINING_ARRAY_LAYERS;
    barrier.srcQueueFamilyIndex             = srcQueue;
    barrier.dstQueueFamilyIndex             = dstQueue;

    auto srcStageMask = VPipelineStage.TOP_OF_PIPE;
    auto dstStageMask = VPipelineStage.TOP_OF_PIPE;

    // VPipelineStage.HOST

    // Undefined layout:
    //   Note: Only allowed as initial layout!
    //   Note: Make sure any writes to the image have been finished
//    if(oldImageLayout == VkImageLayout.VK_VImageLayout.UNDEFINED)
//        barrier.srcAccessMask = VkAccessFlagBits.VK_ACCESS_HOST_WRITE_BIT |
//                                VkAccessFlagBits.VK_ACCESS_TRANSFER_WRITE_BIT;

    if(oldLayout==VImageLayout.PREINITIALIZED &&
       newLayout==VImageLayout.TRANSFER_SRC_OPTIMAL)
    {
        barrier.srcAccessMask = VAccess.HOST_WRITE;
        barrier.dstAccessMask = VAccess.TRANSFER_READ;
        srcStageMask = VPipelineStage.HOST;
        dstStageMask = VPipelineStage.TRANSFER;
    }
    if(oldLayout==VImageLayout.PREINITIALIZED &&
       newLayout==VImageLayout.TRANSFER_DST_OPTIMAL)
    {
        barrier.srcAccessMask = VAccess.HOST_WRITE;
        barrier.dstAccessMask = VAccess.TRANSFER_WRITE;
        srcStageMask = VPipelineStage.HOST;
        dstStageMask = VPipelineStage.TRANSFER;
    }
    if(oldLayout==VImageLayout.UNDEFINED &&
       newLayout==VImageLayout.TRANSFER_DST_OPTIMAL)
    {
        barrier.srcAccessMask = 0;
        barrier.dstAccessMask = VAccess.TRANSFER_WRITE;
        srcStageMask = VPipelineStage.HOST;
        dstStageMask = VPipelineStage.TRANSFER;
    }
    if(oldLayout==VImageLayout.TRANSFER_DST_OPTIMAL &&
       newLayout==VImageLayout.SHADER_READ_ONLY_OPTIMAL)
    {
        barrier.srcAccessMask = VAccess.TRANSFER_WRITE;
        barrier.dstAccessMask = VAccess.SHADER_READ;
        srcStageMask = VPipelineStage.TRANSFER;
        dstStageMask = VPipelineStage.ALL_COMMANDS;
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