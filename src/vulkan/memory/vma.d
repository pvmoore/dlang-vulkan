module vulkan.memory.vma;

import vulkan.all;

/**
 * Vulkan Memory Allocator
 * https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/index.html
 */

void initialiseVma(Vulkan vk) {
    verbose(__FILE__, "Initialising VMA");

    VmaVulkanFunctions vulkanFunctions = {
        vkGetInstanceProcAddr: vkGetInstanceProcAddr,
        vkGetDeviceProcAddr: vkGetDeviceProcAddr,
        vkGetPhysicalDeviceProperties: vkGetPhysicalDeviceProperties,
        vkGetPhysicalDeviceMemoryProperties: vkGetPhysicalDeviceMemoryProperties,
        vkAllocateMemory: vkAllocateMemory,
        vkFreeMemory: vkFreeMemory,
        vkMapMemory: vkMapMemory,
        vkUnmapMemory: vkUnmapMemory,

        vkFlushMappedMemoryRanges: vkFlushMappedMemoryRanges,
        vkInvalidateMappedMemoryRanges: vkInvalidateMappedMemoryRanges,
        vkBindBufferMemory: vkBindBufferMemory,
        vkBindImageMemory: vkBindImageMemory,
        vkGetBufferMemoryRequirements: vkGetBufferMemoryRequirements,
        vkGetImageMemoryRequirements: vkGetImageMemoryRequirements,
        vkCreateBuffer: vkCreateBuffer,
        vkDestroyBuffer: vkDestroyBuffer,
        vkCreateImage: vkCreateImage,
        vkDestroyImage: vkDestroyImage,
        vkCmdCopyBuffer: vkCmdCopyBuffer,

        vkGetBufferMemoryRequirements2KHR: vkGetBufferMemoryRequirements2KHR,
        vkGetImageMemoryRequirements2KHR: vkGetImageMemoryRequirements2KHR,
        vkBindBufferMemory2KHR: vkBindBufferMemory2KHR,
        vkBindImageMemory2KHR: vkBindImageMemory2KHR,
        vkGetPhysicalDeviceMemoryProperties2KHR: vkGetPhysicalDeviceMemoryProperties2,
        vkGetDeviceBufferMemoryRequirements: vkGetDeviceBufferMemoryRequirements,
        vkGetDeviceImageMemoryRequirements: vkGetDeviceImageMemoryRequirements
    };

    version(Windows) {
        vulkanFunctions.vkGetMemoryWin32HandleKHR = vkGetMemoryWin32HandleKHR;
    }

    VmaAllocatorCreateInfo allocatorCreateInfo = {
        flags: 0
            //| VMA_ALLOCATOR_CREATE_KHR_DEDICATED_ALLOCATION_BIT
            | VMA_ALLOCATOR_CREATE_KHR_BIND_MEMORY2_BIT
            | VMA_ALLOCATOR_CREATE_EXT_MEMORY_BUDGET_BIT
            //| VMA_ALLOCATOR_CREATE_AMD_DEVICE_COHERENT_MEMORY_BIT
            | VMA_ALLOCATOR_CREATE_BUFFER_DEVICE_ADDRESS_BIT
            | VMA_ALLOCATOR_CREATE_EXT_MEMORY_PRIORITY_BIT
            | VMA_ALLOCATOR_CREATE_KHR_MAINTENANCE4_BIT
            | VMA_ALLOCATOR_CREATE_KHR_MAINTENANCE5_BIT
            //| VMA_ALLOCATOR_CREATE_KHR_EXTERNAL_MEMORY_WIN32_BIT
            ,
        physicalDevice: vk.physicalDevice,
        device: vk.device,
        preferredLargeHeapBlockSize: 0,  
        pAllocationCallbacks: null,
        pDeviceMemoryCallbacks: null,
        pHeapSizeLimit: null,
        pVulkanFunctions: &vulkanFunctions,
        instance: vk.instance,
        vulkanApiVersion: vk.vprops.apiVersion,
        pTypeExternalMemoryHandleTypes: null
    };

    check(vmaCreateAllocator(&allocatorCreateInfo, &allocator));
    verbose(__FILE__, "VMA initialised");
}
void destroyVma(Vulkan vk) {
    verbose(__FILE__, "Destroying VMA");
    if(allocator) {    
        vmaDestroyAllocator(allocator);
    }
}

/** Todo - flesh this out and make it useful */
void allocBufferExample() {
    VkBufferCreateInfo bufferInfo = { 
        sType: VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        size: 65536,
        usage: VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT 
    };
    
    VmaAllocationCreateInfo allocInfo = {
        flags: 0
            //   |  VMA_ALLOCATION_CREATE_DEDICATED_MEMORY_BIT
            //   |  VMA_ALLOCATION_CREATE_NEVER_ALLOCATE_BIT 
              |  VMA_ALLOCATION_CREATE_MAPPED_BIT
            //   |  VMA_ALLOCATION_CREATE_USER_DATA_COPY_STRING_BIT 
            //   |  VMA_ALLOCATION_CREATE_UPPER_ADDRESS_BIT 
            //   |  VMA_ALLOCATION_CREATE_DONT_BIND_BIT 
            //   |  VMA_ALLOCATION_CREATE_WITHIN_BUDGET_BIT 
            //   |  VMA_ALLOCATION_CREATE_CAN_ALIAS_BIT 
            //   |  VMA_ALLOCATION_CREATE_HOST_ACCESS_SEQUENTIAL_WRITE_BIT 
            //   |  VMA_ALLOCATION_CREATE_HOST_ACCESS_RANDOM_BIT 
            //   |  VMA_ALLOCATION_CREATE_HOST_ACCESS_ALLOW_TRANSFER_INSTEAD_BIT 
            //   |  VMA_ALLOCATION_CREATE_STRATEGY_MIN_MEMORY_BIT 
            //   |  VMA_ALLOCATION_CREATE_STRATEGY_MIN_TIME_BIT 
            //   |  VMA_ALLOCATION_CREATE_STRATEGY_MIN_OFFSET_BIT 
            ,
        usage: 0.as!VmaMemoryUsage
            //| VMA_MEMORY_USAGE_GPU_ONLY 
            // | VMA_MEMORY_USAGE_CPU_ONLY 
             | VMA_MEMORY_USAGE_CPU_TO_GPU 
            // | VMA_MEMORY_USAGE_GPU_TO_CPU 
            // | VMA_MEMORY_USAGE_CPU_COPY 
            // | VMA_MEMORY_USAGE_GPU_LAZILY_ALLOCATED 
            // | VMA_MEMORY_USAGE_AUTO 
            // | VMA_MEMORY_USAGE_AUTO_PREFER_DEVICE 
            // | VMA_MEMORY_USAGE_AUTO_PREFER_HOST 
            ,
        requiredFlags: 0,
        preferredFlags: 0,
        memoryTypeBits: 0,   
        pool: null,
        pUserData: null,
        priority: 0
    };
    
    VkBuffer buffer;
    VmaAllocation allocation;
    check(vmaCreateBuffer(allocator, &bufferInfo, &allocInfo, &buffer, &allocation, null));

    ubyte[] data = [0,1,2,3];

    // Copy from CPU to GPU
    vmaCopyMemoryToAllocation(allocator, data.ptr, allocation, 0 /* dest buffer offset */, data.length);

    // Copy from GPU to CPU
    vmaCopyAllocationToMemory(allocator, allocation, 0 /* src buffer offset */, data.ptr, data.length);

    // Memory mapping
    void* mappedData;
    vmaMapMemory(allocator, allocation, &mappedData);
    vmaFlushAllocation(allocator, allocation, 0, data.length);
    vmaInvalidateAllocation(allocator, allocation, 0, data.length);
    vmaUnmapMemory(allocator, allocation);

    vmaDestroyBuffer(allocator, buffer, allocation);

    // todo - call this in the main frame loop
    vmaSetCurrentFrameIndex(allocator, 0 /* the frame number */); 
}

// todo - move this
__gshared VmaAllocator allocator;

// todo - do something similar to MemoryAllocator to make them interchangeable ?
final class VmaMemoryAllocator {
public:

protected:

private:
}
