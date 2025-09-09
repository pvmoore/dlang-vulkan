module vulkan.helpers.QueueManager;

import vulkan.all;

struct QueueFamily {
    enum NONE = QueueFamily(-1);
    uint index;
}
struct FamilyAndCount { 
    enum NONE = FamilyAndCount(-1, 0);
    uint family; 
    uint count; 
}

final class QueueManager {
private:
    VkPhysicalDevice physicalDevice;
    VkSurfaceKHR surface;
    VkQueueFamilyProperties[] props;

    FamilyAndCount[string] _labelToRequest;
    QueueFamily[string] _labelToFamily;
    VkQueue[][string] _labelToQueues;
    VkQueue[][uint] _familyIndexToQueues;
public:
    enum GRAPHICS = "__GRAPHICS__";
    enum TRANSFER = "__TRANSFER__";
    enum COMPUTE  = "__COMPUTE__";

    VkQueueFlagBits graphics()      { return VkQueueFlagBits.VK_QUEUE_GRAPHICS_BIT; }
    VkQueueFlagBits compute()       { return VkQueueFlagBits.VK_QUEUE_COMPUTE_BIT; }
    VkQueueFlagBits transfer()      { return VkQueueFlagBits.VK_QUEUE_TRANSFER_BIT; }
    VkQueueFlagBits sparseBinding() { return VkQueueFlagBits.VK_QUEUE_SPARSE_BINDING_BIT; }

    bool supportsGraphics(QueueFamily f) { return 0 != (props[f.index].queueFlags & graphics()); }
    bool supportsTransfer(QueueFamily f) { return 0 != (props[f.index].queueFlags & transfer()); }
    bool supportsCompute(QueueFamily f) { return 0 != (props[f.index].queueFlags & compute()); }
    bool supportsSparseBinding(QueueFamily f) { return 0 != (props[f.index].queueFlags & sparseBinding()); }

    bool supportsGraphics(FamilyAndCount f) { return supportsGraphics(f.family.as!QueueFamily); }
    bool supportsTransfer(FamilyAndCount f) { return supportsTransfer(f.family.as!QueueFamily); }
    bool supportsCompute(FamilyAndCount f) { return supportsCompute(f.family.as!QueueFamily); }
    bool supportsSparseBinding(FamilyAndCount f) { return supportsSparseBinding(f.family.as!QueueFamily); }

    this(VkPhysicalDevice physicalDevice, VkSurfaceKHR surface, VkQueueFamilyProperties[] props) {
        this.physicalDevice = physicalDevice;
        this.surface = surface;
        this.props = props;
    }

    void request(string label, FamilyAndCount familyAndCount) {
        request(label, familyAndCount.family.as!QueueFamily, familyAndCount.count);
    }
    void request(string label, QueueFamily family, uint numQueues) {
        throwIf((label in _labelToRequest) !is null);
        throwIf(numQueues > props[family.index].queueCount);

        _labelToFamily[label] = family;
        _labelToRequest[label] = FamilyAndCount(family.index, numQueues);

        this.verbose("[%s] Requesting %s queues from queue family %s %s", label, numQueues, family, .toString!VkQueueFlagBits(props[family.index].queueFlags, "VK_QUEUE_", "_BIT"));
    }
    /** Return a list of family indexes and the requested number of queues for that family */
    Tuple!(uint,uint)[] getAllRequestedQueues() {
        Tuple!(uint,uint)[] res;

        uint[uint] map = getRequiredNumQueuesPerFamily();

        foreach(f, c; map) {
            res ~= tuple(f, c);
        }
        this.verbose("map = %s", map);
        this.verbose("all requested queues = %s", res);
        return res;
    }

    void onDeviceCreated(VkDevice device) {
        throwIf(_familyIndexToQueues.length != 0);
        uint[uint] map = getRequiredNumQueuesPerFamily();

        /** Get all created queues from device */
        foreach(f,c; map) {
            VkQueue[] queues;
            foreach(i; 0..c) {
                queues ~= device.getQueue(f, i);
            }
            _familyIndexToQueues[f] = queues;
        }

        foreach(l, i; _labelToFamily) {
            _labelToQueues[l] = _familyIndexToQueues[i.index];
        }
    }

    QueueFamily getFamily(string label) {
        return _labelToFamily[label];
    }

    VkQueue getQueue(string label, uint queueIndex = 0) {
        VkQueue[] queues = _labelToQueues[label];
        throwIf(queueIndex >= queues.length);
        return queues[queueIndex];
    }
    /**
     *  @return the first family with the given flags, or NO_QUEUE_FAMILY if none found
     */
    FamilyAndCount findFirstWith(VkQueueFlagBits flags, uint[] excludingFamilies = null, uint minQueueCount = 1) {
        FamilyAndCount[] matches = findQueueFamilies(flags, 0.as!VkQueueFlagBits, excludingFamilies, minQueueCount);
        if(matches.length>0) return matches[0];
        return FamilyAndCount.NONE;
    }
    /**
     *  @return all families with _includeFlags_ flags
     *                       without _excludeFlags_ flags
     *                       with at least _minQueueCount_ queues
     *                       not including _excludingFamilies_ families
     */
    FamilyAndCount[] findQueueFamilies(VkQueueFlagBits includeFlags,
                                       VkQueueFlagBits excludeFlags = 0.as!VkQueueFlagBits,
                                       uint[] excludeFamilies = null,
                                       uint minQueueCount = 1)
    {
        FamilyAndCount[] matches;
        foreach(i, f; props) {
            if(f.queueCount < minQueueCount) continue;
            if(i.as!uint.isOneOf(excludeFamilies)) continue;
            if((f.queueFlags & excludeFlags)!=0) continue;

            if((f.queueFlags & includeFlags)==includeFlags) {
                matches ~= FamilyAndCount(i.as!uint, f.queueCount);
            }
        }
        return matches;
    }
private:
    uint[uint] getRequiredNumQueuesPerFamily() {
        uint[uint] map;

        foreach(FamilyAndCount v; _labelToRequest.values()) {
            auto p = v.family in map;
            if(p) {
                *p = maxOf(*p, v.count);
            } else {
                map[v.family] = v.count;
            }
        }
        return map;
    }
}
