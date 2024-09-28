module vulkan.helpers.ShaderCompiler;

import vulkan.all;
import std.file  : dirEntries, SpanMode, isFile, mkdirRecurse, exists;
import std.path	 : dirSeparator, extension, stripExtension, baseName, dirName, isRooted;
import std.array : replace;

final class ShaderCompiler {
private:
    VkDevice device;
    string[] srcDirectories;
    string destDirectory;
    string spirvVersion;
    VkShaderModule[string] shaders;
public:
    this(VkDevice device, VulkanProperties vprops) {
        this.device = device;
        foreach(s; vprops.shaderSrcDirectories) {
            this.srcDirectories ~= toCanonicalPath(s) ~ dirSeparator;
        }
        this.destDirectory = toCanonicalPath(vprops.shaderDestDirectory) ~ dirSeparator;
        this.spirvVersion = vprops.shaderSpirvVersion;
    }
    void destroy() {
        clear();
    }
    void clear() {
        foreach(k,v; shaders) {
            device.destroyShaderModule(v);
        }
        this.log("Destroyed %s shader modules", shaders.length);
        shaders = null;
    }
    /**
     *  If the filename is a .spv file then load it and create module.
     *  Otherwise compile it and write the .spv file and create module from that.
     */
    VkShaderModule getModule(string filename, bool assumeSpvExists = false) {
        filename = toCanonicalPath(filename);

        string ext = filename.extension[1..$];
        string dest;

        if("spv"!=ext) {
            throwIf(isRooted(filename));

            string outDir = dirName(destDirectory ~ filename) ~ dirSeparator;
            dest = toAbsolutePath(outDir, filename.baseName.stripExtension ~ "_" ~ ext ~ ".spv");

            if(dest !in shaders) {

                // Assume the spv files exist?
                if(!assumeSpvExists) {

                    string srcDirectory = findSourceDirectory(filename);
                    string src  = toAbsolutePath(dirName(srcDirectory ~ filename), filename.baseName);

                    // Generate the out directory structure if it does not exist
                    if(!exists(outDir)) {
                        this.log("Making output directory %s", outDir);
                        mkdirRecurse(outDir);
                    }

                    compile(src, dest);
                }
            }

        } else {
            throwIf(true, "boo");
            // filename is a compiled shader
            dest = toAbsolutePath(destDirectory, filename);
        }

        auto ptr = dest in shaders;
        if(ptr) {
            this.log("Returning cached shader %s", dest);
            return *ptr;
        }

        this.log("Loading .spv from %s", dest);
        auto shader = createFromFile(dest);
        shaders[dest] = shader;

        return shader;
    }
private:
    void compile(string src, string dest) {
        import std.string : strip;
        import std.process : execute, Config;

        this.log("Compiling:");
        this.log("  spirv = %s", spirvVersion);
        this.log("  src   = %s", src);
        this.log("  dest  = %s", dest);

        // Include directories
        string includes;
        foreach(s; srcDirectories) {
            includes ~= "-I" ~ s;
            this.log("  inc   = %s", s);
        }

        auto args = [
            "glslangValidator.exe",
            "-V",
            "--target-env", "spirv" ~ spirvVersion,
            "-Os",
            "-t",
            //"-q", // prints out some debug info. Useful for debugging UBO offsets for example
            "--enhanced-msgs",
        ] ~ includes ~ [
            "-o",
            dest,
            src
        ];

        auto result = execute(
            args,
            null,   // env
            Config.suppressConsole
        );

        if(result.status!=0) {
            auto o = result.output.strip;
            throw new Error("Shader compilation failed %s".format(o));
        } 

        //auto o = result.output.strip;
        //this.log("%s", o);
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
    string findSourceDirectory(string filename) {
        foreach(s; srcDirectories) {
            string path = s ~ filename;
            if(exists(path)) return s;
        }
        throwIf(true, "Shader source not found '%s'", filename);
        assert(false);
    }
}
