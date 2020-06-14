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
}
struct VulkanProperties {
    uint minApiVersion         = vulkanVersion(1,0,3);
    string appName             = "Vulkan Library";
    string shaderDirectory     = "/pvmoore/_assets/shaders/vulkan/";

    /** Set this if you want to do anything fancy with the swapchain images */
    VImageUsage swapchainUsage = VImageUsage.NONE;

    /**
     *  Set this if you want a swapchain with depth/stencil.
     *  Example formats: D32_SFLOAT (32 bits depth only)
     *                   D32_SFLOAT_S8_UINT (32 bits depth, 8 bits stencil)
     */
    VFormat depthStencilFormat    = VFormat.UNDEFINED;
    VImageUsage depthStencilUsage = VImageUsage.NONE;

    /** Set any specific features you need to use
        eg. anisotropy or geometry shader */
    VkPhysicalDeviceFeatures features = getStandardFeatures();

    /** Add any required device extensions */
    char*[] deviceExtensions = [
        cast(char*)VK_KHR_SWAPCHAIN_EXTENSION_NAME,
        cast(char*)"VK_KHR_maintenance1".ptr
    ];

    /** Set any extra layers you need here */
    immutable(char)*[] layers;
}

VkPhysicalDeviceFeatures getStandardFeatures() {
    VkPhysicalDeviceFeatures f = {
        geometryShader: VK_TRUE,
        textureCompressionBC: VK_TRUE
    };
    return f;
}

struct MouseState {
	vec2 pos;
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
struct FrameInfo {
    /** The number of times <render> has been called. */
    ulong number;
    /**
     * Elapsed number of seconds
     */
    double seconds;
    /**
     * 1.0 / frames per second.
     * Multiply by this to keep calculations relative to frame speed.
     */
    double perSecond;
}
enum MouseButton : uint { LEFT=0, MIDDLE, RIGHT }
enum KeyMod : uint { NONE=0, SHIFT=GLFW_MOD_SHIFT, CTRL=GLFW_MOD_CONTROL, ALT=GLFW_MOD_ALT, SUPER=GLFW_MOD_SUPER }
enum KeyAction : uint { PRESS=GLFW_PRESS, RELEASE=GLFW_RELEASE, REPEAT=GLFW_REPEAT }

final class Font {
    string name;
    SDFFont sdf;
    DeviceImage image;
}

abstract class VulkanApplication {

    void destroy() {

    }
    /**
     *  Called by Vulkan when everything is ready to use.
     *  The app can now cache the device and
     *  init any application objects.
     */
    void deviceReady(VkDevice device, PerFrameResource[] frameResources) {

    }
    /**
     *  Use this to adjust the queue families if you need to. Also,
     *  validate that the device has the queues you need.
     */
    void selectQueueFamilies(QueueManager queueManager) {

    }
    /**
     *  This will be called before the device is fully ready in order
     *  for Vulkan to create the frame buffers.
     */
    VkRenderPass getRenderPass(VkDevice device) { return null; }

    void run() {

    }

    void render(FrameInfo frame, PerFrameResource res) {

    }
    /// Events
    void keyPress(uint keyCode, uint scanCode, KeyAction action, uint mods) {

    }
    void mouseButton(MouseButton button, float x, float y, bool down, uint mods) {

    }
    void mouseMoved(float x, float y) {

    }
    void mouseWheel(float xdelta, float ydelta, float x, float y) {

    }
}
