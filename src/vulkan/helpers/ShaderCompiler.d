module vulkan.helpers.ShaderCompiler;

import vulkan.all;
import std.datetime : Clock, SysTime, minutes;
import std.file     : dirEntries, SpanMode, isFile, mkdirRecurse, exists, timeLastModified, readText, write;
import std.path	    : dirSeparator, extension, stripExtension, baseName, dirName, isRooted;
import std.array    : replace;
import std.string   : strip, splitLines;
import std.process  : execute, Config;

final class ShaderCompiler {
private:
    VkDevice device;
    VulkanProperties vprops;
    string[] srcDirectories;
    string destDirectory;
    string spirvVersionGlsl, spirvVersionSlang;
    VkShaderModule[string] shaders;
    SysTime spvStaleTime;
    
    static string glslCompilerVersion;
    static string slangCompilerVersion;
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

        // Generate the destination directory structure if it does not exist
        if(!exists(destDirectory)) {
            this.verbose("Making destination directory %s", destDirectory);
            mkdirRecurse(destDirectory);
        }

        this.slangCompilerVersion = getSlangCompilerVersion(vprops);
        this.glslCompilerVersion  = getGlslCompilerVersion(vprops);
    }
    void destroy() {
        clear();
    }
    void clear() {
        foreach(k,v; shaders) {
            device.destroyShaderModule(v);
        }
        this.verbose("Destroyed %s shader modules", shaders.length);
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
        string suffix = isSlangModule ? "" : "-" ~ ext;

        string destBasename = filename.baseName.stripExtension ~ suffix;
        string relDest = generateRelativeDestFilename(destBasename, filename, isSlangModule);
        string absDest = toAbsolutePath(relDest, "");

        // If the shader has already been compiled and cached, return the cached module
        if(auto ptr = relDest in shaders) {
            this.verbose("Returning cached shader %s", relDest);
            return *ptr;
        }

        string srcDir = findSourceDirectory(filename);
        string absSrc = toAbsolutePath(dirName(srcDir ~ filename), filename.baseName);

        // Recompile the source unless the spv file already exists and is more recently modified
        if(!destFileIsUpToDate(absSrc, absDest)) {
            compile(absSrc, absDest, isSlangModule);
        } else {
            this.verbose("Not recompiling because spv file is up to date");
        }

        this.verbose("Loading .spv from %s", absDest);
        auto shader = createFromFile(absDest);
        shaders[relDest] = shader;
        return shader;
    }
    static string getSlangCompilerVersion(VulkanProperties vprops) {
        if(!vprops.slangShaderCompiler) return "Not available";
        if(slangCompilerVersion) return slangCompilerVersion;

        string[] args = [
            vprops.slangShaderCompiler,
            "-version"
        ];
        auto result = execute(
            args,
            null,   // env
            Config.suppressConsole
        );

        string output = result.output.strip;

        throwIf(result.status != 0, "%s -version failed %s", vprops.slangShaderCompiler, output);

        slangCompilerVersion = output;
        return output;
    }
    static string getGlslCompilerVersion(VulkanProperties vprops) {
        if(!vprops.glslShaderCompiler) return "Not available";
        if(glslCompilerVersion) return glslCompilerVersion;

        string[] args = [
            vprops.glslShaderCompiler,
            "-version"
        ];
        auto result = execute(
            args,
            null,   // env
            Config.suppressConsole
        );

        string output = result.output.strip;

        throwIf(result.status != 0, "%s -version failed %s", vprops.glslShaderCompiler, output);

        // Extract the version number from the output
        const TOKEN = "Glslang Version:";
        foreach(line; output.splitLines) {
            if(line.startsWith(TOKEN)) {
                output = line[TOKEN.length..$].strip;
                break;
            }
        }

        glslCompilerVersion = output;
        return output;
    }
private:
    void compile(string src, string dest, bool isSlang) {
        this.verbose("Compiling:");
        this.verbose("  spirv = %s", spirvVersionGlsl);
        this.verbose("  src   = %s", src);
        this.verbose("  dest  = %s", dest);
        this.verbose("  slang = %s", isSlang);

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
    string generateRelativeDestFilename(string destBasename, string filename, bool isSlang) {
        import std.digest.sha;

        string isDebug = "false";
        debug isDebug = "true";

        string prefix = dirName(filename).replace("/", "-").replace("\\", "-");
        if(prefix == ".") {
            prefix = "";
        } else {
            prefix = "%s-".format(prefix);
        }

        // Hash dynamic properties:
        // - spirv version
        // - compiler version
        // - debug mode true/false
        auto hash = sha1Of(
            vprops.shaderSpirvVersion,
            isSlang ? slangCompilerVersion : glslCompilerVersion,
            isDebug);

        auto hex = toHexString(hash)[0..8].idup;

        string destFile = "%s%s%s-%s.spv".format(destDirectory, prefix, destBasename, hex);
        this.verbose("destFilename = %s", destFile);
        return destFile;
    }
    bool destFileIsUpToDate(string srcFile, string destFile) {

        // Does the spv file exist?
        if(!exists(destFile)) {
            this.verbose(":: Spv file does not exist");
            return false;
        }

        // Is the spv file older than the source file?
        SysTime srcTime = timeLastModified(srcFile);
        SysTime destTime = timeLastModified(destFile);
        if(destTime < srcTime) {
            this.verbose(":: Spv file is older than source file");
            return false;
        }

        // Is the spv file older than the stale timeout?
        if(destTime < spvStaleTime) {
            this.verbose(":: Spv file is older than stale timeout (%s minutes)", vprops.shaderSpirvShelfLifeMinutes);
            return false;
        }

        return true;
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
