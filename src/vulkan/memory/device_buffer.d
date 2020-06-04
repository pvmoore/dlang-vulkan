module vulkan.memory.device_buffer;
/**
 *
 */
import vulkan.all;

final class DeviceBuffer {
    Vulkan vk;
    DeviceMemory memory;
    string name;
    VkBuffer handle;
    ulong size;
    VBufferUsage usage;
    Allocator allocs;
    AllocInfo memAllocInfo;

    ulong offset() { return memAllocInfo.offset; }

    this(Vulkan vk, DeviceMemory memory, string name, VkBuffer handle, ulong size, VBufferUsage usage, AllocInfo memAllocInfo) {
        this.vk           = vk;
        this.memory       = memory;
        this.name         = name;
        this.handle       = handle;
        this.size         = size;
        this.usage        = usage;
        this.memAllocInfo = memAllocInfo;
        this.allocs       = new Allocator(size);
    }
    void free() {
        memory.destroy(this);
    }
    SubBuffer alloc(ulong size, uint alignment=16) {

        if(usage.isUniform()) {
            alignment = maxOf(alignment, vk.limits.minUniformBufferOffsetAlignment.as!uint);
        } else if(usage.isStorage()) {
            alignment = maxOf(alignment, vk.limits.minStorageBufferOffsetAlignment.as!uint);
        }

        AllocInfo alloc = {
            offset: allocs.alloc(size, alignment),
            size: size
        };

        version(LOG_MEM) this.log("%s: Alloc SubBuffer [%s: %,s..%,s]", memory.name, name, offset, alloc.offset+size);

        if(alloc.offset==-1) {
            throw new Error("[%s] Out of DeviceBuffer space. Request size: %s (buffer size: %s free: %s)"
                .format(name, size, this.size, allocs.numBytesFree()));
        }
        return new SubBuffer(this, alloc.offset, alloc.size, usage, alloc);
    }

    void free(SubBuffer b) {
        if(b.allocInfo.size==0) throw new Error("Double free");

        allocs.free(b.allocInfo.offset, b.allocInfo.size);
        version(LOG_MEM) this.log("%s: Free SubBuffer [%s: %,s..%,s]", memory.name, name, b.offset, b.offset+b.size);
        b.allocInfo.size = 0;
    }
    void* mapForReading() {
        memory.invalidateRange(offset, size);
        return map();
    }
    void* map() {
        return memory.map(this);
    }
    void flush() {
        flush(0, size);
    }
    void flush(ulong offset, ulong size) {
        if(memory.isHostCoherent) return;

        vk.device.flushMappedMemory(
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
