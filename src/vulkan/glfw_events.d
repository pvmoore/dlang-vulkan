module vulkan.glfw_events;

import vulkan.all;

//──────────────────────────────────────────────────────────────────────────────────────────────────
// GLFW event callback handlers
//──────────────────────────────────────────────────────────────────────────────────────────────────

__gshared:

struct KeyState {
    KeyAction action;
    KeyMod mod;
}
KeyState[GLFW_KEY_LAST] keyStates;

struct MouseButtonState {
    bool pressed;
    KeyMod mod;
}
MouseButtonState[GLFW_MOUSE_BUTTON_LAST] mouseButtonStates;

extern(C):
nothrow:

/**
 * GLFW error callback handler (glfwSetErrorCallback)
 *
 * Note that this is called on the thread where the error occurred
 * so don't assume we are on the main thread here.
 */
void errorCallbackHandler(int error, const(char)* description) {
    log(__FILE__, "GLFW error: %s %s", error, description.fromStringz());
}

/**
 * GLFW key callback handler (glfwSetKeyCallback)
 *
 * @param window 
 * @param key       The key (https://www.glfw.org/docs/latest/group__keys.html)
 * @param scancode  The platform specific scancode
 * @param action    GLFW_PRESS, GLFW_RELEASE or GLFW_REPEAT
 * @param mods      GLFW_MOD_SHIFT, GLFW_MOD_CONTROL, GLFW_MOD_ALT, GLFW_MOD_SUPER, GLFW_MOD_CAPS_LOCK, GLFW_MOD_NUM_LOCK 
 */
void keyCallbackHandler(GLFWwindow* window, int key, int scancode, int action, int mods) {
    //log(__FILE__, "key %s %s %s %s", key, scancode, action, mods);
    try{
        if(g_vulkan.wprops.escapeKeyClosesWindow && key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
            glfwSetWindowShouldClose(window, true);
            return;
        }

        keyStates[key] = KeyState(action.as!KeyAction, mods.as!KeyMod);

        foreach(l; g_vulkan.windowEventListeners) {
            l.keyPress(key, scancode, action.as!KeyAction, mods.as!KeyMod);
        }
	}catch(Throwable t) {
        log(__FILE__, "WARN: Exception ignored: %s", t);
    }
}

/**
 * GLFW window focus callback handler (glfwSetWindowFocusCallback)
 */
void WindowFocusCallbackHandler(GLFWwindow* window, int focussed) {
	//log(__FILE__, "window focus changed to %s FOCUS", focussed?"GAINED":"LOST");
    try{
        foreach(l; g_vulkan.windowEventListeners) {
            l.focus(focussed!=0);
        }
    }catch(Throwable t) {
        log(__FILE__, "WARN: Exception ignored: %s", t);
    }
}

/**
 * GLFW window iconify callback handler (glfwSetWindowIconifyCallback)
 */
void windowIconifyCallbackHandler(GLFWwindow* window, int iconified) {
	//log(__FILE__, "window %s", iconified ? "iconified":"non iconified");
    try{
        g_vulkan.isIconified = iconified!=0;
        foreach(l; g_vulkan.windowEventListeners) {
            l.iconify(iconified!=0);
        }
    }catch(Throwable t) {
        log(__FILE__, "WARN: Exception ignored: %s", t);
    }
}

/**
 * GLFW mouse button callback handler (glfwSetMouseButtonCallback)
 *
 * @param window 
 * @param button    The mouse button (https://www.glfw.org/docs/latest/group__buttons.html)
 * @param action    GLFW_PRESS or GLFW_RELEASE
 * @param mods      GLFW_MOD_SHIFT, GLFW_MOD_CONTROL, GLFW_MOD_ALT, GLFW_MOD_SUPER, GLFW_MOD_CAPS_LOCK, GLFW_MOD_NUM_LOCK
 */
void mouseButtonCallbackHandler(GLFWwindow* window, int button, int action, int mods) {
    //log(__FILE__, " mouse button %s %s %s", button, action, mods);
	try{
        bool pressed = (action == 1);
        double x,y;
        glfwGetCursorPos(window, &x, &y);

        mouseButtonStates[button] = MouseButtonState(pressed, mods.as!KeyMod);

        foreach(l; g_vulkan.windowEventListeners) {
            l.mouseButton(button, x.as!float, y.as!float, pressed, mods.as!KeyMod);
        }

        auto mouseState = &g_vulkan.mouseState;

        if(pressed) {
            mouseState.buttonMask |= (1 << button);
        } else {
            mouseState.buttonMask &= ~(1 << button);

            if(mouseState.isDragging) {
                mouseState.isDragging = false;
                mouseState.dragEnd = float2(x,y);
            }
        }
    }catch(Throwable t) {
        log(__FILE__, "WARN: Exception ignored: %s", t);
    }
}

/**
 * GLFW cursor position callback handler (glfwSetCursorPosCallback)
 */
void cursorPosCallbackHandler(GLFWwindow* window, double x, double y) {
	//log(__FILE__, "mouse move %s %s", x, y);
	try{
        foreach(l; g_vulkan.windowEventListeners) {
            l.mouseMoved(x.as!float, y.as!float);
        }

        auto mouseState = &g_vulkan.mouseState;

        mouseState.pos = Vector2(x,y);
        if(!mouseState.isDragging && mouseState.buttonMask == 1) {
            mouseState.isDragging = true;
            mouseState.dragStart = Vector2(x,y);
        }
	}catch(Throwable t) {
        log(__FILE__, "WARN: Exception ignored: %s", t);
    }
}

/**
 * GLFW scroll callback handler (glfwSetScrollCallback)
 */
void scrollCallbackHandler(GLFWwindow* window, double xoffset, double yoffset) {
	//log(__FILE__, "scroll event: %s %s", xoffset, yoffset);
	try{
        double x,y;
        glfwGetCursorPos(window, &x, &y);

        g_vulkan.mouseState.wheel += yoffset;

        foreach(l; g_vulkan.windowEventListeners) {
            l.mouseWheel(xoffset.as!float, yoffset.as!float, x.as!float, y.as!float);
        }
	}catch(Throwable t) {
        log(__FILE__, "WARN: Exception ignored: %s", t);
    }
}

/**
 * GLFW cursor enter callback handler (glfwSetCursorEnterCallback)
 */
void cursorEnterCallbackHandler(GLFWwindow* window, int enterred) {
	//log(__FILE__, "mouse %s", enterred ? "enterred" : "exited");
    try{
        foreach(l; g_vulkan.windowEventListeners) {
            double x,y;
            glfwGetCursorPos(window, &x, &y);
            l.mouseEnter(x,y, enterred!=0);
        }
    }catch(Throwable t) {
        log(__FILE__, "WARN: Exception ignored: %s", t);
    }
}
