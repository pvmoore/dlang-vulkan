module vulkan.api.descriptor;
/**
 * https://www.khronos.org/registry/vulkan/specs/1.0/man/html/VkDescriptorSetAllocateInfo.html
 */
import vulkan.all;

/*=================================================================================
 *  VkDescriptorPool
 ================================================================================*/
auto createDescriptorPool(VkDevice device, VkDescriptorPoolSize[] sizes, uint maxSets) {
    VkDescriptorPool pool;
    VkDescriptorPoolCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO;

    // VkDescriptorPoolCreateFlagBits.VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT
    info.flags = 0;

    info.maxSets        = maxSets;
    info.poolSizeCount  = cast(uint)sizes.length;
    info.pPoolSizes     = sizes.ptr;

    check(vkCreateDescriptorPool(device, &info, null, &pool));
    return pool;
}
void destroy(VkDevice device, VkDescriptorPool pool) {
    vkDestroyDescriptorPool(device, pool, null);
}
void resetDescriptorPool(VkDevice device, VkDescriptorPool pool) {
    auto flags = 0; // reserved
    check(vkResetDescriptorPool(device, pool, flags));
}
auto descriptorPoolSize(VkDescriptorType type, uint count) {
    VkDescriptorPoolSize s;
    s.type            = type;
    s.descriptorCount = count;
    return s;
}
/*=================================================================================
 *  VkDescriptorSet
 ================================================================================*/
auto allocDescriptorSet(VkDevice device, VkDescriptorPool pool, VkDescriptorSetLayout layout) {
    return allocDescriptorSets(device,pool, [layout])[0];
}
auto allocDescriptorSets(VkDevice device, VkDescriptorPool pool, VkDescriptorSetLayout[] layouts) {
    // todo - is sets count same as layouts.length?
    VkDescriptorSet[] sets = new VkDescriptorSet[layouts.length];

    VkDescriptorSetAllocateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
    info.descriptorPool     = pool;

    info.descriptorSetCount = cast(uint)layouts.length;
    info.pSetLayouts        = layouts.ptr;

    check(vkAllocateDescriptorSets(device, &info, sets.ptr));
    return sets;
}
void freeDescriptorSets(VkDevice device, VkDescriptorPool pool, VkDescriptorSet[] sets) {
    check(vkFreeDescriptorSets(device, pool, cast(uint)sets.length, sets.ptr));
}
void updateDescriptorSets(VkDevice device, VkWriteDescriptorSet[] writes, VkCopyDescriptorSet[] copies) {
    vkUpdateDescriptorSets(device, cast(uint)writes.length, writes.ptr, cast(uint)copies.length, copies.ptr);
}
auto writeBuffer(VkDescriptorSet set,
                 uint binding,
                 VkDescriptorType type,
                 VkDescriptorBufferInfo[] bufferInfos,
                 uint arrayElement=0)
{
    VkWriteDescriptorSet w;
    w.sType  = VkStructureType.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;

    w.dstSet          = set;
    w.dstBinding      = binding;
    w.dstArrayElement = arrayElement;

    w.descriptorType  = type;

    w.descriptorCount   = cast(uint)bufferInfos.length;
    w.pBufferInfo       = bufferInfos.ptr;
    w.pImageInfo        = null;
    w.pTexelBufferView  = null;
    return w;
}
auto writeImage(VkDescriptorSet set,
                uint binding,
                VkDescriptorType type,
                VkDescriptorImageInfo[] imageInfos,
                uint arrayElement=0)
{
    VkWriteDescriptorSet w;
    w.sType  = VkStructureType.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;

    w.dstSet          = set;
    w.dstBinding      = binding;
    w.dstArrayElement = arrayElement;

    w.descriptorType  = type;

    w.descriptorCount   = cast(uint)imageInfos.length;
    w.pBufferInfo       = null;
    w.pImageInfo        = imageInfos.ptr;
    w.pTexelBufferView  = null;
    return w;
}
pragma(inline,true)
auto descriptorBufferInfo(VkBuffer buffer, ulong offset, ulong size) {
    VkDescriptorBufferInfo info;
    info.buffer = buffer;
    info.offset = offset;
    info.range  = size; // VK_WHOLE_SIZE
    return info;
}
pragma(inline,true)
auto descriptorImageInfo(VkSampler sampler, VkImageView view, VkImageLayout layout) {
    VkDescriptorImageInfo info;
    info.sampler     = sampler;
    info.imageView   = view;
    info.imageLayout = layout;
    return info;
}
/*=================================================================================
 *  VkDescriptorSetLayout
 ================================================================================*/
auto createDescriptorSetLayout(VkDevice device, VkDescriptorSetLayoutBinding[] bindings) {
    VkDescriptorSetLayout layout;
    VkDescriptorSetLayoutCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
    info.flags = 0;

    info.bindingCount = cast(uint)bindings.length;
    info.pBindings    = bindings.ptr;

    check(vkCreateDescriptorSetLayout(device, &info, null, &layout));
    return layout;
}
void destroy(VkDevice device, VkDescriptorSetLayout layout) {
    vkDestroyDescriptorSetLayout(device, layout, null);
}
auto samplerBinding(uint index, VkShaderStageFlags stages) {
    return descriptorSetLayoutBinding(
        index,
        VDescriptorType.COMBINED_IMAGE_SAMPLER,
        1,
        stages,
        null);
}
auto uniformBufferBinding(uint index, VkShaderStageFlags stages) {
    return descriptorSetLayoutBinding(
        index,
        VDescriptorType.UNIFORM_BUFFER,
        1,
        stages,
        null);
}
auto storageBufferBinding(uint index, VkShaderStageFlags stages) {
    return descriptorSetLayoutBinding(
        index,
        VDescriptorType.STORAGE_BUFFER,
        1,
        stages,
        null);
}
auto storageImageBinding(uint index, VkShaderStageFlags stages) {
    return descriptorSetLayoutBinding(
        index,
        VDescriptorType.STORAGE_IMAGE,
        1,
        stages,
        null);
}
auto descriptorSetLayoutBinding(
    uint bindingIndex,
    VkDescriptorType type,
    uint count,
    VkShaderStageFlags stageFlags, // can be multiple stages
    VkSampler[] samplers)
{
    VkDescriptorSetLayoutBinding b;
    b.binding            = bindingIndex;
    b.descriptorType     = type;
    b.descriptorCount    = count;
    b.stageFlags         = stageFlags;
    b.pImmutableSamplers = samplers.ptr;
    return b;
}
