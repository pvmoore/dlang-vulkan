module test_graphics2D;

import vulkan.all;

final class TestGraphics2D : VulkanApplication {
    Vulkan vk;
	VkDevice device;
    VulkanContext context;

    VkRenderPass renderPass;
    VkSampler sampler;
    Camera2D camera;
    Quad quad1, quad2, quad3;
    Text text;
    FPS fps;
    Rectangles rectangles;
    RoundRectangles roundRectangles;
    Circles circles;
    Lines lines;
    Points points;

	this() {
        WindowProperties wprops = {
            width: 1400,
            height: 800,
            fullscreen: false,
            vsync: false,
            title: "Vulkan 2D Graphics Test",
            icon: "/pvmoore/_assets/icons/3dshapes.png",
            showWindow: false,
            frameBuffers: 3
        };
        VulkanProperties vprops = {
            appName: "Vulkan 2D Graphics Test"
        };

        //vprops.layers ~= "VK_LAYER_LUNARG_monitor".ptr;

		vk = new Vulkan(this, wprops, vprops);
        vk.initialise();
        this.log("screen = %s", vk.windowSize);

        import std : fromStringz, format;
        import core.cpuid: processor;
        string gpuName = cast(string)vk.properties.deviceName.ptr.fromStringz;
        vk.setWindowTitle("Vulkan 2D Graphics Test :: %s, %s".format(gpuName, processor()));

        vk.showWindow();
	}
	override void destroy() {
	    if(!vk) return;
	    if(device) {
	        vkDeviceWaitIdle(device);

            if(context) context.dumpMemory();

	        if(quad1) quad1.destroy();
	        if(quad2) quad2.destroy();
            if(quad3) quad3.destroy();
	        if(text) text.destroy();
	        if(fps) fps.destroy();
	        if(rectangles) rectangles.destroy();
	        if(roundRectangles) roundRectangles.destroy();
            if(circles) circles.destroy();
	        if(lines) lines.destroy();
            if(points) points.destroy();
            if(sampler) device.destroySampler(sampler);
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
        text.beforeRenderPass(frame);
        fps.beforeRenderPass(frame, vk.getFPS);
        rectangles.beforeRenderPass(frame);
        roundRectangles.beforeRenderPass(frame);
        circles.beforeRenderPass(frame);
        lines.beforeRenderPass(frame);
        points.beforeRenderPass(frame);
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
            [ clearColour(0.2f,0,0,1) ],
            VSubpassContents.INLINE
            //VSubpassContents.SECONDARY_COMMAND_BUFFERS
        );

        quad1.insideRenderPass(frame);
        quad2.insideRenderPass(frame);
        quad3.insideRenderPass(frame);

        rectangles.insideRenderPass(frame);
        roundRectangles.insideRenderPass(frame);
        circles.insideRenderPass(frame);
        lines.insideRenderPass(frame);
        points.insideRenderPass(frame);

        text.insideRenderPass(frame);
        fps.insideRenderPass(frame);

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
        this.camera = Camera2D.forVulkan(vk.windowSize);

        auto mem = new MemoryAllocator(vk);


        auto maxLocal =
            mem.builder(0)
                .withAll(VMemoryProperty.DEVICE_LOCAL)
                .withoutAll(VMemoryProperty.HOST_VISIBLE)
                .maxHeapSize();

        this.log("Max local memory = %s MBs", maxLocal / 1.MB);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("G2D_Local", 128.MB))
            .withMemory(MemID.SHARED, mem.allocStdShared("G2D_Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("G2D_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VBufferUsage.VERTEX | VBufferUsage.TRANSFER_DST, 1.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VBufferUsage.INDEX | VBufferUsage.TRANSFER_DST, 1.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VBufferUsage.UNIFORM | VBufferUsage.TRANSFER_DST, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VBufferUsage.TRANSFER_SRC, 32.MB);

        context.withFonts("/pvmoore/_assets/fonts/hiero/")
               .withImages("/pvmoore/_assets/images")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        createSampler();
        addQuadsToScene();

        this.text = new Text(context, context.fonts.get("segoeprint"), true, 2000);
        text.setCamera(camera);
        text.setSize(16);
        text.setColour(WHITE*1.1);
        text.setDropShadowColour(RGBA(0,0,0, 0.8));
        text.setDropShadowOffset(vec2(-0.0025, 0.0025));
        foreach(i; 0..19) {
            text.setColour(RGBA(i/19.0f,0.5+i/40.0f,1,1)*1.1);
            text.appendText("Hello there I am some text...", 10, 110+i*20);
        }

        fps = new FPS(context);

        addRectanglesToScene();
        addRoundRectanglesToScene();
        addCirclesToScene();
        addLinesToScene();
        addPointsToScene();
    }
    void addQuadsToScene() {
        this.log("Adding quads to scene");
        quad1 = new Quad(context, context.images.get("bmp/goddess_abgr.bmp"), sampler);
        auto scale = Matrix4.scale(Vector3(100,100,0));
        auto trans = Matrix4.translate(Vector3(515,10,0));
        quad1.setVP(trans*scale, camera.V, camera.P);
        //quad1.setColour(RGBA(1,1,1,0.1));
        //quad1.setUV(UV(1,1), UV(0,0));

        this.log("camera.model = \n%s", trans*scale);
        this.log("camera.view = \n%s", camera.V);
        this.log("camera.proj = \n%s", camera.P);

        quad2 = new Quad(context, context.images.get("png/rock3.png"), sampler);
        auto scale2 = Matrix4.scale(Vector3(100,100,0));
        auto trans2 = Matrix4.translate(Vector3(10,10,0));
        quad2.setVP(trans2*scale2, camera.V, camera.P);
        //quad2.setColour(BLUE.xyz);

        quad3 = new Quad(context, context.images.get("dds/rock5.dds"), sampler);
        auto scale3 = Matrix4.scale(Vector3(150,150,0));
        auto trans3 = Matrix4.translate(Vector3(715,10,0));
        quad3.setVP(trans3*scale3, camera.V, camera.P);
    }
    void addRectanglesToScene() {
        this.log("Adding rectangles to scene");

        this.rectangles = new Rectangles(context, 10);
        rectangles.setCamera(camera);
        rectangles.setColour(WHITE)
                  .addRect(vec2(300,200),
                           vec2(400,200),
                           vec2(400,300),
                           vec2(300,300))
                  .setColour(YELLOW)
                  .addRect(vec2(450,200),
                           vec2(550,250),
                           vec2(480,300),
                           vec2(420,230),
                           WHITE, BLUE, RED, GREEN);
    }
    void addRoundRectanglesToScene() {
        this.log("Adding round rectangles to scene");

        enum orange = RGBA(0.7,0.4,0.1,1)*0.75;
        enum black  = RGBA(0,0,0,0);

        roundRectangles = new RoundRectangles(context, 10)
            .setCamera(camera)
            .setColour(RGBA(0.3, 0.5, 0.7, 1))
            .addRect(vec2(650,350), vec2(150,100), 7)
            .addRect(vec2(650,200), vec2(150,100),
                orange,orange*3,
                orange,orange*3,
                30)
            .addRect(vec2(820,200), vec2(150,100),
                orange*3,orange*3,
                orange,orange,
                30)
            // capsule
            .addRect(vec2(1000,220), vec2(150,60),
                WHITE,WHITE,
                black,black,
                30)
            .addRect(vec2(1000,220), vec2(150,60),
                black,black,
                WHITE,WHITE,
                30)
            // white border
            .addRect(vec2(1170,200), vec2(150,100),
                WHITE*0.8, WHITE,
                WHITE*0.8,black+0.5,
                32)
            .addRect(vec2(1175,204), vec2(140,92),
                orange, orange,
                orange,orange,
                30)
            ;
    }
    void addCirclesToScene() {
        this.circles = new Circles(context, 20);

        circles.camera(camera)
               .borderColour(WHITE)
               .colour(RED)
               .borderRadius(1.5f);
        circles.add(float2(100f,600f), 4f);
        circles.add(float2(110f,600f), 8f);
        circles.add(float2(130f,600f), 16f);
        circles.borderRadius(4f)
               .add(float2(170f,600f), 32f);
        circles.borderRadius(8f)
               .add(float2(240f,600f), 64f);
        circles.borderRadius(16f)
               .add(float2(370f,600f), 128f);
    }
    void addLinesToScene() {
        this.lines = new Lines(context, 10);

        lines.camera(camera)
             .fromColour(WHITE)
             .toColour(WHITE)
             .thickness(1);

        lines.add(float2(600f, 510f), float2(800f, 530f));

        lines.add(float2(600f, 520f), float2(800f, 550f), YELLOW, GREEN, 4f, 4f);

        lines.add(float2(600f, 540f), float2(800f, 600f), WHITE, BLUE.merge(MAGENTA), 8, 8);

        lines.add(float2(600, 570), float2(800, 650), GREEN, WHITE, 1, 32);

        lines.add(float2(600, 620), float2(800, 720), YELLOW, CYAN, 32, 32);
    }
    void addPointsToScene() {
        this.points = new Points(context, 100);

        auto w = float4(1,1,1,1);

        points.camera(camera);

        points.add(float2(986, 500), 1, w);
        points.add(float2(992, 500), 2, w);
        points.add(float2(1000, 500), 3, w);
        points.add(float2(1011, 500), 5, w);
        points.add(float2(1028, 500), 8, w);
        auto id = points.add(float2(1052, 500), 12, float4(1,0.8,0.2,1));
        points.add(float2(1086, 500), 17, w);

        points.setEnabled(id, false);
        points.setEnabled(id, true);
    }
    void createSampler() {
        this.log("Creating sampler");
        sampler = device.createSampler(samplerCreateInfo());
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

