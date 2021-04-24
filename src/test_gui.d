module test_gui;

import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.stdio  : writefln;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

import vulkan.all;

final class TestGUI : VulkanApplication {
    Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    FPS fps;
    Canvas2D canvas;
    Camera2D camera;
    VkSampler sampler;

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

            if(canvas) canvas.destroy();
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
        fps.beforeRenderPass(frame, vk.getFPS);
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
            [ bgColour ],
            VSubpassContents.INLINE
            //VSubpassContents.SECONDARY_COMMAND_BUFFERS
        );

        canvas.insideRenderPass(frame);
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
          //.withMemory(MemID.SHARED, mem.allocStdShared("G2D_Shared", 128.MB))
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
        createCanvas();

        this.fps = new FPS(context);

        this.bgColour = clearColour(0.0f,0,0,1);
    }
    void createCanvas() {
        this.canvas = new Canvas2D(context, context.images().get("bmp/goddess_abgr.bmp"))
            .withMaxLines(100)
            .withMaxCircles(200)
            .withMaxRectangles(100)
            .withMaxRoundRectangles(100)
            .withMaxPoints(100)
            .withMaxQuads(100)
            .camera(camera)
            .colour(float4(1,1,1,1))
            .lineThickness(1.5);
    }
    void createSampler() {
        this.log("Creating sampler");
        this.sampler = device.createSampler(samplerCreateInfo());
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