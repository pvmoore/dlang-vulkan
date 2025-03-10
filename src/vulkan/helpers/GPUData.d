module vulkan.helpers.GPUData;

import vulkan.all;

enum GPUDataFrameStrategy { ONLY_ONE, ONE_PER_FRAME }

enum GPUDataUploadStrategy {
    /** Upload the whole buffer if anything changes */
    ALL,

    /** Upload a single range from the minimum to the maximum offset of the dirty area */
    RANGE
}

/**
 *
 *  Note that this class supports either upload or download but not both.
 */
final class GPUData(T) {
    static assert(isStruct!T || isPrimitiveType!T);
private:
    @Borrowed VulkanContext context;
    BufID bufId;
    GPUDataUploadStrategy uploadStrategy;
    GPUDataFrameStrategy frameStrategy;
    uint numFrameBuffers;
    SubBuffer stagingBuf;
    SubBuffer[] deviceBuffers;
    AccessAndStageMasks accessAndStageMasks;

    ulong dirtyWriteOnFrame;
    uint dirtyFromEle, dirtyToEle;
public:
    const uint count;
    const ulong numBytes;
    const bool isUpload;
    bool userFlag;

    SubBuffer getDeviceBuffer(uint index = 0) {
        throwIf(deviceBuffers.length <= index, "index %s >= %s".format(index, deviceBuffers.length));
        return deviceBuffers[index];
    }

    this(VulkanContext context, BufID bufId, bool isUpload, uint count = 1) {
        throwIf(count == 0);
        if(bufId==BufID.UNIFORM) {
            throwIf(count != 1);
            throwIf(numBytes%16 != 0);
        }

        this.count = count;
        this.context = context;
        this.bufId = bufId;
        this.isUpload = isUpload;
        this.dirtyWriteOnFrame = 0;
        this.dirtyFromEle = 0;
        this.dirtyToEle = count;    // set the whole buffer as dirty at the start
        this.numBytes = T.sizeof * count;
        this.frameStrategy = GPUDataFrameStrategy.ONLY_ONE;
        this.uploadStrategy = GPUDataUploadStrategy.ALL;
    }
    void destroy() {
        if(stagingBuf) stagingBuf.free();
        foreach(b; deviceBuffers) b.free();
    }
    auto initialise() {
        this.numFrameBuffers = (frameStrategy == GPUDataFrameStrategy.ONE_PER_FRAME) ? context.vk.swapchain.numImages : 1;
        createBuffers();

        if(accessAndStageMasks.srcAccessMask == 0) {
            if(bufId == BufID.UNIFORM) {
                this.accessAndStageMasks = AccessAndStageMasks(
                    VkAccessFlagBits.VK_ACCESS_UNIFORM_READ_BIT,
                    VkAccessFlagBits.VK_ACCESS_UNIFORM_READ_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_VERTEX_SHADER_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_VERTEX_SHADER_BIT
                );
            } else if(bufId == BufID.VERTEX) {
                this.accessAndStageMasks = AccessAndStageMasks(
                    VkAccessFlagBits.VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT,
                    VkAccessFlagBits.VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT
                );
            } else if(bufId == BufID.INDEX) {
                this.accessAndStageMasks = AccessAndStageMasks(
                    VkAccessFlagBits.VK_ACCESS_INDEX_READ_BIT,
                    VkAccessFlagBits.VK_ACCESS_INDEX_READ_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT
                );
            } else {
                throwIf(accessAndStageMasks.srcAccessMask == 0, "Access and stage masks not set for %s", bufId);
            }
        }

        return this;
    }
    auto withAccessAndStageMasks(AccessAndStageMasks accessAndStageMasks) {
        this.accessAndStageMasks = accessAndStageMasks;
        return this;
    }
    auto withFrameStrategy(GPUDataFrameStrategy s) {
        this.frameStrategy = s;
        return this;
    }
    auto withUploadStrategy(GPUDataUploadStrategy s) {
        this.uploadStrategy = s;
        return this;
    }
    /** Set the whole buffer as dirty */
    void setDirtyRange() {
        this.setDirtyRange(0, count);
    }
    /** Exclusive range */
    void setDirtyRange(uint fromElement, uint toElement) {
        throwIf(fromElement >= toElement);
        throwIf(toElement > count);

        this.dirtyFromEle      = minOf(dirtyFromEle, fromElement);
        this.dirtyToEle        = maxOf(dirtyToEle, toElement);
        this.dirtyWriteOnFrame = currentFrame();
    }

    /** Call 'setDirtyRange' after making any changes to the staging buffer */
    T* map() {
        return cast(T*)stagingBuf.map();
    }
    auto write(void delegate(T*) d, uint elementIndex = 0) {

        setDirtyRange(elementIndex, elementIndex+1);

        d(map() + elementIndex);

        return this;
    }
    auto write(T[] data, uint destIndex = 0) {
        throwIf(destIndex + data.length > this.count);

        setDirtyRange(destIndex, destIndex+data.length.as!uint);

        memcpy(stagingBuf.map() + destIndex, data.ptr, T.sizeof * data.length);

        return this;
    }
    void memset(uint fromElement, uint count) {
        throwIf(fromElement + count > this.count);

        setDirtyRange(fromElement, fromElement+count);

        .memset(map()+fromElement, 0, count*T.sizeof);
    }

    T* read() {
        return cast(T*)stagingBuf.mapForReading();
    }
    void read(T* dest, uint count = 1) {
        throwIf(count > this.count);
        memcpy(dest, stagingBuf.mapForReading(), T.sizeof * count);
    }

    bool isUploadRequired() {
        // Add 1 because the update may be made after this GPUData
        // object has been processed in the current frame.
        return dirtyWriteOnFrame + numFrameBuffers + 1 > currentFrame();
    }

    /**
     * Data will be uploaded only if the stagingBuffer contains unwritten data
     * @return the number of bytes uploaded
     */
    ulong upload(VkCommandBuffer cmd) {
        throwIf(!isUpload);

        if(isUploadRequired()) {
            uint frameIndex = numFrameBuffers == 1 ? 0 : context.vk.getFrameBufferIndex().value;
            return doUpload(cmd, getDeviceBuffer(frameIndex));
        } else {
            resetDirtyRange();
        }
        return 0;
    }
    /**
     * Upload data for the given frameIndex regardless of dirty state.
     * This is useful for uploading buffers in a command buffer that is pre-generated.
     */
    void upload(VkCommandBuffer cmd, uint frameIndex) {
        doUpload(cmd, getDeviceBuffer(frameIndex));
    }
    /** Download data is always assumed to be stale */
    void download(VkCommandBuffer cmd, FrameBufferIndex frameIndex = FRAME_BUFFER_INDEX_0) {
        throwIf(isUpload);
        context.transfer().copy(cmd, getDeviceBuffer(frameIndex.value), stagingBuf, accessAndStageMasks);
    }
private:
    void resetDirtyRange() {
        this.dirtyFromEle = uint.max;
        this.dirtyToEle   = 0;
    }
    ulong currentFrame() {
        return context.vk.getFrameNumber().value;
    }
    void createBuffers() {
        if(isUpload) {
            stagingBuf = context.buffer(BufID.STAGING).alloc(numBytes);

            this.log("Allocating %s upload SubBuffers on device buffer %s", numFrameBuffers, bufId);
            foreach(i; 0..numFrameBuffers) {
                deviceBuffers ~= context.buffer(bufId).alloc(numBytes);
            }
        } else{
            stagingBuf = context.buffer(BufID.STAGING_DOWN).alloc(numBytes);

            this.log("Allocating %s download SubBuffers on device buffer %s", numFrameBuffers, bufId);
            foreach(i; 0..numFrameBuffers) {
                deviceBuffers ~= context.buffer(bufId).alloc(numBytes);
            }
        }
    }
    /** Upload and return num bytes transferred */
    ulong doUpload(VkCommandBuffer cmd, SubBuffer destBuffer) {
        final switch(uploadStrategy) with(GPUDataUploadStrategy) {
            case ALL:
                context.transfer().copy(cmd, stagingBuf, destBuffer, accessAndStageMasks);
                return stagingBuf.size;
            case RANGE:
                auto size = (dirtyToEle-dirtyFromEle)*T.sizeof;
                context.transfer().copy(
                    cmd,
                    stagingBuf.parent, stagingBuf.offset + dirtyFromEle*T.sizeof,
                    destBuffer.parent, destBuffer.offset + dirtyFromEle*T.sizeof,
                    size,
                    accessAndStageMasks);
                return size;
        }
    }
}
