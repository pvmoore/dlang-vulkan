module test_gui;

import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.stdio  : writefln;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

import vulkan.all;
import vulkan.gui;

final class TestGUI : VulkanApplication {
    Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    GUI gui;
    FPS fps;
    Camera2D camera;

    VkClearValue bgColour;

    this() {
        enum NAME = "Vulkan 2D GUI Test";
        WindowProperties wprops = {
            width:          1400,
            height:         800,
            fullscreen:     false,
            vsync:          false,
            title:          NAME,
            icon:           "/pvmoore/_assets/icons/3dshapes.png",
            showWindow:     false,
            frameBuffers:   3
        };
        VulkanProperties vprops = {
            appName: NAME
        };

		this.vk = new Vulkan(this, wprops, vprops);
        vk.initialise();
        this.log("screen = %s", vk.windowSize);

        import std : fromStringz, format;
        import core.cpuid: processor;
        string gpuName = cast(string)vk.properties.deviceName.ptr.fromStringz;
        vk.setWindowTitle(NAME ~ " :: %s, %s".format(gpuName, processor()));

        vk.showWindow();
    }
    override void destroy() {
	    if(!vk) return;
	    if(device) {
	        vkDeviceWaitIdle(device);

            if(context) context.dumpMemory();

            if(gui) gui.destroy();
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
        gui.beforeRenderPass(frame);
        fps.beforeRenderPass(frame, vk.getFPS);
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
            VSubpassContents.INLINE
            //VSubpassContents.SECONDARY_COMMAND_BUFFERS
        );

        gui.insideRenderPass(frame);
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
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("G2D_Local", 256.MB))
          //.withMemory(MemID.SHARED, mem.allocStdShared("G2D_Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("G2D_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VBufferUsage.VERTEX | VBufferUsage.TRANSFER_DST, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VBufferUsage.INDEX | VBufferUsage.TRANSFER_DST, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VBufferUsage.UNIFORM | VBufferUsage.TRANSFER_DST, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VBufferUsage.TRANSFER_SRC, 32.MB);

        context.withFonts("/pvmoore/_assets/fonts/hiero/")
               .withImages("/pvmoore/_assets/images")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        this.gui = new GUI(context);
        gui.camera(camera);

        this.fps = new FPS(context);

        this.bgColour = clearColour(0.0f,0,0,1);

        gui.getStage()
           .add(new Main());
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
    final class Main : Widget {
        override void destroy() {

        }
        override void update(Frame frame) {

        }
        override void render(Frame frame) {

        }
        override void onAddedToStage(Stage stage) {
            auto label1 = new Label("Hello")
                .setRelPos(int2(10,10))
                .setSize(int2(200, 15));
            auto label2 = new Label("ld a, (hl)")
                .setRelPos(int2(10,35))
                .setSize(int2(200, 15));
            auto label3 = new Label("ld a, (hl)")
                .setHAlign(HAlign.LEFT).as!Label
                .setRelPos(int2(10,60))
                .setSize(int2(200, 15));
            auto label4 = new Label("ld a, (hl)")
                .setHAlign(HAlign.RIGHT)
                .setVAlign(VAlign.BOTTOM).as!Label
                .setRelPos(int2(10,85))
                .setSize(int2(200, 40));
            auto label5 = new Label("ld a, (hl)")
                .setHAlign(HAlign.RIGHT)
                .setVAlign(VAlign.TOP).as!Label
                .setFontName("dejavusansmono")
                .setFgColour(float4(1,1,0,1))
                .setRelPos(int2(10,130))
                .setSize(int2(200, 40));
            add(label1);
            add(label2);
            add(label3);
            add(label4);
            add(label5);

            auto b1 = new Button("Step")
                .setRelPos(int2(250,30))
                .setSize(int2(50,20))
                .setBorderSize(1);

            auto b2 = new Button("Step")
                .setRelPos(int2(250,60))
                .setSize(int2(70,30))
                .setBorderSize(2);

            auto b3 = new Button("Step")
                .setRelPos(int2(250,100))
                .setSize(int2(100,40))
                .setBorderSize(3);

           auto b4 = new Button("Step")
                .setType(Button.Type.TOGGLE)
                .setClicked(true)
                .setRelPos(int2(250,160))
                .setSize(int2(100,40))
                .setBgColour(RGBA(0.6,0.3,0,1))
                .setBorderSize(3);

            b3.register(GUIEventType.PRESS, (e) {
                log("b3 pressed");
            });
            b4.register(GUIEventType.PRESS, (e) {
                auto evt = e.as!OnPress;
                auto b = e.getWidget().as!Button;
                log("b4 pressed = %s", evt.isPressed());
            });

            add(b1);
            add(b2);
            add(b3);
            add(b4);
        }
    }
}