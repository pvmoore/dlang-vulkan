module vulkan.queue_family;

import vulkan.all;

struct QueueFamily {
    int graphics;   // assume this can also present the surface
    int compute;
    int transfer;
}

final class QueueFamilySelector {
private:
    VkPhysicalDevice physicalDevice;
    VkSurfaceKHR surface;
    VkQueueFamilyProperties[] properties;
public:
    this(VkPhysicalDevice physicalDevice, VkSurfaceKHR surface, VkQueueFamilyProperties[] properties) {
        this.physicalDevice = physicalDevice;
        this.surface        = surface;
        this.properties     = properties;
    }
    bool isGraphics(uint f) {
        return cast(bool)(f & VkQueueFlagBits.VK_QUEUE_GRAPHICS_BIT);
    }
    bool isCompute(uint f) {
        return cast(bool)(f & VkQueueFlagBits.VK_QUEUE_COMPUTE_BIT);
    }
    bool isTransfer(uint f) {
        return cast(bool)(f & VkQueueFlagBits.VK_QUEUE_TRANSFER_BIT);
    }
    bool canPresent(uint f) {
        if(!surface) return false;
        return physicalDevice.canPresent(surface, f);
    }

    VkQueueFlagBits graphics()      { return VkQueueFlagBits.VK_QUEUE_GRAPHICS_BIT; }
    VkQueueFlagBits compute()       { return VkQueueFlagBits.VK_QUEUE_COMPUTE_BIT; }
    VkQueueFlagBits transfer()      { return VkQueueFlagBits.VK_QUEUE_TRANSFER_BIT; }
    VkQueueFlagBits sparseBinding() { return VkQueueFlagBits.VK_QUEUE_SPARSE_BINDING_BIT; }

    /**
     *  @return the first family with the given flags, or -1 if none found
     */
    int findFirstWith(VkQueueFlagBits flags) {
        uint[] matches = findAllWith(flags);
        if(matches.length>0) return matches[0];
        return -1;
    }
    /**
     *  @return all families with the given flags
     */
    uint[] findAllWith(VkQueueFlagBits flags) {
        uint[] matches;
        foreach(i, f; properties) {
            if(f.queueCount==0) continue;

            if((f.queueFlags & flags)==flags) {
                matches ~= i.as!uint;
            }
        }
        return matches;
    }
}