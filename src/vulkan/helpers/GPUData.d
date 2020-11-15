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

    ulong dirtyWriteOnFrame;
    uint dirtyFromEle, dirtyToEle;
public:
    const uint count;
    const ulong numBytes;
    const bool isUpload;

    SubBuffer getDeviceBuffer(uint index = 0) {
        assert(deviceBuffers.length > index, "index %s >= %s".format(index, deviceBuffers.length));
        return deviceBuffers[index];
    }

    this(VulkanContext context, BufID bufId, bool isUpload, uint count = 1) {
        assert(bufId!=BufID.UNIFORM || count==1);
        assert(bufId!=BufID.UNIFORM || numBytes%16==0);
        assert(count > 0);

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
        assert(fromElement < toElement);
        assert(toElement <= count);

        this.dirtyFromEle      = minOf(dirtyFromEle, fromElement);
        this.dirtyToEle        = maxOf(dirtyToEle, toElement);
        this.dirtyWriteOnFrame = currentFrame();
    }

    /** Call 'setDirtyRange' after making any changes to the staging buffer */
    T* map() {
        return cast(T*)stagingBuf.map();
    }
    void write(void delegate(T*) d, uint elementIndex = 0) {

        setDirtyRange(elementIndex, elementIndex+1);

        d(map() + elementIndex);
    }
    void write(T[] data, uint destIndex = 0) {
        assert(destIndex + data.length <= this.count);

        setDirtyRange(destIndex, destIndex+data.length.as!uint);

        memcpy(stagingBuf.map() + destIndex, data.ptr, T.sizeof * data.length);
    }
    void memset(uint fromElement, uint count) {
        assert(fromElement + count <= this.count);

        setDirtyRange(fromElement, fromElement+count);

        .memset(map()+fromElement, 0, count*T.sizeof);
    }

    T* read() {
        return cast(T*)stagingBuf.mapForReading();
    }
    void read(T* dest, uint count = 1) {
        assert(count <= this.count);
        memcpy(dest, stagingBuf.mapForReading(), T.sizeof * count);
    }

    bool isUploadRequired() {
        return dirtyWriteOnFrame + numFrameBuffers > currentFrame();
    }

    /** Data will be uploaded only if the stagingBuffer contains unwritten data */
    void upload(VkCommandBuffer cmd) {
        assert(isUpload);

        if(isUploadRequired()) {
            uint frameIndex = numFrameBuffers == 1 ? 0 : context.vk.getFrameBufferIndex().value;
            doUpload(cmd, getDeviceBuffer(frameIndex));
        } else {
            resetDirtyRange();
        }
    }
    /** Download data is always assumed to be stale */
    void download(VkCommandBuffer cmd, FrameBufferIndex frameIndex = FRAME_BUFFER_INDEX_0) {
        assert(!isUpload);
        context.transfer().copy(cmd, getDeviceBuffer(frameIndex.value), stagingBuf);
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
    void doUpload(VkCommandBuffer cmd, SubBuffer destBuffer) {
        final switch(uploadStrategy) with(GPUDataUploadStrategy) {
            case ALL:
                context.transfer().copy(cmd, stagingBuf, destBuffer);
                break;
            case RANGE:
                context.transfer().copy(
                    cmd,
                    stagingBuf.parent, stagingBuf.offset + dirtyFromEle*T.sizeof,
                    destBuffer.parent, destBuffer.offset + dirtyFromEle*T.sizeof,
                    (dirtyToEle-dirtyFromEle)*T.sizeof);
                break;
        }
    }
}