module test_render_to_texture;
/**
 *  Use compute shader to write directly to the swapchain images.
 */
import vulkan.all;

import vulkan.misc.logging;

import core.runtime;
import core.sys.windows.windows;
import std.stdio  : writefln;
import std.string : toStringz;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

final class FrameResource {
    VkCommandBuffer computeBuffer;
    VkCommandBuffer transferBuffer;
    VkSemaphore transferFinished;
    VkSemaphore computeFinished;
}

final class TestCompRenderToTexture : VulkanApplication {
	Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;
    VkCommandPool computeCP, transferCP;

    Descriptors descriptors;
	ComputePipeline pipeline;
    FPS fps;

	FrameResource[] frameResources;
	float[] dataIn;
    GPUData!float data;

	this() {
        WindowProperties wprops = {
            width:        800,
            height:       800,
            fullscreen:   false,
            title:        "Vulkan Compute And Display Test",
            icon:         "resources/images/logo.png",
            showWindow:   false,
            frameBuffers: 3,
            titleBarFps: true
        };
        VulkanProperties vprops = {
            appName: "Vulkan Compute And Display Test",
            swapchainUsage: VK_IMAGE_USAGE_STORAGE_BIT
        };

        vk = new Vulkan(this, wprops, vprops);
        vk.initialise();
        vk.showWindow();
	}
    override void destroy() {
        if(!vk) return;
        if(device) {
            if(device) vkDeviceWaitIdle(device);

            if(context) context.dumpMemory();

            foreach(r; frameResources) {
                destroyFrameResource(r);
            }

            if(data) data.destroy();

            if(fps) fps.destroy();
            if(renderPass) device.destroyRenderPass(renderPass);

            if(transferCP) device.destroyCommandPool(transferCP);
            if(computeCP) device.destroyCommandPool(computeCP);

            if(descriptors) descriptors.destroy();

            if(pipeline) pipeline.destroy();

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
        this.frameResources.length = frameResources.length;

        setup();

        foreach(r; frameResources) {
            createFrameResource(r);
        }
    }
    override void render(Frame frame) {
        auto res = frame.resource;

        uint imageIndex = frame.imageIndex;
        auto myres      = frameResources[imageIndex];

        VkSemaphore[] waitSemaphores;       // = [res.imageAvailable];
        VkPipelineStageFlags[] waitStages;  // = [VPipelineStage.COLOR_ATTACHMENT_OUTPUT];

        // do compute stuff

        // Notes on transfers:
        // 1 - Do we need a barrier to transfer ownership from
        //     transfer queue to compute queue? Seems to work
        //     ok without it.
        // 2 - It might be faster to use an alternative method
        //     eg. use compute queue to do transfer.
        // 3 - This copies the whole host buffer to device. Could
        //     also use updateBuffer if the update is <65536 bytes
        //     and the transfer needs to be outside the render pass.
        //     Or just change the size of the VkBufferCopy in the code below.
        // 4 - All frames are looking at the same buffer storage
        //     so any updates will likely need to be done carefully
        //     in an additive way, freeing areas after 3 frames or so.

        // Transfer some data to compute storage buffer every second.
        if(frame.number.value%1000==0) {
            updateDataIn(frame.number);
            writeDataToHost(dataIn);

            auto t = myres.transferBuffer;
            t.begin();
            data.upload(t);
            t.end();
            vk.getTransferQueue().submit(
                [t],
                null,   // wait semaphores
                null,   // wait stages
                [myres.transferFinished],     // signal semaphores
                null    // fence
            );
            waitSemaphores ~= myres.transferFinished;
            waitStages     ~= VK_PIPELINE_STAGE_TRANSFER_BIT;
        }

        auto computeQueue = vk.getComputeQueue();

        // Submit our compute buffer.
        // Wait for imageAvailable semaphore.
        computeQueue.submit(
            [myres.computeBuffer],
            waitSemaphores,
            waitStages,
            [myres.computeFinished],  // signal semaphores
            null                      // fence
        );

        auto b = res.adhocCB;
        b.beginOneTimeSubmit();

        // acquire the image from compute queue
        b.pipelineBarrier(
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    frame.image,
                    0,
                    0,
                    VK_IMAGE_LAYOUT_GENERAL,
                    VK_IMAGE_LAYOUT_GENERAL,
                    vk.getComputeQueueFamily().index,
                    vk.getGraphicsQueueFamily().index
                )
            ]
        );

        // do updates outside the render pass
        fps.beforeRenderPass(frame, vk.getFPSSnapshot());

        // Renderpass initialLayout = GENERAL
        // The renderpass loadOp = LOAD so we are not clearing
        // what the compute shader has rendered.
        b.beginRenderPass(
            renderPass,
            frame.frameBuffer,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            [ clearColour(0,0,0,1) ],
            VK_SUBPASS_CONTENTS_INLINE
        );
        fps.insideRenderPass(frame);

        // Renderpass finalLayout = PRESENT_SRC_KHR
        b.endRenderPass();

        // release the imqge
        b.pipelineBarrier(
            VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    frame.image,
                    VK_ACCESS_NONE,
                    VK_ACCESS_NONE,
                    VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
                    VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
                    vk.getGraphicsQueueFamily().index,
                    vk.getComputeQueueFamily().index
                )
            ]
        );

        b.end();

        /// Submit render buffer
        vk.getGraphicsQueue().submit(
            [b],
            [myres.computeFinished],
            [VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT],
            [res.renderFinished],  // signal semaphores
            res.fence              // fence
        );
    }
private:
    void setup() {
        createContext();
        createStorageBuffers();
        createCommandPools();
        createComputeDescriptors();
        createComputePipeline();

        fps = new FPS(context);
    }
    void createContext() {
        auto mem = new MemoryAllocator(vk);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("Compute_Local", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("Compute_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 4.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VK_BUFFER_USAGE_INDEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 4.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 4.MB)
               .withBuffer(MemID.LOCAL, "device_in".as!BufID, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 25.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 32.MB);

        context.withRenderPass(renderPass)
               .withFonts("resources/fonts/");

        this.log("%s", context);
    }
    void createFrameResource(PerFrameResource res) {
        auto r = new FrameResource;
        frameResources[res.index] = r;

        r.computeBuffer    = device.allocFrom(computeCP);
        r.transferBuffer   = device.allocFrom(transferCP);
        r.transferFinished = device.createSemaphore();
        r.computeFinished  = device.createSemaphore();
        recordComputeFrame(res);
    }
    void destroyFrameResource(FrameResource res) {
        device.destroySemaphore(res.transferFinished);
        device.destroySemaphore(res.computeFinished);
    }
    void createStorageBuffers() {
        auto screen    = vk.swapchain.extent;
        auto numFloats = screen.width*screen.height*3;

        this.log("screen = %s, numFloats = %s", screen, numFloats);

        this.data = new GPUData!float(context, "device_in".as!BufID, true, numFloats.as!int)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                    VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                    VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT
                ))
            .initialise();

        // write some data to staging buffer
        dataIn = new float[numFloats];
        dataIn[] = 0;
        updateDataIn(FrameNumber(0));
        writeDataToHost(dataIn);
    }
    void createCommandPools() {
        computeCP = device.createCommandPool(
            vk.getComputeQueueFamily().index,
            0
        );
        transferCP = device.createCommandPool(
            vk.getTransferQueueFamily().index,
            VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
        );
    }
    void createComputePipeline() {
        pipeline = new ComputePipeline(context)
            .withDSLayouts(descriptors.getAllLayouts())
            .withShader(context.shaders.getModule("vulkan/test/render_to_img.comp"))
            .build();
    }
    void createComputeDescriptors() {

        descriptors = new Descriptors(context)
            .createLayout()
                .storageBuffer(VK_SHADER_STAGE_COMPUTE_BIT)
                .storageImage(VK_SHADER_STAGE_COMPUTE_BIT)
                .sets(vk.swapchain.numImages)
            .build();

        foreach(view; vk.swapchain.views) {
            descriptors.createSetFromLayout(0)
                .add(data)
                .add(view, VK_IMAGE_LAYOUT_GENERAL)
                .write();
        }
    }
    void updateDataIn(FrameNumber frameNum) {
        auto screen = vk.swapchain.extent;
        float v  = (frameNum.value%256)/256.0f;
        ivec2 tl = ivec2(10,10);
        ivec2 br = ivec2(screen.width-10, screen.height-10);

        for(int y=tl.y; y<br.y; y++)
        for(int x=tl.x; x<br.x; x++) {
            int i       = (x+y*screen.width)*3;
            dataIn[i]   = v;
            dataIn[i+1] = v;
            dataIn[i+2] = v;
        }
    }
    void writeDataToHost(float[] data) {
        this.data.write(data);
    }
    void createRenderPass(VkDevice device) {
        auto colorAttachment = attachmentDescription(
            vk.swapchain.colorFormat, (info) {
            // Ensure we keep the previous contents which will
            // be the compute output.
            info.loadOp        = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD;
            info.initialLayout = VK_IMAGE_LAYOUT_GENERAL;
        });
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
            [dependency]);
    }
    void recordComputeFrame(PerFrameResource res) {
        uint index      = res.index;
        FrameResource r = frameResources[index];

        auto b      = r.computeBuffer;
        auto ds     = descriptors.getSet(0, index);
        auto extent = vk.swapchain.extent;
        auto image  = vk.swapchain.images[index];

        assert(extent.width%8==0 && extent.height%8==0);

        b.begin();
        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_COMPUTE,
            pipeline.layout,
            0,
            [ds],
            null
        );

        // acquire image
        b.pipelineBarrier(
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    image,
                    VK_ACCESS_NONE,
                    VK_ACCESS_SHADER_WRITE_BIT,
                    VK_IMAGE_LAYOUT_UNDEFINED,
                    VK_IMAGE_LAYOUT_GENERAL,
                    vk.getGraphicsQueueFamily().index,
                    vk.getComputeQueueFamily().index
                )
            ]
        );

        b.dispatch(extent.width/8, extent.height/8, 1);

        // release image
        b.pipelineBarrier(
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    image,
                    VK_ACCESS_SHADER_WRITE_BIT,
                    VK_ACCESS_SHADER_READ_BIT,
                    VK_IMAGE_LAYOUT_GENERAL,
                    VK_IMAGE_LAYOUT_GENERAL,
                    vk.getComputeQueueFamily().index,
                    vk.getGraphicsQueueFamily().index
                )
            ]
        );
        b.end();
    }
}
