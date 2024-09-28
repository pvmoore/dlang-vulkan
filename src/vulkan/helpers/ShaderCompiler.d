module vulkan.helpers.ShaderCompiler;

import vulkan.all;
import std.datetime : SysTime;
import std.file     : dirEntries, SpanMode, isFile, mkdirRecurse, exists, timeLastModified;
import std.path	    : dirSeparator, extension, stripExtension, baseName, dirName, isRooted;
import std.array    : replace;

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
     *  Fetch the shader module identified by the filename source. This will compile the shader if the 
     *  src file is more recent than any previously compiled version. Also it will be cached once loaded.
     *  Assumes filename is relative to one of the shaderSrcDirectories specified in the VulkanProperties
     */
    VkShaderModule getModule(string filename) {
        filename = toCanonicalPath(filename);

        string ext = filename.extension[1..$];
        string destDir = dirName(destDirectory ~ filename) ~ dirSeparator;
        string absDest = toAbsolutePath(destDir, filename.baseName.stripExtension ~ "_" ~ ext ~ ".spv");

        throwIf("spv"==ext, "Expecting a shader src file");
        throwIf(isRooted(filename), "Expecting a relative path");

        auto ptr = absDest in shaders;

        if(!ptr) {
            string srcDir = findSourceDirectory(filename);
            string absSrc = toAbsolutePath(dirName(srcDir ~ filename), filename.baseName);

            // Generate the destination directory structure if it does not exist
            if(!exists(destDir)) {
                this.log("Making destination directory %s", destDir);
                mkdirRecurse(destDir);
            }

            // Recompile the source unless the spv file already exists and is more recently modified
            if(!destFileIsUpToDate(absSrc, absDest)) {
                compile(absSrc, absDest);
            } else {
                this.log("Not recompiling because spv file is up to date");
            }

            this.log("Loading .spv from %s", absDest);
            auto shader = createFromFile(absDest);
            shaders[absDest] = shader;

            return shader;

        } else {
            this.log("Returning cached shader %s", absDest);
            return *ptr;
        }
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
    bool destFileIsUpToDate(string srcFile, string destFile) {
        if(!exists(destFile)) return false;

        SysTime destTime = timeLastModified(destFile);
        SysTime srcTime = timeLastModified(srcFile);
        return destTime >= srcTime;
    }
}
