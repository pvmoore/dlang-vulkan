module vulkan.helpers.GPUDataFreeList;

import vulkan.all;

/**
 * Wrapper for ContiguousFreeList specifically for GPUData
 */
final class GPUDataFreeList(T) {
public:
    this(GPUData!T gpuData) {
        this.gpuData = gpuData;
        this.freeList = new ContiguousFreeList(gpuData.count, &moveDataCallback);
    }
    void reset() {
        gpuData.setDirtyRange(0, numUsed());
        freeList.reset();
    }
    uint acquire() {
        assert(freeList.numFree() > 0);
        return freeList.acquire().id;
    }
    void release(uint id) {
        assert(getIndex(id) < numUsed(), "Id %s has already been released or was never allocated".format(id));
        freeList.release(ContiguousFreeList.Handle(id));
    }
    uint getIndex(uint id) {
        return freeList.getIndex(ContiguousFreeList.Handle(id));
    }
    uint numUsed() {
        return freeList.numUsed();
    }
    uint numFree() {
        return freeList.numFree();
    }
    /** Returns a pointer to the element at the given id and marks it as dirty */
    T* mapViaId(uint id) {
        uint index = getIndex(id);
        auto ptr = gpuData.map() + index;
        gpuData.setDirtyRange(index, index+1);
        return ptr;
    }
    /** Sets the element at the given id and marks it as dirty */
    void setViaId(uint id, T value) {
        auto ptr = mapViaId(id);
        *ptr = value;
    }   
private:
    @Borrowed GPUData!T gpuData; 
    ContiguousFreeList freeList;

    /** ContiguousFreeList Callback to move data */
    void moveDataCallback(uint from, uint to) {
        auto ptr = gpuData.map();
        memcpy(ptr + to, ptr + from, T.sizeof);
        gpuData.setDirtyRange(to, to+1);
    }
}
