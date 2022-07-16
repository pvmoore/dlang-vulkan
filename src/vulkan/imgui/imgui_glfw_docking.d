module vulkan.imgui.imgui_glfw_docking;

import vulkan.all;
import core.stdc.stdlib : calloc, free;

import core.sys.windows.windows;


/**
 * Converted from:
 * https://github.com/ocornut/imgui.git
 *  - 'docking' branch 2021/07/11
 *  - imgui/backends/imgui_impl_glfw.cpp
 */
private:

enum FLT_MIN = 1.175494351e-38F;
enum FLT_MAX = 3.402823466e+38F;

// dear imgui: Platform Backend for GLFW
// This needs to be used along with a Renderer (e.g. OpenGL3, Vulkan, WebGPU..)
// (Info: GLFW is a cross-platform general purpose library for handling windows, inputs, OpenGL/Vulkan graphics context creation, etc.)
// (Requires: GLFW 3.1+. Prefer GLFW 3.3+ for full feature support.)

// Implemented features:
//  [X] Platform: Clipboard support.
//  [X] Platform: Gamepad support. Enable with 'io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad'.
//  [X] Platform: Mouse cursor shape and visibility. Disable with 'io.ConfigFlags |= ImGuiConfigFlags_NoMouseCursorChange' (note: the resizing cursors requires GLFW 3.4+).
//  [X] Platform: Keyboard arrays indexed using GLFW_KEY_* codes, e.g. ImGui::IsKeyPressed(GLFW_KEY_SPACE).
//  [X] Platform: Multi-viewport support (multiple windows). Enable with 'io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable'.

// Issues:
//  [ ] Platform: Multi-viewport support: ParentViewportID not honored, and so io.ConfigViewportsNoDefaultParent has no effect (minor).

// You can use unmodified imgui_impl_* files in your project. See examples/ folder for examples of using this.
// Prefer including the entire imgui/ repository into your project (either as a copy or as a submodule), and only build the backends you need.
// If you are new to Dear ImGui, read documentation from the docs/ folder + read the top of imgui.cpp.
// Read online: https://github.com/ocornut/imgui/tree/master/docs

// CHANGELOG
// (minor and older changes stripped away, please see git history for details)
//  2021-XX-XX: Platform: Added support for multiple windows via the ImGuiPlatformIO interface.
//  2021-06-29: Reorganized backend to pull data from a single structure to facilitate usage with multiple-contexts (all g_XXXX access changed to bd.XXXX).
//  2020-01-17: Inputs: Disable error callback while assigning mouse cursors because some X11 setup don't have them and it generates errors.
//  2019-12-05: Inputs: Added support for new mouse cursors added in GLFW 3.4+ (resizing cursors, not allowed cursor).
//  2019-10-18: Misc: Previously installed user callbacks are now restored on shutdown.
//  2019-07-21: Inputs: Added mapping for ImGuiKey_KeyPadEnter.
//  2019-05-11: Inputs: Don't filter value from character callback before calling AddInputCharacter().
//  2019-03-12: Misc: Preserve DisplayFramebufferScale when main window is minimized.
//  2018-11-30: Misc: Setting up io.BackendPlatformName so it can be displayed in the About Window.
//  2018-11-07: Inputs: When installing our GLFW callbacks, we save user's previously installed ones - if any - and chain call them.
//  2018-08-01: Inputs: Workaround for Emscripten which doesn't seem to handle focus related calls.
//  2018-06-29: Inputs: Added support for the ImGuiMouseCursor_Hand cursor.
//  2018-06-08: Misc: Extracted imgui_impl_glfw.cpp/.h away from the old combined GLFW+OpenGL/Vulkan examples.
//  2018-03-20: Misc: Setup io.BackendFlags ImGuiBackendFlags_HasMouseCursors flag + honor ImGuiConfigFlags_NoMouseCursorChange flag.
//  2018-02-20: Inputs: Added support for mouse cursors (ImGui::GetMouseCursor() value, passed to glfwSetCursor()).
//  2018-02-06: Misc: Removed call to ImGui::Shutdown() which is not available from 1.60 WIP, user needs to call CreateContext/DestroyContext themselves.
//  2018-02-06: Inputs: Added mapping for ImGuiKey_Space.
//  2018-01-25: Inputs: Added gamepad support if ImGuiConfigFlags_NavEnableGamepad is set.
//  2018-01-25: Inputs: Honoring the io.WantSetMousePos by repositioning the mouse (when using navigation and ImGuiConfigFlags_NavMoveMouse is set).
//  2018-01-20: Inputs: Added Horizontal Mouse Wheel support.
//  2018-01-18: Inputs: Added mapping for ImGuiKey_Insert.
//  2017-08-25: Inputs: MousePos set to -FLT_MAX,-FLT_MAX when mouse is unavailable/missing (instead of -1,-1).
//  2016-10-15: Misc: Added a void* user_data parameter to Clipboard function handlers.

// #include "imgui.h"
// #include "imgui_impl_glfw.h"

// GLFW
// #include <GLFW/glfw3.h>
// #ifdef _WIN32
// #undef APIENTRY
// #define GLFW_EXPOSE_NATIVE_WIN32
// #include <GLFW/glfw3native.h>   // for glfwGetWin32Window
// #endif

enum _WIN32         = true;
enum __APPLE__      = false;
enum __EMSCRIPTEN__ = false;

enum GLFW_HAS_WINDOW_TOPMOST     =  (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3200); // 3.2+ GLFW_FLOATING
enum GLFW_HAS_WINDOW_HOVERED     =  (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3300); // 3.3+ GLFW_HOVERED
enum GLFW_HAS_WINDOW_ALPHA       =  (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3300); // 3.3+ glfwSetWindowOpacity
enum GLFW_HAS_PER_MONITOR_DPI    =  (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3300); // 3.3+ glfwGetMonitorContentScale
enum GLFW_HAS_VULKAN             =  (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3200); // 3.2+ glfwCreateWindowSurface
enum GLFW_HAS_FOCUS_WINDOW       =  (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3200); // 3.2+ glfwFocusWindow
enum GLFW_HAS_FOCUS_ON_SHOW      =  (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3300); // 3.3+ GLFW_FOCUS_ON_SHOW
enum GLFW_HAS_MONITOR_WORK_AREA  =  (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3300); // 3.3+ glfwGetMonitorWorkarea
enum GLFW_HAS_OSX_WINDOW_POS_FIX =  (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 + GLFW_VERSION_REVISION * 10 >= 3310); // 3.3.1+ Fixed: Resizing window repositions it on MacOS #1553

// #ifdef GLFW_RESIZE_NESW_CURSOR        // Let's be nice to people who pulled GLFW between 2019-04-16 (3.4 define) and 2019-11-29 (cursors defines) // FIXME: Remove when GLFW 3.4 is released?
// enum GLFW_HAS_NEW_CURSORS        =  (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3400); // 3.4+ GLFW_RESIZE_ALL_CURSOR, GLFW_RESIZE_NESW_CURSOR, GLFW_RESIZE_NWSE_CURSOR, GLFW_NOT_ALLOWED_CURSOR
// #else
enum GLFW_HAS_NEW_CURSORS = 0;
// #endif
// static if(GLFW_MOUSE_PASSTHROUGH) {         // Let's be nice to people who pulled GLFW between 2019-04-16 (3.4 define) and 2020-07-17 (passthrough)
// #define GLFW_HAS_MOUSE_PASSTHROUGH    (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3400) // 3.4+ GLFW_MOUSE_PASSTHROUGH
// } else {
enum GLFW_HAS_MOUSE_PASSTHROUGH = 0;
// }


// GLFW data
enum GlfwClientApi
{
    GlfwClientApi_Unknown,
    GlfwClientApi_OpenGL,
    GlfwClientApi_Vulkan
}

struct ImGui_ImplGlfw_Data
{
    GLFWwindow*                         Window;
    GlfwClientApi                       ClientApi;
    double                              Time = 0;
    bool[ImGuiMouseButton_COUNT]        MouseJustPressed;
    GLFWcursor*[ImGuiMouseCursor_COUNT] MouseCursors;
    GLFWwindow*[512]                    KeyOwnerWindows;
    bool                                InstalledCallbacks;
    bool                                WantUpdateMonitors;

    // Chain GLFW callbacks: our callbacks will call the user's previously installed callbacks, if any.
    GLFWmousebuttonfun                  PrevUserCallbackMousebutton;
    GLFWscrollfun                       PrevUserCallbackScroll;
    GLFWkeyfun                          PrevUserCallbackKey;
    GLFWcharfun                         PrevUserCallbackChar;
    GLFWmonitorfun                      PrevUserCallbackMonitor;
}

// Backend data stored in io.BackendPlatformUserData to allow support for multiple Dear ImGui contexts
// It is STRONGLY preferred that you use docking branch with multi-viewports (== single Dear ImGui context + multiple windows) instead of multiple Dear ImGui contexts.
// FIXME: multi-context support is not well tested and probably dysfunctional in this backend.
// - Because glfwPollEvents() process all windows and some events may be called outside of it, you will need to register your own callbacks
//   (passing install_callbacks=false in ImGui_ImplGlfw_InitXXX functions), set the current dear imgui context and then call our callbacks.
// - Otherwise we may need to store a GLFWWindow* . ImGuiContext* map and handle this in the backend, adding a little bit of extra complexity to it.
// FIXME: some shared resources (mouse cursor shape, gamepad) are mishandled when using multi-context.
ImGui_ImplGlfw_Data* ImGui_ImplGlfw_GetBackendData() nothrow
{
    return igGetCurrentContext() ? cast(ImGui_ImplGlfw_Data*)igGetIO().BackendPlatformUserData : null;
}

// Forward Declarations
// static void ImGui_ImplGlfw_UpdateMonitors();
// static void ImGui_ImplGlfw_InitPlatformInterface();
// static void ImGui_ImplGlfw_ShutdownPlatformInterface();

// Functions
extern(C) {
nothrow:
    immutable(char)* ImGui_ImplGlfw_GetClipboardText(void* user_data)
    {
        return glfwGetClipboardString(cast(GLFWwindow*)user_data);
    }

    void ImGui_ImplGlfw_SetClipboardText(void* user_data, immutable(char)* text)
    {
        glfwSetClipboardString(cast(GLFWwindow*)user_data, cast(immutable(char)*)text);
    }

    void ImGui_ImplGlfw_MouseButtonCallback(GLFWwindow* window, int button, int action, int mods)
    {
        try{
            ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
            if (bd.PrevUserCallbackMousebutton !is null && window is bd.Window)
                bd.PrevUserCallbackMousebutton(window, button, action, mods);

            if (action == GLFW_PRESS && button >= 0 && button < bd.MouseJustPressed.length)
                bd.MouseJustPressed[button] = true;
        }catch(Exception) {}
    }

    void ImGui_ImplGlfw_ScrollCallback(GLFWwindow* window, double xoffset, double yoffset)
    {
        try{
            ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
            if (bd.PrevUserCallbackScroll !is null && window is bd.Window)
                bd.PrevUserCallbackScroll(window, xoffset, yoffset);

            ImGuiIO* io = igGetIO();
            io.MouseWheelH += cast(float)xoffset;
            io.MouseWheel += cast(float)yoffset;
        }catch(Exception) {}
    }

    void ImGui_ImplGlfw_KeyCallback(GLFWwindow* window, int key, int scancode, int action, int mods)
    {
        try{
            ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
            if (bd.PrevUserCallbackKey !is null && window is bd.Window)
                bd.PrevUserCallbackKey(window, key, scancode, action, mods);

            ImGuiIO* io = igGetIO();
            if (key >= 0 && key < io.KeysDown.length)
            {
                if (action == GLFW_PRESS)
                {
                    io.KeysDown[key] = true;
                    bd.KeyOwnerWindows[key] = window;
                }
                if (action == GLFW_RELEASE)
                {
                    io.KeysDown[key] = false;
                    bd.KeyOwnerWindows[key] = null;
                }
            }

            // Modifiers are not reliable across systems
            io.KeyCtrl = io.KeysDown[GLFW_KEY_LEFT_CONTROL] || io.KeysDown[GLFW_KEY_RIGHT_CONTROL];
            io.KeyShift = io.KeysDown[GLFW_KEY_LEFT_SHIFT] || io.KeysDown[GLFW_KEY_RIGHT_SHIFT];
            io.KeyAlt = io.KeysDown[GLFW_KEY_LEFT_ALT] || io.KeysDown[GLFW_KEY_RIGHT_ALT];
            static if(_WIN32) {
                io.KeySuper = false;
            } else {
                io.KeySuper = io.KeysDown[GLFW_KEY_LEFT_SUPER] || io.KeysDown[GLFW_KEY_RIGHT_SUPER];
            }
        }catch(Exception) {}
    }

    void ImGui_ImplGlfw_CharCallback(GLFWwindow* window, uint c)
    {
        try{
            ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
            if (bd.PrevUserCallbackChar !is null && window is bd.Window)
                bd.PrevUserCallbackChar(window, c);

            ImGuiIO* io = igGetIO();
            //io.AddInputCharacter(c);
            ImGuiIO_AddInputCharacter(io, c);
        }catch(Exception) {}
    }

    void ImGui_ImplGlfw_MonitorCallback(GLFWmonitor*, int)
    {
        try{
            ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
            bd.WantUpdateMonitors = true;
        }catch(Exception) {}
    }
} // extern(C)


bool ImGui_ImplGlfw_Init(GLFWwindow* window, bool install_callbacks, GlfwClientApi client_api)
{
    ImGuiIO* io = igGetIO();
    vkassert(io.BackendPlatformUserData is null, "Already initialized a platform backend!");

    // Setup backend capabilities flags
    ImGui_ImplGlfw_Data* bd = cast(ImGui_ImplGlfw_Data*)calloc(1, ImGui_ImplGlfw_Data.sizeof);
    io.BackendPlatformUserData = cast(void*)bd;
    io.BackendPlatformName = "imgui_impl_glfw";
    io.BackendFlags |= ImGuiBackendFlags_HasMouseCursors;         // We can honor GetMouseCursor() values (optional)
    io.BackendFlags |= ImGuiBackendFlags_HasSetMousePos;          // We can honor io.WantSetMousePos requests (optional, rarely used)
    io.BackendFlags |= ImGuiBackendFlags_PlatformHasViewports;    // We can create multi-viewports on the Platform side (optional)
    static if(GLFW_HAS_MOUSE_PASSTHROUGH || (GLFW_HAS_WINDOW_HOVERED && _WIN32)) {
        io.BackendFlags |= ImGuiBackendFlags_HasMouseHoveredViewport; // We can set io.MouseHoveredViewport correctly (optional, not easy)
    }

    bd.Window = window;
    bd.Time = 0.0;
    bd.WantUpdateMonitors = true;

    // Keyboard mapping. Dear ImGui will use those indices to peek into the io.KeysDown[] array.
    io.KeyMap[ImGuiKey_Tab] = GLFW_KEY_TAB;
    io.KeyMap[ImGuiKey_LeftArrow] = GLFW_KEY_LEFT;
    io.KeyMap[ImGuiKey_RightArrow] = GLFW_KEY_RIGHT;
    io.KeyMap[ImGuiKey_UpArrow] = GLFW_KEY_UP;
    io.KeyMap[ImGuiKey_DownArrow] = GLFW_KEY_DOWN;
    io.KeyMap[ImGuiKey_PageUp] = GLFW_KEY_PAGE_UP;
    io.KeyMap[ImGuiKey_PageDown] = GLFW_KEY_PAGE_DOWN;
    io.KeyMap[ImGuiKey_Home] = GLFW_KEY_HOME;
    io.KeyMap[ImGuiKey_End] = GLFW_KEY_END;
    io.KeyMap[ImGuiKey_Insert] = GLFW_KEY_INSERT;
    io.KeyMap[ImGuiKey_Delete] = GLFW_KEY_DELETE;
    io.KeyMap[ImGuiKey_Backspace] = GLFW_KEY_BACKSPACE;
    io.KeyMap[ImGuiKey_Space] = GLFW_KEY_SPACE;
    io.KeyMap[ImGuiKey_Enter] = GLFW_KEY_ENTER;
    io.KeyMap[ImGuiKey_Escape] = GLFW_KEY_ESCAPE;
    io.KeyMap[ImGuiKey_KeypadEnter] = GLFW_KEY_KP_ENTER;
    io.KeyMap[ImGuiKey_A] = GLFW_KEY_A;
    io.KeyMap[ImGuiKey_C] = GLFW_KEY_C;
    io.KeyMap[ImGuiKey_V] = GLFW_KEY_V;
    io.KeyMap[ImGuiKey_X] = GLFW_KEY_X;
    io.KeyMap[ImGuiKey_Y] = GLFW_KEY_Y;
    io.KeyMap[ImGuiKey_Z] = GLFW_KEY_Z;

    io.SetClipboardTextFn = &ImGui_ImplGlfw_SetClipboardText;
    io.GetClipboardTextFn = &ImGui_ImplGlfw_GetClipboardText;
    io.ClipboardUserData = bd.Window;

    // Create mouse cursors
    // (By design, on X11 cursors are user configurable and some cursors may be missing. When a cursor doesn't exist,
    // GLFW will emit an error which will often be printed by the app, so we temporarily disable error reporting.
    // Missing cursors will return NULL and our _UpdateMouseCursor() function will use the Arrow cursor instead.)
    GLFWerrorfun prev_error_callback = glfwSetErrorCallback(null);
    bd.MouseCursors[ImGuiMouseCursor_Arrow] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
    bd.MouseCursors[ImGuiMouseCursor_TextInput] = glfwCreateStandardCursor(GLFW_IBEAM_CURSOR);
    bd.MouseCursors[ImGuiMouseCursor_ResizeNS] = glfwCreateStandardCursor(GLFW_VRESIZE_CURSOR);
    bd.MouseCursors[ImGuiMouseCursor_ResizeEW] = glfwCreateStandardCursor(GLFW_HRESIZE_CURSOR);
    bd.MouseCursors[ImGuiMouseCursor_Hand] = glfwCreateStandardCursor(GLFW_HAND_CURSOR);
    static if(GLFW_HAS_NEW_CURSORS) {
        bd.MouseCursors[ImGuiMouseCursor_ResizeAll] = glfwCreateStandardCursor(GLFW_RESIZE_ALL_CURSOR);
        bd.MouseCursors[ImGuiMouseCursor_ResizeNESW] = glfwCreateStandardCursor(GLFW_RESIZE_NESW_CURSOR);
        bd.MouseCursors[ImGuiMouseCursor_ResizeNWSE] = glfwCreateStandardCursor(GLFW_RESIZE_NWSE_CURSOR);
        bd.MouseCursors[ImGuiMouseCursor_NotAllowed] = glfwCreateStandardCursor(GLFW_NOT_ALLOWED_CURSOR);
    } else {
        bd.MouseCursors[ImGuiMouseCursor_ResizeAll] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
        bd.MouseCursors[ImGuiMouseCursor_ResizeNESW] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
        bd.MouseCursors[ImGuiMouseCursor_ResizeNWSE] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
        bd.MouseCursors[ImGuiMouseCursor_NotAllowed] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
    }
    glfwSetErrorCallback(prev_error_callback);

    // Chain GLFW callbacks: our callbacks will call the user's previously installed callbacks, if any.
    bd.PrevUserCallbackMousebutton = null;
    bd.PrevUserCallbackScroll = null;
    bd.PrevUserCallbackKey = null;
    bd.PrevUserCallbackChar = null;
    bd.PrevUserCallbackMonitor = null;
    if (install_callbacks)
    {
        bd.InstalledCallbacks = true;
        bd.PrevUserCallbackMousebutton = glfwSetMouseButtonCallback(window, &ImGui_ImplGlfw_MouseButtonCallback);
        bd.PrevUserCallbackScroll = glfwSetScrollCallback(window, &ImGui_ImplGlfw_ScrollCallback);
        bd.PrevUserCallbackKey = glfwSetKeyCallback(window, &ImGui_ImplGlfw_KeyCallback);
        bd.PrevUserCallbackChar = glfwSetCharCallback(window, &ImGui_ImplGlfw_CharCallback);
        bd.PrevUserCallbackMonitor = glfwSetMonitorCallback(&ImGui_ImplGlfw_MonitorCallback);
    }

    // Update monitors the first time (note: monitor callback are broken in GLFW 3.2 and earlier, see github.com/glfw/glfw/issues/784)
    ImGui_ImplGlfw_UpdateMonitors();
    glfwSetMonitorCallback(&ImGui_ImplGlfw_MonitorCallback);

    // Our mouse update function expect PlatformHandle to be filled for the main viewport
    ImGuiViewport* main_viewport = igGetMainViewport();
    main_viewport.PlatformHandle = cast(void*)bd.Window;
    static if(_WIN32) {
        main_viewport.PlatformHandleRaw = glfwGetWin32Window(bd.Window);
    }
    if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
        ImGui_ImplGlfw_InitPlatformInterface();
    }

    bd.ClientApi = client_api;
    return true;
}
public bool ImGui_ImplGlfw_InitForOpenGL(GLFWwindow* window, bool install_callbacks)
{
    return ImGui_ImplGlfw_Init(window, install_callbacks, GlfwClientApi.GlfwClientApi_OpenGL);
}

public bool ImGui_ImplGlfw_InitForVulkan(GLFWwindow* window, bool install_callbacks)
{
    return ImGui_ImplGlfw_Init(window, install_callbacks, GlfwClientApi.GlfwClientApi_Vulkan);
}

public bool ImGui_ImplGlfw_InitForOther(GLFWwindow* window, bool install_callbacks)
{
    return ImGui_ImplGlfw_Init(window, install_callbacks, GlfwClientApi.GlfwClientApi_Unknown);
}

public void ImGui_ImplGlfw_Shutdown()
{
    ImGuiIO* io = igGetIO();
    ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();

    ImGui_ImplGlfw_ShutdownPlatformInterface();

    if (bd.InstalledCallbacks)
    {
        glfwSetMouseButtonCallback(bd.Window, bd.PrevUserCallbackMousebutton);
        glfwSetScrollCallback(bd.Window, bd.PrevUserCallbackScroll);
        glfwSetKeyCallback(bd.Window, bd.PrevUserCallbackKey);
        glfwSetCharCallback(bd.Window, bd.PrevUserCallbackChar);
        glfwSetMonitorCallback(bd.PrevUserCallbackMonitor);
    }

    for (ImGuiMouseCursor cursor_n = 0; cursor_n < ImGuiMouseCursor_COUNT; cursor_n++)
        glfwDestroyCursor(bd.MouseCursors[cursor_n]);

    io.BackendPlatformName = null;
    io.BackendPlatformUserData = null;
    free(bd);
}

void ImGui_ImplGlfw_UpdateMousePosAndButtons()
{
    ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();

    // Update buttons
    ImGuiIO* io = igGetIO();
    for (int i = 0; i < io.MouseDown.length; i++)
    {
        // If a mouse press event came, always pass it as "mouse held this frame", so we don't miss click-release events that are shorter than 1 frame.
        io.MouseDown[i] = bd.MouseJustPressed[i] || glfwGetMouseButton(bd.Window, i) != 0;
        bd.MouseJustPressed[i] = false;
    }

    // Update mouse position
    ImVec2 mouse_pos_backup = io.MousePos;
    io.MousePos = ImVec2(-FLT_MAX, -FLT_MAX);
    io.MouseHoveredViewport = 0;
    ImGuiPlatformIO* platform_io = igGetPlatformIO();
    for (int n = 0; n < platform_io.Viewports.Size; n++)
    {
        ImGuiViewport* viewport = platform_io.Viewports.Data[n];
        GLFWwindow* window = cast(GLFWwindow*)viewport.PlatformHandle;
        vkassert(window !is null);

        static if(__EMSCRIPTEN__) {
            bool focused = true;
            vkassert(platform_io.Viewports.Size == 1);
        } else {
            bool focused = glfwGetWindowAttrib(window, GLFW_FOCUSED) != 0;
        }

        if (focused)
        {
            if (io.WantSetMousePos)
            {
                glfwSetCursorPos(window, cast(double)(mouse_pos_backup.x - viewport.Pos.x), cast(double)(mouse_pos_backup.y - viewport.Pos.y));
            }
            else
            {
                double mouse_x, mouse_y;
                glfwGetCursorPos(window, &mouse_x, &mouse_y);
                if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable)
                {
                    // Multi-viewport mode: mouse position in OS absolute coordinates (io.MousePos is (0,0) when the mouse is on the upper-left of the primary monitor)
                    int window_x, window_y;
                    glfwGetWindowPos(window, &window_x, &window_y);
                    io.MousePos = ImVec2(cast(float)mouse_x + window_x, cast(float)mouse_y + window_y);
                }
                else
                {
                    // Single viewport mode: mouse position in client window coordinates (io.MousePos is (0,0) when the mouse is on the upper-left corner of the app window)
                    io.MousePos = ImVec2(cast(float)mouse_x, cast(float)mouse_y);
                }
            }
            for (int i = 0; i < io.MouseDown.length; i++)
                io.MouseDown[i] |= glfwGetMouseButton(window, i) != 0;
        }

        // (Optional) When using multiple viewports: set io.MouseHoveredViewport to the viewport the OS mouse cursor is hovering.
        // Important: this information is not easy to provide and many high-level windowing library won't be able to provide it correctly, because
        // - This is _ignoring_ viewports with the ImGuiViewportFlags_NoInputs flag (pass-through windows).
        // - This is _regardless_ of whether another viewport is focused or being dragged from.
        // If ImGuiBackendFlags_HasMouseHoveredViewport is not set by the backend, imgui will ignore this field and infer the information by relying on the
        // rectangles and last focused time of every viewports it knows about. It will be unaware of other windows that may be sitting between or over your windows.
        // [GLFW] FIXME: This is currently only correct on Win32. See what we do below with the WM_NCHITTEST, missing an equivalent for other systems.
        // See https://github.com/glfw/glfw/issues/1236 if you want to help in making this a GLFW feature.
        static if(GLFW_HAS_MOUSE_PASSTHROUGH || (GLFW_HAS_WINDOW_HOVERED && _WIN32)) {
            bool window_no_input = (viewport.Flags & ImGuiViewportFlags_NoInputs) != 0;
            static if(GLFW_HAS_MOUSE_PASSTHROUGH) {
                glfwSetWindowAttrib(window, GLFW_MOUSE_PASSTHROUGH, window_no_input);
            }
            if (glfwGetWindowAttrib(window, GLFW_HOVERED) && !window_no_input) {
                io.MouseHoveredViewport = viewport.ID;
            }
        }
    }
}

void ImGui_ImplGlfw_UpdateMouseCursor()
{
    ImGuiIO* io = igGetIO();
    ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
    if ((io.ConfigFlags & ImGuiConfigFlags_NoMouseCursorChange) || glfwGetInputMode(bd.Window, GLFW_CURSOR) == GLFW_CURSOR_DISABLED)
        return;

    ImGuiMouseCursor imgui_cursor = igGetMouseCursor();
    ImGuiPlatformIO* platform_io = igGetPlatformIO();
    for (int n = 0; n < platform_io.Viewports.Size; n++)
    {
        GLFWwindow* window = cast(GLFWwindow*)platform_io.Viewports.Data[n].PlatformHandle;
        if (imgui_cursor == ImGuiMouseCursor_None || io.MouseDrawCursor)
        {
            // Hide OS mouse cursor if imgui is drawing it or if it wants no cursor
            glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);
        }
        else
        {
            // Show OS mouse cursor
            // FIXME-PLATFORM: Unfocused windows seems to fail changing the mouse cursor with GLFW 3.2, but 3.3 works here.
            glfwSetCursor(window, bd.MouseCursors[imgui_cursor] ? bd.MouseCursors[imgui_cursor] : bd.MouseCursors[ImGuiMouseCursor_Arrow]);
            glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
        }
    }
}

void ImGui_ImplGlfw_UpdateGamepads()
{
    ImGuiIO* io = igGetIO();
    //memset(io.NavInputs, 0, sizeof(io.NavInputs));
    io.NavInputs[] = 0;

    if ((io.ConfigFlags & ImGuiConfigFlags_NavEnableGamepad) == 0)
        return;

    // Update gamepad inputs
    int axes_count = 0, buttons_count = 0;
    float* axes = glfwGetJoystickAxes(GLFW_JOYSTICK_1, &axes_count);
    ubyte* buttons = glfwGetJoystickButtons(GLFW_JOYSTICK_1, &buttons_count);

    void MAP_BUTTON(int NAV_NO, int BUTTON_NO) {
        if (buttons_count > BUTTON_NO && buttons[BUTTON_NO] == GLFW_PRESS) io.NavInputs[NAV_NO] = 1.0f;
    }
    void MAP_ANALOG(int NAV_NO, int AXIS_NO, float V0, float V1) {
        float v = (axes_count > AXIS_NO) ? axes[AXIS_NO] : V0;
        v = (v - V0) / (V1 - V0);
        if (v > 1.0f) v = 1.0f;
        if (io.NavInputs[NAV_NO] < v) io.NavInputs[NAV_NO] = v;
    }

    MAP_BUTTON(ImGuiNavInput_Activate,   0);     // Cross / A
    MAP_BUTTON(ImGuiNavInput_Cancel,     1);     // Circle / B
    MAP_BUTTON(ImGuiNavInput_Menu,       2);     // Square / X
    MAP_BUTTON(ImGuiNavInput_Input,      3);     // Triangle / Y
    MAP_BUTTON(ImGuiNavInput_DpadLeft,   13);    // D-Pad Left
    MAP_BUTTON(ImGuiNavInput_DpadRight,  11);    // D-Pad Right
    MAP_BUTTON(ImGuiNavInput_DpadUp,     10);    // D-Pad Up
    MAP_BUTTON(ImGuiNavInput_DpadDown,   12);    // D-Pad Down
    MAP_BUTTON(ImGuiNavInput_FocusPrev,  4);     // L1 / LB
    MAP_BUTTON(ImGuiNavInput_FocusNext,  5);     // R1 / RB
    MAP_BUTTON(ImGuiNavInput_TweakSlow,  4);     // L1 / LB
    MAP_BUTTON(ImGuiNavInput_TweakFast,  5);     // R1 / RB
    MAP_ANALOG(ImGuiNavInput_LStickLeft, 0,  -0.3f,  -0.9f);
    MAP_ANALOG(ImGuiNavInput_LStickRight,0,  +0.3f,  +0.9f);
    MAP_ANALOG(ImGuiNavInput_LStickUp,   1,  +0.3f,  +0.9f);
    MAP_ANALOG(ImGuiNavInput_LStickDown, 1,  -0.3f,  -0.9f);
    // #undef MAP_BUTTON
    // #undef MAP_ANALOG
    if (axes_count > 0 && buttons_count > 0)
        io.BackendFlags |= ImGuiBackendFlags_HasGamepad;
    else
        io.BackendFlags &= ~ImGuiBackendFlags_HasGamepad;
}

void ImGui_ImplGlfw_UpdateMonitors()
{
    ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
    ImGuiPlatformIO* platform_io = igGetPlatformIO();
    int monitors_count = 0;
    GLFWmonitor** glfw_monitors = glfwGetMonitors(&monitors_count);
    platform_io.Monitors.resize(0);
    for (int n = 0; n < monitors_count; n++)
    {
        // These need to be pointers
        ImGuiPlatformMonitor* monitor = new ImGuiPlatformMonitor();
        int x, y;
        glfwGetMonitorPos(glfw_monitors[n], &x, &y);
        GLFWvidmode* vid_mode = cast(GLFWvidmode*)glfwGetVideoMode(glfw_monitors[n]);
        monitor.MainPos = monitor.WorkPos = ImVec2(cast(float)x, cast(float)y);
        monitor.MainSize = monitor.WorkSize = ImVec2(cast(float)vid_mode.width, cast(float)vid_mode.height);
        static if(GLFW_HAS_MONITOR_WORK_AREA) {
            int w, h;
            glfwGetMonitorWorkarea(glfw_monitors[n], &x, &y, &w, &h);
            if (w > 0 && h > 0) // Workaround a small GLFW issue reporting zero on monitor changes: https://github.com/glfw/glfw/pull/1761
            {
                monitor.WorkPos = ImVec2(cast(float)x, cast(float)y);
                monitor.WorkSize = ImVec2(cast(float)w, cast(float)h);
            }
        }
    static if(GLFW_HAS_PER_MONITOR_DPI) {
        // Warning: the validity of monitor DPI information on Windows depends on the application DPI awareness settings, which generally needs to be set in the manifest or at runtime.
        float x_scale, y_scale;
        glfwGetMonitorContentScale(glfw_monitors[n], &x_scale, &y_scale);
        monitor.DpiScale = x_scale;
    }
        platform_io.Monitors.push_back(monitor);
    }
    bd.WantUpdateMonitors = false;
}

public void ImGui_ImplGlfw_NewFrame()
{
    ImGuiIO* io = igGetIO();
    ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
    vkassert(bd !is null, "Did you call ImGui_ImplGlfw_InitForXXX()?");

    // Setup display size (every frame to accommodate for window resizing)
    int w, h;
    int display_w, display_h;
    glfwGetWindowSize(bd.Window, &w, &h);
    glfwGetFramebufferSize(bd.Window, &display_w, &display_h);
    io.DisplaySize = ImVec2(cast(float)w, cast(float)h);
    if (w > 0 && h > 0)
        io.DisplayFramebufferScale = ImVec2(cast(float)display_w / w, cast(float)display_h / h);
    if (bd.WantUpdateMonitors)
        ImGui_ImplGlfw_UpdateMonitors();

    // Setup time step
    double current_time = glfwGetTime();
    io.DeltaTime = bd.Time > 0.0 ? cast(float)(current_time - bd.Time) : cast(float)(1.0f / 60.0f);
    bd.Time = current_time;

    ImGui_ImplGlfw_UpdateMousePosAndButtons();
    ImGui_ImplGlfw_UpdateMouseCursor();

    // Update game controllers (if enabled and available)
    ImGui_ImplGlfw_UpdateGamepads();
}

//--------------------------------------------------------------------------------------------------------
// MULTI-VIEWPORT / PLATFORM INTERFACE SUPPORT
// This is an _advanced_ and _optional_ feature, allowing the backend to create and handle multiple viewports simultaneously.
// If you are new to dear imgui or creating a new binding for dear imgui, it is recommended that you completely ignore this section first..
//--------------------------------------------------------------------------------------------------------

// Helper structure we store in the void* RenderUserData field of each ImGuiViewport to easily retrieve our backend data.
struct ImGui_ImplGlfw_ViewportData
{
    GLFWwindow* Window;
    bool        WindowOwned;
    int         IgnoreWindowPosEventFrame = -1;
    int         IgnoreWindowSizeEventFrame = -1;
}

extern(C) {
nothrow:
    void ImGui_ImplGlfw_WindowCloseCallback(GLFWwindow* window)
    {
        if (ImGuiViewport* viewport = igFindViewportByPlatformHandle(window))
            viewport.PlatformRequestClose = true;
    }

    // GLFW may dispatch window pos/size events after calling glfwSetWindowPos()/glfwSetWindowSize().
    // However: depending on the platform the callback may be invoked at different time:
    // - on Windows it appears to be called within the glfwSetWindowPos()/glfwSetWindowSize() call
    // - on Linux it is queued and invoked during glfwPollEvents()
    // Because the event doesn't always fire on glfwSetWindowXXX() we use a frame counter tag to only
    // ignore recent glfwSetWindowXXX() calls.
    void ImGui_ImplGlfw_WindowPosCallback(GLFWwindow* window, int, int)
    {
        if (ImGuiViewport* viewport = igFindViewportByPlatformHandle(window))
        {
            if (ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData)
            {
                bool ignore_event = (igGetFrameCount() <= vd.IgnoreWindowPosEventFrame + 1);
                //data.IgnoreWindowPosEventFrame = -1;
                if (ignore_event)
                    return;
            }
            viewport.PlatformRequestMove = true;
        }
    }

    void ImGui_ImplGlfw_WindowSizeCallback(GLFWwindow* window, int, int)
    {
        if (ImGuiViewport* viewport = igFindViewportByPlatformHandle(window))
        {
            if (ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData)
            {
                bool ignore_event = (igGetFrameCount() <= vd.IgnoreWindowSizeEventFrame + 1);
                //data.IgnoreWindowSizeEventFrame = -1;
                if (ignore_event)
                    return;
            }
            viewport.PlatformRequestResize = true;
        }
    }

    void ImGui_ImplGlfw_CreateWindow(ImGuiViewport* viewport)
    {
        try{
            ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
            ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)calloc(1, ImGui_ImplGlfw_ViewportData.sizeof);
            viewport.PlatformUserData = vd;

            // GLFW 3.2 unfortunately always set focus on glfwCreateWindow() if GLFW_VISIBLE is set, regardless of GLFW_FOCUSED
            // With GLFW 3.3, the hint GLFW_FOCUS_ON_SHOW fixes this problem
            glfwWindowHint(GLFW_VISIBLE, false);
            glfwWindowHint(GLFW_FOCUSED, false);
            static if(GLFW_HAS_FOCUS_ON_SHOW) {
                glfwWindowHint(GLFW_FOCUS_ON_SHOW, false);
            }
            glfwWindowHint(GLFW_DECORATED, (viewport.Flags & ImGuiViewportFlags_NoDecoration) ? false : true);
            static if(GLFW_HAS_WINDOW_TOPMOST) {
                glfwWindowHint(GLFW_FLOATING, (viewport.Flags & ImGuiViewportFlags_TopMost) ? true : false);
            }
            GLFWwindow* share_window = (bd.ClientApi == GlfwClientApi.GlfwClientApi_OpenGL) ? bd.Window : null;
            vd.Window = glfwCreateWindow(cast(int)viewport.Size.x, cast(int)viewport.Size.y, "No Title Yet", null, share_window);
            vd.WindowOwned = true;
            viewport.PlatformHandle = cast(void*)vd.Window;
            static if(_WIN32) {
                viewport.PlatformHandleRaw = glfwGetWin32Window(vd.Window);
            }
            glfwSetWindowPos(vd.Window, cast(int)viewport.Pos.x, cast(int)viewport.Pos.y);

            // Install GLFW callbacks for secondary viewports
            glfwSetMouseButtonCallback(vd.Window, &ImGui_ImplGlfw_MouseButtonCallback);
            glfwSetScrollCallback(vd.Window, &ImGui_ImplGlfw_ScrollCallback);
            glfwSetKeyCallback(vd.Window, &ImGui_ImplGlfw_KeyCallback);
            glfwSetCharCallback(vd.Window, &ImGui_ImplGlfw_CharCallback);
            glfwSetWindowCloseCallback(vd.Window, &ImGui_ImplGlfw_WindowCloseCallback);
            glfwSetWindowPosCallback(vd.Window, &ImGui_ImplGlfw_WindowPosCallback);
            glfwSetWindowSizeCallback(vd.Window, &ImGui_ImplGlfw_WindowSizeCallback);
            if (bd.ClientApi == GlfwClientApi.GlfwClientApi_OpenGL)
            {
                glfwMakeContextCurrent(vd.Window);
                glfwSwapInterval(0);
            }
        }catch(Exception) {}
    }

    void ImGui_ImplGlfw_DestroyWindow(ImGuiViewport* viewport)
    {
        try{
            ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
            if (ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData)
            {
                if (vd.WindowOwned)
                {
                    static if(!GLFW_HAS_MOUSE_PASSTHROUGH && GLFW_HAS_WINDOW_HOVERED && _WIN32) {
                        HWND hwnd = cast(HWND)viewport.PlatformHandleRaw;
                        RemovePropA(hwnd, "IMGUI_VIEWPORT");
                    }

                    // Release any keys that were pressed in the window being destroyed and are still held down,
                    // because we will not receive any release events after window is destroyed.
                    for (int i = 0; i < bd.KeyOwnerWindows.length; i++)
                        if (bd.KeyOwnerWindows[i] == vd.Window)
                            ImGui_ImplGlfw_KeyCallback(vd.Window, i, 0, GLFW_RELEASE, 0); // Later params are only used for main viewport, on which this function is never called.

                    glfwDestroyWindow(vd.Window);
                }
                vd.Window = null;
                free(vd);
            }
            viewport.PlatformUserData = viewport.PlatformHandle = null;
        }catch(Exception) {}
    }


    // We have submitted https://github.com/glfw/glfw/pull/1568 to allow GLFW to support "transparent inputs".
    // In the meanwhile we implement custom per-platform workarounds here (FIXME-VIEWPORT: Implement same work-around for Linux/OSX!)
    static if(!GLFW_HAS_MOUSE_PASSTHROUGH && GLFW_HAS_WINDOW_HOVERED && _WIN32) {
        __gshared WNDPROC g_GlfwWndProc = null;
        __gshared LRESULT WndProcNoInputs(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam) {
            if (msg == WM_NCHITTEST)
            {
                // Let mouse pass-through the window. This will allow the backend to set io.MouseHoveredViewport properly (which is OPTIONAL).
                // The ImGuiViewportFlags_NoInputs flag is set while dragging a viewport, as want to detect the window behind the one we are dragging.
                // If you cannot easily access those viewport flags from your windowing/event code: you may manually synchronize its state e.g. in
                // your main loop after calling UpdatePlatformWindows(). Iterate all viewports/platform windows and pass the flag to your windowing system.
                ImGuiViewport* viewport = cast(ImGuiViewport*)GetPropA(hWnd, "IMGUI_VIEWPORT");
                if (viewport.Flags & ImGuiViewportFlags_NoInputs)
                    return HTTRANSPARENT;
            }
            return CallWindowProc(g_GlfwWndProc, hWnd, msg, wParam, lParam);
        }
    }

    void ImGui_ImplGlfw_ShowWindow(ImGuiViewport* viewport)
    {
        ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData;

        static if(_WIN32) {
            // GLFW hack: Hide icon from task bar
            HWND hwnd = cast(HWND)viewport.PlatformHandleRaw;
            if (viewport.Flags & ImGuiViewportFlags_NoTaskBarIcon)
            {
                LONG ex_style = GetWindowLong(hwnd, GWL_EXSTYLE);
                ex_style &= ~WS_EX_APPWINDOW;
                ex_style |= WS_EX_TOOLWINDOW;
                SetWindowLong(hwnd, GWL_EXSTYLE, ex_style);
            }

            // GLFW hack: install hook for WM_NCHITTEST message handler
            static if(!GLFW_HAS_MOUSE_PASSTHROUGH && GLFW_HAS_WINDOW_HOVERED && _WIN32) {
                SetPropA(hwnd, "IMGUI_VIEWPORT", viewport);
                if (g_GlfwWndProc == NULL) {
                    g_GlfwWndProc = cast(WNDPROC)GetWindowLongPtr(hwnd, GWLP_WNDPROC);
                }
                SetWindowLongPtr(hwnd, GWLP_WNDPROC, cast(LONG_PTR)&WndProcNoInputs);
            }

            static if(!GLFW_HAS_FOCUS_ON_SHOW) {
                // GLFW hack: GLFW 3.2 has a bug where glfwShowWindow() also activates/focus the window.
                // The fix was pushed to GLFW repository on 2018/01/09 and should be included in GLFW 3.3 via a GLFW_FOCUS_ON_SHOW window attribute.
                // See https://github.com/glfw/glfw/issues/1189
                // FIXME-VIEWPORT: Implement same work-around for Linux/OSX in the meanwhile.
                if (viewport.Flags & ImGuiViewportFlags_NoFocusOnAppearing)
                {
                    ShowWindow(hwnd, SW_SHOWNA);
                    return;
                }
            }
        }

        glfwShowWindow(vd.Window);
    }

    ImVec2 ImGui_ImplGlfw_GetWindowPos(ImGuiViewport* viewport)
    {
        ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData;
        int x = 0, y = 0;
        glfwGetWindowPos(vd.Window, &x, &y);
        return ImVec2(cast(float)x, cast(float)y);
    }

    void ImGui_ImplGlfw_SetWindowPos(ImGuiViewport* viewport, ImVec2 pos)
    {
        ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData;
        vd.IgnoreWindowPosEventFrame = igGetFrameCount();
        glfwSetWindowPos(vd.Window, cast(int)pos.x, cast(int)pos.y);
    }

    ImVec2 ImGui_ImplGlfw_GetWindowSize(ImGuiViewport* viewport)
    {
        ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData;
        int w = 0, h = 0;
        glfwGetWindowSize(vd.Window, &w, &h);
        return ImVec2(cast(float)w, cast(float)h);
    }

    void ImGui_ImplGlfw_SetWindowSize(ImGuiViewport* viewport, ImVec2 size)
    {
        ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData;
        static if(__APPLE__ && !GLFW_HAS_OSX_WINDOW_POS_FIX) {
            // Native OS windows are positioned from the bottom-left corner on macOS, whereas on other platforms they are
            // positioned from the upper-left corner. GLFW makes an effort to convert macOS style coordinates, however it
            // doesn't handle it when changing size. We are manually moving the window in order for changes of size to be based
            // on the upper-left corner.
            int x, y, width, height;
            glfwGetWindowPos(vd.Window, &x, &y);
            glfwGetWindowSize(vd.Window, &width, &height);
            glfwSetWindowPos(vd.Window, x, y - height + size.y);
        }
        vd.IgnoreWindowSizeEventFrame = igGetFrameCount();
        glfwSetWindowSize(vd.Window, cast(int)size.x, cast(int)size.y);
    }

    void ImGui_ImplGlfw_SetWindowTitle(ImGuiViewport* viewport, const(char)* title)
    {
        ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData;
        glfwSetWindowTitle(vd.Window, cast(immutable(char)*)title);
    }

    void ImGui_ImplGlfw_SetWindowFocus(ImGuiViewport* viewport)
    {
        static if(GLFW_HAS_FOCUS_WINDOW) {
            ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData;
            glfwFocusWindow(vd.Window);
        } else {
            // FIXME: What are the effect of not having this function? At the moment imgui doesn't actually call SetWindowFocus - we set that up ahead, will answer that question later.
        }
    }

    bool ImGui_ImplGlfw_GetWindowFocus(ImGuiViewport* viewport)
    {
        ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData;
        return glfwGetWindowAttrib(vd.Window, GLFW_FOCUSED) != 0;
    }

    bool ImGui_ImplGlfw_GetWindowMinimized(ImGuiViewport* viewport)
    {
        ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData;
        return glfwGetWindowAttrib(vd.Window, GLFW_ICONIFIED) != 0;
    }

    static if(GLFW_HAS_WINDOW_ALPHA) {
        void ImGui_ImplGlfw_SetWindowAlpha(ImGuiViewport* viewport, float alpha)
        {
            ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData;
            glfwSetWindowOpacity(vd.Window, alpha);
        }
    }

    void ImGui_ImplGlfw_RenderWindow(ImGuiViewport* viewport, void*)
    {
        ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
        ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData;
        if (bd.ClientApi == GlfwClientApi.GlfwClientApi_OpenGL)
            glfwMakeContextCurrent(vd.Window);
    }

    void ImGui_ImplGlfw_SwapBuffers(ImGuiViewport* viewport, void*)
    {
        ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
        ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData;
        if (bd.ClientApi == GlfwClientApi.GlfwClientApi_OpenGL)
        {
            glfwMakeContextCurrent(vd.Window);
            glfwSwapBuffers(vd.Window);
        }
    }
    void ImGui_ImplWin32_SetImeInputPos(ImGuiViewport* viewport, ImVec2 pos)
    {
        try{
            COMPOSITIONFORM cf = { CFS_FORCE_POSITION,
                { cast(LONG)(pos.x - viewport.Pos.x), cast(LONG)(pos.y - viewport.Pos.y) },
                { 0, 0, 0, 0 }
            };


            if (HWND hwnd = cast(HWND)viewport.PlatformHandleRaw)
                if (HIMC himc = ImmGetContext(hwnd))
                {
                    ImmSetCompositionWindow(himc, &cf);
                    ImmReleaseContext(hwnd, himc);
                }
        }catch(Exception) {}
    }
} // extern(C)

//--------------------------------------------------------------------------------------------------------
// IME (Input Method Editor) basic support for e.g. Asian language users
//--------------------------------------------------------------------------------------------------------

// We provide a Win32 implementation because this is such a common issue for IME users
// #if defined(_WIN32) && !defined(IMGUI_DISABLE_WIN32_FUNCTIONS) && !defined(IMGUI_DISABLE_WIN32_DEFAULT_IME_FUNCTIONS)
// pvmoore: Disabled this when upgrading to 1.87. Not sure if it matters
enum HAS_WIN32_IME = 0;
// #include <imm.h>
// #ifdef _MSC_VER
// #pragma comment(lib, "imm32")
pragma(lib, "imm32");
// #endif


// #else
// #define HAS_WIN32_IME   0
// #endif

//--------------------------------------------------------------------------------------------------------
// Vulkan support (the Vulkan renderer needs to call a platform-side support function to create the surface)
//--------------------------------------------------------------------------------------------------------

// Avoid including <vulkan.h> so we can build without it
static if(GLFW_HAS_VULKAN) {
    // #ifndef VULKAN_H_
    // #define VK_DEFINE_HANDLE(object) typedef struct object##_T* object;
    // #if defined(__LP64__) || defined(_WIN64) || defined(__x86_64__) || defined(_M_X64) || defined(__ia64) || defined (_M_IA64) || defined(__aarch64__) || defined(__powerpc64__)
    // #define VK_DEFINE_NON_DISPATCHABLE_HANDLE(object) typedef struct object##_T *object;
    // #else
    // #define VK_DEFINE_NON_DISPATCHABLE_HANDLE(object) typedef uint64_t object;
    // #endif

    // VK_DEFINE_HANDLE(VkInstance)
    // VK_DEFINE_NON_DISPATCHABLE_HANDLE(VkSurfaceKHR)
    // struct VkAllocationCallbacks;
    // enum VkResult { VK_RESULT_MAX_ENUM = 0x7FFFFFFF };
    // #endif // VULKAN_H_
    // extern "C" { extern GLFWAPI VkResult glfwCreateWindowSurface(VkInstance instance, GLFWwindow* window, const VkAllocationCallbacks* allocator, VkSurfaceKHR* surface); }

    extern(C) {
    nothrow:
        int ImGui_ImplGlfw_CreateVkSurface(ImGuiViewport* viewport, ImU64 vk_instance, const void* vk_allocator, ImU64* out_vk_surface)
        {
            VkResult err;
            try{
                ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
                ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)viewport.PlatformUserData;
                vkassert(bd.ClientApi == GlfwClientApi.GlfwClientApi_Vulkan);

                err = glfwCreateWindowSurface(cast(VkInstance)vk_instance, vd.Window, cast(VkAllocationCallbacks*)vk_allocator, cast(VkSurfaceKHR*)out_vk_surface);
            }catch(Exception) {}
            return cast(int)err;
        }
    }
}

void ImGui_ImplGlfw_InitPlatformInterface()
{
    // Register platform interface (will be coupled with a renderer interface)
    ImGui_ImplGlfw_Data* bd = ImGui_ImplGlfw_GetBackendData();
    ImGuiPlatformIO* platform_io = igGetPlatformIO();
    platform_io.Platform_CreateWindow = &ImGui_ImplGlfw_CreateWindow;
    platform_io.Platform_DestroyWindow = &ImGui_ImplGlfw_DestroyWindow;
    platform_io.Platform_ShowWindow = &ImGui_ImplGlfw_ShowWindow;
    platform_io.Platform_SetWindowPos = &ImGui_ImplGlfw_SetWindowPos;
    platform_io.Platform_GetWindowPos = &ImGui_ImplGlfw_GetWindowPos;
    platform_io.Platform_SetWindowSize = &ImGui_ImplGlfw_SetWindowSize;
    platform_io.Platform_GetWindowSize = &ImGui_ImplGlfw_GetWindowSize;
    platform_io.Platform_SetWindowFocus = &ImGui_ImplGlfw_SetWindowFocus;
    platform_io.Platform_GetWindowFocus = &ImGui_ImplGlfw_GetWindowFocus;
    platform_io.Platform_GetWindowMinimized = &ImGui_ImplGlfw_GetWindowMinimized;
    platform_io.Platform_SetWindowTitle = &ImGui_ImplGlfw_SetWindowTitle;
    platform_io.Platform_RenderWindow = &ImGui_ImplGlfw_RenderWindow;
    platform_io.Platform_SwapBuffers = &ImGui_ImplGlfw_SwapBuffers;

    static if(GLFW_HAS_WINDOW_ALPHA) {
        platform_io.Platform_SetWindowAlpha = &ImGui_ImplGlfw_SetWindowAlpha;
    }
    static if(GLFW_HAS_VULKAN) {
        platform_io.Platform_CreateVkSurface = &ImGui_ImplGlfw_CreateVkSurface;
    }
    static if(HAS_WIN32_IME) {
        platform_io.Platform_SetImeInputPos = &ImGui_ImplWin32_SetImeInputPos;
    }

    // Register main window handle (which is owned by the main application, not by us)
    // This is mostly for simplicity and consistency, so that our code (e.g. mouse handling etc.) can use same logic for main and secondary viewports.
    ImGuiViewport* main_viewport = igGetMainViewport();
    ImGui_ImplGlfw_ViewportData* vd = cast(ImGui_ImplGlfw_ViewportData*)calloc(1, ImGui_ImplGlfw_ViewportData.sizeof);
    vd.Window = bd.Window;
    vd.WindowOwned = false;
    main_viewport.PlatformUserData = vd;
    main_viewport.PlatformHandle = cast(void*)bd.Window;
}

void ImGui_ImplGlfw_ShutdownPlatformInterface()
{
}
