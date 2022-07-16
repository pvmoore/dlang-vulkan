module vulkan.generators.image_generator;
/**
 *
 */
import vulkan.all;

final class ImageGenerator {
    VulkanContext context;
    VkDevice device;

    string name;
    uint[] imageDimensions;
    uint[] workgroupDimensions;
    ComputePipeline pipeline;
    uint pushConstSize;
    void* pushConst;
    VkFormat format;
    VkImageUsageFlags usage;
    VkImageLayout layout;
    DeviceImage image;

    this(VulkanContext context, string name, uint[] imageDimensions, uint[] workgroupDimensions) {
        this.context     = context;
        this.device      = context.device;
        this.name        = name;
        this.imageDimensions = imageDimensions;
        this.workgroupDimensions = workgroupDimensions;
        this.pipeline    = new ComputePipeline(context);
        this.format      = VK_FORMAT_R8G8B8A8_UNORM;
        this.usage       = VK_IMAGE_USAGE_NONE;
        this.layout      = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;

        vkassert(workgroupDimensions.length==3);
        vkassert(workgroupDimensions[1]!=0);
        vkassert(workgroupDimensions[2]!=0);
    }
    auto withFormat(VkFormat format) {
        this.format = format;
        return this;
    }
    auto withUsage(VkImageUsageFlags usage) {
        this.usage = usage;
        return this;
    }
    auto withLayout(VkImageLayout layout) {
        this.layout = layout;
        return this;
    }
    auto withShader(T)(VkShaderModule shader, T* specConsts) {
        pipeline.withShader!T(shader, specConsts);
        return this;
    }
    auto withPushConstants(T)(T* data) {
        pipeline.withPushConstantRange!T();
        this.pushConstSize = T.sizeof;
        this.pushConst     = data;
        return this;
    }
    DeviceImage generate() {
        createImage();
        doGenerate();
        return image;
    }
private:
    void createImage() {

        image = context.memory(MemID.LOCAL)
                       .allocImage(
            name,
            imageDimensions,
            VK_IMAGE_USAGE_STORAGE_BIT | usage,
            format
        );
        image.createView(
            format,
            cast(VkImageViewType)(VK_IMAGE_VIEW_TYPE_1D + (imageDimensions.length-1)),
            VK_IMAGE_ASPECT_COLOR_BIT
        );
    }
    void doGenerate() {
        StopWatch w; w.start();

        auto dsLayout = device.createDescriptorSetLayout([
            storageImageBinding(0, VK_SHADER_STAGE_COMPUTE_BIT)
        ]);
        auto descriptorPool = device.createDescriptorPool([
                descriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, 1)
            ],
            1
        );
        auto descriptorSet = device.allocDescriptorSets(
            descriptorPool,
            [dsLayout]
        )[0];

        auto writes = [
            descriptorSet.writeImage(
                0,  // binding
                VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                [descriptorImageInfo(null, image.view, VK_IMAGE_LAYOUT_GENERAL)]
            )
        ];
        device.updateDescriptorSets(
            writes,
            null // copies
        );

        pipeline
            .withDSLayouts([dsLayout])
            .build();

        auto commandPool = device.createCommandPool(
            context.vk.getComputeQueueFamily().index,
            VK_COMMAND_POOL_CREATE_TRANSIENT_BIT | VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
        );

        auto cmd = device.allocFrom(commandPool);
        cmd.beginOneTimeSubmit();
        cmd.bindPipeline(pipeline);
        cmd.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_COMPUTE,
            pipeline.layout,
            0,
            [descriptorSet],
            null
        );
        cmd.pipelineBarrier(
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    image.handle,
                    VK_ACCESS_NONE,
                    VK_ACCESS_SHADER_WRITE_BIT,
                    VK_IMAGE_LAYOUT_UNDEFINED,
                    VK_IMAGE_LAYOUT_GENERAL
                )
            ]
        );
        if(pushConstSize>0) {
            cmd.pushConstants(
                pipeline.layout,
                VK_SHADER_STAGE_COMPUTE_BIT,
                0,
                pushConstSize,
                pushConst
            );
        }

        auto g = workgroupDimensions;
        cmd.dispatch(g[0], g[1], g[2]);

        cmd.pipelineBarrier(
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    image.handle,
                    VK_ACCESS_SHADER_WRITE_BIT,
                    VK_ACCESS_SHADER_READ_BIT,
                    VK_IMAGE_LAYOUT_GENERAL,
                    layout
                )
            ]
        );
        cmd.end();

        context.vk.getComputeQueue().submit([cmd], null);
        vkQueueWaitIdle(context.vk.getComputeQueue());

        pipeline.destroy();
        device.destroyCommandPool(commandPool);
        device.destroyDescriptorPool(descriptorPool);
        device.destroyDescriptorSetLayout(dsLayout);

        ulong end = w.peek().total!"nsecs";
        this.log("Image '%s' generated in %s millis", name, end/1000000.0);
    }
}
