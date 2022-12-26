module vulkan.helpers.PipelineBarrier;

import vulkan.all;

/**
 *  auto barrier = new PipelineBarrier()
 *    .stageMask(VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR, VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR)
 *    .imageBarrier()
 *        .image(myImage)
 *        .accessMasks(VK_ACCESS_SHADER_READ_BIT, VK_ACCESS_SHADER_WRITE_BIT)
 *        .layouts(VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_GENERAL)
 *        .queues(0, 1)
 *        .also((b) { b.subresourceRange.baseMipLevel = 1; })
 *        .build()
 *    .imageBarrier() ... .build()
 *    .bufferBarrier() ... .build()
 *    .memoryBarrier() ... .build()
 *    etc...
 *
 *  barrier.execute(cmd); 
 */
final class PipelineBarrier {
private:
    VkPipelineStageFlags srcStageMask;
    VkPipelineStageFlags dstStageMask;
    VkDependencyFlags _dependencyFlags;

    VkMemoryBarrier[] memoryBarriers;
    VkBufferMemoryBarrier[] bufferBarriers;
    VkImageMemoryBarrier[] imageBarriers;
public:
    this() {
        this._dependencyFlags = 0;
    }
    auto stageMasks(VkPipelineStageFlags src, VkPipelineStageFlags dst) {
        this.srcStageMask = src;
        this.dstStageMask = dst;
        return this;
    }
    auto dependencyFlags(VkDependencyFlags flags) {
        this._dependencyFlags = flags;
        return this;
    }
    void execute(VkCommandBuffer cmd) {
        vkCmdPipelineBarrier(
            cmd,
            srcStageMask,
            dstStageMask,
            _dependencyFlags,
            memoryBarriers.length.as!uint,
            memoryBarriers.ptr,
            bufferBarriers.length.as!uint,
            bufferBarriers.ptr,
            imageBarriers.length.as!uint,
            imageBarriers.ptr
        );
    }
    MemoryBarrier memoryBarrier() {
        return new MemoryBarrier(this);
    }
    BufferMemoryBarrier bufferBarrier() {
        return new BufferMemoryBarrier(this);
    }
    ImageMemoryBarrier imageBarrier() {
        return new ImageMemoryBarrier(this);
    }
}
private:
//──────────────────────────────────────────────────────────────────────────────────────────────────
final class MemoryBarrier {
private:
    PipelineBarrier pipelineBarrier;
    VkMemoryBarrier barrier;
public:
    this(PipelineBarrier pipelineBarrier) {
        this.pipelineBarrier = pipelineBarrier;
        barrier.sType = VK_STRUCTURE_TYPE_MEMORY_BARRIER;
    }
    auto accessMasks(VkAccessFlags src, VkAccessFlags dst) {
        barrier.srcAccessMask = src;
        barrier.dstAccessMask = dst;
        return this;
    }
    PipelineBarrier build() {
        pipelineBarrier.memoryBarriers ~= barrier;
        return pipelineBarrier;
    }
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
final class BufferMemoryBarrier {
private:
    PipelineBarrier pipelineBarrier;
    VkBufferMemoryBarrier barrier;
public:
    this(PipelineBarrier pipelineBarrier) {
        this.pipelineBarrier = pipelineBarrier;
        barrier.sType = VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
        barrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
        barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
    }
    auto buffer(VkBuffer b, ulong offset, ulong size) {
        barrier.buffer = b;
        barrier.offset = offset;
        barrier.size   = size;
        return this;
    }
    auto accessMasks(VkAccessFlags src, VkAccessFlags dst) {
        barrier.srcAccessMask = src;
        barrier.dstAccessMask = dst;
        return this;
    }
    auto queues(uint src, uint dst) {
        barrier.srcQueueFamilyIndex = src;
        barrier.dstQueueFamilyIndex = dst;
        return this;
    }
    PipelineBarrier build() {
        pipelineBarrier.bufferBarriers ~= barrier;
        return pipelineBarrier;
    }
}
//──────────────────────────────────────────────────────────────────────────────────────────────────
final class ImageMemoryBarrier {
private:
    PipelineBarrier pipelineBarrier;
    VkImageMemoryBarrier barrier;
public:
    this(PipelineBarrier pipelineBarrier) {
        this.pipelineBarrier = pipelineBarrier;
        barrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        barrier.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
        barrier.subresourceRange.baseMipLevel = 0;
        barrier.subresourceRange.levelCount = VK_REMAINING_MIP_LEVELS;
        barrier.subresourceRange.baseArrayLayer = 0;
        barrier.subresourceRange.layerCount = VK_REMAINING_ARRAY_LAYERS;
        barrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
        barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
    }
    auto image(VkImage image) {
        barrier.image = image;
        return this;
    }
    auto accessMasks(VkAccessFlags src, VkAccessFlags dst) {
        barrier.srcAccessMask = src;
        barrier.dstAccessMask = dst;
        return this;
    }
    auto layouts(VkImageLayout src, VkImageLayout dst) {
        barrier.oldLayout = src;
        barrier.newLayout = dst;
        return this;
    }
    auto queues(uint src, uint dst) {
        barrier.srcQueueFamilyIndex = src;
        barrier.dstQueueFamilyIndex = dst;
        return this;
    }
    /**
     * Set any uncommon properties
     */
    auto also(void delegate(ref VkImageMemoryBarrier barrier) f) {
        f(barrier);
        return this;
    }
    PipelineBarrier build() {
        pipelineBarrier.imageBarriers ~= barrier;
        return pipelineBarrier;
    }
}