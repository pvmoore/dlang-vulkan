module hello_world_1_3;

import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.stdio  : writefln;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

import vulkan.all;

/**
 * Hello World using Vulkan 1.3 features:
 *
 *  https://registry.khronos.org/vulkan/specs/latest/man/html/VK_VERSION_1_3.html
 *
 *
 * Vulkan 1.3 implies all of:
 * - Spirv 1.6
 * - VK_KHR_copy_commands2 : adds vkCmdCopyBuffer2KHR, vkCmdCopyImage2KHR, vkCmdCopyBufferToImage2KHR, vkCmdCopyImageToBuffer2KHR
 * - VK_KHR_dynamic_rendering : allow flexible rendering without a VkRenderPass
 * - VK_KHR_format_feature_flags2 : adds format features to VkFormatProperties2
 * - VK_KHR_maintenance4 : adds vkGetDeviceBufferMemoryRequirementsKHR, vkGetDeviceImageMemoryRequirementsKHR, vkGetDeviceImageSparseMemoryRequirementsKHR
 * - VK_KHR_shader_integer_dot_product : adds integer dot product operations to shaders
 * - VK_KHR_shader_non_semantic_info : allows shaders to output debug info
 * - VK_KHR_shader_terminate_invocation : allows shaders to terminate invocations
 * - VK_KHR_synchronization2 : adds vkCmdPipelineBarrier2KHR, vkCmdResetEvent2KHR, vkCmdSetEvent2KHR, vkCmdWaitEvents2KHR, vkCmdWriteTimestamp2KHR, vkGetFenceStatus2KHR, vkGetQueryPoolResults2KHR, vkResetFences2KHR, vkWaitForFences2KHR
 * - VK_KHR_zero_initialize_workgroup_memory : allows workgroup memory to be zero initialized
 * - VK_EXT_4444_formats : adds 4444 formats
 * - VK_EXT_extended_dynamic_state : adds extended dynamic state for rasterization
 * - VK_EXT_extended_dynamic_state2 : adds more extended dynamic state for rasterization
 * - VK_EXT_image_robustness : allows robust access to images
 * - VK_EXT_inline_uniform_block : allows inline uniform blocks in shaders
 * - VK_EXT_pipeline_creation_cache_control : allows extra flags for pipeline creation cache control
 * - VK_EXT_pipeline_creation_feedback : allows feedback on pipeline creation
 * - VK_EXT_private_data : allows private data to be attached to Vulkan objects
 * - VK_EXT_shader_demote_to_helper_invocation : allows shaders to demote invocations to helper invocations
 * - VK_EXT_subgroup_size_control : allows control over subgroup size
 * - VK_EXT_texel_buffer_alignment : allows texel buffer alignment
 * - VK_EXT_texture_compression_astc_hdr : adds ASTC HDR texture compression
 * - VK_EXT_tooling_info : allows querying tooling info
 * - VK_EXT_ycbcr_2plane_444_formats : adds 2-plane 444 YCbCr formats
 */
final class HelloWorld_1_3 : VulkanApplication {
public:
    this() {
        enum NAME = "Vulkan 1.3 Hello World";
        WindowProperties wprops = {
            width:          1400,
            height:         800,
            fullscreen:     false,
            vsync:          false,
            title:          NAME,
            icon:           "resources/images/logo.png",
            showWindow:     false,
            frameBuffers:   3
        };
        VulkanProperties vprops = {
            appName: NAME,
            shaderSrcDirectories: ["shaders/"],
            shaderDestDirectory:  "resources/shaders/",
            apiVersion: vulkanVersion(1,3,0),
            shaderSpirvVersion:   "1.6"
        };

		this.vk = new Vulkan(this, wprops, vprops);
        vk.initialise();
        this.log("screen = %s", vk.windowSize);

        import std : fromStringz, format;
        import core.cpuid: processor;
        string gpuName = cast(string)vk.properties.deviceName.ptr.fromStringz;
        vk.setWindowTitle(NAME ~ " :: %s, %s".format(gpuName, processor()));

        vk.showWindow();

        static if(false) {
            // Just some temporary code to generate the 123456.png sprite sheet for the graphics3d test :)
            auto sprites = new SpriteSheet(512, 512);
            sprites.addImage("1", "resources/images/1.png");
            sprites.addImage("2", "resources/images/2.png");
            sprites.addImage("3", "resources/images/3.png");
            sprites.addImage("4", "resources/images/4.png");
            sprites.addImage("5", "resources/images/5.png");
            sprites.addImage("6", "resources/images/6.png");
            sprites.saveImageTo("resources/images/123456-2.png");
            log("uvs = %s", sprites.getUVs());
        }
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
    override void deviceReady(VkDevice device, PerFrameResource[] frameResources) {
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
            res.frameBuffer,
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
