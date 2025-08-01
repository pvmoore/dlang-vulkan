module vulkan.tests.hello_world_1_2;

import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.stdio  : writefln;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

import vulkan.all;

/**
 * Hello World using Vulkan 1.2 features:
 *
 *  https://registry.khronos.org/vulkan/specs/latest/man/html/VK_VERSION_1_2.html
 *
 * Vulkan 1.2 implies all of:
 * - Spirv 1.5
 * - K_KHR_8bit_storage : 8 bit types in uniform and storage buffers (optional)
 * - VK_KHR_buffer_device_address : get buffer addresses (eg. for ray tracing)
 * - VK_KHR_create_renderpass2 : adds sType/pNext to VkRenderPassCreateInfo2
 * - VK_KHR_depth_stencil_resolve : resolve multisample depth/stencil attachments
 * - VK_KHR_draw_indirect_count : draw commands with indirect count (via a buffer)
 * - VK_KHR_driver_properties : get driver properties (eg. vendor, version, etc)
 * - VK_KHR_image_format_list : vkCreateImage can return a list of supported view formats
 * - VK_KHR_imageless_framebuffer : create framebuffers without creating images
 * - VK_KHR_sampler_mirror_clamp_to_edge : mirror clamp to edge sampler address mode
 * - VK_KHR_separate_depth_stencil_layouts : separate depth/stencil layouts for attachments
 * - VK_KHR_shader_atomic_int64 : 64-bit atomic operations in shaders (optional)
 * - VK_KHR_shader_float16_int8 : 16-bit floats and 8-bit integers in shader code (optional)
 * - VK_KHR_shader_float_controls : control over shader rounding modes and denormals 
 * - VK_KHR_shader_subgroup_extended_types : additional subgroup operations
 * - VK_KHR_timeline_semaphore : create semaphores with ulong counter values. Can wait/signal
 * - VK_KHR_uniform_buffer_standard_layout : uniform buffers can use std430 layout
 * - VK_KHR_vulkan_memory_model
 * - VK_EXT_descriptor_indexing : bindless resources, arrays of descriptors, etc
 * - VK_EXT_host_query_reset : reset queries from the host
 * - VK_EXT_sampler_filter_minmax : adds sampler param to set min/max filtering
 * - VK_EXT_scalar_block_layout : scalar block layout for push constants, uniform and storage buffers (optional)
 * - VK_EXT_separate_stencil_usage : separate stencil usage flag for depth/stencil attachments
 * - VK_EXT_shader_viewport_index_layer : set viewport and layer in the vertex shader
 */
final class HelloWorld_1_2 : VulkanApplication {
public:
    this() {
        enum NAME = "Vulkan 1.2 Hello World";
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
        ImguiOptions imgui = {
            enabled: true,
            configFlags: 0 
                    | ImGuiConfigFlags_NoMouseCursorChange 
                    | ImGuiConfigFlags_DockingEnable 
                    | ImGuiConfigFlags_ViewportsEnable,
                fontPaths: [
                    "resources/fonts/Roboto-Regular.ttf",
                    "resources/fonts/RobotoCondensed-Regular.ttf"
                ],
                fontSizes: [
                    22,
                    20
                ]
        };
        VulkanProperties vprops = {
            appName: NAME,
            shaderSrcDirectories: ["shaders/"],
            shaderDestDirectory:  "resources/shaders/",
            apiVersion: VK_API_VERSION_1_2,
            shaderSpirvVersion:   "1.5",
            imgui: imgui
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

        if(vk.isKeyPressed(GLFW_KEY_A)) {
            camera3D.rotateZRelative((-40 * frame.perSecond).degrees());
        } else if(vk.isKeyPressed(GLFW_KEY_D)) {
            camera3D.rotateZRelative((40 * frame.perSecond).degrees());
        }
        if(vk.isKeyPressed(GLFW_KEY_Q)) {
            camera3D.rotateXRelative((-40 * frame.perSecond).degrees());
        } else if(vk.isKeyPressed(GLFW_KEY_E)) {
            camera3D.rotateXRelative((40 * frame.perSecond).degrees());
        }
        if(vk.isKeyPressed(GLFW_KEY_Z)) {
            camera3D.rotateYRelative((-40 * frame.perSecond).degrees());
        } else if(vk.isKeyPressed(GLFW_KEY_C)) {
            camera3D.rotateYRelative((40 * frame.perSecond).degrees());
        }

        if(vk.isKeyPressed(GLFW_KEY_W)) {
            camera3D.moveForward(10 * frame.perSecond);
        } else if(vk.isKeyPressed(GLFW_KEY_S)) {
            camera3D.moveForward(-10 * frame.perSecond);
        } 
        
        if(vk.isKeyPressed(GLFW_KEY_UP)) {
            camera3D.movePositionRelative(float3(0,100,0) * frame.perSecond);
        } else if(vk.isKeyPressed(GLFW_KEY_DOWN)) {
            camera3D.movePositionRelative(float3(0,-100,0) * frame.perSecond);
        } else if(vk.isKeyPressed(GLFW_KEY_LEFT)) {
            camera3D.movePositionRelative(float3(-100,0,0) * frame.perSecond);
        } else if(vk.isKeyPressed(GLFW_KEY_RIGHT)) {
            camera3D.movePositionRelative(float3(100,0,0) * frame.perSecond);
        }

        if(camera3D.wasModified()) {
            cartesian.camera(camera3D);
            camera3D.resetModifiedState();
        }

        cartesian.beforeRenderPass(frame);
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
        cartesian.insideRenderPass(frame);
        imguiFrame(frame);

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
    Camera3D camera3D;
    VkClearValue bgColour;
    CartesianCoordinates cartesian;

    void initScene() {
        createCamera();

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
        this.cartesian = new CartesianCoordinates(context, 2, 100)
            .camera(camera3D);

        this.bgColour = clearColour(0.0f, 0.1f, 0.05f, 1);
    }
    void createCamera() {
        float3 focalPoint = float3(0,0,0);
        this.camera3D = Camera3D.forVulkan(vk.windowSize, float3(0,0,-150), focalPoint);
        camera3D.fovNearFar(60.degrees(), 0.01f, 1000.0f);
        camera3D.rotateZRelative(180.degrees());

        float3 cameraPos = float3(60, 50, -150);
        camera3D.movePositionAbsolute(cameraPos);

        this.log("camera3D = %s", camera3D);
        this.log("fov,near,far = %s, %s, %s", camera3D.fov.radians, camera3D.near, camera3D.far);
        this.log("V = \n%s", camera3D.V());
        this.log("P = \n%s", camera3D.P());
        this.log("VP = \n%s", camera3D.VP());
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

    void imguiFrame(Frame frame) {
        vk.imguiRenderStart(frame);

        // This will turn the main window into a dockspace
        // which means it won't have a menu bar.
        // If you don't want this behaviour then comment the line below
        igDockSpaceOverViewport(0, null, ImGuiDockNodeFlags_PassthruCentralNode, null);
    
        cartesian.insideImguiFrame(frame);

        vk.imguiRenderEnd(frame);
    }
}
