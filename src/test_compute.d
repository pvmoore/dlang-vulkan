module test_compute;
/**
 *  Possible improvements:
 *      - Use multiple virtual 'frames' and use them alternately.
 *      - Use the dedicated transfer queue for the transfers. This would
 *        work well with multiple frames assuming there were also multiple buffers.
 *        Semaphores and fences would be required.
 */
import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.stdio : writefln;
import std.datetime.stopwatch : StopWatch;

import vulkan;
import common;

pragma(lib, "user32.lib");

extern(Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow) {
	int result = 0;
	TestCompute app;
	try{
        Runtime.initialize();

        app = new TestCompute();
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
final class TestCompute : VulkanApplication {
    const bool DEBUG = true;
	Vulkan vk;
	VkDevice device;
	DeviceBuffer deviceReadBuffer, deviceWriteBuffer;
	VkCommandPool commandPool;
	SubBuffer hostBuffer;

	Descriptors descriptors;
	VkDescriptorSet descriptorSet, debugDS;

	ShaderPrintf shaderPrintf;

	ComputePipeline pipeline;

	this() {
	    WindowProperties wprops = {
	        headless: true,
            showWindow: false
        };
        VulkanProperties vprops = {
            appName: "Vulkan Compute Test",
            deviceMemorySizeMB: 64,
            stagingMemorySizeMB: 32,
            sharedMemorySizeMB: 32,

            uniformBufferSizeMB: 1,

            requiredComputeQueues: 1
        };
        vk = new Vulkan(
            this,
            wprops,
            vprops
        );
        vk.initialise();
	}
    void destroy() {
        if(!vk) return;
        if(device) {
            if(device) vkDeviceWaitIdle(device);
            vk.memory.dumpStats();

            if(commandPool) device.destroy(commandPool);
            if(descriptors) descriptors.destroy();
            if(pipeline) pipeline.destroy();

            if(hostBuffer) hostBuffer.free();
            if(deviceReadBuffer) deviceReadBuffer.free();
            if(deviceWriteBuffer) deviceWriteBuffer.free();

            if(shaderPrintf) shaderPrintf.destroy();
        }
        vk.destroy();
    }
    void run() {
        log("running...");
        float[] dataIn = new float[1.MB];
        dataIn[] = 0;
        dataIn[0..10]   = [0.0f, 1, 2, 3, 4, 5, 6, 7, 8, 9];
        dataIn[$-10..$] = [9.0f, 8, 7, 6, 5, 4, 3, 2, 1, 0];

        StopWatch w; w.start();
        writeDataIn(dataIn);

        auto cmd = device.allocFrom(commandPool);
        cmd.beginOneTimeSubmit();
        copyHostToDevice(cmd);
        cmd.bindPipeline(pipeline);
        cmd.bindDescriptorSets(
            VPipelineBindPoint.COMPUTE,
            pipeline.layout,
            0,
            [descriptorSet],
            null
        );
        if(DEBUG) {
            cmd.bindDescriptorSets(
                VPipelineBindPoint.COMPUTE,
                pipeline.layout,
                1,
                [debugDS],
                null
            );
        }

        cmd.dispatch(1_000_000,1,1);

        copyDeviceToHost(cmd);
        cmd.end();

        ulong queueStart = w.peek().total!"nsecs";
        vk.getComputeQueue(0).submit([cmd], null);

        // lol simple synchronisation
        vkQueueWaitIdle(vk.getComputeQueue(0));
        ulong queueFinished = w.peek().total!"nsecs";

        float[] dataOut = readDataOut();
        w.stop();

        if(DEBUG) {
            log("\nShader debug output:");
            log("===========================");
            log("%s", shaderPrintf.getDebugString());
            log("\n===========================\n");
        }

        log("dataOut = %s .. %s", dataOut[0..12], dataOut[$-12..$]);
        log("Total time : %s ms", w.peek().total!"nsecs"/1000000.0);
        log("Queue time : %s ms", (queueFinished-queueStart)/1000000.0);
        // total time = 14  - 18 ms
        // queue time = 1.8 - 2.2 ms
    }
    override void selectQueueFamilies(
        VulkanProperties vprops,
        VkQueueFamilyProperties[] props,
        ref QueueFamily queueFamily)
    {
        if(queueFamily.compute==-1 && vprops.requiredComputeQueues>0) {
            throw new Error("No Vulkan compute found");
        }
        if(queueFamily.transfer==-1) {
            throw new Error("No Vulkan transfer found");
        }
    }
    override void deviceReady(VkDevice device, PerFrameResource[] frameResources) {
        this.device = device;
        setup();
    }
private:
    void setup() {
        // Allocate SubBuffer from staging DeviveBuffer.
        hostBuffer = vk.memory.createStagingBuffer(4.MB);

        // Create dst storage DeviceBuffer.
        deviceReadBuffer = vk.memory.local.allocBuffer("device_in", 4.MB,
            VBufferUsage.TRANSFER_DST | VBufferUsage.STORAGE);

        // Create src storage DeviceBuffer.
        deviceWriteBuffer = vk.memory.local.allocBuffer("device_out", 4.MB,
            VBufferUsage.TRANSFER_SRC | VBufferUsage.STORAGE);

        if(DEBUG) {
            shaderPrintf = new ShaderPrintf(vk);
        }

        createCommandPool();
        createDescriptorSets();
        createPipeline();
    }
    void createCommandPool() {
        commandPool = device.createCommandPool(
            vk.queueFamily.compute,
            VCommandPoolCreate.TRANSIENT |
            VCommandPoolCreate.RESET_COMMAND_BUFFER
        );
    }
    void createPipeline() {

        static struct SpecData {
            float add1;
            float add2;
        }
        auto data = SpecData(0.1f, 0.2f);

        pipeline = new ComputePipeline(vk)
            .withDSLayouts(descriptors.layouts)
            .withShader!SpecData("/pvmoore/_assets/shaders/vulkan/test/test_comp.spv", &data)
            .build();
    }
    void createDescriptorSets() {
        descriptors = new Descriptors(vk);
        descriptors.createLayout()
                .storageBuffer(VShaderStage.COMPUTE)
                .storageBuffer(VShaderStage.COMPUTE)
                .sets(1);
        if(DEBUG) {
            shaderPrintf.createLayout(descriptors);
        }
        descriptors.build();

        descriptorSet = descriptors.createSetFromLayout(0)
            .add(deviceReadBuffer.handle, 0, VK_WHOLE_SIZE)
            .add(deviceWriteBuffer.handle, 0, VK_WHOLE_SIZE)
            .write();

        if(DEBUG) {
            debugDS = shaderPrintf.createDescriptorSet(descriptors, 1);
        }
    }
    void writeDataIn(float[] data) {
        void* p = hostBuffer.map();
        memcpy(p, data.ptr, data.length*float.sizeof);
        hostBuffer.flush();
    }
    float[] readDataOut() {
        float[] data = new float[hostBuffer.size/float.sizeof];
        void* p = hostBuffer.mapForReading();
        memcpy(data.ptr, p, hostBuffer.size);
        return data;
    }
    void copyHostToDevice(VkCommandBuffer cmd) {
        //auto cmd = device.allocFrom(commandPool);
        //cmd.beginOneTimeSubmit();
        //deviceReadBuffer.convertAccess(cmd, 0, ACCESS_TRANSFER_WRITE);
        cmd.copyBuffer(hostBuffer.handle, deviceReadBuffer.handle, [VkBufferCopy(0,0, hostBuffer.size)]);

        //deviceReadBuffer.convertAccess(cmd, 0, ACCESS_SHADER_READ);
        //deviceWriteBuffer.convertAccess(cmd, 0, ACCESS_SHADER_WRITE);
//        cmd.end();
//
//        device.submitAndWait(vk.getComputeQueue(), cmd);
//        device.free(commandPool, cmd);
    }
    void copyDeviceToHost(VkCommandBuffer cmd) {
        //auto cmd = device.allocFrom(commandPool);
        //cmd.beginOneTimeSubmit();
        //deviceWriteBuffer.convertAccess(cmd, ACCESS_SHADER_WRITE, ACCESS_TRANSFER_READ);
        cmd.copyBuffer(deviceWriteBuffer.handle, hostBuffer.handle, [VkBufferCopy(0,0, hostBuffer.size)]);
        //deviceWriteBuffer.convertAccess(cmd, ACCESS_TRANSFER_READ, ACCESS_SHADER_WRITE);
//        cmd.end();
//        device.submitAndWait(vk.getComputeQueue(), cmd);
//        device.free(commandPool, cmd);
    }
}
