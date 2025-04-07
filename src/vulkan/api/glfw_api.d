module vulkan.api.glfw_api;

private:

import vulkan.api.vulkan_api;
import core.sys.windows.windows : HWND;

public:

// GLFW 3.4 Include files converted to D (This is a generated file)
// 
// Usage:
//   ** Start program
//   GLFWLoader.load();
//   ** 
//   GLFWLoader.unload();
//   ** Exit program

// GLFWLoader
private struct _GLFWLoader {
	import core.sys.windows.windows;
	import common.utils : throwIf;
	HANDLE handle;
	void load() {
		this.handle = LoadLibraryA("glfw3.4.dll");
		if(!handle) throw new Exception("Unable to load 'glfw3.4.dll'");
		
		*(cast(void**)&glfwCreateCursor) = GetProcAddress(handle, "glfwCreateCursor"); throwIf(!glfwCreateCursor);
		*(cast(void**)&glfwCreateStandardCursor) = GetProcAddress(handle, "glfwCreateStandardCursor"); throwIf(!glfwCreateStandardCursor);
		*(cast(void**)&glfwCreateWindow) = GetProcAddress(handle, "glfwCreateWindow"); throwIf(!glfwCreateWindow);
		*(cast(void**)&glfwCreateWindowSurface) = GetProcAddress(handle, "glfwCreateWindowSurface"); throwIf(!glfwCreateWindowSurface);
		*(cast(void**)&glfwDefaultWindowHints) = GetProcAddress(handle, "glfwDefaultWindowHints"); throwIf(!glfwDefaultWindowHints);
		*(cast(void**)&glfwDestroyCursor) = GetProcAddress(handle, "glfwDestroyCursor"); throwIf(!glfwDestroyCursor);
		*(cast(void**)&glfwDestroyWindow) = GetProcAddress(handle, "glfwDestroyWindow"); throwIf(!glfwDestroyWindow);
		*(cast(void**)&glfwExtensionSupported) = GetProcAddress(handle, "glfwExtensionSupported"); throwIf(!glfwExtensionSupported);
		*(cast(void**)&glfwFocusWindow) = GetProcAddress(handle, "glfwFocusWindow"); throwIf(!glfwFocusWindow);
		*(cast(void**)&glfwGetClipboardString) = GetProcAddress(handle, "glfwGetClipboardString"); throwIf(!glfwGetClipboardString);
		*(cast(void**)&glfwGetCurrentContext) = GetProcAddress(handle, "glfwGetCurrentContext"); throwIf(!glfwGetCurrentContext);
		*(cast(void**)&glfwGetCursorPos) = GetProcAddress(handle, "glfwGetCursorPos"); throwIf(!glfwGetCursorPos);
		*(cast(void**)&glfwGetError) = GetProcAddress(handle, "glfwGetError"); throwIf(!glfwGetError);
		*(cast(void**)&glfwGetFramebufferSize) = GetProcAddress(handle, "glfwGetFramebufferSize"); throwIf(!glfwGetFramebufferSize);
		*(cast(void**)&glfwGetGamepadName) = GetProcAddress(handle, "glfwGetGamepadName"); throwIf(!glfwGetGamepadName);
		*(cast(void**)&glfwGetGamepadState) = GetProcAddress(handle, "glfwGetGamepadState"); throwIf(!glfwGetGamepadState);
		*(cast(void**)&glfwGetGammaRamp) = GetProcAddress(handle, "glfwGetGammaRamp"); throwIf(!glfwGetGammaRamp);
		*(cast(void**)&glfwGetInputMode) = GetProcAddress(handle, "glfwGetInputMode"); throwIf(!glfwGetInputMode);
		*(cast(void**)&glfwGetInstanceProcAddress) = GetProcAddress(handle, "glfwGetInstanceProcAddress"); throwIf(!glfwGetInstanceProcAddress);
		*(cast(void**)&glfwGetJoystickAxes) = GetProcAddress(handle, "glfwGetJoystickAxes"); throwIf(!glfwGetJoystickAxes);
		*(cast(void**)&glfwGetJoystickButtons) = GetProcAddress(handle, "glfwGetJoystickButtons"); throwIf(!glfwGetJoystickButtons);
		*(cast(void**)&glfwGetJoystickGUID) = GetProcAddress(handle, "glfwGetJoystickGUID"); throwIf(!glfwGetJoystickGUID);
		*(cast(void**)&glfwGetJoystickHats) = GetProcAddress(handle, "glfwGetJoystickHats"); throwIf(!glfwGetJoystickHats);
		*(cast(void**)&glfwGetJoystickName) = GetProcAddress(handle, "glfwGetJoystickName"); throwIf(!glfwGetJoystickName);
		*(cast(void**)&glfwGetJoystickUserPointer) = GetProcAddress(handle, "glfwGetJoystickUserPointer"); throwIf(!glfwGetJoystickUserPointer);
		*(cast(void**)&glfwGetKey) = GetProcAddress(handle, "glfwGetKey"); throwIf(!glfwGetKey);
		*(cast(void**)&glfwGetKeyName) = GetProcAddress(handle, "glfwGetKeyName"); throwIf(!glfwGetKeyName);
		*(cast(void**)&glfwGetKeyScancode) = GetProcAddress(handle, "glfwGetKeyScancode"); throwIf(!glfwGetKeyScancode);
		*(cast(void**)&glfwGetMonitorContentScale) = GetProcAddress(handle, "glfwGetMonitorContentScale"); throwIf(!glfwGetMonitorContentScale);
		*(cast(void**)&glfwGetMonitorName) = GetProcAddress(handle, "glfwGetMonitorName"); throwIf(!glfwGetMonitorName);
		*(cast(void**)&glfwGetMonitorPhysicalSize) = GetProcAddress(handle, "glfwGetMonitorPhysicalSize"); throwIf(!glfwGetMonitorPhysicalSize);
		*(cast(void**)&glfwGetMonitorPos) = GetProcAddress(handle, "glfwGetMonitorPos"); throwIf(!glfwGetMonitorPos);
		*(cast(void**)&glfwGetMonitorUserPointer) = GetProcAddress(handle, "glfwGetMonitorUserPointer"); throwIf(!glfwGetMonitorUserPointer);
		*(cast(void**)&glfwGetMonitorWorkarea) = GetProcAddress(handle, "glfwGetMonitorWorkarea"); throwIf(!glfwGetMonitorWorkarea);
		*(cast(void**)&glfwGetMonitors) = GetProcAddress(handle, "glfwGetMonitors"); throwIf(!glfwGetMonitors);
		*(cast(void**)&glfwGetMouseButton) = GetProcAddress(handle, "glfwGetMouseButton"); throwIf(!glfwGetMouseButton);
		*(cast(void**)&glfwGetPhysicalDevicePresentationSupport) = GetProcAddress(handle, "glfwGetPhysicalDevicePresentationSupport"); throwIf(!glfwGetPhysicalDevicePresentationSupport);
		*(cast(void**)&glfwGetPlatform) = GetProcAddress(handle, "glfwGetPlatform"); throwIf(!glfwGetPlatform);
		*(cast(void**)&glfwGetPrimaryMonitor) = GetProcAddress(handle, "glfwGetPrimaryMonitor"); throwIf(!glfwGetPrimaryMonitor);
		*(cast(void**)&glfwGetProcAddress) = GetProcAddress(handle, "glfwGetProcAddress"); throwIf(!glfwGetProcAddress);
		*(cast(void**)&glfwGetRequiredInstanceExtensions) = GetProcAddress(handle, "glfwGetRequiredInstanceExtensions"); throwIf(!glfwGetRequiredInstanceExtensions);
		*(cast(void**)&glfwGetTime) = GetProcAddress(handle, "glfwGetTime"); throwIf(!glfwGetTime);
		*(cast(void**)&glfwGetTimerFrequency) = GetProcAddress(handle, "glfwGetTimerFrequency"); throwIf(!glfwGetTimerFrequency);
		*(cast(void**)&glfwGetTimerValue) = GetProcAddress(handle, "glfwGetTimerValue"); throwIf(!glfwGetTimerValue);
		*(cast(void**)&glfwGetVersion) = GetProcAddress(handle, "glfwGetVersion"); throwIf(!glfwGetVersion);
		*(cast(void**)&glfwGetVersionString) = GetProcAddress(handle, "glfwGetVersionString"); throwIf(!glfwGetVersionString);
		*(cast(void**)&glfwGetVideoMode) = GetProcAddress(handle, "glfwGetVideoMode"); throwIf(!glfwGetVideoMode);
		*(cast(void**)&glfwGetVideoModes) = GetProcAddress(handle, "glfwGetVideoModes"); throwIf(!glfwGetVideoModes);
		*(cast(void**)&glfwGetWin32Adapter) = GetProcAddress(handle, "glfwGetWin32Adapter"); throwIf(!glfwGetWin32Adapter);
		*(cast(void**)&glfwGetWin32Monitor) = GetProcAddress(handle, "glfwGetWin32Monitor"); throwIf(!glfwGetWin32Monitor);
		*(cast(void**)&glfwGetWin32Window) = GetProcAddress(handle, "glfwGetWin32Window"); throwIf(!glfwGetWin32Window);
		*(cast(void**)&glfwGetWindowAttrib) = GetProcAddress(handle, "glfwGetWindowAttrib"); throwIf(!glfwGetWindowAttrib);
		*(cast(void**)&glfwGetWindowContentScale) = GetProcAddress(handle, "glfwGetWindowContentScale"); throwIf(!glfwGetWindowContentScale);
		*(cast(void**)&glfwGetWindowFrameSize) = GetProcAddress(handle, "glfwGetWindowFrameSize"); throwIf(!glfwGetWindowFrameSize);
		*(cast(void**)&glfwGetWindowMonitor) = GetProcAddress(handle, "glfwGetWindowMonitor"); throwIf(!glfwGetWindowMonitor);
		*(cast(void**)&glfwGetWindowOpacity) = GetProcAddress(handle, "glfwGetWindowOpacity"); throwIf(!glfwGetWindowOpacity);
		*(cast(void**)&glfwGetWindowPos) = GetProcAddress(handle, "glfwGetWindowPos"); throwIf(!glfwGetWindowPos);
		*(cast(void**)&glfwGetWindowSize) = GetProcAddress(handle, "glfwGetWindowSize"); throwIf(!glfwGetWindowSize);
		*(cast(void**)&glfwGetWindowTitle) = GetProcAddress(handle, "glfwGetWindowTitle"); throwIf(!glfwGetWindowTitle);
		*(cast(void**)&glfwGetWindowUserPointer) = GetProcAddress(handle, "glfwGetWindowUserPointer"); throwIf(!glfwGetWindowUserPointer);
		*(cast(void**)&glfwHideWindow) = GetProcAddress(handle, "glfwHideWindow"); throwIf(!glfwHideWindow);
		*(cast(void**)&glfwIconifyWindow) = GetProcAddress(handle, "glfwIconifyWindow"); throwIf(!glfwIconifyWindow);
		*(cast(void**)&glfwInit) = GetProcAddress(handle, "glfwInit"); throwIf(!glfwInit);
		*(cast(void**)&glfwInitAllocator) = GetProcAddress(handle, "glfwInitAllocator"); throwIf(!glfwInitAllocator);
		*(cast(void**)&glfwInitHint) = GetProcAddress(handle, "glfwInitHint"); throwIf(!glfwInitHint);
		*(cast(void**)&glfwInitVulkanLoader) = GetProcAddress(handle, "glfwInitVulkanLoader"); throwIf(!glfwInitVulkanLoader);
		*(cast(void**)&glfwJoystickIsGamepad) = GetProcAddress(handle, "glfwJoystickIsGamepad"); throwIf(!glfwJoystickIsGamepad);
		*(cast(void**)&glfwJoystickPresent) = GetProcAddress(handle, "glfwJoystickPresent"); throwIf(!glfwJoystickPresent);
		*(cast(void**)&glfwMakeContextCurrent) = GetProcAddress(handle, "glfwMakeContextCurrent"); throwIf(!glfwMakeContextCurrent);
		*(cast(void**)&glfwMaximizeWindow) = GetProcAddress(handle, "glfwMaximizeWindow"); throwIf(!glfwMaximizeWindow);
		*(cast(void**)&glfwPlatformSupported) = GetProcAddress(handle, "glfwPlatformSupported"); throwIf(!glfwPlatformSupported);
		*(cast(void**)&glfwPollEvents) = GetProcAddress(handle, "glfwPollEvents"); throwIf(!glfwPollEvents);
		*(cast(void**)&glfwPostEmptyEvent) = GetProcAddress(handle, "glfwPostEmptyEvent"); throwIf(!glfwPostEmptyEvent);
		*(cast(void**)&glfwRawMouseMotionSupported) = GetProcAddress(handle, "glfwRawMouseMotionSupported"); throwIf(!glfwRawMouseMotionSupported);
		*(cast(void**)&glfwRequestWindowAttention) = GetProcAddress(handle, "glfwRequestWindowAttention"); throwIf(!glfwRequestWindowAttention);
		*(cast(void**)&glfwRestoreWindow) = GetProcAddress(handle, "glfwRestoreWindow"); throwIf(!glfwRestoreWindow);
		*(cast(void**)&glfwSetCharCallback) = GetProcAddress(handle, "glfwSetCharCallback"); throwIf(!glfwSetCharCallback);
		*(cast(void**)&glfwSetCharModsCallback) = GetProcAddress(handle, "glfwSetCharModsCallback"); throwIf(!glfwSetCharModsCallback);
		*(cast(void**)&glfwSetClipboardString) = GetProcAddress(handle, "glfwSetClipboardString"); throwIf(!glfwSetClipboardString);
		*(cast(void**)&glfwSetCursor) = GetProcAddress(handle, "glfwSetCursor"); throwIf(!glfwSetCursor);
		*(cast(void**)&glfwSetCursorEnterCallback) = GetProcAddress(handle, "glfwSetCursorEnterCallback"); throwIf(!glfwSetCursorEnterCallback);
		*(cast(void**)&glfwSetCursorPos) = GetProcAddress(handle, "glfwSetCursorPos"); throwIf(!glfwSetCursorPos);
		*(cast(void**)&glfwSetCursorPosCallback) = GetProcAddress(handle, "glfwSetCursorPosCallback"); throwIf(!glfwSetCursorPosCallback);
		*(cast(void**)&glfwSetDropCallback) = GetProcAddress(handle, "glfwSetDropCallback"); throwIf(!glfwSetDropCallback);
		*(cast(void**)&glfwSetErrorCallback) = GetProcAddress(handle, "glfwSetErrorCallback"); throwIf(!glfwSetErrorCallback);
		*(cast(void**)&glfwSetFramebufferSizeCallback) = GetProcAddress(handle, "glfwSetFramebufferSizeCallback"); throwIf(!glfwSetFramebufferSizeCallback);
		*(cast(void**)&glfwSetGamma) = GetProcAddress(handle, "glfwSetGamma"); throwIf(!glfwSetGamma);
		*(cast(void**)&glfwSetGammaRamp) = GetProcAddress(handle, "glfwSetGammaRamp"); throwIf(!glfwSetGammaRamp);
		*(cast(void**)&glfwSetInputMode) = GetProcAddress(handle, "glfwSetInputMode"); throwIf(!glfwSetInputMode);
		*(cast(void**)&glfwSetJoystickCallback) = GetProcAddress(handle, "glfwSetJoystickCallback"); throwIf(!glfwSetJoystickCallback);
		*(cast(void**)&glfwSetJoystickUserPointer) = GetProcAddress(handle, "glfwSetJoystickUserPointer"); throwIf(!glfwSetJoystickUserPointer);
		*(cast(void**)&glfwSetKeyCallback) = GetProcAddress(handle, "glfwSetKeyCallback"); throwIf(!glfwSetKeyCallback);
		*(cast(void**)&glfwSetMonitorCallback) = GetProcAddress(handle, "glfwSetMonitorCallback"); throwIf(!glfwSetMonitorCallback);
		*(cast(void**)&glfwSetMonitorUserPointer) = GetProcAddress(handle, "glfwSetMonitorUserPointer"); throwIf(!glfwSetMonitorUserPointer);
		*(cast(void**)&glfwSetMouseButtonCallback) = GetProcAddress(handle, "glfwSetMouseButtonCallback"); throwIf(!glfwSetMouseButtonCallback);
		*(cast(void**)&glfwSetScrollCallback) = GetProcAddress(handle, "glfwSetScrollCallback"); throwIf(!glfwSetScrollCallback);
		*(cast(void**)&glfwSetTime) = GetProcAddress(handle, "glfwSetTime"); throwIf(!glfwSetTime);
		*(cast(void**)&glfwSetWindowAspectRatio) = GetProcAddress(handle, "glfwSetWindowAspectRatio"); throwIf(!glfwSetWindowAspectRatio);
		*(cast(void**)&glfwSetWindowAttrib) = GetProcAddress(handle, "glfwSetWindowAttrib"); throwIf(!glfwSetWindowAttrib);
		*(cast(void**)&glfwSetWindowCloseCallback) = GetProcAddress(handle, "glfwSetWindowCloseCallback"); throwIf(!glfwSetWindowCloseCallback);
		*(cast(void**)&glfwSetWindowContentScaleCallback) = GetProcAddress(handle, "glfwSetWindowContentScaleCallback"); throwIf(!glfwSetWindowContentScaleCallback);
		*(cast(void**)&glfwSetWindowFocusCallback) = GetProcAddress(handle, "glfwSetWindowFocusCallback"); throwIf(!glfwSetWindowFocusCallback);
		*(cast(void**)&glfwSetWindowIcon) = GetProcAddress(handle, "glfwSetWindowIcon"); throwIf(!glfwSetWindowIcon);
		*(cast(void**)&glfwSetWindowIconifyCallback) = GetProcAddress(handle, "glfwSetWindowIconifyCallback"); throwIf(!glfwSetWindowIconifyCallback);
		*(cast(void**)&glfwSetWindowMaximizeCallback) = GetProcAddress(handle, "glfwSetWindowMaximizeCallback"); throwIf(!glfwSetWindowMaximizeCallback);
		*(cast(void**)&glfwSetWindowMonitor) = GetProcAddress(handle, "glfwSetWindowMonitor"); throwIf(!glfwSetWindowMonitor);
		*(cast(void**)&glfwSetWindowOpacity) = GetProcAddress(handle, "glfwSetWindowOpacity"); throwIf(!glfwSetWindowOpacity);
		*(cast(void**)&glfwSetWindowPos) = GetProcAddress(handle, "glfwSetWindowPos"); throwIf(!glfwSetWindowPos);
		*(cast(void**)&glfwSetWindowPosCallback) = GetProcAddress(handle, "glfwSetWindowPosCallback"); throwIf(!glfwSetWindowPosCallback);
		*(cast(void**)&glfwSetWindowRefreshCallback) = GetProcAddress(handle, "glfwSetWindowRefreshCallback"); throwIf(!glfwSetWindowRefreshCallback);
		*(cast(void**)&glfwSetWindowShouldClose) = GetProcAddress(handle, "glfwSetWindowShouldClose"); throwIf(!glfwSetWindowShouldClose);
		*(cast(void**)&glfwSetWindowSize) = GetProcAddress(handle, "glfwSetWindowSize"); throwIf(!glfwSetWindowSize);
		*(cast(void**)&glfwSetWindowSizeCallback) = GetProcAddress(handle, "glfwSetWindowSizeCallback"); throwIf(!glfwSetWindowSizeCallback);
		*(cast(void**)&glfwSetWindowSizeLimits) = GetProcAddress(handle, "glfwSetWindowSizeLimits"); throwIf(!glfwSetWindowSizeLimits);
		*(cast(void**)&glfwSetWindowTitle) = GetProcAddress(handle, "glfwSetWindowTitle"); throwIf(!glfwSetWindowTitle);
		*(cast(void**)&glfwSetWindowUserPointer) = GetProcAddress(handle, "glfwSetWindowUserPointer"); throwIf(!glfwSetWindowUserPointer);
		*(cast(void**)&glfwShowWindow) = GetProcAddress(handle, "glfwShowWindow"); throwIf(!glfwShowWindow);
		*(cast(void**)&glfwSwapBuffers) = GetProcAddress(handle, "glfwSwapBuffers"); throwIf(!glfwSwapBuffers);
		*(cast(void**)&glfwSwapInterval) = GetProcAddress(handle, "glfwSwapInterval"); throwIf(!glfwSwapInterval);
		*(cast(void**)&glfwTerminate) = GetProcAddress(handle, "glfwTerminate"); throwIf(!glfwTerminate);
		*(cast(void**)&glfwUpdateGamepadMappings) = GetProcAddress(handle, "glfwUpdateGamepadMappings"); throwIf(!glfwUpdateGamepadMappings);
		*(cast(void**)&glfwVulkanSupported) = GetProcAddress(handle, "glfwVulkanSupported"); throwIf(!glfwVulkanSupported);
		*(cast(void**)&glfwWaitEvents) = GetProcAddress(handle, "glfwWaitEvents"); throwIf(!glfwWaitEvents);
		*(cast(void**)&glfwWaitEventsTimeout) = GetProcAddress(handle, "glfwWaitEventsTimeout"); throwIf(!glfwWaitEventsTimeout);
		*(cast(void**)&glfwWindowHint) = GetProcAddress(handle, "glfwWindowHint"); throwIf(!glfwWindowHint);
		*(cast(void**)&glfwWindowHintString) = GetProcAddress(handle, "glfwWindowHintString"); throwIf(!glfwWindowHintString);
		*(cast(void**)&glfwWindowShouldClose) = GetProcAddress(handle, "glfwWindowShouldClose"); throwIf(!glfwWindowShouldClose);
	}
	void unload() {
		if(handle) FreeLibrary(handle);
	}
}
__gshared _GLFWLoader GLFWLoader;
// End of GLFWLoader

// Definitions
enum GLFW_ACCUM_ALPHA_BITS = 0x0002100A;
enum GLFW_ACCUM_BLUE_BITS = 0x00021009;
enum GLFW_ACCUM_GREEN_BITS = 0x00021008;
enum GLFW_ACCUM_RED_BITS = 0x00021007;
enum GLFW_ALPHA_BITS = 0x00021004;
enum GLFW_ANGLE_PLATFORM_TYPE = 0x00050002;
enum GLFW_ANGLE_PLATFORM_TYPE_D3D11 = 0x00037005;
enum GLFW_ANGLE_PLATFORM_TYPE_D3D9 = 0x00037004;
enum GLFW_ANGLE_PLATFORM_TYPE_METAL = 0x00037008;
enum GLFW_ANGLE_PLATFORM_TYPE_NONE = 0x00037001;
enum GLFW_ANGLE_PLATFORM_TYPE_OPENGL = 0x00037002;
enum GLFW_ANGLE_PLATFORM_TYPE_OPENGLES = 0x00037003;
enum GLFW_ANGLE_PLATFORM_TYPE_VULKAN = 0x00037007;
enum GLFW_ANY_PLATFORM = 0x00060000;
enum GLFW_ANY_POSITION = 0x80000000;
enum GLFW_ANY_RELEASE_BEHAVIOR = 0;
enum GLFW_API_UNAVAILABLE = 0x00010006;
enum GLFW_ARROW_CURSOR = 0x00036001;
enum GLFW_AUTO_ICONIFY = 0x00020006;
enum GLFW_AUX_BUFFERS = 0x0002100B;
enum GLFW_BLUE_BITS = 0x00021003;
enum GLFW_CENTER_CURSOR = 0x00020009;
enum GLFW_CLIENT_API = 0x00022001;
enum GLFW_COCOA_CHDIR_RESOURCES = 0x00051001;
enum GLFW_COCOA_FRAME_NAME = 0x00023002;
enum GLFW_COCOA_GRAPHICS_SWITCHING = 0x00023003;
enum GLFW_COCOA_MENUBAR = 0x00051002;
enum GLFW_COCOA_RETINA_FRAMEBUFFER = 0x00023001;
enum GLFW_CONNECTED = 0x00040001;
enum GLFW_CONTEXT_CREATION_API = 0x0002200B;
enum GLFW_CONTEXT_DEBUG = 0x00022007;
enum GLFW_CONTEXT_NO_ERROR = 0x0002200A;
enum GLFW_CONTEXT_RELEASE_BEHAVIOR = 0x00022009;
enum GLFW_CONTEXT_REVISION = 0x00022004;
enum GLFW_CONTEXT_ROBUSTNESS = 0x00022005;
enum GLFW_CONTEXT_VERSION_MAJOR = 0x00022002;
enum GLFW_CONTEXT_VERSION_MINOR = 0x00022003;
enum GLFW_CROSSHAIR_CURSOR = 0x00036003;
enum GLFW_CURSOR = 0x00033001;
enum GLFW_CURSOR_CAPTURED = 0x00034004;
enum GLFW_CURSOR_DISABLED = 0x00034003;
enum GLFW_CURSOR_HIDDEN = 0x00034002;
enum GLFW_CURSOR_NORMAL = 0x00034001;
enum GLFW_CURSOR_UNAVAILABLE = 0x0001000B;
enum GLFW_DECORATED = 0x00020005;
enum GLFW_DEPTH_BITS = 0x00021005;
enum GLFW_DISCONNECTED = 0x00040002;
enum GLFW_DONT_CARE = - 1;
enum GLFW_DOUBLEBUFFER = 0x00021010;
enum GLFW_EGL_CONTEXT_API = 0x00036002;
enum GLFW_EXPOSE_NATIVE_WIN32 = 1;
enum GLFW_FALSE = 0;
enum GLFW_FEATURE_UNAVAILABLE = 0x0001000C;
enum GLFW_FEATURE_UNIMPLEMENTED = 0x0001000D;
enum GLFW_FLOATING = 0x00020007;
enum GLFW_FOCUSED = 0x00020001;
enum GLFW_FOCUS_ON_SHOW = 0x0002000C;
enum GLFW_FORMAT_UNAVAILABLE = 0x00010009;
enum GLFW_GAMEPAD_AXIS_LAST = GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER;
enum GLFW_GAMEPAD_AXIS_LEFT_TRIGGER = 4;
enum GLFW_GAMEPAD_AXIS_LEFT_X = 0;
enum GLFW_GAMEPAD_AXIS_LEFT_Y = 1;
enum GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER = 5;
enum GLFW_GAMEPAD_AXIS_RIGHT_X = 2;
enum GLFW_GAMEPAD_AXIS_RIGHT_Y = 3;
enum GLFW_GAMEPAD_BUTTON_A = 0;
enum GLFW_GAMEPAD_BUTTON_B = 1;
enum GLFW_GAMEPAD_BUTTON_BACK = 6;
enum GLFW_GAMEPAD_BUTTON_CIRCLE = GLFW_GAMEPAD_BUTTON_B;
enum GLFW_GAMEPAD_BUTTON_CROSS = GLFW_GAMEPAD_BUTTON_A;
enum GLFW_GAMEPAD_BUTTON_DPAD_DOWN = 13;
enum GLFW_GAMEPAD_BUTTON_DPAD_LEFT = 14;
enum GLFW_GAMEPAD_BUTTON_DPAD_RIGHT = 12;
enum GLFW_GAMEPAD_BUTTON_DPAD_UP = 11;
enum GLFW_GAMEPAD_BUTTON_GUIDE = 8;
enum GLFW_GAMEPAD_BUTTON_LAST = GLFW_GAMEPAD_BUTTON_DPAD_LEFT;
enum GLFW_GAMEPAD_BUTTON_LEFT_BUMPER = 4;
enum GLFW_GAMEPAD_BUTTON_LEFT_THUMB = 9;
enum GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER = 5;
enum GLFW_GAMEPAD_BUTTON_RIGHT_THUMB = 10;
enum GLFW_GAMEPAD_BUTTON_SQUARE = GLFW_GAMEPAD_BUTTON_X;
enum GLFW_GAMEPAD_BUTTON_START = 7;
enum GLFW_GAMEPAD_BUTTON_TRIANGLE = GLFW_GAMEPAD_BUTTON_Y;
enum GLFW_GAMEPAD_BUTTON_X = 2;
enum GLFW_GAMEPAD_BUTTON_Y = 3;
enum GLFW_GLAPIENTRY_DEFINED = 1;
enum GLFW_GREEN_BITS = 0x00021002;
enum GLFW_HAND_CURSOR = GLFW_POINTING_HAND_CURSOR;
enum GLFW_HAT_CENTERED = 0;
enum GLFW_HAT_DOWN = 4;
enum GLFW_HAT_LEFT = 8;
enum GLFW_HAT_LEFT_DOWN = ( GLFW_HAT_LEFT | GLFW_HAT_DOWN );
enum GLFW_HAT_LEFT_UP = ( GLFW_HAT_LEFT | GLFW_HAT_UP );
enum GLFW_HAT_RIGHT = 2;
enum GLFW_HAT_RIGHT_DOWN = ( GLFW_HAT_RIGHT | GLFW_HAT_DOWN );
enum GLFW_HAT_RIGHT_UP = ( GLFW_HAT_RIGHT | GLFW_HAT_UP );
enum GLFW_HAT_UP = 1;
enum GLFW_HOVERED = 0x0002000B;
enum GLFW_HRESIZE_CURSOR = GLFW_RESIZE_EW_CURSOR;
enum GLFW_IBEAM_CURSOR = 0x00036002;
enum GLFW_ICONIFIED = 0x00020002;
enum GLFW_INCLUDE_VULKAN = 1;
enum GLFW_INVALID_ENUM = 0x00010003;
enum GLFW_INVALID_VALUE = 0x00010004;
enum GLFW_JOYSTICK_1 = 0;
enum GLFW_JOYSTICK_10 = 9;
enum GLFW_JOYSTICK_11 = 10;
enum GLFW_JOYSTICK_12 = 11;
enum GLFW_JOYSTICK_13 = 12;
enum GLFW_JOYSTICK_14 = 13;
enum GLFW_JOYSTICK_15 = 14;
enum GLFW_JOYSTICK_16 = 15;
enum GLFW_JOYSTICK_2 = 1;
enum GLFW_JOYSTICK_3 = 2;
enum GLFW_JOYSTICK_4 = 3;
enum GLFW_JOYSTICK_5 = 4;
enum GLFW_JOYSTICK_6 = 5;
enum GLFW_JOYSTICK_7 = 6;
enum GLFW_JOYSTICK_8 = 7;
enum GLFW_JOYSTICK_9 = 8;
enum GLFW_JOYSTICK_HAT_BUTTONS = 0x00050001;
enum GLFW_JOYSTICK_LAST = GLFW_JOYSTICK_16;
enum GLFW_KEY_0 = 48;
enum GLFW_KEY_1 = 49;
enum GLFW_KEY_2 = 50;
enum GLFW_KEY_3 = 51;
enum GLFW_KEY_4 = 52;
enum GLFW_KEY_5 = 53;
enum GLFW_KEY_6 = 54;
enum GLFW_KEY_7 = 55;
enum GLFW_KEY_8 = 56;
enum GLFW_KEY_9 = 57;
enum GLFW_KEY_A = 65;
enum GLFW_KEY_APOSTROPHE = 39;
enum GLFW_KEY_B = 66;
enum GLFW_KEY_BACKSLASH = 92;
enum GLFW_KEY_BACKSPACE = 259;
enum GLFW_KEY_C = 67;
enum GLFW_KEY_CAPS_LOCK = 280;
enum GLFW_KEY_COMMA = 44;
enum GLFW_KEY_D = 68;
enum GLFW_KEY_DELETE = 261;
enum GLFW_KEY_DOWN = 264;
enum GLFW_KEY_E = 69;
enum GLFW_KEY_END = 269;
enum GLFW_KEY_ENTER = 257;
enum GLFW_KEY_EQUAL = 61;
enum GLFW_KEY_ESCAPE = 256;
enum GLFW_KEY_F = 70;
enum GLFW_KEY_F1 = 290;
enum GLFW_KEY_F10 = 299;
enum GLFW_KEY_F11 = 300;
enum GLFW_KEY_F12 = 301;
enum GLFW_KEY_F13 = 302;
enum GLFW_KEY_F14 = 303;
enum GLFW_KEY_F15 = 304;
enum GLFW_KEY_F16 = 305;
enum GLFW_KEY_F17 = 306;
enum GLFW_KEY_F18 = 307;
enum GLFW_KEY_F19 = 308;
enum GLFW_KEY_F2 = 291;
enum GLFW_KEY_F20 = 309;
enum GLFW_KEY_F21 = 310;
enum GLFW_KEY_F22 = 311;
enum GLFW_KEY_F23 = 312;
enum GLFW_KEY_F24 = 313;
enum GLFW_KEY_F25 = 314;
enum GLFW_KEY_F3 = 292;
enum GLFW_KEY_F4 = 293;
enum GLFW_KEY_F5 = 294;
enum GLFW_KEY_F6 = 295;
enum GLFW_KEY_F7 = 296;
enum GLFW_KEY_F8 = 297;
enum GLFW_KEY_F9 = 298;
enum GLFW_KEY_G = 71;
enum GLFW_KEY_GRAVE_ACCENT = 96;
enum GLFW_KEY_H = 72;
enum GLFW_KEY_HOME = 268;
enum GLFW_KEY_I = 73;
enum GLFW_KEY_INSERT = 260;
enum GLFW_KEY_J = 74;
enum GLFW_KEY_K = 75;
enum GLFW_KEY_KP_0 = 320;
enum GLFW_KEY_KP_1 = 321;
enum GLFW_KEY_KP_2 = 322;
enum GLFW_KEY_KP_3 = 323;
enum GLFW_KEY_KP_4 = 324;
enum GLFW_KEY_KP_5 = 325;
enum GLFW_KEY_KP_6 = 326;
enum GLFW_KEY_KP_7 = 327;
enum GLFW_KEY_KP_8 = 328;
enum GLFW_KEY_KP_9 = 329;
enum GLFW_KEY_KP_ADD = 334;
enum GLFW_KEY_KP_DECIMAL = 330;
enum GLFW_KEY_KP_DIVIDE = 331;
enum GLFW_KEY_KP_ENTER = 335;
enum GLFW_KEY_KP_EQUAL = 336;
enum GLFW_KEY_KP_MULTIPLY = 332;
enum GLFW_KEY_KP_SUBTRACT = 333;
enum GLFW_KEY_L = 76;
enum GLFW_KEY_LAST = GLFW_KEY_MENU;
enum GLFW_KEY_LEFT = 263;
enum GLFW_KEY_LEFT_ALT = 342;
enum GLFW_KEY_LEFT_BRACKET = 91;
enum GLFW_KEY_LEFT_CONTROL = 341;
enum GLFW_KEY_LEFT_SHIFT = 340;
enum GLFW_KEY_LEFT_SUPER = 343;
enum GLFW_KEY_M = 77;
enum GLFW_KEY_MENU = 348;
enum GLFW_KEY_MINUS = 45;
enum GLFW_KEY_N = 78;
enum GLFW_KEY_NUM_LOCK = 282;
enum GLFW_KEY_O = 79;
enum GLFW_KEY_P = 80;
enum GLFW_KEY_PAGE_DOWN = 267;
enum GLFW_KEY_PAGE_UP = 266;
enum GLFW_KEY_PAUSE = 284;
enum GLFW_KEY_PERIOD = 46;
enum GLFW_KEY_PRINT_SCREEN = 283;
enum GLFW_KEY_Q = 81;
enum GLFW_KEY_R = 82;
enum GLFW_KEY_RIGHT = 262;
enum GLFW_KEY_RIGHT_ALT = 346;
enum GLFW_KEY_RIGHT_BRACKET = 93;
enum GLFW_KEY_RIGHT_CONTROL = 345;
enum GLFW_KEY_RIGHT_SHIFT = 344;
enum GLFW_KEY_RIGHT_SUPER = 347;
enum GLFW_KEY_S = 83;
enum GLFW_KEY_SCROLL_LOCK = 281;
enum GLFW_KEY_SEMICOLON = 59;
enum GLFW_KEY_SLASH = 47;
enum GLFW_KEY_SPACE = 32;
enum GLFW_KEY_T = 84;
enum GLFW_KEY_TAB = 258;
enum GLFW_KEY_U = 85;
enum GLFW_KEY_UNKNOWN = - 1;
enum GLFW_KEY_UP = 265;
enum GLFW_KEY_V = 86;
enum GLFW_KEY_W = 87;
enum GLFW_KEY_WORLD_1 = 161;
enum GLFW_KEY_WORLD_2 = 162;
enum GLFW_KEY_X = 88;
enum GLFW_KEY_Y = 89;
enum GLFW_KEY_Z = 90;
enum GLFW_LOCK_KEY_MODS = 0x00033004;
enum GLFW_LOSE_CONTEXT_ON_RESET = 0x00031002;
enum GLFW_MAXIMIZED = 0x00020008;
enum GLFW_MOD_ALT = 0x0004;
enum GLFW_MOD_CAPS_LOCK = 0x0010;
enum GLFW_MOD_CONTROL = 0x0002;
enum GLFW_MOD_NUM_LOCK = 0x0020;
enum GLFW_MOD_SHIFT = 0x0001;
enum GLFW_MOD_SUPER = 0x0008;
enum GLFW_MOUSE_BUTTON_1 = 0;
enum GLFW_MOUSE_BUTTON_2 = 1;
enum GLFW_MOUSE_BUTTON_3 = 2;
enum GLFW_MOUSE_BUTTON_4 = 3;
enum GLFW_MOUSE_BUTTON_5 = 4;
enum GLFW_MOUSE_BUTTON_6 = 5;
enum GLFW_MOUSE_BUTTON_7 = 6;
enum GLFW_MOUSE_BUTTON_8 = 7;
enum GLFW_MOUSE_BUTTON_LAST = GLFW_MOUSE_BUTTON_8;
enum GLFW_MOUSE_BUTTON_LEFT = GLFW_MOUSE_BUTTON_1;
enum GLFW_MOUSE_BUTTON_MIDDLE = GLFW_MOUSE_BUTTON_3;
enum GLFW_MOUSE_BUTTON_RIGHT = GLFW_MOUSE_BUTTON_2;
enum GLFW_MOUSE_PASSTHROUGH = 0x0002000D;
enum GLFW_NATIVE_CONTEXT_API = 0x00036001;
enum GLFW_NOT_ALLOWED_CURSOR = 0x0003600A;
enum GLFW_NOT_INITIALIZED = 0x00010001;
enum GLFW_NO_API = 0;
enum GLFW_NO_CURRENT_CONTEXT = 0x00010002;
enum GLFW_NO_ERROR = 0;
enum GLFW_NO_RESET_NOTIFICATION = 0x00031001;
enum GLFW_NO_ROBUSTNESS = 0;
enum GLFW_NO_WINDOW_CONTEXT = 0x0001000A;
enum GLFW_OPENGL_ANY_PROFILE = 0;
enum GLFW_OPENGL_API = 0x00030001;
enum GLFW_OPENGL_COMPAT_PROFILE = 0x00032002;
enum GLFW_OPENGL_CORE_PROFILE = 0x00032001;
enum GLFW_OPENGL_DEBUG_CONTEXT = GLFW_CONTEXT_DEBUG;
enum GLFW_OPENGL_ES_API = 0x00030002;
enum GLFW_OPENGL_FORWARD_COMPAT = 0x00022006;
enum GLFW_OPENGL_PROFILE = 0x00022008;
enum GLFW_OSMESA_CONTEXT_API = 0x00036003;
enum GLFW_OUT_OF_MEMORY = 0x00010005;
enum GLFW_PLATFORM = 0x00050003;
enum GLFW_PLATFORM_COCOA = 0x00060002;
enum GLFW_PLATFORM_ERROR = 0x00010008;
enum GLFW_PLATFORM_NULL = 0x00060005;
enum GLFW_PLATFORM_UNAVAILABLE = 0x0001000E;
enum GLFW_PLATFORM_WAYLAND = 0x00060003;
enum GLFW_PLATFORM_WIN32 = 0x00060001;
enum GLFW_PLATFORM_X11 = 0x00060004;
enum GLFW_POINTING_HAND_CURSOR = 0x00036004;
enum GLFW_POSITION_X = 0x0002000E;
enum GLFW_POSITION_Y = 0x0002000F;
enum GLFW_PRESS = 1;
enum GLFW_RAW_MOUSE_MOTION = 0x00033005;
enum GLFW_RED_BITS = 0x00021001;
enum GLFW_REFRESH_RATE = 0x0002100F;
enum GLFW_RELEASE = 0;
enum GLFW_RELEASE_BEHAVIOR_FLUSH = 0x00035001;
enum GLFW_RELEASE_BEHAVIOR_NONE = 0x00035002;
enum GLFW_REPEAT = 2;
enum GLFW_RESIZABLE = 0x00020003;
enum GLFW_RESIZE_ALL_CURSOR = 0x00036009;
enum GLFW_RESIZE_EW_CURSOR = 0x00036005;
enum GLFW_RESIZE_NESW_CURSOR = 0x00036008;
enum GLFW_RESIZE_NS_CURSOR = 0x00036006;
enum GLFW_RESIZE_NWSE_CURSOR = 0x00036007;
enum GLFW_SAMPLES = 0x0002100D;
enum GLFW_SCALE_FRAMEBUFFER = 0x0002200D;
enum GLFW_SCALE_TO_MONITOR = 0x0002200C;
enum GLFW_SRGB_CAPABLE = 0x0002100E;
enum GLFW_STENCIL_BITS = 0x00021006;
enum GLFW_STEREO = 0x0002100C;
enum GLFW_STICKY_KEYS = 0x00033002;
enum GLFW_STICKY_MOUSE_BUTTONS = 0x00033003;
enum GLFW_TRANSPARENT_FRAMEBUFFER = 0x0002000A;
enum GLFW_TRUE = 1;
enum GLFW_VERSION_MAJOR = 3;
enum GLFW_VERSION_MINOR = 4;
enum GLFW_VERSION_REVISION = 0;
enum GLFW_VERSION_UNAVAILABLE = 0x00010007;
enum GLFW_VISIBLE = 0x00020004;
enum GLFW_VRESIZE_CURSOR = GLFW_RESIZE_NS_CURSOR;
enum GLFW_WAYLAND_APP_ID = 0x00026001;
enum GLFW_WAYLAND_DISABLE_LIBDECOR = 0x00038002;
enum GLFW_WAYLAND_LIBDECOR = 0x00053001;
enum GLFW_WAYLAND_PREFER_LIBDECOR = 0x00038001;
enum GLFW_WIN32_KEYBOARD_MENU = 0x00025001;
enum GLFW_WIN32_SHOWDEFAULT = 0x00025002;
enum GLFW_X11_CLASS_NAME = 0x00024001;
enum GLFW_X11_INSTANCE_NAME = 0x00024002;
enum GLFW_X11_XCB_VULKAN_SURFACE = 0x00052001;
// End Definitions

// Aliases
alias BOOL = int;
alias BYTE = ubyte;
alias CCHAR = char;
alias CHAR = char;
alias DWORD = uint;
alias DWORD64 = ulong;
alias FLOAT = float;
alias FXPT2DOT30 = int;
alias GLFWallocatefun = extern(C) void* function(size_t size, void* user) nothrow;
alias GLFWcharfun = extern(C) void function(GLFWwindow* window, uint codepoint) nothrow;
alias GLFWcharmodsfun = extern(C) void function(GLFWwindow* window, uint codepoint, int mods) nothrow;
alias GLFWcursorenterfun = extern(C) void function(GLFWwindow* window, int entered) nothrow;
alias GLFWcursorposfun = extern(C) void function(GLFWwindow* window, double xpos, double ypos) nothrow;
alias GLFWdeallocatefun = extern(C) void function(void* block, void* user) nothrow;
alias GLFWdropfun = extern(C) void function(GLFWwindow* window, int path_count, immutable(char)** paths) nothrow;
alias GLFWerrorfun = extern(C) void function(int error_code, immutable(char)* description) nothrow;
alias GLFWframebuffersizefun = extern(C) void function(GLFWwindow* window, int width, int height) nothrow;
alias GLFWglproc = extern(C) void function() nothrow;
alias GLFWjoystickfun = extern(C) void function(int jid, int event) nothrow;
alias GLFWkeyfun = extern(C) void function(GLFWwindow* window, int key, int scancode, int action, int mods) nothrow;
alias GLFWmonitorfun = extern(C) void function(GLFWmonitor* monitor, int event) nothrow;
alias GLFWmousebuttonfun = extern(C) void function(GLFWwindow* window, int button, int action, int mods) nothrow;
alias GLFWreallocatefun = extern(C) void* function(void* block, size_t size, void* user) nothrow;
alias GLFWscrollfun = extern(C) void function(GLFWwindow* window, double xoffset, double yoffset) nothrow;
alias GLFWvkproc = extern(C) void function() nothrow;
alias GLFWwindowclosefun = extern(C) void function(GLFWwindow* window) nothrow;
alias GLFWwindowcontentscalefun = extern(C) void function(GLFWwindow* window, float xscale, float yscale) nothrow;
alias GLFWwindowfocusfun = extern(C) void function(GLFWwindow* window, int focused) nothrow;
alias GLFWwindowiconifyfun = extern(C) void function(GLFWwindow* window, int iconified) nothrow;
alias GLFWwindowmaximizefun = extern(C) void function(GLFWwindow* window, int maximized) nothrow;
alias GLFWwindowposfun = extern(C) void function(GLFWwindow* window, int xpos, int ypos) nothrow;
alias GLFWwindowrefreshfun = extern(C) void function(GLFWwindow* window) nothrow;
alias GLFWwindowsizefun = extern(C) void function(GLFWwindow* window, int width, int height) nothrow;
alias GLbitfield = uint;
alias GLboolean = ubyte;
alias GLbyte = char;
alias GLclampd = double;
alias GLclampf = float;
alias GLdouble = double;
alias GLenum = uint;
alias GLfloat = float;
alias GLint = int;
alias GLshort = short;
alias GLsizei = int;
alias GLubyte = ubyte;
alias GLuint = uint;
alias GLushort = ushort;
alias GLvoid = void;
alias HANDLE = void*;
alias HANDLE64 = void*;
alias HFILE = int;
alias HGDIOBJ = void*;
alias HPCON = void*;
alias HRESULT = int;
alias INT = int;
alias INT16 = short;
alias INT32 = int;
alias INT64 = long;
alias INT8 = char;
alias INT_PTR = long;
alias LONG = int;
alias LONG64 = long;
alias LONGLONG = long;
alias LONG_PTR = long;
alias LPCVOID = void*;
alias LPINT = int*;
alias LPLONG = int*;
alias LPVOID = void*;
alias MENUTEMPLATEA = void;
alias MENUTEMPLATEW = void;
alias PUINT = uint*;
alias PUMS_COMPLETION_LIST = void*;
alias PUMS_CONTEXT = void*;
alias PVOID = void*;
alias PVOID64 = void*;
alias SHORT = short;
alias UCHAR = ubyte;
alias UCSCHAR = uint;
alias UINT = uint;
alias UINT16 = ushort;
alias UINT32 = uint;
alias UINT64 = ulong;
alias UINT8 = ubyte;
alias UINT_PTR = ulong;
alias ULONG = uint;
alias ULONG64 = ulong;
alias ULONGLONG = ulong;
alias ULONG_PTR = ulong;
alias USHORT = ushort;
alias WORD = ushort;
alias __time64_t = long;
alias errno_t = int;
alias int16_t = short;
alias int32_t = int;
alias int64_t = long;
alias int8_t = char;
alias size_t = ulong;
alias uint16_t = ushort;
alias uint32_t = uint;
alias uint64_t = ulong;
alias uint8_t = ubyte;
alias uintptr_t = ulong;
alias va_list = immutable(char)*;
alias wchar_t = ushort;
alias wctype_t = ushort;
alias wint_t = ushort;

// Enums

// Unions

// Structs
struct GLFWallocator {
	GLFWallocatefun allocate;
	GLFWreallocatefun reallocate;
	GLFWdeallocatefun deallocate;
	void* user;
}
struct GLFWcursor {
}
struct GLFWgamepadstate {
	ubyte[15] buttons;
	float[6] axes;
}
struct GLFWgammaramp {
	ushort* red;
	ushort* green;
	ushort* blue;
	uint size;
}
struct GLFWimage {
	int width;
	int height;
	ubyte* pixels;
}
struct GLFWmonitor {
}
struct GLFWvidmode {
	int width;
	int height;
	int redBits;
	int greenBits;
	int blueBits;
	int refreshRate;
}
struct GLFWwindow {
}

// Global variables

extern(Windows) { nothrow __gshared {

}} // extern(Windows), __gshared

extern(C) { nothrow __gshared {

GLFWcursor* function(GLFWimage* image, int xhot, int yhot)
	glfwCreateCursor;

GLFWcursor* function(int shape)
	glfwCreateStandardCursor;

GLFWwindow* function(int width, int height, immutable(char)* title, GLFWmonitor* monitor, GLFWwindow* share)
	glfwCreateWindow;

VkResult function(VkInstance instance, GLFWwindow* window, VkAllocationCallbacks* allocator, VkSurfaceKHR* surface)
	glfwCreateWindowSurface;

void function()
	glfwDefaultWindowHints;

void function(GLFWcursor* cursor)
	glfwDestroyCursor;

void function(GLFWwindow* window)
	glfwDestroyWindow;

int function(immutable(char)* extension)
	glfwExtensionSupported;

void function(GLFWwindow* window)
	glfwFocusWindow;

immutable(char)* function(GLFWwindow* window)
	glfwGetClipboardString;

GLFWwindow* function()
	glfwGetCurrentContext;

void function(GLFWwindow* window, double* xpos, double* ypos)
	glfwGetCursorPos;

int function(immutable(char)** description)
	glfwGetError;

void function(GLFWwindow* window, int* width, int* height)
	glfwGetFramebufferSize;

immutable(char)* function(int jid)
	glfwGetGamepadName;

int function(int jid, GLFWgamepadstate* state)
	glfwGetGamepadState;

GLFWgammaramp* function(GLFWmonitor* monitor)
	glfwGetGammaRamp;

int function(GLFWwindow* window, int mode)
	glfwGetInputMode;

GLFWvkproc function(VkInstance instance, immutable(char)* procname)
	glfwGetInstanceProcAddress;

float* function(int jid, int* count)
	glfwGetJoystickAxes;

ubyte* function(int jid, int* count)
	glfwGetJoystickButtons;

immutable(char)* function(int jid)
	glfwGetJoystickGUID;

ubyte* function(int jid, int* count)
	glfwGetJoystickHats;

immutable(char)* function(int jid)
	glfwGetJoystickName;

void* function(int jid)
	glfwGetJoystickUserPointer;

int function(GLFWwindow* window, int key)
	glfwGetKey;

immutable(char)* function(int key, int scancode)
	glfwGetKeyName;

int function(int key)
	glfwGetKeyScancode;

void function(GLFWmonitor* monitor, float* xscale, float* yscale)
	glfwGetMonitorContentScale;

immutable(char)* function(GLFWmonitor* monitor)
	glfwGetMonitorName;

void function(GLFWmonitor* monitor, int* widthMM, int* heightMM)
	glfwGetMonitorPhysicalSize;

void function(GLFWmonitor* monitor, int* xpos, int* ypos)
	glfwGetMonitorPos;

void* function(GLFWmonitor* monitor)
	glfwGetMonitorUserPointer;

void function(GLFWmonitor* monitor, int* xpos, int* ypos, int* width, int* height)
	glfwGetMonitorWorkarea;

GLFWmonitor** function(int* count)
	glfwGetMonitors;

int function(GLFWwindow* window, int button)
	glfwGetMouseButton;

int function(VkInstance instance, VkPhysicalDevice device, uint32_t queuefamily)
	glfwGetPhysicalDevicePresentationSupport;

int function()
	glfwGetPlatform;

GLFWmonitor* function()
	glfwGetPrimaryMonitor;

GLFWglproc function(immutable(char)* procname)
	glfwGetProcAddress;

immutable(char)** function(uint32_t* count)
	glfwGetRequiredInstanceExtensions;

double function()
	glfwGetTime;

uint64_t function()
	glfwGetTimerFrequency;

uint64_t function()
	glfwGetTimerValue;

void function(int* major, int* minor, int* rev)
	glfwGetVersion;

immutable(char)* function()
	glfwGetVersionString;

GLFWvidmode* function(GLFWmonitor* monitor)
	glfwGetVideoMode;

GLFWvidmode* function(GLFWmonitor* monitor, int* count)
	glfwGetVideoModes;

immutable(char)* function(GLFWmonitor* monitor)
	glfwGetWin32Adapter;

immutable(char)* function(GLFWmonitor* monitor)
	glfwGetWin32Monitor;

HWND function(GLFWwindow* window)
	glfwGetWin32Window;

int function(GLFWwindow* window, int attrib)
	glfwGetWindowAttrib;

void function(GLFWwindow* window, float* xscale, float* yscale)
	glfwGetWindowContentScale;

void function(GLFWwindow* window, int* left, int* top, int* right, int* bottom)
	glfwGetWindowFrameSize;

GLFWmonitor* function(GLFWwindow* window)
	glfwGetWindowMonitor;

float function(GLFWwindow* window)
	glfwGetWindowOpacity;

void function(GLFWwindow* window, int* xpos, int* ypos)
	glfwGetWindowPos;

void function(GLFWwindow* window, int* width, int* height)
	glfwGetWindowSize;

immutable(char)* function(GLFWwindow* window)
	glfwGetWindowTitle;

void* function(GLFWwindow* window)
	glfwGetWindowUserPointer;

void function(GLFWwindow* window)
	glfwHideWindow;

void function(GLFWwindow* window)
	glfwIconifyWindow;

int function()
	glfwInit;

void function(GLFWallocator* allocator)
	glfwInitAllocator;

void function(int hint, int value)
	glfwInitHint;

void function(PFN_vkGetInstanceProcAddr loader)
	glfwInitVulkanLoader;

int function(int jid)
	glfwJoystickIsGamepad;

int function(int jid)
	glfwJoystickPresent;

void function(GLFWwindow* window)
	glfwMakeContextCurrent;

void function(GLFWwindow* window)
	glfwMaximizeWindow;

int function(int platform)
	glfwPlatformSupported;

void function()
	glfwPollEvents;

void function()
	glfwPostEmptyEvent;

int function()
	glfwRawMouseMotionSupported;

void function(GLFWwindow* window)
	glfwRequestWindowAttention;

void function(GLFWwindow* window)
	glfwRestoreWindow;

GLFWcharfun function(GLFWwindow* window, GLFWcharfun callback)
	glfwSetCharCallback;

GLFWcharmodsfun function(GLFWwindow* window, GLFWcharmodsfun callback)
	glfwSetCharModsCallback;

void function(GLFWwindow* window, immutable(char)* string_)
	glfwSetClipboardString;

void function(GLFWwindow* window, GLFWcursor* cursor)
	glfwSetCursor;

GLFWcursorenterfun function(GLFWwindow* window, GLFWcursorenterfun callback)
	glfwSetCursorEnterCallback;

void function(GLFWwindow* window, double xpos, double ypos)
	glfwSetCursorPos;

GLFWcursorposfun function(GLFWwindow* window, GLFWcursorposfun callback)
	glfwSetCursorPosCallback;

GLFWdropfun function(GLFWwindow* window, GLFWdropfun callback)
	glfwSetDropCallback;

GLFWerrorfun function(GLFWerrorfun callback)
	glfwSetErrorCallback;

GLFWframebuffersizefun function(GLFWwindow* window, GLFWframebuffersizefun callback)
	glfwSetFramebufferSizeCallback;

void function(GLFWmonitor* monitor, float gamma)
	glfwSetGamma;

void function(GLFWmonitor* monitor, GLFWgammaramp* ramp)
	glfwSetGammaRamp;

void function(GLFWwindow* window, int mode, int value)
	glfwSetInputMode;

GLFWjoystickfun function(GLFWjoystickfun callback)
	glfwSetJoystickCallback;

void function(int jid, void* pointer)
	glfwSetJoystickUserPointer;

GLFWkeyfun function(GLFWwindow* window, GLFWkeyfun callback)
	glfwSetKeyCallback;

GLFWmonitorfun function(GLFWmonitorfun callback)
	glfwSetMonitorCallback;

void function(GLFWmonitor* monitor, void* pointer)
	glfwSetMonitorUserPointer;

GLFWmousebuttonfun function(GLFWwindow* window, GLFWmousebuttonfun callback)
	glfwSetMouseButtonCallback;

GLFWscrollfun function(GLFWwindow* window, GLFWscrollfun callback)
	glfwSetScrollCallback;

void function(double time)
	glfwSetTime;

void function(GLFWwindow* window, int numer, int denom)
	glfwSetWindowAspectRatio;

void function(GLFWwindow* window, int attrib, int value)
	glfwSetWindowAttrib;

GLFWwindowclosefun function(GLFWwindow* window, GLFWwindowclosefun callback)
	glfwSetWindowCloseCallback;

GLFWwindowcontentscalefun function(GLFWwindow* window, GLFWwindowcontentscalefun callback)
	glfwSetWindowContentScaleCallback;

GLFWwindowfocusfun function(GLFWwindow* window, GLFWwindowfocusfun callback)
	glfwSetWindowFocusCallback;

void function(GLFWwindow* window, int count, GLFWimage* images)
	glfwSetWindowIcon;

GLFWwindowiconifyfun function(GLFWwindow* window, GLFWwindowiconifyfun callback)
	glfwSetWindowIconifyCallback;

GLFWwindowmaximizefun function(GLFWwindow* window, GLFWwindowmaximizefun callback)
	glfwSetWindowMaximizeCallback;

void function(GLFWwindow* window, GLFWmonitor* monitor, int xpos, int ypos, int width, int height, int refreshRate)
	glfwSetWindowMonitor;

void function(GLFWwindow* window, float opacity)
	glfwSetWindowOpacity;

void function(GLFWwindow* window, int xpos, int ypos)
	glfwSetWindowPos;

GLFWwindowposfun function(GLFWwindow* window, GLFWwindowposfun callback)
	glfwSetWindowPosCallback;

GLFWwindowrefreshfun function(GLFWwindow* window, GLFWwindowrefreshfun callback)
	glfwSetWindowRefreshCallback;

void function(GLFWwindow* window, int value)
	glfwSetWindowShouldClose;

void function(GLFWwindow* window, int width, int height)
	glfwSetWindowSize;

GLFWwindowsizefun function(GLFWwindow* window, GLFWwindowsizefun callback)
	glfwSetWindowSizeCallback;

void function(GLFWwindow* window, int minwidth, int minheight, int maxwidth, int maxheight)
	glfwSetWindowSizeLimits;

void function(GLFWwindow* window, immutable(char)* title)
	glfwSetWindowTitle;

void function(GLFWwindow* window, void* pointer)
	glfwSetWindowUserPointer;

void function(GLFWwindow* window)
	glfwShowWindow;

void function(GLFWwindow* window)
	glfwSwapBuffers;

void function(int interval)
	glfwSwapInterval;

void function()
	glfwTerminate;

int function(immutable(char)* string_)
	glfwUpdateGamepadMappings;

int function()
	glfwVulkanSupported;

void function()
	glfwWaitEvents;

void function(double timeout)
	glfwWaitEventsTimeout;

void function(int hint, int value)
	glfwWindowHint;

void function(int hint, immutable(char)* value)
	glfwWindowHintString;

int function(GLFWwindow* window)
	glfwWindowShouldClose;

}} // extern(C), __gshared

