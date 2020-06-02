module test_noise;

import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.utf	  : toUTF16z;
import std.format : format;
import std.random : uniform01;

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
	TestNoise app;
	try{
        Runtime.initialize();

        app = new TestNoise();
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
//-------------------------------------------------------------------
final class TestNoise : VulkanApplication {
    Vulkan vk;
    VkDevice device;
    VkRenderPass renderPass;

    DeviceImage noiseImage, quadImage;
    VkSampler sampler;

    Camera2D camera;
    Quad quad;
    FPS fps;
    VulkanContext context;

	this() {
        WindowProperties wprops = {
            width: 1200,
            height: 900,
            fullscreen: false,
            vsync: false,
            title: "Vulkan Noise Test",
            icon: "/pvmoore/_assets/icons/3dshapes.png",
            showWindow: false,
            frameBuffers: 3
        };
        VulkanProperties vprops = {
            appName: "Vulkan Noise Test"
        };

        vprops.features.geometryShader = VK_TRUE;

        setEagerFlushing(true);

		vk = new Vulkan(
		    this,
		    wprops,
		    vprops
        );
        vk.initialise();
        log("screen = %s", vk.windowSize);

        vk.showWindow();
	}
	void destroy() {
	    if(!vk) return;
	    if(device) {
	        vkDeviceWaitIdle(device);

            if(context) {
                string buf;
                foreach(s; context.takeMemorySnapshot()) {
                    buf ~= "\n%s".format(s);
                }
                this.log(buf);
            }

	        if(noiseImage) noiseImage.free();
	        if(quadImage) quadImage.free();
	        if(quad) quad.destroy();
	        if(fps) fps.destroy();
	        if(sampler) device.destroySampler(sampler);
	        if(renderPass) device.destroyRenderPass(renderPass);
            if(context) context.destroy();
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
        fps.beforeRenderPass(res, vk.getFPS);
    }
	override void render(FrameInfo frame, PerFrameResource res) {
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
        );

        quad.insideRenderPass(res);
        fps.insideRenderPass(res);

        b.endRenderPass();
        b.end();

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
        camera = Camera2D.forVulkan(vk.windowSize);

        auto mem = new MemoryAllocator(vk);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("TestNoise_Local", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("TestNoise_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VBufferUsage.VERTEX | VBufferUsage.TRANSFER_DST, 4.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VBufferUsage.INDEX | VBufferUsage.TRANSFER_DST, 4.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VBufferUsage.UNIFORM | VBufferUsage.TRANSFER_DST, 4.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VBufferUsage.TRANSFER_SRC, 8.MB);

        context.withRenderPass(renderPass)
               .withFonts("/pvmoore/_assets/fonts/hiero/");

        this.log("%s", context);

        createSampler();
        createNoiseImage();
        createQuadImage();

        quad = new Quad(context, ImageMeta(quadImage, VFormat.R8G8B8A8_UNORM), sampler);
        auto scale = mat4.scale(vec3(quadImage.width,quadImage.height,0));
        auto trans = mat4.translate(vec3(20,20,0));
        quad.setVP(trans*scale, camera.V, camera.P);

        fps = new FPS(context);
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
    /**
     *  Creates a noise image of R32_SFLOAT.
     */
    void createNoiseImage() {
        int octaves      = 5;
        float wavelength = 1.0f/50;

        noiseImage = new NoiseGenerator(context, [800,800])
                            .withOctaves(octaves)
                            .withWavelength(wavelength)
                            .withRandomSeed(uniform01())
                            .withUsage(VImageUsage.STORAGE | VImageUsage.SAMPLED)
                            .withLayout(VImageLayout.GENERAL)
                            .generate();
    }
    /**
     *  Modify noise image to a new format.
     */
    void createQuadImage() {
        quadImage = context.memory(MemID.LOCAL).allocImage(
            "QuadImage",
            [noiseImage.width, noiseImage.height],
            VImageUsage.STORAGE | VImageUsage.SAMPLED,
            VFormat.R8G8B8A8_UNORM
        );
        quadImage.createView(VFormat.R8G8B8A8_UNORM, VImageViewType._2D);

        auto dsLayout = device.createDescriptorSetLayout([
            storageImageBinding(0, VShaderStage.COMPUTE),
            storageImageBinding(1, VShaderStage.COMPUTE),
            samplerBinding(2, VShaderStage.COMPUTE)
        ]);
        auto descriptorPool = device.createDescriptorPool([
                descriptorPoolSize(VDescriptorType.STORAGE_IMAGE,2),
                descriptorPoolSize(VDescriptorType.COMBINED_IMAGE_SAMPLER,1)
            ],
            1
        );
        auto descriptorSet = device.allocDescriptorSets(
            descriptorPool,
            [dsLayout]
        )[0];

        auto writes = [
            descriptorSet.writeImage(
                0,  // binding
                VDescriptorType.STORAGE_IMAGE,
                [descriptorImageInfo(null, noiseImage.view, VImageLayout.GENERAL)]
            ),
            descriptorSet.writeImage(
                1,  // binding
                VDescriptorType.STORAGE_IMAGE,
                [descriptorImageInfo(null, quadImage.view, VImageLayout.GENERAL)]
            ),
            descriptorSet.writeImage(
                2,  // binding
                VDescriptorType.COMBINED_IMAGE_SAMPLER,
                [
                    descriptorImageInfo(sampler,
                                        noiseImage.view(VFormat.R32_SFLOAT,VImageViewType._2D),
                                        VImageLayout.SHADER_READ_ONLY_OPTIMAL)
                ]
            )
        ];
        device.updateDescriptorSets(
            writes,
            null // copies
        );

        ComputePipeline pipeline = new ComputePipeline(context)
            .withShader(vk.shaderCompiler.getModule("test/test_noise_comp.spv"))
            .withDSLayouts([dsLayout])
            .build();

        auto commandPool = device.createCommandPool(
            vk.getComputeQueueFamily().index,
            VCommandPoolCreate.TRANSIENT | VCommandPoolCreate.RESET_COMMAND_BUFFER
        );

        auto cmd = device.allocFrom(commandPool);
        cmd.beginOneTimeSubmit();
        cmd.bindPipeline(pipeline);
        cmd.bindDescriptorSets(
            VPipelineBindPoint.COMPUTE,
            pipeline.layout,
            0,
            [descriptorSet],
            null
        );
        cmd.pipelineBarrier(
            VPipelineStage.COMPUTE_SHADER,
            VPipelineStage.COMPUTE_SHADER,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    quadImage.handle,
                    VAccess.NONE,
                    VAccess.SHADER_WRITE,
                    VImageLayout.UNDEFINED,
                    VImageLayout.GENERAL
                )
            ]
        );

        cmd.dispatch(quadImage.width/8, quadImage.height/8, 1);

        cmd.pipelineBarrier(
            VPipelineStage.COMPUTE_SHADER,
            VPipelineStage.COMPUTE_SHADER,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    quadImage.handle,
                    VAccess.SHADER_WRITE,
                    VAccess.SHADER_READ,
                    VImageLayout.GENERAL,
                    VImageLayout.SHADER_READ_ONLY_OPTIMAL
                )
            ]
        );
        cmd.end();

        vk.getComputeQueue().submit([cmd], null);
        vkQueueWaitIdle(vk.getComputeQueue());

        pipeline.destroy();
        device.destroyCommandPool(commandPool);
        device.destroyDescriptorPool(descriptorPool);
        device.destroyDescriptorSetLayout(dsLayout);
    }
}

