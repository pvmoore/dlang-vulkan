module vulkan.misc.logging;

import vulkan.all;

import core.thread         : Thread;
import core.sync.semaphore : Semaphore;
import std.stdio           : File;
import std.string          : toLower;
import std.file            : exists, mkdirRecurse;
import std.path            : dirName;

/**
 * Set g_loggingEnabled to false to disable all logging.
 *
 * Set g_verboseEnabled to false to disable verbose logging.
 * 
 * If g_filterEnabled is true then any log entry containing any of the strings in FILTERS
 * will be discarded.
 *
 * Set g_logfileName to change the log file location (default is ".logs/vulkan.log")
 */
private __gshared {

    // Global logging enable. 
    // If unknown then it will be enabled in debug mode, disabled in release mode.
    bool3 g_loggingEnabled = bool3.unknown();

    // If true and g_loggingEnabled is true then verbose() calls will be logged 
    // otherwise they will be ignored.
    bool g_verboseEnabled = true;

    // Drop log entries containing any of the following strings
    bool g_filterEnabled = false;

    string g_logfileName = ".logs/vulkan.log";

    bool g_filterCaseSensitive = true;
    string[] FILTERS = [
        // "[Swapchain]",
        // "[DeviceMemory]",
        // "[DeviceBuffer]",
        // "[DeviceImage]",
        // "[ShaderCompiler]",
        // "[Descriptors]",
        // "[GPUData]",
        // "[Fonts]",
    ];
}

//──────────────────────────────────────────────────────────────────────────────────────────────────
public:

void log(T, A...)(T, string fmt, A args) nothrow if(is(T==class) || is(T==interface)) {
    try{
	    string name = getClassName!T;

        enqueueLogMessage("[%s] ".format(name) ~ format(fmt, args));

    }catch(Exception e) {
        // Ignore any exceptions
    }
}
void log(A...)(string source, string fmt, A args) nothrow {
    try{
        string name = getFileName(source);
        enqueueLogMessage("[%s]".format(name) ~ format(fmt, args));
    }catch(Exception e) {
        // Ignore any exceptions
    }
}
void verbose(T, A...)(T, string fmt, A args) nothrow if(is(T==class) || is(T==interface)) {
    if(!g_verboseEnabled) return;
    try{
	    string name = getClassName!T;
        enqueueLogMessage("[%s] ".format(name) ~ format(fmt, args));

    }catch(Exception e) {
        // Ignore any exceptions
    }
}
void verbose(A...)(string source, string fmt, A args) nothrow {
    if(!g_verboseEnabled) return;
    try{
        string name = getFileName(source);
        enqueueLogMessage("[%s] ".format(name) ~ format(fmt, args));
    }catch(Exception e) {
        // Ignore any exceptions
    }
}

void loggerShutdown() {
    g_loggerRunning.set(false);
    g_loggerSemaphore.notify();
    g_loggerThread.join();
}

//──────────────────────────────────────────────────────────────────────────────────────────────────
private:

__gshared File g_logfile;
__gshared Atomic!bool g_loggerRunning = true;
__gshared Thread g_loggerThread;
__gshared Semaphore g_loggerSemaphore;
__gshared IQueue!string g_logQueue;

shared static this() {
    // Enable global logging if we are in debug mode and logging is not explicitly disabled
    debug {
        if(g_loggingEnabled.isUnknown()) {
            g_loggingEnabled.setTrue();
        }
    }

    if(g_loggingEnabled) {
        // Create the log file directory if it doesn't exist
        auto dir = dirName(g_logfileName);
        if(!exists(dir)) mkdirRecurse(dir);

        g_logfile.open(g_logfileName, "w");

        g_logQueue = makeMPSCQueue!string(4096);

        g_loggerSemaphore = new Semaphore(0);

        g_loggerThread = new Thread(&loggingLoop);
        g_loggerThread.isDaemon = true;
        g_loggerThread.name = "logger";
        g_loggerThread.start();

        if(g_filterEnabled && !g_filterCaseSensitive) {
            foreach(ref f; FILTERS) {
                f = f.toLower();
            }
        }

        import std.datetime : Clock, Date, SysTime, TimeOfDay;
        SysTime time = Clock.currTime();
        Date date = time.as!Date;
        TimeOfDay tod = time.as!TimeOfDay();

        enqueueLogMessage("[logging] Logging started at [%s :: %s]".format(date.toString(), tod.toString()));
    }
}

string getClassName(T)() {
    import std.string : indexOf;
    // Get the class/interface name
    // Remove template types
    static if(T.stringof.indexOf('!') != -1) {
        string name = T.stringof[0..T.stringof.indexOf('!')];
    } else {
        string name = T.stringof;
    }
    return name;
}
string getFileName(string s) {
    import std.path : baseName, stripExtension;
    return s.baseName().stripExtension();
}

void enqueueLogMessage(string str) {
    if(!g_loggingEnabled) return;

    // Queue the log entry for asynchronous writing
    g_logQueue.push(str);
    g_loggerSemaphore.notify();
}

// g_loggerThread function
void loggingLoop() {
    string[64] entries;

    bool filterOutEntry(string entry) {
        if(g_filterEnabled) {
            string cmd = g_filterCaseSensitive ? entry : entry.toLower();
            foreach(s; FILTERS) {
                if(cmd.contains(s)) return true;
            }
        }
        return false;
    }

    while(g_loggerRunning.get()) {
        try{
            g_loggerSemaphore.wait();
            if(!g_loggerRunning.get()) break;

            // Fetch up to 64 log entries, join them together and write them out
            auto count = g_logQueue.drain(entries);
            if(count > 0) {

                string str;

                foreach(i; 0..count) {
                    if(!filterOutEntry(entries[i])) {
                        str ~= entries[i] ~ "\n";
                    }
                }

                g_logfile.write(str);
                g_logfile.flush();
            }
        }catch(Exception e) {
            // Ignore exceptions
        }
    }
    if(g_verboseEnabled) {
        g_logfile.write("[logging] Logger thread exiting]]");
    }
    g_logfile.close();
}
