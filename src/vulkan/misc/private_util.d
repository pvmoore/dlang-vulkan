module vulkan.misc.private_util;

import vulkan.all;

pragma(inline,true)
void check(VkResult r) {
    if(r != VkResult.VK_SUCCESS) {
        log("API call returned %s", r);
        flushLog();
        throw new Error("API call returned %s".format(r));
    }
}
string versionToString(uint v) {
    return "%s.%s.%s".format(
        VK_VERSION_MAJOR(v),
        VK_VERSION_MINOR(v),
        VK_VERSION_PATCH(v)
    );
}
/**
 *  auto entries = [
 *      //             constant_id, byte_offset, size
 *      VkSpecializationMapEntry(0, 0,           int.sizeof),
 *      VkSpecializationMapEntry(1, int.sizeof,  int.sizeof)
 *  ]
 *  Note that specialisation constants can
 *  only be int, float or bool (4 bytes each).
 */
auto specialisationInfo(T)(T* data) {
    VkSpecializationMapEntry[] entries;
    uint offset = 0;
    uint i      = 0;
    foreach(m; __traits(allMembers, T)) {
        uint size = __traits(getMember, T, m).sizeof;
        expect(size%4==0);

        foreach(n; 0..size/4) {
            entries ~= VkSpecializationMapEntry(
                i,
                offset,
                4
            );
            i++;
            offset += 4;
        }
    }
    VkSpecializationInfo info;
    info.mapEntryCount = cast(uint)entries.length;
    info.pMapEntries   = entries.ptr;
    info.dataSize      = T.sizeof;
    info.pData         = data;
    return info;
}