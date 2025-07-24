module vulkan.tests.test_skybox;

import core.sys.windows.windows;
import core.runtime;

import std.stdio                : writefln;
import std.string               : toStringz;

import vulkan.all;

final class TestSkyBox : VulkanApplication {
    Vulkan vk;
	VkDevice device;
    VulkanContext context;

    VkRenderPass renderPass;
    FPS fps;
    SkyBox skybox;
    ImageMeta cubemap;
    Camera3D camera3D;

    this() {
        WindowProperties wprops = {
            width:      1400,
            height:     800,
            fullscreen: false,
            vsync:      false,
            title:      "Vulkan SkyBox Test",
            icon:       "resources/images/logo.png",
            showWindow: false,
            frameBuffers: 3,
            titleBarFps: true
        };
        VulkanProperties vprops = {
            appName: "Vulkan SkyBox Test"
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

            //if(cubemap.image) cubemap.image.free();
            if(skybox) skybox.destroy();

	        if(fps) fps.destroy();
	        if(renderPass) device.destroyRenderPass(renderPass);

            if(context) context.destroy();
	    }
		vk.destroy();
    }
    override void run() {
        vk.mainLoop();
    }
    override void deviceReady(VkDevice device) {
        this.device = device;
        initScene();
    }
    override VkRenderPass getRenderPass(VkDevice device) {
        createRenderPass(device);
        return renderPass;
    }
    void update(Frame frame) {
        auto res = frame.resource;
        bool cameraMoved = false;

        if(vk.isKeyPressed(GLFW_KEY_LEFT)) {
            camera3D.yaw(-10 * frame.perSecond);
            cameraMoved = true;
        } else if(vk.isKeyPressed(GLFW_KEY_RIGHT)) {
            camera3D.yaw(10 * frame.perSecond);
            cameraMoved = true;
        } else if(vk.isKeyPressed(GLFW_KEY_UP)) {
            camera3D.pitch(-10 * frame.perSecond);
            cameraMoved = true;
        } else if(vk.isKeyPressed(GLFW_KEY_DOWN)) {
            camera3D.pitch(10 * frame.perSecond);
            cameraMoved = true;
        }

        if(cameraMoved) {
            //this.log("moved to %s", camera3D);
            skybox.camera(camera3D);
        }

        fps.beforeRenderPass(frame, vk.getFPSSnapshot());
        skybox.beforeRenderPass(frame);
    }
    override void render(Frame frame) {
        auto res = frame.resource;
        auto b = res.adhocCB;
	    b.beginOneTimeSubmit();

        // before render pass
        update(frame);

        // RenderPass: initialLayout = UNDEFINED, loadOp = CLEAR
        b.beginRenderPass(
            renderPass,
            frame.frameBuffer,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            [ clearColour(0.2, 0.0, 0.2, 1) ],
            VK_SUBPASS_CONTENTS_INLINE
        );

        // inside render pass
        skybox.insideRenderPass(frame);
        fps.insideRenderPass(frame);

        // End RenderPass: finalLayout = PRESENT_SRC_KHR
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
    void initScene() {
        this.camera3D = Camera3D.forVulkan(
            vk.windowSize,
            float3(0, 0, 100),
            float3(0));
            //float3(4096.00, 2047.72, 7649.85) + float3(0.00, -0.28, -0.96));
        camera3D.fovNearFar(70.degrees, 10, 100000);

        createContext();
        loadCubemap();

        this.fps = new FPS(context);

        this.skybox = new SkyBox(context, cubemap)
            .camera(camera3D);
    }
    void createContext() {
        auto mem = new MemoryAllocator(vk);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("TestSkyBox_Local", 128.MB))
            //.withMemory(MemID.SHARED, mem.allocStdShared("TestSkyBox_Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("TestSkyBox_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VK_BUFFER_USAGE_INDEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 32.MB);

        context.withFonts("resources/fonts/")
               .withImages("resources/images")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);
    }
    void createRenderPass(VkDevice device) {
        this.log("Creating render pass");
        auto colorAttachment    = attachmentDescription(vk.swapchain.colorFormat);
        auto colorAttachmentRef = attachmentReference(0);

        auto subpass = subpassDescription((info) {
            info.colorAttachmentCount = 1;
            info.pColorAttachments    = &colorAttachmentRef;
        });

        this.renderPass = .createRenderPass(
            device,
            [colorAttachment],
            [subpass],
            subpassDependency2()
        );
    }
    void loadCubemap() {
        //this.cubemap = context.images().getCubemap("skyboxes/skybox1", "png");
        //this.cubemap = context.images().getCubemap("skyboxes/skybox2", "png");
        this.cubemap = context.images().getCubemap("skybox3", "dds");
    }
}
