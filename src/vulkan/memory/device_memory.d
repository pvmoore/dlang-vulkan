module vulkan.memory.device_memory;
/**
 *
 */
import vulkan.all;

final class DeviceMemory {
private:
    Allocator allocs;
    DeviceBuffer[string] deviceBuffers;
    DeviceImage[ulong] deviceImages;
    void* mapPtr;
public:
    Vulkan vk;
    VkDevice device;
    VkDeviceMemory handle;
    string name;
    ulong size;
    uint flags;
    uint typeIndex;

    this(Vulkan vk, VkDeviceMemory handle, string name, ulong size, uint flags, uint typeIndex) {
        version(LOG_MEM) this.log("Creating DeviceMemory '%s' %.1f MB type:%s flags:%s", name, cast(double)size/1.MB, typeIndex, toArray!VMemoryProperty(flags));

        this.vk        = vk;
        this.device    = vk.device;
        this.handle    = handle;
        this.name      = name;
        this.size      = size;
        this.flags     = flags;
        this.typeIndex = typeIndex;
        this.allocs    = new Allocator(size);

        if(isHostVisible) {
            this.mapPtr = device.mapMemory(handle, 0, size);
        }
    }
    void destroy() {
        foreach(b; deviceBuffers.values()) destroy(b); deviceBuffers = null;
        foreach(i; deviceImages.values()) destroy(i); deviceImages = null;
        if(mapPtr) device.unmapMemory(handle);
        device.freeMemory(handle);
    }
    override string toString() {
        return "DeviceMemory('%s' %s MB)".format(name, size/1.MB);
    }
    bool isLocal()        const { return cast(bool)(flags & VMemoryProperty.DEVICE_LOCAL); }
    bool isHostVisible()  const { return cast(bool)(flags & VMemoryProperty.HOST_VISIBLE); }
    bool isHostCoherent() const { return cast(bool)(flags & VMemoryProperty.HOST_COHERENT); }
    bool isHostCached()   const { return cast(bool)(flags & VMemoryProperty.HOST_CACHED); }
    bool isLazy()         const { return cast(bool)(flags & VMemoryProperty.LAZILY_ALLOCATED); }

    DeviceBuffer allocBuffer(string name, ulong size, VBufferUsage usage) {
        if(name in deviceBuffers) throw new Error("Buffer name '%s' already allocated".format(name));

        auto buffer    = device.createBuffer(size, usage);
        auto memreq    = device.getBufferMemoryRequirements(buffer);
        auto allocInfo = bind(buffer, memreq, name);

        version(LOG_MEM) this.log("allocBuffer: %s: Creating '%s' [%,s..%,s] (size buf %s, mem %s) %s",
            this.name, name, allocInfo.offset, allocInfo.offset+size,
            sizeToString(size), sizeToString(memreq.size), toArray!VBufferUsage(usage));

        auto db = new DeviceBuffer(vk, this, name, buffer, size, usage, allocInfo);
        deviceBuffers[name] = db;
        return db;
    }
    DeviceBuffer allocVertexBuffer(string name, ulong size, VBufferUsage usage = VBufferUsage.TRANSFER_DST) {
        return allocBuffer(name, size, VBufferUsage.VERTEX | usage);
    }
    DeviceBuffer allocIndexBuffer(string name, ulong size, VBufferUsage usage = VBufferUsage.TRANSFER_DST) {
        return allocBuffer(name, size, VBufferUsage.INDEX | usage);
    }
    DeviceBuffer allocUniformBuffer(string name, ulong size, VBufferUsage usage = VBufferUsage.TRANSFER_DST) {
        return allocBuffer(name, size, VBufferUsage.UNIFORM | usage);
    }
    DeviceBuffer allocStorageBuffer(string name, ulong size, VBufferUsage usage = VBufferUsage.TRANSFER_DST) {
        return allocBuffer(name, size, VBufferUsage.STORAGE | usage);
    }
    DeviceBuffer allocStagingBuffer(string name, ulong size, VBufferUsage usage = VBufferUsage.TRANSFER_DST) {
        return allocBuffer(name, size, VBufferUsage.TRANSFER_SRC | usage);
    }

    DeviceImage allocImage(string name, uint[] dimensions, uint usage, VFormat format) {
        auto image = device.createImage(format, dimensions, (info) {
            info.tiling        = VImageTiling.OPTIMAL;
            info.initialLayout = VImageLayout.UNDEFINED;
            info.usage         = usage;
        });
        auto memReqs = device.getImageMemoryRequirements(image);
        version(LOG_MEM) this.log("allocImage: Image '%s' %s requires size %s align %s",
            name, dimensions, memReqs.size, memReqs.alignment);

        // alignment seems to be either 256 bytes or 128k depending on image size
        ulong offset = bind(image, memReqs);
        auto di      = new DeviceImage(vk, this, name, image, format, offset, memReqs.size, dimensions);
        deviceImages[cast(ulong)image] = di;
        return di;
    }

    void destroy(DeviceBuffer b) {
        if(b.memAllocInfo.size==0) throw new Error("Double free");

        allocs.free(b.memAllocInfo.offset, b.memAllocInfo.size);
        b.memAllocInfo.size = 0;

        deviceBuffers.remove(b.name);
        device.destroyBuffer(b.handle);
    }
    void destroy(DeviceImage i) {
        allocs.free(i.offset, i.size);
        deviceImages.remove(cast(ulong)i.handle);
        // destroy views and image handle
        foreach(v; i.views.values) device.destroyImageView(v);
        device.destroyImage(i.handle);
    }
    DeviceBuffer getBuffer(string name) {
        return deviceBuffers[name];
    }
//    DeviceBuffer getBuffer(VBufferUsage usage) {
//        return deviceBuffers[to!string(usage)];
//    }
    DeviceImage getImage(VkImage i) {
        return deviceImages[cast(ulong)i];
    }
    void* mapForWriting(DeviceBuffer b) {
        assert(isHostVisible, "This memory cannot be mapped");
        invalidateRange(b.offset, b.size);
        return mapPtr + b.offset;
    }
    void* mapForWriting(SubBuffer b) {
        assert(isHostVisible, "This memory cannot be mapped");
        invalidateRange(b.parent.offset + b.offset, b.size);
        return mapPtr + b.parent.offset + b.offset;
    }
    void* mapForWriting(DeviceImage i) {
        assert(isHostVisible, "This memory cannot be mapped");
        invalidateRange(i.offset, i.size);
        return mapPtr + i.offset;
    }
    void* mapForReading(DeviceBuffer b) {
        assert(isHostVisible, "This memory cannot be mapped");
        return mapPtr + b.offset;
    }
    void* mapForReading(SubBuffer b) {
        assert(isHostVisible, "This memory cannot be mapped");
        return mapPtr + b.parent.offset + b.offset;
    }
    void* mapForReading(DeviceImage i) {
        assert(isHostVisible, "This memory cannot be mapped");
        return mapPtr + i.offset;
    }
    void* map(DeviceBuffer b) {
        assert(isHostVisible, "This memory cannot be mapped");
        return mapPtr + b.offset;
    }
    void* map(SubBuffer b) {
        assert(isHostVisible, "This memory cannot be mapped");
        return mapPtr + b.parent.offset + b.offset;
    }
    void* map(DeviceImage i) {
        assert(isHostVisible, "This memory cannot be mapped");
        return mapPtr + i.offset;
    }
    void flush(SubBuffer b) {
        if(isHostCoherent) return;

        // TODO - non coherent memory size should be a multiple of VkPhysicalDeviceLimits::nonCoherentAtomSize
        device.flushMappedMemory(handle, b.parent.offset + b.offset, b.size);
    }
    void flush(DeviceImage b) {
        if(isHostCoherent) return;

        // TODO - non coherent memory size should be a multiple of VkPhysicalDeviceLimits::nonCoherentAtomSize
        device.flushMappedMemory(handle, b.offset, b.size);
    }
    void invalidateRange(ulong offset, ulong size) {
        if(isHostCoherent) return;
        device.invalidateMappedMemory(handle, offset, size);
    }
private:
    AllocInfo bind(VkBuffer buffer, ref VkMemoryRequirements reqs, string bufferName) {
        version(LOG_MEM) this.log("%s: Binding buffer size %,s align %s", name, reqs.size, reqs.alignment);
        long offset = allocs.alloc(reqs.size, cast(uint)reqs.alignment);
        if(offset==-1) throw new Error("Out of DeviceMemory space");
        device.bindBufferMemory(buffer, handle, offset);
        //logMem("%s: Bound buffer '%s' [%,s - %,s] align %s", name, bufferName, offset, offset+reqs.size, reqs.alignment);
        return AllocInfo(offset, reqs.size);
    }
    ulong bind(VkImage image, ref VkMemoryRequirements reqs) {
        long offset = allocs.alloc(reqs.size, cast(uint)reqs.alignment);
        if(offset==-1) throw new Error("Out of DeviceMemory space");
        device.bindImageMemory(image, handle, offset);
        //logMem("%s: Bound image [%,s - %,s] align %s", name, offset, offset+reqs.size, reqs.alignment);
        return offset;
    }
}

final class DeviceMemorySnapshot {
    string name;
    int usedPct;
    int unusedPct;
    ulong used;
    ulong total;
    DeviceBufferSnapshot[] bufferSS;
    DeviceImageSnapshot[] imageSS;

    this(DeviceMemory m) {
        name      = m.name;
        usedPct   = cast(int)((m.allocs.numBytesUsed*100)/m.allocs.length);
        unusedPct = 100-usedPct;
        used      = m.allocs.numBytesUsed/1.MB;
        total     = m.allocs.length/1.MB;
        bufferSS  = m.deviceBuffers.values.map!(it=>
            new DeviceBufferSnapshot(it)
        ).array;
        imageSS = m.deviceImages.values.map!(it=>
            new DeviceImageSnapshot(it)
        ).array;
    }
    override string toString() {
        auto buf = appender!(string[]);
        buf ~= "DeviceMemory '%s': [%s |%s|%s| %s] MB"
            .format(name,
                    used,
                    "X".repeat(usedPct/5),
                    ":".repeat(unusedPct/5),
                    total);
        foreach(b; bufferSS) buf ~= ("\t" ~ b.toString());
        foreach(i; imageSS) buf ~= ("\t" ~ i.toString());
        return buf.data.join("\n");
    }
}

