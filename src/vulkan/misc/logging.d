module vulkan.misc.logging;

import vulkan.all;

import core.thread         : Thread;
import core.sync.semaphore : Semaphore;
import std.stdio           : File;
import std.string          : toLower;
import std.file            : exists, isFile, mkdirRecurse;
import std.path            : dirName;

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
    if(!verboseEnabled()) return;
    try{
	    string name = getClassName!T;
        enqueueLogMessage("[%s] ".format(name) ~ format(fmt, args));

    }catch(Exception e) {
        // Ignore any exceptions
    }
}
void verbose(A...)(string source, string fmt, A args) nothrow {
    if(!verboseEnabled()) return;
    try{
        string name = getFileName(source);
        enqueueLogMessage("[%s] ".format(name) ~ format(fmt, args));
    }catch(Exception e) {
        // Ignore any exceptions
    }
}

void loggerShutdown(Vulkan vk) {
    if(!vk.vprops.logging.enabled) return;

    g_loggerRunning.set(false);
    g_loggerSemaphore.notify();
    g_loggerThread.join();
}

// Called by Vulkan.d on creation
void loggerInitialise(Vulkan vk) {
    if(!vk.vprops.logging.enabled) return;

    // Local copy
    auto options = vk.vprops.logging;

    // Check and update the log file name if it is not valid
    string filename = options.logFilename;
    if(!filename.isFile()) filename = ".logs/vulkan.log";

    // Create the log file directory if it doesn't exist
    auto dir = dirName(filename);
    if(!exists(dir)) mkdirRecurse(dir);

    g_logfile.open(filename, "w");

    // Convert all filters to lower case if filtering is enabled and not case sensitive
    if(options.filter && !options.filterCaseSensitive) {
        foreach(ref f; vk.vprops.logging.filters) {
            f = f.toLower();
        }
    }

    g_logQueue = makeMPSCQueue!string(4096);

    g_loggerSemaphore = new Semaphore(0);

    g_loggerThread = new Thread(&loggingLoop);
    g_loggerThread.isDaemon = true;
    g_loggerThread.name = "logger";
    g_loggerThread.start();

    // Add an initial log entry with the current date and time
    import std.datetime : Clock, Date, SysTime, TimeOfDay;
    SysTime time = Clock.currTime();
    Date date = time.as!Date;
    TimeOfDay tod = time.as!TimeOfDay();

    enqueueLogMessage("[logging] Logging started at [%s :: %s]".format(date.toString(), tod.toString()));
}

//──────────────────────────────────────────────────────────────────────────────────────────────────
private:

__gshared File g_logfile;
__gshared Atomic!bool g_loggerRunning = true;
__gshared Thread g_loggerThread;
__gshared Semaphore g_loggerSemaphore;
__gshared IQueue!string g_logQueue;

bool loggingEnabled() nothrow { return g_vulkan && g_vulkan.vprops.logging.enabled; }
bool verboseEnabled() nothrow { return loggingEnabled() && g_vulkan.vprops.logging.verbose; }
bool filterEnabled() nothrow { return loggingEnabled() && g_vulkan.vprops.logging.filter; }

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
    if(!loggingEnabled()) return;

    // Queue the log entry for asynchronous writing
    g_logQueue.push(str);
    g_loggerSemaphore.notify();
}

// g_loggerThread function
void loggingLoop() {
    string[64] entries;

    bool filterOutEntry(string entry) {
        if(filterEnabled()) {
            string cmd = g_vulkan.vprops.logging.filterCaseSensitive ? entry : entry.toLower();
            foreach(s; g_vulkan.vprops.logging.filters) {
                if(cmd.contains(s)) return true;
            }
        }
        return false;
    }

    while(g_loggerRunning.get()) {
        try{
            g_loggerSemaphore.wait();

            // Double check that we are still running after waking up
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
    if(verboseEnabled()) {
        g_logfile.write("[logging] Logger thread exiting");
    }
    g_logfile.close();
}
