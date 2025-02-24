module vulkan.api.buffer;

import vulkan.all;

VkBuffer createBuffer(VkDevice device,
                      ulong sizeBytes,
                      VkBufferUsageFlags usage,
                      uint[] queueFamilies = null)
{
    VkBuffer buffer;
    VkBufferCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
    // VK_BUFFER_CREATE_SPARSE_BINDING_BIT
    // VK_BUFFER_CREATE_SPARSE_RESIDENCY_BIT
    // VK_BUFFER_CREATE_SPARSE_ALIASED_BIT
    info.flags = 0;

    info.size  = sizeBytes;
    info.usage = usage;

    if(queueFamilies.length==0) {
        info.sharingMode            = VkSharingMode.VK_SHARING_MODE_EXCLUSIVE;
        info.queueFamilyIndexCount  = 0;
        info.pQueueFamilyIndices    = null;
    } else {
        info.sharingMode            = VkSharingMode.VK_SHARING_MODE_CONCURRENT;
        info.queueFamilyIndexCount  = cast(uint)queueFamilies.length;
        info.pQueueFamilyIndices    = queueFamilies.ptr;
    }

    check(vkCreateBuffer(
        device,
        &info,
        null,
        &buffer
    ));
    return buffer;
}

VkBufferView createBufferView(VkDevice device,
                              VkBuffer buffer,
                              VkFormat format,
                              ulong offset,
                              ulong range)
{
    VkBufferView view;
    VkBufferViewCreateInfo info;
    info.sType  = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_VIEW_CREATE_INFO;
    info.flags  = 0;
    info.buffer = buffer;
    info.format = format;
    info.offset = offset;   // in bytes
    info.range  = range;    // in bytes or VK_WHOLE_SIZE

    check(vkCreateBufferView(
        device,
        &info,
        null,
        &view
    ));
    return view;
}
auto getBufferMemoryRequirements(VkDevice device, VkBuffer buffer) {
    VkMemoryRequirements m;
    vkGetBufferMemoryRequirements(device, buffer, &m);
    return m;
}

