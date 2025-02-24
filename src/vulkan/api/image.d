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
