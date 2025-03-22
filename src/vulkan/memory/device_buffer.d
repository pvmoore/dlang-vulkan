module vulkan.memory.device_buffer;

import vulkan.all;

final class DeviceBuffer {
    Vulkan vk;
    DeviceMemory memory;
    string name;
    VkBuffer handle;
    ulong size;
    VkBufferUsageFlags usage;
    BasicAllocator allocs;
    AllocInfo memAllocInfo;

    ulong offset() { return memAllocInfo.offset; }

    this(Vulkan vk, DeviceMemory memory, string name, VkBuffer handle, ulong size, VkBufferUsageFlags usage, AllocInfo memAllocInfo) {
        this.vk           = vk;
        this.memory       = memory;
        this.name         = name;
        this.handle       = handle;
        this.size         = size;
        this.usage        = usage;
        this.memAllocInfo = memAllocInfo;
        this.allocs       = new BasicAllocator(size);
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

        debug this.log("'%s': Alloc SubBuffer ['%s': %,s..%,s]", memory.name, name, alloc.offset, alloc.offset+size);

        if(alloc.offset==-1) {
            throw new Error("[%s] Out of DeviceBuffer space. Request size: %s (buffer size: %s free: %s)"
                .format(name, size, this.size, allocs.numBytesFree()));
        }
        return new SubBuffer(this, alloc.offset, alloc.size, usage, alloc);
    }

    void free(SubBuffer b) {
        if(b.allocInfo.size==0) throw new Error("Double free");

        allocs.free(b.allocInfo.offset, b.allocInfo.size);
        debug this.log("'%s': Free SubBuffer ['%s': %,s..%,s]", memory.name, name, b.offset, b.offset+b.size);
        b.allocInfo.size = 0;
    }
    void* mapForReading() {
        return mapForReading(0, size);
    }
    void* mapForReading(ulong offset, ulong size) {
        return memory.mapForReading(this, offset, size);
    }
    void* map() {
        return memory.map(this);
    }
    void mapAndWrite(void* data, ulong offset, ulong size) {
        memory.mapAndWrite(data, this.offset + offset, size);
    }
    void flush() {
        flush(0, size);
    }
    void flush(ulong offset, ulong size) {
        memory.flushRange(this.offset + offset, size);
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

void copyBuffer(VkCommandBuffer cmd, DeviceBuffer src, DeviceBuffer dest) {
    throwIf(src.size != dest.size);
    From!"vulkan.api.command_buffer".copyBuffer(cmd, src.handle, 0, dest.handle, 0, src.size);
}
void copyBuffer(VkCommandBuffer cmd, DeviceBuffer src, ulong srcOffset, DeviceBuffer dest, ulong destOffset, ulong size) {
    From!"vulkan.api.command_buffer".copyBuffer(cmd, src.handle, srcOffset, dest.handle, destOffset, size);
}
