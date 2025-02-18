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
    Quads quads;
    //Text text;
    FPS fps;
    Rectangles rectangles;
    RoundRectangles roundRectangles;
    Circles circles;
    Lines lines;
    Points points;
    RendererFactory canvas;

	this() {
        WindowProperties wprops = {
            width:        1600,
            height:       1024,
            fullscreen:   false,
            vsync:        false,
            title:        "Vulkan 2D Graphics Test",
            icon:         "resources/images/logo.png",
            showWindow:   false,
            frameBuffers: 3
        };
        VulkanProperties vprops = {
            apiVersion: vulkanVersion(1,1,0),
            appName: "Vulkan 2D Graphics Test",
            shaderSrcDirectories: ["shaders/"],
            shaderDestDirectory:  "resources/shaders/",
            shaderSpirvVersion:   "1.3"
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

            if(canvas) canvas.destroy();
            if(quads) quads.destroy();
	        if(quad1) quad1.destroy();
	        if(quad2) quad2.destroy();
            if(quad3) quad3.destroy();
	        //if(text) text.destroy();
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
        //text.beforeRenderPass(frame);
        fps.beforeRenderPass(frame, vk.getFPSSnapshot());
        rectangles.beforeRenderPass(frame);
        roundRectangles.beforeRenderPass(frame);
        circles.beforeRenderPass(frame);
        lines.beforeRenderPass(frame);
        points.beforeRenderPass(frame);
        quads.beforeRenderPass(frame);
        canvas.beforeRenderPass(frame);
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
            VK_SUBPASS_CONTENTS_INLINE
            //VkSubpassContents.VK_SUBPASS_SECONDARY_COMMAND_BUFFERS
        );

        quads.insideRenderPass(frame);
        quad1.insideRenderPass(frame);
        quad2.insideRenderPass(frame);
        quad3.insideRenderPass(frame);

        rectangles.insideRenderPass(frame);
        roundRectangles.insideRenderPass(frame);
        circles.insideRenderPass(frame);
        lines.insideRenderPass(frame);
        points.insideRenderPass(frame);

        canvas.insideRenderPass(frame);

        //text.insideRenderPass(frame);
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
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("G2D_Local", 128.MB))
           // .withMemory(MemID.SHARED, mem.allocStdShared("G2D_Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("G2D_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VK_BUFFER_USAGE_INDEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 32.MB);

        context.withFonts("resources/fonts/")
               .withImages("resources/images/")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        createSampler();

        fps = new FPS(context);

        //addTextToScreen();
        addQuadsToScene();
        addRectanglesToScene();
        addRoundRectanglesToScene();
        addCirclesToScene();
        addLinesToScene();
        addPointsToScene();
        addCanvasToScene();
    }
    // void addTextToScreen() {

    // }
    void addQuadsToScene() {
        this.log("Adding quads to scene");

        this.quads = new Quads(context, context.images.get("goddess_abgr.bmp"), sampler, 10);
        quads.camera(camera)
             .setSize(float2(100,100))
             .setColour(float4(1,1,1,1))
             .setRotation(0.degrees.radians);

        uint x = 10;
        quads.add(float2(x+=115,10));
        auto id = quads.add(float2(x+=115,10));
        quads.add(float2(x+=115,10));

        quads.setEnabled(id, false);
        quads.setEnabled(id, true);
        quads.setSize(id, float2(80,80))
             .setColour(id, float4(1,0.8,0.2,1));


        quad1 = new Quad(context, context.images.get("goddess_abgr.bmp"), sampler);
        auto scale = Matrix4.scale(float3(100,100,0));
        auto trans = Matrix4.translate(float3(515,10,0));
        quad1.setVP(trans*scale, camera.V, camera.P);
        //quad1.setColour(RGBA(1,1,1,0.1));
        //quad1.setUV(UV(1,1), UV(0,0));

        this.log("camera.model = \n%s", trans*scale);
        this.log("camera.view = \n%s", camera.V);
        this.log("camera.proj = \n%s", camera.P);

        quad2 = new Quad(context, context.images.get("rock3.png"), sampler);
        auto scale2 = Matrix4.scale(float3(100,100,0));
        auto trans2 = Matrix4.translate(float3(10,10,0));
        quad2.setVP(trans2*scale2, camera.V, camera.P);
        //quad2.setColour(BLUE.xyz);

        quad3 = new Quad(context, context.images.get("rock5.dds"), sampler);
        auto scale3 = Matrix4.scale(float3(150,150,0));
        auto trans3 = Matrix4.translate(float3(630,10,0));
        quad3.setVP(trans3*scale3, camera.V, camera.P);
    }
    void addRectanglesToScene() {
        this.log("Adding rectangles to scene");

        this.rectangles = new Rectangles(context, 10);
        rectangles.camera(camera);
        rectangles.setColour(WHITE)
                  .add(vec2(800,10),
                       vec2(900,10),
                       vec2(900,110),
                       vec2(800,110));

        rectangles.setColour(YELLOW)
                  .add(vec2(850, 30),
                       vec2(950, 80),
                       vec2(880, 130),
                       vec2(820, 50),
                       WHITE, BLUE, RED, GREEN);
    }
    void addRoundRectanglesToScene() {
        this.log("Adding round rectangles to scene");

        enum orange = RGBA(0.7,0.4,0.1,1)*0.75;
        enum black  = RGBA(0,0,0,0);

        float x = 300;

        roundRectangles = new RoundRectangles(context, 10)
            .camera(camera);

        roundRectangles
            .add(float2(x, 200), float2(150,100),
                orange,orange*3,
                orange,orange*3,
                30);
        roundRectangles
            .add(float2(x + 170, 200), float2(150,100),
                orange*3,orange*3,
                orange,orange,
                30);
            // capsule
        roundRectangles
            .add(float2(x + 350, 220), float2(150,60),
                WHITE,WHITE,
                black,black,
                30);
        roundRectangles
            .add(float2(x + 350 ,220), float2(150,60),
                black,black,
                WHITE,WHITE,
                30);
            // white border
        roundRectangles
            .add(float2(x + 520, 200), float2(150,100),
                WHITE*0.8, WHITE,
                WHITE*0.8,black+0.5,
                32);
        roundRectangles
            .add(float2(x + 525, 204), float2(140,92),
                orange, orange,
                orange,orange,
                30);
        roundRectangles
            .setColour(RGBA(0.3, 0.5, 0.7, 1))
            .add(float2(x + 700, 200), float2(150,100), 7);
    }
    void addCirclesToScene() {
        this.circles = new Circles(context, 20);

        circles.camera(camera)
               .borderColour(WHITE)
               .colour(RED)
               .borderRadius(1.5f);

        float x = 10;
        float y = 500;

        circles.add(float2(x,y), 4f);
        circles.add(float2(x+10,y), 8f);
        circles.add(float2(x+30,y), 16f);
        circles.borderRadius(4f)
               .add(float2(x+70,y), 32f);
        circles.borderRadius(8f)
               .add(float2(x+140,y), 64f);
        circles.borderRadius(16f)
               .add(float2(x+270,y), 128f);
    }
    void addLinesToScene() {
        this.lines = new Lines(context, 10);

        lines.camera(camera)
             .fromColour(WHITE)
             .toColour(WHITE)
             .thickness(1);

        float x = 1100;
        float y = 10;

        lines.add(float2(x, y), float2(x+150, y+20));

        lines.add(float2(x, y+10), float2(x+150, y+40), YELLOW, GREEN, 4f, 4f);

        lines.add(float2(x, y+40), float2(x+150, y+90), WHITE, BLUE.merge(MAGENTA), 8, 8);

        lines.add(float2(x, y+70), float2(x+150, y+140), GREEN, WHITE, 1, 32);

        lines.add(float2(x, y+120), float2(x+150, y+210), YELLOW, CYAN, 32, 32);
    }
    void addPointsToScene() {
        this.points = new Points(context, 100);

        auto w = float4(1,1,1,1);

        points.camera(camera);

        float x = 960;
        float y = 50;

        points.add(float2(x,  y), 1, w);
        points.add(float2(x+8,  y), 2, w);
        points.add(float2(x+18, y), 3, w);
        points.add(float2(x+31, y), 5, w);
        points.add(float2(x+50, y), 8, w);
        auto id = points.add(float2(x+72, y), 12, float4(1,0.8,0.2,1));
        points.add(float2(x+102, y), 17, w);

        points.setEnabled(id, false);
        points.setEnabled(id, true);
    }
    void addCanvasToScene() {
        const imageName = "goddess_abgr.bmp";
        const fontName = "segoeprint";

        RendererFactory.Properties rfProps = {
            maxLines: 100,
            maxCircles: 200,
            maxRectangles: 100,
            maxRoundRectangles: 100,
            maxPoints: 100,
            maxQuads: 100,
            maxCharacters: 1000,
            imageMaxQuads: [imageName : 100],
            fontMaxCharacters: [fontName : 1000]
        };

        this.canvas = new RendererFactory(context, rfProps)
            .camera(camera);

        foreach(i; 0..100) {
            { // lines
                float x = 300;
                float y = 320;

                float x1 = uniform(0, 200),
                      x2 = uniform(0, 200);
                float y1 = uniform(0, 200),
                      y2 = uniform(0, 200);
                float th = uniform(1.5f, 5f);
                auto col = float4(uniform(0f,1f), uniform(0f,1f), uniform(0f,1f), 1);

                canvas.getLines().add(float2(x+x1, y+y1), float2(x+x2,y+ y2),
                    col, col, th, th);
            }
            { // circles
                float x = 300;
                float y = 550;
                float x1 = uniform(0, 200);
                float y1 = uniform(0, 200);
                float r = uniform(10f, 40f);
                float th = uniform(1.5f, 5f);
                auto col = float4(uniform(0f,1f), uniform(0f,1f), uniform(0f,1f), 1);

                canvas.getCircles().add(float2(x+x1, y+y1), r, th, float4(0,0,0,0), col);
            }
            { // filled circles
                float x = 550;
                float y = 320;
                float x1 = uniform(0, 200);
                float y1 = uniform(0, 200);
                float r = uniform(10f, 40f);
                float th = uniform(1.5f, 5f);
                auto col = float4(uniform(0f,1f), uniform(0f,1f), uniform(0f,1f), 1);

                canvas.getCircles().add(float2(x+x1, y+y1), r, th, col, float4(1,1,1,1));
            }
            { // rectangles

                float2[4] _generateVertices() {
                    const x = 550 + uniform(0, 160);
                    const y = 550 + uniform(0, 160);
                    const a = float2(x + uniform(0, 80), y + uniform(0, 80));
                    const b = float2(x + uniform(0, 80), y + uniform(0, 80));
                    const c = float2(x + uniform(0, 80), y + uniform(0, 80));
                    const d = float2(x + uniform(0, 80), y + uniform(0, 80));

                    float2[4] p = [a,b,c,d];

                    int count = 0;
                    bool flag = true;
                    while(flag) {
                        flag = false;
                        if(p[2].isLeftOfLine(p[1], p[0])) {
                            swap(p[1], p[2]);
                            flag = true;
                        }
                        if(p[3].isLeftOfLine(p[2], p[0])) {
                            swap(p[2], p[3]);
                            flag = true;
                        }
                        if(count++ > 5) break;
                    }
                    return p;
                }

                float2[4] p = _generateVertices();
                auto col = float4(uniform(0f,1f), uniform(0f,1f), uniform(0f,1f), 1);

                canvas.getRectangles()
                      .add(p[0], p[1], p[2], p[3],
                            col, col, col, col);
            }
            { // round rectangle
                float x = 800;
                float y = 320;
                float2 p = float2(x + uniform(0, 200), y + uniform(0, 200));
                float2 s = float2(uniform(10, 70), uniform(10, 70));
                float cr = 15;
                auto col = float4(uniform(0f,1f), uniform(0f,1f), uniform(0f,1f), 1);

                canvas.getRoundRectangles()
                      .add(p, s, col, col, col, col, cr);
            }
            { // points
                float x = 800;
                float y = 570;
                float2 p = float2(x + uniform(0, 200), y + uniform(0, 200));
                float s = uniform(1f, 10f);
                auto col = float4(uniform(0f,1f), uniform(0f,1f), uniform(0f,1f), 1);

                canvas.getPoints().add(p, s, col);
            }
            { // quads
                float x = 1050;
                float y = 320;
                float2 p = float2(x + uniform(0, 250), y + uniform(0, 400));
                float s  = uniform(20f, 100f);
                float r  = uniform(0f, 360.degrees.radians);
                auto col = float4(uniform(0f,1f), uniform(0f,1f), uniform(0f,1f), 1);

                canvas.getQuads(imageName)
                    .add(p, float2(s,s), float4(0,0,1,1), col, r);
            }
        }

        auto text = canvas.getText(fontName);
        text.setSize(16);
        text.setColour(WHITE*1.1);
        text.setDropShadowColour(RGBA(0,0,0, 0.8));
        text.setDropShadowOffset(vec2(-0.0025, 0.0025));

        foreach(i; 0..10) {
            text.setColour(RGBA(i/10.0f,0.5+i/40.0f,1,1)*1.1);
            text.add("Hello there I am some text...", 10, 110+i*20);
        }
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

