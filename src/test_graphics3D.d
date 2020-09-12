module test_graphics3D;

import vulkan;
import common;
import logging;
import resources;

final class TestGraphics3D : VulkanApplication {
    Vulkan vk;
    VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    FPS fps;
    Model3D!20000 model3d;
    Camera3D camera3D;

    Angle!float rotation;

	this() {
        WindowProperties wprops = {
            width:        1400,
            height:       800,
            fullscreen:   false,
            vsync:        false,
            title:        "Vulkan 3D Graphics Test",
            icon:         "/pvmoore/_assets/icons/3dshapes.png",
            showWindow:   false,
            frameBuffers: 3
        };
        VulkanProperties vprops = {
            appName: "Vulkan 3D Graphics Test",

            /* Add a depth buffer */
            depthStencilFormat: VFormat.D32_SFLOAT_S8_UINT,
            depthStencilUsage: VImageUsage.TRANSFER_SRC
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
            if(model3d) model3d.destroy();
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
        auto res = frame.resource;
        bool cameraMoved = false;

        if(vk.isKeyPressed(GLFW_KEY_LEFT)) {
            camera3D.movePositionRelative(float3(-100,0,0) * frame.perSecond);
            cameraMoved = true;
        } else if(vk.isKeyPressed(GLFW_KEY_RIGHT)) {
            camera3D.movePositionRelative(float3(100,0,0) * frame.perSecond);
            cameraMoved = true;
        } else if(vk.isKeyPressed(GLFW_KEY_UP)) {
            camera3D.movePositionRelative(float3(0,100,0) * frame.perSecond);
            cameraMoved = true;
        } else if(vk.isKeyPressed(GLFW_KEY_DOWN)) {
            camera3D.movePositionRelative(float3(0,-100,0) * frame.perSecond);
            cameraMoved = true;
        } else if(vk.isKeyPressed(GLFW_KEY_A)) {
            camera3D.movePositionRelative(float3(0,0,100) * frame.perSecond);
            cameraMoved = true;
        } else if(vk.isKeyPressed(GLFW_KEY_Z)) {
            camera3D.movePositionRelative(float3(0,0,-100) * frame.perSecond);
            cameraMoved = true;
        }

        auto mouse = vk.getMouseState();

        if(mouse.wheel != 0) {
            camera3D.moveForward(mouse.wheel * frame.perSecond * 10000);
            cameraMoved = true;
        }

        /** Rotate model */
        auto add = (1.0f * frame.perSecond);
        rotation = (rotation.radians + add).radians;
        model3d.rotate(rotation, rotation, rotation);

        if(cameraMoved) {
            this.log("camera = %s", camera3D);

            model3d.camera(camera3D);
        }

        fps.beforeRenderPass(frame, vk.getFPS);
        model3d.beforeRenderPass(frame);
    }
    override void render(Frame frame) {
        auto res = frame.resource;
	    auto b = res.adhocCB;
	    b.beginOneTimeSubmit();

        update(frame);

        // Renderpass initialLayout = UNDEFINED
        //                   loadOp = CLEAR
        b.beginRenderPass(
            renderPass,
            res.frameBuffer,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            [ clearColour(0,0,0,1), depthStencilClearColour(0f, 0) ],
            VSubpassContents.INLINE
            //VSubpassContents.SECONDARY_COMMAND_BUFFERS
        );

        model3d.insideRenderPass(frame);
        fps.insideRenderPass(frame);

        // Renderpass finalLayout = PRESENT_SRC_KHR
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
        this.log("Initialising scene");

        createContext();
        createCamera();
        createModel3D();

        this.fps = new FPS(context);
    }
    void createCamera() {
        this.camera3D = Camera3D.forVulkan(vk.windowSize, float3(0f, 0f, 120f), float3(0f,0f,0f));
        camera3D.fovNearFar(70.degrees(), 0.01f, 1000.0f);
        this.log("camera3D = %s", camera3D);
        this.log("fov,near,far = %s, %s, %s", camera3D.fov.radians, camera3D.near, camera3D.far);
        this.log("V = \n%s", camera3D.V());
        this.log("P = \n%s", camera3D.P());
        this.log("VP = \n%s", camera3D.VP());
    }
    void createModel3D() {
        auto objModel = Obj.read("/pvmoore/_assets/models/suzanne.obj.txt");
        this.log("obj = %s", objModel);

        this.rotation = 0.degrees;

        this.model3d = new Model3D!20000(context)
            .camera(camera3D)
            .modelData(objModel)
            .scale(float3(50))
            .lightPosition(float3(200f,1000f,800f));
    }
    void createContext() {
        this.log("Creating context");
        auto mem = new MemoryAllocator(vk);

        auto maxLocal =
            mem.builder(0)
                .withAll(VMemoryProperty.DEVICE_LOCAL)
                .withoutAll(VMemoryProperty.HOST_VISIBLE)
                .maxHeapSize();

        this.log("Max local memory = %s MBs", maxLocal / 1.MB);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("G3D_Local", 128.MB))
            .withMemory(MemID.SHARED, mem.allocStdShared("G3D_Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("G3D_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VBufferUsage.VERTEX | VBufferUsage.TRANSFER_DST, 10.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VBufferUsage.INDEX | VBufferUsage.TRANSFER_DST, 1.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VBufferUsage.UNIFORM | VBufferUsage.TRANSFER_DST, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VBufferUsage.TRANSFER_SRC, 16.MB);

        context.withFonts("/pvmoore/_assets/fonts/hiero/")
               .withImages("/pvmoore/_assets/images")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);
    }
    void createRenderPass(VkDevice device) {
        this.log("Creating render pass");

        auto attachmentDescs = [
            attachmentDescription(vk.swapchain.colorFormat),
            depthAttachmentDescription(vk.vprops.depthStencilFormat)
        ];

        auto colorAttachmentRefs = [
            attachmentReference(0, VImageLayout.COLOR_ATTACHMENT_OPTIMAL)
        ];

        auto depthStencilAttachment = attachmentReference(1, VImageLayout.DEPTH_STENCIL_ATTACHMENT_OPTIMAL);

        auto subpass = subpassDescription((info) {
            info.colorAttachmentCount    = colorAttachmentRefs.length.as!int;
            info.pColorAttachments       = colorAttachmentRefs.ptr;
            info.pDepthStencilAttachment = &depthStencilAttachment;
        });

        this.renderPass = .createRenderPass(
            device,
            attachmentDescs,
            [subpass],
            subpassDependency2()
        );
    }
}
