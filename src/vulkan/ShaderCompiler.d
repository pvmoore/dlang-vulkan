module vulkan.ShaderCompiler;

import vulkan.all;
import std.file  : dirEntries, SpanMode, isFile, mkdirRecurse, exists;
import std.path	 : dirSeparator, extension, stripExtension, baseName, dirName, isRooted;
import std.array : replace;

final class ShaderCompiler {
private:
    VkDevice device;
    string srcDirectory, destDirectory;
    VkShaderModule[string] shaders;
public:
    this(VkDevice device, string srcDirectory, string destDirectory) {
        this.device = device;
        this.srcDirectory = toCanonicalPath(srcDirectory) ~ dirSeparator;
        this.destDirectory = toCanonicalPath(destDirectory) ~ dirSeparator;
    }
    void destroy() {
        clear();
    }
    void clear() {
        foreach(k,v; shaders) {
            log("ShaderCompiler: Destroying %s", k);
            device.destroyShaderModule(v);
        }
        shaders = null;
    }
    /**
     *  If the filename is a .spv file then load it and create module.
     *  Otherwise compile it and write the .spv file and create module from that.
     */
    VkShaderModule getModule(string filename) {
        filename = toCanonicalPath(filename);

        string ext = filename.extension[1..$];
        string dest;

        if("spv"!=ext) {
            assert(!isRooted(filename));

            string outDir = dirName(destDirectory ~ filename) ~ dirSeparator;
            dest = toAbsolutePath(outDir, filename.baseName.stripExtension ~ "_" ~ ext ~ ".spv");

            if(dest !in shaders) {

                // Only do this in debug mode. Assume the spv files exist when in release mode
                debug {

                    string src  = toAbsolutePath(dirName(srcDirectory ~ filename), filename.baseName);

                    // Generate the out directory structure if it does not exist
                    if(!exists(outDir)) {
                        log("ShaderCompiler: Making output directory %s", outDir);
                        mkdirRecurse(outDir);
                    }

                    compile(src, dest);
                }
            }

        } else {
            dest = toAbsolutePath(destDirectory, filename);
        }

        auto ptr = dest in shaders;
        if(ptr) {
            log("ShaderCompiler: Returning cached shader %s", dest);
            return *ptr;
        }

        log("ShaderCompiler: Loading .spv from %s", dest);
        auto shader = createFromFile(dest);
        shaders[dest] = shader;

        return shader;
    }
private:
    void compile(string src, string dest) {
        import std.string : strip;
        import std.process : execute, Config;

        log("ShaderCompiler: Compiling:");
        log("  src  = %s", src);
        log("  dest = %s", dest);

        auto result = execute(
            [
                "glslangValidator.exe",
                "-V",
                "-Os",
                "-t",
                //"--target-env vulkan1.1",
                "-I/pvmoore/_assets/shaders/",
                "-I/pvmoore/d/libs/vulkan/shaders/vulkan/",
                "-o",
                dest,
                src
            ],
            null,   // env
            Config.suppressConsole
        );

        if(result.status!=0) {
            auto o = result.output.strip;
            throw new Error("Shader compilation failed %s".format(o));
        }
    }
    VkShaderModule createFromFile(string filename) {
        import std.stdio : File;
        auto f = File(filename, "rb");
        scope(exit) f.close();

        auto bytes = f.rawRead(new ubyte[f.size]);
        return createFromCode(bytes);
    }
    VkShaderModule createFromCode(ubyte[] code) {
        VkShaderModule handle;
        VkShaderModuleCreateInfo info;
        info.sType      = VkStructureType.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
        info.flags      = 0;
        info.codeSize   = code.length;    // in bytes
        info.pCode      = cast(uint*)code.ptr;

        check(vkCreateShaderModule(
            device,
            &info,
            null,
            &handle
        ));
        return handle;
    }
}