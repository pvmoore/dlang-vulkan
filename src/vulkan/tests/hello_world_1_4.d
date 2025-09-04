module vulkan.tests.hello_world_1_4;

import core.cpuid: processor;
import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz, fromStringz;
import std.stdio  : writefln;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

import vulkan.all;

/**
 * Hello World using Vulkan 1.4 features:
 *
 * https://registry.khronos.org/vulkan/specs/latest/man/html/VK_VERSION_1_4.html
 *
 *
 * Vulkan 1.4 implies all of:
 * - Spirv 1.6
 * - VK_KHR_dynamic_rendering_local_read : enables reads from attachments and resources written by previous fragment shaders within a dynamic render pass  
 * - VK_KHR_global_priority : allows setting global priority for queues
 * - VK_KHR_index_type_uint8 : allows using uint8_t as vertex index type
 * - VK_KHR_line_rasterization : allows configuring line rasterization 
 * - VK_KHR_load_store_op_none : allows using VK_ATTACHMENT_LOAD_OP_NONE and VK_ATTACHMENT_STORE_OP_NONE for attachments
 * - VK_KHR_maintenance5
 * - VK_KHR_maintenance6
 * - VK_KHR_map_memory2 : adds extensible vkMapMemory2KHR and vkUnmapMemory2KHR functions
 * - VK_KHR_push_descriptors : allows using push descriptors in pipelines  
 * - VK_KHR_shader_expect_assume : allows using expect/assume intrinsics in shaders
 * - VK_KHR_shader_float_controls2 : finer grained control over shader rounding modes and denormals
 * - VK_KHR_shader_subgroup_rotate : adds subgroup rotate operations
 * - VK_KHR_vertex_attribute_divisor : allows using vertex attribute divisor
 * - VK_EXT_host_image_copy : allows copying images between host and device memory
 * - VK_EXT_pipeline_protected_access : allows using protected access per pipeline
 * - VK_EXT_pipeline_robustness : allows configuring robustness for pipelines
 */
final class HelloWorld_1_4 : VulkanApplication {
public:
    this() {
        enum NAME = "Vulkan 1.4 Hello World";
        WindowProperties wprops = {
            width:          1400,
            height:         800,
            fullscreen:     false,
            vsync:          false,
            title:          NAME,
            icon:           "resources/images/logo.png",
            showWindow:     false,
            frameBuffers:   3,
            titleBarFps:    true
        };
        VulkanProperties vprops = {
            appName: NAME,
            shaderSrcDirectories: ["shaders/"],
            shaderDestDirectory:  "resources/shaders/",
            apiVersion: VK_API_VERSION_1_4,
            shaderSpirvVersion:   "1.6",
            features : 
                DeviceFeatures.Features.Vulkan11 |
                DeviceFeatures.Features.Vulkan12 |
                DeviceFeatures.Features.Vulkan13 |
                DeviceFeatures.Features.Vulkan14 |
                DeviceFeatures.Features.UnifiedImageLayouts
        };

		this.vk = new Vulkan(this, wprops, vprops);
        vk.initialise();
        vk.showWindow();
    }
    override void destroy() {
	    if(!vk) return;
	    if(device) {
	        vkDeviceWaitIdle(device);

            if(context) context.dumpMemory();

            if(fps) fps.destroy();
            if(renderPass) device.destroyRenderPass(renderPass);
            if(context) context.destroy();
	    }
		vk.destroy();
    }
    override void run() {
        vk.mainLoop();
    }
    override VkRenderPass getRenderPass(VkDevice device) {
        createRenderPass(device);
        return renderPass;
    }
    override void selectFeatures(DeviceFeatures deviceFeatures) {

        // Disable this as it has a performance impact
        deviceFeatures.apply((ref VkPhysicalDeviceFeatures f) {
            f.robustBufferAccess = VK_FALSE;
        });
        
        deviceFeatures.apply((ref VkPhysicalDeviceUnifiedImageLayoutsFeaturesKHR f) {
            // Interesting feature. Use VK_IMAGE_LAYOUT_GENERAL in most cases instead
            // of having to manage the layout transitions.

            // 2025-09-04:
            // Note that the driver is returning false for this at the moment so it appears to
            // be unsupported but enabling it here does not cause an error. I need to test
            // whether it is actually enabled or just ignored by the driver 
            f.unifiedImageLayouts = VK_TRUE;
        });
    }
    override void deviceReady(VkDevice device) {
        this.device = device;
        initScene();
    }
    void update(Frame frame) {
        fps.beforeRenderPass(frame, vk.getFPSSnapshot());
    }
    override void render(Frame frame) {
        auto res = frame.resource;
	    auto b = res.adhocCB;
	    b.beginOneTimeSubmit();

        update(frame);

        // begin the render pass
        b.beginRenderPass(
            renderPass,
            frame.frameBuffer,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            [ bgColour ],
            VK_SUBPASS_CONTENTS_INLINE
            //VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS
        );

        fps.insideRenderPass(frame);

        b.endRenderPass();
        b.end();

        /// Submit our render buffer
        vk.getGraphicsQueue().submit(
            [b],
            [res.imageAvailable],
            [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT],
            [res.renderFinished],  // signal semaphores
            res.fence              // fence
        );
    }
private:
    Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    FPS fps;
    Camera2D camera;
    VkClearValue bgColour;
    string title;

    void initScene() {
        this.camera = Camera2D.forVulkan(vk.windowSize);

        auto mem = new MemoryAllocator(vk);

        auto maxLocal =
            mem.builder(0)
                .withAll(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                .withoutAll(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)
                .maxHeapSize();

        this.log("Max local memory = %s MBs", maxLocal / 1.MB);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("G2D_Local", 256.MB))
          //.withMemory(MemID.SHARED, mem.allocStdShared("G2D_Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("G2D_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VK_BUFFER_USAGE_INDEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 32.MB);

        context.withFonts("resources/fonts/")
               .withImages("resources/images/")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        this.fps = new FPS(context);

        this.bgColour = clearColour(0.0f,0,0,1);
    }
    void createRenderPass(VkDevice device) {
        this.log("Creating render pass");
        auto colorAttachment    = attachmentDescription(vk.swapchain.colorFormat);
        auto colorAttachmentRef = attachmentReference(0);

        auto subpass = subpassDescription((info) {
            info.colorAttachmentCount = 1;
            info.pColorAttachments    = &colorAttachmentRef;
        });

        auto dependency = subpassDependency();

        renderPass = .createRenderPass(
            device,
            [colorAttachment],
            [subpass],
            subpassDependency2()//[dependency]
        );
    }
}
