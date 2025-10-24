module vulkan.api.cmd_barriers2;

/**
 * VK_KHR_synchronization2 barriers.
 *
 * https://docs.vulkan.org/guide/latest/extensions/VK_KHR_synchronization2.html
 *
 * Functions in this file require either Vulkan 1.3 or VK_KHR_synchronization2 to be enabled.
 *
 * Notes:
 *  [1] VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT and VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT are deprecated.
 *
 *  They are replaced with VK_PIPELINE_STAGE_2_NONE_KHR and VK_PIPELINE_STAGE_2_ALL_COMMANDS_BIT_KHR
 *  in combination with VK_ACCESS_2_NONE_KHR.
 *
 *  [2] There are 2 new image layouts:
 * 
 *  VK_IMAGE_LAYOUT_ATTACHMENT_OPTIMAL
 *  VK_IMAGE_LAYOUT_READ_ONLY_OPTIMAL
 *
 *
 */

import vulkan.all;

void pipelineBarrier(VkCommandBuffer buffer, VkDependencyInfo* dependencyInfo) {
    vkCmdPipelineBarrier2(buffer, dependencyInfo);
} 
