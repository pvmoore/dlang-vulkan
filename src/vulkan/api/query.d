module vulkan.api.query;
/**
 *
 */
import vulkan.all;

VkQueryPool createQueryPool(
    VkDevice device,
    VkQueryType queryType,
    uint numQueries,
    VkQueryPipelineStatisticFlags queryStats = VK_QUERY_PIPELINE_STATISTIC_NONE)
{
    VkQueryPool pool;
    VkQueryPoolCreateInfo info = {
        sType: VkStructureType.VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO,
        flags: 0,
        queryType: queryType,
        queryCount: numQueries,
        pipelineStatistics: queryStats,
    };

    check(vkCreateQueryPool(
        device,
        &info,
        null,
        &pool
    ));
    return pool;
}
VkResult getQueryPoolResults(
    VkDevice device,
    VkQueryPool pool,
    uint firstQuery,
    uint queryCount,
    ulong dataSize,
    void* data,
    ulong stride,
    VkQueryResultFlags flags)
{
    return vkGetQueryPoolResults(device, pool,
        firstQuery,
        queryCount,
        dataSize,
        data,
        stride,
        flags
    );

}

