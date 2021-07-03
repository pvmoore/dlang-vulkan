module vulkan.memory.subbuffer;
/**
 *
 */
import vulkan.all;

final class SubBuffer {
    DeviceBuffer parent;
    ulong offset;
    ulong size;
    VBufferUsage usage;
    AllocInfo allocInfo;

    this(DeviceBuffer parent, ulong offset, ulong size, VBufferUsage usage, AllocInfo allocInfo) {
        this.parent    = parent;
        this.offset    = offset;
        this.size      = size;
        this.usage     = usage;
        this.allocInfo = allocInfo;
    }

    override string toString() {
        return "SubBuffer(offset:%s, size:%s, usage:%s)".format(offset,size.sizeToString(),toArray!VBufferUsage(usage));
    }

    VkBuffer handle() { return parent.handle; }
    string name() { return parent.name; }
    DeviceMemory memory () { return parent.memory; }

    void* map() {
        return parent.map() + offset;
    }
    void* mapForReading() {
        return mapForReading(0, size);
    }
    void* mapForReading(ulong offset, ulong size) {
        vkassert(offset + size <= this.size);
        return parent.mapForReading(this.offset + offset, size);
    }
    void mapAndWrite(void* data, ulong offset, ulong size) {
        parent.mapAndWrite(data, this.offset + offset, size);
    }

    void flush() {
        flush(0, size);
    }
    void flush(ulong offset, ulong size) {
        parent.flush(this.offset+offset, size);
    }
    void free() {
        parent.free(this);
    }

    bool isVertexBuffer() const { return cast(bool)(usage & VBufferUsage.VERTEX); }
    bool isIndexBuffer() const { return cast(bool)(usage & VBufferUsage.INDEX); }
    bool isUniformBuffer() const { return cast(bool)(usage & VBufferUsage.UNIFORM); }
    bool isTransferSrc()  const { return cast(bool)(usage & VBufferUsage.TRANSFER_SRC); }
    bool isTransferDst()  const { return cast(bool)(usage & VBufferUsage.TRANSFER_DST); }
}

void copyBuffer(VkCommandBuffer cmd, SubBuffer src, SubBuffer dest) {
    vkassert(src.size == dest.size);
    From!"vulkan.memory.device_buffer".copyBuffer(cmd, src.parent, src.offset, dest.parent, dest.offset, src.size);
}
void copyBuffer(VkCommandBuffer cmd, SubBuffer src, ulong srcOffset, SubBuffer dest, ulong destOffset, ulong size) {
    vkassert(size <= src.size && size <= dest.size);
    From!"vulkan.memory.device_buffer".copyBuffer(cmd, src.parent, src.offset+srcOffset, dest.parent, dest.offset+destOffset, size);
}