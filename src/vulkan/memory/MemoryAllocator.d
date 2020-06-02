module vulkan.memory.MemoryAllocator;

import vulkan.all;

final class MemoryAllocator {
private:
    Vulkan vk;
    VkMemoryType[] memoryTypes;
	VkMemoryHeap[] memoryHeaps;

    final class Builder {
    private:
        string name;
        ulong size;
        uint[] typeIndexes;
    public:
        this(string name, ulong size) {
            this.name = name;
            this.size = size;
            this.typeIndexes = iota(0, memoryTypes.length.as!uint).array;
        }
        auto withAll(VMemoryProperty props) {
            typeIndexes = typeIndexes.filter!(i=>(memoryTypes[i].propertyFlags&props)==props).array;
            return this;
        }
        auto withoutAll(VMemoryProperty props) {
            typeIndexes = typeIndexes.filter!(i=>(memoryTypes[i].propertyFlags&props)==0).array;
            return this;
        }
        auto withIfPossible(VMemoryProperty props) {
            auto temp = typeIndexes.filter!(i=>(memoryTypes[i].propertyFlags&props)==props).array;
            if(temp.length > 0) {
                typeIndexes = temp;
            }
            return this;
        }
        auto withoutIfPossible(VMemoryProperty props) {
            auto temp = typeIndexes.filter!(i=>(memoryTypes[i].propertyFlags&props)==0).array;
            if(temp.length > 0) {
                typeIndexes = temp;
            }
            return this;
        }
        DeviceMemory build() {

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
    Builder builder(string name, ulong size) {
        return new Builder(name, size);
    }
    DeviceMemory allocStdDeviceLocal(string name, ulong size) {
        return builder(name, size)
            .withAll(VMemoryProperty.DEVICE_LOCAL)
            .withoutAll(VMemoryProperty.HOST_VISIBLE)
            .build();
    }
    DeviceMemory allocStdShared(string name, ulong size) {
        return builder(name, size)
            .withAll(VMemoryProperty.DEVICE_LOCAL | VMemoryProperty.HOST_VISIBLE)
            .build();
    }
    DeviceMemory allocStdStagingUpload(string name, ulong size) {
        return builder(name, size)
            .withAll(VMemoryProperty.HOST_VISIBLE)
            .withoutAll(VMemoryProperty.DEVICE_LOCAL)

            .withIfPossible(VMemoryProperty.HOST_COHERENT)
            .withoutIfPossible(VMemoryProperty.HOST_CACHED)
            .build();
    }
    DeviceMemory allocStdStagingDownload(string name, ulong size) {
        return builder(name, size)
            .withAll(VMemoryProperty.HOST_VISIBLE)
            .withoutAll(VMemoryProperty.DEVICE_LOCAL)

            .withIfPossible(VMemoryProperty.HOST_COHERENT)
            .withIfPossible(VMemoryProperty.HOST_CACHED)
            .build();
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