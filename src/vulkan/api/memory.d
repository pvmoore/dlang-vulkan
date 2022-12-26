module vulkan.api.memory;

import vulkan.all;

auto allocateMemory(VkDevice device,
                    uint typeIndex,
                    ulong sizeBytes,
                    VkMemoryAllocateFlags allocateFlags = 0)
{
    VkDeviceMemory memory;
    void* pNext = null;

    // Add VkMemoryAllocateFlagsInfo to the chain
    if(allocateFlags != 0) {
        // VK_MEMORY_ALLOCATE_DEVICE_MASK_BIT
        // VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT
        // VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT

        VkMemoryAllocateFlagsInfo flagsInfo = {
            sType: VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_FLAGS_INFO,
            pNext: null,
            flags: allocateFlags,
            deviceMask: 0
        };
        pNext = &flagsInfo;
    }

    VkMemoryAllocateInfo info = {
        sType: VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        pNext: pNext,
        memoryTypeIndex: typeIndex,
        allocationSize: sizeBytes
    };

    check(vkAllocateMemory(device, &info, null, &memory));
    return memory;
}
void freeMemory(VkDevice device, VkDeviceMemory memory) {
    vkFreeMemory(device, memory, null);
}
void* mapMemory(VkDevice device,
                VkDeviceMemory memory,
                ulong offset,
                ulong sizeBytes)
{
    void* data;
    // there aren't any flags defined
    VkMemoryMapFlags flags = 0;
    check(vkMapMemory(device, memory, offset, sizeBytes, flags, &data));
    return data;
}
void unmapMemory(VkDevice device, VkDeviceMemory memory) {
    vkUnmapMemory(device, memory);
}
void flushMappedMemory(VkDevice device, VkDeviceMemory mem, ulong offset, ulong size) {
    VkMappedMemoryRange r;
    r.sType  = VkStructureType.VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE;
    r.memory = mem;
    r.offset = offset;
    r.size   = size;
    flushMappedMemoryRanges(device, [r]);
}
void flushMappedMemoryRanges(VkDevice device, VkMappedMemoryRange[] ranges) {
    check(vkFlushMappedMemoryRanges(device, cast(uint)ranges.length, ranges.ptr));
}
void invalidateMappedMemory(VkDevice device, VkDeviceMemory mem, ulong offset, ulong size) {
    VkMappedMemoryRange r;
    r.sType  = VkStructureType.VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE;
    r.memory = mem;
    r.offset = offset;
    r.size   = size;
    invalidateMappedMemoryRanges(device, [r]);
}
void invalidateMappedMemoryRanges(VkDevice device, VkMappedMemoryRange[] ranges) {
    check(vkInvalidateMappedMemoryRanges(device, cast(uint)ranges.length, ranges.ptr));
}
ulong getMemoryCommitment(VkDevice device, VkDeviceMemory memory) {
    ulong numBytes;
    vkGetDeviceMemoryCommitment(device, memory, &numBytes);
    return numBytes;
}
void bindBufferMemory(VkDevice device, VkBuffer buffer, VkDeviceMemory memory, ulong offset=0) {
    check(vkBindBufferMemory(device, buffer, memory, offset));
}
void bindImageMemory(VkDevice device, VkImage image, VkDeviceMemory memory, ulong offset=0) {
    check(vkBindImageMemory(device, image, memory, offset));
}

