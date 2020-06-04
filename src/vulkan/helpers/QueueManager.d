module vulkan.helpers.QueueManager;

import vulkan.all;

struct QueueFamily {
    enum NONE = QueueFamily(-1);
    uint index;
}

final class QueueManager {
private:
    struct FamilyAndCount { uint index; uint count; }
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

    this(VkPhysicalDevice physicalDevice, VkSurfaceKHR surface, VkQueueFamilyProperties[] props) {
        this.physicalDevice = physicalDevice;
        this.surface = surface;
        this.props = props;
    }

    void request(string label, QueueFamily family, uint numQueues) {
        expect(label !in _labelToRequest);
        expect(props[family.index].queueCount >= numQueues);

        _labelToFamily[label] = family;
        _labelToRequest[label] = FamilyAndCount(family.index, numQueues);

        this.log("[%s] Requesting %s queues from queue family %s %s", label, numQueues, family, toArray!VkQueueFlagBits(props[family.index].queueFlags));
    }
    /** Return a list of family indexes and the requested number of queues for that family */
    Tuple!(uint,uint)[] getAllRequestedQueues() {
        Tuple!(uint,uint)[] res;

        uint[uint] map = getRequiredNumQueuesPerFamily();

        foreach(f, c; map) {
            res ~= tuple(f, c);
        }
        this.log("map = %s", map);
        this.log("all requested queues = %s", res);
        return res;
    }

    void onDeviceCreated(VkDevice device) {
        expect(_familyIndexToQueues.length==0);
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
        expect(queueIndex < queues.length);
        return queues[queueIndex];
    }
    /**
     *  @return the first family with the given flags, or NO_QUEUE_FAMILY if none found
     */
    QueueFamily findFirstWith(VkQueueFlagBits flags, QueueFamily[] excludingFamilies = null) {
        QueueFamily[] matches = findQueueFamilies(flags, 0.as!VkQueueFlagBits, excludingFamilies);
        if(matches.length>0) return matches[0];
        return QueueFamily.NONE;
    }
    /**
     *  @return all families with _includeFlags_ flags
     *                       without _excludeFlags_ flags
     *                       not including _excludingFamilies_ families
     */
    QueueFamily[] findQueueFamilies(VkQueueFlagBits includeFlags,
                                    VkQueueFlagBits excludeFlags = 0.as!VkQueueFlagBits,
                                    QueueFamily[] excludeFamilies = null)
    {
        QueueFamily[] matches;
        foreach(i, f; props) {
            if(f.queueCount==0) continue;
            if(QueueFamily(i.as!uint).isOneOf(excludeFamilies)) continue;
            if((f.queueFlags & excludeFlags)!=0) continue;

            if((f.queueFlags & includeFlags)==includeFlags) {
                matches ~= QueueFamily(i.as!uint);
            }
        }
        return matches;
    }
private:
    uint[uint] getRequiredNumQueuesPerFamily() {
        uint[uint] map;

        foreach(v; _labelToRequest.values()) {
            auto p = v.index in map;
            if(p) {
                *p = maxOf(*p, v.count);
            } else {
                map[v.index] = v.count;
            }
        }
        return map;
    }
}
