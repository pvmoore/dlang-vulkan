module test_compute;
/**
 *  Compute example that runs once.
 *
 *  Possible improvements:
 *      - Use multiple virtual 'frames' and use them alternately.
 *      - Use the dedicated transfer queue for the transfers. This would
 *        work well with multiple frames assuming there were also multiple buffers.
 *        Semaphores and fences would be required.
 */
import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.stdio  : writefln;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

import vulkan;
import common;
import logging;

final class TestCompute : VulkanApplication {
    enum DEBUG = true;
	Vulkan vk;
	VkDevice device;

    VulkanContext context;
    VkCommandPool commandPool;
	Descriptors descriptors;
	ShaderPrintf shaderPrintf;
	ComputePipeline pipeline;

    GPUData!float input;
    GPUData!float output;

    float[] dataIn;
    float[] dataOut;

	this() {
	    WindowProperties wprops = {
	        headless: true,
            showWindow: false
        };
        VulkanProperties vprops = {
            appName: "Vulkan Compute Test"
        };

        vk = new Vulkan(this, wprops, vprops);

        vk.initialise();
	}
    override void destroy() {
        if(!vk) return;
        if(device) {
            if(device) vkDeviceWaitIdle(device);

            if(context) context.dumpMemory();

            if(input) input.destroy();
            if(output) output.destroy();

            if(commandPool) device.destroyCommandPool(commandPool);
            if(descriptors) descriptors.destroy();
            if(pipeline) pipeline.destroy();

            if(shaderPrintf) shaderPrintf.destroy();
            if(context) context.destroy();
        }
        vk.destroy();
    }
    override void run() {
        log("running...");

        StopWatch w;
        w.start();
        writeDataIn();

        auto cmd = device.allocFrom(commandPool);
        cmd.beginOneTimeSubmit();
        copyHostToDevice(cmd, 0);
        cmd.bindPipeline(pipeline);
        cmd.bindDescriptorSets(
            VPipelineBindPoint.COMPUTE,
            pipeline.layout,
            0,
            [descriptors.getSet(0,0)],  // layout 0, set 0
            null
        );
        if(DEBUG) {
            cmd.bindDescriptorSets(
                VPipelineBindPoint.COMPUTE,
                pipeline.layout,
                1,
                [descriptors.getSet(1,0)],  // layout 1, set 0
                null
            );
        }

        /* This is 'local_size_x' in the shader */
        enum workgroupSizeX = 1024;
        enum dispatchSizeX  = 1.MB / workgroupSizeX;

        if(workgroupSizeX*1*1 > vk.limits.maxComputeWorkGroupInvocations) {
            throw new Error("This device does not support maxComputeWorkGroupInvocations of 1024");
        }
        if(dispatchSizeX > vk.limits.maxComputeWorkGroupCount[0]) {
            throw new Error("This device does not support maxComputeWorkGroupCount[0] of %s".format(dispatchSizeX));
        }

        cmd.dispatch(dispatchSizeX, 1, 1);

        copyDeviceToHost(cmd, 0);
        cmd.end();

        ulong queueStart = w.peek().total!"nsecs";
        vk.getComputeQueue().submit([cmd], null);

        // lol simple synchronisation
        vkQueueWaitIdle(vk.getComputeQueue());
        ulong queueFinished = w.peek().total!"nsecs";

        readDataOut();
        w.stop();

        if(DEBUG) {
            log("\nShader debug output:");
            log("===========================");
            log("%s", shaderPrintf.getDebugString());
            log("\n===========================\n");
        }

        log("dataOut = %s .. %s", dataOut[0..12], dataOut[$-12..$]);
        log("Total time : %s ms", w.peek().total!"nsecs" / 1.MB.as!double);
        log("Queue time : %s ms", (queueFinished-queueStart) / 1.MB.as!double);
        // total time = 14  - 18 ms
        // queue time = 1.8 - 2.2 ms
    }
    override void selectQueueFamilies(QueueManager queueManager) {
        // Use the default compute queue
    }
    override void deviceReady(VkDevice device, PerFrameResource[] frameResources) {
        this.device = device;
        setup();
    }
private:
    void setup() {
        createContext();
        createBuffers();

        if(DEBUG) {
            shaderPrintf = new ShaderPrintf(context);
        }

        createCommandPool();
        createDescriptorSets();
        createPipeline();
    }
    void createContext() {
        auto mem = new MemoryAllocator(vk);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("Compute_Local", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("Compute_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, "device_in".as!BufID, VBufferUsage.STORAGE | VBufferUsage.TRANSFER_DST , 4.MB)
               .withBuffer(MemID.LOCAL, "device_out".as!BufID, VBufferUsage.STORAGE | VBufferUsage.TRANSFER_SRC, 4.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VBufferUsage.TRANSFER_SRC, 4.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING_DOWN, VBufferUsage.TRANSFER_DST, 4.MB);

        this.log("%s", context);
    }
    void createBuffers() {
        input  = new GPUData!float(context, "device_in".as!BufID, true, 1.MB.as!int)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .initialise();
        output = new GPUData!float(context, "device_out".as!BufID, false, 1.MB.as!int)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .initialise();
    }
    void createCommandPool() {
        commandPool = device.createCommandPool(
            vk.getComputeQueueFamily().index,
            VCommandPoolCreate.TRANSIENT | VCommandPoolCreate.RESET_COMMAND_BUFFER
        );
    }
    void createPipeline() {

        static struct SpecData {
            float add1;
            float add2;
        }
        auto data = SpecData(0.1f, 0.2f);

        pipeline = new ComputePipeline(context)
            .withDSLayouts(descriptors.getAllLayouts())
            .withShader!SpecData(vk.shaderCompiler.getModule("test/test_comp.spv"), &data)
            .build();
    }
    void createDescriptorSets() {
        descriptors = new Descriptors(context);
        descriptors.createLayout()
                .storageBuffer(VShaderStage.COMPUTE)
                .storageBuffer(VShaderStage.COMPUTE)
                .sets(1);
        if(DEBUG) {
            shaderPrintf.createLayout(descriptors, VShaderStage.COMPUTE);
        }
        descriptors.build();

        descriptors.createSetFromLayout(0)
                   .add(input)
                   .add(output)
                   .write();

        if(DEBUG) {
            shaderPrintf.createDescriptorSet(descriptors, 1);
        }
    }
    void writeDataIn() {
        this.dataIn = new float[1.MB];
        dataIn[] = 0;
        dataIn[0..10]   = [0.0f, 1, 2, 3, 4, 5, 6, 7, 8, 9];
        dataIn[$-10..$] = [9.0f, 8, 7, 6, 5, 4, 3, 2, 1, 0];

        input.write(dataIn);
    }
    void readDataOut() {
        dataOut = new float[1.MB];
        output.read(dataOut.ptr, 1.MB.as!uint);
    }
    void copyHostToDevice(VkCommandBuffer cmd, ulong frameNumber) {
        input.upload(cmd);
    }
    void copyDeviceToHost(VkCommandBuffer cmd, ulong frameNumber) {
        output.download(cmd);
    }
}
