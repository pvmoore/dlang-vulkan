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

    void* mapForReading() {
        memory().invalidateRange(parent.offset + offset, size);
        return map();
    }
    void* map() {
        return parent.map() + offset;
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

