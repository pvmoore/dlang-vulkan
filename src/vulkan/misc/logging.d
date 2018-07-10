module vulkan.misc.logging;
/**
 *
 */
import logging                : log, flushLog, FileLogger;
import std.datetime.stopwatch : StopWatch;

private {
    __gshared FileLogger memoryLogger;
    __gshared FileLogger debugLogger;
    __gshared FileLogger profileLogger;

    __gshared bool verboseMemLogging    = false;
    __gshared const bool profileLogging = true;

    __gshared ulong prevProfileTime;
    __gshared StopWatch watch;
}

void logMem(A...)(lazy string fmt, lazy A args) {
	if(verboseMemLogging) memoryLogger.log(fmt, args);
}
void logDebug(A...)(lazy string fmt, lazy A args) {
	debugLogger.log(fmt, args);
}
void logTime(lazy string msg) {
    if(profileLogging) {
        ulong time     = watch.peek().total!"nsecs";
        double elapsed = (time-prevProfileTime)/1000000.0;
        prevProfileTime = time;

        string note = elapsed > 5 ? "   !" : "";
        if(elapsed>10) note ~= "!!";

        import vulkan.vulkan;
        profileLogger.log("[%u] % 24s: %.4f %s", g_vulkan.getFrameNumber(), msg, elapsed, note);
    }
}
void logTime(string msg, ulong time) {
    if(profileLogging) {
        import vulkan.vulkan;
        double elapsed = time/1000000.0;
        string note = elapsed > 5 ? "   !" : "";
        if(elapsed>10) note ~= "!!";
        profileLogger.log("[%u] % 24s: (%.4f) %s", g_vulkan.getFrameNumber(), msg, elapsed, note);
    }
}

shared static this() {
    import std.file : exists, mkdir;
    if(!exists("logs/")) mkdir("logs");
    version(assert) {
        verboseMemLogging = true;
        debugLogger  = new FileLogger("logs/debug.log");
        memoryLogger = new FileLogger("logs/memory.log");
    }
    if(profileLogging) {
        watch.start();
        profileLogger = new FileLogger("logs/profile.log");
    }
}
shared static ~this() {
    if(memoryLogger) memoryLogger.close();
    if(debugLogger) debugLogger.close();
    if(profileLogger) profileLogger.close();
}


