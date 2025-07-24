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
            icon:           "resources/images/logo.png",
            showWindow:     false,
            frameBuffers:   3,
            titleBarFps:    true
        };
        VulkanProperties vprops = {
            appName: NAME
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
    override void deviceReady(VkDevice device) {
        this.device = device;
        initScene();
    }
    void update(Frame frame) {
        gui.beforeRenderPass(frame);
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
        );

        gui.insideRenderPass(frame);
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
        this() {
            this.props = new GUIProps(null);
        }
        override void destroy() {

        }
        override void onUpdate(Frame frame, UpdateState state) {
            switch(state) with(UpdateState) {
            case INIT: initialise(); break;
            case UPDATE: update(); break;
            default:
                break;
        }
        }
        override void onRender(Frame frame) {

        }
    private:
        void initialise() {
            auto stage = getStage();
            auto label1 = new Label("Hello")
                .setRelPos(int2(10,10))
                .setSize(uint2(200, 15));
            auto label2 = new Label("ld a, (hl)")
                .setRelPos(int2(10,35))
                .setSize(uint2(200, 15));
            auto label3 = new Label("ld a, (hl)")
                .setHAlign(HAlign.LEFT).as!Label
                .setRelPos(int2(10,60))
                .setSize(uint2(200, 15));
            auto label4 = new Label("ld a, (hl)")
                .setHAlign(HAlign.RIGHT)
                .setVAlign(VAlign.BOTTOM).as!Label
                .setRelPos(int2(10,85))
                .setSize(uint2(200, 40));
            auto label5 = new Label("ld a, (hl)")
                .setHAlign(HAlign.RIGHT)
                .setVAlign(VAlign.TOP).as!Label
                .setRelPos(int2(10,130))
                .setSize(uint2(200, 40));
            label5.props
                .setFontName("dejavusansmono")
                .setFgColour(float4(1,1,0,1));
            add(label1);
            add(label2);
            add(label3);
            add(label4);
            add(label5);

            auto b1 = new Button("Step")
                .setRelPos(int2(250,30))
                .setSize(uint2(50,20));
            b1.props.setBorderSize(1);

            auto b2 = new Button("Step")
                .setRelPos(int2(250,60))
                .setSize(uint2(70,30));
            b2.props.setBorderSize(2);

            auto b3 = new Button("Step")
                .setRelPos(int2(250,100))
                .setSize(uint2(100,40))
                .as!Button;
            b3.props.setBorderSize(3);

            b3.onPress((b,p) {
                log("b3 pressed");
            });

            auto t1 = new ToggleButton("One", "1")
                .setRelPos(int2(250,160))
                .setSize(uint2(100,40))
                .as!Button;
            t1.props
                .setBorderSize(3)
                .setBgColour(RGBA(0.6,0.3,0,1));

            auto t2 = new ToggleButton("Two", "2")
                .setRelPos(int2(355,160))
                .setSize(uint2(100,40))
                .as!Button;
            t2.props
                .setBorderSize(3)
                .setBgColour(RGBA(0.6,0.3,0,1));

            auto t3 = new ToggleButton("Three", "3")
                .setRelPos(int2(460,160))
                .setSize(uint2(100,40))
                .as!Button;
            t3.props
                .setBorderSize(3)
                .setBgColour(RGBA(0.6,0.3,0,1));

            t1.onPress((b,p) {
                log("t1 press %s", p);
            });
            t2.onPress((w,p) {
                log("t2 press %s", p);
            });
            t3.onPress((w,p) {
                log("t3 press %s", p);
            });

            auto tg = new ToggleGroup()
                .add(t1)
                .add(t2)
                .add(t3);

            tg.setToggled(t1);

            tg.onToggle((tb) {
                log("selected toggle %s", tb.getText());
            });

            add(b1);
            add(b2);
            add(b3);
            add(t1);
            add(t2);
            add(t3);

            // Tabs
            auto tabBar = new TabBar()
                .setRelPos(int2(10, 300));

            auto tab1 = new Tab("One")
                .setRelPos(int2(5,5));

            add(tabBar);

            tabBar.add(tab1);
        }
        void update() {
            auto stage = getStage();

        }
    }
}
