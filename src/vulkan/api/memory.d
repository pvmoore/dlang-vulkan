module vulkan.api.memory;

import vulkan.all;

auto allocateMemory(VkDevice device, uint typeIndex, ulong sizeBytes) {
    VkDeviceMemory memory;
    VkMemoryAllocateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;

    info.memoryTypeIndex = typeIndex;
    info.allocationSize  = sizeBytes;

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
pragma(inline,true)
auto bufferMemoryBarrier(
    VkBuffer buffer, ulong offset, ulong size,
    VkAccessFlags srcAccess,
    VkAccessFlags dstAccess,
    uint srcQueue=VK_QUEUE_FAMILY_IGNORED,
    uint dstQueue=VK_QUEUE_FAMILY_IGNORED)
{
    VkBufferMemoryBarrier b;
    b.sType         = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
    b.srcAccessMask = srcAccess;
    b.dstAccessMask = dstAccess;
    b.srcQueueFamilyIndex = srcQueue;
    b.dstQueueFamilyIndex = dstQueue;
    b.buffer        = buffer;
    b.offset        = offset;
    b.size          = size;
    return b;
}






