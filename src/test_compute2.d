module test_compute2;

import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.stdio  : writefln;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

import vulkan;
import common;
import logging;

pragma(lib, "user32.lib");

/**
 * Use separate compute resources per frame. Run the compute each frame and download the results.
 * This will be fairly slow but the idea is to check that the written data is what we expect.
 */
final class TestCompute2 : VulkanApplication {
    static struct FrameResource {
        VkCommandBuffer computeBuffer;
        VkSemaphore computeFinished;
    }
    FrameResource[] frameResources;

	Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;
    VkCommandPool computeCP;
	Descriptors descriptors;
	ComputePipeline pipeline;
    FPS fps;

    GPUData!float input;
    GPUData!float output;

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
            appName: "Vulkan Compute Test 2"
        };

        // vprops.deviceExtensions ~= "VK_KHR_shader_float16_int8".ptr;

        vk = new Vulkan(this, wprops, vprops);
        vk.initialise();
        vk.showWindow();
	}
    override void destroy() {
        if(!vk) return;
        if(device) {
            if(device) vkDeviceWaitIdle(device);

            if(context) context.dumpMemory();

            if(input) input.destroy();
            if(output) output.destroy();
            if(fps) fps.destroy();
            if(renderPass) device.destroyRenderPass(renderPass);

            foreach(ref f; frameResources) {
                device.free(computeCP, f.computeBuffer);
                device.destroySemaphore(f.computeFinished);
            }

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
    override void selectQueueFamilies(QueueManager queueManager) {
        /* Assume a suitable graphics queue has already been found */
        assert(queueManager.getFamily(queueManager.GRAPHICS) != QueueFamily.NONE);

        /* Look for a compute queue which can also transfer */
        auto computeQueues = queueManager.findQueueFamilies(queueManager.compute() | queueManager.transfer());

        if(computeQueues.length==0) throw new Error("Couldn't find a compute queue with transfer capability");

        // If we have more than one option then ensure we pick a unique one
        auto computeQ = computeQueues[0];
        foreach(q; computeQueues) {
            if(!queueManager.supportsGraphics(q)) {
                computeQ = q;
                break;
            }
        }

        /* This compute queue will also be the one that Vulkan chose */
        queueManager.request("compute", computeQ, 1);
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

        createContext();

        this.fps = new FPS(context);

        createBuffers();
        createCommandPools();
        createDescriptorLayouts();
        createPipeline();

        foreach(ref r; frameResources) {
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
        if(frame.number < 2) {
            auto floats = readFromStagingBuffer();
            log("Frame[%s] results[0..32]    = %s", frame.number, floats[0..32]);
            log("Frame[%s] results[100..132] = %s", frame.number, floats[100..132]);
            log("Frame[%s] results[1048575]  = %s", frame.number, floats[1.MB-1].as!long); // 1_048_585

            /* Expect the results at frame 0 to be all zeroes (or random)
               and the results at frame 1 to be:

            [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41]
            [110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141]

            Note that if the results are not ready at frame 1 it might be because frame 1 is being rendered
            while frame 0 is still being processed. For me though, I see results at frame 1.
            */
            if(frame.number==1) if(floats[1.MB-1].as!long != 1_048_585) throw new Error("Fail!! Incorrect value");
        }

        auto myres = frameResources[res.index];

        /* Submit our compute work */
        vk.getQueue("compute").submit(
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
    void createContext() {
        auto mem = new MemoryAllocator(vk);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("Compute_Local", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("Compute_Staging", 8.MB))
            .withMemory(MemID.STAGING_DOWN, mem.allocStdStagingDownload("Compute_Staging_down", 4.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VBufferUsage.VERTEX | VBufferUsage.TRANSFER_DST, 4.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VBufferUsage.UNIFORM | VBufferUsage.TRANSFER_DST, 4.MB)
               .withBuffer(MemID.LOCAL, "device_in".as!BufID, VBufferUsage.STORAGE | VBufferUsage.TRANSFER_DST , 4.MB)
               .withBuffer(MemID.LOCAL, "device_out".as!BufID, VBufferUsage.STORAGE | VBufferUsage.TRANSFER_SRC, 4.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VBufferUsage.TRANSFER_SRC, 8.MB)
               .withBuffer(MemID.STAGING_DOWN, BufID.STAGING_DOWN, VBufferUsage.TRANSFER_DST, 4.MB);

        context.withRenderPass(renderPass)
               .withFonts("/pvmoore/_assets/fonts/hiero/");

        this.log("%s", context);
    }
    void createBuffers() {
        input  = new GPUData!float(context, "device_in".as!BufID, true, false, 1.MB.as!int);
        output = new GPUData!float(context, "device_out".as!BufID, false, true, 1.MB.as!int);
    }
    void writeToStagingBuffer(float[] data) {
        input.write(data.ptr, 1.MB.as!int);
    }
    float[] readFromStagingBuffer() {
        float[] data = new float[1.MB];
        output.read(data.ptr, 1.MB.as!int);
        return data;
    }
    void createCommandPools() {
        computeCP = device.createCommandPool(
            vk.getComputeQueueFamily().index,
            0
        );
    }
    void createPipeline() {
        pipeline = new ComputePipeline(context)
            .withDSLayouts(descriptors.getAllLayouts())
            .withShader(vk.shaderCompiler.getModule("test/test_compute2_comp.spv"))
            .build();
    }
    void createDescriptorLayouts() {
        descriptors = new Descriptors(context);
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

        descriptors.createSetFromLayout(0)
            .add(input, true)
            .add(output, false)
            .write();

        auto b  = frameResources[res.index].computeBuffer;

        b.begin();

        input.upload(b);

        b.bindPipeline(pipeline);
        b.bindDescriptorSets(
            VPipelineBindPoint.COMPUTE,
            pipeline.layout,
            0,
            [descriptors.getSet(0,0)],
            null
        );

        /* This is 'local_size_x' in the shader */
        enum workgroupSizeX = 1024;
        enum dispatchSizeX  = 1.MB / workgroupSizeX;

        if(workgroupSizeX*1*1 > vk.limits.maxComputeWorkGroupInvocations) {
            throw new Error("This device does not support maxComputeWorkGroupInvocations of 1024");
        }
        if(dispatchSizeX > vk.limits.maxComputeWorkGroupCount[0]) {
            throw new Error("This device does not support maxComputeWorkGroupCount[0] of %s".format(dispatchSizeX));
        }

        b.dispatch(dispatchSizeX, 1, 1);

        output.download(b);

        b.end();
    }
}
