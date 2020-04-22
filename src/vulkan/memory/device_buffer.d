module vulkan.memory.device_buffer;
/**
 *
 */
import vulkan.all;

final class DeviceBuffer {
    DeviceMemory memory;
    string name;
    VkBuffer handle;
    ulong size;
    VBufferUsage usage;
    Allocator allocs;
    AllocInfo memAllocation;

    ulong offset() { return memAllocation.offset; }

    this(DeviceMemory memory, string name, VkBuffer handle, ulong size, VBufferUsage usage, AllocInfo memAllocInfo) {
        this.memory        = memory;
        this.name          = name;
        this.handle        = handle;
        this.size          = size;
        this.usage         = usage;
        this.memAllocation = memAllocInfo;
        this.allocs        = new Allocator(size);
    }
    void free() {
        memory.destroy(this);
    }
    SubBuffer alloc(ulong size, uint alignment=16) {
        auto offset = allocs.alloc(size, alignment);
        logMem("%s: Alloc SubBuffer [%s: %,s..%,s]", memory.name, name, offset, offset+size);
        if(offset==-1) throw new Error("Out of DeviceBuffer space");

        return new SubBuffer(this, offset, size, usage);
    }
    void free(SubBuffer b) {
        allocs.free(b.offset, b.size);
        logMem("%s: Free SubBuffer [%s: %,s..%,s]", memory.name, name, b.offset, b.offset+b.size);
    }
    void* mapForReading() {
        memory.invalidateRange(offset, size);
        return map();
    }
    void* map() {
        return memory.mapPtr + offset;
    }
    void flush() {
        flush(0, size);
    }
    void flush(ulong offset, ulong size) {
        if(memory.isHostCoherent) return;
        memory.device.flushMappedMemory(
            memory.handle,
            this.offset+offset, size
        );
    }
    void resize(SubBuffer b, ulong size) {
        // todo
    }
//    void convertAccess(VkCommandBuffer cmd, VkAccessFlags srcAccess, VkAccessFlags dstAccess) {
//        cmd.pipelineBarrier(
//            VPipelineStage.TRANSFER,
//            VPipelineStage.TRANSFER,
//            0,
//            null,
//            [bufferMemoryBarrier(handle, 0, size,
//                srcAccess,
//                dstAccess
//            )],
//            null
//        );
//    }
}

final class DeviceBufferSnapshot {
    string name;
    ulong size;
    ulong numAllocs;
    ulong numFrees;

    this(DeviceBuffer b) {
        name = b.name;
        size = b.size;
        numAllocs = b.allocs.numAllocs;
        numFrees  = b.allocs.numFrees;
    }
    override string toString() {
        return "DeviceBuffer '%s' (%.1f MB) %s allocs, %s frees".format(
            name,
            size/(1024.0*1024),
            numAllocs,
            numFrees
        );
    }
}
