module vulkan.api.command_buffer;
/**
 *
 *  https://cdp.packtpub.com/learningvulkan/chapter/command-buffer-and-memory-management-in-vulkan/
 *
 */
import vulkan.all;

VkCommandBuffer allocFrom(VkDevice device, VkCommandPool pool) {
    VkCommandBuffer[] buffers = allocFrom(device, pool, 1, VkCommandBufferLevel.VK_COMMAND_BUFFER_LEVEL_PRIMARY);
    return buffers[0];
}
VkCommandBuffer allocSecondaryFrom(VkDevice device, VkCommandPool pool) {
    VkCommandBuffer[] buffers = allocFrom(device, pool, 1, VkCommandBufferLevel.VK_COMMAND_BUFFER_LEVEL_SECONDARY);
    return buffers[0];
}
VkCommandBuffer[] allocFrom(
    VkDevice device,
    VkCommandPool pool,
    uint num,
    VkCommandBufferLevel level)
{
    VkCommandBuffer[] buffers;
    buffers.length = num;

    VkCommandBufferAllocateInfo info;
    info.sType       = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    info.commandPool = pool;
    info.level       = level;
    info.commandBufferCount = num;

    check(vkAllocateCommandBuffers(device, &info, buffers.ptr));
    return buffers;
}
void free(VkDevice device, VkCommandPool pool, VkCommandBuffer buffer) {
    vkFreeCommandBuffers(device, pool, 1, &buffer);
}
void free(VkDevice device, VkCommandPool pool, VkCommandBuffer[] buffers) {
    vkFreeCommandBuffers(device, pool, cast(uint)buffers.length, buffers.ptr);
}
void beginSimultaneous(VkCommandBuffer buffer) {
    begin(buffer, VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT);
}
void beginOneTimeSubmit(VkCommandBuffer buffer) {
    buffer.begin(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT);
}
void begin(VkCommandBuffer buffer) {
    buffer.begin(VK_COMMAND_BUFFER_USAGE_NONE);
}
void begin(
    VkCommandBuffer buffer,
    VkCommandBufferUsageFlags flags,
    VkCommandBufferInheritanceInfo* inheritanceInfo=null)
{
    VkCommandBufferBeginInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
    with(VkCommandBufferUsageFlagBits) {
        // Each recording of the command buffer will only be submitted once
        // VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT

        // A secondary command buffer is considered to be entirely inside a render pass
        // VK_COMMAND_BUFFER_USAGE_RENDER_PASS_CONTINUE_BIT

        // Allows the command buffer to be resubmitted to a queue while it is in the pending state
        // VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT
        info.flags = flags;
    }
    info.pInheritanceInfo = inheritanceInfo;

    check(vkBeginCommandBuffer(buffer, &info));
}
void end(VkCommandBuffer buffer) {
    check(vkEndCommandBuffer(buffer));
}
/**
 *  Only call reset if VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT was
 *  set on the pool.
 */
void reset(VkCommandBuffer buffer, bool releaseResources) {
    VkCommandBufferResetFlags flags;
    if(releaseResources) {
        flags |= VkCommandBufferResetFlagBits.VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT;
    }
    check(vkResetCommandBuffer(buffer, flags));
}
void bindPipeline(VkCommandBuffer buffer, GraphicsPipeline p) {
    bindGraphicsPipeline(buffer, p.pipeline);
}
void bindPipeline(VkCommandBuffer buffer, ComputePipeline p) {
    bindComputePipeline(buffer, p.pipeline);
}
private void bindGraphicsPipeline(VkCommandBuffer buffer, VkPipeline pipeline) {
    vkCmdBindPipeline(buffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS, pipeline);
}
private void bindComputePipeline(VkCommandBuffer buffer, VkPipeline pipeline) {
    vkCmdBindPipeline(buffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_COMPUTE, pipeline);
}
void setViewport(VkCommandBuffer buffer, uint first, VkViewport[] viewports) {
    vkCmdSetViewport(buffer, first, cast(uint)viewports.length, viewports.ptr);
}
void setScissor(VkCommandBuffer buffer, uint first, VkRect2D[] scissors) {
    vkCmdSetScissor(buffer, first, cast(uint)scissors.length, scissors.ptr);
}
void setLineWidth(VkCommandBuffer buffer, float width) {
    vkCmdSetLineWidth(buffer, width);
}
void setDepthBias(VkCommandBuffer buffer, float depthBiasConstantFactor, float depthBiasClamp, float depthBiasSlopeFactor) {
    vkCmdSetDepthBias(buffer, depthBiasConstantFactor, depthBiasClamp, depthBiasSlopeFactor);
}
void setBlendConstants(VkCommandBuffer buffer, float[4] constants) {
    vkCmdSetBlendConstants(buffer, constants);
}
void setDepthBounds(VkCommandBuffer buffer, float minDepthBounds, float maxDepthBounds) {
    vkCmdSetDepthBounds(buffer, minDepthBounds, maxDepthBounds);
}
void setStencilCompareMask(VkCommandBuffer buffer, VkStencilFaceFlags faceMask, uint compareMask) {
    vkCmdSetStencilCompareMask(buffer, faceMask, compareMask);
}
void setStencilWriteMask(VkCommandBuffer buffer, VkStencilFaceFlags faceMask, uint writeMask) {
    vkCmdSetStencilWriteMask(buffer, faceMask, writeMask);
}
void setStencilReference(VkCommandBuffer buffer, VkStencilFaceFlags faceMask, uint reference) {
    vkCmdSetStencilReference(buffer, faceMask, reference);
}
void bindDescriptorSets(VkCommandBuffer buffer,
                        VkPipelineBindPoint pipelineBindPoint,
                        VkPipelineLayout layout,
                        uint firstSet,
                        VkDescriptorSet[] descriptorSets,
                        uint[] dynamicOffsets)
{
    vkCmdBindDescriptorSets(buffer, pipelineBindPoint, layout, firstSet,
        cast(uint)descriptorSets.length, descriptorSets.ptr,
        cast(uint)dynamicOffsets.length, dynamicOffsets.ptr);
}
void bindIndexBuffer(VkCommandBuffer cmdbuffer, VkBuffer buffer, ulong offset, bool useShorts=true) {
    auto indexType = useShorts ? VkIndexType.VK_INDEX_TYPE_UINT16
                               : VkIndexType.VK_INDEX_TYPE_UINT32;
    vkCmdBindIndexBuffer(cmdbuffer, buffer, offset, indexType);
}
void bindVertexBuffers(VkCommandBuffer buffer, uint firstBinding, VkBuffer[] buffers, ulong[] offsets) {
    vkassert(buffers.length==offsets.length);
    vkCmdBindVertexBuffers(buffer, firstBinding, cast(uint)buffers.length, buffers.ptr, offsets.ptr);
}
void draw(VkCommandBuffer buffer, uint vertexCount, uint instanceCount, uint firstVertex, uint firstInstance) {
    vkCmdDraw(buffer, vertexCount, instanceCount, firstVertex, firstInstance);
}
void drawIndexed(VkCommandBuffer buffer, uint indexCount, uint instanceCount, uint firstIndex, int vertexOffset, uint firstInstance) {
    vkCmdDrawIndexed(buffer, indexCount, instanceCount, firstIndex, vertexOffset, firstInstance);
}
void drawIndirect(VkCommandBuffer cmdbuffer, VkBuffer buffer, ulong offset, uint drawCount, uint stride) {
    vkCmdDrawIndirect(cmdbuffer, buffer, offset, drawCount, stride);
}
void drawIndexedIndirect(VkCommandBuffer cmdbuffer, VkBuffer buffer, ulong offset, uint drawCount, uint stride) {
    vkCmdDrawIndexedIndirect(cmdbuffer, buffer, offset, drawCount, stride);
}
void dispatch(VkCommandBuffer buffer, uint x, uint y, uint z) {
    vkCmdDispatch(buffer, x, y, z);
}
void dispatchIndirect(VkCommandBuffer cmdbuffer, VkBuffer buffer, ulong offset) {
    vkCmdDispatchIndirect(cmdbuffer, buffer, offset);
}
void copyBuffer(VkCommandBuffer cmd, VkBuffer src, ulong srcOffset, VkBuffer dest, ulong destOffset, ulong size) {
    VkBufferCopy region = {
        srcOffset: srcOffset,
        dstOffset: destOffset,
        size: size
    };
    copyBuffer(cmd, src, dest, [region]);
}
void copyBuffer(VkCommandBuffer cmdbuffer, VkBuffer srcBuffer, VkBuffer dstBuffer, VkBufferCopy[] regions) {
    vkCmdCopyBuffer(cmdbuffer, srcBuffer, dstBuffer, cast(uint)regions.length, regions.ptr);
}
void copyImage(VkCommandBuffer buffer, VkImage srcImage, VkImageLayout srcImageLayout, VkImage dstImage, VkImageLayout dstImageLayout, VkImageCopy[] regions) {
    vkCmdCopyImage(buffer, srcImage, srcImageLayout, dstImage, dstImageLayout, cast(uint)regions.length, regions.ptr);
}
void blitImage(VkCommandBuffer buffer, VkImage srcImage, VkImageLayout srcImageLayout, VkImage dstImage, VkImageLayout dstImageLayout, VkImageBlit[] regions, VkFilter filter) {
    vkCmdBlitImage(buffer, srcImage, srcImageLayout, dstImage, dstImageLayout, cast(uint)regions.length, regions.ptr, filter);
}
void copyBufferToImage(VkCommandBuffer cmdbuffer, VkBuffer srcBuffer, VkImage dstImage, VkImageLayout dstImageLayout, VkBufferImageCopy[] regions) {
    vkCmdCopyBufferToImage(cmdbuffer, srcBuffer, dstImage, dstImageLayout, cast(uint)regions.length, regions.ptr);
}
void copyImageToBuffer(VkCommandBuffer cmdbuffer, VkImage srcImage, VkImageLayout srcImageLayout, VkBuffer dstBuffer, VkBufferImageCopy[] regions) {
    vkCmdCopyImageToBuffer(cmdbuffer, srcImage, srcImageLayout, dstBuffer, cast(uint)regions.length, regions.ptr);
}
void updateBuffer(VkCommandBuffer cmdbuffer, VkBuffer dstBuffer, ulong dstOffset, uint[] data) {
    // https://www.khronos.org/registry/vulkan/specs/1.0/man/html/vkCmdUpdateBuffer.html
    vkassert((data.length & 3) == 0);
    vkassert(data.length <= 65536);
    vkCmdUpdateBuffer(cmdbuffer, dstBuffer, dstOffset, data.length, data.ptr);
}
void fillBuffer(VkCommandBuffer cmdbuffer, VkBuffer dstBuffer, ulong dstOffset, ulong size, uint data) {
    vkCmdFillBuffer(cmdbuffer, dstBuffer, dstOffset, size, data);
}
void clearColorImage(VkCommandBuffer buffer, VkImage image, VkImageLayout imageLayout, VkClearColorValue[] colours, VkImageSubresourceRange[] ranges) {
    vkCmdClearColorImage(buffer, image, imageLayout, colours.ptr, cast(uint)ranges.length, ranges.ptr);
}
void clearDepthStencilImage(VkCommandBuffer buffer, VkImage image, VkImageLayout imageLayout, VkClearDepthStencilValue[] depthStencils, VkImageSubresourceRange[] ranges) {
    vkCmdClearDepthStencilImage(buffer, image, imageLayout, depthStencils.ptr, cast(uint)ranges.length, ranges.ptr);
}
void clearAttachments(VkCommandBuffer buffer, VkClearAttachment[] attachments, VkClearRect[] rects) {
    vkCmdClearAttachments(buffer, cast(uint)attachments.length, attachments.ptr, cast(uint)rects.length, rects.ptr);
}
void resolveImage(VkCommandBuffer buffer, VkImage srcImage, VkImageLayout srcImageLayout, VkImage dstImage, VkImageLayout dstImageLayout, VkImageResolve[] regions) {
    vkCmdResolveImage(buffer, srcImage, srcImageLayout, dstImage, dstImageLayout, cast(uint)regions.length, regions.ptr);
}
void setEvent(VkCommandBuffer buffer, VkEvent event, VkPipelineStageFlags stageMask) {
    vkCmdSetEvent(buffer, event, stageMask);
}
void resetEvent(VkCommandBuffer buffer, VkEvent event, VkPipelineStageFlags stageMask) {
    vkCmdResetEvent(buffer, event, stageMask);
}
/// https://www.khronos.org/registry/vulkan/specs/1.0/man/html/vkCmdWaitEvents.html
void waitEvents(VkCommandBuffer buffer, VkEvent[] events, VkPipelineStageFlags srcStageMask, VkPipelineStageFlags dstStageMask, VkMemoryBarrier[] memoryBarriers, VkBufferMemoryBarrier[] bufferMemoryBarriers, VkImageMemoryBarrier[] imageMemoryBarriers) {
    vkCmdWaitEvents(buffer, cast(uint)events.length, events.ptr, srcStageMask, dstStageMask, cast(uint)memoryBarriers.length, memoryBarriers.ptr, cast(uint)bufferMemoryBarriers.length, bufferMemoryBarriers.ptr, cast(uint)imageMemoryBarriers.length, imageMemoryBarriers.ptr);
}
void pipelineBarrier(VkCommandBuffer buffer, VkPipelineStageFlags srcStageMask, VkPipelineStageFlags dstStageMask, VkDependencyFlags dependencyFlags, VkMemoryBarrier[] memoryBarriers, VkBufferMemoryBarrier[] bufferMemoryBarriers, VkImageMemoryBarrier[] imageMemoryBarriers) {
    vkCmdPipelineBarrier(buffer, srcStageMask, dstStageMask, dependencyFlags, cast(uint)memoryBarriers.length, memoryBarriers.ptr, cast(uint)bufferMemoryBarriers.length, bufferMemoryBarriers.ptr, cast(uint)imageMemoryBarriers.length, imageMemoryBarriers.ptr);
}
void beginQuery(VkCommandBuffer buffer, VkQueryPool queryPool, uint query, VkQueryControlFlags flags) {
    vkCmdBeginQuery(buffer, queryPool, query, flags);
}
void endQuery(VkCommandBuffer buffer, VkQueryPool queryPool, uint query) {
    vkCmdEndQuery(buffer, queryPool, query);
}
void resetQueryPool(VkCommandBuffer buffer, VkQueryPool queryPool, uint firstQuery, uint queryCount) {
    vkCmdResetQueryPool(buffer, queryPool, firstQuery, queryCount);
}
void writeTimestamp(VkCommandBuffer buffer, VkPipelineStageFlags pipelineStage, VkQueryPool queryPool, uint query) {
    vkCmdWriteTimestamp(buffer, cast(VkPipelineStageFlagBits)pipelineStage, queryPool, query);
}
void copyQueryResults(VkCommandBuffer buffer, VkQueryPool queryPool, uint firstQuery, uint queryCount, VkBuffer dstBuffer, ulong dstOffset, ulong stride, VkQueryResultFlags flags) {
    vkCmdCopyQueryPoolResults(buffer, queryPool, firstQuery, queryCount, dstBuffer, dstOffset, stride, flags);
}
void pushConstants(VkCommandBuffer buffer, VkPipelineLayout layout, VkShaderStageFlags stageFlags, uint offset, uint size, void* values) {
    vkCmdPushConstants(buffer, layout, stageFlags, offset, size, values);
}
void beginRenderPass(VkCommandBuffer buffer,
                     VkRenderPass renderPass,
                     VkFramebuffer frameBuffer,
                     VkRect2D renderArea,
                     VkClearValue[] clearValues,
                     VkSubpassContents contents)
{
    VkRenderPassBeginInfo info;
    info.sType           = VkStructureType.VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
    info.renderPass      = renderPass;
    info.framebuffer     = frameBuffer;
    info.renderArea      = renderArea;

    // union VkClearValue {
    //     VkClearColorValue           color;
    //     VkClearDepthStencilValue    depthStencil;
    // }
    //union VkClearColorValue {
    //    float       float32[4];
    //    int32_t     int32[4];
    //    uint32_t    uint32[4];
    //}
    //struct VkClearDepthStencilValue {
    //    float       depth;
    //    uint32_t    stencil;
    //}
    info.clearValueCount = cast(uint)clearValues.length;
    info.pClearValues    = clearValues.ptr;

    //VkSubpassContents.VK_SUBPASS_CONTENTS_INLINE = 0,
    //VkSubpassContents.VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS = 1,

    vkCmdBeginRenderPass(buffer, &info, contents);
}
void nextSubpass(VkCommandBuffer buffer, VkSubpassContents contents) {
    vkCmdNextSubpass(buffer, contents);
}
void endRenderPass(VkCommandBuffer buffer) {
    vkCmdEndRenderPass(buffer);
}
void executeCommands(VkCommandBuffer buffer, VkCommandBuffer[] commandBuffers) {
    vkCmdExecuteCommands(buffer, cast(uint)commandBuffers.length, commandBuffers.ptr);
}