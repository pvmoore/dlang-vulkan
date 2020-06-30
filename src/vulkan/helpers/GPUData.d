module vulkan.helpers.GPUData;

import vulkan.all;

final class GPUData(T) {
    static assert(isStruct!T || isPrimitiveType!T);
private:
    VulkanContext context;
    BufID bufId;
    bool staleWrite;
    SubBuffer stagingUpBuf, stagingDownBuf;
public:
    const uint count;
    const ulong numBytes;
    const bool uploadble, downloadable;
    SubBuffer upBuffer, downBuffer;

    this(VulkanContext context, BufID bufId, bool upload, bool download, uint count = 1) {
        assert(bufId!=BufID.UNIFORM || count==1);
        assert(bufId!=BufID.UNIFORM || numBytes%16==0);
        assert(upload || download);
        assert(count > 0);

        this.count = count;
        this.context = context;
        this.bufId = bufId;
        this.uploadble = upload;
        this.downloadable = download;
        this.staleWrite = true;
        this.numBytes = T.sizeof * count;

        createBuffers();
    }
    void destroy() {
        if(stagingUpBuf) stagingUpBuf.free();
        if(stagingDownBuf) stagingDownBuf.free();
        if(upBuffer) upBuffer.free();
        if(downBuffer) downBuffer.free();
    }
    bool isStaleWrite() {
        return staleWrite;
    }
    void setStaleWrite() {
        staleWrite = true;
    }

    void write(void delegate(T*) d) {
        staleWrite = true;
        d(cast(T*)stagingUpBuf.map());
    }
    T* read() {
        return cast(T*)stagingDownBuf.mapForReading();
    }
    void write(T* src, uint count = 1) {
        assert(count <= this.count);
        staleWrite = true;
        memcpy(stagingUpBuf.map(), src, T.sizeof * count);
    }
    void read(T* dest, uint count = 1) {
        assert(count <= this.count);
        memcpy(dest, stagingDownBuf.mapForReading(), T.sizeof * count);
    }

    void upload(VkCommandBuffer cmd) {
        assert(uploadble);
        if(staleWrite) {
            staleWrite = false;
            context.transfer().copy(cmd, stagingUpBuf, upBuffer);
        }
    }
    void download(VkCommandBuffer cmd) {
        assert(downloadable);
        context.transfer().copy(cmd, downBuffer, stagingDownBuf);
    }
private:
    void createBuffers() {
        if(uploadble) {
            stagingUpBuf = context.buffer(BufID.STAGING).alloc(numBytes);
            upBuffer = context.buffer(bufId).alloc(numBytes);
        }
        if(downloadable) {
            stagingDownBuf = context.buffer(BufID.STAGING_DOWN).alloc(numBytes);
            downBuffer = context.buffer(bufId).alloc(numBytes);
        }
    }
}