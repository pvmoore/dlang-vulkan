module test_skybox;

import core.sys.windows.windows;
import core.runtime;

import std.stdio                : writefln;
import std.string               : toStringz;

import vulkan;
import common;
import logging;

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
            icon:       "/pvmoore/_assets/icons/3dshapes.png",
            showWindow: false,
            frameBuffers: 3
        };
        VulkanProperties vprops = {
            appName: "Vulkan SkyBox Test"
        };

        setEagerFlushing(true);

		this.vk = new Vulkan(this, wprops, vprops);
        vk.initialise();
        vk.setDesiredMaximumFPS(240);

        this.log("screen = %s", vk.windowSize);

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
    override void deviceReady(VkDevice device, PerFrameResource[] frameResources) {
        this.device = device;
        initScene();
    }
    override VkRenderPass getRenderPass(VkDevice device) {
        createRenderPass(device);
        return renderPass;
    }
    override void render(FrameInfo frame, PerFrameResource res) {
        auto b = res.adhocCB;
	    b.beginOneTimeSubmit();

        // before render pass
        fps.beforeRenderPass(res, vk.getFPS);


        b.beginRenderPass(
            renderPass,
            res.frameBuffer,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            [ clearColour(0.2, 0.0, 0.2, 1) ],
            VSubpassContents.INLINE
            //VSubpassContents.SECONDARY_COMMAND_BUFFERS
        );

        // inside render pass
        skybox.insideRenderPass(res);
        fps.insideRenderPass(res);

        b.endRenderPass();
        b.end();

        /// Submit our render buffer
        vk.getGraphicsQueue().submit(
            [b],
            [res.imageAvailable],
            [VPipelineStage.COLOR_ATTACHMENT_OUTPUT],
            [res.renderFinished],  // signal semaphores
            res.fence              // fence
        );
    }
private:
    void initScene() {
        this.camera3D = Camera3D.forVulkan(
            vk.windowSize,
            float3(4096.00, 2047.72, 7649.85),
            float3(4096.00, 2047.72, 7649.85) + float3(0.00, -0.28, -0.96));
        camera3D.fovNearFar(60.degrees, 10, 100000);

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
            .withMemory(MemID.SHARED, mem.allocStdShared("TestSkyBox_Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("TestSkyBox_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VBufferUsage.VERTEX | VBufferUsage.TRANSFER_DST, 1.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VBufferUsage.INDEX | VBufferUsage.TRANSFER_DST, 1.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VBufferUsage.UNIFORM | VBufferUsage.TRANSFER_DST, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VBufferUsage.TRANSFER_SRC, 32.MB);

        context.withFonts("/pvmoore/_assets/fonts/hiero/")
               .withImages("/pvmoore/_assets/images")
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
        this.cubemap = context.images().getCubemap("skyboxes/skybox1", "png");
    }
}