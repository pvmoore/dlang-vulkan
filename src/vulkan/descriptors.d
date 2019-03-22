module vulkan.descriptors;
/**
 *  Handles common case DescriptorPool, DescriptorSetLayout
 *  and DescriptorSet usage.
 */
import vulkan.all;

//----------------------------------------------------------------
private class Descriptor {
    VDescriptorType type;
    VShaderStage stages;
    this(VDescriptorType type, VShaderStage stages) {
        this.type   = type;
        this.stages = stages;
    }
}
private final class BufferDescriptor : Descriptor {
    SubBuffer buffer;
    this(VDescriptorType type, VShaderStage stages) {
        super(type, stages);
    }
}
private class ImageDescriptor : Descriptor {
    VkImageView view;
    VImageLayout layout;
    this(VDescriptorType type, VShaderStage stages) {
        super(type, stages);
    }
}
private final class ImageSamplerDescriptor : ImageDescriptor {
    VkImageView view;
    VImageLayout layout;
    VkSampler sampler;
    this(VDescriptorType type, VShaderStage stages) {
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
    auto combinedImageSampler(VShaderStage stages) {
        descriptors ~= new ImageSamplerDescriptor(
            VDescriptorType.COMBINED_IMAGE_SAMPLER,
            stages
        );
        return this;
    }
    auto sampledImage(VShaderStage stages) {
        descriptors ~= new ImageDescriptor(
            VDescriptorType.SAMPLED_IMAGE,
            stages
        );
        return this;
    }
    auto storageImage(VShaderStage stages) {
        descriptors ~= new ImageDescriptor(
            VDescriptorType.STORAGE_IMAGE,
            stages
        );
        return this;
    }
    auto storageBuffer(VShaderStage stages) {
        descriptors ~= new BufferDescriptor(
            VDescriptorType.STORAGE_BUFFER,
            stages
        );
        return this;
    }
    auto uniformBuffer(VShaderStage stages) {
        descriptors ~= new BufferDescriptor(
            VDescriptorType.UNIFORM_BUFFER,
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
    auto add(VkImageView v, VImageLayout l) {
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
    auto add(VkSampler s, VkImageView v, VImageLayout l) {
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
    auto write() {
        log("Descriptors: writes %s", writes);
        device.updateDescriptorSets(writes, null /* copies */);
        return set;
    }
}
//----------------------------------------------------------------
/**
 *  d = new Descriptors(vk)
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
 *  d.layouts
 *
 */
final class Descriptors {
private:
    Vulkan vk;
    VkDevice device;
    VkDescriptorPool pool;
    Layout[] _layouts;
public:
    VkDescriptorSetLayout[] layouts;

    this(Vulkan vk) {
        this.vk      = vk;
        this.device  = vk.device;
    }
    void destroy() {
        foreach(l; layouts) device.destroy(l);
        if(pool) device.destroy(pool);
    }
    auto createLayout() {
        auto l = new Layout(this);
        _layouts ~= l;
        return l;
    }
    auto build() {
        createPool();
        createLayouts();
        return this;
    }
    auto createSetFromLayout(uint layoutIndex = 0) {
        expect(layouts.length>layoutIndex);
        auto ds = device.allocDescriptorSet(
            pool,
            layouts[layoutIndex]
        );
        return new Set(device, _layouts[layoutIndex], ds);
    }
private:
    void createPool() {
        VkDescriptorPoolSize[VDescriptorType] sizes;
        uint maxSets;

        foreach(l; _layouts) {
            foreach(d; l.descriptors) {
                auto v = sizes.get(d.type, VkDescriptorPoolSize(d.type,0));
                v.descriptorCount += l.maxSets;
                sizes[d.type] = v;
            }
            maxSets += l.maxSets;
        }
        log("Descriptors: pool sizes=%s", sizes.values);
        pool = device.createDescriptorPool(sizes.values, maxSets);
    }
    void createLayouts() {
        foreach(l; _layouts) {
            VkDescriptorSetLayoutBinding[] bindings;
            foreach(index, d; l.descriptors) {
                auto i = index.as!uint;
                switch(d.type) with(VDescriptorType) {
                    case COMBINED_IMAGE_SAMPLER:
                        bindings ~= samplerBinding(i, d.stages);
                        break;
                    case STORAGE_IMAGE:
                        bindings ~= storageImageBinding(i, d.stages);
                        break;
                    case STORAGE_BUFFER:
                        bindings ~= storageBufferBinding(i, d.stages);
                        break;
                    case UNIFORM_BUFFER:
                        bindings ~= uniformBufferBinding(i, d.stages);
                        break;
                    default:
                        expect(false); break;
                }
            }
            layouts ~= device.createDescriptorSetLayout(bindings);
            log("Descriptors: layout bindings=%s", bindings);
        }

        //dsLayout = device.createDescriptorSetLayout([
        //    uniformBufferBinding(0, VShaderStage.VERTEX),
        //    samplerBinding(1, VShaderStage.FRAGMENT)
        //]);
    }
}

