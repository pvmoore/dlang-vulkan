module vulkan.memory.memory_manager;
/**
 *  Possible improvements:
 *      - Use several gpu memory pools for different allocation sizes.
 *      - Use a different gpu memory pool for short lived allocations.
 *      - Use a different buffer for dynamic allocations
 *      - Have more than 1 large memory block so that the OS can switch one out if necessary
 *      - Try using shared memory to upload data.
 */
import vulkan.all;

final class VulkanMemoryManager {
private:
    Vulkan vk;
    VkDevice device;
    ulong localSize, stagingSize, sharedSize;
public:
    DeviceMemory local, staging, shared_;

    this(Vulkan vk, ulong localSize, ulong stagingSize, ulong sharedSize) {
        this.vk          = vk;
        this.device      = vk.device;
        this.localSize   = localSize;
        this.stagingSize = stagingSize;
        this.sharedSize  = sharedSize;
        allocPools();
    }
    void destroy() {
        if(local) local.destroy();
        if(staging) staging.destroy();
        if(shared_) shared_.destroy();
    }
    SubBuffer createVertexBuffer(ulong size) {
        return local.getBuffer("VertexBuffer").alloc(size);
    }
    SubBuffer createIndexBuffer(ulong size) {
        return local.getBuffer("IndexBuffer").alloc(size);
    }
    SubBuffer createUniformBuffer(ulong size) {
        return local.getBuffer("UniformBuffer")
                    .alloc(size, cast(uint)vk.limits.minUniformBufferOffsetAlignment);
    }
    SubBuffer createStagingBuffer(ulong size) {
        return staging.getBuffer("StagingBuffer").alloc(size);
    }
    DeviceImage uploadImage(
        string name,
        uint width,
        uint height,
        ubyte[] data)
    {
        auto bytesPerPixel = data.length / (width*height);
        //logMem("bytesPerPixel = %s", bytesPerPixel);

        VFormat format =
            bytesPerPixel==4 ? VFormat.R8G8B8A8_UNORM :
            bytesPerPixel==3 ? VFormat.R8G8B8_UNORM :
            bytesPerPixel==1 ? VFormat.R8_UNORM :
            VFormat.UNDEFINED;

        logMem("uploadImage %s x %s (%,s KB) format:%s",width, height, data.length/1.KB, format);

        // Check format support
        if(!vk.physicalDevice.isFormatSupported(format)) {
            log("PERF_WARN: Format %s is not supported", format);
            if(bytesPerPixel==3) {
                log("Converting RGB image to RGBA");
                auto png = PNG.create_RGB(width, height, data);
                png.addAlphaChannel(1);
                data          = png.data;
                format        = VFormat.R8G8B8A8_UNORM;
                bytesPerPixel = 4;
            }
        }
        return uploadImage(name, width, height, data, format);
    }
    DeviceImage uploadImage(
            string name,
            uint width,
            uint height,
            ubyte[] data,
            VFormat format)
    {
        expect(format!=VFormat.UNDEFINED);

        StopWatch w; w.start();
        auto stagingBuffer = createStagingBuffer(data.length);

        ubyte* dest = cast(ubyte*)staging.map(stagingBuffer);
        memcpy(dest, data.ptr, data.length);
        staging.flush(stagingBuffer);

        auto image = local.allocImage(
            name,
            [width, height],
            VImageUsage.TRANSFER_DST | VImageUsage.SAMPLED,
            format
        );
        copyFromStagingToLocal(stagingBuffer, image);

        stagingBuffer.free();
        w.stop();
        logMem("uploadImage took %s ms", w.peek().total!"nsecs"/1000000.0);
        return image;
    }
    /**
     *  Blocking copy of data to a DeviceBuffer.
     *  Assumes data size (bytes)==destDB.size.
     */
    void copyToDevice(DeviceBuffer destDB, void* data) {
        expect(destDB.memory.isLocal);

        auto dest = new SubBuffer(destDB, 0, destDB.size, destDB.usage);
        auto src  = createStagingBuffer(destDB.size);

        // memcpy the data to staging subbuffer
        void* ptr = staging.map(src);
        memcpy(ptr, data, destDB.size);
        staging.flush(src);

        copy(src, dest);
        src.free();
    }
    /**
     *  Blocking copy of device data to host.
     */
    T[] copyToHost(T)(DeviceBuffer buffer) {
        expect(buffer.memory.isLocal);

        auto src  = new SubBuffer(buffer, 0, buffer.size, buffer.usage);
        auto dest = createStagingBuffer(buffer.size);

        copy(src, dest);

        T[] data = new T[buffer.size/T.sizeof];

        void* ptr = staging.map(dest);
        memcpy(data.ptr, ptr, buffer.size);
        staging.flush(dest);

        dest.free();

        return data;
    }
    /**
     *  Copy data to a buffer on the GPU
     *  via a staging buffer in host memory.
     */
    void copyToDevice(SubBuffer dest, void* data) {
        copyToDevice(dest, data, 0, dest.size);
    }
    void copyToDevice(SubBuffer dest, void* data, ulong dstOffset, ulong numBytes) {
        StopWatch w; w.start();

        // create staging subbuffer as transfer source
        SubBuffer src = createStagingBuffer(dest.size);

        // memcpy the data to staging subbuffer
        void* ptr = staging.map(src);
        memcpy(ptr+dstOffset, data, numBytes);
        staging.flush(src);

        // copy from staging to dest
        copy(src, dest, dstOffset, dstOffset, numBytes);

        src.free();

        w.stop();
        logMem("copyToDevice: Took %.3f ms to copy %s bytes", w.peek().total!"nsecs"/1000000.0, dest.size);
    }
    void copy(SubBuffer src, SubBuffer dest) {
        expect(src.size==dest.size);
        copy(src, dest, 0, 0, src.size);
    }
    void copy(SubBuffer src, SubBuffer dest, ulong srcOffset, ulong dstOffset, ulong numBytes) {
        expect(src.size==dest.size);

        auto region = VkBufferCopy(
            src.offset + srcOffset,
            dest.offset + dstOffset,
            numBytes
        );

        logMem("Copy %s bytes from %s:%,s to %s:%,s ", region.size,
            src.name, region.srcOffset,
            dest.name, region.dstOffset);

        auto b = device.allocFrom(vk.getTransferCP());
        b.beginOneTimeSubmit();
        b.copyBuffer(
            src.handle,
            dest.handle,
            [region]
        );
        /*b.pipelineBarrier(
            PIPELINE_STAGE_TRANSFER,
            PIPELINE_STAGE_TOP_OF_PIPE,
            0,      // dependencyFlags
            null,   // memory barriers
            [
                bufferMemoryBarrier(
                    dest.handle, 0, dest.size,
                    ACCESS_MEMORY_WRITE,
                    ACCESS_MEMORY_READ,
                    vk.queueFamily.transfer,
                    vk.queueFamily.graphics
                ),
            ],     // buffer memory barriers
            null    // image memory barriers
        );*/
        b.end();
        auto fence = device.createFence();

        vk.getTransferQueue().submit([b], fence);

        device.waitFor(fence);
        device.destroy(fence);

        device.free(vk.getTransferCP(), b);
    }
    /**
     *  Do several non-overlapping copies and block until all are completed.
     *  todo - test this
     */
//    void copy(SubBuffer[] src, SubBuffer[] dest) {
//        uint count = cast(uint)src.length;
//        auto cmdBuffers = device.allocFrom(vk.getTransferCP(), count);
//
//        for(auto i=0;i<count;i++) {
//            cmdBuffers[i].beginOneTimeSubmit();
//            cmdBuffers[i].copyBuffer(src[i].handle, dest[i].handle, [VkBufferCopy(0,0, src[i].size)]);
//            cmdBuffers[i].end();
//        }
//
//        auto fence = device.createFence();
//        vk.getTransferQueue().submit(cmdBuffers, fence);
//        device.waitFor(fence);
//        device.destroy(fence);
//
//        device.free(vk.getTransferCP(), cmdBuffers);
//    }
    DeviceMemorySnapshot[] takeSnapshot() {
        return [
            new DeviceMemorySnapshot(local),
            new DeviceMemorySnapshot(staging),
            new DeviceMemorySnapshot(shared_)
        ];
    }
    void dumpStats() {
        import std.stdio : writefln;
        writefln("=========================================================");
        writefln("%s", new DeviceMemorySnapshot(local).toString());
        writefln("---------------------------------------------------------");
        writefln("%s", new DeviceMemorySnapshot(staging).toString());
        writefln("=========================================================");
        writefln("%s", new DeviceMemorySnapshot(shared_).toString());
        writefln("=========================================================");
    }
private:
    void allocPools() {
        this.local   = allocDeviceMemory("Local", localSize, VMemoryProperty.DEVICE_LOCAL, VMemoryProperty.HOST_VISIBLE);
        this.staging = allocDeviceMemory("Staging", stagingSize, VMemoryProperty.HOST_VISIBLE | VMemoryProperty.HOST_COHERENT, VMemoryProperty.DEVICE_LOCAL | VMemoryProperty.HOST_CACHED);
        this.shared_ = allocDeviceMemory("Shared", sharedSize, VMemoryProperty.HOST_VISIBLE | VMemoryProperty.HOST_COHERENT | VMemoryProperty.DEVICE_LOCAL);
    }
    DeviceMemory allocDeviceMemory(string name, ulong size, uint withFlags, uint withoutFlags=0) {
        uint[] types = filterMemoryTypes(withFlags, withoutFlags);
        if(types.length==0) throw new Error("Requested memory not found");
        uint type = types[0];
        if(types.length>1) type = selectTypeWithLargestHeap(types);
        //logMem("Allocating memory [type %s] of size %s", type, size);

        VkDeviceMemory m = device.allocateMemory(type, size);
        return new DeviceMemory(device, m, name, size, withFlags, type);
    }
    uint[] filterMemoryTypes(uint yes, uint no) {
        uint[] types;
        for(auto i=0; i<vk.memoryProperties.memoryTypeCount; i++) {
            auto f = vk.memoryProperties.memoryTypes[i].propertyFlags;
            if((f & yes)==yes && (f & no)==0) {
                types ~= i;
            }
        }
        return types;
    }
    uint selectTypeWithLargestHeap(uint[] types) {
        uint type;
        ulong size;
        foreach(i; types) {
            auto t = vk.memoryProperties.memoryTypes[i];
            auto h = vk.memoryProperties.memoryHeaps[t.heapIndex];
            if(h.size > size) {
                type = i;
                size = h.size;
            }
        }
        logMem("Found largest heap for types %s : %s (%sMB)", types, type, size/(1024*1024));
        return type;
    }
    void copyFromStagingToLocal(SubBuffer src, DeviceImage dest) {
        auto cmdBuffer = device.allocFrom(vk.getTransferCP());
        auto aspect    = VImageAspect.COLOR;

        cmdBuffer.beginOneTimeSubmit();

        // change dest image layout from VImageLayout.UNDEFINED
        // to VImageLayout.TRANSFER_DST_OPTIMAL
        cmdBuffer.setImageLayout(
            dest.handle,
            aspect,
            VImageLayout.UNDEFINED,
            VImageLayout.TRANSFER_DST_OPTIMAL
        );

        auto region = VkBufferImageCopy();
        region.bufferOffset      = src.offset;
        region.bufferRowLength   = 0;//dest.width*3;
        region.bufferImageHeight = 0;//dest.height;
        region.imageSubresource  = VkImageSubresourceLayers(aspect, 0,0,1);
        region.imageOffset       = VkOffset3D(0,0,0);
        region.imageExtent       = VkExtent3D(dest.width, dest.height, 1);

        // copy the staging buffer to the GPU image
        cmdBuffer.copyBufferToImage(
            src.handle,
            dest.handle, VImageLayout.TRANSFER_DST_OPTIMAL,
            [region]
        );

        // change the GPU image layout from VImageLayout.TRANSFER_DST_OPTIMAL
        // to VImageLayout.SHADER_READ_ONLY_OPTIMAL
        cmdBuffer.setImageLayout(
            dest.handle,
            aspect,
            VImageLayout.TRANSFER_DST_OPTIMAL,
            VImageLayout.SHADER_READ_ONLY_OPTIMAL
        );
        cmdBuffer.end();

        auto fence = device.createFence();

        vk.getTransferQueue().submit([cmdBuffer], fence);

        device.waitFor(fence);
        device.destroy(fence);

        device.free(vk.getTransferCP(), cmdBuffer);
    }
}
