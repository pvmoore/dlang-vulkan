module vulkan.api.debug_utils;

/**
 * https://registry.khronos.org/vulkan/specs/latest/man/html/VK_EXT_debug_utils.html
 *
 */

import vulkan.all;

void initialise_VK_EXT_debug_utils(VkInstance instance, InstanceHelper helper) {
    if(helper.hasExtension("VK_EXT_debug_utils")) {
        populateFunctions(instance);
        setMessengerCallback(instance);
    } else {
        log("[WARN] VK_EXT_debug_utils is not available");
    }
} 
void destroy_VK_EXT_debug_utils(VkInstance instance) {
    if(debugUtilsCallback && vkDestroyDebugUtilsMessengerEXT) {
        vkDestroyDebugUtilsMessengerEXT(instance, debugUtilsCallback, null);
    }
}

/**
 * Set a pretty name for a Vk object handle in the debug log.
 */
void setObjectDebugName(VkObjectType T)(VkDevice device, void* handle, string name) {
    if(!vkSetDebugUtilsObjectNameEXT) return;

    VkDebugUtilsObjectNameInfoEXT nameInfo = {
        sType: VkStructureType.VK_STRUCTURE_TYPE_DEBUG_UTILS_OBJECT_NAME_INFO_EXT,
        pNext: null,
        objectType: T,
        objectHandle: handle.as!ulong,
        pObjectName: toStringz(name)
    };
    auto result = vkSetDebugUtilsObjectNameEXT(device, &nameInfo);
    if(result != VkResult.VK_SUCCESS) {
        log("[WARN] Failed to set debug name for object %s: %s", name, result);
    }
}

//──────────────────────────────────────────────────────────────────────────────────────────────────
private:

void populateFunctions(VkInstance instance) {
    vkCreateDebugUtilsMessengerEXT = instance.getProcAddr!PFN_vkCreateDebugUtilsMessengerEXT("vkCreateDebugUtilsMessengerEXT");
	vkDestroyDebugUtilsMessengerEXT = instance.getProcAddr!PFN_vkDestroyDebugUtilsMessengerEXT("vkDestroyDebugUtilsMessengerEXT");
	
    vkCmdBeginDebugUtilsLabelEXT = instance.getProcAddr!PFN_vkCmdBeginDebugUtilsLabelEXT("vkCmdBeginDebugUtilsLabelEXT");
    vkCmdEndDebugUtilsLabelEXT = instance.getProcAddr!PFN_vkCmdEndDebugUtilsLabelEXT("vkCmdEndDebugUtilsLabelEXT");
    vkCmdInsertDebugUtilsLabelEXT = instance.getProcAddr!PFN_vkCmdInsertDebugUtilsLabelEXT("vkCmdInsertDebugUtilsLabelEXT");

    vkQueueBeginDebugUtilsLabelEXT = instance.getProcAddr!PFN_vkQueueBeginDebugUtilsLabelEXT("vkQueueBeginDebugUtilsLabelEXT");
    vkQueueEndDebugUtilsLabelEXT = instance.getProcAddr!PFN_vkQueueEndDebugUtilsLabelEXT("vkQueueEndDebugUtilsLabelEXT");
    vkQueueInsertDebugUtilsLabelEXT = instance.getProcAddr!PFN_vkQueueInsertDebugUtilsLabelEXT("vkQueueInsertDebugUtilsLabelEXT");
    
    vkSetDebugUtilsObjectNameEXT = instance.getProcAddr!PFN_vkSetDebugUtilsObjectNameEXT("vkSetDebugUtilsObjectNameEXT");
    vkSetDebugUtilsObjectTagEXT = instance.getProcAddr!PFN_vkSetDebugUtilsObjectTagEXT("vkSetDebugUtilsObjectTagEXT");
    vkSubmitDebugUtilsMessageEXT = instance.getProcAddr!PFN_vkSubmitDebugUtilsMessageEXT("vkSubmitDebugUtilsMessageEXT");
}
void setMessengerCallback(VkInstance instance) {
    VkDebugUtilsMessengerCreateInfoEXT dbgCreateInfo = {
        sType: VkStructureType.VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
        pNext: null,
        flags: 0,
        messageSeverity: 0
            //| VkDebugUtilsMessageSeverityFlagBitsEXT.VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT
            | VkDebugUtilsMessageSeverityFlagBitsEXT.VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT
            | VkDebugUtilsMessageSeverityFlagBitsEXT.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT
            | VkDebugUtilsMessageSeverityFlagBitsEXT.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT
            ,
        messageType: 0
            | VkDebugUtilsMessageTypeFlagBitsEXT.VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT
            | VkDebugUtilsMessageTypeFlagBitsEXT.VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT
            | VkDebugUtilsMessageTypeFlagBitsEXT.VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT
            | VkDebugUtilsMessageTypeFlagBitsEXT.VK_DEBUG_UTILS_MESSAGE_TYPE_DEVICE_ADDRESS_BINDING_BIT_EXT
            ,
        pfnUserCallback: &myVkDebugUtilsMessengerCallbackEXTFunc,
        pUserData: null
    };

    auto result = vkCreateDebugUtilsMessengerEXT(instance, &dbgCreateInfo, null, &debugUtilsCallback);
    if(result == VkResult.VK_SUCCESS) {
        log("VK_EXT_debug_utils extension enabled");
    } else {
        log("[WARN] Failed to enable VK_EXT_debug_utils extension: %s".format(result));
    }
}

__gshared:

VkDebugUtilsMessengerEXT debugUtilsCallback;
PFN_vkCreateDebugUtilsMessengerEXT vkCreateDebugUtilsMessengerEXT;
PFN_vkDestroyDebugUtilsMessengerEXT vkDestroyDebugUtilsMessengerEXT;

PFN_vkCmdBeginDebugUtilsLabelEXT vkCmdBeginDebugUtilsLabelEXT;
PFN_vkCmdEndDebugUtilsLabelEXT vkCmdEndDebugUtilsLabelEXT;
PFN_vkCmdInsertDebugUtilsLabelEXT vkCmdInsertDebugUtilsLabelEXT;
PFN_vkQueueBeginDebugUtilsLabelEXT vkQueueBeginDebugUtilsLabelEXT;
PFN_vkQueueEndDebugUtilsLabelEXT vkQueueEndDebugUtilsLabelEXT;
PFN_vkQueueInsertDebugUtilsLabelEXT vkQueueInsertDebugUtilsLabelEXT;

PFN_vkSetDebugUtilsObjectNameEXT vkSetDebugUtilsObjectNameEXT;
PFN_vkSetDebugUtilsObjectTagEXT vkSetDebugUtilsObjectTagEXT;
PFN_vkSubmitDebugUtilsMessageEXT vkSubmitDebugUtilsMessageEXT;

//──────────────────────────────────────────────────────────────────────────────────────────────────
extern(Windows) {
nothrow:

VkBool32 myVkDebugUtilsMessengerCallbackEXTFunc(VkDebugUtilsMessageSeverityFlagBitsEXT messageSeverity, 
				  								VkDebugUtilsMessageTypeFlagsEXT messageTypes, 
				  								VkDebugUtilsMessengerCallbackDataEXT* pCallbackData, 
				  								void* pUserData)
{
	try{
		string level;
		switch(messageSeverity) with(VkDebugUtilsMessageSeverityFlagBitsEXT) {
			case VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT: level = "VERBOSE"; break;
			case VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT: level = "INFO"; break;
			case VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT: level = "WARN"; break;
			case VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT:	level = "ERROR"; break;
			default: level = "?"; break;
		}
		string type;
		switch(messageTypes) with(VkDebugUtilsMessageTypeFlagBitsEXT) {
			case VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT: type = "GENERAL"; break;
			case VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT: type = "VALIDATION"; break;
			case VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT: type = "PERFORMANCE"; break;
			case VK_DEBUG_UTILS_MESSAGE_TYPE_DEVICE_ADDRESS_BINDING_BIT_EXT: type = "DEVICE_ADDRESS_BINDING"; break;
			default: type = "?"; break;
		}
		auto s = pCallbackData.pMessage.fromStringz;
		log("[%s] [%s] %s", level, type, s);
	}catch(Exception e) {
		log("oops: %s", e);
	}
	return 0;
}
}	// extern(Windows)
