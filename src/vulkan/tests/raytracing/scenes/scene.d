module vulkan.tests.raytracing.scenes.scene;

import vulkan.tests.raytracing.test_ray_tracing;

abstract class Scene {
public:
    this(VulkanContext context, VkCommandPool traceCP, FrameResource[] frameResources) {
        this.context = context;
        this.device = context.device;
        this.vk = context.vk;
        this.traceCP = traceCP;
        this.frameResources = frameResources;
        this.windowSize = context.vk.windowSize();
    }

    final Descriptors getDescriptors() { return descriptors; }
    final RayTracingPipeline getPipeline() { return rtPipeline; }
    final Camera3D getCamera() { return camera3d; }
    final VkCommandBuffer getCommandBuffer(uint index) { return cmdBuffers[index]; }

    abstract string name();
    abstract string description();

    final void update(Frame frame, float3 lightPos) {
        subclassUpdate(frame, lightPos);
    }

    abstract void subclassUpdate(Frame frame, float3 lightPos);
    abstract void subclassInitialise();

    final void initialise() {
        subclassInitialise();
        recordCommandBuffers();
    }
    void destroy() {
        if(rtPipeline) rtPipeline.destroy();
        if(descriptors) descriptors.destroy();
        if(tlas) tlas.destroy();
        foreach(cmd; cmdBuffers) device.free(traceCP, cmd);
    }
protected:
    @Borrowed VulkanContext context;
    @Borrowed VkDevice device;
    @Borrowed Vulkan vk;
    @Borrowed VkCommandPool traceCP;
    @Borrowed FrameResource[] frameResources;

    Descriptors descriptors;
    RayTracingPipeline rtPipeline;
    TLAS tlas;
    Camera3D camera3d;
    VkCommandBuffer[] cmdBuffers;
    VkCommandPool buildCommandPool;

    uint2 windowSize;

    final void recordCommandBuffers() {

        foreach(i, fr; frameResources) {

            auto cmd = device.allocFrom(traceCP);
            cmdBuffers ~= cmd;

            cmd.begin();

            cmd.bindPipeline(rtPipeline);
            cmd.bindDescriptorSets(
                VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR,
                rtPipeline.layout,
                0,
                [descriptors.getSet(0, i.as!uint)],
                null
            );

            // Prepare the traceTarget image to be updated in the ray tracing shaders
            cmd.pipelineBarrier(
                VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                0,      // dependency flags
                null,   // memory barriers
                null,   // buffer barriers
                [
                    imageMemoryBarrier(
                        fr.traceTarget.handle,
                        VK_ACCESS_SHADER_READ_BIT,
                        VK_ACCESS_SHADER_WRITE_BIT,
                        VK_IMAGE_LAYOUT_UNDEFINED,
                        VK_IMAGE_LAYOUT_GENERAL
                    )
                ]
            );

            // Trace rays to traceTarget image
            cmd.traceRays(
                &rtPipeline.raygenStridedDeviceAddressRegion,
                &rtPipeline.missStridedDeviceAddressRegion,
                &rtPipeline.hitStridedDeviceAddressRegion,
                &rtPipeline.callableStridedDeviceAddressRegion,
                windowSize.x, windowSize.y, 1);

            // Prepare the traceTarget image to be used in the Quad fragment shader
            cmd.pipelineBarrier(
                VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR,
                0,      // dependency flags
                null,   // memory barriers
                null,   // buffer barriers
                [
                    imageMemoryBarrier(
                        fr.traceTarget.handle,
                        VK_ACCESS_SHADER_WRITE_BIT,
                        VK_ACCESS_SHADER_READ_BIT,
                        VK_IMAGE_LAYOUT_GENERAL,
                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
                    )
                ]
            );

            cmd.end();
        }
    }
}
