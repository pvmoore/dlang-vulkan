module vulkan.vulkan_app;

import vulkan.all;

struct WindowProperties {
	int width        = 400;
	int height       = 400;
	bool vsync       = false;
	bool fullscreen  = false;
	bool decorated   = true;
	bool resizable   = false;
	bool autoIconify = true;
	bool showWindow  = true;
	string title	 = "Vulkan";
	string icon      = null;
	bool headless    = false;
	int frameBuffers = 3;
    bool titleBarFps = false;   // display FPS in the title bar
}
struct VulkanProperties {
    uint apiVersion               = vulkanVersion(1,0,0);
    string appName                = "Vulkan Library";

    string[] shaderSrcDirectories = ["shaders/"];
    string shaderDestDirectory    = "resources/shaders/";
    string shaderSpirvVersion     = "1.0"; 
    string glslShaderCompiler     = "glslangValidator";
    string slangShaderCompiler    = "C:/work/VulkanSDK/1.4.304.1/Bin/slangc";

    /** 
     * Set spv files to be recompiled if they are older than this number of minutes regardless
     * of whether or not the source file has been modified. 
     * Default is 24 hours.
     */
    uint shaderSpirvShelfLifeMinutes = 24*60;

    /** 
     *  Set this to true if you want to enable 'debugPrintfEXT' inside shaders.
     *  If this is set to true and we are in debug mode then shader printf will be enabled.
     */
    bool enableShaderPrintf = false;

    /** 
     *  Set this to true if you want to use dynamic rendering.
     *  Note that this requires either Vulkan 1.3 or VK_KHR_dynamic_rendering to be enabled.
     *  If this flag is set to true then no VkRenderPass or VkFrameBuffers will be created. 
     */
    bool useDynamicRendering = false;

    /** Set this if you want to do anything fancy with the swapchain images */
    VkImageUsageFlags swapchainUsage = VK_IMAGE_USAGE_NONE;

    /**
     *  Set this if you want a swapchain with depth/stencil.
     *  Example formats: D32_SFLOAT (32 bits depth only)
     *                   D32_SFLOAT_S8_UINT (32 bits depth, 8 bits stencil)
     */
    VkFormat depthStencilFormat         = VK_FORMAT_UNDEFINED;
    VkImageUsageFlags depthStencilUsage = VK_IMAGE_USAGE_NONE;

    /**
     * Set the device features you will be querying/updating in the selectFeatures(...) callback.
     * API version 1.1 and later
     */
    DeviceFeatures.Features features;

    /** Add any required device extensions */
    immutable(char)*[] deviceExtensions = [
        "VK_KHR_swapchain".ptr,
        "VK_KHR_maintenance1".ptr
    ];

    /** Set any extra layers you need here */
    immutable(char)*[] layers;

    /** Set ImGui options here */
    ImguiOptions imgui;

    /** Convenience functions */
    bool isV10() { return isApiVersion(1, 0); }
    bool isV11() { return isApiVersion(1, 1); }
    bool isV12() { return isApiVersion(1, 2); }
    bool isV13() { return isApiVersion(1, 3); }
    bool isV14() { return isApiVersion(1, 4); }
    bool isV13orHigher() { return apiMajorVersion() >=1 || (apiMajorVersion() == 1 && apiMinorVersion() >= 3); }
    bool isApiVersion(uint major, int minor) { return apiMajorVersion() == major && apiMinorVersion() == minor; }
    uint apiMajorVersion() { return apiVersion >>> 22; }
    uint apiMinorVersion() { return (apiVersion >>> 12) & 0x3ff; }

    void addDeviceExtension(string name) {
        deviceExtensions ~= toStringz(name);
    }
}

VkPhysicalDeviceFeatures getStandardFeatures() {
    VkPhysicalDeviceFeatures f = {
        geometryShader: VK_TRUE,
        textureCompressionBC: VK_TRUE
    };
    return f;
}

struct ImguiOptions {
    bool enabled = false;
    uint configFlags;           // eg. ImGuiConfigFlags_DockingEnable
    string[] fontPaths;         // full path of TTF
    float[] fontSizes;
}

struct MouseState {
	float2 pos;
	int button = -1;
	float wheel = 0;
	vec2 dragStart;
	vec2 dragEnd;
	bool isDragging;

	string toString() {
		return "pos:%s button:%s wheel:%s dragging:%s dragStart:%s dragEnd:%s"
			.format(pos, button, wheel, isDragging, dragStart, dragEnd);
	}
}

/** Subclass this to add more fields */
final class PerFrameResource {
    uint index;
    /// Current swapchain image
    VkImage image;
    /// Current swapchain image view
    VkImageView imageView;
    /// Current framebuffer
    VkFramebuffer frameBuffer;
    /// Use this for adhoc commands per frame on the graphics queue
    VkCommandBuffer adhocCB;
    /// Synchronisation
    VkSemaphore imageAvailable;
    VkSemaphore renderFinished;
    VkFence fence;
}
struct Frame {
    /** The number of times <render> has been called. */
    FrameNumber number;
    /**
     * Elapsed number of seconds
     */
    double seconds;
    /**
     * 1.0 / frames per second.
     * Multiply by this to keep calculations relative to frame speed.
     */
    double perSecond;

    /**
     *  The frame buffer resources for the current frame
     */
    PerFrameResource resource;
}
enum KeyMod : uint {
    NONE    = 0,
    SHIFT   = GLFW_MOD_SHIFT,
    CTRL    = GLFW_MOD_CONTROL,
    ALT     = GLFW_MOD_ALT,
    SUPER   = GLFW_MOD_SUPER
}
enum KeyAction : uint {
    PRESS   = GLFW_PRESS,
    RELEASE = GLFW_RELEASE,
    REPEAT  = GLFW_REPEAT
}

final class Font {
    string name;
    SDFFont sdf;
    DeviceImage image;
}

abstract class VulkanApplication : IVulkanApplication {
    void destroy() {}
    void deviceReady(VkDevice device, PerFrameResource[] frameResources) {}
    void selectQueueFamilies(QueueManager queueManager) {}
    void selectFeatures(DeviceFeatures features) {}
    VkRenderPass getRenderPass(VkDevice device) { return null; }
    void run() {}
    void render(Frame frame) {} 
}

interface IVulkanApplication {

    void destroy();
    /**
     *  Called by Vulkan when everything is ready to use.
     *  The app can now cache the device and
     *  init any application objects.
     */
    void deviceReady(VkDevice device, PerFrameResource[] frameResources);

    /**
     *  Use this to adjust the queue families if you need to. Also,
     *  validate that the device has the queues you need.
     */
    void selectQueueFamilies(QueueManager queueManager);

    /**
     *  Enable and disable the features you require.
     */
    void selectFeatures(DeviceFeatures features);

    /**
     *  This will be called before the device is fully ready in order
     *  for Vulkan to create the frame buffers.
     */
    VkRenderPass getRenderPass(VkDevice device);

    void run();
    void render(Frame frame);
}
