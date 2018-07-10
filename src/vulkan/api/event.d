module vulkan.api.event;
/**
 * https://www.khronos.org/registry/vulkan/specs/1.0/man/html/vkCreateEvent.html
 * https://www.khronos.org/registry/vulkan/specs/1.0/man/html/VkEventCreateInfo.html
 */
import vulkan.all;

/*
vkCreateEvent
vkDestroyEvent
vkGetEventStatus
vkSetEvent
vkResetEvent
*/

VkEvent createEvent(VkDevice device) {
    VkEvent event;
    VkEventCreateInfo info;
    info.sType = VkStructureType.VK_STRUCTURE_TYPE_EVENT_CREATE_INFO;
    info.flags = 0;

    check(vkCreateEvent(
        device,
        &info,
        null,
        &event
    ));

    return event;
}
void destroy(VkDevice device, VkEvent event) {
    vkDestroyEvent(device, event, null);
}
/**
 *  On success, returns VK_EVENT_SET or VK_EVENT_RESET.
 */
VkResult getStatus(VkDevice device, VkEvent event) {
    return vkGetEventStatus(device, event);
}
/// Sets event to signalled
void signal(VkDevice device, VkEvent event) {
    check(vkSetEvent(device, event));
}
/// Sets event to unsignalled
void unsignal(VkDevice device, VkEvent event) {
    check(vkResetEvent(device, event));
}