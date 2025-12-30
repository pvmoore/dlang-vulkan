module vulkan.tests.hello_world_1_4;

import core.cpuid: processor;
import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz, fromStringz;
import std.stdio  : writefln;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

import vulkan.all;

/**
 * Hello World using Vulkan 1.4 features:
 *
 * https://registry.khronos.org/vulkan/specs/latest/man/html/VK_VERSION_1_4.html
 * https://docs.vulkan.org/features/latest/features/proposals/VK_VERSION_1_4.html
 *
 *
 * Vulkan 1.4 implies all of:
 * - Spirv 1.6
 *
 * The following extensions are promoted in their entirety to Vulkan 1.4:
 *
 * - VK_KHR_dynamic_rendering_local_read (partially promoted) : enables reads from attachments and resources written by previous fragment shaders within a dynamic render pass  
 * - VK_KHR_index_type_uint8            : allows using uint8_t as vertex index type
 * - VK_KHR_line_rasterization          : allows configuring line rasterization 
 * - VK_KHR_load_store_op_none          : allows using VK_ATTACHMENT_LOAD_OP_NONE and VK_ATTACHMENT_STORE_OP_NONE for attachments
 * - VK_KHR_maintenance5
 * - VK_KHR_maintenance6
 * - VK_KHR_map_memory2                 : adds extensible vkMapMemory2KHR and vkUnmapMemory2KHR functions
 * - VK_KHR_shader_expect_assume        : allows using expect/assume intrinsics in shaders
 * - VK_KHR_shader_float_controls2      : finer grained control over shader rounding modes and denormals
 * - VK_KHR_shader_subgroup_rotate      : adds subgroup rotate operations
 * - VK_KHR_vertex_attribute_divisor    : allows using vertex attribute divisor
 * - VK_EXT_pipeline_protected_access   : allows using protected access per pipeline
 * - VK_EXT_pipeline_robustness         : allows configuring robustness for pipelines
 * - VK_EXT_host_image_copy (optional)  : allows copying images between host and device memory
 * - VK_KHR_push_descriptor             : allows using push descriptors in pipelines  
 * - VK_KHR_global_priority             : allows setting global priority for queues
 * 
 * If Vulkan 1.4 is supported, the following features must be supported:
 *
 *  - fullDrawIndexUint32
 *  - imageCubeArray
 *  - independentBlend
 *  - sampleRateShading
 *  - drawIndirectFirstInstance
 *  - depthClamp
 *  - depthBiasClamp
 *  - samplerAnisotropy
 *  - fragmentStoresAndAtomics
 *  - shaderStorageImageExtendedFormats
 *  - shaderUniformBufferArrayDynamicIndexing
 *  - shaderSampledImageArrayDynamicIndexing
 *  - shaderStorageBufferArrayDynamicIndexing
 *  - shaderStorageImageArrayDynamicIndexing
 *  - shaderImageGatherExtended
 *  - shaderInt16
 *  - largePoints
 *  - samplerYcbcrConversion
 *  - storageBuffer16BitAccess
 *  - variablePointers
 *  - variablePointersStorageBuffer
 *  - samplerMirrorClampToEdge
 *  - scalarBlockLayout
 *  - shaderUniformTexelBufferArrayDynamicIndexing
 *  - shaderStorageTexelBufferArrayDynamicIndexing
 *  - shaderInt8
 *  - storageBuffer8BitAccess
 *  - globalPriorityQuery
 *  - shaderSubgroupRotate
 *  - shaderSubgroupRotateClustered
 *  - shaderFloatControls2
 *  - shaderExpectAssume
 *  - bresenhamLines
 *  - vertexAttributeInstanceRateDivisor
 *  - indexTypeUint8
 *  - maintenance5
 *  - pushDescriptor
 *  - dynamicRenderingLocalRead
 *  - maintenance6
 *  - pipelineProtectedAccess if protectedMemory is supported
 *  - pipelineRobustness
 *
 * Deprecations:
 *
 * - Shader modules are deprecated - applications can now pass VkShaderModuleCreateInfo as a chained structure to pipeline creation via VkPipelineShaderStageCreateInfo
 * - 
 */
final class HelloWorld_1_4 : VulkanApplication {
public:
    this() {
        enum NAME = "Vulkan 1.4 Hello World";
        WindowProperties wprops = {
            width:          1400,
            height:         800,
            fullscreen:     false,
            vsync:          false,
            title:          NAME,
            icon:           "resources/images/logo.png",
            showWindow:     false,
            frameBuffers:   3,
            titleBarFps:    true
        };
        VulkanProperties vprops = {
            appName: NAME,
            shaderSrcDirectories: ["shaders/"],
            shaderDestDirectory:  "resources/shaders/",
            apiVersion: VK_API_VERSION_1_4,
            shaderSpirvVersion:   "1.6"
        };

        debug {
            vprops.enableShaderPrintf  = true;
            vprops.enableGpuValidation = true;
        }

		this.vk = new Vulkan(this, wprops, vprops);
        vk.initialise();
        vk.showWindow();
    }
    override void destroy() {
	    if(!vk) return;
	    if(device) {
	        vkDeviceWaitIdle(device);

            if(context) context.dumpMemory();

            if(fps) fps.destroy();
            if(circles) circles.destroy();
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
    override void selectFeaturesAndExtensions(FeaturesAndExtensions fae) {
        VkPhysicalDeviceVulkan11Features v11 = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES
        };
        VkPhysicalDeviceVulkan12Features v12 = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES
        };
        VkPhysicalDeviceVulkan13Features v13 = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_3_FEATURES
        };
        VkPhysicalDeviceVulkan14Features v14 = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_4_FEATURES
        };

        VkPhysicalDeviceFeatures v10 = {
            wideLines: VK_TRUE
        };
        fae.addFeatures(v11, v12, v13, v14, v10);
    }
    override void deviceReady(VkDevice device) {
        this.device = device;
        initScene();
    }
    void update(Frame frame) {
        fps.beforeRenderPass(frame, vk.getFPSSnapshot());
        circles.beforeRenderPass(frame);

        foreach(d; doodads) {
            d.pos.x = d.ease.step(frame.perSecond)[0];
            circles.update(d.index, d.pos, 50);
        }
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
            [ bgColour ],
            VK_SUBPASS_CONTENTS_INLINE
            //VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS
        );

        fps.insideRenderPass(frame);
        circles.insideRenderPass(frame);

        b.endRenderPass();
        b.end();

        /// Submit our render buffer
        vk.getGraphicsQueue().submit(
            [b],
            [res.imageAvailable],
            [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT],
            [res.renderFinished],  // signal semaphores
            res.fence              // fence
        );
    }
private:
    Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    FPS fps;
    Camera2D camera;
    VkClearValue bgColour;
    string title;
    Circles circles;
    Doodad[] doodads;

    static struct Doodad {
        uint index;
        float2 pos;
        Ease ease;
        Ease[2] eases;
    }

    void initScene() {
        this.camera = Camera2D.forVulkan(vk.windowSize);

        auto mem = new MemoryAllocator(vk);

        auto maxLocal =
            mem.builder(0)
                .withAll(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                .withoutAll(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)
                .maxHeapSize();

        this.log("Max local memory = %s MBs", maxLocal / 1.MB);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("Local", 256.MB))
          //.withMemory(MemID.SHARED, mem.allocStdShared("Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VK_BUFFER_USAGE_INDEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 32.MB);

        context.withFonts("resources/fonts/")
               .withImages("resources/images/")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        this.fps = new FPS(context);

        this.bgColour = clearColour(0.0f,0,0,1);

        this.circles = new Circles(context, 6)
            .camera(camera)
            .borderColour(WHITE)
            .borderRadius(5);

        addAnimationDoodads();
    }
    void createRenderPass(VkDevice device) {
        this.log("Creating render pass");
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
    void addAnimationDoodads() {
        doodads.length = 6;

        doodads[0].eases[0] = new Ease(5, EasingType.EASEIN, EasingSubType.SINE, [100], [1300])
            .withUserData(&doodads[0]);
        doodads[1].eases[0] = new Ease(5, EasingType.EASEIN, EasingSubType.EXPONENTIAL, [100], [1300])
            .withUserData(&doodads[1]);
        doodads[2].eases[0] = new Ease(5, EasingType.EASEOUT, EasingSubType.SINE, [100], [1300])
            .withUserData(&doodads[2]);
        doodads[3].eases[0] = new Ease(5, EasingType.EASEOUT, EasingSubType.EXPONENTIAL, [100], [1300])
            .withUserData(&doodads[3]);
        doodads[4].eases[0] = new Ease(5, EasingType.EASEINOUT, EasingSubType.SINE, [100], [1300])
            .withUserData(&doodads[4]);
        doodads[5].eases[0] = new Ease(5, EasingType.EASEINOUT, EasingSubType.EXPONENTIAL, [100], [1300])
            .withUserData(&doodads[5]);

        doodads[0].eases[1] = new Ease(5, EasingType.EASEIN, EasingSubType.SINE, [1300], [100])
            .withUserData(&doodads[0]);
        doodads[1].eases[1] = new Ease(5, EasingType.EASEIN, EasingSubType.EXPONENTIAL, [1300], [100])
            .withUserData(&doodads[1]);
        doodads[2].eases[1] = new Ease(5, EasingType.EASEOUT, EasingSubType.SINE, [1300], [100])
            .withUserData(&doodads[2]);
        doodads[3].eases[1] = new Ease(5, EasingType.EASEOUT, EasingSubType.EXPONENTIAL, [1300], [100])
            .withUserData(&doodads[3]);
        doodads[4].eases[1] = new Ease(5, EasingType.EASEINOUT, EasingSubType.SINE, [1300], [100])
            .withUserData(&doodads[4]);
        doodads[5].eases[1] = new Ease(5, EasingType.EASEINOUT, EasingSubType.EXPONENTIAL, [1300], [100])
            .withUserData(&doodads[5]);

        foreach(i, ref d; doodads) {
            d.pos = float2(100, 100 + i * 120);
            d.ease = d.eases[0];
            d.eases[0].onFinish((e) {
                auto d = e.getUserData().as!(Doodad*);
                d.eases[1].reset();
                d.ease = d.eases[1];
            });
            d.eases[1].onFinish((e) {
                auto d = e.getUserData().as!(Doodad*);
                d.eases[0].reset();
                d.ease = d.eases[0];
            });
        }

        circles.colour(float4(0.9, 0.7, 0.2, 1));
        doodads[0].index = circles.add(doodads[0].pos, 50);
        doodads[1].index = circles.add(doodads[1].pos, 50);
        circles.colour(float4(0.7, 0.8, 0.2, 1));
        doodads[2].index = circles.add(doodads[2].pos, 50);
        doodads[3].index = circles.add(doodads[3].pos, 50);
        circles.colour(float4(0.7, 0.2, 0.9, 1));
        doodads[4].index = circles.add(doodads[4].pos, 50);
        doodads[5].index = circles.add(doodads[5].pos, 50);
    }
}
