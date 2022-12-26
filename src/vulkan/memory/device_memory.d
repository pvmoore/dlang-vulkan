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
        version(LOG_MEM) this.log("Creating DeviceMemory '%s' %.1f MB type:%s flags:%s", name, cast(double)size/1.MB, typeIndex, .toString!VkMemoryPropertyFlagBits(flags, "VK_MEMORY_PROPERTY_", "_BIT"));

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
    bool isLocal()        const { return cast(bool)(flags & VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT); }
    bool isHostVisible()  const { return cast(bool)(flags & VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT); }
    bool isHostCoherent() const { return cast(bool)(flags & VK_MEMORY_PROPERTY_HOST_COHERENT_BIT); }
    bool isHostCached()   const { return cast(bool)(flags & VK_MEMORY_PROPERTY_HOST_CACHED_BIT); }
    bool isLazy()         const { return cast(bool)(flags & VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT); }

    DeviceBuffer allocBuffer(string name, ulong size, VkBufferUsageFlags usage) {
        if(name in deviceBuffers) throw new Error("Buffer name '%s' already allocated".format(name));

        auto buffer    = device.createBuffer(size, usage);
        auto memreq    = device.getBufferMemoryRequirements(buffer);
        auto allocInfo = bind(buffer, memreq, name);

        version(LOG_MEM) this.log("allocBuffer: %s: Creating '%s' [%,s..%,s] (size buf %s, mem %s) %s",
            this.name, name, allocInfo.offset, allocInfo.offset+size,
            sizeToString(size), sizeToString(memreq.size), .toString!VkBufferUsageFlagBits(usage, "VK_BUFFER_USAGE_", "_BIT"));

        auto db = new DeviceBuffer(vk, this, name, buffer, size, usage, allocInfo);
        deviceBuffers[name] = db;
        return db;
    }
    DeviceBuffer allocVertexBuffer(string name, ulong size, VkBufferUsageFlags usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT) {
        return allocBuffer(name, size, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | usage);
    }
    DeviceBuffer allocIndexBuffer(string name, ulong size, VkBufferUsageFlags usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT) {
        return allocBuffer(name, size, VK_BUFFER_USAGE_INDEX_BUFFER_BIT | usage);
    }
    DeviceBuffer allocUniformBuffer(string name, ulong size, VkBufferUsageFlags usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT) {
        return allocBuffer(name, size, VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT | usage);
    }
    DeviceBuffer allocStorageBuffer(string name, ulong size, VkBufferUsageFlags usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT) {
        return allocBuffer(name, size, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | usage);
    }
    DeviceBuffer allocStagingBuffer(string name, ulong size, VkBufferUsageFlags usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT) {
        return allocBuffer(name, size, VK_BUFFER_USAGE_TRANSFER_SRC_BIT | usage);
    }

    DeviceImage allocImage(string name,
                           uint[] dimensions,
                           uint usage,
                           VkFormat format,
                           void delegate(VkImageCreateInfo*) overrides=null)
    {
        VkImageCreateInfo createInfo;
        auto image = device.createImage(format, dimensions, (info) {
            info.tiling        = VK_IMAGE_TILING_OPTIMAL;
            info.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
            info.usage         = usage;

            if(overrides) overrides(info);

            createInfo = *info;
        });

        auto memReqs = device.getImageMemoryRequirements(image);
        version(LOG_MEM) this.log("allocImage: Image '%s' %s requires size %s align %s",
            name, dimensions, memReqs.size, memReqs.alignment);

        // alignment seems to be either 256 bytes, 1K or 128k depending on image size
        ulong offset = bind(image, memReqs);
        auto di      = new DeviceImage(vk, this, name, image, format, offset, memReqs.size, dimensions, createInfo);
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
        vkassert(isHostVisible, "This memory cannot be mapped");
        return mapPtr + b.offset;
    }
    void* mapForWriting(SubBuffer b) {
        vkassert(isHostVisible, "This memory cannot be mapped");
        return mapPtr + b.parent.offset + b.offset;
    }
    void* mapForWriting(DeviceImage i) {
        vkassert(isHostVisible, "This memory cannot be mapped");
        return mapPtr + i.offset;
    }

    void* mapForReading(DeviceBuffer b, ulong offset, ulong size) {
        vkassert(isHostVisible, "This memory cannot be mapped");
        vkassert(offset + size <= b.size);
        invalidateRange(b.offset + offset, size);
        return mapPtr + b.offset + offset;
    }
    void* mapForReading(DeviceImage i) {
        vkassert(isHostVisible, "This memory cannot be mapped");
        invalidateRange(i.offset, i.size);
        return mapPtr + i.offset;
    }

    void mapAndWrite(void* data, ulong offset, ulong size) {
        auto ptr = mapPtr + offset;
        memcpy(ptr, data, size);
        flushRange(offset, size);
    }

    void* map(DeviceBuffer b) {
        vkassert(isHostVisible, "This memory cannot be mapped");
        return mapPtr + b.offset;
    }
    void* map(SubBuffer b) {
        vkassert(isHostVisible, "This memory cannot be mapped");
        return mapPtr + b.parent.offset + b.offset;
    }
    void* map(DeviceImage i) {
        vkassert(isHostVisible, "This memory cannot be mapped");
        return mapPtr + i.offset;
    }

    void flushRange(ulong offset, ulong size) {
        if(isHostCoherent) return;

        // TODO - non coherent memory size should be a multiple of VkPhysicalDeviceLimits::nonCoherentAtomSize
        //                            offset should be a multiple of VkPhysicalDeviceLimits::nonCoherentAtomSize
        device.flushMappedMemory(handle, offset, size);
    }
    void invalidateRange(ulong offset, ulong size) {
        if(isHostCoherent) return;
        device.invalidateMappedMemory(handle, offset, size);
    }
private:
    AllocInfo bind(VkBuffer buffer, ref VkMemoryRequirements reqs, string bufferName) {
        version(LOG_MEM) this.log("%s: Binding buffer size %,s align %s", name, reqs.size, reqs.alignment);
        long offset = allocs.alloc(reqs.size, cast(uint)reqs.alignment);
        if(offset==-1) throwOOM(reqs.size);
        device.bindBufferMemory(buffer, handle, offset);
        //logMem("%s: Bound buffer '%s' [%,s - %,s] align %s", name, bufferName, offset, offset+reqs.size, reqs.alignment);
        return AllocInfo(offset, reqs.size);
    }
    ulong bind(VkImage image, ref VkMemoryRequirements reqs) {
        long offset = allocs.alloc(reqs.size, cast(uint)reqs.alignment);
        if(offset==-1) throwOOM(reqs.size);
        device.bindImageMemory(image, handle, offset);
        //logMem("%s: Bound image [%,s - %,s] align %s", name, offset, offset+reqs.size, reqs.alignment);
        return offset;
    }
    void throwOOM(ulong requestSize) {
        throw new Error("%s: Out of DeviceMemory space. Currently allocated %s of %s. Request of %s bytes exceeds capacity"
            .format(name, allocs.numBytesUsed, size, requestSize));
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

