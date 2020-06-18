module vulkan.helpers.GPUData;

import vulkan.all;

final class GPUData(T) {
private:
    VulkanContext context;
    T data;
    BufID bufId;
    SubBuffer stagingUpBuf, stagingDownBuf;
    const bool uploadble, downloadable;
    bool staleRead, staleWrite;
public:
    SubBuffer upBuffer, downBuffer;

    this(VulkanContext context, BufID bufId, bool upload, bool download) {
        assert(upload || download);
        this.context = context;
        this.bufId = bufId;
        this.uploadble = upload;
        this.downloadable = download;
        this.staleRead = false;
        this.staleWrite = true;
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
        d(&data);
    }
    T* read() {
        if(staleRead) {
            staleRead = false;
            auto ptr = stagingDownBuf.mapForReading();
            memcpy(&data, ptr, T.sizeof);
        }
        return &data;
    }
    void upload(VkCommandBuffer cmd) {
        assert(uploadble);
        if(staleWrite) {
            staleWrite = false;
            stagingUpBuf.mapAndWrite(&data, 0, T.sizeof);
            context.transfer().copy(cmd, stagingUpBuf, upBuffer);
        }
    }
    void download(VkCommandBuffer cmd) {
        assert(downloadable);
        staleRead = true;
        context.transfer().copy(cmd, downBuffer, stagingDownBuf);
    }
private:
    void createBuffers() {
        if(uploadble) {
            stagingUpBuf = context.buffer(BufID.STAGING).alloc(T.sizeof);
            upBuffer = context.buffer(bufId).alloc(T.sizeof);
        }
        if(downloadable) {
            stagingDownBuf = context.buffer(BufID.STAGING_DOWN).alloc(T.sizeof);
            downBuffer = context.buffer(bufId).alloc(T.sizeof);
        }
    }
}