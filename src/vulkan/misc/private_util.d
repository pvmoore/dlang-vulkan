module vulkan.misc.private_util;

import vulkan.all;
import vulkan.misc.public_util;

bool vk11Enabled() { return g_vulkan.vprops.apiVersion >= VK_API_VERSION_1_1; }
bool vk12Enabled() { return g_vulkan.vprops.apiVersion >= VK_API_VERSION_1_2; }
bool vk13Enabled() { return g_vulkan.vprops.apiVersion >= VK_API_VERSION_1_3; }
bool vk14Enabled() { return g_vulkan.vprops.apiVersion >= VK_API_VERSION_1_4; }

void check(VkResult r, string file = __FILE__) {
    if(r != VkResult.VK_SUCCESS) {
        log(file, "API call returned %s", r);
        throwIf(true, "API call returned %s", r);
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

/** 
 *  Returns true if T is a struct with sType and pNext members.
 */
template isVulkanStruct(T) {
    const bool isVulkanStruct = 
        is(T == struct) && 
        __traits(hasMember, T, "sType") && 
        __traits(hasMember, T, "pNext");
}

/** 
 * Find the StructureType for a given Vulkan struct.
 */
VkStructureType getStructureType(T)() {

    string name = T.stringof;
    string buf = "VK_STRUCTURE_TYPE";

    // Assume name is camel case
    if(name.startsWith("Vk")) name = name[2..$];

    const atomsAZ = [
        "ASTC", "HDR", "D3D12", "Win32", "AABB", "Uint8",
        "Int8", "Float16", "Int64", "RGBA10X6", "H264", "H265"
    ];
    const atoms09 = ["2D", "3D", "8Bit", "16Bit"];

    for(int i=0; i<name.length; ) {
        char peek(int offset) {
            return i+offset >= name.length ? '\0' : name[i+offset];
        }
        bool isKw(string s, int offset) {
            foreach(j; 0..s.length.as!int) {
                if(peek(j+offset)!=s[j]) return false;
            }
            return true;
        }
        bool isUpper(char c) { return c >= 'A' && c <= 'Z'; }
        bool isDigit(char c) { return c >= '0' && c <= '9'; }

        string findAZKeyword() {
            return atomsAZ.filter!(it=>isKw(it, -1)).frontOrElse!string(null);
        }
        string find09Keyword() {
            return atoms09.filter!(it=>isKw(it, -1)).frontOrElse!string(null);
        }

        auto ch = name[i];

        if(isUpper(ch)) {
            buf ~= "_" ~ ch;
            i++;

            if(name[i-1] == 'W' && i+7 < name.length && "Scaling"==name[i..i+7]) {
                // _W_SCALING

            } else if(auto kw = findAZKeyword()) {
                auto count = kw.length-1;
                buf ~= name[i..i+count];
                i += count;

            } else if(isUpper(peek(0))) {
                while(isUpper(peek(0))) {
                    buf ~= peek(0);
                    i++;
                    if(!isUpper(peek(1)) && peek(1) != 0) {
                        break;
                    }
                }
            }
        } else if(isDigit(ch)) {
            buf ~= "_" ~ ch;
            i++;

            if(i>7 && name[i-7..i-1] == "Vulkan") {
                // VULKAN_i_j
                buf ~= "_" ~ peek(0);
                i++;

            } else if(auto kw = find09Keyword()) {
                auto count = kw.length-1;
                buf ~= name[i..i+count];
                i += count;

            } else if(isDigit(peek(0))) {
                while(isDigit(peek(0))) {
                    buf ~= peek(0);
                    i++;
                }
            }
        } else {
            i++;
            buf ~= ch;
        }
    }

    import std.conv   : to;
    import std.string : toUpper;

    return buf.toUpper().to!VkStructureType;
}
