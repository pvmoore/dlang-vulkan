module vulkan.helpers.Descriptors;
/**
 *  Handles common case DescriptorPool, DescriptorSetLayout
 *  and DescriptorSet usage.
 */
import vulkan.all;

//----------------------------------------------------------------
private class Descriptor {
    VkDescriptorType type;
    VkShaderStageFlags stages;
    this(VkDescriptorType type, VkShaderStageFlags stages) {
        this.type   = type;
        this.stages = stages;
    }
}
private final class BufferDescriptor : Descriptor {
    SubBuffer buffer;
    this(VkDescriptorType type, VkShaderStageFlags stages) {
        super(type, stages);
    }
}
private class ImageDescriptor : Descriptor {
    VkImageView view;
    VkImageLayout layout;
    this(VkDescriptorType type, VkShaderStageFlags stages) {
        super(type, stages);
    }
}
private final class ImageSamplerDescriptor : ImageDescriptor {
    VkImageView view;
    VkImageLayout layout;
    VkSampler sampler;
    this(VkDescriptorType type, VkShaderStageFlags stages) {
        super(type, stages);
    }
}
private final class AccelerationStructureDescriptor : Descriptor {
    this(VkDescriptorType type, VkShaderStageFlags stages) {
        super(type, stages);
    }
}
//----------------------------------------------------------------
private final class Layout {
    Descriptors desc;
    Descriptor[] descriptors;
    uint maxSets;

    this(Descriptors d) {
        this.desc = d;
    }
    auto combinedImageSampler(VkShaderStageFlags stages) {
        descriptors ~= new ImageSamplerDescriptor(
            VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
            stages
        );
        return this;
    }
    auto sampledImage(VkShaderStageFlags stages) {
        descriptors ~= new ImageDescriptor(
            VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
            stages
        );
        return this;
    }
    auto storageImage(VkShaderStageFlags stages) {
        descriptors ~= new ImageDescriptor(
            VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
            stages
        );
        return this;
    }
    auto storageBuffer(VkShaderStageFlags stages) {
        descriptors ~= new BufferDescriptor(
            VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
            stages
        );
        return this;
    }
    auto uniformBuffer(VkShaderStageFlags stages) {
        descriptors ~= new BufferDescriptor(
            VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
            stages
        );
        return this;
    }
    auto accelerationStructure(VkShaderStageFlags stages) {
        descriptors ~= new AccelerationStructureDescriptor(
            VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR,
            stages
        );
        return this;
    }
    Descriptors sets(uint maxSets) {
        this.maxSets = maxSets;
        return desc;
    }
}
//----------------------------------------------------------------
private final class Set {
    VkDevice device;
    Layout layout;
    VkDescriptorSet set;
    VkWriteDescriptorSet[] writes;

    this(VkDevice device, Layout layout, VkDescriptorSet set) {
        this.device = device;
        this.layout = layout;
        this.set    = set;
    }
    auto add(VkAccelerationStructureKHR as) {
        int binding  = cast(int)writes.length;
        Descriptor d = layout.descriptors[binding];

        // Tidy this later
        auto array = new VkAccelerationStructureKHR[1];
        array[0] = as;

        writes ~= writeAccelerationStructure(set, binding, array);
        return this;
    }
    auto add(VkImageView v, VkImageLayout l) {
        int binding  = cast(int)writes.length;
        Descriptor d = layout.descriptors[binding];
        writes ~= set.writeImage(
            binding,
            d.type,
            [
                descriptorImageInfo(null, v, l)
            ]
        );
        return this;
    }
    auto add(VkSampler s, VkImageView v, VkImageLayout l) {
        int binding  = cast(int)writes.length;
        Descriptor d = layout.descriptors[binding];
        writes ~= set.writeImage(
            binding,
            d.type,
            [
                descriptorImageInfo(s, v, l)
            ]
        );
        return this;
    }
    auto add(VkBuffer b, ulong offset, ulong size) {
        int binding  = cast(int)writes.length;
        Descriptor d = layout.descriptors[binding];
        writes ~= set.writeBuffer(
            binding,
            d.type,
            [
                descriptorBufferInfo(b, offset, size)
            ]
        );
        return this;
    }
    auto add(DeviceBuffer b) {
        return add(b.handle, 0, b.size);
    }
    auto add(SubBuffer b) {
        return add(b.handle(), b.offset, b.size);
    }
    auto add(T)(GPUData!T data, uint frameIndex = 0) {
        auto b = data.getDeviceBuffer(frameIndex);
        return add(b.handle(), b.offset, data.numBytes);
    }
    auto add(T)(StaticGPUData!T rbuf) {
        this.log("Adding %s (%s bytes)", rbuf.name, rbuf.numBytes());
        auto b = rbuf.getBuffer();
        this.log("VkBuffer size = %s", b.size);
        return add(b.handle, 0, rbuf.numBytes());
    }
    void write() {
        this.log("Writing descriptor set:");
        foreach(w; writes) {
            this.log(" - %s", .toString(w));
        }
        device.updateDescriptorSets(writes, null /* copies */);
    }
}

string toString(VkWriteDescriptorSet w) {
    return ("dstSet: 0x%x " ~
	        "dstBinding: %s " ~
            "dstArrayElement: %s " ~
            "descriptorCount: %s " ~
	        "descriptorType: %s " ~
	        "pImageInfo: %s " ~
	        "pBufferInfo: %s " ~
	        "pTexelBufferView: %s").format(
                w.dstSet,
                w.dstBinding,
                w.dstArrayElement,
                w.descriptorCount,
                w.descriptorType,
                w.pImageInfo ? (*w.pImageInfo).toString() : "null",
                w.pBufferInfo ? (*w.pBufferInfo).toString() : "null",
                w.pTexelBufferView
            );
}
string toString(VkDescriptorBufferInfo b) {
    return ("(buffer: 0x%x " ~
	        "offset: %s " ~
	        "range: %s)").format(
                b.buffer,
                b.offset,
                b.range
            );
}
string toString(VkDescriptorImageInfo i) {
    return ("(sampler: 0x%x " ~
	        "imageView: 0x%x " ~
	        "imageLayout: %s)").format(
                i.sampler,
                i.imageView,
                i.imageLayout
            );
}
//----------------------------------------------------------------
/**
 *  auto d = new Descriptors(vk)
 *         .createLayout()
 *              .storageImage(VShaderStage.FRAGMENT)
 *              .storageBuffer(VShaderStage.FRAGMENT)
 *              .combinedImageSampler(VShaderStage.FRAGMENT)
 *              .uniformBuffer(VShaderStage.VERTEX)
 *              .sets(1)
 *         .createLayout()
 *              .uniformBuffer(VShaderStage.FRAGMENT)
 *              .sets(1)
 *         .build()
 *
 *  d.createSetFromLayout(0)
 *      .add(view, layout)
 *      .add(buffer, offset, size)
 *      .add(sampler, view, layout)
 *      .add(buffer, offset, size)
 *      .write()
 *  d.createSetFromLayout(1)
 *      .add(buffer, offset, size)
 *      .write()
 *
 *  d.getSet(0, 0)
 *
 *  d.getAllLayouts()
 */
final class Descriptors {
private:
    VulkanContext context;
    VkDevice device;
    VkDescriptorPool pool;
    Layout[] _layouts;
    Set[][] _sets;
    VkDescriptorSetLayout[] _dsLayouts;
public:
    auto getAllLayouts() { return _dsLayouts; }
    auto getSet(uint layoutIndex, uint setIndex) { return _sets[layoutIndex][setIndex].set; }

    this(VulkanContext context) {
        this.context = context;
        this.device  = context.device;
    }
    void destroy() {
        foreach(l; _dsLayouts) device.destroyDescriptorSetLayout(l);
        _dsLayouts = null;
        _layouts = null;
        _sets = null;
        if(pool) device.destroyDescriptorPool(pool);
    }
    auto createLayout() {
        auto l = new Layout(this);
        _layouts ~= l;
        _sets.length++;
        return l;
    }
    auto build() {
        createPool();
        createLayouts();
        return this;
    }
    auto createSetFromLayout(uint layoutIndex) {
        throwIf(layoutIndex >= _dsLayouts.length);
        auto ds = device.allocDescriptorSet(
            pool,
            _dsLayouts[layoutIndex]
        );
        auto set = new Set(device, _layouts[layoutIndex], ds);

        _sets[layoutIndex] ~= set;

        return set;
    }
private:
    void createPool() {
        VkDescriptorPoolSize[VkDescriptorType] sizes;
        uint maxSets;

        foreach(l; _layouts) {
            foreach(d; l.descriptors) {
                auto v = sizes.get(d.type, VkDescriptorPoolSize(d.type,0));
                v.descriptorCount += l.maxSets;
                sizes[d.type] = v;
            }
            maxSets += l.maxSets;
        }
        this.log("pool sizes=%s", sizes.values);
        pool = device.createDescriptorPool(sizes.values, maxSets);
    }
    void createLayouts() {
        foreach(l; _layouts) {
            VkDescriptorSetLayoutBinding[] bindings;
            foreach(index, d; l.descriptors) {
                auto i = index.as!uint;
                switch(d.type) with(VkDescriptorType) {
                    case VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER:
                        bindings ~= samplerBinding(i, d.stages);
                        break;
                    case VK_DESCRIPTOR_TYPE_STORAGE_IMAGE:
                        bindings ~= storageImageBinding(i, d.stages);
                        break;
                    case VK_DESCRIPTOR_TYPE_STORAGE_BUFFER:
                        bindings ~= storageBufferBinding(i, d.stages);
                        break;
                    case VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER:
                        bindings ~= uniformBufferBinding(i, d.stages);
                        break;
                    case VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR:
                        bindings ~= accelerationStructureBinding(i, d.stages);
                        break;
                    default:
                        throwIf(true, "VDescriptorType not implemented %s".format(d.type)); break;
                }
            }
            _dsLayouts ~= device.createDescriptorSetLayout(bindings);
            this.log("layout bindings=%s", bindings);
        }

        //dsLayout = device.createDescriptorSetLayout([
        //    uniformBufferBinding(0, VShaderStage.VERTEX),
        //    samplerBinding(1, VShaderStage.FRAGMENT)
        //]);
    }
}

