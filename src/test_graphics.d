module test_graphics;
/**
 *
 */
import vulkan;
import test;
import common : Implements;
import resources : PNG;
import std.stdio : writefln;
import core.sys.windows.windows : HINSTANCE;

import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.utf	  : toUTF16z;
import std.format : format;

import vulkan;
import common;
import logging;

pragma(lib, "user32.lib");

//extern(C) __gshared string[] rt_options = [
//    "gcopt=profile:1"
//];

extern(Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow) {
	int result = 0;
	TestGraphics app;
	try{
        Runtime.initialize();

        app = new TestGraphics();
		app.run();
    }catch(Throwable e) {
		log("exception: %s", e.msg);
		MessageBoxA(null, e.toString().toStringz, "Error", MB_OK | MB_ICONEXCLAMATION);
		result = -1;
    }finally{
		flushLog();
		if(app) app.destroy();
		Runtime.terminate();
	}
	flushLog();
    return result;
}
//--------------------------------------------------------
final class TestGraphics : VulkanApplication {
    // stuff managed by our Vulkan class
	VkDevice device;
    DeviceImage image1;
    DeviceImage image2;
    VkSampler sampler;

    // stuff we need to manage
    Vulkan vk;
    VkRenderPass renderPass;

    Camera2D camera;
    Quad quad1;
    Quad quad2;
    Text text;
    FPS fps;
    Rectangles rectangles;
    RoundRectangles roundRectangles;

	this() {
        WindowProperties wprops = {
            width: 1400,
            height: 800,
            fullscreen: false,
            vsync: false,
            title: "Vulkan Graphics Test",
            icon: "/pvmoore/_assets/icons/3dshapes.png",
            showWindow: false,
            frameBuffers: 3
        };
        VulkanProperties vprops = {
            appName: "Vulkan Graphics Test",
            deviceMemorySizeMB: 128,
            requiredComputeQueues: 1
        };

        vprops.features.geometryShader = VK_TRUE;

		vk = new Vulkan(
		    this,
		    wprops,
		    vprops
        );
        vk.initialise();
        vk.setDesiredMaximumFPS(240);
        log("screen = %s", vk.windowSize);

        vk.showWindow();
	}
	void destroy() {
	    if(!vk) return;
	    if(device) {
	        vkDeviceWaitIdle(device);
	        //vk.memory.dumpStats();
	        if(quad1) quad1.destroy();
	        if(quad2) quad2.destroy();
	        if(text) text.destroy();
	        if(fps) fps.destroy();
	        if(rectangles) rectangles.destroy();
	        if(roundRectangles) roundRectangles.destroy();
	        if(sampler) device.destroy(sampler);
	        if(renderPass) device.destroy(renderPass);
	        vk.memory.dumpStats();
	    }
		vk.destroy();
	}
    void run() {
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
    void update(FrameInfo frame, PerFrameResource res) {
        text.beforeRenderPass(res);
        fps.beforeRenderPass(res, vk.getFPS);
        rectangles.beforeRenderPass(res);
        roundRectangles.beforeRenderPass(res);
    }
	override void render(
        FrameInfo frame,
        PerFrameResource res)
    {
	    auto b = res.adhocCB;
	    b.beginOneTimeSubmit();

        update(frame, res);

        // begin the render pass
        b.beginRenderPass(
            renderPass,
            res.frameBuffer,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            [ clearColour(0.2f,0,0,1) ],
            VSubpassContents.INLINE
            //VSubpassContents.SECONDARY_COMMAND_BUFFERS
        );

        quad1.insideRenderPass(res);
        quad2.insideRenderPass(res);

        rectangles.insideRenderPass(res);
        roundRectangles.insideRenderPass(res);

        text.insideRenderPass(res);
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
    //void updateUniforms() {
        //vk.memory.copyToDevice(uniformBuffer, &ubo);

        //pushConstants.colour = Vector4(1,0,0,1);
    //}
    void initScene() {
        camera = Camera2D.forVulkan(vk.windowSize);

        createTexture();
        createSampler();

        quad1 = new Quad(
            vk,
            renderPass,
            image1,
            sampler
        );
        auto scale = Matrix4.scale(Vector3(100,100,0));
        auto trans = Matrix4.translate(Vector3(515,10,0));
        quad1.setVP(trans*scale, camera.V, camera.P);
        //quad1.setColour(RGBA(1,1,1,0.1));
        //quad1.setUV(UV(1,1), UV(0,0));

        quad2 = new Quad(
            vk,
            renderPass,
            image2,
            sampler
        );
        auto scale2 = Matrix4.scale(Vector3(100,100,0));
        auto trans2 = Matrix4.translate(Vector3(10,10,0));
        quad2.setVP(trans2*scale2, camera.V, camera.P);
        //quad2.setColour(BLUE.xyz);

        text = new Text(
            vk,
            renderPass,
            vk.getFont("segoeprint"),
            //new SDFFont("/pvmoore/_assets/fonts/hiero/", "segoeprint"),
            true,
            2000
        );
        text.setCamera(camera);
        text.setSize(16);
        text.setColour(WHITE*1.1);
        text.setDropShadowColour(RGBA(0,0,0, 0.8));
        text.setDropShadowOffset(vec2(-0.0025, 0.0025));
        foreach(i; 0..19) {
            text.setColour(RGBA(i/19.0f,0.5+i/40.0f,1,1)*1.1);
            text.appendText("Hello there I am some text...", 10, 110+i*20);
        }

        fps = new FPS(vk, renderPass);

        auto orange = RGBA(0.7,0.4,0.1,1)*0.75;
        auto black  = RGBA(0,0,0,0);

        rectangles = new Rectangles(vk, renderPass, 10);
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
                           WHITE, BLUE, RED, GREEN
                           );

        roundRectangles = new RoundRectangles(vk, renderPass, 10)
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
    void createTexture() {
        auto bmp = BMP.read("C:\\pvmoore\\_assets\\images\\bmp\\goddess_abgr.bmp");
        //auto bmp = BMP.read("C:\\pvmoore\\_assets\\images\\bmp\\floor.bmp");

        image1 = vk.memory.uploadImage("goddess_abgr.bmp", bmp.width, bmp.height, bmp.data);
        image1.createView(VFormat.R8G8B8A8_UNORM);

        auto png = PNG.read("/pvmoore/_assets/images/png/rock3.png");
        image2 = vk.memory.uploadImage("rock3.png", png.width, png.height, png.data);
        image2.createView(VFormat.R8G8B8A8_UNORM);
    }
    void createSampler() {
        sampler = device.createSampler(samplerCreateInfo());
    }
    void createRenderPass(VkDevice device) {
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

