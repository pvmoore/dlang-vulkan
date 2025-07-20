module vulkan.misc.private_util;

import vulkan.all;
import vulkan.misc.public_util;

bool vk11Enabled() { return g_vulkan.vprops.apiVersion >= VK_API_VERSION_1_1; }
bool vk12Enabled() { return g_vulkan.vprops.apiVersion >= VK_API_VERSION_1_2; }
bool vk13Enabled() { return g_vulkan.vprops.apiVersion >= VK_API_VERSION_1_3; }
bool vk14Enabled() { return g_vulkan.vprops.apiVersion >= VK_API_VERSION_1_4; }

void check(VkResult r) {
    if(r != VkResult.VK_SUCCESS) {
        log("API call returned %s", r);
        flushLog();
        throw new Error("API call returned %s".format(r));
    }
}
string versionToString(uint v) {
    return "%s.%s.%s".format(
        v >> 22,
        (v >> 12) & 0x3ff,
        v & 0xfff
    );
}
string sizeToString(ulong size) {
    if(size < 20000) return "%s bytes".format(size);
    if(size < 1.MB) return "%0.2f KBs".format(cast(double)size / 1.KB);

    if(size%1.MB==0) {
        return "%s MBs".format(size / 1.MB);
    }
    return "%0.2f MBs".format(cast(double)size / 1.MB);
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
        throwIf(size%4 != 0);

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

string toAbsolutePath(string root, string path) {
    import std.path : absolutePath, dirSeparator, isRooted;

    if(!isRooted(path)) {
        path = root ~ dirSeparator ~ path;
    }

    return absolutePath(toCanonicalPath(path));
}
string toCanonicalPath(string path) {
    import std.array : replace;
    import std.path : buildNormalizedPath, dirSeparator;
    return buildNormalizedPath(path.replace("/", dirSeparator));
}
