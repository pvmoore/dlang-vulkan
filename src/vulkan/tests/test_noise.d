module vulkan.tests.test_noise;

import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.utf	  : toUTF16z;
import std.format : format;
import std.random : uniform01;

import vulkan.all;

final class TestNoise : VulkanApplication {
    Vulkan vk;
    VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    DeviceImage noiseImage, quadImage;
    VkSampler sampler;

    Camera2D camera;
    Quad quad;
    FPS fps;


	this() {
        WindowProperties wprops = {
            width:        1200,
            height:       900,
            fullscreen:   false,
            vsync:        false,
            title:        "Vulkan Noise Test",
            icon:         "resources/images/logo.png",
            showWindow:   false,
            frameBuffers: 3,
            titleBarFps: true
        };
        VulkanProperties vprops = {
            appName: "Vulkan Noise Test",
            apiVersion: VK_API_VERSION_1_1,
            shaderSrcDirectories: ["shaders/"],
            shaderDestDirectory:  "resources/shaders/",
            shaderSpirvVersion:   "1.3"
        };

		vk = new Vulkan(this, wprops, vprops);
        vk.initialise();
        vk.showWindow();
	}
	override void destroy() {
	    if(!vk) return;
	    if(device) {
	        vkDeviceWaitIdle(device);

            if(context) context.dumpMemory();

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
            [ clearColour(0.2f,0,0,1) ],
            VK_SUBPASS_CONTENTS_INLINE
        );

        quad.insideRenderPass(frame);
        fps.insideRenderPass(frame);

        b.endRenderPass();
        b.end();

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

        createContext();
        createSampler();
        createNoiseImage();
        createQuadImage();

        auto scale = mat4.scale(vec3(quadImage.width,quadImage.height,0));
        auto trans = mat4.translate(vec3(20,20,0));

        this.quad = new Quad(context, ImageMeta(quadImage, VK_FORMAT_R8G8B8A8_UNORM), sampler);
        quad.setVP(trans*scale, camera.V, camera.P);

        this.fps = new FPS(context);
    }
    void createContext() {
        auto mem = new MemoryAllocator(vk);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("TestNoise_Local", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("TestNoise_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX,    VK_BUFFER_USAGE_VERTEX_BUFFER_BIT  | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 4.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX,     VK_BUFFER_USAGE_INDEX_BUFFER_BIT   | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 4.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM,   VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 4.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 8.MB);

        context.withRenderPass(renderPass)
               .withFonts("resources/fonts/");

        this.log("%s", context);
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
                            .withUsage(VK_IMAGE_USAGE_STORAGE_BIT | VK_IMAGE_USAGE_SAMPLED_BIT)
                            .withLayout(VK_IMAGE_LAYOUT_GENERAL)
                            .generate();
    }
    /**
     *  Modify noise image to a new format.
     */
    void createQuadImage() {
        quadImage = context.memory(MemID.LOCAL).allocImage(
            "QuadImage",
            [noiseImage.width, noiseImage.height],
            VK_IMAGE_USAGE_STORAGE_BIT | VK_IMAGE_USAGE_SAMPLED_BIT,
            VK_FORMAT_R8G8B8A8_UNORM
        );
        quadImage.createView(VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_VIEW_TYPE_2D, VK_IMAGE_ASPECT_COLOR_BIT);

        auto dsLayout = device.createDescriptorSetLayout([
            storageImageBinding(0, VK_SHADER_STAGE_COMPUTE_BIT),
            storageImageBinding(1, VK_SHADER_STAGE_COMPUTE_BIT),
            samplerBinding(2, VK_SHADER_STAGE_COMPUTE_BIT, 1)
        ]);
        auto descriptorPool = device.createDescriptorPool([
                descriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, 2),
                descriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 1)
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
                VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                [descriptorImageInfo(null, noiseImage.view, VK_IMAGE_LAYOUT_GENERAL)]
            ),
            descriptorSet.writeImage(
                1,  // binding
                VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                [descriptorImageInfo(null, quadImage.view, VK_IMAGE_LAYOUT_GENERAL)]
            ),
            descriptorSet.writeImage(
                2,  // binding
                VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                [
                    descriptorImageInfo(sampler,
                                        noiseImage.view(VK_FORMAT_R32_SFLOAT, VK_IMAGE_VIEW_TYPE_2D),
                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)
                ]
            )
        ];
        device.updateDescriptorSets(
            writes,
            null // copies
        );

        ComputePipeline pipeline = new ComputePipeline(context)
            .withShader(vk.shaderCompiler.getModule("vulkan/test/test_noise.comp"))
            .withDSLayouts([dsLayout])
            .build();

        auto commandPool = device.createCommandPool(
            vk.getComputeQueueFamily().index,
            VK_COMMAND_POOL_CREATE_TRANSIENT_BIT | VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
        );

        auto cmd = device.allocFrom(commandPool);
        cmd.beginOneTimeSubmit();
        cmd.bindPipeline(pipeline);
        cmd.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_COMPUTE,
            pipeline.layout,
            0,
            [descriptorSet],
            null
        );
        cmd.pipelineBarrier(
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    quadImage.handle,
                    VK_ACCESS_NONE,
                    VK_ACCESS_SHADER_WRITE_BIT,
                    VK_IMAGE_LAYOUT_UNDEFINED,
                    VK_IMAGE_LAYOUT_GENERAL
                )
            ]
        );

        cmd.dispatch(quadImage.width/8, quadImage.height/8, 1);

        cmd.pipelineBarrier(
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    quadImage.handle,
                    VK_ACCESS_SHADER_WRITE_BIT,
                    VK_ACCESS_SHADER_READ_BIT,
                    VK_IMAGE_LAYOUT_GENERAL,
                    VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
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

