module vulkan.frame;

import vulkan.all;

final class Frame {
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

    /** The current frame key state */
    KeyState[] keysPressed;
    KeyState[] keysReleased;

    KeyState keyPress(uint key) {
        foreach(ks; keysPressed) {
            if(ks.key == key) {
                return ks;
            }
        }
        return KeyState(KeyAction.RELEASE, KeyMod.NONE, key, 0);
    }
    bool isKeyPressed(uint key) {
        return !keysPressed.filter!(it=>it.key == key).empty();
    }
    bool isKeyReleased(uint key) {
        return !keysReleased.filter!(it=>it.key == key).empty();
    }
}

struct FrameNumber {
	ulong value;
	FrameNumber next() { return FrameNumber(value+1); }
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
