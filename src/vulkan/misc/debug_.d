module vulkan.misc.debug_;

import vulkan.all;

final class VDebug {
public:
	this(VkInstance instance, InstanceHelper helper) {
		this.instance = instance;

		// Prefer [VK_EXT_debug_utils] instead of [VK_EXT_debug_report] if available
		if(helper.hasExtension("VK_EXT_debug_utils")) {
			setupVK_EXT_debug_utils();
		} else {
			setupVK_EXT_debug_report();
		}
	}
	void destroy() {
		if(msg_callback && destroyDebugReportCallback) {
			destroyDebugReportCallback(instance, msg_callback, null);
		}
		if(debugUtilsCallback && destroyDebugUtilsMessenger) {
			destroyDebugUtilsMessenger(instance, debugUtilsCallback, null);
		}
	}
private:
	VkInstance instance;

	// VK_EXT_debug_report variables
	VkDebugReportCallbackEXT msg_callback;
	PFN_vkCreateDebugReportCallbackEXT createDebugReportCallback;
	PFN_vkDestroyDebugReportCallbackEXT destroyDebugReportCallback;
	//PFN_vkDebugReportMessageEXT debugReportMessage;

	// VK_EXT_debug_utils variables
	VkDebugUtilsMessengerEXT debugUtilsCallback;
	PFN_vkCreateDebugUtilsMessengerEXT createDebugUtilsMessenger;
	PFN_vkDestroyDebugUtilsMessengerEXT destroyDebugUtilsMessenger;
	PFN_vkSetDebugUtilsObjectNameEXT setDebugUtilsObjectName;

	/**
	 * Original debug report. Prefer debug utils instead.
	 */
	void setupVK_EXT_debug_report() {
		this.createDebugReportCallback  = instance.getProcAddr!PFN_vkCreateDebugReportCallbackEXT("vkCreateDebugReportCallbackEXT");
		this.destroyDebugReportCallback = instance.getProcAddr!PFN_vkDestroyDebugReportCallbackEXT("vkDestroyDebugReportCallbackEXT");
		
		if(createDebugReportCallback) {
			VkDebugReportCallbackCreateInfoEXT dbgCreateInfo;
			dbgCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_DEBUG_REPORT_CREATE_INFO_EXT;
			dbgCreateInfo.flags = 0
				| VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_ERROR_BIT_EXT
				| VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_WARNING_BIT_EXT
				| VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_INFORMATION_BIT_EXT
				| VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT
				//| VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_DEBUG_BIT_EXT
				;
			dbgCreateInfo.pfnCallback = &dbgFunc;
			dbgCreateInfo.pUserData = null;
			dbgCreateInfo.pNext = null;
			auto result = createDebugReportCallback(instance, &dbgCreateInfo, null, &msg_callback);
			if(result != VkResult.VK_SUCCESS) {
				log("createDebugReportCallback failed: %s".format(result));
			} else {
				log("VK_EXT_debug_report extension enabled");
			}
		}
	}
	/**
	 * Improved debug reporting.
	 * https://registry.khronos.org/vulkan/specs/latest/man/html/VK_EXT_debug_utils.html
	 */
	void setupVK_EXT_debug_utils() {
		this.createDebugUtilsMessenger = instance.getProcAddr!PFN_vkCreateDebugUtilsMessengerEXT("vkCreateDebugUtilsMessengerEXT");
		this.destroyDebugUtilsMessenger = instance.getProcAddr!PFN_vkDestroyDebugUtilsMessengerEXT("vkDestroyDebugUtilsMessengerEXT");
		this.setDebugUtilsObjectName = instance.getProcAddr!PFN_vkSetDebugUtilsObjectNameEXT("vkSetDebugUtilsObjectNameEXT");

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

		auto result = createDebugUtilsMessenger(instance, &dbgCreateInfo, null, &debugUtilsCallback);
		if(result == VkResult.VK_SUCCESS) {
			log("VK_EXT_debug_utils extension enabled");
		} else {
			log("createDebugUtilsMessenger failed: %s".format(result));
		}
	}
}

extern(Windows) {
uint dbgFunc(uint msgFlags, 
			 VkDebugReportObjectTypeEXT objType,
			 ulong srcObject, 
			 size_t location, 
			 int msgCode,
			 const(char)* pLayerPrefix,
			 const(char)* pMsg, 
			 void* pUserData) nothrow
{
    try{
        string level;
        if(msgFlags & VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_ERROR_BIT_EXT) {
            level = "ERROR";
        } else if (msgFlags & VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_WARNING_BIT_EXT) {
            level = "WARN";
        } else if(msgFlags & VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_INFORMATION_BIT_EXT) {
            level = "INFO";
        } else if(msgFlags & VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT) {
            level = "PERF";
        } else if(msgFlags & VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_DEBUG_BIT_EXT) {
            level = "DEBUG";
        } else {
            level = "?";
        }
		
        auto s = pMsg.fromStringz;
		//stderr.writef("[%s] %s", level, s);
		//flushConsole();

		log("[%s] %s", level, s);

	}catch(Exception e) {
		log("oops: %s", e);
	}
	return 0;
}

VkBool32 myVkDebugUtilsMessengerCallbackEXTFunc(VkDebugUtilsMessageSeverityFlagBitsEXT messageSeverity, 
				  								VkDebugUtilsMessageTypeFlagsEXT messageTypes, 
				  								VkDebugUtilsMessengerCallbackDataEXT* pCallbackData, 
				  								void* pUserData) nothrow
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
