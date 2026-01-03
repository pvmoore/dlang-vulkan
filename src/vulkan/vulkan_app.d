module vulkan.vulkan_app;

import vulkan.all;

struct WindowProperties {
	int width                  = 400;
	int height                 = 400;
	bool vsync                 = false;
	bool fullscreen            = false;
	bool decorated             = true;
	bool resizable             = false;
	bool autoIconify           = true;
	bool showWindow            = true;
	string title	           = "Vulkan";
	string icon                = null;
	bool headless              = false;
	int frameBuffers           = 3;
    bool titleBarFps           = false;   // display FPS in the title bar
    bool escapeKeyClosesWindow = true;    // disable this to allow more useful exit functionality
}
struct VulkanProperties {
    uint apiVersion               = VK_API_VERSION_1_1;
    string appName                = "Vulkan Library";

    // Shader properties

    string[] shaderSrcDirectories = ["shaders/"];
    string shaderDestDirectory    = "resources/shaders/";
    string shaderSpirvVersion     = "1.3"; 
    string glslShaderCompiler;      // Will default to %VULKAN_SDK%/Bin/glslangValidator
    string slangShaderCompiler;     // Will default to %VULKAN_SDK%/Bin/slangc

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
     * Set this to true if you want to enable GPU validation.
     */
    bool enableGpuValidation = false;

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

    /** Set any extra layers you need here */
    immutable(char)*[] layers;

    /** Set ImGui options here */
    ImguiOptions imgui;

    /** Set logging options here */
    LoggingOptions logging;

    /** Convenience functions */
    bool isV10() { return isApiVersion(1, 0); }
    bool isV11() { return isApiVersion(1, 1); }
    bool isV12() { return isApiVersion(1, 2); }
    bool isV13() { return isApiVersion(1, 3); }
    bool isV14() { return isApiVersion(1, 4); }
    bool isV11orHigher() { return apiMajorVersion() >=1 || (apiMajorVersion() == 1 && apiMinorVersion() >= 1); }
    bool isV13orHigher() { return apiMajorVersion() >=1 || (apiMajorVersion() == 1 && apiMinorVersion() >= 3); }
    bool isApiVersion(uint major, int minor) { return apiMajorVersion() == major && apiMinorVersion() == minor; }
    uint apiMajorVersion() { return apiVersion >>> 22; }
    uint apiMinorVersion() { return (apiVersion >>> 12) & 0x3ff; }

    string getSlangShaderCompilerLocation() {
        if(slangShaderCompiler is null) {
            slangShaderCompiler = getVulkanSDKBinDirectory() ~ "/slangc";
        }
        return slangShaderCompiler;
    }
    string getGlslShaderCompilerLocation() {
        if(glslShaderCompiler is null) {
            glslShaderCompiler = getVulkanSDKBinDirectory() ~ "/glslangValidator";
        }
        return glslShaderCompiler;
    }
}

struct ImguiOptions {
    bool enabled = false;
    uint configFlags;           // eg. ImGuiConfigFlags_DockingEnable
    string[] fontPaths;         // full path of TTF
    float[] fontSizes;
}

struct LoggingOptions {
    bool enabled = true;
    bool verbose = true;

    /** Enable filtering of log messages */
    bool filter = false;
    bool filterCaseSensitive = true;
    /** List of exclusion filters */
    string[] filters;
    string logFilename = ".logs/vulkan.log";
}

/** Subclass this to add more fields */
final class PerFrameResource {
    // The index of this frame resource (0..swapchain.numImages-1)
    uint index;
    
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
     * The swapchain image render target for this frame
     */
    uint imageIndex;
    VkImage image;
    VkImageView imageView;
    VkFramebuffer frameBuffer;

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
    SUPER   = GLFW_MOD_SUPER,
    CAPS    = GLFW_MOD_CAPS_LOCK,
    NUM     = GLFW_MOD_NUM_LOCK
}
enum KeyAction : uint {
    RELEASE = GLFW_RELEASE,
    PRESS   = GLFW_PRESS,
    REPEAT  = GLFW_REPEAT
}

final class Font {
    string name;
    SDFFont sdf;
    DeviceImage image;
}

abstract class VulkanApplication : IVulkanApplication {
    void destroy() {}
    void deviceReady(VkDevice device) {}
    void selectQueueFamilies(QueueManager queueManager) {}
    void selectFeaturesAndExtensions(FeaturesAndExtensions fae) {}
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
    void deviceReady(VkDevice device);

    /**
     *  Use this to adjust the queue families if you need to. Also,
     *  validate that the device has the queues you need.
     */
    void selectQueueFamilies(QueueManager queueManager);

    /**
     *  Enable the device features and extenstion required by the app.
     */
    void selectFeaturesAndExtensions(FeaturesAndExtensions fae);

    /**
     *  This will be called before the device is fully ready in order
     *  for Vulkan to create the frame buffers.
     */
    VkRenderPass getRenderPass(VkDevice device);

    void run();
    void render(Frame frame);
}
