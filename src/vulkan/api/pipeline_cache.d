module vulkan.api.pipeline_cache;

import vulkan.all;
import std.file : exists, read, mkdir, write;

VkPipelineCache createPipelineCache(VkDevice device) {

    void[] cacheData = readCacheData();

    // VK_PIPELINE_CACHE_CREATE_EXTERNALLY_SYNCHRONIZED_BIT = 0x00000001,
    // VK_PIPELINE_CACHE_CREATE_INTERNALLY_SYNCHRONIZED_MERGE_BIT_KHR = 0x00000008,

    VkPipelineCacheCreateInfo info = {
        sType: VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO,
        flags: 0,
        initialDataSize: cacheData.length,
        pInitialData: cacheData.ptr
    };

    VkPipelineCache cache;
    check(vkCreatePipelineCache(
        device,
        &info,
        null,
        &cache
    ));

    return cache;
}

void destroyPipelineCache(VkDevice device, VkPipelineCache cache) {
    writeCacheData(device, cache);
    vkDestroyPipelineCache(device, cache, null);
}

private:

enum CACHE_FILE      = CACHE_DIRECTORY ~ "pipeline-cache";
enum CACHE_DIRECTORY = ".cache/";

void[] readCacheData() {
    verbose(__FILE__, "Reading pipeline cache data");
    if(!exists(CACHE_DIRECTORY)) {
        mkdir(CACHE_DIRECTORY);
        return null;
    }
    if(!exists(CACHE_FILE)) return null;

    void[] cacheData = read(CACHE_FILE);
    verbose(__FILE__, "Pipeline cache found of size %s", cacheData.length);
    return cacheData;
}
void writeCacheData(VkDevice device, VkPipelineCache cache) {
    ulong size;
    check(vkGetPipelineCacheData(device, cache, &size, null)); 
    verbose(__FILE__, "Writing pipeline cache size = %s", size);
    if(size == 0) return;

    void[] cacheData = new void[size];
    check(vkGetPipelineCacheData(device, cache, &size, cacheData.ptr));

    write(CACHE_FILE, cacheData);
}
