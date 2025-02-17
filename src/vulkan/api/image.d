module vulkan.api.image;

import vulkan.all;

struct CreateImageResult {
    VkImage image;
    VkImageFormatListCreateInfo formatList;
}

/** 
 * Creates a Vulkan image (Vulkan 1.2)
 * Params:
 *   device               - The Vulkan device
 *   format               - The format of the image
 *   dimensions           - The dimensions of the image as an array
 *   returnViewFormatList - A boolean to specify if format list info should be returned
 *   callback             - An optional delegate to modify the VkImageCreateInfo structure before creation
 * Returns: 
 *   CreateImageResult containing VkImage and VkImageFormatListCreateInfo which will be populated if returnViewFormatList is true
 */
CreateImageResult createImage12(VkDevice device,
                                VkFormat format,
                                uint[] dimensions,
                                bool returnViewFormatList,
                                void delegate(VkImageCreateInfo*) callback = null)
{
    VkImage image;
    VkImageCreateInfo info = {
        sType:         VkStructureType.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        flags:         0,
        imageType:     cast(VkImageType)(dimensions.length-1),
        format:        format,
        extent:        toVkExtent3D(dimensions),
        mipLevels:     1,
        arrayLayers:   1,
        samples:       VkSampleCountFlagBits.VK_SAMPLE_COUNT_1_BIT,
        tiling:        VK_IMAGE_TILING_LINEAR,
        usage:         VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
        sharingMode:   VK_SHARING_MODE_EXCLUSIVE,
        initialLayout: VK_IMAGE_LAYOUT_PREINITIALIZED
    };
    
    VkImageFormatListCreateInfo formatList = {
        sType: VkStructureType.VK_STRUCTURE_TYPE_IMAGE_FORMAT_LIST_CREATE_INFO
    };

    if(returnViewFormatList) {
        info.pNext = &formatList;
    }

    if(callback) callback(&info);

    check(vkCreateImage(device, &info, null, &image));

    return CreateImageResult(image, formatList);
}

/**
 * Creates a Vulkan image.
 * Params:
 *    device     - The Vulkan device 
 *    format     - The format of the image
 *    dimensions - The dimensions of the image as an array
 *    call       - An optional delegate to modify the VkImageCreateInfo structure before creation
 * Returns A VkImage handle for the created image
 */
VkImage createImage(VkDevice device,
                    VkFormat format,
                    uint[] dimensions,
                    void delegate(VkImageCreateInfo*) call = null)
{
    VkImage image;
    VkImageCreateInfo info = {
        sType: VkStructureType.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO
    };

    // VK_IMAGE_CREATE_SPARSE_BINDING_BIT
    // VK_IMAGE_CREATE_SPARSE_RESIDENCY_BIT
    // VK_IMAGE_CREATE_SPARSE_ALIASED_BIT
    // VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT
    // VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT
    // etc...
    info.flags = 0;

    // VK_IMAGE_TYPE_1D = 0,
    // VK_IMAGE_TYPE_2D = 1,
    // VK_IMAGE_TYPE_3D = 2,
    info.imageType   = cast(VkImageType)(dimensions.length-1);
    info.format      = format;
    info.extent      = toVkExtent3D(dimensions);
    info.mipLevels   = 1;
    info.arrayLayers = 1;

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
    info.tiling = VK_IMAGE_TILING_LINEAR;

    // VK_IMAGE_USAGE_TRANSFER_SRC_BIT
    // VK_IMAGE_USAGE_TRANSFER_DST_BIT
    // VK_IMAGE_USAGE_SAMPLED_BIT
    // VK_IMAGE_USAGE_STORAGE_BIT
    // VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT
    // VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT
    // VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT
    // VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT
    // etc...
    info.usage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;

    //if(queueFamilies.length==0) {
        info.sharingMode = VK_SHARING_MODE_EXCLUSIVE;
//    } else {
//        info.sharingMode           = VkSharingMode.VK_SHARING_MODE_CONCURRENT;
//        info.queueFamilyIndexCount = cast(uint)queueFamilies.length;
//        info.pQueueFamilyIndices   = queueFamilies.ptr;
//    }

    // VK_IMAGE_LAYOUT_UNDEFINED
    // VK_IMAGE_LAYOUT_GENERAL
    // VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
    // VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
    // VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL
    // VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
    // VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL
    // VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL
    // VK_IMAGE_LAYOUT_PREINITIALIZED
    // etc...
    info.initialLayout = VK_IMAGE_LAYOUT_PREINITIALIZED;

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

auto ref build(return ref VkImageViewCreateInfo info, VkImage image, VkFormat format, VkImageViewType type) {
    info.sType      = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
    info.flags      = 0; // reserved
    info.image      = image;
    info.viewType   = type;
    info.format     = format.as!VkFormat;
    info.components = componentMapping!"rgba";
    info.subresourceRange = VkImageSubresourceRange(
        VK_IMAGE_ASPECT_COLOR_BIT, // aspectMask
        0,  // baseMipLevel
        1,  // levelCount
        0,  // baseArrayLayer
        1   // layerCount
    );
    return info;
}
auto ref build(return ref VkImageViewCreateInfo info, VkImageAspectFlags aspectMask) {
    info.subresourceRange = VkImageSubresourceRange(
        aspectMask,
        0,                          // baseMipLevel
        VK_REMAINING_MIP_LEVELS,    // levelCount
        0,                          // baseArrayLayer
        VK_REMAINING_ARRAY_LAYERS   // layerCount
    );
    return info;
}

auto imageViewCreateInfo(VkImage image,
                         VkFormat format,
                         VkImageViewType type,
                         void delegate(VkImageViewCreateInfo*) call = null)
{
    VkImageViewCreateInfo info = {
        sType: VkStructureType.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
        flags: 0,   // reserved
        image: image,
        viewType: type,
        format: format,
        components: componentMapping!"rgba",
        subresourceRange: VkImageSubresourceRange(
            VK_IMAGE_ASPECT_COLOR_BIT,  // aspectMask
            0,                          // baseMipLevel
            VK_REMAINING_MIP_LEVELS,    // levelCount
            0,                          // baseArrayLayer
            VK_REMAINING_ARRAY_LAYERS   // layerCount
        )
    };
    if(call) call(&info);
    return info;
}
VkImageView createImageView(VkDevice device, VkImageViewCreateInfo info) {
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
auto imageMemoryBarrier(VkImage image,
                        VkAccessFlags srcAccess,
                        VkAccessFlags dstAccess,
                        VkImageLayout fromLayout,
                        VkImageLayout toLayout,
                        uint fromQueue = VK_QUEUE_FAMILY_IGNORED,
                        uint toQueue = VK_QUEUE_FAMILY_IGNORED)
{
    VkImageMemoryBarrier barrier;
    barrier.sType     = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
    barrier.srcAccessMask = srcAccess;
    barrier.dstAccessMask = dstAccess;
    barrier.oldLayout = fromLayout;
    barrier.newLayout = toLayout;
    barrier.image     = image;
    barrier.subresourceRange.aspectMask     = VK_IMAGE_ASPECT_COLOR_BIT;
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
                    VkImageLayout oldLayout,
                    VkImageLayout newLayout,
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
