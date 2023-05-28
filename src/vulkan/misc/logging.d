module vulkan.misc.logging;

private:

shared static this() {
    import std.file : exists, mkdir;
    if(!exists(".logs/")) mkdir(".logs");
}
