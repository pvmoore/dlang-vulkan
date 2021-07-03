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
    VFormat format;
    VImageUsage usage;
    VImageLayout layout;
    DeviceImage image;

    this(VulkanContext context, string name, uint[] imageDimensions, uint[] workgroupDimensions) {
        this.context     = context;
        this.device      = context.device;
        this.name        = name;
        this.imageDimensions = imageDimensions;
        this.workgroupDimensions = workgroupDimensions;
        this.pipeline    = new ComputePipeline(context);
        this.format      = VFormat.R8G8B8A8_UNORM;
        this.usage       = VImageUsage.NONE;
        this.layout      = VImageLayout.SHADER_READ_ONLY_OPTIMAL;

        vkassert(workgroupDimensions.length==3);
        vkassert(workgroupDimensions[1]!=0);
        vkassert(workgroupDimensions[2]!=0);
    }
    auto withFormat(VFormat format) {
        this.format = format;
        return this;
    }
    auto withUsage(VImageUsage usage) {
        this.usage = usage;
        return this;
    }
    auto withLayout(VImageLayout layout) {
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
            VImageUsage.STORAGE | usage,
            format
        );
        image.createView(
            format,
            cast(VImageViewType)(VImageViewType._1D + (imageDimensions.length-1)),
            VImageAspect.COLOR
        );
    }
    void doGenerate() {
        StopWatch w; w.start();

        auto dsLayout = device.createDescriptorSetLayout([
            storageImageBinding(0, VShaderStage.COMPUTE)
        ]);
        auto descriptorPool = device.createDescriptorPool([
                descriptorPoolSize(VDescriptorType.STORAGE_IMAGE,1)
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
                VDescriptorType.STORAGE_IMAGE,
                [descriptorImageInfo(null, image.view, VImageLayout.GENERAL)]
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
            VCommandPoolCreate.TRANSIENT |
            VCommandPoolCreate.RESET_COMMAND_BUFFER
        );

        auto cmd = device.allocFrom(commandPool);
        cmd.beginOneTimeSubmit();
        cmd.bindPipeline(pipeline);
        cmd.bindDescriptorSets(
            VPipelineBindPoint.COMPUTE,
            pipeline.layout,
            0,
            [descriptorSet],
            null
        );
        cmd.pipelineBarrier(
            VPipelineStage.COMPUTE_SHADER,
            VPipelineStage.COMPUTE_SHADER,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    image.handle,
                    VAccess.NONE,
                    VAccess.SHADER_WRITE,
                    VImageLayout.UNDEFINED,
                    VImageLayout.GENERAL
                )
            ]
        );
        if(pushConstSize>0) {
            cmd.pushConstants(
                pipeline.layout,
                VShaderStage.COMPUTE,
                0,
                pushConstSize,
                pushConst
            );
        }

        auto g = workgroupDimensions;
        cmd.dispatch(g[0], g[1], g[2]);

        cmd.pipelineBarrier(
            VPipelineStage.COMPUTE_SHADER,
            VPipelineStage.COMPUTE_SHADER,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    image.handle,
                    VAccess.SHADER_WRITE,
                    VAccess.SHADER_READ,
                    VImageLayout.GENERAL,
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
