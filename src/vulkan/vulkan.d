module vulkan.vulkan;

/**
 *  Todo:
 *      - Updating uniform buffers may really benefit from using shared memory.
 */
import vulkan.all;
import vulkan.glfw_events;

// Global Vulkan instance. We assume there will only be one
__gshared Vulkan g_vulkan;

struct MouseState {
	float2 pos;
	float wheel = 0;

	float2 dragStart;
	float2 dragEnd;
	bool isDragging;

    uint buttonMask; // bit flag for each mouse button ( 1 = pressed )

    /** Return the index of the first pressed button starting from 0 (the LMB) or -1 if none are pressed */
    int button() {
        import core.bitop : bsf;
        if(buttonMask == 0) return -1;
        return bsf(buttonMask);
    }

	string toString() {
		return "pos:%s buttons:%08b wheel:%s dragging:%s dragStart:%s dragEnd:%s"
			.format(pos, buttonMask, wheel, isDragging, dragStart, dragEnd);
	}
}

final class Vulkan {
public:
    WindowProperties wprops;
    VulkanProperties vprops;
    IVulkanApplication app;

    VkInstance instance;
    VkPhysicalDevice physicalDevice;
    VkPhysicalDeviceProperties properties;
    VkPhysicalDeviceMemoryProperties memoryProperties;
    VkFormatProperties formatProperties;
    VkPhysicalDeviceLimits limits;
    VkDevice device;
    VkSurfaceKHR surface;

    ShaderCompiler shaderCompiler;
    FeaturesAndExtensions featuresAndExtensions = new FeaturesAndExtensions();
    InstanceHelper instanceHelper;
    Swapchain swapchain;
    QueueManager queueManager;

    GLFWwindow* getGLFWWindow() { return window; }
    ImGuiContext* getImguiContext() { return imguiContext; }

    ImFont* getImguiFont(uint index) {
        throwIf(index >= imguiFonts.length, "Font at index %s does not exist".format(index));
        return imguiFonts[index];
    }

    uint getGraphicsQueueFamily() { return queueManager.getFamily(QueueManager.GRAPHICS); }
    uint getTransferQueueFamily() { return queueManager.getFamily(QueueManager.TRANSFER); }
    uint getComputeQueueFamily()  { return queueManager.getFamily(QueueManager.COMPUTE); }

    VkQueue getGraphicsQueue() { return getQueue(QueueManager.GRAPHICS); }
    VkQueue getTransferQueue() { return getQueue(QueueManager.TRANSFER); }
    VkQueue getComputeQueue()  { return getQueue(QueueManager.COMPUTE); }

    VkQueue getQueue(string label, uint queueIndex = 0) {
        return queueManager.getQueue(label, queueIndex);
    }

    VkCommandPool getGraphicsCP() { return graphicsCP; }
    VkCommandPool getTransferCP() { return transferCP; }

    uint2 windowSize() const { return swapchain.extent.toUint2(); }

    FrameNumber getFrameNumber() { return frameNumber; }
    uint getFrameResourceIndex() { return frameResourceIndex; }

    PerFrameResource[] getPerFrameResources() { return perFrameResources; }

	this(IVulkanApplication app,
	     ref WindowProperties wprops,
	     ref VulkanProperties vprops)
    {
        g_vulkan          = this;
	    this.app          = app;
		this.wprops       = wprops;
		this.vprops       = vprops;
		this.frameTiming  = new Timing(10,3);
	}
	void destroy() {
		this.verbose("Destroy called...");

        // device objects
		if(device) {
            vkDeviceWaitIdle(device);

            if(shaderCompiler) shaderCompiler.destroy();

            foreach(qp; queryPools) {
                device.destroyQueryPool(qp);
            }
            this.verbose("Destroyed %s query pools", queryPools.length);
            queryPools = null;

            foreach(cp; commandPools) {
                device.destroyCommandPool(cp);
            }
            this.verbose("Destroyed %s command pools", commandPools.length);
            commandPools = null;

            foreach(r; perFrameResources) {
                if(r is null) continue;
                if(r.imageAvailable) device.destroySemaphore(r.imageAvailable);
                if(r.renderFinished) device.destroySemaphore(r.renderFinished);
                if(r.fence) device.destroyFence(r.fence);
            }
            this.verbose("Destroyed %s per frame resources", perFrameResources.length);
            perFrameResources = null;

            if(swapchain) swapchain.destroy();

            if(vprops.imgui.enabled) {
                destroyImgui();
            }

            device.destroyDevice();
        }

        // instance objects
        if(surface) instance.destroySurfaceKHR(surface);
		destroy_VK_EXT_debug_utils(instance);
		if(instance) instance.destroyInstance();

		// glfw and derelict objects
        this.verbose("Terminating");
		if(window) glfwDestroyWindow(window);
		glfwTerminate();

        unloadSharedLibs();
	}
	void initialise() {
        assert(thread_isMainThread());

        loadSharedLibs();

        this.verbose("Initialising GLFW %s", glfwGetVersionString().fromStringz);
        if(!glfwInit()) {
            glfwTerminate();
            throw new Exception("glfwInit failed");
        }
        if(!glfwVulkanSupported()) {
            throw new Exception("Vulkan is not supported on this device.");
        }
        glfwSetErrorCallback(&errorCallbackHandler);

        // vulkan instance
        this.verbose("----------------------------------------------------------------------------------");
        instanceHelper = new InstanceHelper();
        instance = createInstance(vprops, instanceHelper);
        initialise_VK_EXT_debug_utils(instance, instanceHelper);

        vkLoadInstanceFunctions(instance);


        this.verbose("----------------------------------------------------------------------------------");

        string slangCompilerVersion = ShaderCompiler.getSlangCompilerVersion(vprops);
        string glslCompilerVersion = ShaderCompiler.getGlslCompilerVersion(vprops);
        this.verbose("Slang compiler version: %s", slangCompilerVersion);
        this.verbose("GLSL  compiler version: %s", glslCompilerVersion);

        this.verbose("----------------------------------------------------------------------------------");;

        // physical device
        physicalDevice   = selectBestPhysicalDevice(instance, vprops.apiVersion);
        memoryProperties = physicalDevice.getMemoryProperties();
        properties       = physicalDevice.getProperties();
        limits           = properties.limits;

        featuresAndExtensions.initialise(physicalDevice, vprops);
        // Allow the application to enable/disable features
        app.selectFeaturesAndExtensions(featuresAndExtensions);

        this.verbose("----------------------------------------------------------------------------------");

        createQueueManager();

        this.verbose("----------------------------------------------------------------------------------");

        // window and surface
        if(!wprops.headless) {
            createWindow();
            createSurface();

            if (!physicalDevice.canPresent(surface, queueManager.getFamily(QueueManager.GRAPHICS))) {
                throw new Error("Can't present on this surface");
            }
        }

        this.verbose("----------------------------------------------------------------------------------");

        createLogicalDevice();

        this.verbose("----------------------------------------------------------------------------------");

        this.verbose("Loading device functions...");
        vkLoadDeviceFunctions(device);

        // these require a logical device

        this.shaderCompiler = new ShaderCompiler(device, vprops);

        if(!wprops.headless) {
            createSwapChain();
            this.verbose("windowSize = %s", windowSize);

            if(!wprops.fullscreen) {
                import std : fromStringz, format, strip;
                import core.cpuid: processor;
                string gpuName = cast(string)properties.deviceName.ptr.fromStringz;
                string title = "%s :: %s, %s".format(wprops.title, gpuName, processor()).strip();
                setWindowTitle(title);
            }
        }
        
        createCommandPools();
        createPerFrameResources();

        if(vprops.imgui.enabled) {
            initImgui();
        } else {
            this.verbose("Imgui is not enabled");
        }

        // Inform the app that we are now ready
        this.verbose("--------------------------------------------------------------- device ready");
        app.deviceReady(device);

        if(wprops.showWindow) showWindow(true);
        isInitialised = true;
    }
    /**
     *  This will run until mainLoopExit() or glfwWindowShouldClose() is called.
     */
	void mainLoop() {
	    throwIf(!isInitialised, "vulkan.init() has not been called");

	    this.verbose("╔═════════════════════════════════════════════════════════════════╗");
        this.verbose("║ Entering main loop                                              ║");
        this.verbose("╚═════════════════════════════════════════════════════════════════╝");
	    import core.sys.windows.windows;

        enum FPS_SAMPLES_PER_SECOND = 8; static assert(popcnt(FPS_SAMPLES_PER_SECOND) == 1);
        enum NANOS_PER_FPS_SAMPLE   = 1_000_000_000 / FPS_SAMPLES_PER_SECOND;
        ulong[FPS_SAMPLES_PER_SECOND] fpsSamples;

        ulong lastFrameTotalNsecs;
        ulong lastSecond;
        uint lastSampleIndex = uint.max;
        StopWatch watch;
        watch.start();

        Frame frame = {
            number: FrameNumber(0),
            seconds: 0,
            perSecond: 1,
            resource: null
        };

        /**
         *  Called once per FPS sample (see FPS_SAMPLES_PER_SECOND)
         */
        void perFPSSample(uint index, ulong frameTimeNanos) {
            if(index == 0) {
                ulong total = (fpsSamples[].sum()) / FPS_SAMPLES_PER_SECOND;
                this.currentFPS = 1_000_000_000.0 / total;
            }

            lastSampleIndex = index;
            fpsSamples[index] = frameTimeNanos;
        }
        /**
         *  Called once per second 
         */
        void perSecond(Frame frame, ulong second) {
            lastSecond = second;

            if(wprops.titleBarFps && !wprops.fullscreen) {
                string s = "%s :: | %.2f fps |".format(wprops.title, currentFPS);
                glfwSetWindowTitle(window, s.toStringz);
            }

            this.verbose("Frame (number:%s, seconds:%.2f) perSecond=%.4f time:%.3f fps:%.2f",
                frame.number,
                frame.seconds,
                frame.perSecond,
                frameTimeNanos/1_000_000.0,
                currentFPS);
        }

        while(!glfwWindowShouldClose(window)) {
            glfwPollEvents();

            if(isIconified) {
                // Don't render the frame if the app is iconified.
                // We could still call the app to let it do processing but
                // this needs some thought.
                if(watch.running) {
                    watch.stop();
                }
                continue;
            }
            // Make sure watch is running after possible iconification
            if(!watch.running) {
                watch.start();
            }

            renderFrame(frame);

            ulong time          = watch.peek().total!"nsecs";
            frameTimeNanos      = time - lastFrameTotalNsecs;
            lastFrameTotalNsecs = time;

            frame.perSecond = frameTimeNanos/1_000_000_000.0;
            frame.number    = frame.number.next();
            frame.seconds  += frame.perSecond;

            this.frameNumber = frame.number;

            // Per sample
            uint index = (time/NANOS_PER_FPS_SAMPLE & (FPS_SAMPLES_PER_SECOND-1)).as!uint;
            if(index != lastSampleIndex) {
                perFPSSample(index, frameTimeNanos);
            }

            // Per second
            if(frame.seconds.as!ulong > lastSecond) {
                perSecond(frame, frame.seconds.as!ulong);
            }
        }
        this.verbose("╔═════════════════════════════════════════════════════════════════╗");
        this.verbose("║ Exiting main loop                                               ║");
        this.verbose("╚═════════════════════════════════════════════════════════════════╝");
	}
    /**
     *  Signal the main loop to exit.
     */
    void mainLoopExit() {
        glfwSetWindowShouldClose(window, true);
    }
    /**
     *  This function must only be called from the main thread
     */
    void showWindow(bool show=true) {
        assert(thread_isMainThread());
        if(show) glfwShowWindow(window);
        else glfwHideWindow(window);
	}
    ulong getFrameTimeNanos() {
        return frameTimeNanos;
    }
	float getFPSSnapshot() const {
	    return currentFPS;
	}
    /**
     * This function must only be called from the main thread
     */
	Tuple!(float,float) getMousePos() {
        assert(thread_isMainThread());
        double x,y;
        glfwGetCursorPos(window, &x, &y);
        return Tuple!(float,float)(cast(float)x, cast(float)y);
    }
    MouseState getMouseState() {
        auto state = mouseState;
        mouseState.wheel = 0;
        return state;
    }
    /**
     * Return true if the key is pressed with any of the the specified modifiers
     * (This can be called on any thread)
     *
     * https://www.glfw.org/docs/latest/group__keys.html
     */
    bool isKeyPressed(uint key, KeyMod mods = KeyMod.NONE) {
        KeyState state = keyStates[key];
        return state.action!=KeyAction.RELEASE && (mods == 0 || ((mods & state.mod) != 0));
    }
    /**
     * Return true if the mouse button is pressed with any of the the specified key modifiers
     * (This can be called on any thread)
     */
    bool isMouseButtonPressed(int button, KeyMod mods = KeyMod.NONE) {
        MouseButtonState state = mouseButtonStates[button];
        return state.pressed && (mods == 0 || ((mods & state.mod) != 0));
    }
    /**
     *  This function must only be called from the main thread
     */
    void setWindowTitle(string title) {
        assert(thread_isMainThread());
        wprops.title = title;
        glfwSetWindowTitle(window, title.toStringz);
    }
    /**
     *  This function must only be called from the main thread
     */
    void setWindowIcon(string pngfile) {
        assert(thread_isMainThread());
        auto png = PNG.read(pngfile);
        GLFWimage image = {
            width: png.width,
            height: png.height,
            pixels: png.data.ptr
        };
        glfwSetWindowIcon(window, 1, &image);
    }
    /**
     *  This function must only be called from the main thread
     */
    void setMouseCursorVisible(bool visible) {
        assert(thread_isMainThread());
        glfwSetInputMode(window, GLFW_CURSOR, visible? GLFW_CURSOR_NORMAL : GLFW_CURSOR_HIDDEN);
    }
    /**
     *  This will capture the mouse and make it hidden.
     *  The application will need to display its own cursor.
     *  This function must only be called from the main thread
     */
    void captureMouse() {
        assert(thread_isMainThread());
        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    }
    /**
     *  This sort of works but it doesn't display on Vulkan screen.
     *  Not sure whether this works better on OpenGL??
     *  This function must only be called from the main thread
     */
    void setCustomMouse(string pngfile, int xhotspot=0, int yhotspot=0) {
        assert(thread_isMainThread());
        auto png = PNG.read(pngfile);
        GLFWimage image = {
            width: png.width,
            height: png.height,
            pixels: png.data.ptr
        };
        auto cursor = glfwCreateCursor(&image, xhotspot, yhotspot);
        if(cursor) {
            glfwSetCursor(window, cursor);
        }
        // cursor will be destroyed by glfwTerminate
    }
    /**
     *  VCommandPoolCreate.RESET_COMMAND_BUFFER
     *  VCommandPoolCreate.TRANSIENT
     */
    VkCommandPool createCommandPool(uint queueFamily, VkCommandPoolCreateFlags flags) {
        throwIf((flags & ~(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT|VK_COMMAND_POOL_CREATE_TRANSIENT_BIT)) != 0);

        auto cp = device.createCommandPool(queueFamily, flags);
        commandPools ~= cp;
        return cp;
    }
    VkQueryPool createQueryPool(VkQueryType type, uint count, VkQueryPipelineStatisticFlags flags) {
        auto qp = device.createQueryPool(type, count, flags);
        queryPools ~= qp;
        return qp;
    }
    void addWindowEventListener(WindowEventListener listener) {
        this.windowEventListeners ~= listener;
    }
    /** Call this before doing any imgui rendering in your frame */
    void imguiRenderStart(Frame frame) {
        ImGui_ImplVulkan_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        igNewFrame();
    }
    /** Call this after doing your imgui rendering in your frame */
    void imguiRenderEnd(Frame frame) {
        igRender();
        auto drawData = igGetDrawData();
        ImGui_ImplVulkan_RenderDrawData(drawData, frame.resource.adhocCB, null);

        ImGuiIO* io = igGetIO();
        if(io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
            // These are required to correctly display docking windows
            igUpdatePlatformWindows();
            igRenderPlatformWindowsDefault(null, null);
        }
    }
//──────────────────────────────────────────────────────────────────────────────────────────────────    
package:
    // Semi-private members. Used by vulkan_events.d
    WindowEventListener[] windowEventListeners;
    bool isIconified;
    MouseState mouseState;
//──────────────────────────────────────────────────────────────────────────────────────────────────    
private:
    bool isInitialised;
    float currentFPS = 0;   // Latest FPS snapshot (recalculated every second)
    ulong frameTimeNanos;   // Latest frame time in nanoseconds
    GLFWwindow* window;

    FrameNumber frameNumber; // The current frame number (increments every frame)
    uint frameResourceIndex; // The current Frame.resource.index (0..swapchain.numImages-1)

    Timing frameTiming;
    PerFrameResource[] perFrameResources;

    VkCommandPool[] commandPools;
    VkQueryPool[] queryPools;
    VkCommandPool graphicsCP;
    VkCommandPool transferCP;
    @Borrowed VkRenderPass renderPass;

    // optional if imgui is enabled
    ImGuiContext* imguiContext;
    ImFont*[] imguiFonts;

    void renderFrame(Frame frame) {

        /// Select the current frame resource.
        this.frameResourceIndex = (frameNumber.value%perFrameResources.length).as!uint;
        frame.resource = perFrameResources[frameResourceIndex];

        /// Wait for the fence.
        device.waitFor(frame.resource.fence);
        device.reset(frame.resource.fence);

        /// Get the next available image view.
        frame.imageIndex = swapchain.acquireNext(frame.resource.imageAvailable, null);

        // Set the Frame image
        frame.image = swapchain.images[frame.imageIndex];
        frame.imageView = swapchain.views[frame.imageIndex];
        if(swapchain.frameBuffers.length != 0) {
            frame.frameBuffer = swapchain.frameBuffers[frame.imageIndex];
        }

        /// Let the app do its thing.
        app.render(frame);

        /// Present.
        swapchain.queuePresent(
            getQueue(QueueManager.GRAPHICS),
            frame.imageIndex,
            [frame.resource.renderFinished] // wait semaphores
        );
    }
    /**
     * Select a single graphics, transfer and compute queue family for our use.
     * If 'headless' is requested then we don't select a graphics queue family.
     *
     * After this, the app can make adjustments and validate the queue families.
     */
    void createQueueManager() {
        this.verbose("Creating QueueManager and selecting queue families...");
        auto queueFamilyProps = physicalDevice.getQueueFamilies();

        this.queueManager = new QueueManager(physicalDevice, surface, queueFamilyProps);

        /** Find a graphics queue family if we are not in headless mode */
        FamilyAndCount graphics = FamilyAndCount.NONE;

        if(!wprops.headless) {
            graphics = queueManager.findFirstWith(VkQueueFlagBits.VK_QUEUE_GRAPHICS_BIT);
            if(graphics==FamilyAndCount.NONE) {
                throwIf(true, "No graphics queue family found");
            }
            // Request a single graphics queue
            graphics.count = 1;
            queueManager.request(QueueManager.GRAPHICS, graphics);
        } else {
            this.verbose("Headless mode requested: Not selecting a graphics queue family");
        }

        /** Try to find a dedicated transfer queue family */
        auto transfer = queueManager.findFirstWith(VkQueueFlagBits.VK_QUEUE_TRANSFER_BIT, [graphics.family]);
        if(transfer==FamilyAndCount.NONE) {
            transfer = queueManager.findFirstWith(VkQueueFlagBits.VK_QUEUE_TRANSFER_BIT);
        }
        if(transfer==FamilyAndCount.NONE) {
            throwIf(true, "No transfer queue family found");
        }
        // Request a single transfer queue
        transfer.count = 1;
        queueManager.request(QueueManager.TRANSFER, transfer);

        /** Try to find a dedicated compute queue family */
        FamilyAndCount[] allCompute = queueManager.findQueueFamilies(VkQueueFlagBits.VK_QUEUE_COMPUTE_BIT, VkQueueFlagBits.VK_QUEUE_GRAPHICS_BIT);
        if(allCompute.length==0) {
            /** No non-graphics compute queue families. Get a non-dedicated one */
            allCompute = queueManager.findQueueFamilies(VkQueueFlagBits.VK_QUEUE_COMPUTE_BIT, 0.as!VkQueueFlagBits);
        }
        if(allCompute.length==0) {
            throwIf(true, "No compute queue family found");
        }
        /** Use a single queue from the first one */
        allCompute[0].count = 1;
        queueManager.request(QueueManager.COMPUTE, allCompute[0]);

        // Let the app make adjustments and validate
        app.selectQueueFamilies(queueManager);
    }
    void createLogicalDevice() {
        this.verbose("Creating logical device...");

        this.verbose("   Creating queue infos:");
        VkDeviceQueueCreateInfo[] queueInfos;
        foreach(t; queueManager.getAllRequestedQueues()) {
            uint index = t[0];
            uint count = t[1];

            this.verbose("   Family index %s : %s queues", index, count);

            float[] priorities = new float[count];
            priorities[] = 1.0f;
            queueInfos ~= deviceQueueCreateInfo(index, priorities);
        }

        /** Create the logical device */
        device = .createLogicalDevice(app, physicalDevice, vprops, featuresAndExtensions, queueInfos);

        queueManager.onDeviceCreated(device);

        // optimise some device calls to remove trampoline
//        vkCreateBuffer     = device.getProcAddr!PFN_vkCreateBuffer("vkCreateBuffer");
//        vkBindBufferMemory = device.getProcAddr!PFN_vkBindBufferMemory("vkBindBufferMemory");
//        vkMapMemory        = device.getProcAddr!PFN_vkMapMemory("vkMapMemory");
//        vkUnmapMemory      = device.getProcAddr!PFN_vkUnmapMemory("vkUnmapMemory");
//        vkGetBufferMemoryRequirements = device.getProcAddr!PFN_vkGetBufferMemoryRequirements("vkGetBufferMemoryRequirements");
//
//        vkAllocateCommandBuffers = device.getProcAddr!PFN_vkAllocateCommandBuffers("vkAllocateCommandBuffers");
//
//        vkCreateFence = device.getProcAddr!PFN_vkCreateFence("vkCreateFence");
//        vkDestroyFence = device.getProcAddr!PFN_vkDestroyFence("vkDestroyFence");
//
//        vkQueueSubmit = device.getProcAddr!PFN_vkQueueSubmit("vkQueueSubmit");
    }
    void createCommandPools() {
        this.verbose("Creating command pools");
        if(!wprops.headless) {
            graphicsCP = createCommandPool(queueManager.getFamily(QueueManager.GRAPHICS),
                VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT | VK_COMMAND_POOL_CREATE_TRANSIENT_BIT);
            this.verbose("Vulkan: Created graphics command pool using queue family %s", queueManager.getFamily(QueueManager.GRAPHICS));
        }
        transferCP = createCommandPool(queueManager.getFamily(QueueManager.TRANSFER),
            VK_COMMAND_POOL_CREATE_TRANSIENT_BIT);
        this.verbose("Vulkan: Created transfer command pool using queue family %s", queueManager.getFamily(QueueManager.TRANSFER));
    }
    void createPerFrameResources() {
        if(wprops.headless) return;
        this.verbose("Creating per frame resources");
        throwIf(!vprops.useDynamicRendering && swapchain.frameBuffers[0] is null);
        foreach(i; 0..swapchain.numImages) {
            auto r = new PerFrameResource;
            r.index            = i;
            r.adhocCB          = device.allocFrom(graphicsCP);
            r.renderFinished   = device.createSemaphore();
            r.imageAvailable   = device.createSemaphore();
            r.fence            = device.createFence(true);

            setObjectDebugName!VK_OBJECT_TYPE_COMMAND_BUFFER(device, r.adhocCB, "PerFrameResource[%s].adhocCB".format(i));
            setObjectDebugName!VK_OBJECT_TYPE_SEMAPHORE(device, r.imageAvailable, "PerFrameResource[%s].imageAvailable".format(i));
            setObjectDebugName!VK_OBJECT_TYPE_SEMAPHORE(device, r.renderFinished, "PerFrameResource[%s].renderFinished".format(i));
            setObjectDebugName!VK_OBJECT_TYPE_FENCE(device, r.fence, "PerFrameResource[%s].fence".format(i));

            perFrameResources ~= r;
        }
        this.verbose("Created %s per frame resources", perFrameResources.length);
    }
    void createWindow() {
        this.verbose("Creating window");
        GLFWmonitor* monitor = glfwGetPrimaryMonitor();
        auto vidmode = glfwGetVideoMode(monitor);
        if(!wprops.fullscreen) {
            this.verbose("Windowed mode selected");
            monitor = null;
            if(wprops.width==0 || wprops.height==0) {
                wprops.width  = vidmode.width;
                wprops.height = vidmode.height;
            }
            glfwWindowHint(GLFW_VISIBLE, 0);
            glfwWindowHint(GLFW_RESIZABLE, wprops.resizable ? 1 : 0);
            glfwWindowHint(GLFW_DECORATED, wprops.decorated ? 1 : 0);
        } else {
            this.verbose("Full screen mode selected");
            //glfwWindowHint(GLFW_REFRESH_RATE, 60);
            wprops.width  = vidmode.width;
            wprops.height = vidmode.height;
        }

        // other window hints
        //glfwWindowHint(GLFW_DOUBLEBUFFER, 1);
//        if(hints.samples > 0) {
//            glfwWindowHint(GLFW_SAMPLES, hints.samples);
//        }
        glfwWindowHint(GLFW_AUTO_ICONIFY, wprops.autoIconify ? 1 : 0);

        glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
        GLFWwindow* share = null;
        window = glfwCreateWindow(wprops.width, wprops.height, wprops.title.toStringz, monitor, share);

        if(!wprops.fullscreen) {
            glfwSetWindowPos(
                window,
                ((cast(int)vidmode.width - wprops.width) / 2),
                ((cast(int)vidmode.height - wprops.height) / 2)
            );
        }

        // Key events
        glfwSetKeyCallback(window, &keyCallbackHandler);
        
        // Mouse events
        glfwSetMouseButtonCallback(window, &mouseButtonCallbackHandler);
        glfwSetCursorPosCallback(window, &cursorPosCallbackHandler);
        glfwSetScrollCallback(window, &scrollCallbackHandler);
        glfwSetCursorEnterCallback(window, &cursorEnterCallbackHandler);
        
        // Window events
        glfwSetWindowFocusCallback(window, &WindowFocusCallbackHandler);
        glfwSetWindowIconifyCallback(window, &windowIconifyCallbackHandler);

        //glfwSetWindowRefreshCallback(window, &windowRefreshCallbackHandler);
        //glfwSetWindowPosCallback(window, &windowPosCallbackHandler);
        //glfwSetWindowSizeCallback(window, &windowSizeCallbackHandler);
        //glfwSetWindowCloseCallback(window, &windowCloseCallbackHandler);
        //glfwSetWindowMaximizeCallback(window, &windowMaximizeCallbackHandler);
        //glfwSetDropCallback(window, &dropCallbackHandler);

        if(wprops.icon !is null) {
            setWindowIcon(wprops.icon);
        }
    }
    void createSurface() {
        this.verbose("Creating surface");
        check(glfwCreateWindowSurface(instance, window, null, &surface));
    }
    void createSwapChain() {
        this.swapchain = new Swapchain(this);
        this.swapchain.create(surface);
        
        if(!vprops.useDynamicRendering) {
            this.renderPass = app.getRenderPass(device);
            this.swapchain.createFrameBuffers(renderPass);
        }
    }
    void initImgui() {
        this.verbose("Initialising ImGui");

        imguiContext = igCreateContext(null);
        throwIf(imguiContext is null);

        ImGuiIO* io = igGetIO(imguiContext);

        //io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls
        //io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls
        //io.ConfigFlags |= ImGuiConfigFlags_NavNoCaptureKeyboard; // Don't capture the keyboard
        //io.ConfigFlags |= ImGuiConfigFlags_NoMouseCursorChange; // Don't change the mouse pointer

        // Enable docking
        // io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
        // io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;

        io.ConfigFlags |= vprops.imgui.configFlags;

        igStyleColorsDark(null);

        auto v = igGetVersion();
        this.verbose("ImGui version is %s", fromStringz(v));

        bool res = ImGui_ImplGlfw_InitForVulkan(window, true);
        throwIf(!res, "ImGui_ImplGlfw_InitForVulkan failed");

        ImGui_ImplVulkan_InitInfo info = {
            Instance: instance,
            PhysicalDevice: physicalDevice,
            Device: device,
            Queue: getGraphicsQueue(),
            DescriptorPool: null, 
            MinImageCount: swapchain.numImages(),
            ImageCount: swapchain.numImages(),
            MSAASamples: VK_SAMPLE_COUNT_1_BIT,
            RenderPass: renderPass,
            DescriptorPoolSize: 100,
            UseDynamicRendering: false,
        };

        // Set some properties for dynamic rendering
        if(vprops.useDynamicRendering) {
            VkPipelineRenderingCreateInfo renderingInfo = {
                sType: VK_STRUCTURE_TYPE_PIPELINE_RENDERING_CREATE_INFO,
                viewMask: 0,
                colorAttachmentCount: 1,
                pColorAttachmentFormats: &swapchain.colorFormat,
                depthAttachmentFormat: VK_FORMAT_UNDEFINED,
                stencilAttachmentFormat: VK_FORMAT_UNDEFINED
            };
            info.UseDynamicRendering = true;
            info.PipelineRenderingCreateInfo = renderingInfo;
        }

        res = ImGui_ImplVulkan_Init(&info);
        throwIf(!res, "ImGui_ImplVulkan_Init failed");

        // Upload font textures
        {
            throwIf(vprops.imgui.fontPaths.length != vprops.imgui.fontSizes.length,
                "fontPaths.length amd fontSizes.length must be the same");
            foreach(i, path; vprops.imgui.fontPaths) {
                auto size = vprops.imgui.fontSizes[i];

                auto font = ImFontAtlas_AddFontFromFileTTF(
                    io.Fonts,
                    toStringz(path),
                    size,
                    null,   // ImFontConfig* (in)
                    null);  // ImWchar* glyph_ranges (in)

                throwIf(font is null, "Failed to load font '%s'".format(path));

                imguiFonts ~= font;
            }
        }
    }
    void destroyImgui() {
        ImGui_ImplVulkan_Shutdown();
        ImGui_ImplGlfw_Shutdown();
        igDestroyContext(imguiContext);
    }
}
