module vulkan.WindowEventListener;

import vulkan.all;

interface IWindowEventListener {
    void keyPress(uint keyCode, uint scanCode, KeyAction action, KeyMod mods);
    void mouseButton(uint button, float x, float y, bool down, KeyMod mods);
    void mouseDoubleClick(uint button, float x, float y, KeyMod mods);
    void mouseMoved(float x, float y);
    void mouseWheel(float xdelta, float ydelta, float x, float y);
    void mouseEnter(float x, float y, bool enterred);
    void iconify(bool flag);
    void focus(bool flag);
}

/**
 * Call vulkan.addWindowEventListener(...) to receive key, mouse and window events
 *
 * eg.
 * vk.addWindowEventListener(new class WindowEventListener {
 *      override void mouseMoved(float x, float y) {}
 * });
 */
class WindowEventListener : IWindowEventListener {

    void keyPress(uint keyCode, uint scanCode, KeyAction action, KeyMod mods) {

    }
    void mouseButton(uint button, float x, float y, bool down, KeyMod mods) {

    }
    void mouseDoubleClick(uint button, float x, float y, KeyMod mods) {

    }
    void mouseMoved(float x, float y) {

    }
    void mouseWheel(float xdelta, float ydelta, float x, float y) {

    }
    void mouseEnter(float x, float y, bool enterred) {

    }
    void iconify(bool flag) {

    }
    void focus(bool flag) {

    }
}
