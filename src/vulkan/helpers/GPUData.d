module vulkan.helpers.GPUData;

import vulkan.all;

final class GPUData(T, uint COUNT=1) {
    static assert(COUNT > 0);
    static assert(isStruct!T || isPrimitiveType!T);
private:
    VulkanContext context;
    BufID bufId;
    const ulong numBytes;
    const bool uploadble, downloadable;
    bool staleWrite;
    SubBuffer stagingUpBuf, stagingDownBuf;
public:
    SubBuffer upBuffer, downBuffer;

    this(VulkanContext context, BufID bufId, bool upload, bool download) {
        assert(bufId!=BufID.UNIFORM || COUNT==1);
        assert(bufId!=BufID.UNIFORM || numBytes%16==0);
        assert(upload || download);

        this.context = context;
        this.bufId = bufId;
        this.uploadble = upload;
        this.downloadable = download;
        this.staleWrite = true;
        this.numBytes = T.sizeof * COUNT;

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
    void write(T* src) {
        staleWrite = true;
        memcpy(stagingUpBuf.map(), src, T.sizeof * COUNT);
    }
    T* read() {
        return cast(T*)stagingDownBuf.mapForReading();
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