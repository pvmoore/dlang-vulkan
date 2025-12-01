module vulkan.tests.test_graphics3D;

import vulkan.all;
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
            icon:         "resources/images/logo.png",
            showWindow:   false,
            frameBuffers: 3,
            titleBarFps: true
        };
        VulkanProperties vprops = {
            apiVersion: VK_API_VERSION_1_1,
            appName: "Vulkan 3D Graphics Test",

            /* Add a depth buffer */
            depthStencilFormat: VK_FORMAT_D32_SFLOAT_S8_UINT,
            depthStencilUsage: VK_IMAGE_USAGE_TRANSFER_SRC_BIT
        };

        debug {
            vprops.enableShaderPrintf  = true;
            vprops.enableGpuValidation = true;
        }

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
            foreach(c; cubes) if(c) c.destroy();
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
    override void deviceReady(VkDevice device) {
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

        if(mouse.wheel.ydelta != 0) {
            camera3D.moveForward(mouse.wheel.ydelta * frame.perSecond * 2000);
            cameraMoved = true;
        }

        /** Rotate model */
        auto add = (1.0f * frame.perSecond);
        rotation = (rotation.radians + add).radians;
        model3d.rotate(rotation, rotation, rotation);

        foreach(i; 0..cubes.length) {
            cubeRotations[i] = (cubeRotations[i].radians + add).radians;
            cubes[i].rotate(cubeRotations[i], cubeRotations[i], cubeRotations[i]);
        }

        if(cameraMoved) {
            this.log("camera = %s", camera3D);

            model3d.camera(camera3D);
            foreach(c; cubes) {
                c.camera(camera3D);
            }
        }

        foreach(c; cubes) {
            c.beforeRenderPass(frame);
        }
        fps.beforeRenderPass(frame, vk.getFPSSnapshot());
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
            frame.frameBuffer,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            [ clearColour(0,0,0,1), depthStencilClearColour(0f, 0) ],
            VK_SUBPASS_CONTENTS_INLINE
        );

        model3d.insideRenderPass(frame);
        foreach(c; cubes) {
            c.insideRenderPass(frame);
        }
        fps.insideRenderPass(frame);

        // Renderpass finalLayout = PRESENT_SRC_KHR
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
    Cube[] cubes;
    Angle!(float)[] cubeRotations;

    void initScene() {
        this.log("Initialising scene");

        createContext();
        createCamera();
        createModel3D();

        this.fps = new FPS(context);

        this.cubes ~= createCube(Cube.Kind.SOLID)
            .colour(RGBA(1,1,1,1))
            .translate(float3(100, 50, 0))
            .scale(float3(30,30,30));
        this.cubes ~= createCube(Cube.Kind.WIREFRAME, 1.0f)
            .colour(RGBA(.3,1,.2,1))
            .translate(float3(100, 0, 0))
            .scale(float3(30,30,30));
        this.cubes ~= createCube(Cube.Kind.WIREFRAME, 2.0f)
            .colour(RGBA(1,1,1,1))
            .translate(float3(100, -50, 0))
            .scale(float3(30,30,30));

        this.cubes ~= createCube(Cube.Kind.WIREFRAME, 3.0f)
            .colour(RGBA(1,1,1,1))
            .translate(float3(-100, 50, 0))
            .scale(float3(30,30,30));
        this.cubes ~= createCube(Cube.Kind.WIREFRAME, 6.0f)
            .colour(RGBA(1,1,1,1))
            .translate(float3(-100, 0, 0))
            .scale(float3(30,30,30));
        this.cubes ~= createCube(Cube.Kind.SOLID)
            .colour(RGBA(1,.5,.5,1))
            .translate(float3(-100, -50, 0))
            .scale(float3(30,30,30));
    }
    Cube createCube(Cube.Kind kind, float lineWidth = 1.0f) {
        this.cubeRotations ~= uniform(0,360).degrees;
        return new Cube(context, kind, context.images().get("123456.png"), lineWidth)
            .camera(camera3D);
    }
    void createCamera() {
        this.camera3D = Camera3D.forVulkan(vk.windowSize, float3(0f, 0f, 150f), float3(0f,0f,0f));
        camera3D.fovNearFar(60.degrees(), 0.01f, 1000.0f);
        this.log("camera3D = %s", camera3D);
        this.log("fov,near,far = %s, %s, %s", camera3D.fov.radians, camera3D.near, camera3D.far);
        this.log("V = \n%s", camera3D.V());
        this.log("P = \n%s", camera3D.P());
        this.log("VP = \n%s", camera3D.VP());
    }
    void createModel3D() {
        auto objModel = Obj.read("resources/models/suzanne.obj.txt");
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
                .withAll(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                .withoutAll(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)
                .maxHeapSize();

        this.log("Max local memory = %s MBs", maxLocal / 1.MB);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("G3D_Local", 128.MB))
            //.withMemory(MemID.SHARED, mem.allocStdShared("G3D_Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("G3D_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 10.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VK_BUFFER_USAGE_INDEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 16.MB);

        context.withFonts("resources/fonts/")
               .withImages("resources/images/")
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
            attachmentReference(0, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL)
        ];

        auto depthStencilAttachment = attachmentReference(1, VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL);

        auto subpass = subpassDescription((info) {
            info.colorAttachmentCount    = colorAttachmentRefs.length.as!int;
            info.pColorAttachments       = colorAttachmentRefs.ptr;
            info.pDepthStencilAttachment = &depthStencilAttachment;
        });

        // These may not be optimal but the validation warnings are gone :)
        VkSubpassDependency d = {
            srcSubpass: VK_SUBPASS_EXTERNAL,
            dstSubpass: 0,
            srcStageMask: VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
            srcAccessMask: VK_ACCESS_MEMORY_READ_BIT,
            dstStageMask: 
                VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT | 
                VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT | 
                VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT,
            dstAccessMask: 
                VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | 
                VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT | 
                VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT,
            dependencyFlags: VkDependencyFlagBits.VK_DEPENDENCY_BY_REGION_BIT
        };
        VkSubpassDependency d2 = {
            srcSubpass: 0,
            dstSubpass: VK_SUBPASS_EXTERNAL,
            srcStageMask: 
                VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT | 
                VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT,
            srcAccessMask: 
                VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | 
                VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT | 
                VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT,
            dstStageMask: VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
            dstAccessMask: VK_ACCESS_MEMORY_READ_BIT,
            dependencyFlags: VkDependencyFlagBits.VK_DEPENDENCY_BY_REGION_BIT
        };

        this.renderPass = .createRenderPass(
            device,
            attachmentDescs,
            [subpass],
            [d, d2]
        );
    }
}
