module test_compute2;

import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.stdio : writefln;
import std.datetime.stopwatch : StopWatch;

import vulkan;
import common;

pragma(lib, "user32.lib");

/**
 * Use separate compute resources per frame. Run the compute each frame and download the results.
 * This will be fairly slow but the idea is to check that the written data is what we expect.
 */

extern(Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow) {
	int result = 0;
	TestCompute2 app;
	try{
        Runtime.initialize();

        app = new TestCompute2();
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
final class TestCompute2 : VulkanApplication {
    static struct FrameResource {
        VkCommandBuffer computeBuffer;
        VkSemaphore computeFinished;
    }
    FrameResource[] frameResources;

	Vulkan vk;
	VkDevice device;
    VkRenderPass renderPass;
	DeviceBuffer deviceReadBuffer, deviceWriteBuffer;
    SubBuffer stagingUploadBuffer, stagingDownloadBuffer;

    VkCommandPool computeCP;
	Descriptors descriptors;
	ComputePipeline pipeline;
    FPS fps;

	this() {
	    WindowProperties wprops = {
	        width: 800,
            height: 800,
            fullscreen: false,
            title: "Vulkan Compute Test 2",
            showWindow: false,
            frameBuffers: 3
        };
        VulkanProperties vprops = {
            appName: "Vulkan Compute Test 2",
            deviceMemorySizeMB: 64,
            stagingMemorySizeMB: 32,
            sharedMemorySizeMB: 32,

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
            vk.memory.dumpStats();

            if(fps) fps.destroy();
            if(renderPass) device.destroy(renderPass);

            foreach(f; frameResources) {
                f.computeFinished.destroy();
            }

            if(computeCP) computeCP.destroy();

            if(descriptors) descriptors.destroy();
            if(pipeline) pipeline.destroy();

            if(deviceReadBuffer) deviceReadBuffer.free();
            if(deviceWriteBuffer) deviceWriteBuffer.free();
        }
        vk.destroy();
    }
    void run() {
        vk.mainLoop();
    }
    // void run() {
    //     log("running...");
    //     float[] dataIn = new float[1.MB];
    //     dataIn[] = 0;
    //     dataIn[0..10]   = [0.0f, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    //     dataIn[$-10..$] = [9.0f, 8, 7, 6, 5, 4, 3, 2, 1, 0];

    //     StopWatch w; w.start();
    //     writeDataIn(dataIn);

    //     auto cmd = device.allocFrom(commandPool);
    //     cmd.beginOneTimeSubmit();
    //     copyHostToDevice(cmd);
    //     cmd.bindPipeline(pipeline);
    //     cmd.bindDescriptorSets(
    //         VPipelineBindPoint.COMPUTE,
    //         pipeline.layout,
    //         0,
    //         [descriptorSet],
    //         null
    //     );
    //     if(DEBUG) {
    //         cmd.bindDescriptorSets(
    //             VPipelineBindPoint.COMPUTE,
    //             pipeline.layout,
    //             1,
    //             [debugDS],
    //             null
    //         );
    //     }

    //     cmd.dispatch(1_000_000,1,1);

    //     copyDeviceToHost(cmd);
    //     cmd.end();

    //     ulong queueStart = w.peek().total!"nsecs";
    //     vk.getComputeQueue(0).submit([cmd], null);

    //     // lol simple synchronisation
    //     vkQueueWaitIdle(vk.getComputeQueue(0));
    //     ulong queueFinished = w.peek().total!"nsecs";

    //     float[] dataOut = readDataOut();
    //     w.stop();

    //     if(DEBUG) {
    //         log("\nShader debug output:");
    //         log("===========================");
    //         log("%s", shaderPrintf.getDebugString());
    //         log("\n===========================\n");
    //     }

    //     log("dataOut = %s .. %s", dataOut[0..12], dataOut[$-12..$]);
    //     log("Total time : %s ms", w.peek().total!"nsecs"/1000000.0);
    //     log("Queue time : %s ms", (queueFinished-queueStart)/1000000.0);
    //     // total time = 14  - 18 ms
    //     // queue time = 1.8 - 2.2 ms
    // }
    override void selectQueueFamilies2(QueueFamilySelector selector, ref QueueFamily queueFamily) {
        /* Assume a suitable graphics queue has already been found */
        assert(queueFamily.graphics != -1);

        /* Look for a compute queue which can also transfer */
        auto compute = selector.findAllWith(selector.compute() | selector.transfer());

        if(compute.length==0) throw new Error("Couldn't find a compute queue with transfer capability");

        queueFamily.compute = compute[0];
    }
    /** Create a basic render pass */
    override VkRenderPass getRenderPass(VkDevice device) {
        auto colorAttachment    = attachmentDescription(vk.swapchain.colorFormat);
        auto colorAttachmentRef = attachmentReference(0);

        auto subpass = subpassDescription((info) {
            info.colorAttachmentCount = 1;
            info.pColorAttachments    = &colorAttachmentRef;
        });

        this.renderPass = .createRenderPass(
            device,
            [colorAttachment],
            [subpass],
            subpassDependency2()
        );

        return renderPass;
    }
    override void deviceReady(VkDevice device, PerFrameResource[] frameResources) {
        this.device                = device;
        this.frameResources.length = frameResources.length;

        this.fps = new FPS(vk, renderPass);

        createBuffers();
        createCommandPools();
        createDescriptorLayouts();
        createPipeline();

        foreach(r; frameResources) {
            createFrameResource(r);
        }

        /* Write some initial data */
        float[] inputData = new float[1.MB];
        for(auto i=0; i<inputData.length; i++) {
            inputData[i] = i;
        }
        writeToStagingBuffer(inputData);
    }
    override void render(
        FrameInfo frame,
        PerFrameResource res)
    {
        if(frame.number == 1 || frame.number==0) {
            auto floats = readFromStagingBuffer();
            log("Frame[%s] results[0..32]    = %s", frame.number, floats[0..32]);
            log("Frame[%s] results[100..132] = %s", frame.number, floats[100..132]);

            /* Expect the results at frame 0 to be all zeroes (or random)
               and the results at frame 1 to be:

            [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41]
            [110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141]

            Note that if the results are not ready at frame 1 it might be because frame 1 is being rendered
            while frame 0 is still being processed. For me though, I see results at frame 1.
            */
        }

        auto myres = frameResources[res.index];

        /* Submit our compute work */
        vk.getComputeQueue(0).submit(
            [myres.computeBuffer],
            null,                     // wait semaphores
            null,                     // wait stages
            [myres.computeFinished],  // signal semaphores
            null                      // fence
        );

        /* Do the graphics stuff - Just display a blank screen with an FPS counter */
        auto b = res.adhocCB;
        b.beginOneTimeSubmit();

        // do updates outside the render pass
        fps.beforeRenderPass(res, vk.getFPS);

        // Renderpass initialLayout = UNDEFINED
        // Renderpass loadOp        = CLEAR
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

        /* Wait for the compute to finish before processing. Not necessary in this case
           because the graphics does not use the compute results but this way we get an
           idea of how long the compute is taking */

        vk.getGraphicsQueue().submit(
            [b],
            [myres.computeFinished, res.imageAvailable],
            [VPipelineStage.COMPUTE_SHADER, VPipelineStage.COLOR_ATTACHMENT_OUTPUT],
            [res.renderFinished],           // signal semaphores
            res.fence                       // fence
        );
    }
private:
    void createBuffers() {
        stagingUploadBuffer   = vk.memory.createStagingBuffer(4.MB);
        stagingDownloadBuffer = vk.memory.createStagingBuffer(4.MB);

        deviceReadBuffer = vk.memory.local.allocBuffer("device_in", 4.MB,
            VBufferUsage.TRANSFER_DST | VBufferUsage.STORAGE);

        deviceWriteBuffer = vk.memory.local.allocBuffer("device_out", 4.MB,
            VBufferUsage.TRANSFER_SRC | VBufferUsage.STORAGE);
    }
    void writeToStagingBuffer(float[] data) {
        void* p = stagingUploadBuffer.map();
        memcpy(p, data.ptr, data.length*float.sizeof);
        stagingUploadBuffer.flush();
    }
    float[] readFromStagingBuffer() {
        float[] data = new float[stagingDownloadBuffer.size/float.sizeof];
        void* p = stagingDownloadBuffer.mapForReading();
        memcpy(data.ptr, p, stagingDownloadBuffer.size);
        return data;
    }
    void createCommandPools() {
        computeCP = device.createCommandPool(
            vk.queueFamily.compute,
            0
        );
    }
    void createPipeline() {
        pipeline = new ComputePipeline(vk)
            .withDSLayouts(descriptors.layouts)
            .withShader("/pvmoore/_assets/shaders/vulkan/test/test_compute2_comp.spv")
            .build();
    }
    void createDescriptorLayouts() {
        descriptors = new Descriptors(vk);
        descriptors.createLayout()
                .storageBuffer(VShaderStage.COMPUTE)
                .storageBuffer(VShaderStage.COMPUTE)
                .sets(vk.swapchain.numImages())
            .build();
    }
    void createFrameResource(PerFrameResource res) {
        frameResources[res.index].computeBuffer   = device.allocFrom(computeCP);
        frameResources[res.index].computeFinished = device.createSemaphore();

        recordComputeFrame(res);
    }
    void recordComputeFrame(PerFrameResource res) {

        auto ds = descriptors.createSetFromLayout(0)
            .add(deviceReadBuffer.handle, 0, VK_WHOLE_SIZE)
            .add(deviceWriteBuffer.handle, 0, VK_WHOLE_SIZE)
            .write();

        auto uploadRegion   = VkBufferCopy(stagingUploadBuffer.offset, 0, stagingUploadBuffer.size);
        auto downloadRegion = VkBufferCopy(0, stagingDownloadBuffer.offset, stagingDownloadBuffer.size);

        // todo - make a copyBuffer(SubBuffer,SubBuffer) and other variants

        auto b  = frameResources[res.index].computeBuffer;

        b.begin();

        b.copyBuffer(stagingUploadBuffer.handle, deviceReadBuffer.handle, [uploadRegion]);

        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VPipelineBindPoint.COMPUTE,
            pipeline.layout,
            0,
            [ds],
            null
        );

        b.dispatch(1024*1024, 1, 1);

        b.copyBuffer(deviceWriteBuffer.handle, stagingDownloadBuffer.handle, [downloadRegion]);

        b.end();
    }

//     void copyHostToDevice(VkCommandBuffer cmd) {
//         //auto cmd = device.allocFrom(commandPool);
//         //cmd.beginOneTimeSubmit();
//         //deviceReadBuffer.convertAccess(cmd, 0, ACCESS_TRANSFER_WRITE);
//         cmd.copyBuffer(hostBuffer.handle, deviceReadBuffer.handle, [VkBufferCopy(0,0, hostBuffer.size)]);

//         //deviceReadBuffer.convertAccess(cmd, 0, ACCESS_SHADER_READ);
//         //deviceWriteBuffer.convertAccess(cmd, 0, ACCESS_SHADER_WRITE);
// //        cmd.end();
// //
// //        device.submitAndWait(vk.getComputeQueue(), cmd);
// //        device.free(commandPool, cmd);
//     }
//     void copyDeviceToHost(VkCommandBuffer cmd) {
//         //auto cmd = device.allocFrom(commandPool);
//         //cmd.beginOneTimeSubmit();
//         //deviceWriteBuffer.convertAccess(cmd, ACCESS_SHADER_WRITE, ACCESS_TRANSFER_READ);
//         cmd.copyBuffer(deviceWriteBuffer.handle, hostBuffer.handle, [VkBufferCopy(0,0, hostBuffer.size)]);
//         //deviceWriteBuffer.convertAccess(cmd, ACCESS_TRANSFER_READ, ACCESS_SHADER_WRITE);
// //        cmd.end();
// //        device.submitAndWait(vk.getComputeQueue(), cmd);
// //        device.free(commandPool, cmd);
//     }
}
