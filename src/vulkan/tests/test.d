module vulkan.tests.test;

import core.sys.windows.windows;
import core.runtime;

import std.string : toStringz, fromStringz;
import std.utf	  : toUTF8, toUTF16z;
import std.format : format;

import vulkan;
import common;
import logging;
import resources;

import vulkan.tests.hello_world_1_0;
import vulkan.tests.hello_world_1_1;
import vulkan.tests.hello_world_1_2;
import vulkan.tests.hello_world_1_3;
import vulkan.tests.hello_world_1_4;
import vulkan.tests.test_compute;
import vulkan.tests.test_compute2;
import vulkan.tests.test_GLTF;
import vulkan.tests.test_graphics2D;
import vulkan.tests.test_graphics3D;
import vulkan.tests.test_gui;
import vulkan.tests.test_imgui;
import vulkan.tests.test_noise;
import vulkan.tests.test_render_to_texture;
import vulkan.tests.test_skybox;
import vulkan.tests.raytracing.test_ray_tracing;

pragma(lib, "user32.lib");
//pragma(lib, "libucrt.lib");

//extern(C) __gshared string[] rt_options = [
//    "gcopt=profile:1"
//];

extern(Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow) {
	int result = 0;
	VulkanApplication app;
	try{
        Runtime.initialize();

        setEagerFlushing(true);

        auto args = getArgs();
        log("args = %s", args);
        if(args.length > 1) {
            switch(args[1]) {
                case "noise":
                    app = new TestNoise();
                    break;
                case "compute":
                    app = new TestCompute();
                    break; 
                case "compute2":
                    app = new TestCompute2();
                    break;
                case "renderToTexture":
                    app = new TestCompRenderToTexture();
                    break;
                case "skybox":
                    app = new TestSkyBox();
                    break;
                case "graphics3D":
                    app = new TestGraphics3D();
                    break;
                case "gui":
                    app = new TestGUI();
                    break;
                case "imgui":
                    app = new TestImgui();
                    break;
                case "graphics2D":
                    app = new TestGraphics2D();
                    break;
                case "rayTracing":
                    app = new TestRayTracing();
                    break;
                case "hello_1_1":
                    app = new HelloWorld_1_1();
                    break;
                case "hello_1_2":
                    app = new HelloWorld_1_2();
                    break;  
                case "hello_1_3":
                    app = new HelloWorld_1_3();
                    break;      
                case "hello_1_4":
                    app = new HelloWorld_1_4();
                    break;
                case "gltf":
                    app = new TestGLTF();
                    break;
                default:
                    app = new HelloWorld_1_0();
                    break;
            }
        } else {
            app = new HelloWorld_1_0();
        }

		app.run();

    }catch(Throwable e) {
		log("exception: %s", e.msg);
		MessageBoxA(null, e.toString().toStringz(), "Error", MB_OK | MB_ICONEXCLAMATION);
		result = -1;
    }finally{
		flushLog();
		if(app) app.destroy();
		Runtime.terminate();
	}
	flushLog();
    return result;
}

/**
 *  getArgs()[0] should always be the program name
 */
string[] getArgs() {
    int nArgs;
    auto ptr = CommandLineToArgvW(GetCommandLineW(), &nArgs);

    string[] arguments;
    if(ptr !is null && nArgs>0) {
        foreach(i; 0..nArgs) {
            auto arg = fromStringz!wchar(*ptr);
            arguments ~= arg.toUTF8;
            ptr++;
        }
    }
    return arguments;
}
