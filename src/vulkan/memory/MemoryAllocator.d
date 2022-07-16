module vulkan.memory.MemoryAllocator;

import vulkan.all;

final class MemoryAllocator {
private:
    Vulkan vk;
    VkMemoryType[] memoryTypes;
	VkMemoryHeap[] memoryHeaps;

    final class Builder {
    private:
        ulong size;
        uint[] typeIndexes;
    public:
        this(ulong size) {
            this.size = size;
            this.typeIndexes = iota(0, memoryTypes.length.as!uint).array;

            // Filter out by size
            typeIndexes = typeIndexes.filter!(i=>memoryHeaps[memoryTypes[i].heapIndex].size >= size).array;
        }
        auto withAll(VkMemoryPropertyFlags props) {
            typeIndexes = typeIndexes.filter!(i=>(memoryTypes[i].propertyFlags&props)==props).array;
            return this;
        }
        auto withoutAll(VkMemoryPropertyFlags props) {
            typeIndexes = typeIndexes.filter!(i=>(memoryTypes[i].propertyFlags&props)==0).array;
            return this;
        }
        auto withIfPossible(VkMemoryPropertyFlags props) {
            auto temp = typeIndexes.filter!(i=>(memoryTypes[i].propertyFlags&props)==props).array;
            if(temp.length > 0) {
                typeIndexes = temp;
            }
            return this;
        }
        auto withoutIfPossible(VkMemoryPropertyFlags props) {
            auto temp = typeIndexes.filter!(i=>(memoryTypes[i].propertyFlags&props)==0).array;
            if(temp.length > 0) {
                typeIndexes = temp;
            }
            return this;
        }
        ulong maxHeapSize() {
            if(typeIndexes.length==0) return 0;
            uint typeIndex = typeIndexes[0];
            if(typeIndexes.length > 1) {
                typeIndex = selectTypeWithLargestHeap(typeIndexes);
            }
            auto heapIndex = memoryTypes[typeIndex].heapIndex;
            return memoryHeaps[heapIndex].size;
        }
        DeviceMemory build(string name) {

            if(typeIndexes.length==0) return null;

            uint typeIndex = typeIndexes[0];
            if(typeIndexes.length > 1) {
                typeIndex = selectTypeWithLargestHeap(typeIndexes);
            }

            VkDeviceMemory m = vk.device.allocateMemory(typeIndex, size);
            return new DeviceMemory(vk, m, name, size, memoryTypes[typeIndex].propertyFlags, typeIndex);
        }
    }
public:
    this(Vulkan vk) {
        this.vk = vk;
        this.memoryTypes = vk.memoryProperties.memoryTypes[0..vk.memoryProperties.memoryTypeCount];
        this.memoryHeaps = vk.memoryProperties.memoryHeaps[0..vk.memoryProperties.memoryHeapCount];
    }
    Builder builder(ulong size) {
        return new Builder(size);
    }
    DeviceMemory allocStdDeviceLocal(string name, ulong size) {
        return builder(size)
            .withAll(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
            .withoutAll(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)
            .build(name);
    }
    DeviceMemory allocStdShared(string name, ulong size) {
        return builder(size)
            .withAll(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT | VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)
            .build(name);
    }
    DeviceMemory allocStdStagingUpload(string name, ulong size) {
        return builder(size)
            .withAll(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)
            .withoutIfPossible(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)

            .withIfPossible(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT)
            .withoutIfPossible(VK_MEMORY_PROPERTY_HOST_CACHED_BIT)
            .build(name);
    }
    DeviceMemory allocStdStagingDownload(string name, ulong size) {
        return builder(size)
            .withAll(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)
            .withoutIfPossible(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)

            .withIfPossible(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT)
            .withIfPossible(VK_MEMORY_PROPERTY_HOST_CACHED_BIT)
            .build(name);
    }
private:
    uint selectTypeWithLargestHeap(uint[] typeIndexes) {
        uint type;
        ulong bestSize;
        foreach(i; typeIndexes) {

            auto t = memoryTypes[i];
            auto h = memoryHeaps[t.heapIndex];

            if(h.size > bestSize) {
                type = i.as!uint;
                bestSize = h.size;
            }
        }
        return type;
    }
}