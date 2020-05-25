module vulkan.vulkan;
/**
 *  Todo:
 *        Try using this syntax for infos:
 *        VkDescriptorPoolSize s = {
 *            descriptorCount : 1
 *        };
 *
 *        If using dyanamic command buffers because of push constants:
 *          If the push constants don't change every frame it might
 *          be worthwhile baking the command buffer when the constants
 *          change and using them statically until the next change. This
 *          might work well for Text for example.
 *
 *        Updating uniform buffers may really benefit from using
 *        shared memory.
 */
import vulkan.all;

__gshared Vulkan g_vulkan;

final class Vulkan {
private:
    bool isInitialised;
    uint prevFrameIndex;
    float currentFPS = 0;
    uint targetFPS = 60;
    ulong targetFrameTimeNsecs = 1_000_000_000/60;
    GLFWwindow* window;
    MouseState mouseState;
    ulong frameNumber;
    ulong maxFPS;

    Timing frameTiming;
    PerFrameResource[] perFrameResources;

    VDebug debug_;
    VkCommandPool[] commandPools;
    VkQueryPool[] queryPools;
    VkCommandPool graphicsCP, transferCP;
public:
    WindowProperties wprops;
    VulkanProperties vprops;
    VulkanApplication app;
    ShaderCompiler shaderCompiler;

    VkInstance instance;
    VkPhysicalDevice physicalDevice;
    VkPhysicalDeviceProperties properties;
    VkPhysicalDeviceMemoryProperties memoryProperties;
    VkFormatProperties formatProperties;
    VkPhysicalDeviceLimits limits;
    VkDevice device;
    VkSurfaceKHR surface;

    Swapchain swapchain;
    VulkanMemoryManager memory;
    Fonts fonts;
    QueueManager queueManager;

    QueueFamily getGraphicsQueueFamily() { return queueManager.getFamily(QueueManager.GRAPHICS); }
    QueueFamily getTransferQueueFamily() { return queueManager.getFamily(QueueManager.TRANSFER); }
    QueueFamily getComputeQueueFamily()  { return queueManager.getFamily(QueueManager.COMPUTE); }

    VkQueue getGraphicsQueue() { return getQueue(QueueManager.GRAPHICS); }
    VkQueue getTransferQueue() { return getQueue(QueueManager.TRANSFER); }
    VkQueue getComputeQueue()  { return getQueue(QueueManager.COMPUTE); }

    VkQueue getQueue(string label, uint queueIndex = 0) {
        return queueManager.getQueue(label, queueIndex);
    }


    VkCommandPool getTransferCP() { return transferCP; }
    uvec2 windowSize() const { return swapchain.extent.toUvec2; }

    ulong getFrameNumber() { return frameNumber; }

    PerFrameResource getFrameResource(ulong i) { return perFrameResources[i]; }

	this(VulkanApplication app,
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
		log("Destroying Vulkan");

        // device objects
		if(device) {
            vkDeviceWaitIdle(device);

            if(shaderCompiler) shaderCompiler.destroy();

            foreach(qp; queryPools) {
                device.destroyQueryPool(qp);
            }
            log("Destroyed %s query pools", queryPools.length);
            queryPools = null;

            foreach(cp; commandPools) {
                device.destroyCommandPool(cp);
            }
            log("Destroyed %s command pools", commandPools.length);
            commandPools = null;

            if(fonts) fonts.destroy();

            foreach(r; perFrameResources) {
                if(r is null) continue;
                if(r.imageAvailable) device.destroySemaphore(r.imageAvailable);
                if(r.renderFinished) device.destroySemaphore(r.renderFinished);
                if(r.fence) device.destroyFence(r.fence);
                if(r.frameBuffer) device.destroyFrameBuffer(r.frameBuffer);
            }
            log("Destroyed %s per frame resources", perFrameResources.length);
            perFrameResources = null;

            if(swapchain) swapchain.destroy();
            if(memory) memory.destroy();
            device.destroyDevice();
        }

        // instance objects
        if(surface) instance.destroySurfaceKHR(surface);
		if(debug_) debug_.destroy();
		if(instance) instance.destroyInstance();

		// glfw and derelict objects
		if(window) glfwDestroyWindow(window);
		glfwTerminate();
        DerelictGLFW3.unload();
		DerelictVulkan.unload();
        unloadExtraVulkanFunctions();
	}
	void initialise() {
        log("Initialising Vulkan");
        DerelictVulkan.load();
        DerelictGLFW3.load();
        DerelictGLFW3_loadVulkan();
        loadVulkan_1_1_Functions();

        log("Initialising GLFW %s", glfwGetVersionString().fromStringz);
        if(!glfwInit()) {
            glfwTerminate();
            throw new Exception("glfwInit failed");
        }
        if(!glfwVulkanSupported()) {
            throw new Exception("Vulkan is not supported on this device.");
        }
        glfwSetErrorCallback(&errorCallback);

        // vulkan instance
        instance = createInstance(vprops);
        debug debug_ = new VDebug(instance);

        loadVulkanInstanceFunctions(instance);

        // physical device
        physicalDevice   = selectBestPhysicalDevice(instance, vprops.minApiVersion, vprops.deviceExtensions);
        memoryProperties = physicalDevice.getMemoryProperties();
        properties       = physicalDevice.getProperties();
        limits           = properties.limits;

        // window
        if(!wprops.headless) {
            createWindow();
            createSurface();
        }

        createQueueManager();

        if(!wprops.headless) {
            if (!physicalDevice.canPresent(surface, queueManager.getFamily(QueueManager.GRAPHICS).index)) {
                throw new Error("Can't present on this surface");
            }
        }

        createLogicalDevice();

        // these require a logical device

        this.shaderCompiler = new ShaderCompiler(device, "shaders/", vprops.shaderDirectory);
        createSwapChain();
        createMemoryManager();
        createCommandPools();
        createPerFrameResources();

        this.fonts = new Fonts(this);

        // Inform the app that we are now ready
        app.deviceReady(device, perFrameResources);

        if(wprops.showWindow) showWindow(true);
        isInitialised = true;
        flushLog();
    }
	void mainLoop() {
	    log("----- Entering main loop");
	    import core.sys.windows.windows;

	    if(!isInitialised) throw new Error("vulkan.init() has not been called");
        ulong lastFrameTotalNsecs;
        ulong seconds;
        FrameInfo frame = FrameInfo(0,0,1);
        StopWatch watch;
        watch.start();

        while(!glfwWindowShouldClose(window)) {

            renderFrame(frame);
            glfwPollEvents();

            ulong time          = watch.peek().total!"nsecs";
            ulong frameNsecs    = time - lastFrameTotalNsecs;
            lastFrameTotalNsecs = time;

            frame.delta = cast(double)frameNsecs/targetFrameTimeNsecs;
            frame.number++;
            frame.relativeNumber += frame.delta;

            frameNumber = frame.number;

            frameTiming.endFrame(frameNsecs);

            if(maxFPS>0 && frameNsecs<maxFPS) {
                // Throttle down to max fps
                // This doesn't work very well
                //auto wait = maxFPS-frameNsecs;
                //Thread.sleep(dur!"nsecs"(maxFPS-frameNsecs));
            }

            if(time/1_000_000_000L > seconds) {
                seconds = time/1_000_000_000L;
                double fps = 1_000_000_000.0 / frameNsecs;
                float avg  = frameTiming.average(2);
                currentFPS = 1000.0 / avg;

                log("Frame (abs:%s, rel:%.2f) delta=%.4f time:%.3f fps:%.2f",
                    frame.number,
                    frame.relativeNumber,
                    frame.delta,
                    frameNsecs/1000000.0,
                    fps);
            }
        }
        log("----- Exiting main loop");
	}
    void showWindow(bool show=true) {
        if(show) glfwShowWindow(window);
        else glfwHideWindow(window);
	}
	float getFPS() const {
	    return currentFPS;
	}
	void setTargetFPS(uint fps) {
        targetFPS = fps;
        targetFrameTimeNsecs = 1_000_000_000/fps;
    }
	Tuple!(float,float) getMousePos() {
        double x,y;
        glfwGetCursorPos(window, &x, &y);
        return Tuple!(float,float)(cast(float)x, cast(float)y);
    }
    MouseState getMouseState() {
        auto state = mouseState;
        mouseState.wheel = 0;
        return state;
    }
    /// http://www.glfw.org/docs/3.0/group__keys.html
    bool isKeyPressed(uint key) {
        return glfwGetKey(window, key) == GLFW_PRESS;
    }
    bool isMouseButtonPressed(int button) {
        return glfwGetMouseButton(window, button) == GLFW_PRESS;
    }
    void setDesiredMaximumFPS(int fps) {
        this.maxFPS = 1_000_000_000/fps;
    }
    void setWindowTitle(string title) {
        wprops.title = title;
        glfwSetWindowTitle(window, title.toStringz);
    }
    void setWindowIcon(string pngfile) {
        auto png = PNG.read(pngfile);
        GLFWimage image = {
            width: png.width,
            height: png.height,
            pixels: png.data.ptr
        };
        glfwSetWindowIcon(window, 1, &image);
    }
    void setMouseCursorVisible(bool visible) {
        glfwSetInputMode(window, GLFW_CURSOR, visible? GLFW_CURSOR_NORMAL : GLFW_CURSOR_HIDDEN);
    }
    /**
     *  This will capture the mouse and make it hidden.
     *  The application will need to display its own cursor.
     */
    void captureMouse() {
        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    }
    /**
     *  This sort of works but it doesn't display on Vulkan screen.
     *  Not sure whether this works better on OpenGL??
     */
    void setCustomMouse(string pngfile, int xhotspot=0, int yhotspot=0) {
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
    VkCommandPool createCommandPool(uint queueFamily, VCommandPoolCreate flags) {
        with(VCommandPoolCreate) expect((flags & ~(RESET_COMMAND_BUFFER|TRANSIENT))==0);

        auto cp = device.createCommandPool(queueFamily, flags);
        commandPools ~= cp;
        return cp;
    }
    VkQueryPool createQueryPool(VQueryType type, uint count) {
        auto qp = device.createQueryPool(type, count);
        queryPools ~= qp;
        return qp;
    }
private:
    void renderFrame(FrameInfo frame) {
        /// Select the current frame resource.
        static ulong resourceIndex = 0;
        auto resource = perFrameResources[resourceIndex%perFrameResources.length];
        resourceIndex++;

        //logTime("Wait fence");
        /// Wait for the fence.
        device.waitFor(resource.fence);
        device.reset(resource.fence);
        //logTime("Fence signalled");

        /// Get the next available image view.
        uint index = swapchain.acquireNext(resource.imageAvailable, null);

        /// Let the app do its thing.
        app.render(frame, resource);

        /// Present.
        swapchain.queuePresent(
            getQueue(QueueManager.GRAPHICS),
            index,
            [resource.renderFinished] // wait semaphores
        );

        prevFrameIndex = index;
    }
    void createMemoryManager() {
        log("Creating memory manager");
        expect(vprops.deviceMemorySizeMB > 0 &&
               vprops.stagingMemorySizeMB > 0 &&
               vprops.sharedMemorySizeMB);

        memory = new VulkanMemoryManager(
            this,
            vprops.deviceMemorySizeMB.MB,
            vprops.stagingMemorySizeMB.MB,
            vprops.sharedMemorySizeMB.MB
        );
        if(vprops.vertexBufferSizeMB > 0) {
            memory.local.allocBuffer(
                "VertexBuffer",
                vprops.vertexBufferSizeMB.MB,
                VBufferUsage.VERTEX | VBufferUsage.TRANSFER_DST
            );
        }

        if(vprops.indexBufferSizeMB > 0) {
            memory.local.allocBuffer(
                "IndexBuffer",
                vprops.indexBufferSizeMB.MB,
                VBufferUsage.INDEX | VBufferUsage.TRANSFER_DST
            );
        }
        if(vprops.uniformBufferSizeMB > 0) {
            memory.local.allocBuffer(
                "UniformBuffer",
                vprops.uniformBufferSizeMB.MB,
                VBufferUsage.UNIFORM | VBufferUsage.TRANSFER_DST
            );
        }
        memory.staging.allocBuffer(
            "StagingBuffer",
            vprops.stagingMemorySizeMB.MB,
            VBufferUsage.TRANSFER_SRC | VBufferUsage.TRANSFER_DST
        );
    }
    /**
     *  Select a single graphics and transfer queue family for our use.
     *  If 'headless' is requested then we don't need a graphics queue family.
     */
    void createQueueManager() {
        log("Creating QueueManager and selecting queue families...");
        auto queueFamilyProps = physicalDevice.getQueueFamilies();

        this.queueManager = new QueueManager(physicalDevice, surface, queueFamilyProps);

        /** Find a grphics queue family if we are not in headless mode */
        QueueFamily graphics = QueueFamily.NONE;

        if(!wprops.headless) {
            graphics = queueManager.findFirstWith(VkQueueFlagBits.VK_QUEUE_GRAPHICS_BIT);
            if(graphics==QueueFamily.NONE) {
                throw new Error("No graphics queue family found");
            }
            queueManager.request(QueueManager.GRAPHICS, graphics, 1);
        } else {
            log("Headless mode requested: Not selecting a graphics queue family");
        }

        /** Try to find a dedicated transfer queue family */
        auto transfer = queueManager.findFirstWith(VkQueueFlagBits.VK_QUEUE_TRANSFER_BIT, [graphics]);
        if(transfer==QueueFamily.NONE) {
            transfer = queueManager.findFirstWith(VkQueueFlagBits.VK_QUEUE_TRANSFER_BIT);
        }
        if(transfer==QueueFamily.NONE) {
            throw new Error("No transfer queue family found");
        }
        queueManager.request(QueueManager.TRANSFER, transfer, 1);

        /** Try to find a dedicated compute queue family */
        auto allCompute = queueManager.findQueueFamilies(VkQueueFlagBits.VK_QUEUE_COMPUTE_BIT, VkQueueFlagBits.VK_QUEUE_GRAPHICS_BIT);
        if(allCompute.length==0) {
            /** No non-graphics compute queue families. Get a non-dedicated one */
            allCompute = queueManager.findQueueFamilies(VkQueueFlagBits.VK_QUEUE_COMPUTE_BIT, 0.as!VkQueueFlagBits);
        }
        if(allCompute.length==0) {
            throw new Error("No compute queue family found");
        }
        /** Use the first one */
        queueManager.request(QueueManager.COMPUTE, allCompute[0], 1);

        /// Let the app make adjustments and validate
        app.selectQueueFamilies(queueManager);
    }
    void createLogicalDevice() {
        log("Creating logical device...");

        log("   Creating queue infos:");
        VkDeviceQueueCreateInfo[] queueInfos;
        foreach(t; queueManager.getAllRequestedQueues()) {
            uint index = t[0];
            uint count = t[1];

            log("   Family index %s : %s queues", index, count);

            float[] priorities = new float[count];
            priorities[] = 1.0f;
            queueInfos ~= deviceQueueCreateInfo(index, priorities);
        }

        /** Create the logicla device */
        device = physicalDevice.createLogicalDevice(
            vprops.deviceExtensions,
            vprops.features,
            queueInfos
        );

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
        log("Creating command pools");
        if(!wprops.headless) {
            graphicsCP = createCommandPool(queueManager.getFamily(QueueManager.GRAPHICS).index,
                VCommandPoolCreate.RESET_COMMAND_BUFFER | VCommandPoolCreate.TRANSIENT);
            log("Vulkan: Created graphics command pool using queue family %s", queueManager.getFamily(QueueManager.GRAPHICS));
        }
        transferCP = createCommandPool(queueManager.getFamily(QueueManager.TRANSFER).index,
            VCommandPoolCreate.TRANSIENT);
        log("Vulkan: Created transfer command pool using queue family %s", queueManager.getFamily(QueueManager.TRANSFER));
    }
    void createPerFrameResources() {
        if(wprops.headless) return;
        log("Creating per frame resources");
        expect(swapchain.frameBuffers[0] !is null);
        foreach(i; 0..swapchain.numImages) {
            auto r = new PerFrameResource;
            r.index            = i;
            r.adhocCB          = device.allocFrom(graphicsCP);
            r.renderFinished   = device.createSemaphore();
            r.imageAvailable   = device.createSemaphore();
            r.fence            = device.createFence(true);
            r.image            = swapchain.images[i];
            r.imageView        = swapchain.views[i];
            r.frameBuffer      = swapchain.frameBuffers[i];
            perFrameResources ~= r;
        }
        log("Created %s per frame resources", perFrameResources.length);
    }
    void createWindow() {
        log("Creating window");
        GLFWmonitor* monitor = glfwGetPrimaryMonitor();
        auto vidmode = glfwGetVideoMode(monitor);
        if(!wprops.fullscreen) {
            monitor = null;
            if(wprops.width==0 || wprops.height==0) {
                wprops.width  = vidmode.width;
                wprops.height = vidmode.height;
            }
            glfwWindowHint(GLFW_VISIBLE, 0);
            glfwWindowHint(GLFW_RESIZABLE, wprops.resizable ? 1 : 0);
            glfwWindowHint(GLFW_DECORATED, wprops.decorated ? 1 : 0);
        } else {
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

        glfwSetKeyCallback(window, &onKeyEvent);
        glfwSetWindowFocusCallback(window, &onWindowFocusEvent);
        glfwSetMouseButtonCallback(window, &onMouseClickEvent);
        glfwSetScrollCallback(window, &onScrollEvent);
        glfwSetCursorPosCallback(window, &onMouseMoveEvent);
        glfwSetCursorEnterCallback(window, &onMouseEnterEvent);
        glfwSetWindowIconifyCallback(window, &onIconifyEvent);

        //glfwSetWindowRefreshCallback(window, &refreshWindow);
        //glfwSetWindowSizeCallback(window, &resizeWindow);
        //glfwSetWindowCloseCallback(window, &onWindowCloseEvent);
        //glfwSetDropCallback(window, &onDropEvent);

        //glfwSetInputMode(window, GLFW_STICKY_KEYS, 1);

        if(wprops.icon !is null) {
            setWindowIcon(wprops.icon);
        }
    }
    void createSurface() {
        log("Creating surface");
        check(glfwCreateWindowSurface(instance, window, null, &surface));
   }
    void createSwapChain() {
        if(wprops.headless) return;
        this.swapchain = new Swapchain(this);
        swapchain.create(surface);
        swapchain.createFrameBuffers(app.getRenderPass(device));
    }
}
extern(C) {
void errorCallback(int error, const(char)* description) nothrow {
    log("glfw error: %s %s", error, description);
}
void onKeyEvent(GLFWwindow* window, int key, int scancode, int action, int mods) nothrow {
	if(key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
		glfwSetWindowShouldClose(window, true);
		return;
	}
	//bool shiftClick = (mods & GLFW_MOD_SHIFT) != 0;
	//bool ctrlClick	= (mods & GLFW_MOD_CONTROL) != 0;
	//bool altClick	= (mods & GLFW_MOD_ALT ) != 0;

    try{
	    g_vulkan.app.keyPress(key, scancode, cast(KeyAction)action, mods);
	}catch(Throwable t) {}
}
void onWindowFocusEvent(GLFWwindow* window, int focussed) nothrow {
	//log("window focus changed to %s FOCUS", focussed?"GAINED":"LOST");
}
void onIconifyEvent(GLFWwindow* window, int iconified) nothrow {
	//log("window %s", iconified ? "iconified":"non iconified");
}
void onMouseClickEvent(GLFWwindow* window, int button, int action, int mods) nothrow {
	bool pressed = (action == 1);
	double x,y;
	glfwGetCursorPos(window, &x, &y);

	try{
	    g_vulkan.app.mouseButton(cast(MouseButton)button, cast(float)x, cast(float)y, pressed, mods);
    }catch(Throwable t) {}

    auto mouseState = &g_vulkan.mouseState;

	if(pressed) {
		mouseState.button = button;
	} else {
		mouseState.button = -1;
		if(mouseState.isDragging) {
			mouseState.isDragging = false;
			mouseState.dragEnd = Vector2(x,y);
		}
	}
}
void onMouseMoveEvent(GLFWwindow* window, double x, double y) nothrow {
	//log("mouse move %s %s", x, y);
	try{
        g_vulkan.app.mouseMoved(cast(float)x, cast(float)y);
	}catch(Throwable t) {}

    auto mouseState = &g_vulkan.mouseState;

	mouseState.pos = Vector2(x,y);
	if(!mouseState.isDragging && mouseState.button >= 0) {
		mouseState.isDragging = true;
		mouseState.dragStart = Vector2(x,y);
	}
}
void onScrollEvent(GLFWwindow* window, double xoffset, double yoffset) nothrow {
	//log("scroll event: %s %s", xoffset, yoffset);
	try{
        double x,y;
        glfwGetCursorPos(window, &x, &y);
        g_vulkan.app.mouseWheel(cast(float)xoffset, cast(float)yoffset, cast(float)x, cast(float)y);
        g_vulkan.mouseState.wheel += yoffset;
	}catch(Throwable t) {}
}
void onMouseEnterEvent(GLFWwindow* window, int enterred) nothrow {
	//log("mouse %s", enterred ? "enterred" : "exited");
}
}
