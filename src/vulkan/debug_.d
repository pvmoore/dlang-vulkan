module vulkan.debug_;

import vulkan.all;
import std.stdio : writef, stderr;

extern(Windows)
uint dbgFunc(uint msgFlags, VkDebugReportObjectTypeEXT objType,
			 ulong srcObject, size_t location, int msgCode,
			 const(char)* pLayerPrefix,
			 const(char)* pMsg, void* pUserData) nothrow
{
    try{
        string level;
        bool toMainLog = false;
        if(msgFlags & VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_ERROR_BIT_EXT) {
            level = "ERROR";
            toMainLog = true;
        } else if (msgFlags & VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_WARNING_BIT_EXT) {
            level = "WARN";
            toMainLog = true;
        } else if(msgFlags & VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_INFORMATION_BIT_EXT) {
            level = "INFO";
        } else if(msgFlags & VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT) {
            level = "PERF";
            toMainLog = true;
        } else if(msgFlags & VkDebugReportFlagBitsEXT.VK_DEBUG_REPORT_DEBUG_BIT_EXT) {
            level = "DEBUG";
        } else {
            level = "?";
        }
        auto s = pMsg.fromStringz;
        logDebug("[%s] %s", level, s);
        if(toMainLog) {
            //stderr.writef("[%s] %s", level, s);
            //flushConsole();

			log("[%s] %s", level, s);
        }
	}catch(Exception e) {
		log("oops: %s", e);
	}
	return 0;
}

final class VDebug {
	VkInstance instance;
	VkDebugReportCallbackEXT msg_callback;
	PFN_vkCreateDebugReportCallbackEXT createDebugReportCallback;
	PFN_vkDestroyDebugReportCallbackEXT destroyDebugReportCallback;
	//PFN_vkDebugReportMessageEXT debugReportMessage;

	this(VkInstance instance) {
		this.instance = instance;
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
	void destroy() {
		if(msg_callback && destroyDebugReportCallback) {
			destroyDebugReportCallback(instance, msg_callback, null);
		}
	}
}