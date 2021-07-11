module vulkan.all;

version(Win64) {} else { static assert(false); }

public:

import core.sys.windows.windows : HINSTANCE, HWND, ShowWindow;
import core.thread              : Thread;
import core.stdc.string         : memcpy, memmove;
import core.time                : dur;

import std.stdio                : writefln;
import std.array                : appender, join, array;
import std.format				: format;
import std.conv					: to;
import std.string				: toStringz, fromStringz;
import std.typecons				: Tuple, tuple;
import std.algorithm.iteration	: each, map, sum, filter;
import std.algorithm.searching	: any, maxElement;
import std.algorithm.sorting    : sort;
import std.range				: iota;
import std.datetime.stopwatch   : StopWatch;
import std.random				: uniform, uniform01, Mt19937, unpredictableSeed;
import std.uuid                 : UUID, randomUUID;

import common;
import maths;
import logging      : log, flushLog;
import fonts        : SDFFont;
import resources    : Image, BMP, DDS, PNG, R32, ModelData, Obj;

import vulkan;

import vulkan.misc.dump;
import vulkan.misc.functions;
import vulkan.misc.load_unload;
import vulkan.misc.logging;
import vulkan.misc.private_util;

