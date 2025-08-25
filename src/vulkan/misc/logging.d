module vulkan.misc.logging;

import vulkan.all;

private:

shared static this() {
    // Create the .logs directory if it doesn't exist
    import std.file : exists, mkdir;
    if(!exists(".logs/")) mkdir(".logs");
}
