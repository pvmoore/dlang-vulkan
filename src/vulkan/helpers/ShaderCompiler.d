module vulkan.helpers.ShaderCompiler;

import vulkan.all;
import std.datetime : Clock, SysTime, minutes;
import std.file     : dirEntries, SpanMode, isFile, mkdirRecurse, exists, timeLastModified;
import std.path	    : dirSeparator, extension, stripExtension, baseName, dirName, isRooted;
import std.array    : replace;

final class ShaderCompiler {
private:
    VkDevice device;
    VulkanProperties vprops;
    string[] srcDirectories;
    string destDirectory;
    string spirvVersionGlsl, spirvVersionSlang;
    VkShaderModule[string] shaders;
    SysTime spvStaleTime;
public:
    this(VkDevice device, VulkanProperties vprops) {
        this.device = device;
        this.vprops = vprops;

        foreach(s; vprops.shaderSrcDirectories) {
            this.srcDirectories ~= toCanonicalPath(s) ~ dirSeparator;
        }
        this.destDirectory = toCanonicalPath(vprops.shaderDestDirectory) ~ dirSeparator;
        this.spirvVersionGlsl = vprops.shaderSpirvVersion;
        this.spirvVersionSlang = vprops.shaderSpirvVersion.replace(".", "_");
        this.spvStaleTime = Clock.currTime() - vprops.shaderSpirvShelfLifeMinutes.minutes;
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
     * Retrieves or creates a VkShaderModule for the specified shader source file.
     *
     * This function handles shader compilation, caching, and module creation:
     * 1. If the shader has already been compiled and cached, returns the cached module
     * 2. Otherwise, locates the source file in the configured source directories
     * 3. Compiles the shader if the compiled .spv file doesn't exist or is outdated
     * 4. Creates a new VkShaderModule from the compiled code
     * 5. Caches the module for future use
     *
     * Params:
     *     filename = Relative path to the shader source file from one of the configured source directories
     *
     * Returns:
     *     VkShaderModule handle for the compiled shader
     *
     * Throws:
     *     Exception if:
     *     - The input file is already a .spv file
     *     - The filename is an absolute path
     *     - The source file cannot be found in any of the configured directories
     *     - Shader compilation fails
     */
    VkShaderModule getModule(string filename) {
        filename = toCanonicalPath(filename);
        throwIf(isRooted(filename), "Expecting a relative path");

        string ext = filename.extension[1..$];
        throwIf("spv"==ext, "Expecting a shader src file");

        bool isSlangModule = filename.endsWith(".slang");
        string suffix = isSlangModule ? "" : "_" ~ ext;

        string destDir = dirName(destDirectory ~ filename) ~ dirSeparator;
        string absDest = toAbsolutePath(destDir, filename.baseName.stripExtension ~ suffix ~ ".spv");

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
                compile(absSrc, absDest, isSlangModule);
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
    void compile(string src, string dest, bool isSlang) {
        import std.string : strip;
        import std.process : execute, Config;

        this.log("Compiling:");
        this.log("  spirv = %s", spirvVersionGlsl);
        this.log("  src   = %s", src);
        this.log("  dest  = %s", dest);
        this.log("  slang = %s", isSlang);

        // Include directories
        string[] includes;
        foreach(s; srcDirectories) {
            includes ~= ["-I" ~ s];
            //this.log("  inc   = %s", s);
        }

        auto args = isSlang ? createArgsForSlang(src, dest, includes) 
                            : createArgsForGLSL(src, dest, includes);
        //this.log("  args = %s", args);

        auto result = execute(
            args,
            null,   // env
            Config.suppressConsole
        );

        throwIf(result.status != 0, "Shader compilation failed %s", result.output.strip);
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
        if(destTime < spvStaleTime) {
            this.log("Spv file is older than %s minutes", vprops.shaderSpirvShelfLifeMinutes);
            return false;
        }

        SysTime srcTime = timeLastModified(srcFile);
        return destTime >= srcTime;
    }
    string getRequestedStage(string filename, string stage) {
        if(stage) return stage;
        return filename.extension[1..$];
    }
    string[] createArgsForGLSL(string src, string dest, string[] includes) {
        string[] args = [
            vprops.glslShaderCompiler,
            "-V",
            "--target-env", "spirv" ~ spirvVersionGlsl,
            "-Os",
            "-t",
            "-e", "main"
        ];

        debug {
            args ~= "-g";   // debug info
            args ~= "--enhanced-msgs";   // print more readable error messages (GLSL only)
            //args ~= "-q", // prints out some debug info. Useful for debugging UBO offsets for example
        }
        
        return args ~ includes ~ [
            "-o", dest,
            src
        ];
    }
    string[] createArgsForSlang(string src, string dest, string[] includes) {
        string[] args = [
            vprops.slangShaderCompiler, 
            "-target", "spirv",
            "-profile", "spirv_" ~ spirvVersionSlang, 
            "-O3",
            "-lang", "slang",
            //"-lang", "glsl",
            //"-entry", entry, 
            "-warnings-as-errors", "all",
            "-fvk-use-entrypoint-name",     // keep the function entry names in the shader file
            "-matrix-layout-column-major",
            "-fp-mode", "fast"
        ];

        debug {
            args ~= "-g";   // debug info
        }
        
        return args ~ includes ~ [
            "-o", dest,
            src
        ];
    }
}
