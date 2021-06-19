module vulkan.WindowEventListener;

import vulkan.all;

/**
 * Call vulkan.addWindowEventListener(...) to receive key, mouse and window events
 *
 * eg.
 * vk.addWindowEventListener(new class WindowEventListener {
 *      override void void mouseMoved(float x, float y) {}
 * }
 */
class WindowEventListener {
    void keyPress(uint keyCode, uint scanCode, KeyAction action, uint mods) {

    }
    void mouseButton(uint button, float x, float y, bool down, uint mods) {

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