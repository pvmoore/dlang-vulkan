module vulkan.Shaders;

import vulkan.all;
import std.file  : dirEntries, SpanMode, isFile, mkdirRecurse, exists;
import std.path	 : buildNormalizedPath, dirSeparator, extension, stripExtension, baseName, dirName;
import std.process : execute;
import std.array : replace;

final class Shaders {
private:
    VkDevice device;
    string srcDirectory, destDirectory;
    VkShaderModule[string] modules;
public:
    this(VkDevice device, string srcDirectory, string destDirectory) {
        this.device = device;
        this.srcDirectory = toCanonicalPath(srcDirectory) ~ dirSeparator;
        this.destDirectory = toCanonicalPath(destDirectory) ~ dirSeparator;

    }
    void destroy() {
        foreach(k,v; modules) {
            device.destroy(v);
        }
        modules = null;
    }
    VkShaderModule getModule(string filename) {
        filename = toCanonicalPath(filename);
        log("getModule(%s)", filename);

        string ext = filename.extension[1..$];

        string outname;

        if("spv"!=ext) {

            string outDir = dirName(destDirectory ~ filename) ~ "\\";
            if(!exists(outDir)) {
                //mkdirRecurse(outDir);
            }

            string src  = dirName(srcDirectory ~ filename);
            string dest = dirName(destDirectory ~ filename) ~ "\\" ~ filename.baseName.stripExtension ~ "_" ~ ext ~ ".spv";

            log("  src  = %s", src);
            log("  dest = %s", dest);

        }

        //return load(destDirectory ~ filename);
        return null;
    }
private:
    VkShaderModule load(string filename) {
        auto ptr = filename in modules;
        if(ptr) return *ptr;

        auto m = createShaderModule(device, filename);
        modules[filename] = m;
        return m;
    }
    void compile(string filename) {


        string ext  = filename.extension[1..$];
        string dir  = dirName(destDirectory ~ filename) ~ "\\";
        mkdirRecurse(dir);
        string outname = dir ~ filename.baseName.stripExtension ~ "_" ~ ext ~ ".spv";
        log("%s -> %s", filename, outname);

        // auto result = execute([
        //     "glslangValidator.exe",
        //     "-V",
        //     "-Os",
        //     "-t",
        //     "--target-env vulkan1.1",
        //     "-I/pvmoore/_assets/shaders/",
        //     "-I/pvmoore/d/libs/vulkan/shaders/vulkan/",
        //     "-o",
        //     outname,
        //     filename
        // ]);

        // if(result.status!=0) {
        //     log("error");
        // }
        // stdout.flush();
        // stderr.flush();
        // auto o = result.output.strip;
        // if(o.length>0) {
        //     log("%s", o);
        // }
    }
}