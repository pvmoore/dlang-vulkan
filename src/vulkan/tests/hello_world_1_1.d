module vulkan.tests.hello_world_1_1;

import core.sys.windows.windows;
import core.runtime;
import std.string             : toStringz;
import std.stdio              : writefln;
import std.format             : format;
import std.datetime.stopwatch : StopWatch;

import vulkan.all;

/**
 * Hello World using Vulkan 1.1 features:
 *
 *  https://www.khronos.org/files/vulkan11-reference-guide.pdf
 *  https://registry.khronos.org/vulkan/specs/latest/man/html/VK_VERSION_1_1.html
 *
 * Vulkan 1.1 implies all of:
 * - spirv 1.3
 * - VK_KHR_16bit_storage : allows shaders to use 16-bit types in input/output (optional)
 * - VK_KHR_bind_memory2 : bind multiple buffers/images in one call using the 'vkBindBufferMemory2' function
 * - VK_KHR_dedicated_allocation : allows resources to be bound to a dedicated memory allocation
 * - VK_KHR_descriptor_update_template : update descriptor sets using a template
 * - VK_KHR_device_group : allows multiple physical devices to be used in a single logical device
 * - VK_KHR_device_group_creation : create a logical device from multiple physical devices
 * - VK_KHR_external_fence : allows fences to be exported/imported from/to other APIs
 * - VK_KHR_external_fence_capabilities : query fence capabilities for external APIs
 * - VK_KHR_external_memory : allows memory to be exported/imported from/to other devices
 * - VK_KHR_external_memory_capabilities : query memory capabilities for external devices
 * - VK_KHR_external_semaphore : allows semaphores to be exported/imported from/to other APIs
 * - VK_KHR_external_semaphore_capabilities : query semaphore capabilities for external APIs
 * - VK_KHR_get_memory_requirements2 : adds sType/pNext to Vk[Buffer|Image]MemoryRequirementsInfo2
 * - VK_KHR_get_physical_device_properties2 : adds vkGetPhysicalDeviceProperties2 
 * - VK_KHR_maintenance1
 * - VK_KHR_maintenance2
 * - VK_KHR_maintenance3
 * - VK_KHR_multiview : allows rendering to multiple views simultaneously
 * - VK_KHR_relaxed_block_layout : allows relaxed block layout rules in shaders
 * - VK_KHR_sampler_ycbcr_conversion : allows conversion between YCbCr and RGB in samplers
 * - VK_KHR_shader_draw_parameters : allows shaders to use the 'BaseIndex', 'BaseVertex' and 'DrawIndex' variables
 * - VK_KHR_storage_buffer_storage_class : allows storage buffers to be declared with the 'storage' storage class
 * - VK_KHR_variable_pointers : allows shader modules to use invocation-private pointers into uniform and/or storage buffers
 *
 * If Vulkan 1.1 is supported, the following features must be supported:
 *
 *  - storageBuffer16BitAccess if uniformAndStorageBuffer16BitAccess is supported
 *  - multiview
 *  - shaderDrawParameters if VK_KHR_shader_draw_parameters is supported
 */
final class HelloWorld_1_1 : VulkanApplication {
public:
    this() {
        enum NAME = "Vulkan 1.1 Hello World";
        WindowProperties wprops = {
            width:          1600,
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
            apiVersion: VK_API_VERSION_1_1,
            shaderSpirvVersion:   "1.3"
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

            if(lines) lines.destroy();
            if(text) text.destroy();
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
    override void selectFeaturesAndExtensions(FeaturesAndExtensions fae) {
        VkPhysicalDeviceVulkan11Features v11 = {
            sType: VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES
        };
        fae.addFeatures(v11);
    }
    void update(Frame frame) {
        text.beforeRenderPass(frame);
        lines.beforeRenderPass(frame);
    }
    override void render(Frame frame) {
        auto res = frame.resource;
	    auto b = res.adhocCB;
	    b.beginOneTimeSubmit();

        update(frame);

        // ----------------------------- start render pass
        b.beginRenderPass(
            renderPass,
            frame.frameBuffer,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            [ bgColour ],
            VK_SUBPASS_CONTENTS_INLINE
        );

        lines.insideRenderPass(frame);
        text.insideRenderPass(frame);

        // ----------------------------- end render pass
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

    Camera2D camera;
    VkClearValue bgColour;

    Lines lines;
    Text2 text;
    uint[] spans;

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

        context.withBuffer(MemID.LOCAL, BufID.STORAGE, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 8.MB);

        context.withFonts("resources/fonts/")
               .withImages("resources/images/")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        this.bgColour = clearColour(0.3,0.3,0.3, 1);

        this.lines = new Lines(context, 100)
            .camera(camera)
            .fromColour(float4(0.5,0.5,0.5,1))
            .toColour(float4(0.5,0.5,0.5,1))
            .thickness(1);

        this.text = new Text2(context, context.fonts().get("dejavusansmono"), 10000, 100)
            .camera(camera)
            .setDropShadow(RGBA(0,0,0, 0.75), float2(-0.0025, 0.0025));

        addText();
        //addTestText();
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
    void addText() {
        void add(float2 pos, Text2.Align alignment, string str, float rotation, float4 colour, uint textSize) {       
    
            spans ~= text.createSpan(alignment, pos, textSize, rotation.degrees.radians);

            text.appendText(spans[$-1], str, colour);
        }

        float2 pos = float2(300,50);
        float2 size = float2(600,50);
        lines.add(pos, pos + float2(size.x,0), float4(0.6,0.6,0.6,1), float4(0.5,0.5,0.5,0), 5, 1);
        lines.add(pos, pos + float2(0,size.y), float4(0.6,0.6,0.6,1), float4(0.5,0.5,0.5,0), 5, 1);   

        pos = float2(750, 100);
        lines.add(pos, pos - float2(size.x/2,0), float4(0.6,0.6,0.6,1), float4(0.5,0.5,0.5,0), 5, 1);
        lines.add(pos, pos + float2(size.x/2,0), float4(0.6,0.6,0.6,1), float4(0.5,0.5,0.5,0), 5, 1);
        lines.add(pos, pos + float2(0,size.y), float4(0.6,0.6,0.6,1), float4(0.5,0.5,0.5,0), 5, 1);   

        pos = float2(1200, 150);
        lines.add(pos, pos - float2(size.x,0), float4(0.6,0.6,0.6,1), float4(0.5,0.5,0.5,0), 5, 1);
        lines.add(pos, pos + float2(0,size.y), float4(0.6,0.6,0.6,1), float4(0.5,0.5,0.5,0), 5, 1);   

        add(float2(300,50), Text2.Align.LEFT, "Left aligned", 0, float4(1,1,1,1), 32);
        add(float2(300,50), Text2.Align.LEFT, "Left aligned", 7, float4(1,0.5,0.5,1), 20);

        add(float2(750,100), Text2.Align.CENTRE, "Centered Text", 0, float4(1,1,1,1), 32);
        add(float2(750,100), Text2.Align.CENTRE, "Centered Text", 7, float4(1,0.5,0.5,1), 20);
        
        add(float2(1200,150), Text2.Align.RIGHT, "Right aligned", 0, float4(1,1,1,1), 32);
        add(float2(1200,150), Text2.Align.RIGHT, "Right aligned", 7, float4(1,0.5,0.5,1), 20);

        foreach(i; 0..28) {
            uint span = text.createSpan(Text2.Align.LEFT, float2(20,220 + i*20), 16);
            spans ~= span;

            string s;
            foreach(j; 0..164) {
                s ~= 'a' + uniform(0,26);
            }
            text.appendText(span, s, float4(1,1,1,1));
        }
    }
    void addTestText() {
        uint span = text.createSpan(Text2.Align.LEFT, float2(100,100), 32);
        this.verbose("span = %s", span);
        text.appendText(span, "Hello there", float4(1,1,1,1));

        //text.replaceText(span, "Goodbye", float4(1,0,0,1));
        //text.appendText(span, " Goodbye", float4(1,0,0,1));

        //text.removeText(span, 0, 6);    // "there"
        //text.removeText(span, 5, 600);    // "Hello"
        //text.removeText(span, 1, 3);    // "Ho there"

        // text.updateText(span, 0, "hELLO", float4(0,1,0,1));     // "hELLO there"
        // text.updateText(span, 6, "tHERE!!", float4(0,0,1,1));   // "hELLO tHERE!!"
        // text.updateText(span, 1, "", float4(1,1,1,1));          // no change

        // text.colourSpan(span, 1, 2, float4(1,0,0,1));
        // text.colourSpan(span, 1, 0, float4(1,1,1,1));     // no effect
        // text.colourSpan(span, 2, 100, float4(1,1,1,1));     // no effect
        
        // text.resizeSpan(span, 64);
        // text.rotateSpan(span, 15.degrees.radians);
        // text.moveSpan(span, float2(300,300));

        text.insertText(span, 6, "!! ", float4(0,1,1,1));   // "Hello !! there"
        text.insertText(span, text.getSpanLength(span), "!!", float4(1,1,0,1));  // "Hello !! there!!"
        text.insertText(span, 0, "!!", float4(1,0,1,1));  // "!!Hello !! there!!"

        // uint span2 = text.createSpan(Text2.Align.LEFT, float2(100,150), 32);
        // text.appendText(span2, "Goodbye", float4(1,1,1,1));

        // text.removeSpan(span);

        // span = text.createSpan(Text2.Align.LEFT, float2(100,100), 32);
        // text.appendText(span, "Welcome", float4(1,1,1,1));
        // this.verbose("span = %s", span);

        //text.clear();
    }
}
