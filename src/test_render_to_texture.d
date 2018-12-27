module test_render_to_texture;
/**
 *  Use compute shader to write to the swapchain images.
 */
import vulkan;
import common;

import vulkan.misc.logging;

import core.runtime;
import std.string : toStringz;
import core.sys.windows.windows;
import std.stdio : writefln;
import std.datetime.stopwatch : StopWatch;

pragma(lib, "user32.lib");

extern(Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow) {
	int result = 0;
	TestCompRenderToTexture app;
	try{
        Runtime.initialize();

        app = new TestCompRenderToTexture();
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
//-------------------------------------------------------------
final class FrameResource {
    VkCommandBuffer computeBuffer;
    VkCommandBuffer transferBuffer;
    VkSemaphore transferFinished;
    VkSemaphore computeFinished;
}

final class TestCompRenderToTexture : VulkanApplication {
	Vulkan vk;
	VkDevice device;
    VkRenderPass renderPass;
    VkCommandPool computeCP, transferCP;

    Descriptors descriptors;
	ComputePipeline pipeline;

	DeviceBuffer deviceReadBuffer;
	SubBuffer hostBuffer;

	VkDescriptorSet[] descriptorSets;
	FrameResource[] frameResources;
	float[] dataIn;
	FPS fps;

	this() {
        WindowProperties wprops = {
            width: 800,
            height: 800,
            fullscreen: false,
            title: "Vulkan Compute And Display Test",
            showWindow: false,
            frameBuffers: 3
        };
        VulkanProperties vprops = {
            appName: "Vulkan Compute And Display Test",
            swapchainUsage: VImageUsage.STORAGE,

            deviceMemorySizeMB: 64,
            stagingMemorySizeMB: 32,
            sharedMemorySizeMB: 1,

            vertexBufferSizeMB: 16,
            uniformBufferSizeMB: 1,

            requiredComputeQueues: 1
        };

        vprops.features.geometryShader = VK_TRUE;

        vk = new Vulkan(
            this,
            wprops,
            vprops
        );
        vk.initialise();
        vk.showWindow();
	}
    void destroy() {
        if(!vk) return;
        if(device) {
            if(device) vkDeviceWaitIdle(device);

            foreach(r; frameResources) {
                destroyFrameResource(r);
            }

            if(fps) fps.destroy();
            if(renderPass) device.destroy(renderPass);

            if(transferCP) device.destroy(transferCP);
            if(computeCP) device.destroy(computeCP);

            if(descriptors) descriptors.destroy();

            if(pipeline) pipeline.destroy();

            if(hostBuffer) hostBuffer.free();
            if(deviceReadBuffer) vk.memory.local.destroy(deviceReadBuffer);
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
        this.frameResources.length = frameResources.length;
        init();
        foreach(r; frameResources) {
            createFrameResource(r);
        }
    }
    override void render(
        FrameInfo frame,
        PerFrameResource res)
    {
        auto myres          = frameResources[res.index];
        auto waitSemaphores = [res.imageAvailable];
        auto waitStages     = [VPipelineStage.COLOR_ATTACHMENT_OUTPUT];

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

        // Transfer some data to compute storage buffer
        // every 1000 frames.
        if(frame.number%1000==0) {
            logTime("Update data");
            updateDataIn(frame.number);
            logTime("Mid update");
            writeDataToHost(dataIn);
            logTime("After update");

            auto t = myres.transferBuffer;
            t.begin();
            t.copyBuffer(hostBuffer.handle, deviceReadBuffer.handle, [VkBufferCopy(hostBuffer.offset,0, hostBuffer.size)]);
            t.end();
            vk.getTransferQueue().submit(
                [t],
                null,   // wait semaphores
                null,   // wait stages
                [myres.transferFinished],     // signal semaphores
                null    // fence
            );
            waitSemaphores ~= myres.transferFinished;
            waitStages     ~= VPipelineStage.TRANSFER;
        }

        auto computeQueue = vk.getComputeQueue(0);

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

        // do updates outside the render pass
        fps.beforeRenderPass(res, vk.getFPS);

        // Renderpass initialLayout = GENERAL
        // The renderpass loadOp = LOAD so we are not clearing
        // what the compute shader has rendered.
        b.beginRenderPass(
            renderPass,
            res.frameBuffer,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            [ clearColour(0,0,0,1) ],
            VSubpassContents.INLINE
        );
        fps.insideRenderPass(res);

        // Renderpass finalLayout = PRESENT_SRC_KHR
        b.endRenderPass();
        b.end();

        /// Submit render buffer
        vk.getGraphicsQueue().submit(
            [b],
            [myres.computeFinished],
            [VPipelineStage.COMPUTE_SHADER],
            [res.renderFinished],  // signal semaphores
            res.fence              // fence
        );
    }
private:
    void init() {
        createStorageBuffers();
        createCommandPools();
        createComputeDescriptors();
        createComputePipeline();
        fps = new FPS(vk, renderPass);
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
        device.destroy(res.transferFinished);
        device.destroy(res.computeFinished);
    }
    void createStorageBuffers() {
        auto screen = vk.swapchain.extent;
        auto size   = screen.width*screen.height*3*float.sizeof;

        assert(size<=25.MB);

        // Alloc 8MB from staging buffer.
        hostBuffer = vk.memory.createStagingBuffer(25.MB);

        // Create a DeviceBuffer for dst storage.
        deviceReadBuffer = vk.memory.local.allocBuffer(
            "device_in", 25.MB,
            VBufferUsage.TRANSFER_DST | VBufferUsage.STORAGE);

        // write some data to staging buffer
        dataIn = new float[size];
        dataIn[] = 0;
        updateDataIn(0);
        writeDataToHost(dataIn);
    }
    void createCommandPools() {
        computeCP = device.createCommandPool(
            vk.queueFamily.compute,
            0
        );
        transferCP = device.createCommandPool(
            vk.queueFamily.transfer,
            VCommandPoolCreate.RESET_COMMAND_BUFFER
        );
    }
    void createComputePipeline() {
        pipeline = new ComputePipeline(vk)
            .withDSLayouts(descriptors.layouts)
            .withShader("/pvmoore/_assets/shaders/vulkan/test/render_to_img_comp.spv")
            .build();
    }
    void createComputeDescriptors() {

        descriptors = new Descriptors(vk)
            .createLayout()
                .storageBuffer(VShaderStage.COMPUTE)
                .storageImage(VShaderStage.COMPUTE)
                .sets(vk.swapchain.numImages)
            .build();

        foreach(view; vk.swapchain.views) {
            descriptorSets ~= descriptors.createSetFromLayout(0)
                .add(deviceReadBuffer.handle, 0, VK_WHOLE_SIZE)
                .add(view, VImageLayout.GENERAL)
                .write();
        }
    }
    void updateDataIn(ulong frameNum) {
        auto screen = vk.swapchain.extent;
        float v  = (frameNum%256)/256.0f;
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
        void* p = hostBuffer.map();
        memcpy(p, data.ptr, data.length*float.sizeof);
        logTime("Before flush");
        hostBuffer.flush();
    }
//    float[] readDataOut() {
//        float[] data = new float[hostBuffer.size/float.sizeof];
//        void* p = hostBuffer.map();
//        memcpy(data.ptr, p, hostBuffer.size);
//        hostBuffer.flush();
//        return data;
//    }
//    void copyHostToDevice(VkCommandBuffer cmd) {
        //auto cmd = device.allocFrom(commandPool);
        //cmd.beginOneTimeSubmit();
        //deviceReadBuffer.convertAccess(cmd, 0, ACCESS_TRANSFER_WRITE);
//        cmd.copyBuffer(hostBuffer.handle, deviceReadBuffer.handle, [VkBufferCopy(0,0, hostBuffer.size)]);

        //deviceReadBuffer.convertAccess(cmd, 0, ACCESS_SHADER_READ);
        //deviceWriteBuffer.convertAccess(cmd, 0, ACCESS_SHADER_WRITE);
//        cmd.end();
//
//        device.submitAndWait(vk.getComputeQueue(), cmd);
//        device.free(commandPool, cmd);
 //   }
//    void copyDeviceToHost(VkCommandBuffer cmd) {
//        //auto cmd = device.allocFrom(commandPool);
//        //cmd.beginOneTimeSubmit();
//        //deviceWriteBuffer.convertAccess(cmd, ACCESS_SHADER_WRITE, ACCESS_TRANSFER_READ);
//        cmd.copyBuffer(deviceWriteBuffer.handle, hostBuffer.handle, [VkBufferCopy(0,0, hostBuffer.size)]);
//        //deviceWriteBuffer.convertAccess(cmd, ACCESS_TRANSFER_READ, ACCESS_SHADER_WRITE);
//        cmd.end();
//        device.submitAndWait(vk.getComputeQueue(), cmd);
//        device.free(commandPool, cmd);
//    }
    void createRenderPass(VkDevice device) {
        auto colorAttachment = attachmentDescription(
            vk.swapchain.colorFormat, (info) {
            // Ensure we keep the previous contents which will
            // be the compute output.
            info.loadOp        = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD;
            info.initialLayout = VImageLayout.GENERAL;
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
        auto ds     = descriptorSets[index];
        auto extent = vk.swapchain.extent;
        auto image  = res.image;

        assert(extent.width%8==0 && extent.height%8==0);

        b.begin();
        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VPipelineBindPoint.COMPUTE,
            pipeline.layout,
            0,
            [ds],
            null
        );
        b.pipelineBarrier(
            VPipelineStage.COMPUTE_SHADER,
            VPipelineStage.COMPUTE_SHADER,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    image,
                    VAccess.NONE,
                    VAccess.SHADER_WRITE,
                    VImageLayout.UNDEFINED,
                    VImageLayout.GENERAL,
                    vk.queueFamily.graphics,
                    vk.queueFamily.compute
                )
            ]
        );
        b.dispatch(extent.width/8, extent.height/8, 1);
        b.pipelineBarrier(
            VPipelineStage.COMPUTE_SHADER,
            VPipelineStage.COMPUTE_SHADER,
            0,      // dependency flags
            null,   // memory barriers
            null,   // buffer barriers
            [
                imageMemoryBarrier(
                    image,
                    VAccess.SHADER_WRITE,
                    VAccess.SHADER_READ,
                    VImageLayout.GENERAL,
                    VImageLayout.GENERAL,
                    vk.queueFamily.compute,
                    vk.queueFamily.graphics
                )
            ]
        );
        b.end();
    }
}
