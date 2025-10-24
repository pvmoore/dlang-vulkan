module vulkan.tests.test_compute;
/**
 *  Compute example that runs once.
 *
 *  Note this uses the built in printf shader debugging
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

import vulkan.all;

final class TestCompute : VulkanApplication {
	Vulkan vk;
	VkDevice device;

    VulkanContext context;
    VkCommandPool commandPool;
	Descriptors descriptors;
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
            appName: "Vulkan Compute Test NEW",
            apiVersion: VK_API_VERSION_1_1
        };

        debug {
            vprops.enableShaderPrintf  = true;
            vprops.enableGpuValidation = true;
        }

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

            if(context) context.destroy();
        }
        vk.destroy();
    }
    override void run() {
        log(__FILE__, "running...");

        StopWatch w;
        w.start();
        writeDataIn();

        auto cmd = device.allocFrom(commandPool);
        cmd.beginOneTimeSubmit();
        copyHostToDevice(cmd, 0);
        cmd.bindPipeline(pipeline);
        cmd.bindDescriptorSets(
            VK_PIPELINE_BIND_POINT_COMPUTE,
            pipeline.layout,
            0,
            [descriptors.getSet(0,0)],  // layout 0, set 0
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

        log(__FILE__, "dataOut = %s .. %s", dataOut[0..12], dataOut[$-12..$]);
        log(__FILE__, "Total time : %s ms", w.peek().total!"nsecs" / 1.MB.as!double);
        log(__FILE__, "Queue time : %s ms", (queueFinished-queueStart) / 1.MB.as!double);
        // total time = 14  - 18 ms
        // queue time = 1.8 - 2.2 ms
    }
    override void selectQueueFamilies(QueueManager queueManager) {
        // Use the default compute queue
    }
    override void deviceReady(VkDevice device) {
        this.device = device;
        setup();
    }
private:
    void setup() {
        createContext();
        createBuffers();

        createCommandPool();
        createDescriptorSets();
        createPipeline();
    }
    void createContext() {
        auto mem = new MemoryAllocator(vk);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("Compute_Local", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("Compute_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, "device_in".as!BufID, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT , 4.MB)
               .withBuffer(MemID.LOCAL, "device_out".as!BufID, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 4.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 4.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING_DOWN, VK_BUFFER_USAGE_TRANSFER_DST_BIT, 4.MB);

        this.log("%s", context);
    }
    void createBuffers() {
        input  = new GPUData!float(context, "device_in".as!BufID, true, 1.MB.as!int)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                    VkAccessFlagBits.VK_ACCESS_TRANSFER_WRITE_BIT,
                    VkAccessFlagBits.VK_ACCESS_SHADER_READ_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT
                ))
            .initialise();
        output = new GPUData!float(context, "device_out".as!BufID, false, 1.MB.as!int)
            .withFrameStrategy(GPUDataFrameStrategy.ONLY_ONE)
            .withAccessAndStageMasks(AccessAndStageMasks(
                    VkAccessFlagBits.VK_ACCESS_SHADER_WRITE_BIT,
                    VkAccessFlagBits.VK_ACCESS_TRANSFER_READ_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
                    VkPipelineStageFlagBits.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT
                ))
            .initialise();
    }
    void createCommandPool() {
        commandPool = device.createCommandPool(
            vk.getComputeQueueFamily(),
            VK_COMMAND_POOL_CREATE_TRANSIENT_BIT | VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
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
            .withShader!SpecData(context.shaders.getModule("vulkan/test/test_compute.comp"), &data)
            .build();
    }
    void createDescriptorSets() {
        descriptors = new Descriptors(context);
        descriptors.createLayout()
                .storageBuffer(VK_SHADER_STAGE_COMPUTE_BIT)
                .storageBuffer(VK_SHADER_STAGE_COMPUTE_BIT)
                .sets(1);
        descriptors.build();

        descriptors.createSetFromLayout(0)
                   .add(input)
                   .add(output)
                   .write();
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
