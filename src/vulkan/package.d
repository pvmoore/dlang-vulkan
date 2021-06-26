module vulkan;

public:

import core.stdc.string : memset, memcpy;

import derelict.vulkan.vulkan;
//import derelict.vulkan.functions;
//import derelict.vulkan.types;

import derelict.glfw3;

import vulkan.enums;
import vulkan.types;
import vulkan.Swapchain;
import vulkan.vulkan;
import vulkan.vulkan_app;
import vulkan.WindowEventListener;

import vulkan.helpers.Context;
import vulkan.helpers.Descriptor;
import vulkan.helpers.GPUData;
import vulkan.helpers.InfoBuilder;
import vulkan.helpers.QueueManager;
import vulkan.helpers.ShaderCompiler;
import vulkan.helpers.ShaderPrintf;
import vulkan.helpers.StaticGPUData;
import vulkan.helpers.Transfer;
import vulkan.helpers.UpdateableImage;

import vulkan.memory.buffer_manager;
import vulkan.memory.device_buffer;
import vulkan.memory.device_image;
import vulkan.memory.device_memory;
import vulkan.memory.MemoryAllocator;
import vulkan.memory.memory_util;
import vulkan.memory.subbuffer;

import vulkan.pipelines.compute_pipeline;
import vulkan.pipelines.graphics_pipeline;

import vulkan.image.Fonts;
import vulkan.image.Images;
import vulkan.image.ImageAtlas;
import vulkan.image.ImageMeta;

import vulkan.api.buffer;
import vulkan.api.command_buffer;
import vulkan.api.command_pool;
import vulkan.api.descriptor;
import vulkan.api.device;
import vulkan.api.event;
import vulkan.api.fence;
import vulkan.api.frame_buffer;
import vulkan.api.image;
import vulkan.api.instance;
import vulkan.api.memory;
import vulkan.api.physical_device;
import vulkan.api.pipeline;
import vulkan.api.query;
import vulkan.api.queue;
import vulkan.api.render_pass;
import vulkan.api.sampler;
import vulkan.api.semaphore;
import vulkan.api.shader;
import vulkan.api.surface;

import vulkan.generators.image_generator;
import vulkan.generators.noise_generator;

import vulkan.misc.debug_;
import vulkan.misc.InstanceInfo;
import vulkan.misc.public_util;

import vulkan.renderers;

/**
 *  Throws an Exception if the assertion fails.
 *  Is executed in both debug and release modes;
 */
bool _assert(bool b, string msg = "") {
    if(!b) throw new Exception(msg);
    return true;
}