module hello_world_1_1;

import core.sys.windows.windows;
import core.runtime;
import std.string             : toStringz;
import std.stdio              : writefln;
import std.format             : format;
import std.datetime.stopwatch : StopWatch;

import vulkan.all;

/**
 * Hello World using Vulkan 1.1 features:
 *
 *  https://www.khronos.org/files/vulkan11-reference-guide.pdf
 *  https://registry.khronos.org/vulkan/specs/latest/man/html/VK_VERSION_1_1.html
 *
 * Vulkan 1.1 implies all of:
 * - spirv 1.3
 * - VK_KHR_16bit_storage : allows shaders to use 16-bit types in input/output (optional)
 * - VK_KHR_bind_memory2 : bind multiple buffers/images in one call using the 'vkBindBufferMemory2' function
 * - VK_KHR_dedicated_allocation : allows resources to be bound to a dedicated memory allocation
 * - VK_KHR_descriptor_update_template : update descriptor sets using a template
 * - VK_KHR_device_group : allows multiple physical devices to be used in a single logical device
 * - VK_KHR_device_group_creation : create a logical device from multiple physical devices
 * - VK_KHR_external_fence : allows fences to be exported/imported from/to other APIs
 * - VK_KHR_external_fence_capabilities : query fence capabilities for external APIs
 * - VK_KHR_external_memory : allows memory to be exported/imported from/to other devices
 * - VK_KHR_external_memory_capabilities : query memory capabilities for external devices
 * - VK_KHR_external_semaphore : allows semaphores to be exported/imported from/to other APIs
 * - VK_KHR_external_semaphore_capabilities : query semaphore capabilities for external APIs
 * - VK_KHR_get_memory_requirements2 : adds sType/pNext to Vk[Buffer|Image]MemoryRequirementsInfo2
 * - VK_KHR_get_physical_device_properties2 : adds vkGetPhysicalDeviceProperties2 
 * - VK_KHR_maintenance1
 * - VK_KHR_maintenance2
 * - VK_KHR_maintenance3
 * - VK_KHR_multiview : allows rendering to multiple views simultaneously
 * - VK_KHR_relaxed_block_layout : allows relaxed block layout rules in shaders
 * - VK_KHR_sampler_ycbcr_conversion : allows conversion between YCbCr and RGB in samplers
 * - VK_KHR_shader_draw_parameters : allows shaders to use the 'BaseIndex', 'BaseVertex' and 'DrawIndex' variables
 * - VK_KHR_storage_buffer_storage_class : allows storage buffers to be declared with the 'storage' storage class
 * - VK_KHR_variable_pointers : allows shader modules to use invocation-private pointers into uniform and/or storage buffers
 */
final class HelloWorld_1_1 : VulkanApplication {
public:
    this() {
        enum NAME = "Vulkan 1.1 Hello World";
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
            apiVersion: VK_API_VERSION_1_1,
            shaderSpirvVersion:   "1.3"
        };

        vprops.enableShaderPrintf = false;
        vprops.enableGpuValidation = false;

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
