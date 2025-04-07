module vulkan.api.imgui_api;

private:

import core.stdc.stdio;

public:

// CImgui include files converted to D (This is a generated file)
// 
// Usage:
//   ** Start program
//   CImguiLoader.load();
//   ** 
//   CImguiLoader.unload();
//   ** Exit program

// CImguiLoader
private struct _CImguiLoader {
	import core.sys.windows.windows;
	import common.utils : throwIf;
	HANDLE handle;
	void load() {
		this.handle = LoadLibraryA("cimgui-glfw-vk-1.91.dll");
		if(!handle) throw new Exception("Unable to load 'cimgui-glfw-vk-1.91.dll'");
		
		*(cast(void**)&ImBitVector_Clear) = GetProcAddress(handle, "ImBitVector_Clear"); throwIf(!ImBitVector_Clear);
		*(cast(void**)&ImBitVector_ClearBit) = GetProcAddress(handle, "ImBitVector_ClearBit"); throwIf(!ImBitVector_ClearBit);
		*(cast(void**)&ImBitVector_Create) = GetProcAddress(handle, "ImBitVector_Create"); throwIf(!ImBitVector_Create);
		*(cast(void**)&ImBitVector_SetBit) = GetProcAddress(handle, "ImBitVector_SetBit"); throwIf(!ImBitVector_SetBit);
		*(cast(void**)&ImBitVector_TestBit) = GetProcAddress(handle, "ImBitVector_TestBit"); throwIf(!ImBitVector_TestBit);
		*(cast(void**)&ImColor_HSV) = GetProcAddress(handle, "ImColor_HSV"); throwIf(!ImColor_HSV);
		*(cast(void**)&ImColor_ImColor_Float) = GetProcAddress(handle, "ImColor_ImColor_Float"); throwIf(!ImColor_ImColor_Float);
		*(cast(void**)&ImColor_ImColor_Int) = GetProcAddress(handle, "ImColor_ImColor_Int"); throwIf(!ImColor_ImColor_Int);
		*(cast(void**)&ImColor_ImColor_Nil) = GetProcAddress(handle, "ImColor_ImColor_Nil"); throwIf(!ImColor_ImColor_Nil);
		*(cast(void**)&ImColor_ImColor_U32) = GetProcAddress(handle, "ImColor_ImColor_U32"); throwIf(!ImColor_ImColor_U32);
		*(cast(void**)&ImColor_ImColor_Vec4) = GetProcAddress(handle, "ImColor_ImColor_Vec4"); throwIf(!ImColor_ImColor_Vec4);
		*(cast(void**)&ImColor_SetHSV) = GetProcAddress(handle, "ImColor_SetHSV"); throwIf(!ImColor_SetHSV);
		*(cast(void**)&ImColor_destroy) = GetProcAddress(handle, "ImColor_destroy"); throwIf(!ImColor_destroy);
		*(cast(void**)&ImDrawCmd_GetTexID) = GetProcAddress(handle, "ImDrawCmd_GetTexID"); throwIf(!ImDrawCmd_GetTexID);
		*(cast(void**)&ImDrawCmd_ImDrawCmd) = GetProcAddress(handle, "ImDrawCmd_ImDrawCmd"); throwIf(!ImDrawCmd_ImDrawCmd);
		*(cast(void**)&ImDrawCmd_destroy) = GetProcAddress(handle, "ImDrawCmd_destroy"); throwIf(!ImDrawCmd_destroy);
		*(cast(void**)&ImDrawDataBuilder_ImDrawDataBuilder) = GetProcAddress(handle, "ImDrawDataBuilder_ImDrawDataBuilder"); throwIf(!ImDrawDataBuilder_ImDrawDataBuilder);
		*(cast(void**)&ImDrawDataBuilder_destroy) = GetProcAddress(handle, "ImDrawDataBuilder_destroy"); throwIf(!ImDrawDataBuilder_destroy);
		*(cast(void**)&ImDrawData_AddDrawList) = GetProcAddress(handle, "ImDrawData_AddDrawList"); throwIf(!ImDrawData_AddDrawList);
		*(cast(void**)&ImDrawData_Clear) = GetProcAddress(handle, "ImDrawData_Clear"); throwIf(!ImDrawData_Clear);
		*(cast(void**)&ImDrawData_DeIndexAllBuffers) = GetProcAddress(handle, "ImDrawData_DeIndexAllBuffers"); throwIf(!ImDrawData_DeIndexAllBuffers);
		*(cast(void**)&ImDrawData_ImDrawData) = GetProcAddress(handle, "ImDrawData_ImDrawData"); throwIf(!ImDrawData_ImDrawData);
		*(cast(void**)&ImDrawData_ScaleClipRects) = GetProcAddress(handle, "ImDrawData_ScaleClipRects"); throwIf(!ImDrawData_ScaleClipRects);
		*(cast(void**)&ImDrawData_destroy) = GetProcAddress(handle, "ImDrawData_destroy"); throwIf(!ImDrawData_destroy);
		*(cast(void**)&ImDrawListSharedData_ImDrawListSharedData) = GetProcAddress(handle, "ImDrawListSharedData_ImDrawListSharedData"); throwIf(!ImDrawListSharedData_ImDrawListSharedData);
		*(cast(void**)&ImDrawListSharedData_SetCircleTessellationMaxError) = GetProcAddress(handle, "ImDrawListSharedData_SetCircleTessellationMaxError"); throwIf(!ImDrawListSharedData_SetCircleTessellationMaxError);
		*(cast(void**)&ImDrawListSharedData_destroy) = GetProcAddress(handle, "ImDrawListSharedData_destroy"); throwIf(!ImDrawListSharedData_destroy);
		*(cast(void**)&ImDrawListSplitter_Clear) = GetProcAddress(handle, "ImDrawListSplitter_Clear"); throwIf(!ImDrawListSplitter_Clear);
		*(cast(void**)&ImDrawListSplitter_ClearFreeMemory) = GetProcAddress(handle, "ImDrawListSplitter_ClearFreeMemory"); throwIf(!ImDrawListSplitter_ClearFreeMemory);
		*(cast(void**)&ImDrawListSplitter_ImDrawListSplitter) = GetProcAddress(handle, "ImDrawListSplitter_ImDrawListSplitter"); throwIf(!ImDrawListSplitter_ImDrawListSplitter);
		*(cast(void**)&ImDrawListSplitter_Merge) = GetProcAddress(handle, "ImDrawListSplitter_Merge"); throwIf(!ImDrawListSplitter_Merge);
		*(cast(void**)&ImDrawListSplitter_SetCurrentChannel) = GetProcAddress(handle, "ImDrawListSplitter_SetCurrentChannel"); throwIf(!ImDrawListSplitter_SetCurrentChannel);
		*(cast(void**)&ImDrawListSplitter_Split) = GetProcAddress(handle, "ImDrawListSplitter_Split"); throwIf(!ImDrawListSplitter_Split);
		*(cast(void**)&ImDrawListSplitter_destroy) = GetProcAddress(handle, "ImDrawListSplitter_destroy"); throwIf(!ImDrawListSplitter_destroy);
		*(cast(void**)&ImDrawList_AddBezierCubic) = GetProcAddress(handle, "ImDrawList_AddBezierCubic"); throwIf(!ImDrawList_AddBezierCubic);
		*(cast(void**)&ImDrawList_AddBezierQuadratic) = GetProcAddress(handle, "ImDrawList_AddBezierQuadratic"); throwIf(!ImDrawList_AddBezierQuadratic);
		*(cast(void**)&ImDrawList_AddCallback) = GetProcAddress(handle, "ImDrawList_AddCallback"); throwIf(!ImDrawList_AddCallback);
		*(cast(void**)&ImDrawList_AddCircle) = GetProcAddress(handle, "ImDrawList_AddCircle"); throwIf(!ImDrawList_AddCircle);
		*(cast(void**)&ImDrawList_AddCircleFilled) = GetProcAddress(handle, "ImDrawList_AddCircleFilled"); throwIf(!ImDrawList_AddCircleFilled);
		*(cast(void**)&ImDrawList_AddConcavePolyFilled) = GetProcAddress(handle, "ImDrawList_AddConcavePolyFilled"); throwIf(!ImDrawList_AddConcavePolyFilled);
		*(cast(void**)&ImDrawList_AddConvexPolyFilled) = GetProcAddress(handle, "ImDrawList_AddConvexPolyFilled"); throwIf(!ImDrawList_AddConvexPolyFilled);
		*(cast(void**)&ImDrawList_AddDrawCmd) = GetProcAddress(handle, "ImDrawList_AddDrawCmd"); throwIf(!ImDrawList_AddDrawCmd);
		*(cast(void**)&ImDrawList_AddEllipse) = GetProcAddress(handle, "ImDrawList_AddEllipse"); throwIf(!ImDrawList_AddEllipse);
		*(cast(void**)&ImDrawList_AddEllipseFilled) = GetProcAddress(handle, "ImDrawList_AddEllipseFilled"); throwIf(!ImDrawList_AddEllipseFilled);
		*(cast(void**)&ImDrawList_AddImage) = GetProcAddress(handle, "ImDrawList_AddImage"); throwIf(!ImDrawList_AddImage);
		*(cast(void**)&ImDrawList_AddImageQuad) = GetProcAddress(handle, "ImDrawList_AddImageQuad"); throwIf(!ImDrawList_AddImageQuad);
		*(cast(void**)&ImDrawList_AddImageRounded) = GetProcAddress(handle, "ImDrawList_AddImageRounded"); throwIf(!ImDrawList_AddImageRounded);
		*(cast(void**)&ImDrawList_AddLine) = GetProcAddress(handle, "ImDrawList_AddLine"); throwIf(!ImDrawList_AddLine);
		*(cast(void**)&ImDrawList_AddNgon) = GetProcAddress(handle, "ImDrawList_AddNgon"); throwIf(!ImDrawList_AddNgon);
		*(cast(void**)&ImDrawList_AddNgonFilled) = GetProcAddress(handle, "ImDrawList_AddNgonFilled"); throwIf(!ImDrawList_AddNgonFilled);
		*(cast(void**)&ImDrawList_AddPolyline) = GetProcAddress(handle, "ImDrawList_AddPolyline"); throwIf(!ImDrawList_AddPolyline);
		*(cast(void**)&ImDrawList_AddQuad) = GetProcAddress(handle, "ImDrawList_AddQuad"); throwIf(!ImDrawList_AddQuad);
		*(cast(void**)&ImDrawList_AddQuadFilled) = GetProcAddress(handle, "ImDrawList_AddQuadFilled"); throwIf(!ImDrawList_AddQuadFilled);
		*(cast(void**)&ImDrawList_AddRect) = GetProcAddress(handle, "ImDrawList_AddRect"); throwIf(!ImDrawList_AddRect);
		*(cast(void**)&ImDrawList_AddRectFilled) = GetProcAddress(handle, "ImDrawList_AddRectFilled"); throwIf(!ImDrawList_AddRectFilled);
		*(cast(void**)&ImDrawList_AddRectFilledMultiColor) = GetProcAddress(handle, "ImDrawList_AddRectFilledMultiColor"); throwIf(!ImDrawList_AddRectFilledMultiColor);
		*(cast(void**)&ImDrawList_AddText_FontPtr) = GetProcAddress(handle, "ImDrawList_AddText_FontPtr"); throwIf(!ImDrawList_AddText_FontPtr);
		*(cast(void**)&ImDrawList_AddText_Vec2) = GetProcAddress(handle, "ImDrawList_AddText_Vec2"); throwIf(!ImDrawList_AddText_Vec2);
		*(cast(void**)&ImDrawList_AddTriangle) = GetProcAddress(handle, "ImDrawList_AddTriangle"); throwIf(!ImDrawList_AddTriangle);
		*(cast(void**)&ImDrawList_AddTriangleFilled) = GetProcAddress(handle, "ImDrawList_AddTriangleFilled"); throwIf(!ImDrawList_AddTriangleFilled);
		*(cast(void**)&ImDrawList_ChannelsMerge) = GetProcAddress(handle, "ImDrawList_ChannelsMerge"); throwIf(!ImDrawList_ChannelsMerge);
		*(cast(void**)&ImDrawList_ChannelsSetCurrent) = GetProcAddress(handle, "ImDrawList_ChannelsSetCurrent"); throwIf(!ImDrawList_ChannelsSetCurrent);
		*(cast(void**)&ImDrawList_ChannelsSplit) = GetProcAddress(handle, "ImDrawList_ChannelsSplit"); throwIf(!ImDrawList_ChannelsSplit);
		*(cast(void**)&ImDrawList_CloneOutput) = GetProcAddress(handle, "ImDrawList_CloneOutput"); throwIf(!ImDrawList_CloneOutput);
		*(cast(void**)&ImDrawList_GetClipRectMax) = GetProcAddress(handle, "ImDrawList_GetClipRectMax"); throwIf(!ImDrawList_GetClipRectMax);
		*(cast(void**)&ImDrawList_GetClipRectMin) = GetProcAddress(handle, "ImDrawList_GetClipRectMin"); throwIf(!ImDrawList_GetClipRectMin);
		*(cast(void**)&ImDrawList_ImDrawList) = GetProcAddress(handle, "ImDrawList_ImDrawList"); throwIf(!ImDrawList_ImDrawList);
		*(cast(void**)&ImDrawList_PathArcTo) = GetProcAddress(handle, "ImDrawList_PathArcTo"); throwIf(!ImDrawList_PathArcTo);
		*(cast(void**)&ImDrawList_PathArcToFast) = GetProcAddress(handle, "ImDrawList_PathArcToFast"); throwIf(!ImDrawList_PathArcToFast);
		*(cast(void**)&ImDrawList_PathBezierCubicCurveTo) = GetProcAddress(handle, "ImDrawList_PathBezierCubicCurveTo"); throwIf(!ImDrawList_PathBezierCubicCurveTo);
		*(cast(void**)&ImDrawList_PathBezierQuadraticCurveTo) = GetProcAddress(handle, "ImDrawList_PathBezierQuadraticCurveTo"); throwIf(!ImDrawList_PathBezierQuadraticCurveTo);
		*(cast(void**)&ImDrawList_PathClear) = GetProcAddress(handle, "ImDrawList_PathClear"); throwIf(!ImDrawList_PathClear);
		*(cast(void**)&ImDrawList_PathEllipticalArcTo) = GetProcAddress(handle, "ImDrawList_PathEllipticalArcTo"); throwIf(!ImDrawList_PathEllipticalArcTo);
		*(cast(void**)&ImDrawList_PathFillConcave) = GetProcAddress(handle, "ImDrawList_PathFillConcave"); throwIf(!ImDrawList_PathFillConcave);
		*(cast(void**)&ImDrawList_PathFillConvex) = GetProcAddress(handle, "ImDrawList_PathFillConvex"); throwIf(!ImDrawList_PathFillConvex);
		*(cast(void**)&ImDrawList_PathLineTo) = GetProcAddress(handle, "ImDrawList_PathLineTo"); throwIf(!ImDrawList_PathLineTo);
		*(cast(void**)&ImDrawList_PathLineToMergeDuplicate) = GetProcAddress(handle, "ImDrawList_PathLineToMergeDuplicate"); throwIf(!ImDrawList_PathLineToMergeDuplicate);
		*(cast(void**)&ImDrawList_PathRect) = GetProcAddress(handle, "ImDrawList_PathRect"); throwIf(!ImDrawList_PathRect);
		*(cast(void**)&ImDrawList_PathStroke) = GetProcAddress(handle, "ImDrawList_PathStroke"); throwIf(!ImDrawList_PathStroke);
		*(cast(void**)&ImDrawList_PopClipRect) = GetProcAddress(handle, "ImDrawList_PopClipRect"); throwIf(!ImDrawList_PopClipRect);
		*(cast(void**)&ImDrawList_PopTextureID) = GetProcAddress(handle, "ImDrawList_PopTextureID"); throwIf(!ImDrawList_PopTextureID);
		*(cast(void**)&ImDrawList_PrimQuadUV) = GetProcAddress(handle, "ImDrawList_PrimQuadUV"); throwIf(!ImDrawList_PrimQuadUV);
		*(cast(void**)&ImDrawList_PrimRect) = GetProcAddress(handle, "ImDrawList_PrimRect"); throwIf(!ImDrawList_PrimRect);
		*(cast(void**)&ImDrawList_PrimRectUV) = GetProcAddress(handle, "ImDrawList_PrimRectUV"); throwIf(!ImDrawList_PrimRectUV);
		*(cast(void**)&ImDrawList_PrimReserve) = GetProcAddress(handle, "ImDrawList_PrimReserve"); throwIf(!ImDrawList_PrimReserve);
		*(cast(void**)&ImDrawList_PrimUnreserve) = GetProcAddress(handle, "ImDrawList_PrimUnreserve"); throwIf(!ImDrawList_PrimUnreserve);
		*(cast(void**)&ImDrawList_PrimVtx) = GetProcAddress(handle, "ImDrawList_PrimVtx"); throwIf(!ImDrawList_PrimVtx);
		*(cast(void**)&ImDrawList_PrimWriteIdx) = GetProcAddress(handle, "ImDrawList_PrimWriteIdx"); throwIf(!ImDrawList_PrimWriteIdx);
		*(cast(void**)&ImDrawList_PrimWriteVtx) = GetProcAddress(handle, "ImDrawList_PrimWriteVtx"); throwIf(!ImDrawList_PrimWriteVtx);
		*(cast(void**)&ImDrawList_PushClipRect) = GetProcAddress(handle, "ImDrawList_PushClipRect"); throwIf(!ImDrawList_PushClipRect);
		*(cast(void**)&ImDrawList_PushClipRectFullScreen) = GetProcAddress(handle, "ImDrawList_PushClipRectFullScreen"); throwIf(!ImDrawList_PushClipRectFullScreen);
		*(cast(void**)&ImDrawList_PushTextureID) = GetProcAddress(handle, "ImDrawList_PushTextureID"); throwIf(!ImDrawList_PushTextureID);
		*(cast(void**)&ImDrawList__CalcCircleAutoSegmentCount) = GetProcAddress(handle, "ImDrawList__CalcCircleAutoSegmentCount"); throwIf(!ImDrawList__CalcCircleAutoSegmentCount);
		*(cast(void**)&ImDrawList__ClearFreeMemory) = GetProcAddress(handle, "ImDrawList__ClearFreeMemory"); throwIf(!ImDrawList__ClearFreeMemory);
		*(cast(void**)&ImDrawList__OnChangedClipRect) = GetProcAddress(handle, "ImDrawList__OnChangedClipRect"); throwIf(!ImDrawList__OnChangedClipRect);
		*(cast(void**)&ImDrawList__OnChangedTextureID) = GetProcAddress(handle, "ImDrawList__OnChangedTextureID"); throwIf(!ImDrawList__OnChangedTextureID);
		*(cast(void**)&ImDrawList__OnChangedVtxOffset) = GetProcAddress(handle, "ImDrawList__OnChangedVtxOffset"); throwIf(!ImDrawList__OnChangedVtxOffset);
		*(cast(void**)&ImDrawList__PathArcToFastEx) = GetProcAddress(handle, "ImDrawList__PathArcToFastEx"); throwIf(!ImDrawList__PathArcToFastEx);
		*(cast(void**)&ImDrawList__PathArcToN) = GetProcAddress(handle, "ImDrawList__PathArcToN"); throwIf(!ImDrawList__PathArcToN);
		*(cast(void**)&ImDrawList__PopUnusedDrawCmd) = GetProcAddress(handle, "ImDrawList__PopUnusedDrawCmd"); throwIf(!ImDrawList__PopUnusedDrawCmd);
		*(cast(void**)&ImDrawList__ResetForNewFrame) = GetProcAddress(handle, "ImDrawList__ResetForNewFrame"); throwIf(!ImDrawList__ResetForNewFrame);
		*(cast(void**)&ImDrawList__TryMergeDrawCmds) = GetProcAddress(handle, "ImDrawList__TryMergeDrawCmds"); throwIf(!ImDrawList__TryMergeDrawCmds);
		*(cast(void**)&ImDrawList_destroy) = GetProcAddress(handle, "ImDrawList_destroy"); throwIf(!ImDrawList_destroy);
		*(cast(void**)&ImFontAtlasCustomRect_ImFontAtlasCustomRect) = GetProcAddress(handle, "ImFontAtlasCustomRect_ImFontAtlasCustomRect"); throwIf(!ImFontAtlasCustomRect_ImFontAtlasCustomRect);
		*(cast(void**)&ImFontAtlasCustomRect_IsPacked) = GetProcAddress(handle, "ImFontAtlasCustomRect_IsPacked"); throwIf(!ImFontAtlasCustomRect_IsPacked);
		*(cast(void**)&ImFontAtlasCustomRect_destroy) = GetProcAddress(handle, "ImFontAtlasCustomRect_destroy"); throwIf(!ImFontAtlasCustomRect_destroy);
		*(cast(void**)&ImFontAtlas_AddCustomRectFontGlyph) = GetProcAddress(handle, "ImFontAtlas_AddCustomRectFontGlyph"); throwIf(!ImFontAtlas_AddCustomRectFontGlyph);
		*(cast(void**)&ImFontAtlas_AddCustomRectRegular) = GetProcAddress(handle, "ImFontAtlas_AddCustomRectRegular"); throwIf(!ImFontAtlas_AddCustomRectRegular);
		*(cast(void**)&ImFontAtlas_AddFont) = GetProcAddress(handle, "ImFontAtlas_AddFont"); throwIf(!ImFontAtlas_AddFont);
		*(cast(void**)&ImFontAtlas_AddFontDefault) = GetProcAddress(handle, "ImFontAtlas_AddFontDefault"); throwIf(!ImFontAtlas_AddFontDefault);
		*(cast(void**)&ImFontAtlas_AddFontFromFileTTF) = GetProcAddress(handle, "ImFontAtlas_AddFontFromFileTTF"); throwIf(!ImFontAtlas_AddFontFromFileTTF);
		*(cast(void**)&ImFontAtlas_AddFontFromMemoryCompressedBase85TTF) = GetProcAddress(handle, "ImFontAtlas_AddFontFromMemoryCompressedBase85TTF"); throwIf(!ImFontAtlas_AddFontFromMemoryCompressedBase85TTF);
		*(cast(void**)&ImFontAtlas_AddFontFromMemoryCompressedTTF) = GetProcAddress(handle, "ImFontAtlas_AddFontFromMemoryCompressedTTF"); throwIf(!ImFontAtlas_AddFontFromMemoryCompressedTTF);
		*(cast(void**)&ImFontAtlas_AddFontFromMemoryTTF) = GetProcAddress(handle, "ImFontAtlas_AddFontFromMemoryTTF"); throwIf(!ImFontAtlas_AddFontFromMemoryTTF);
		*(cast(void**)&ImFontAtlas_Build) = GetProcAddress(handle, "ImFontAtlas_Build"); throwIf(!ImFontAtlas_Build);
		*(cast(void**)&ImFontAtlas_CalcCustomRectUV) = GetProcAddress(handle, "ImFontAtlas_CalcCustomRectUV"); throwIf(!ImFontAtlas_CalcCustomRectUV);
		*(cast(void**)&ImFontAtlas_Clear) = GetProcAddress(handle, "ImFontAtlas_Clear"); throwIf(!ImFontAtlas_Clear);
		*(cast(void**)&ImFontAtlas_ClearFonts) = GetProcAddress(handle, "ImFontAtlas_ClearFonts"); throwIf(!ImFontAtlas_ClearFonts);
		*(cast(void**)&ImFontAtlas_ClearInputData) = GetProcAddress(handle, "ImFontAtlas_ClearInputData"); throwIf(!ImFontAtlas_ClearInputData);
		*(cast(void**)&ImFontAtlas_ClearTexData) = GetProcAddress(handle, "ImFontAtlas_ClearTexData"); throwIf(!ImFontAtlas_ClearTexData);
		*(cast(void**)&ImFontAtlas_GetCustomRectByIndex) = GetProcAddress(handle, "ImFontAtlas_GetCustomRectByIndex"); throwIf(!ImFontAtlas_GetCustomRectByIndex);
		*(cast(void**)&ImFontAtlas_GetGlyphRangesChineseFull) = GetProcAddress(handle, "ImFontAtlas_GetGlyphRangesChineseFull"); throwIf(!ImFontAtlas_GetGlyphRangesChineseFull);
		*(cast(void**)&ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon) = GetProcAddress(handle, "ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon"); throwIf(!ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon);
		*(cast(void**)&ImFontAtlas_GetGlyphRangesCyrillic) = GetProcAddress(handle, "ImFontAtlas_GetGlyphRangesCyrillic"); throwIf(!ImFontAtlas_GetGlyphRangesCyrillic);
		*(cast(void**)&ImFontAtlas_GetGlyphRangesDefault) = GetProcAddress(handle, "ImFontAtlas_GetGlyphRangesDefault"); throwIf(!ImFontAtlas_GetGlyphRangesDefault);
		*(cast(void**)&ImFontAtlas_GetGlyphRangesGreek) = GetProcAddress(handle, "ImFontAtlas_GetGlyphRangesGreek"); throwIf(!ImFontAtlas_GetGlyphRangesGreek);
		*(cast(void**)&ImFontAtlas_GetGlyphRangesJapanese) = GetProcAddress(handle, "ImFontAtlas_GetGlyphRangesJapanese"); throwIf(!ImFontAtlas_GetGlyphRangesJapanese);
		*(cast(void**)&ImFontAtlas_GetGlyphRangesKorean) = GetProcAddress(handle, "ImFontAtlas_GetGlyphRangesKorean"); throwIf(!ImFontAtlas_GetGlyphRangesKorean);
		*(cast(void**)&ImFontAtlas_GetGlyphRangesThai) = GetProcAddress(handle, "ImFontAtlas_GetGlyphRangesThai"); throwIf(!ImFontAtlas_GetGlyphRangesThai);
		*(cast(void**)&ImFontAtlas_GetGlyphRangesVietnamese) = GetProcAddress(handle, "ImFontAtlas_GetGlyphRangesVietnamese"); throwIf(!ImFontAtlas_GetGlyphRangesVietnamese);
		*(cast(void**)&ImFontAtlas_GetMouseCursorTexData) = GetProcAddress(handle, "ImFontAtlas_GetMouseCursorTexData"); throwIf(!ImFontAtlas_GetMouseCursorTexData);
		*(cast(void**)&ImFontAtlas_GetTexDataAsAlpha8) = GetProcAddress(handle, "ImFontAtlas_GetTexDataAsAlpha8"); throwIf(!ImFontAtlas_GetTexDataAsAlpha8);
		*(cast(void**)&ImFontAtlas_GetTexDataAsRGBA32) = GetProcAddress(handle, "ImFontAtlas_GetTexDataAsRGBA32"); throwIf(!ImFontAtlas_GetTexDataAsRGBA32);
		*(cast(void**)&ImFontAtlas_ImFontAtlas) = GetProcAddress(handle, "ImFontAtlas_ImFontAtlas"); throwIf(!ImFontAtlas_ImFontAtlas);
		*(cast(void**)&ImFontAtlas_IsBuilt) = GetProcAddress(handle, "ImFontAtlas_IsBuilt"); throwIf(!ImFontAtlas_IsBuilt);
		*(cast(void**)&ImFontAtlas_SetTexID) = GetProcAddress(handle, "ImFontAtlas_SetTexID"); throwIf(!ImFontAtlas_SetTexID);
		*(cast(void**)&ImFontAtlas_destroy) = GetProcAddress(handle, "ImFontAtlas_destroy"); throwIf(!ImFontAtlas_destroy);
		*(cast(void**)&ImFontConfig_ImFontConfig) = GetProcAddress(handle, "ImFontConfig_ImFontConfig"); throwIf(!ImFontConfig_ImFontConfig);
		*(cast(void**)&ImFontConfig_destroy) = GetProcAddress(handle, "ImFontConfig_destroy"); throwIf(!ImFontConfig_destroy);
		*(cast(void**)&ImFontGlyphRangesBuilder_AddChar) = GetProcAddress(handle, "ImFontGlyphRangesBuilder_AddChar"); throwIf(!ImFontGlyphRangesBuilder_AddChar);
		*(cast(void**)&ImFontGlyphRangesBuilder_AddRanges) = GetProcAddress(handle, "ImFontGlyphRangesBuilder_AddRanges"); throwIf(!ImFontGlyphRangesBuilder_AddRanges);
		*(cast(void**)&ImFontGlyphRangesBuilder_AddText) = GetProcAddress(handle, "ImFontGlyphRangesBuilder_AddText"); throwIf(!ImFontGlyphRangesBuilder_AddText);
		*(cast(void**)&ImFontGlyphRangesBuilder_BuildRanges) = GetProcAddress(handle, "ImFontGlyphRangesBuilder_BuildRanges"); throwIf(!ImFontGlyphRangesBuilder_BuildRanges);
		*(cast(void**)&ImFontGlyphRangesBuilder_Clear) = GetProcAddress(handle, "ImFontGlyphRangesBuilder_Clear"); throwIf(!ImFontGlyphRangesBuilder_Clear);
		*(cast(void**)&ImFontGlyphRangesBuilder_GetBit) = GetProcAddress(handle, "ImFontGlyphRangesBuilder_GetBit"); throwIf(!ImFontGlyphRangesBuilder_GetBit);
		*(cast(void**)&ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder) = GetProcAddress(handle, "ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder"); throwIf(!ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder);
		*(cast(void**)&ImFontGlyphRangesBuilder_SetBit) = GetProcAddress(handle, "ImFontGlyphRangesBuilder_SetBit"); throwIf(!ImFontGlyphRangesBuilder_SetBit);
		*(cast(void**)&ImFontGlyphRangesBuilder_destroy) = GetProcAddress(handle, "ImFontGlyphRangesBuilder_destroy"); throwIf(!ImFontGlyphRangesBuilder_destroy);
		*(cast(void**)&ImFont_AddGlyph) = GetProcAddress(handle, "ImFont_AddGlyph"); throwIf(!ImFont_AddGlyph);
		*(cast(void**)&ImFont_AddRemapChar) = GetProcAddress(handle, "ImFont_AddRemapChar"); throwIf(!ImFont_AddRemapChar);
		*(cast(void**)&ImFont_BuildLookupTable) = GetProcAddress(handle, "ImFont_BuildLookupTable"); throwIf(!ImFont_BuildLookupTable);
		*(cast(void**)&ImFont_CalcTextSizeA) = GetProcAddress(handle, "ImFont_CalcTextSizeA"); throwIf(!ImFont_CalcTextSizeA);
		*(cast(void**)&ImFont_CalcWordWrapPositionA) = GetProcAddress(handle, "ImFont_CalcWordWrapPositionA"); throwIf(!ImFont_CalcWordWrapPositionA);
		*(cast(void**)&ImFont_ClearOutputData) = GetProcAddress(handle, "ImFont_ClearOutputData"); throwIf(!ImFont_ClearOutputData);
		*(cast(void**)&ImFont_FindGlyph) = GetProcAddress(handle, "ImFont_FindGlyph"); throwIf(!ImFont_FindGlyph);
		*(cast(void**)&ImFont_FindGlyphNoFallback) = GetProcAddress(handle, "ImFont_FindGlyphNoFallback"); throwIf(!ImFont_FindGlyphNoFallback);
		*(cast(void**)&ImFont_GetCharAdvance) = GetProcAddress(handle, "ImFont_GetCharAdvance"); throwIf(!ImFont_GetCharAdvance);
		*(cast(void**)&ImFont_GetDebugName) = GetProcAddress(handle, "ImFont_GetDebugName"); throwIf(!ImFont_GetDebugName);
		*(cast(void**)&ImFont_GrowIndex) = GetProcAddress(handle, "ImFont_GrowIndex"); throwIf(!ImFont_GrowIndex);
		*(cast(void**)&ImFont_ImFont) = GetProcAddress(handle, "ImFont_ImFont"); throwIf(!ImFont_ImFont);
		*(cast(void**)&ImFont_IsGlyphRangeUnused) = GetProcAddress(handle, "ImFont_IsGlyphRangeUnused"); throwIf(!ImFont_IsGlyphRangeUnused);
		*(cast(void**)&ImFont_IsLoaded) = GetProcAddress(handle, "ImFont_IsLoaded"); throwIf(!ImFont_IsLoaded);
		*(cast(void**)&ImFont_RenderChar) = GetProcAddress(handle, "ImFont_RenderChar"); throwIf(!ImFont_RenderChar);
		*(cast(void**)&ImFont_RenderText) = GetProcAddress(handle, "ImFont_RenderText"); throwIf(!ImFont_RenderText);
		*(cast(void**)&ImFont_SetGlyphVisible) = GetProcAddress(handle, "ImFont_SetGlyphVisible"); throwIf(!ImFont_SetGlyphVisible);
		*(cast(void**)&ImFont_destroy) = GetProcAddress(handle, "ImFont_destroy"); throwIf(!ImFont_destroy);
		*(cast(void**)&ImGuiBoxSelectState_ImGuiBoxSelectState) = GetProcAddress(handle, "ImGuiBoxSelectState_ImGuiBoxSelectState"); throwIf(!ImGuiBoxSelectState_ImGuiBoxSelectState);
		*(cast(void**)&ImGuiBoxSelectState_destroy) = GetProcAddress(handle, "ImGuiBoxSelectState_destroy"); throwIf(!ImGuiBoxSelectState_destroy);
		*(cast(void**)&ImGuiComboPreviewData_ImGuiComboPreviewData) = GetProcAddress(handle, "ImGuiComboPreviewData_ImGuiComboPreviewData"); throwIf(!ImGuiComboPreviewData_ImGuiComboPreviewData);
		*(cast(void**)&ImGuiComboPreviewData_destroy) = GetProcAddress(handle, "ImGuiComboPreviewData_destroy"); throwIf(!ImGuiComboPreviewData_destroy);
		*(cast(void**)&ImGuiContextHook_ImGuiContextHook) = GetProcAddress(handle, "ImGuiContextHook_ImGuiContextHook"); throwIf(!ImGuiContextHook_ImGuiContextHook);
		*(cast(void**)&ImGuiContextHook_destroy) = GetProcAddress(handle, "ImGuiContextHook_destroy"); throwIf(!ImGuiContextHook_destroy);
		*(cast(void**)&ImGuiContext_ImGuiContext) = GetProcAddress(handle, "ImGuiContext_ImGuiContext"); throwIf(!ImGuiContext_ImGuiContext);
		*(cast(void**)&ImGuiContext_destroy) = GetProcAddress(handle, "ImGuiContext_destroy"); throwIf(!ImGuiContext_destroy);
		*(cast(void**)&ImGuiDataVarInfo_GetVarPtr) = GetProcAddress(handle, "ImGuiDataVarInfo_GetVarPtr"); throwIf(!ImGuiDataVarInfo_GetVarPtr);
		*(cast(void**)&ImGuiDebugAllocInfo_ImGuiDebugAllocInfo) = GetProcAddress(handle, "ImGuiDebugAllocInfo_ImGuiDebugAllocInfo"); throwIf(!ImGuiDebugAllocInfo_ImGuiDebugAllocInfo);
		*(cast(void**)&ImGuiDebugAllocInfo_destroy) = GetProcAddress(handle, "ImGuiDebugAllocInfo_destroy"); throwIf(!ImGuiDebugAllocInfo_destroy);
		*(cast(void**)&ImGuiDockContext_ImGuiDockContext) = GetProcAddress(handle, "ImGuiDockContext_ImGuiDockContext"); throwIf(!ImGuiDockContext_ImGuiDockContext);
		*(cast(void**)&ImGuiDockContext_destroy) = GetProcAddress(handle, "ImGuiDockContext_destroy"); throwIf(!ImGuiDockContext_destroy);
		*(cast(void**)&ImGuiDockNode_ImGuiDockNode) = GetProcAddress(handle, "ImGuiDockNode_ImGuiDockNode"); throwIf(!ImGuiDockNode_ImGuiDockNode);
		*(cast(void**)&ImGuiDockNode_IsCentralNode) = GetProcAddress(handle, "ImGuiDockNode_IsCentralNode"); throwIf(!ImGuiDockNode_IsCentralNode);
		*(cast(void**)&ImGuiDockNode_IsDockSpace) = GetProcAddress(handle, "ImGuiDockNode_IsDockSpace"); throwIf(!ImGuiDockNode_IsDockSpace);
		*(cast(void**)&ImGuiDockNode_IsEmpty) = GetProcAddress(handle, "ImGuiDockNode_IsEmpty"); throwIf(!ImGuiDockNode_IsEmpty);
		*(cast(void**)&ImGuiDockNode_IsFloatingNode) = GetProcAddress(handle, "ImGuiDockNode_IsFloatingNode"); throwIf(!ImGuiDockNode_IsFloatingNode);
		*(cast(void**)&ImGuiDockNode_IsHiddenTabBar) = GetProcAddress(handle, "ImGuiDockNode_IsHiddenTabBar"); throwIf(!ImGuiDockNode_IsHiddenTabBar);
		*(cast(void**)&ImGuiDockNode_IsLeafNode) = GetProcAddress(handle, "ImGuiDockNode_IsLeafNode"); throwIf(!ImGuiDockNode_IsLeafNode);
		*(cast(void**)&ImGuiDockNode_IsNoTabBar) = GetProcAddress(handle, "ImGuiDockNode_IsNoTabBar"); throwIf(!ImGuiDockNode_IsNoTabBar);
		*(cast(void**)&ImGuiDockNode_IsRootNode) = GetProcAddress(handle, "ImGuiDockNode_IsRootNode"); throwIf(!ImGuiDockNode_IsRootNode);
		*(cast(void**)&ImGuiDockNode_IsSplitNode) = GetProcAddress(handle, "ImGuiDockNode_IsSplitNode"); throwIf(!ImGuiDockNode_IsSplitNode);
		*(cast(void**)&ImGuiDockNode_Rect) = GetProcAddress(handle, "ImGuiDockNode_Rect"); throwIf(!ImGuiDockNode_Rect);
		*(cast(void**)&ImGuiDockNode_SetLocalFlags) = GetProcAddress(handle, "ImGuiDockNode_SetLocalFlags"); throwIf(!ImGuiDockNode_SetLocalFlags);
		*(cast(void**)&ImGuiDockNode_UpdateMergedFlags) = GetProcAddress(handle, "ImGuiDockNode_UpdateMergedFlags"); throwIf(!ImGuiDockNode_UpdateMergedFlags);
		*(cast(void**)&ImGuiDockNode_destroy) = GetProcAddress(handle, "ImGuiDockNode_destroy"); throwIf(!ImGuiDockNode_destroy);
		*(cast(void**)&ImGuiIDStackTool_ImGuiIDStackTool) = GetProcAddress(handle, "ImGuiIDStackTool_ImGuiIDStackTool"); throwIf(!ImGuiIDStackTool_ImGuiIDStackTool);
		*(cast(void**)&ImGuiIDStackTool_destroy) = GetProcAddress(handle, "ImGuiIDStackTool_destroy"); throwIf(!ImGuiIDStackTool_destroy);
		*(cast(void**)&ImGuiIO_AddFocusEvent) = GetProcAddress(handle, "ImGuiIO_AddFocusEvent"); throwIf(!ImGuiIO_AddFocusEvent);
		*(cast(void**)&ImGuiIO_AddInputCharacter) = GetProcAddress(handle, "ImGuiIO_AddInputCharacter"); throwIf(!ImGuiIO_AddInputCharacter);
		*(cast(void**)&ImGuiIO_AddInputCharacterUTF16) = GetProcAddress(handle, "ImGuiIO_AddInputCharacterUTF16"); throwIf(!ImGuiIO_AddInputCharacterUTF16);
		*(cast(void**)&ImGuiIO_AddInputCharactersUTF8) = GetProcAddress(handle, "ImGuiIO_AddInputCharactersUTF8"); throwIf(!ImGuiIO_AddInputCharactersUTF8);
		*(cast(void**)&ImGuiIO_AddKeyAnalogEvent) = GetProcAddress(handle, "ImGuiIO_AddKeyAnalogEvent"); throwIf(!ImGuiIO_AddKeyAnalogEvent);
		*(cast(void**)&ImGuiIO_AddKeyEvent) = GetProcAddress(handle, "ImGuiIO_AddKeyEvent"); throwIf(!ImGuiIO_AddKeyEvent);
		*(cast(void**)&ImGuiIO_AddMouseButtonEvent) = GetProcAddress(handle, "ImGuiIO_AddMouseButtonEvent"); throwIf(!ImGuiIO_AddMouseButtonEvent);
		*(cast(void**)&ImGuiIO_AddMousePosEvent) = GetProcAddress(handle, "ImGuiIO_AddMousePosEvent"); throwIf(!ImGuiIO_AddMousePosEvent);
		*(cast(void**)&ImGuiIO_AddMouseSourceEvent) = GetProcAddress(handle, "ImGuiIO_AddMouseSourceEvent"); throwIf(!ImGuiIO_AddMouseSourceEvent);
		*(cast(void**)&ImGuiIO_AddMouseViewportEvent) = GetProcAddress(handle, "ImGuiIO_AddMouseViewportEvent"); throwIf(!ImGuiIO_AddMouseViewportEvent);
		*(cast(void**)&ImGuiIO_AddMouseWheelEvent) = GetProcAddress(handle, "ImGuiIO_AddMouseWheelEvent"); throwIf(!ImGuiIO_AddMouseWheelEvent);
		*(cast(void**)&ImGuiIO_ClearEventsQueue) = GetProcAddress(handle, "ImGuiIO_ClearEventsQueue"); throwIf(!ImGuiIO_ClearEventsQueue);
		*(cast(void**)&ImGuiIO_ClearInputKeys) = GetProcAddress(handle, "ImGuiIO_ClearInputKeys"); throwIf(!ImGuiIO_ClearInputKeys);
		*(cast(void**)&ImGuiIO_ClearInputMouse) = GetProcAddress(handle, "ImGuiIO_ClearInputMouse"); throwIf(!ImGuiIO_ClearInputMouse);
		*(cast(void**)&ImGuiIO_ImGuiIO) = GetProcAddress(handle, "ImGuiIO_ImGuiIO"); throwIf(!ImGuiIO_ImGuiIO);
		*(cast(void**)&ImGuiIO_SetAppAcceptingEvents) = GetProcAddress(handle, "ImGuiIO_SetAppAcceptingEvents"); throwIf(!ImGuiIO_SetAppAcceptingEvents);
		*(cast(void**)&ImGuiIO_SetKeyEventNativeData) = GetProcAddress(handle, "ImGuiIO_SetKeyEventNativeData"); throwIf(!ImGuiIO_SetKeyEventNativeData);
		*(cast(void**)&ImGuiIO_destroy) = GetProcAddress(handle, "ImGuiIO_destroy"); throwIf(!ImGuiIO_destroy);
		*(cast(void**)&ImGuiInputEvent_ImGuiInputEvent) = GetProcAddress(handle, "ImGuiInputEvent_ImGuiInputEvent"); throwIf(!ImGuiInputEvent_ImGuiInputEvent);
		*(cast(void**)&ImGuiInputEvent_destroy) = GetProcAddress(handle, "ImGuiInputEvent_destroy"); throwIf(!ImGuiInputEvent_destroy);
		*(cast(void**)&ImGuiInputTextCallbackData_ClearSelection) = GetProcAddress(handle, "ImGuiInputTextCallbackData_ClearSelection"); throwIf(!ImGuiInputTextCallbackData_ClearSelection);
		*(cast(void**)&ImGuiInputTextCallbackData_DeleteChars) = GetProcAddress(handle, "ImGuiInputTextCallbackData_DeleteChars"); throwIf(!ImGuiInputTextCallbackData_DeleteChars);
		*(cast(void**)&ImGuiInputTextCallbackData_HasSelection) = GetProcAddress(handle, "ImGuiInputTextCallbackData_HasSelection"); throwIf(!ImGuiInputTextCallbackData_HasSelection);
		*(cast(void**)&ImGuiInputTextCallbackData_ImGuiInputTextCallbackData) = GetProcAddress(handle, "ImGuiInputTextCallbackData_ImGuiInputTextCallbackData"); throwIf(!ImGuiInputTextCallbackData_ImGuiInputTextCallbackData);
		*(cast(void**)&ImGuiInputTextCallbackData_InsertChars) = GetProcAddress(handle, "ImGuiInputTextCallbackData_InsertChars"); throwIf(!ImGuiInputTextCallbackData_InsertChars);
		*(cast(void**)&ImGuiInputTextCallbackData_SelectAll) = GetProcAddress(handle, "ImGuiInputTextCallbackData_SelectAll"); throwIf(!ImGuiInputTextCallbackData_SelectAll);
		*(cast(void**)&ImGuiInputTextCallbackData_destroy) = GetProcAddress(handle, "ImGuiInputTextCallbackData_destroy"); throwIf(!ImGuiInputTextCallbackData_destroy);
		*(cast(void**)&ImGuiInputTextDeactivatedState_ClearFreeMemory) = GetProcAddress(handle, "ImGuiInputTextDeactivatedState_ClearFreeMemory"); throwIf(!ImGuiInputTextDeactivatedState_ClearFreeMemory);
		*(cast(void**)&ImGuiInputTextDeactivatedState_ImGuiInputTextDeactivatedState) = GetProcAddress(handle, "ImGuiInputTextDeactivatedState_ImGuiInputTextDeactivatedState"); throwIf(!ImGuiInputTextDeactivatedState_ImGuiInputTextDeactivatedState);
		*(cast(void**)&ImGuiInputTextDeactivatedState_destroy) = GetProcAddress(handle, "ImGuiInputTextDeactivatedState_destroy"); throwIf(!ImGuiInputTextDeactivatedState_destroy);
		*(cast(void**)&ImGuiInputTextState_ClearFreeMemory) = GetProcAddress(handle, "ImGuiInputTextState_ClearFreeMemory"); throwIf(!ImGuiInputTextState_ClearFreeMemory);
		*(cast(void**)&ImGuiInputTextState_ClearSelection) = GetProcAddress(handle, "ImGuiInputTextState_ClearSelection"); throwIf(!ImGuiInputTextState_ClearSelection);
		*(cast(void**)&ImGuiInputTextState_ClearText) = GetProcAddress(handle, "ImGuiInputTextState_ClearText"); throwIf(!ImGuiInputTextState_ClearText);
		*(cast(void**)&ImGuiInputTextState_CursorAnimReset) = GetProcAddress(handle, "ImGuiInputTextState_CursorAnimReset"); throwIf(!ImGuiInputTextState_CursorAnimReset);
		*(cast(void**)&ImGuiInputTextState_CursorClamp) = GetProcAddress(handle, "ImGuiInputTextState_CursorClamp"); throwIf(!ImGuiInputTextState_CursorClamp);
		*(cast(void**)&ImGuiInputTextState_GetCursorPos) = GetProcAddress(handle, "ImGuiInputTextState_GetCursorPos"); throwIf(!ImGuiInputTextState_GetCursorPos);
		*(cast(void**)&ImGuiInputTextState_GetRedoAvailCount) = GetProcAddress(handle, "ImGuiInputTextState_GetRedoAvailCount"); throwIf(!ImGuiInputTextState_GetRedoAvailCount);
		*(cast(void**)&ImGuiInputTextState_GetSelectionEnd) = GetProcAddress(handle, "ImGuiInputTextState_GetSelectionEnd"); throwIf(!ImGuiInputTextState_GetSelectionEnd);
		*(cast(void**)&ImGuiInputTextState_GetSelectionStart) = GetProcAddress(handle, "ImGuiInputTextState_GetSelectionStart"); throwIf(!ImGuiInputTextState_GetSelectionStart);
		*(cast(void**)&ImGuiInputTextState_GetUndoAvailCount) = GetProcAddress(handle, "ImGuiInputTextState_GetUndoAvailCount"); throwIf(!ImGuiInputTextState_GetUndoAvailCount);
		*(cast(void**)&ImGuiInputTextState_HasSelection) = GetProcAddress(handle, "ImGuiInputTextState_HasSelection"); throwIf(!ImGuiInputTextState_HasSelection);
		*(cast(void**)&ImGuiInputTextState_ImGuiInputTextState) = GetProcAddress(handle, "ImGuiInputTextState_ImGuiInputTextState"); throwIf(!ImGuiInputTextState_ImGuiInputTextState);
		*(cast(void**)&ImGuiInputTextState_OnKeyPressed) = GetProcAddress(handle, "ImGuiInputTextState_OnKeyPressed"); throwIf(!ImGuiInputTextState_OnKeyPressed);
		*(cast(void**)&ImGuiInputTextState_ReloadUserBufAndKeepSelection) = GetProcAddress(handle, "ImGuiInputTextState_ReloadUserBufAndKeepSelection"); throwIf(!ImGuiInputTextState_ReloadUserBufAndKeepSelection);
		*(cast(void**)&ImGuiInputTextState_ReloadUserBufAndMoveToEnd) = GetProcAddress(handle, "ImGuiInputTextState_ReloadUserBufAndMoveToEnd"); throwIf(!ImGuiInputTextState_ReloadUserBufAndMoveToEnd);
		*(cast(void**)&ImGuiInputTextState_ReloadUserBufAndSelectAll) = GetProcAddress(handle, "ImGuiInputTextState_ReloadUserBufAndSelectAll"); throwIf(!ImGuiInputTextState_ReloadUserBufAndSelectAll);
		*(cast(void**)&ImGuiInputTextState_SelectAll) = GetProcAddress(handle, "ImGuiInputTextState_SelectAll"); throwIf(!ImGuiInputTextState_SelectAll);
		*(cast(void**)&ImGuiInputTextState_destroy) = GetProcAddress(handle, "ImGuiInputTextState_destroy"); throwIf(!ImGuiInputTextState_destroy);
		*(cast(void**)&ImGuiKeyOwnerData_ImGuiKeyOwnerData) = GetProcAddress(handle, "ImGuiKeyOwnerData_ImGuiKeyOwnerData"); throwIf(!ImGuiKeyOwnerData_ImGuiKeyOwnerData);
		*(cast(void**)&ImGuiKeyOwnerData_destroy) = GetProcAddress(handle, "ImGuiKeyOwnerData_destroy"); throwIf(!ImGuiKeyOwnerData_destroy);
		*(cast(void**)&ImGuiKeyRoutingData_ImGuiKeyRoutingData) = GetProcAddress(handle, "ImGuiKeyRoutingData_ImGuiKeyRoutingData"); throwIf(!ImGuiKeyRoutingData_ImGuiKeyRoutingData);
		*(cast(void**)&ImGuiKeyRoutingData_destroy) = GetProcAddress(handle, "ImGuiKeyRoutingData_destroy"); throwIf(!ImGuiKeyRoutingData_destroy);
		*(cast(void**)&ImGuiKeyRoutingTable_Clear) = GetProcAddress(handle, "ImGuiKeyRoutingTable_Clear"); throwIf(!ImGuiKeyRoutingTable_Clear);
		*(cast(void**)&ImGuiKeyRoutingTable_ImGuiKeyRoutingTable) = GetProcAddress(handle, "ImGuiKeyRoutingTable_ImGuiKeyRoutingTable"); throwIf(!ImGuiKeyRoutingTable_ImGuiKeyRoutingTable);
		*(cast(void**)&ImGuiKeyRoutingTable_destroy) = GetProcAddress(handle, "ImGuiKeyRoutingTable_destroy"); throwIf(!ImGuiKeyRoutingTable_destroy);
		*(cast(void**)&ImGuiLastItemData_ImGuiLastItemData) = GetProcAddress(handle, "ImGuiLastItemData_ImGuiLastItemData"); throwIf(!ImGuiLastItemData_ImGuiLastItemData);
		*(cast(void**)&ImGuiLastItemData_destroy) = GetProcAddress(handle, "ImGuiLastItemData_destroy"); throwIf(!ImGuiLastItemData_destroy);
		*(cast(void**)&ImGuiListClipperData_ImGuiListClipperData) = GetProcAddress(handle, "ImGuiListClipperData_ImGuiListClipperData"); throwIf(!ImGuiListClipperData_ImGuiListClipperData);
		*(cast(void**)&ImGuiListClipperData_Reset) = GetProcAddress(handle, "ImGuiListClipperData_Reset"); throwIf(!ImGuiListClipperData_Reset);
		*(cast(void**)&ImGuiListClipperData_destroy) = GetProcAddress(handle, "ImGuiListClipperData_destroy"); throwIf(!ImGuiListClipperData_destroy);
		*(cast(void**)&ImGuiListClipperRange_FromIndices) = GetProcAddress(handle, "ImGuiListClipperRange_FromIndices"); throwIf(!ImGuiListClipperRange_FromIndices);
		*(cast(void**)&ImGuiListClipperRange_FromPositions) = GetProcAddress(handle, "ImGuiListClipperRange_FromPositions"); throwIf(!ImGuiListClipperRange_FromPositions);
		*(cast(void**)&ImGuiListClipper_Begin) = GetProcAddress(handle, "ImGuiListClipper_Begin"); throwIf(!ImGuiListClipper_Begin);
		*(cast(void**)&ImGuiListClipper_End) = GetProcAddress(handle, "ImGuiListClipper_End"); throwIf(!ImGuiListClipper_End);
		*(cast(void**)&ImGuiListClipper_ImGuiListClipper) = GetProcAddress(handle, "ImGuiListClipper_ImGuiListClipper"); throwIf(!ImGuiListClipper_ImGuiListClipper);
		*(cast(void**)&ImGuiListClipper_IncludeItemByIndex) = GetProcAddress(handle, "ImGuiListClipper_IncludeItemByIndex"); throwIf(!ImGuiListClipper_IncludeItemByIndex);
		*(cast(void**)&ImGuiListClipper_IncludeItemsByIndex) = GetProcAddress(handle, "ImGuiListClipper_IncludeItemsByIndex"); throwIf(!ImGuiListClipper_IncludeItemsByIndex);
		*(cast(void**)&ImGuiListClipper_SeekCursorForItem) = GetProcAddress(handle, "ImGuiListClipper_SeekCursorForItem"); throwIf(!ImGuiListClipper_SeekCursorForItem);
		*(cast(void**)&ImGuiListClipper_Step) = GetProcAddress(handle, "ImGuiListClipper_Step"); throwIf(!ImGuiListClipper_Step);
		*(cast(void**)&ImGuiListClipper_destroy) = GetProcAddress(handle, "ImGuiListClipper_destroy"); throwIf(!ImGuiListClipper_destroy);
		*(cast(void**)&ImGuiMenuColumns_CalcNextTotalWidth) = GetProcAddress(handle, "ImGuiMenuColumns_CalcNextTotalWidth"); throwIf(!ImGuiMenuColumns_CalcNextTotalWidth);
		*(cast(void**)&ImGuiMenuColumns_DeclColumns) = GetProcAddress(handle, "ImGuiMenuColumns_DeclColumns"); throwIf(!ImGuiMenuColumns_DeclColumns);
		*(cast(void**)&ImGuiMenuColumns_ImGuiMenuColumns) = GetProcAddress(handle, "ImGuiMenuColumns_ImGuiMenuColumns"); throwIf(!ImGuiMenuColumns_ImGuiMenuColumns);
		*(cast(void**)&ImGuiMenuColumns_Update) = GetProcAddress(handle, "ImGuiMenuColumns_Update"); throwIf(!ImGuiMenuColumns_Update);
		*(cast(void**)&ImGuiMenuColumns_destroy) = GetProcAddress(handle, "ImGuiMenuColumns_destroy"); throwIf(!ImGuiMenuColumns_destroy);
		*(cast(void**)&ImGuiMultiSelectState_ImGuiMultiSelectState) = GetProcAddress(handle, "ImGuiMultiSelectState_ImGuiMultiSelectState"); throwIf(!ImGuiMultiSelectState_ImGuiMultiSelectState);
		*(cast(void**)&ImGuiMultiSelectState_destroy) = GetProcAddress(handle, "ImGuiMultiSelectState_destroy"); throwIf(!ImGuiMultiSelectState_destroy);
		*(cast(void**)&ImGuiMultiSelectTempData_Clear) = GetProcAddress(handle, "ImGuiMultiSelectTempData_Clear"); throwIf(!ImGuiMultiSelectTempData_Clear);
		*(cast(void**)&ImGuiMultiSelectTempData_ClearIO) = GetProcAddress(handle, "ImGuiMultiSelectTempData_ClearIO"); throwIf(!ImGuiMultiSelectTempData_ClearIO);
		*(cast(void**)&ImGuiMultiSelectTempData_ImGuiMultiSelectTempData) = GetProcAddress(handle, "ImGuiMultiSelectTempData_ImGuiMultiSelectTempData"); throwIf(!ImGuiMultiSelectTempData_ImGuiMultiSelectTempData);
		*(cast(void**)&ImGuiMultiSelectTempData_destroy) = GetProcAddress(handle, "ImGuiMultiSelectTempData_destroy"); throwIf(!ImGuiMultiSelectTempData_destroy);
		*(cast(void**)&ImGuiNavItemData_Clear) = GetProcAddress(handle, "ImGuiNavItemData_Clear"); throwIf(!ImGuiNavItemData_Clear);
		*(cast(void**)&ImGuiNavItemData_ImGuiNavItemData) = GetProcAddress(handle, "ImGuiNavItemData_ImGuiNavItemData"); throwIf(!ImGuiNavItemData_ImGuiNavItemData);
		*(cast(void**)&ImGuiNavItemData_destroy) = GetProcAddress(handle, "ImGuiNavItemData_destroy"); throwIf(!ImGuiNavItemData_destroy);
		*(cast(void**)&ImGuiNextItemData_ClearFlags) = GetProcAddress(handle, "ImGuiNextItemData_ClearFlags"); throwIf(!ImGuiNextItemData_ClearFlags);
		*(cast(void**)&ImGuiNextItemData_ImGuiNextItemData) = GetProcAddress(handle, "ImGuiNextItemData_ImGuiNextItemData"); throwIf(!ImGuiNextItemData_ImGuiNextItemData);
		*(cast(void**)&ImGuiNextItemData_destroy) = GetProcAddress(handle, "ImGuiNextItemData_destroy"); throwIf(!ImGuiNextItemData_destroy);
		*(cast(void**)&ImGuiNextWindowData_ClearFlags) = GetProcAddress(handle, "ImGuiNextWindowData_ClearFlags"); throwIf(!ImGuiNextWindowData_ClearFlags);
		*(cast(void**)&ImGuiNextWindowData_ImGuiNextWindowData) = GetProcAddress(handle, "ImGuiNextWindowData_ImGuiNextWindowData"); throwIf(!ImGuiNextWindowData_ImGuiNextWindowData);
		*(cast(void**)&ImGuiNextWindowData_destroy) = GetProcAddress(handle, "ImGuiNextWindowData_destroy"); throwIf(!ImGuiNextWindowData_destroy);
		*(cast(void**)&ImGuiOldColumnData_ImGuiOldColumnData) = GetProcAddress(handle, "ImGuiOldColumnData_ImGuiOldColumnData"); throwIf(!ImGuiOldColumnData_ImGuiOldColumnData);
		*(cast(void**)&ImGuiOldColumnData_destroy) = GetProcAddress(handle, "ImGuiOldColumnData_destroy"); throwIf(!ImGuiOldColumnData_destroy);
		*(cast(void**)&ImGuiOldColumns_ImGuiOldColumns) = GetProcAddress(handle, "ImGuiOldColumns_ImGuiOldColumns"); throwIf(!ImGuiOldColumns_ImGuiOldColumns);
		*(cast(void**)&ImGuiOldColumns_destroy) = GetProcAddress(handle, "ImGuiOldColumns_destroy"); throwIf(!ImGuiOldColumns_destroy);
		*(cast(void**)&ImGuiOnceUponAFrame_ImGuiOnceUponAFrame) = GetProcAddress(handle, "ImGuiOnceUponAFrame_ImGuiOnceUponAFrame"); throwIf(!ImGuiOnceUponAFrame_ImGuiOnceUponAFrame);
		*(cast(void**)&ImGuiOnceUponAFrame_destroy) = GetProcAddress(handle, "ImGuiOnceUponAFrame_destroy"); throwIf(!ImGuiOnceUponAFrame_destroy);
		*(cast(void**)&ImGuiPayload_Clear) = GetProcAddress(handle, "ImGuiPayload_Clear"); throwIf(!ImGuiPayload_Clear);
		*(cast(void**)&ImGuiPayload_ImGuiPayload) = GetProcAddress(handle, "ImGuiPayload_ImGuiPayload"); throwIf(!ImGuiPayload_ImGuiPayload);
		*(cast(void**)&ImGuiPayload_IsDataType) = GetProcAddress(handle, "ImGuiPayload_IsDataType"); throwIf(!ImGuiPayload_IsDataType);
		*(cast(void**)&ImGuiPayload_IsDelivery) = GetProcAddress(handle, "ImGuiPayload_IsDelivery"); throwIf(!ImGuiPayload_IsDelivery);
		*(cast(void**)&ImGuiPayload_IsPreview) = GetProcAddress(handle, "ImGuiPayload_IsPreview"); throwIf(!ImGuiPayload_IsPreview);
		*(cast(void**)&ImGuiPayload_destroy) = GetProcAddress(handle, "ImGuiPayload_destroy"); throwIf(!ImGuiPayload_destroy);
		*(cast(void**)&ImGuiPlatformIO_ImGuiPlatformIO) = GetProcAddress(handle, "ImGuiPlatformIO_ImGuiPlatformIO"); throwIf(!ImGuiPlatformIO_ImGuiPlatformIO);
		*(cast(void**)&ImGuiPlatformIO_Set_Platform_GetWindowPos) = GetProcAddress(handle, "ImGuiPlatformIO_Set_Platform_GetWindowPos"); throwIf(!ImGuiPlatformIO_Set_Platform_GetWindowPos);
		*(cast(void**)&ImGuiPlatformIO_Set_Platform_GetWindowSize) = GetProcAddress(handle, "ImGuiPlatformIO_Set_Platform_GetWindowSize"); throwIf(!ImGuiPlatformIO_Set_Platform_GetWindowSize);
		*(cast(void**)&ImGuiPlatformIO_destroy) = GetProcAddress(handle, "ImGuiPlatformIO_destroy"); throwIf(!ImGuiPlatformIO_destroy);
		*(cast(void**)&ImGuiPlatformImeData_ImGuiPlatformImeData) = GetProcAddress(handle, "ImGuiPlatformImeData_ImGuiPlatformImeData"); throwIf(!ImGuiPlatformImeData_ImGuiPlatformImeData);
		*(cast(void**)&ImGuiPlatformImeData_destroy) = GetProcAddress(handle, "ImGuiPlatformImeData_destroy"); throwIf(!ImGuiPlatformImeData_destroy);
		*(cast(void**)&ImGuiPlatformMonitor_ImGuiPlatformMonitor) = GetProcAddress(handle, "ImGuiPlatformMonitor_ImGuiPlatformMonitor"); throwIf(!ImGuiPlatformMonitor_ImGuiPlatformMonitor);
		*(cast(void**)&ImGuiPlatformMonitor_destroy) = GetProcAddress(handle, "ImGuiPlatformMonitor_destroy"); throwIf(!ImGuiPlatformMonitor_destroy);
		*(cast(void**)&ImGuiPopupData_ImGuiPopupData) = GetProcAddress(handle, "ImGuiPopupData_ImGuiPopupData"); throwIf(!ImGuiPopupData_ImGuiPopupData);
		*(cast(void**)&ImGuiPopupData_destroy) = GetProcAddress(handle, "ImGuiPopupData_destroy"); throwIf(!ImGuiPopupData_destroy);
		*(cast(void**)&ImGuiPtrOrIndex_ImGuiPtrOrIndex_Int) = GetProcAddress(handle, "ImGuiPtrOrIndex_ImGuiPtrOrIndex_Int"); throwIf(!ImGuiPtrOrIndex_ImGuiPtrOrIndex_Int);
		*(cast(void**)&ImGuiPtrOrIndex_ImGuiPtrOrIndex_Ptr) = GetProcAddress(handle, "ImGuiPtrOrIndex_ImGuiPtrOrIndex_Ptr"); throwIf(!ImGuiPtrOrIndex_ImGuiPtrOrIndex_Ptr);
		*(cast(void**)&ImGuiPtrOrIndex_destroy) = GetProcAddress(handle, "ImGuiPtrOrIndex_destroy"); throwIf(!ImGuiPtrOrIndex_destroy);
		*(cast(void**)&ImGuiSelectionBasicStorage_ApplyRequests) = GetProcAddress(handle, "ImGuiSelectionBasicStorage_ApplyRequests"); throwIf(!ImGuiSelectionBasicStorage_ApplyRequests);
		*(cast(void**)&ImGuiSelectionBasicStorage_Clear) = GetProcAddress(handle, "ImGuiSelectionBasicStorage_Clear"); throwIf(!ImGuiSelectionBasicStorage_Clear);
		*(cast(void**)&ImGuiSelectionBasicStorage_Contains) = GetProcAddress(handle, "ImGuiSelectionBasicStorage_Contains"); throwIf(!ImGuiSelectionBasicStorage_Contains);
		*(cast(void**)&ImGuiSelectionBasicStorage_GetNextSelectedItem) = GetProcAddress(handle, "ImGuiSelectionBasicStorage_GetNextSelectedItem"); throwIf(!ImGuiSelectionBasicStorage_GetNextSelectedItem);
		*(cast(void**)&ImGuiSelectionBasicStorage_GetStorageIdFromIndex) = GetProcAddress(handle, "ImGuiSelectionBasicStorage_GetStorageIdFromIndex"); throwIf(!ImGuiSelectionBasicStorage_GetStorageIdFromIndex);
		*(cast(void**)&ImGuiSelectionBasicStorage_ImGuiSelectionBasicStorage) = GetProcAddress(handle, "ImGuiSelectionBasicStorage_ImGuiSelectionBasicStorage"); throwIf(!ImGuiSelectionBasicStorage_ImGuiSelectionBasicStorage);
		*(cast(void**)&ImGuiSelectionBasicStorage_SetItemSelected) = GetProcAddress(handle, "ImGuiSelectionBasicStorage_SetItemSelected"); throwIf(!ImGuiSelectionBasicStorage_SetItemSelected);
		*(cast(void**)&ImGuiSelectionBasicStorage_Swap) = GetProcAddress(handle, "ImGuiSelectionBasicStorage_Swap"); throwIf(!ImGuiSelectionBasicStorage_Swap);
		*(cast(void**)&ImGuiSelectionBasicStorage_destroy) = GetProcAddress(handle, "ImGuiSelectionBasicStorage_destroy"); throwIf(!ImGuiSelectionBasicStorage_destroy);
		*(cast(void**)&ImGuiSelectionExternalStorage_ApplyRequests) = GetProcAddress(handle, "ImGuiSelectionExternalStorage_ApplyRequests"); throwIf(!ImGuiSelectionExternalStorage_ApplyRequests);
		*(cast(void**)&ImGuiSelectionExternalStorage_ImGuiSelectionExternalStorage) = GetProcAddress(handle, "ImGuiSelectionExternalStorage_ImGuiSelectionExternalStorage"); throwIf(!ImGuiSelectionExternalStorage_ImGuiSelectionExternalStorage);
		*(cast(void**)&ImGuiSelectionExternalStorage_destroy) = GetProcAddress(handle, "ImGuiSelectionExternalStorage_destroy"); throwIf(!ImGuiSelectionExternalStorage_destroy);
		*(cast(void**)&ImGuiSettingsHandler_ImGuiSettingsHandler) = GetProcAddress(handle, "ImGuiSettingsHandler_ImGuiSettingsHandler"); throwIf(!ImGuiSettingsHandler_ImGuiSettingsHandler);
		*(cast(void**)&ImGuiSettingsHandler_destroy) = GetProcAddress(handle, "ImGuiSettingsHandler_destroy"); throwIf(!ImGuiSettingsHandler_destroy);
		*(cast(void**)&ImGuiStackLevelInfo_ImGuiStackLevelInfo) = GetProcAddress(handle, "ImGuiStackLevelInfo_ImGuiStackLevelInfo"); throwIf(!ImGuiStackLevelInfo_ImGuiStackLevelInfo);
		*(cast(void**)&ImGuiStackLevelInfo_destroy) = GetProcAddress(handle, "ImGuiStackLevelInfo_destroy"); throwIf(!ImGuiStackLevelInfo_destroy);
		*(cast(void**)&ImGuiStackSizes_CompareWithContextState) = GetProcAddress(handle, "ImGuiStackSizes_CompareWithContextState"); throwIf(!ImGuiStackSizes_CompareWithContextState);
		*(cast(void**)&ImGuiStackSizes_ImGuiStackSizes) = GetProcAddress(handle, "ImGuiStackSizes_ImGuiStackSizes"); throwIf(!ImGuiStackSizes_ImGuiStackSizes);
		*(cast(void**)&ImGuiStackSizes_SetToContextState) = GetProcAddress(handle, "ImGuiStackSizes_SetToContextState"); throwIf(!ImGuiStackSizes_SetToContextState);
		*(cast(void**)&ImGuiStackSizes_destroy) = GetProcAddress(handle, "ImGuiStackSizes_destroy"); throwIf(!ImGuiStackSizes_destroy);
		*(cast(void**)&ImGuiStoragePair_ImGuiStoragePair_Float) = GetProcAddress(handle, "ImGuiStoragePair_ImGuiStoragePair_Float"); throwIf(!ImGuiStoragePair_ImGuiStoragePair_Float);
		*(cast(void**)&ImGuiStoragePair_ImGuiStoragePair_Int) = GetProcAddress(handle, "ImGuiStoragePair_ImGuiStoragePair_Int"); throwIf(!ImGuiStoragePair_ImGuiStoragePair_Int);
		*(cast(void**)&ImGuiStoragePair_ImGuiStoragePair_Ptr) = GetProcAddress(handle, "ImGuiStoragePair_ImGuiStoragePair_Ptr"); throwIf(!ImGuiStoragePair_ImGuiStoragePair_Ptr);
		*(cast(void**)&ImGuiStoragePair_destroy) = GetProcAddress(handle, "ImGuiStoragePair_destroy"); throwIf(!ImGuiStoragePair_destroy);
		*(cast(void**)&ImGuiStorage_BuildSortByKey) = GetProcAddress(handle, "ImGuiStorage_BuildSortByKey"); throwIf(!ImGuiStorage_BuildSortByKey);
		*(cast(void**)&ImGuiStorage_Clear) = GetProcAddress(handle, "ImGuiStorage_Clear"); throwIf(!ImGuiStorage_Clear);
		*(cast(void**)&ImGuiStorage_GetBool) = GetProcAddress(handle, "ImGuiStorage_GetBool"); throwIf(!ImGuiStorage_GetBool);
		*(cast(void**)&ImGuiStorage_GetBoolRef) = GetProcAddress(handle, "ImGuiStorage_GetBoolRef"); throwIf(!ImGuiStorage_GetBoolRef);
		*(cast(void**)&ImGuiStorage_GetFloat) = GetProcAddress(handle, "ImGuiStorage_GetFloat"); throwIf(!ImGuiStorage_GetFloat);
		*(cast(void**)&ImGuiStorage_GetFloatRef) = GetProcAddress(handle, "ImGuiStorage_GetFloatRef"); throwIf(!ImGuiStorage_GetFloatRef);
		*(cast(void**)&ImGuiStorage_GetInt) = GetProcAddress(handle, "ImGuiStorage_GetInt"); throwIf(!ImGuiStorage_GetInt);
		*(cast(void**)&ImGuiStorage_GetIntRef) = GetProcAddress(handle, "ImGuiStorage_GetIntRef"); throwIf(!ImGuiStorage_GetIntRef);
		*(cast(void**)&ImGuiStorage_GetVoidPtr) = GetProcAddress(handle, "ImGuiStorage_GetVoidPtr"); throwIf(!ImGuiStorage_GetVoidPtr);
		*(cast(void**)&ImGuiStorage_GetVoidPtrRef) = GetProcAddress(handle, "ImGuiStorage_GetVoidPtrRef"); throwIf(!ImGuiStorage_GetVoidPtrRef);
		*(cast(void**)&ImGuiStorage_SetAllInt) = GetProcAddress(handle, "ImGuiStorage_SetAllInt"); throwIf(!ImGuiStorage_SetAllInt);
		*(cast(void**)&ImGuiStorage_SetBool) = GetProcAddress(handle, "ImGuiStorage_SetBool"); throwIf(!ImGuiStorage_SetBool);
		*(cast(void**)&ImGuiStorage_SetFloat) = GetProcAddress(handle, "ImGuiStorage_SetFloat"); throwIf(!ImGuiStorage_SetFloat);
		*(cast(void**)&ImGuiStorage_SetInt) = GetProcAddress(handle, "ImGuiStorage_SetInt"); throwIf(!ImGuiStorage_SetInt);
		*(cast(void**)&ImGuiStorage_SetVoidPtr) = GetProcAddress(handle, "ImGuiStorage_SetVoidPtr"); throwIf(!ImGuiStorage_SetVoidPtr);
		*(cast(void**)&ImGuiStyleMod_ImGuiStyleMod_Float) = GetProcAddress(handle, "ImGuiStyleMod_ImGuiStyleMod_Float"); throwIf(!ImGuiStyleMod_ImGuiStyleMod_Float);
		*(cast(void**)&ImGuiStyleMod_ImGuiStyleMod_Int) = GetProcAddress(handle, "ImGuiStyleMod_ImGuiStyleMod_Int"); throwIf(!ImGuiStyleMod_ImGuiStyleMod_Int);
		*(cast(void**)&ImGuiStyleMod_ImGuiStyleMod_Vec2) = GetProcAddress(handle, "ImGuiStyleMod_ImGuiStyleMod_Vec2"); throwIf(!ImGuiStyleMod_ImGuiStyleMod_Vec2);
		*(cast(void**)&ImGuiStyleMod_destroy) = GetProcAddress(handle, "ImGuiStyleMod_destroy"); throwIf(!ImGuiStyleMod_destroy);
		*(cast(void**)&ImGuiStyle_ImGuiStyle) = GetProcAddress(handle, "ImGuiStyle_ImGuiStyle"); throwIf(!ImGuiStyle_ImGuiStyle);
		*(cast(void**)&ImGuiStyle_ScaleAllSizes) = GetProcAddress(handle, "ImGuiStyle_ScaleAllSizes"); throwIf(!ImGuiStyle_ScaleAllSizes);
		*(cast(void**)&ImGuiStyle_destroy) = GetProcAddress(handle, "ImGuiStyle_destroy"); throwIf(!ImGuiStyle_destroy);
		*(cast(void**)&ImGuiTabBar_ImGuiTabBar) = GetProcAddress(handle, "ImGuiTabBar_ImGuiTabBar"); throwIf(!ImGuiTabBar_ImGuiTabBar);
		*(cast(void**)&ImGuiTabBar_destroy) = GetProcAddress(handle, "ImGuiTabBar_destroy"); throwIf(!ImGuiTabBar_destroy);
		*(cast(void**)&ImGuiTabItem_ImGuiTabItem) = GetProcAddress(handle, "ImGuiTabItem_ImGuiTabItem"); throwIf(!ImGuiTabItem_ImGuiTabItem);
		*(cast(void**)&ImGuiTabItem_destroy) = GetProcAddress(handle, "ImGuiTabItem_destroy"); throwIf(!ImGuiTabItem_destroy);
		*(cast(void**)&ImGuiTableColumnSettings_ImGuiTableColumnSettings) = GetProcAddress(handle, "ImGuiTableColumnSettings_ImGuiTableColumnSettings"); throwIf(!ImGuiTableColumnSettings_ImGuiTableColumnSettings);
		*(cast(void**)&ImGuiTableColumnSettings_destroy) = GetProcAddress(handle, "ImGuiTableColumnSettings_destroy"); throwIf(!ImGuiTableColumnSettings_destroy);
		*(cast(void**)&ImGuiTableColumnSortSpecs_ImGuiTableColumnSortSpecs) = GetProcAddress(handle, "ImGuiTableColumnSortSpecs_ImGuiTableColumnSortSpecs"); throwIf(!ImGuiTableColumnSortSpecs_ImGuiTableColumnSortSpecs);
		*(cast(void**)&ImGuiTableColumnSortSpecs_destroy) = GetProcAddress(handle, "ImGuiTableColumnSortSpecs_destroy"); throwIf(!ImGuiTableColumnSortSpecs_destroy);
		*(cast(void**)&ImGuiTableColumn_ImGuiTableColumn) = GetProcAddress(handle, "ImGuiTableColumn_ImGuiTableColumn"); throwIf(!ImGuiTableColumn_ImGuiTableColumn);
		*(cast(void**)&ImGuiTableColumn_destroy) = GetProcAddress(handle, "ImGuiTableColumn_destroy"); throwIf(!ImGuiTableColumn_destroy);
		*(cast(void**)&ImGuiTableInstanceData_ImGuiTableInstanceData) = GetProcAddress(handle, "ImGuiTableInstanceData_ImGuiTableInstanceData"); throwIf(!ImGuiTableInstanceData_ImGuiTableInstanceData);
		*(cast(void**)&ImGuiTableInstanceData_destroy) = GetProcAddress(handle, "ImGuiTableInstanceData_destroy"); throwIf(!ImGuiTableInstanceData_destroy);
		*(cast(void**)&ImGuiTableSettings_GetColumnSettings) = GetProcAddress(handle, "ImGuiTableSettings_GetColumnSettings"); throwIf(!ImGuiTableSettings_GetColumnSettings);
		*(cast(void**)&ImGuiTableSettings_ImGuiTableSettings) = GetProcAddress(handle, "ImGuiTableSettings_ImGuiTableSettings"); throwIf(!ImGuiTableSettings_ImGuiTableSettings);
		*(cast(void**)&ImGuiTableSettings_destroy) = GetProcAddress(handle, "ImGuiTableSettings_destroy"); throwIf(!ImGuiTableSettings_destroy);
		*(cast(void**)&ImGuiTableSortSpecs_ImGuiTableSortSpecs) = GetProcAddress(handle, "ImGuiTableSortSpecs_ImGuiTableSortSpecs"); throwIf(!ImGuiTableSortSpecs_ImGuiTableSortSpecs);
		*(cast(void**)&ImGuiTableSortSpecs_destroy) = GetProcAddress(handle, "ImGuiTableSortSpecs_destroy"); throwIf(!ImGuiTableSortSpecs_destroy);
		*(cast(void**)&ImGuiTableTempData_ImGuiTableTempData) = GetProcAddress(handle, "ImGuiTableTempData_ImGuiTableTempData"); throwIf(!ImGuiTableTempData_ImGuiTableTempData);
		*(cast(void**)&ImGuiTableTempData_destroy) = GetProcAddress(handle, "ImGuiTableTempData_destroy"); throwIf(!ImGuiTableTempData_destroy);
		*(cast(void**)&ImGuiTable_ImGuiTable) = GetProcAddress(handle, "ImGuiTable_ImGuiTable"); throwIf(!ImGuiTable_ImGuiTable);
		*(cast(void**)&ImGuiTable_destroy) = GetProcAddress(handle, "ImGuiTable_destroy"); throwIf(!ImGuiTable_destroy);
		*(cast(void**)&ImGuiTextBuffer_ImGuiTextBuffer) = GetProcAddress(handle, "ImGuiTextBuffer_ImGuiTextBuffer"); throwIf(!ImGuiTextBuffer_ImGuiTextBuffer);
		*(cast(void**)&ImGuiTextBuffer_append) = GetProcAddress(handle, "ImGuiTextBuffer_append"); throwIf(!ImGuiTextBuffer_append);
		*(cast(void**)&ImGuiTextBuffer_appendf) = GetProcAddress(handle, "ImGuiTextBuffer_appendf"); throwIf(!ImGuiTextBuffer_appendf);
		*(cast(void**)&ImGuiTextBuffer_appendfv) = GetProcAddress(handle, "ImGuiTextBuffer_appendfv"); throwIf(!ImGuiTextBuffer_appendfv);
		*(cast(void**)&ImGuiTextBuffer_begin) = GetProcAddress(handle, "ImGuiTextBuffer_begin"); throwIf(!ImGuiTextBuffer_begin);
		*(cast(void**)&ImGuiTextBuffer_c_str) = GetProcAddress(handle, "ImGuiTextBuffer_c_str"); throwIf(!ImGuiTextBuffer_c_str);
		*(cast(void**)&ImGuiTextBuffer_clear) = GetProcAddress(handle, "ImGuiTextBuffer_clear"); throwIf(!ImGuiTextBuffer_clear);
		*(cast(void**)&ImGuiTextBuffer_destroy) = GetProcAddress(handle, "ImGuiTextBuffer_destroy"); throwIf(!ImGuiTextBuffer_destroy);
		*(cast(void**)&ImGuiTextBuffer_empty) = GetProcAddress(handle, "ImGuiTextBuffer_empty"); throwIf(!ImGuiTextBuffer_empty);
		*(cast(void**)&ImGuiTextBuffer_end) = GetProcAddress(handle, "ImGuiTextBuffer_end"); throwIf(!ImGuiTextBuffer_end);
		*(cast(void**)&ImGuiTextBuffer_reserve) = GetProcAddress(handle, "ImGuiTextBuffer_reserve"); throwIf(!ImGuiTextBuffer_reserve);
		*(cast(void**)&ImGuiTextBuffer_size) = GetProcAddress(handle, "ImGuiTextBuffer_size"); throwIf(!ImGuiTextBuffer_size);
		*(cast(void**)&ImGuiTextFilter_Build) = GetProcAddress(handle, "ImGuiTextFilter_Build"); throwIf(!ImGuiTextFilter_Build);
		*(cast(void**)&ImGuiTextFilter_Clear) = GetProcAddress(handle, "ImGuiTextFilter_Clear"); throwIf(!ImGuiTextFilter_Clear);
		*(cast(void**)&ImGuiTextFilter_Draw) = GetProcAddress(handle, "ImGuiTextFilter_Draw"); throwIf(!ImGuiTextFilter_Draw);
		*(cast(void**)&ImGuiTextFilter_ImGuiTextFilter) = GetProcAddress(handle, "ImGuiTextFilter_ImGuiTextFilter"); throwIf(!ImGuiTextFilter_ImGuiTextFilter);
		*(cast(void**)&ImGuiTextFilter_IsActive) = GetProcAddress(handle, "ImGuiTextFilter_IsActive"); throwIf(!ImGuiTextFilter_IsActive);
		*(cast(void**)&ImGuiTextFilter_PassFilter) = GetProcAddress(handle, "ImGuiTextFilter_PassFilter"); throwIf(!ImGuiTextFilter_PassFilter);
		*(cast(void**)&ImGuiTextFilter_destroy) = GetProcAddress(handle, "ImGuiTextFilter_destroy"); throwIf(!ImGuiTextFilter_destroy);
		*(cast(void**)&ImGuiTextIndex_append) = GetProcAddress(handle, "ImGuiTextIndex_append"); throwIf(!ImGuiTextIndex_append);
		*(cast(void**)&ImGuiTextIndex_clear) = GetProcAddress(handle, "ImGuiTextIndex_clear"); throwIf(!ImGuiTextIndex_clear);
		*(cast(void**)&ImGuiTextIndex_get_line_begin) = GetProcAddress(handle, "ImGuiTextIndex_get_line_begin"); throwIf(!ImGuiTextIndex_get_line_begin);
		*(cast(void**)&ImGuiTextIndex_get_line_end) = GetProcAddress(handle, "ImGuiTextIndex_get_line_end"); throwIf(!ImGuiTextIndex_get_line_end);
		*(cast(void**)&ImGuiTextIndex_size) = GetProcAddress(handle, "ImGuiTextIndex_size"); throwIf(!ImGuiTextIndex_size);
		*(cast(void**)&ImGuiTextRange_ImGuiTextRange_Nil) = GetProcAddress(handle, "ImGuiTextRange_ImGuiTextRange_Nil"); throwIf(!ImGuiTextRange_ImGuiTextRange_Nil);
		*(cast(void**)&ImGuiTextRange_ImGuiTextRange_Str) = GetProcAddress(handle, "ImGuiTextRange_ImGuiTextRange_Str"); throwIf(!ImGuiTextRange_ImGuiTextRange_Str);
		*(cast(void**)&ImGuiTextRange_destroy) = GetProcAddress(handle, "ImGuiTextRange_destroy"); throwIf(!ImGuiTextRange_destroy);
		*(cast(void**)&ImGuiTextRange_empty) = GetProcAddress(handle, "ImGuiTextRange_empty"); throwIf(!ImGuiTextRange_empty);
		*(cast(void**)&ImGuiTextRange_split) = GetProcAddress(handle, "ImGuiTextRange_split"); throwIf(!ImGuiTextRange_split);
		*(cast(void**)&ImGuiTypingSelectState_Clear) = GetProcAddress(handle, "ImGuiTypingSelectState_Clear"); throwIf(!ImGuiTypingSelectState_Clear);
		*(cast(void**)&ImGuiTypingSelectState_ImGuiTypingSelectState) = GetProcAddress(handle, "ImGuiTypingSelectState_ImGuiTypingSelectState"); throwIf(!ImGuiTypingSelectState_ImGuiTypingSelectState);
		*(cast(void**)&ImGuiTypingSelectState_destroy) = GetProcAddress(handle, "ImGuiTypingSelectState_destroy"); throwIf(!ImGuiTypingSelectState_destroy);
		*(cast(void**)&ImGuiViewportP_CalcWorkRectPos) = GetProcAddress(handle, "ImGuiViewportP_CalcWorkRectPos"); throwIf(!ImGuiViewportP_CalcWorkRectPos);
		*(cast(void**)&ImGuiViewportP_CalcWorkRectSize) = GetProcAddress(handle, "ImGuiViewportP_CalcWorkRectSize"); throwIf(!ImGuiViewportP_CalcWorkRectSize);
		*(cast(void**)&ImGuiViewportP_ClearRequestFlags) = GetProcAddress(handle, "ImGuiViewportP_ClearRequestFlags"); throwIf(!ImGuiViewportP_ClearRequestFlags);
		*(cast(void**)&ImGuiViewportP_GetBuildWorkRect) = GetProcAddress(handle, "ImGuiViewportP_GetBuildWorkRect"); throwIf(!ImGuiViewportP_GetBuildWorkRect);
		*(cast(void**)&ImGuiViewportP_GetMainRect) = GetProcAddress(handle, "ImGuiViewportP_GetMainRect"); throwIf(!ImGuiViewportP_GetMainRect);
		*(cast(void**)&ImGuiViewportP_GetWorkRect) = GetProcAddress(handle, "ImGuiViewportP_GetWorkRect"); throwIf(!ImGuiViewportP_GetWorkRect);
		*(cast(void**)&ImGuiViewportP_ImGuiViewportP) = GetProcAddress(handle, "ImGuiViewportP_ImGuiViewportP"); throwIf(!ImGuiViewportP_ImGuiViewportP);
		*(cast(void**)&ImGuiViewportP_UpdateWorkRect) = GetProcAddress(handle, "ImGuiViewportP_UpdateWorkRect"); throwIf(!ImGuiViewportP_UpdateWorkRect);
		*(cast(void**)&ImGuiViewportP_destroy) = GetProcAddress(handle, "ImGuiViewportP_destroy"); throwIf(!ImGuiViewportP_destroy);
		*(cast(void**)&ImGuiViewport_GetCenter) = GetProcAddress(handle, "ImGuiViewport_GetCenter"); throwIf(!ImGuiViewport_GetCenter);
		*(cast(void**)&ImGuiViewport_GetWorkCenter) = GetProcAddress(handle, "ImGuiViewport_GetWorkCenter"); throwIf(!ImGuiViewport_GetWorkCenter);
		*(cast(void**)&ImGuiViewport_ImGuiViewport) = GetProcAddress(handle, "ImGuiViewport_ImGuiViewport"); throwIf(!ImGuiViewport_ImGuiViewport);
		*(cast(void**)&ImGuiViewport_destroy) = GetProcAddress(handle, "ImGuiViewport_destroy"); throwIf(!ImGuiViewport_destroy);
		*(cast(void**)&ImGuiWindowClass_ImGuiWindowClass) = GetProcAddress(handle, "ImGuiWindowClass_ImGuiWindowClass"); throwIf(!ImGuiWindowClass_ImGuiWindowClass);
		*(cast(void**)&ImGuiWindowClass_destroy) = GetProcAddress(handle, "ImGuiWindowClass_destroy"); throwIf(!ImGuiWindowClass_destroy);
		*(cast(void**)&ImGuiWindowSettings_GetName) = GetProcAddress(handle, "ImGuiWindowSettings_GetName"); throwIf(!ImGuiWindowSettings_GetName);
		*(cast(void**)&ImGuiWindowSettings_ImGuiWindowSettings) = GetProcAddress(handle, "ImGuiWindowSettings_ImGuiWindowSettings"); throwIf(!ImGuiWindowSettings_ImGuiWindowSettings);
		*(cast(void**)&ImGuiWindowSettings_destroy) = GetProcAddress(handle, "ImGuiWindowSettings_destroy"); throwIf(!ImGuiWindowSettings_destroy);
		*(cast(void**)&ImGuiWindow_CalcFontSize) = GetProcAddress(handle, "ImGuiWindow_CalcFontSize"); throwIf(!ImGuiWindow_CalcFontSize);
		*(cast(void**)&ImGuiWindow_GetIDFromRectangle) = GetProcAddress(handle, "ImGuiWindow_GetIDFromRectangle"); throwIf(!ImGuiWindow_GetIDFromRectangle);
		*(cast(void**)&ImGuiWindow_GetID_Int) = GetProcAddress(handle, "ImGuiWindow_GetID_Int"); throwIf(!ImGuiWindow_GetID_Int);
		*(cast(void**)&ImGuiWindow_GetID_Ptr) = GetProcAddress(handle, "ImGuiWindow_GetID_Ptr"); throwIf(!ImGuiWindow_GetID_Ptr);
		*(cast(void**)&ImGuiWindow_GetID_Str) = GetProcAddress(handle, "ImGuiWindow_GetID_Str"); throwIf(!ImGuiWindow_GetID_Str);
		*(cast(void**)&ImGuiWindow_ImGuiWindow) = GetProcAddress(handle, "ImGuiWindow_ImGuiWindow"); throwIf(!ImGuiWindow_ImGuiWindow);
		*(cast(void**)&ImGuiWindow_MenuBarRect) = GetProcAddress(handle, "ImGuiWindow_MenuBarRect"); throwIf(!ImGuiWindow_MenuBarRect);
		*(cast(void**)&ImGuiWindow_Rect) = GetProcAddress(handle, "ImGuiWindow_Rect"); throwIf(!ImGuiWindow_Rect);
		*(cast(void**)&ImGuiWindow_TitleBarRect) = GetProcAddress(handle, "ImGuiWindow_TitleBarRect"); throwIf(!ImGuiWindow_TitleBarRect);
		*(cast(void**)&ImGuiWindow_destroy) = GetProcAddress(handle, "ImGuiWindow_destroy"); throwIf(!ImGuiWindow_destroy);
		*(cast(void**)&ImRect_Add_Rect) = GetProcAddress(handle, "ImRect_Add_Rect"); throwIf(!ImRect_Add_Rect);
		*(cast(void**)&ImRect_Add_Vec2) = GetProcAddress(handle, "ImRect_Add_Vec2"); throwIf(!ImRect_Add_Vec2);
		*(cast(void**)&ImRect_ClipWith) = GetProcAddress(handle, "ImRect_ClipWith"); throwIf(!ImRect_ClipWith);
		*(cast(void**)&ImRect_ClipWithFull) = GetProcAddress(handle, "ImRect_ClipWithFull"); throwIf(!ImRect_ClipWithFull);
		*(cast(void**)&ImRect_ContainsWithPad) = GetProcAddress(handle, "ImRect_ContainsWithPad"); throwIf(!ImRect_ContainsWithPad);
		*(cast(void**)&ImRect_Contains_Rect) = GetProcAddress(handle, "ImRect_Contains_Rect"); throwIf(!ImRect_Contains_Rect);
		*(cast(void**)&ImRect_Contains_Vec2) = GetProcAddress(handle, "ImRect_Contains_Vec2"); throwIf(!ImRect_Contains_Vec2);
		*(cast(void**)&ImRect_Expand_Float) = GetProcAddress(handle, "ImRect_Expand_Float"); throwIf(!ImRect_Expand_Float);
		*(cast(void**)&ImRect_Expand_Vec2) = GetProcAddress(handle, "ImRect_Expand_Vec2"); throwIf(!ImRect_Expand_Vec2);
		*(cast(void**)&ImRect_Floor) = GetProcAddress(handle, "ImRect_Floor"); throwIf(!ImRect_Floor);
		*(cast(void**)&ImRect_GetArea) = GetProcAddress(handle, "ImRect_GetArea"); throwIf(!ImRect_GetArea);
		*(cast(void**)&ImRect_GetBL) = GetProcAddress(handle, "ImRect_GetBL"); throwIf(!ImRect_GetBL);
		*(cast(void**)&ImRect_GetBR) = GetProcAddress(handle, "ImRect_GetBR"); throwIf(!ImRect_GetBR);
		*(cast(void**)&ImRect_GetCenter) = GetProcAddress(handle, "ImRect_GetCenter"); throwIf(!ImRect_GetCenter);
		*(cast(void**)&ImRect_GetHeight) = GetProcAddress(handle, "ImRect_GetHeight"); throwIf(!ImRect_GetHeight);
		*(cast(void**)&ImRect_GetSize) = GetProcAddress(handle, "ImRect_GetSize"); throwIf(!ImRect_GetSize);
		*(cast(void**)&ImRect_GetTL) = GetProcAddress(handle, "ImRect_GetTL"); throwIf(!ImRect_GetTL);
		*(cast(void**)&ImRect_GetTR) = GetProcAddress(handle, "ImRect_GetTR"); throwIf(!ImRect_GetTR);
		*(cast(void**)&ImRect_GetWidth) = GetProcAddress(handle, "ImRect_GetWidth"); throwIf(!ImRect_GetWidth);
		*(cast(void**)&ImRect_ImRect_Float) = GetProcAddress(handle, "ImRect_ImRect_Float"); throwIf(!ImRect_ImRect_Float);
		*(cast(void**)&ImRect_ImRect_Nil) = GetProcAddress(handle, "ImRect_ImRect_Nil"); throwIf(!ImRect_ImRect_Nil);
		*(cast(void**)&ImRect_ImRect_Vec2) = GetProcAddress(handle, "ImRect_ImRect_Vec2"); throwIf(!ImRect_ImRect_Vec2);
		*(cast(void**)&ImRect_ImRect_Vec4) = GetProcAddress(handle, "ImRect_ImRect_Vec4"); throwIf(!ImRect_ImRect_Vec4);
		*(cast(void**)&ImRect_IsInverted) = GetProcAddress(handle, "ImRect_IsInverted"); throwIf(!ImRect_IsInverted);
		*(cast(void**)&ImRect_Overlaps) = GetProcAddress(handle, "ImRect_Overlaps"); throwIf(!ImRect_Overlaps);
		*(cast(void**)&ImRect_ToVec4) = GetProcAddress(handle, "ImRect_ToVec4"); throwIf(!ImRect_ToVec4);
		*(cast(void**)&ImRect_Translate) = GetProcAddress(handle, "ImRect_Translate"); throwIf(!ImRect_Translate);
		*(cast(void**)&ImRect_TranslateX) = GetProcAddress(handle, "ImRect_TranslateX"); throwIf(!ImRect_TranslateX);
		*(cast(void**)&ImRect_TranslateY) = GetProcAddress(handle, "ImRect_TranslateY"); throwIf(!ImRect_TranslateY);
		*(cast(void**)&ImRect_destroy) = GetProcAddress(handle, "ImRect_destroy"); throwIf(!ImRect_destroy);
		*(cast(void**)&ImVec1_ImVec1_Float) = GetProcAddress(handle, "ImVec1_ImVec1_Float"); throwIf(!ImVec1_ImVec1_Float);
		*(cast(void**)&ImVec1_ImVec1_Nil) = GetProcAddress(handle, "ImVec1_ImVec1_Nil"); throwIf(!ImVec1_ImVec1_Nil);
		*(cast(void**)&ImVec1_destroy) = GetProcAddress(handle, "ImVec1_destroy"); throwIf(!ImVec1_destroy);
		*(cast(void**)&ImVec2_ImVec2_Float) = GetProcAddress(handle, "ImVec2_ImVec2_Float"); throwIf(!ImVec2_ImVec2_Float);
		*(cast(void**)&ImVec2_ImVec2_Nil) = GetProcAddress(handle, "ImVec2_ImVec2_Nil"); throwIf(!ImVec2_ImVec2_Nil);
		*(cast(void**)&ImVec2_destroy) = GetProcAddress(handle, "ImVec2_destroy"); throwIf(!ImVec2_destroy);
		*(cast(void**)&ImVec2ih_ImVec2ih_Nil) = GetProcAddress(handle, "ImVec2ih_ImVec2ih_Nil"); throwIf(!ImVec2ih_ImVec2ih_Nil);
		*(cast(void**)&ImVec2ih_ImVec2ih_Vec2) = GetProcAddress(handle, "ImVec2ih_ImVec2ih_Vec2"); throwIf(!ImVec2ih_ImVec2ih_Vec2);
		*(cast(void**)&ImVec2ih_ImVec2ih_short) = GetProcAddress(handle, "ImVec2ih_ImVec2ih_short"); throwIf(!ImVec2ih_ImVec2ih_short);
		*(cast(void**)&ImVec2ih_destroy) = GetProcAddress(handle, "ImVec2ih_destroy"); throwIf(!ImVec2ih_destroy);
		*(cast(void**)&ImVec4_ImVec4_Float) = GetProcAddress(handle, "ImVec4_ImVec4_Float"); throwIf(!ImVec4_ImVec4_Float);
		*(cast(void**)&ImVec4_ImVec4_Nil) = GetProcAddress(handle, "ImVec4_ImVec4_Nil"); throwIf(!ImVec4_ImVec4_Nil);
		*(cast(void**)&ImVec4_destroy) = GetProcAddress(handle, "ImVec4_destroy"); throwIf(!ImVec4_destroy);
		*(cast(void**)&ImVector_ImWchar_Init) = GetProcAddress(handle, "ImVector_ImWchar_Init"); throwIf(!ImVector_ImWchar_Init);
		*(cast(void**)&ImVector_ImWchar_UnInit) = GetProcAddress(handle, "ImVector_ImWchar_UnInit"); throwIf(!ImVector_ImWchar_UnInit);
		*(cast(void**)&ImVector_ImWchar_create) = GetProcAddress(handle, "ImVector_ImWchar_create"); throwIf(!ImVector_ImWchar_create);
		*(cast(void**)&ImVector_ImWchar_destroy) = GetProcAddress(handle, "ImVector_ImWchar_destroy"); throwIf(!ImVector_ImWchar_destroy);
		*(cast(void**)&igAcceptDragDropPayload) = GetProcAddress(handle, "igAcceptDragDropPayload"); throwIf(!igAcceptDragDropPayload);
		*(cast(void**)&igActivateItemByID) = GetProcAddress(handle, "igActivateItemByID"); throwIf(!igActivateItemByID);
		*(cast(void**)&igAddContextHook) = GetProcAddress(handle, "igAddContextHook"); throwIf(!igAddContextHook);
		*(cast(void**)&igAddDrawListToDrawDataEx) = GetProcAddress(handle, "igAddDrawListToDrawDataEx"); throwIf(!igAddDrawListToDrawDataEx);
		*(cast(void**)&igAddSettingsHandler) = GetProcAddress(handle, "igAddSettingsHandler"); throwIf(!igAddSettingsHandler);
		*(cast(void**)&igAlignTextToFramePadding) = GetProcAddress(handle, "igAlignTextToFramePadding"); throwIf(!igAlignTextToFramePadding);
		*(cast(void**)&igArrowButton) = GetProcAddress(handle, "igArrowButton"); throwIf(!igArrowButton);
		*(cast(void**)&igArrowButtonEx) = GetProcAddress(handle, "igArrowButtonEx"); throwIf(!igArrowButtonEx);
		*(cast(void**)&igBegin) = GetProcAddress(handle, "igBegin"); throwIf(!igBegin);
		*(cast(void**)&igBeginBoxSelect) = GetProcAddress(handle, "igBeginBoxSelect"); throwIf(!igBeginBoxSelect);
		*(cast(void**)&igBeginChildEx) = GetProcAddress(handle, "igBeginChildEx"); throwIf(!igBeginChildEx);
		*(cast(void**)&igBeginChild_ID) = GetProcAddress(handle, "igBeginChild_ID"); throwIf(!igBeginChild_ID);
		*(cast(void**)&igBeginChild_Str) = GetProcAddress(handle, "igBeginChild_Str"); throwIf(!igBeginChild_Str);
		*(cast(void**)&igBeginColumns) = GetProcAddress(handle, "igBeginColumns"); throwIf(!igBeginColumns);
		*(cast(void**)&igBeginCombo) = GetProcAddress(handle, "igBeginCombo"); throwIf(!igBeginCombo);
		*(cast(void**)&igBeginComboPopup) = GetProcAddress(handle, "igBeginComboPopup"); throwIf(!igBeginComboPopup);
		*(cast(void**)&igBeginComboPreview) = GetProcAddress(handle, "igBeginComboPreview"); throwIf(!igBeginComboPreview);
		*(cast(void**)&igBeginDisabled) = GetProcAddress(handle, "igBeginDisabled"); throwIf(!igBeginDisabled);
		*(cast(void**)&igBeginDisabledOverrideReenable) = GetProcAddress(handle, "igBeginDisabledOverrideReenable"); throwIf(!igBeginDisabledOverrideReenable);
		*(cast(void**)&igBeginDockableDragDropSource) = GetProcAddress(handle, "igBeginDockableDragDropSource"); throwIf(!igBeginDockableDragDropSource);
		*(cast(void**)&igBeginDockableDragDropTarget) = GetProcAddress(handle, "igBeginDockableDragDropTarget"); throwIf(!igBeginDockableDragDropTarget);
		*(cast(void**)&igBeginDocked) = GetProcAddress(handle, "igBeginDocked"); throwIf(!igBeginDocked);
		*(cast(void**)&igBeginDragDropSource) = GetProcAddress(handle, "igBeginDragDropSource"); throwIf(!igBeginDragDropSource);
		*(cast(void**)&igBeginDragDropTarget) = GetProcAddress(handle, "igBeginDragDropTarget"); throwIf(!igBeginDragDropTarget);
		*(cast(void**)&igBeginDragDropTargetCustom) = GetProcAddress(handle, "igBeginDragDropTargetCustom"); throwIf(!igBeginDragDropTargetCustom);
		*(cast(void**)&igBeginGroup) = GetProcAddress(handle, "igBeginGroup"); throwIf(!igBeginGroup);
		*(cast(void**)&igBeginItemTooltip) = GetProcAddress(handle, "igBeginItemTooltip"); throwIf(!igBeginItemTooltip);
		*(cast(void**)&igBeginListBox) = GetProcAddress(handle, "igBeginListBox"); throwIf(!igBeginListBox);
		*(cast(void**)&igBeginMainMenuBar) = GetProcAddress(handle, "igBeginMainMenuBar"); throwIf(!igBeginMainMenuBar);
		*(cast(void**)&igBeginMenu) = GetProcAddress(handle, "igBeginMenu"); throwIf(!igBeginMenu);
		*(cast(void**)&igBeginMenuBar) = GetProcAddress(handle, "igBeginMenuBar"); throwIf(!igBeginMenuBar);
		*(cast(void**)&igBeginMenuEx) = GetProcAddress(handle, "igBeginMenuEx"); throwIf(!igBeginMenuEx);
		*(cast(void**)&igBeginMultiSelect) = GetProcAddress(handle, "igBeginMultiSelect"); throwIf(!igBeginMultiSelect);
		*(cast(void**)&igBeginPopup) = GetProcAddress(handle, "igBeginPopup"); throwIf(!igBeginPopup);
		*(cast(void**)&igBeginPopupContextItem) = GetProcAddress(handle, "igBeginPopupContextItem"); throwIf(!igBeginPopupContextItem);
		*(cast(void**)&igBeginPopupContextVoid) = GetProcAddress(handle, "igBeginPopupContextVoid"); throwIf(!igBeginPopupContextVoid);
		*(cast(void**)&igBeginPopupContextWindow) = GetProcAddress(handle, "igBeginPopupContextWindow"); throwIf(!igBeginPopupContextWindow);
		*(cast(void**)&igBeginPopupEx) = GetProcAddress(handle, "igBeginPopupEx"); throwIf(!igBeginPopupEx);
		*(cast(void**)&igBeginPopupModal) = GetProcAddress(handle, "igBeginPopupModal"); throwIf(!igBeginPopupModal);
		*(cast(void**)&igBeginTabBar) = GetProcAddress(handle, "igBeginTabBar"); throwIf(!igBeginTabBar);
		*(cast(void**)&igBeginTabBarEx) = GetProcAddress(handle, "igBeginTabBarEx"); throwIf(!igBeginTabBarEx);
		*(cast(void**)&igBeginTabItem) = GetProcAddress(handle, "igBeginTabItem"); throwIf(!igBeginTabItem);
		*(cast(void**)&igBeginTable) = GetProcAddress(handle, "igBeginTable"); throwIf(!igBeginTable);
		*(cast(void**)&igBeginTableEx) = GetProcAddress(handle, "igBeginTableEx"); throwIf(!igBeginTableEx);
		*(cast(void**)&igBeginTooltip) = GetProcAddress(handle, "igBeginTooltip"); throwIf(!igBeginTooltip);
		*(cast(void**)&igBeginTooltipEx) = GetProcAddress(handle, "igBeginTooltipEx"); throwIf(!igBeginTooltipEx);
		*(cast(void**)&igBeginTooltipHidden) = GetProcAddress(handle, "igBeginTooltipHidden"); throwIf(!igBeginTooltipHidden);
		*(cast(void**)&igBeginViewportSideBar) = GetProcAddress(handle, "igBeginViewportSideBar"); throwIf(!igBeginViewportSideBar);
		*(cast(void**)&igBringWindowToDisplayBack) = GetProcAddress(handle, "igBringWindowToDisplayBack"); throwIf(!igBringWindowToDisplayBack);
		*(cast(void**)&igBringWindowToDisplayBehind) = GetProcAddress(handle, "igBringWindowToDisplayBehind"); throwIf(!igBringWindowToDisplayBehind);
		*(cast(void**)&igBringWindowToDisplayFront) = GetProcAddress(handle, "igBringWindowToDisplayFront"); throwIf(!igBringWindowToDisplayFront);
		*(cast(void**)&igBringWindowToFocusFront) = GetProcAddress(handle, "igBringWindowToFocusFront"); throwIf(!igBringWindowToFocusFront);
		*(cast(void**)&igBullet) = GetProcAddress(handle, "igBullet"); throwIf(!igBullet);
		*(cast(void**)&igBulletText) = GetProcAddress(handle, "igBulletText"); throwIf(!igBulletText);
		*(cast(void**)&igBulletTextV) = GetProcAddress(handle, "igBulletTextV"); throwIf(!igBulletTextV);
		*(cast(void**)&igButton) = GetProcAddress(handle, "igButton"); throwIf(!igButton);
		*(cast(void**)&igButtonBehavior) = GetProcAddress(handle, "igButtonBehavior"); throwIf(!igButtonBehavior);
		*(cast(void**)&igButtonEx) = GetProcAddress(handle, "igButtonEx"); throwIf(!igButtonEx);
		*(cast(void**)&igCalcItemSize) = GetProcAddress(handle, "igCalcItemSize"); throwIf(!igCalcItemSize);
		*(cast(void**)&igCalcItemWidth) = GetProcAddress(handle, "igCalcItemWidth"); throwIf(!igCalcItemWidth);
		*(cast(void**)&igCalcRoundingFlagsForRectInRect) = GetProcAddress(handle, "igCalcRoundingFlagsForRectInRect"); throwIf(!igCalcRoundingFlagsForRectInRect);
		*(cast(void**)&igCalcTextSize) = GetProcAddress(handle, "igCalcTextSize"); throwIf(!igCalcTextSize);
		*(cast(void**)&igCalcTypematicRepeatAmount) = GetProcAddress(handle, "igCalcTypematicRepeatAmount"); throwIf(!igCalcTypematicRepeatAmount);
		*(cast(void**)&igCalcWindowNextAutoFitSize) = GetProcAddress(handle, "igCalcWindowNextAutoFitSize"); throwIf(!igCalcWindowNextAutoFitSize);
		*(cast(void**)&igCalcWrapWidthForPos) = GetProcAddress(handle, "igCalcWrapWidthForPos"); throwIf(!igCalcWrapWidthForPos);
		*(cast(void**)&igCallContextHooks) = GetProcAddress(handle, "igCallContextHooks"); throwIf(!igCallContextHooks);
		*(cast(void**)&igCheckbox) = GetProcAddress(handle, "igCheckbox"); throwIf(!igCheckbox);
		*(cast(void**)&igCheckboxFlags_IntPtr) = GetProcAddress(handle, "igCheckboxFlags_IntPtr"); throwIf(!igCheckboxFlags_IntPtr);
		*(cast(void**)&igCheckboxFlags_S64Ptr) = GetProcAddress(handle, "igCheckboxFlags_S64Ptr"); throwIf(!igCheckboxFlags_S64Ptr);
		*(cast(void**)&igCheckboxFlags_U64Ptr) = GetProcAddress(handle, "igCheckboxFlags_U64Ptr"); throwIf(!igCheckboxFlags_U64Ptr);
		*(cast(void**)&igCheckboxFlags_UintPtr) = GetProcAddress(handle, "igCheckboxFlags_UintPtr"); throwIf(!igCheckboxFlags_UintPtr);
		*(cast(void**)&igClearActiveID) = GetProcAddress(handle, "igClearActiveID"); throwIf(!igClearActiveID);
		*(cast(void**)&igClearDragDrop) = GetProcAddress(handle, "igClearDragDrop"); throwIf(!igClearDragDrop);
		*(cast(void**)&igClearIniSettings) = GetProcAddress(handle, "igClearIniSettings"); throwIf(!igClearIniSettings);
		*(cast(void**)&igClearWindowSettings) = GetProcAddress(handle, "igClearWindowSettings"); throwIf(!igClearWindowSettings);
		*(cast(void**)&igCloseButton) = GetProcAddress(handle, "igCloseButton"); throwIf(!igCloseButton);
		*(cast(void**)&igCloseCurrentPopup) = GetProcAddress(handle, "igCloseCurrentPopup"); throwIf(!igCloseCurrentPopup);
		*(cast(void**)&igClosePopupToLevel) = GetProcAddress(handle, "igClosePopupToLevel"); throwIf(!igClosePopupToLevel);
		*(cast(void**)&igClosePopupsExceptModals) = GetProcAddress(handle, "igClosePopupsExceptModals"); throwIf(!igClosePopupsExceptModals);
		*(cast(void**)&igClosePopupsOverWindow) = GetProcAddress(handle, "igClosePopupsOverWindow"); throwIf(!igClosePopupsOverWindow);
		*(cast(void**)&igCollapseButton) = GetProcAddress(handle, "igCollapseButton"); throwIf(!igCollapseButton);
		*(cast(void**)&igCollapsingHeader_BoolPtr) = GetProcAddress(handle, "igCollapsingHeader_BoolPtr"); throwIf(!igCollapsingHeader_BoolPtr);
		*(cast(void**)&igCollapsingHeader_TreeNodeFlags) = GetProcAddress(handle, "igCollapsingHeader_TreeNodeFlags"); throwIf(!igCollapsingHeader_TreeNodeFlags);
		*(cast(void**)&igColorButton) = GetProcAddress(handle, "igColorButton"); throwIf(!igColorButton);
		*(cast(void**)&igColorConvertFloat4ToU32) = GetProcAddress(handle, "igColorConvertFloat4ToU32"); throwIf(!igColorConvertFloat4ToU32);
		*(cast(void**)&igColorConvertHSVtoRGB) = GetProcAddress(handle, "igColorConvertHSVtoRGB"); throwIf(!igColorConvertHSVtoRGB);
		*(cast(void**)&igColorConvertRGBtoHSV) = GetProcAddress(handle, "igColorConvertRGBtoHSV"); throwIf(!igColorConvertRGBtoHSV);
		*(cast(void**)&igColorConvertU32ToFloat4) = GetProcAddress(handle, "igColorConvertU32ToFloat4"); throwIf(!igColorConvertU32ToFloat4);
		*(cast(void**)&igColorEdit3) = GetProcAddress(handle, "igColorEdit3"); throwIf(!igColorEdit3);
		*(cast(void**)&igColorEdit4) = GetProcAddress(handle, "igColorEdit4"); throwIf(!igColorEdit4);
		*(cast(void**)&igColorEditOptionsPopup) = GetProcAddress(handle, "igColorEditOptionsPopup"); throwIf(!igColorEditOptionsPopup);
		*(cast(void**)&igColorPicker3) = GetProcAddress(handle, "igColorPicker3"); throwIf(!igColorPicker3);
		*(cast(void**)&igColorPicker4) = GetProcAddress(handle, "igColorPicker4"); throwIf(!igColorPicker4);
		*(cast(void**)&igColorPickerOptionsPopup) = GetProcAddress(handle, "igColorPickerOptionsPopup"); throwIf(!igColorPickerOptionsPopup);
		*(cast(void**)&igColorTooltip) = GetProcAddress(handle, "igColorTooltip"); throwIf(!igColorTooltip);
		*(cast(void**)&igColumns) = GetProcAddress(handle, "igColumns"); throwIf(!igColumns);
		*(cast(void**)&igCombo_FnStrPtr) = GetProcAddress(handle, "igCombo_FnStrPtr"); throwIf(!igCombo_FnStrPtr);
		*(cast(void**)&igCombo_Str) = GetProcAddress(handle, "igCombo_Str"); throwIf(!igCombo_Str);
		*(cast(void**)&igCombo_Str_arr) = GetProcAddress(handle, "igCombo_Str_arr"); throwIf(!igCombo_Str_arr);
		*(cast(void**)&igConvertSingleModFlagToKey) = GetProcAddress(handle, "igConvertSingleModFlagToKey"); throwIf(!igConvertSingleModFlagToKey);
		*(cast(void**)&igCreateContext) = GetProcAddress(handle, "igCreateContext"); throwIf(!igCreateContext);
		*(cast(void**)&igCreateNewWindowSettings) = GetProcAddress(handle, "igCreateNewWindowSettings"); throwIf(!igCreateNewWindowSettings);
		*(cast(void**)&igDataTypeApplyFromText) = GetProcAddress(handle, "igDataTypeApplyFromText"); throwIf(!igDataTypeApplyFromText);
		*(cast(void**)&igDataTypeApplyOp) = GetProcAddress(handle, "igDataTypeApplyOp"); throwIf(!igDataTypeApplyOp);
		*(cast(void**)&igDataTypeClamp) = GetProcAddress(handle, "igDataTypeClamp"); throwIf(!igDataTypeClamp);
		*(cast(void**)&igDataTypeCompare) = GetProcAddress(handle, "igDataTypeCompare"); throwIf(!igDataTypeCompare);
		*(cast(void**)&igDataTypeFormatString) = GetProcAddress(handle, "igDataTypeFormatString"); throwIf(!igDataTypeFormatString);
		*(cast(void**)&igDataTypeGetInfo) = GetProcAddress(handle, "igDataTypeGetInfo"); throwIf(!igDataTypeGetInfo);
		*(cast(void**)&igDebugAllocHook) = GetProcAddress(handle, "igDebugAllocHook"); throwIf(!igDebugAllocHook);
		*(cast(void**)&igDebugBreakButton) = GetProcAddress(handle, "igDebugBreakButton"); throwIf(!igDebugBreakButton);
		*(cast(void**)&igDebugBreakButtonTooltip) = GetProcAddress(handle, "igDebugBreakButtonTooltip"); throwIf(!igDebugBreakButtonTooltip);
		*(cast(void**)&igDebugBreakClearData) = GetProcAddress(handle, "igDebugBreakClearData"); throwIf(!igDebugBreakClearData);
		*(cast(void**)&igDebugCheckVersionAndDataLayout) = GetProcAddress(handle, "igDebugCheckVersionAndDataLayout"); throwIf(!igDebugCheckVersionAndDataLayout);
		*(cast(void**)&igDebugDrawCursorPos) = GetProcAddress(handle, "igDebugDrawCursorPos"); throwIf(!igDebugDrawCursorPos);
		*(cast(void**)&igDebugDrawItemRect) = GetProcAddress(handle, "igDebugDrawItemRect"); throwIf(!igDebugDrawItemRect);
		*(cast(void**)&igDebugDrawLineExtents) = GetProcAddress(handle, "igDebugDrawLineExtents"); throwIf(!igDebugDrawLineExtents);
		*(cast(void**)&igDebugFlashStyleColor) = GetProcAddress(handle, "igDebugFlashStyleColor"); throwIf(!igDebugFlashStyleColor);
		*(cast(void**)&igDebugHookIdInfo) = GetProcAddress(handle, "igDebugHookIdInfo"); throwIf(!igDebugHookIdInfo);
		*(cast(void**)&igDebugLocateItem) = GetProcAddress(handle, "igDebugLocateItem"); throwIf(!igDebugLocateItem);
		*(cast(void**)&igDebugLocateItemOnHover) = GetProcAddress(handle, "igDebugLocateItemOnHover"); throwIf(!igDebugLocateItemOnHover);
		*(cast(void**)&igDebugLocateItemResolveWithLastItem) = GetProcAddress(handle, "igDebugLocateItemResolveWithLastItem"); throwIf(!igDebugLocateItemResolveWithLastItem);
		*(cast(void**)&igDebugLog) = GetProcAddress(handle, "igDebugLog"); throwIf(!igDebugLog);
		*(cast(void**)&igDebugLogV) = GetProcAddress(handle, "igDebugLogV"); throwIf(!igDebugLogV);
		*(cast(void**)&igDebugNodeColumns) = GetProcAddress(handle, "igDebugNodeColumns"); throwIf(!igDebugNodeColumns);
		*(cast(void**)&igDebugNodeDockNode) = GetProcAddress(handle, "igDebugNodeDockNode"); throwIf(!igDebugNodeDockNode);
		*(cast(void**)&igDebugNodeDrawCmdShowMeshAndBoundingBox) = GetProcAddress(handle, "igDebugNodeDrawCmdShowMeshAndBoundingBox"); throwIf(!igDebugNodeDrawCmdShowMeshAndBoundingBox);
		*(cast(void**)&igDebugNodeDrawList) = GetProcAddress(handle, "igDebugNodeDrawList"); throwIf(!igDebugNodeDrawList);
		*(cast(void**)&igDebugNodeFont) = GetProcAddress(handle, "igDebugNodeFont"); throwIf(!igDebugNodeFont);
		*(cast(void**)&igDebugNodeFontGlyph) = GetProcAddress(handle, "igDebugNodeFontGlyph"); throwIf(!igDebugNodeFontGlyph);
		*(cast(void**)&igDebugNodeInputTextState) = GetProcAddress(handle, "igDebugNodeInputTextState"); throwIf(!igDebugNodeInputTextState);
		*(cast(void**)&igDebugNodeMultiSelectState) = GetProcAddress(handle, "igDebugNodeMultiSelectState"); throwIf(!igDebugNodeMultiSelectState);
		*(cast(void**)&igDebugNodePlatformMonitor) = GetProcAddress(handle, "igDebugNodePlatformMonitor"); throwIf(!igDebugNodePlatformMonitor);
		*(cast(void**)&igDebugNodeStorage) = GetProcAddress(handle, "igDebugNodeStorage"); throwIf(!igDebugNodeStorage);
		*(cast(void**)&igDebugNodeTabBar) = GetProcAddress(handle, "igDebugNodeTabBar"); throwIf(!igDebugNodeTabBar);
		*(cast(void**)&igDebugNodeTable) = GetProcAddress(handle, "igDebugNodeTable"); throwIf(!igDebugNodeTable);
		*(cast(void**)&igDebugNodeTableSettings) = GetProcAddress(handle, "igDebugNodeTableSettings"); throwIf(!igDebugNodeTableSettings);
		*(cast(void**)&igDebugNodeTypingSelectState) = GetProcAddress(handle, "igDebugNodeTypingSelectState"); throwIf(!igDebugNodeTypingSelectState);
		*(cast(void**)&igDebugNodeViewport) = GetProcAddress(handle, "igDebugNodeViewport"); throwIf(!igDebugNodeViewport);
		*(cast(void**)&igDebugNodeWindow) = GetProcAddress(handle, "igDebugNodeWindow"); throwIf(!igDebugNodeWindow);
		*(cast(void**)&igDebugNodeWindowSettings) = GetProcAddress(handle, "igDebugNodeWindowSettings"); throwIf(!igDebugNodeWindowSettings);
		*(cast(void**)&igDebugNodeWindowsList) = GetProcAddress(handle, "igDebugNodeWindowsList"); throwIf(!igDebugNodeWindowsList);
		*(cast(void**)&igDebugNodeWindowsListByBeginStackParent) = GetProcAddress(handle, "igDebugNodeWindowsListByBeginStackParent"); throwIf(!igDebugNodeWindowsListByBeginStackParent);
		*(cast(void**)&igDebugRenderKeyboardPreview) = GetProcAddress(handle, "igDebugRenderKeyboardPreview"); throwIf(!igDebugRenderKeyboardPreview);
		*(cast(void**)&igDebugRenderViewportThumbnail) = GetProcAddress(handle, "igDebugRenderViewportThumbnail"); throwIf(!igDebugRenderViewportThumbnail);
		*(cast(void**)&igDebugStartItemPicker) = GetProcAddress(handle, "igDebugStartItemPicker"); throwIf(!igDebugStartItemPicker);
		*(cast(void**)&igDebugTextEncoding) = GetProcAddress(handle, "igDebugTextEncoding"); throwIf(!igDebugTextEncoding);
		*(cast(void**)&igDebugTextUnformattedWithLocateItem) = GetProcAddress(handle, "igDebugTextUnformattedWithLocateItem"); throwIf(!igDebugTextUnformattedWithLocateItem);
		*(cast(void**)&igDestroyContext) = GetProcAddress(handle, "igDestroyContext"); throwIf(!igDestroyContext);
		*(cast(void**)&igDestroyPlatformWindow) = GetProcAddress(handle, "igDestroyPlatformWindow"); throwIf(!igDestroyPlatformWindow);
		*(cast(void**)&igDestroyPlatformWindows) = GetProcAddress(handle, "igDestroyPlatformWindows"); throwIf(!igDestroyPlatformWindows);
		*(cast(void**)&igDockBuilderAddNode) = GetProcAddress(handle, "igDockBuilderAddNode"); throwIf(!igDockBuilderAddNode);
		*(cast(void**)&igDockBuilderCopyDockSpace) = GetProcAddress(handle, "igDockBuilderCopyDockSpace"); throwIf(!igDockBuilderCopyDockSpace);
		*(cast(void**)&igDockBuilderCopyNode) = GetProcAddress(handle, "igDockBuilderCopyNode"); throwIf(!igDockBuilderCopyNode);
		*(cast(void**)&igDockBuilderCopyWindowSettings) = GetProcAddress(handle, "igDockBuilderCopyWindowSettings"); throwIf(!igDockBuilderCopyWindowSettings);
		*(cast(void**)&igDockBuilderDockWindow) = GetProcAddress(handle, "igDockBuilderDockWindow"); throwIf(!igDockBuilderDockWindow);
		*(cast(void**)&igDockBuilderFinish) = GetProcAddress(handle, "igDockBuilderFinish"); throwIf(!igDockBuilderFinish);
		*(cast(void**)&igDockBuilderGetCentralNode) = GetProcAddress(handle, "igDockBuilderGetCentralNode"); throwIf(!igDockBuilderGetCentralNode);
		*(cast(void**)&igDockBuilderGetNode) = GetProcAddress(handle, "igDockBuilderGetNode"); throwIf(!igDockBuilderGetNode);
		*(cast(void**)&igDockBuilderRemoveNode) = GetProcAddress(handle, "igDockBuilderRemoveNode"); throwIf(!igDockBuilderRemoveNode);
		*(cast(void**)&igDockBuilderRemoveNodeChildNodes) = GetProcAddress(handle, "igDockBuilderRemoveNodeChildNodes"); throwIf(!igDockBuilderRemoveNodeChildNodes);
		*(cast(void**)&igDockBuilderRemoveNodeDockedWindows) = GetProcAddress(handle, "igDockBuilderRemoveNodeDockedWindows"); throwIf(!igDockBuilderRemoveNodeDockedWindows);
		*(cast(void**)&igDockBuilderSetNodePos) = GetProcAddress(handle, "igDockBuilderSetNodePos"); throwIf(!igDockBuilderSetNodePos);
		*(cast(void**)&igDockBuilderSetNodeSize) = GetProcAddress(handle, "igDockBuilderSetNodeSize"); throwIf(!igDockBuilderSetNodeSize);
		*(cast(void**)&igDockBuilderSplitNode) = GetProcAddress(handle, "igDockBuilderSplitNode"); throwIf(!igDockBuilderSplitNode);
		*(cast(void**)&igDockContextCalcDropPosForDocking) = GetProcAddress(handle, "igDockContextCalcDropPosForDocking"); throwIf(!igDockContextCalcDropPosForDocking);
		*(cast(void**)&igDockContextClearNodes) = GetProcAddress(handle, "igDockContextClearNodes"); throwIf(!igDockContextClearNodes);
		*(cast(void**)&igDockContextEndFrame) = GetProcAddress(handle, "igDockContextEndFrame"); throwIf(!igDockContextEndFrame);
		*(cast(void**)&igDockContextFindNodeByID) = GetProcAddress(handle, "igDockContextFindNodeByID"); throwIf(!igDockContextFindNodeByID);
		*(cast(void**)&igDockContextGenNodeID) = GetProcAddress(handle, "igDockContextGenNodeID"); throwIf(!igDockContextGenNodeID);
		*(cast(void**)&igDockContextInitialize) = GetProcAddress(handle, "igDockContextInitialize"); throwIf(!igDockContextInitialize);
		*(cast(void**)&igDockContextNewFrameUpdateDocking) = GetProcAddress(handle, "igDockContextNewFrameUpdateDocking"); throwIf(!igDockContextNewFrameUpdateDocking);
		*(cast(void**)&igDockContextNewFrameUpdateUndocking) = GetProcAddress(handle, "igDockContextNewFrameUpdateUndocking"); throwIf(!igDockContextNewFrameUpdateUndocking);
		*(cast(void**)&igDockContextProcessUndockNode) = GetProcAddress(handle, "igDockContextProcessUndockNode"); throwIf(!igDockContextProcessUndockNode);
		*(cast(void**)&igDockContextProcessUndockWindow) = GetProcAddress(handle, "igDockContextProcessUndockWindow"); throwIf(!igDockContextProcessUndockWindow);
		*(cast(void**)&igDockContextQueueDock) = GetProcAddress(handle, "igDockContextQueueDock"); throwIf(!igDockContextQueueDock);
		*(cast(void**)&igDockContextQueueUndockNode) = GetProcAddress(handle, "igDockContextQueueUndockNode"); throwIf(!igDockContextQueueUndockNode);
		*(cast(void**)&igDockContextQueueUndockWindow) = GetProcAddress(handle, "igDockContextQueueUndockWindow"); throwIf(!igDockContextQueueUndockWindow);
		*(cast(void**)&igDockContextRebuildNodes) = GetProcAddress(handle, "igDockContextRebuildNodes"); throwIf(!igDockContextRebuildNodes);
		*(cast(void**)&igDockContextShutdown) = GetProcAddress(handle, "igDockContextShutdown"); throwIf(!igDockContextShutdown);
		*(cast(void**)&igDockNodeBeginAmendTabBar) = GetProcAddress(handle, "igDockNodeBeginAmendTabBar"); throwIf(!igDockNodeBeginAmendTabBar);
		*(cast(void**)&igDockNodeEndAmendTabBar) = GetProcAddress(handle, "igDockNodeEndAmendTabBar"); throwIf(!igDockNodeEndAmendTabBar);
		*(cast(void**)&igDockNodeGetDepth) = GetProcAddress(handle, "igDockNodeGetDepth"); throwIf(!igDockNodeGetDepth);
		*(cast(void**)&igDockNodeGetRootNode) = GetProcAddress(handle, "igDockNodeGetRootNode"); throwIf(!igDockNodeGetRootNode);
		*(cast(void**)&igDockNodeGetWindowMenuButtonId) = GetProcAddress(handle, "igDockNodeGetWindowMenuButtonId"); throwIf(!igDockNodeGetWindowMenuButtonId);
		*(cast(void**)&igDockNodeIsInHierarchyOf) = GetProcAddress(handle, "igDockNodeIsInHierarchyOf"); throwIf(!igDockNodeIsInHierarchyOf);
		*(cast(void**)&igDockNodeWindowMenuHandler_Default) = GetProcAddress(handle, "igDockNodeWindowMenuHandler_Default"); throwIf(!igDockNodeWindowMenuHandler_Default);
		*(cast(void**)&igDockSpace) = GetProcAddress(handle, "igDockSpace"); throwIf(!igDockSpace);
		*(cast(void**)&igDockSpaceOverViewport) = GetProcAddress(handle, "igDockSpaceOverViewport"); throwIf(!igDockSpaceOverViewport);
		*(cast(void**)&igDragBehavior) = GetProcAddress(handle, "igDragBehavior"); throwIf(!igDragBehavior);
		*(cast(void**)&igDragFloat) = GetProcAddress(handle, "igDragFloat"); throwIf(!igDragFloat);
		*(cast(void**)&igDragFloat2) = GetProcAddress(handle, "igDragFloat2"); throwIf(!igDragFloat2);
		*(cast(void**)&igDragFloat3) = GetProcAddress(handle, "igDragFloat3"); throwIf(!igDragFloat3);
		*(cast(void**)&igDragFloat4) = GetProcAddress(handle, "igDragFloat4"); throwIf(!igDragFloat4);
		*(cast(void**)&igDragFloatRange2) = GetProcAddress(handle, "igDragFloatRange2"); throwIf(!igDragFloatRange2);
		*(cast(void**)&igDragInt) = GetProcAddress(handle, "igDragInt"); throwIf(!igDragInt);
		*(cast(void**)&igDragInt2) = GetProcAddress(handle, "igDragInt2"); throwIf(!igDragInt2);
		*(cast(void**)&igDragInt3) = GetProcAddress(handle, "igDragInt3"); throwIf(!igDragInt3);
		*(cast(void**)&igDragInt4) = GetProcAddress(handle, "igDragInt4"); throwIf(!igDragInt4);
		*(cast(void**)&igDragIntRange2) = GetProcAddress(handle, "igDragIntRange2"); throwIf(!igDragIntRange2);
		*(cast(void**)&igDragScalar) = GetProcAddress(handle, "igDragScalar"); throwIf(!igDragScalar);
		*(cast(void**)&igDragScalarN) = GetProcAddress(handle, "igDragScalarN"); throwIf(!igDragScalarN);
		*(cast(void**)&igDummy) = GetProcAddress(handle, "igDummy"); throwIf(!igDummy);
		*(cast(void**)&igEnd) = GetProcAddress(handle, "igEnd"); throwIf(!igEnd);
		*(cast(void**)&igEndBoxSelect) = GetProcAddress(handle, "igEndBoxSelect"); throwIf(!igEndBoxSelect);
		*(cast(void**)&igEndChild) = GetProcAddress(handle, "igEndChild"); throwIf(!igEndChild);
		*(cast(void**)&igEndColumns) = GetProcAddress(handle, "igEndColumns"); throwIf(!igEndColumns);
		*(cast(void**)&igEndCombo) = GetProcAddress(handle, "igEndCombo"); throwIf(!igEndCombo);
		*(cast(void**)&igEndComboPreview) = GetProcAddress(handle, "igEndComboPreview"); throwIf(!igEndComboPreview);
		*(cast(void**)&igEndDisabled) = GetProcAddress(handle, "igEndDisabled"); throwIf(!igEndDisabled);
		*(cast(void**)&igEndDisabledOverrideReenable) = GetProcAddress(handle, "igEndDisabledOverrideReenable"); throwIf(!igEndDisabledOverrideReenable);
		*(cast(void**)&igEndDragDropSource) = GetProcAddress(handle, "igEndDragDropSource"); throwIf(!igEndDragDropSource);
		*(cast(void**)&igEndDragDropTarget) = GetProcAddress(handle, "igEndDragDropTarget"); throwIf(!igEndDragDropTarget);
		*(cast(void**)&igEndFrame) = GetProcAddress(handle, "igEndFrame"); throwIf(!igEndFrame);
		*(cast(void**)&igEndGroup) = GetProcAddress(handle, "igEndGroup"); throwIf(!igEndGroup);
		*(cast(void**)&igEndListBox) = GetProcAddress(handle, "igEndListBox"); throwIf(!igEndListBox);
		*(cast(void**)&igEndMainMenuBar) = GetProcAddress(handle, "igEndMainMenuBar"); throwIf(!igEndMainMenuBar);
		*(cast(void**)&igEndMenu) = GetProcAddress(handle, "igEndMenu"); throwIf(!igEndMenu);
		*(cast(void**)&igEndMenuBar) = GetProcAddress(handle, "igEndMenuBar"); throwIf(!igEndMenuBar);
		*(cast(void**)&igEndMultiSelect) = GetProcAddress(handle, "igEndMultiSelect"); throwIf(!igEndMultiSelect);
		*(cast(void**)&igEndPopup) = GetProcAddress(handle, "igEndPopup"); throwIf(!igEndPopup);
		*(cast(void**)&igEndTabBar) = GetProcAddress(handle, "igEndTabBar"); throwIf(!igEndTabBar);
		*(cast(void**)&igEndTabItem) = GetProcAddress(handle, "igEndTabItem"); throwIf(!igEndTabItem);
		*(cast(void**)&igEndTable) = GetProcAddress(handle, "igEndTable"); throwIf(!igEndTable);
		*(cast(void**)&igEndTooltip) = GetProcAddress(handle, "igEndTooltip"); throwIf(!igEndTooltip);
		*(cast(void**)&igErrorCheckEndFrameRecover) = GetProcAddress(handle, "igErrorCheckEndFrameRecover"); throwIf(!igErrorCheckEndFrameRecover);
		*(cast(void**)&igErrorCheckEndWindowRecover) = GetProcAddress(handle, "igErrorCheckEndWindowRecover"); throwIf(!igErrorCheckEndWindowRecover);
		*(cast(void**)&igErrorCheckUsingSetCursorPosToExtendParentBoundaries) = GetProcAddress(handle, "igErrorCheckUsingSetCursorPosToExtendParentBoundaries"); throwIf(!igErrorCheckUsingSetCursorPosToExtendParentBoundaries);
		*(cast(void**)&igFindBestWindowPosForPopup) = GetProcAddress(handle, "igFindBestWindowPosForPopup"); throwIf(!igFindBestWindowPosForPopup);
		*(cast(void**)&igFindBestWindowPosForPopupEx) = GetProcAddress(handle, "igFindBestWindowPosForPopupEx"); throwIf(!igFindBestWindowPosForPopupEx);
		*(cast(void**)&igFindBlockingModal) = GetProcAddress(handle, "igFindBlockingModal"); throwIf(!igFindBlockingModal);
		*(cast(void**)&igFindBottomMostVisibleWindowWithinBeginStack) = GetProcAddress(handle, "igFindBottomMostVisibleWindowWithinBeginStack"); throwIf(!igFindBottomMostVisibleWindowWithinBeginStack);
		*(cast(void**)&igFindHoveredViewportFromPlatformWindowStack) = GetProcAddress(handle, "igFindHoveredViewportFromPlatformWindowStack"); throwIf(!igFindHoveredViewportFromPlatformWindowStack);
		*(cast(void**)&igFindHoveredWindowEx) = GetProcAddress(handle, "igFindHoveredWindowEx"); throwIf(!igFindHoveredWindowEx);
		*(cast(void**)&igFindOrCreateColumns) = GetProcAddress(handle, "igFindOrCreateColumns"); throwIf(!igFindOrCreateColumns);
		*(cast(void**)&igFindRenderedTextEnd) = GetProcAddress(handle, "igFindRenderedTextEnd"); throwIf(!igFindRenderedTextEnd);
		*(cast(void**)&igFindSettingsHandler) = GetProcAddress(handle, "igFindSettingsHandler"); throwIf(!igFindSettingsHandler);
		*(cast(void**)&igFindViewportByID) = GetProcAddress(handle, "igFindViewportByID"); throwIf(!igFindViewportByID);
		*(cast(void**)&igFindViewportByPlatformHandle) = GetProcAddress(handle, "igFindViewportByPlatformHandle"); throwIf(!igFindViewportByPlatformHandle);
		*(cast(void**)&igFindWindowByID) = GetProcAddress(handle, "igFindWindowByID"); throwIf(!igFindWindowByID);
		*(cast(void**)&igFindWindowByName) = GetProcAddress(handle, "igFindWindowByName"); throwIf(!igFindWindowByName);
		*(cast(void**)&igFindWindowDisplayIndex) = GetProcAddress(handle, "igFindWindowDisplayIndex"); throwIf(!igFindWindowDisplayIndex);
		*(cast(void**)&igFindWindowSettingsByID) = GetProcAddress(handle, "igFindWindowSettingsByID"); throwIf(!igFindWindowSettingsByID);
		*(cast(void**)&igFindWindowSettingsByWindow) = GetProcAddress(handle, "igFindWindowSettingsByWindow"); throwIf(!igFindWindowSettingsByWindow);
		*(cast(void**)&igFixupKeyChord) = GetProcAddress(handle, "igFixupKeyChord"); throwIf(!igFixupKeyChord);
		*(cast(void**)&igFocusItem) = GetProcAddress(handle, "igFocusItem"); throwIf(!igFocusItem);
		*(cast(void**)&igFocusTopMostWindowUnderOne) = GetProcAddress(handle, "igFocusTopMostWindowUnderOne"); throwIf(!igFocusTopMostWindowUnderOne);
		*(cast(void**)&igFocusWindow) = GetProcAddress(handle, "igFocusWindow"); throwIf(!igFocusWindow);
		*(cast(void**)&igGET_FLT_MAX) = GetProcAddress(handle, "igGET_FLT_MAX"); throwIf(!igGET_FLT_MAX);
		*(cast(void**)&igGET_FLT_MIN) = GetProcAddress(handle, "igGET_FLT_MIN"); throwIf(!igGET_FLT_MIN);
		*(cast(void**)&igGcAwakeTransientWindowBuffers) = GetProcAddress(handle, "igGcAwakeTransientWindowBuffers"); throwIf(!igGcAwakeTransientWindowBuffers);
		*(cast(void**)&igGcCompactTransientMiscBuffers) = GetProcAddress(handle, "igGcCompactTransientMiscBuffers"); throwIf(!igGcCompactTransientMiscBuffers);
		*(cast(void**)&igGcCompactTransientWindowBuffers) = GetProcAddress(handle, "igGcCompactTransientWindowBuffers"); throwIf(!igGcCompactTransientWindowBuffers);
		*(cast(void**)&igGetActiveID) = GetProcAddress(handle, "igGetActiveID"); throwIf(!igGetActiveID);
		*(cast(void**)&igGetAllocatorFunctions) = GetProcAddress(handle, "igGetAllocatorFunctions"); throwIf(!igGetAllocatorFunctions);
		*(cast(void**)&igGetBackgroundDrawList) = GetProcAddress(handle, "igGetBackgroundDrawList"); throwIf(!igGetBackgroundDrawList);
		*(cast(void**)&igGetBoxSelectState) = GetProcAddress(handle, "igGetBoxSelectState"); throwIf(!igGetBoxSelectState);
		*(cast(void**)&igGetClipboardText) = GetProcAddress(handle, "igGetClipboardText"); throwIf(!igGetClipboardText);
		*(cast(void**)&igGetColorU32_Col) = GetProcAddress(handle, "igGetColorU32_Col"); throwIf(!igGetColorU32_Col);
		*(cast(void**)&igGetColorU32_U32) = GetProcAddress(handle, "igGetColorU32_U32"); throwIf(!igGetColorU32_U32);
		*(cast(void**)&igGetColorU32_Vec4) = GetProcAddress(handle, "igGetColorU32_Vec4"); throwIf(!igGetColorU32_Vec4);
		*(cast(void**)&igGetColumnIndex) = GetProcAddress(handle, "igGetColumnIndex"); throwIf(!igGetColumnIndex);
		*(cast(void**)&igGetColumnNormFromOffset) = GetProcAddress(handle, "igGetColumnNormFromOffset"); throwIf(!igGetColumnNormFromOffset);
		*(cast(void**)&igGetColumnOffset) = GetProcAddress(handle, "igGetColumnOffset"); throwIf(!igGetColumnOffset);
		*(cast(void**)&igGetColumnOffsetFromNorm) = GetProcAddress(handle, "igGetColumnOffsetFromNorm"); throwIf(!igGetColumnOffsetFromNorm);
		*(cast(void**)&igGetColumnWidth) = GetProcAddress(handle, "igGetColumnWidth"); throwIf(!igGetColumnWidth);
		*(cast(void**)&igGetColumnsCount) = GetProcAddress(handle, "igGetColumnsCount"); throwIf(!igGetColumnsCount);
		*(cast(void**)&igGetColumnsID) = GetProcAddress(handle, "igGetColumnsID"); throwIf(!igGetColumnsID);
		*(cast(void**)&igGetContentRegionAvail) = GetProcAddress(handle, "igGetContentRegionAvail"); throwIf(!igGetContentRegionAvail);
		*(cast(void**)&igGetCurrentContext) = GetProcAddress(handle, "igGetCurrentContext"); throwIf(!igGetCurrentContext);
		*(cast(void**)&igGetCurrentFocusScope) = GetProcAddress(handle, "igGetCurrentFocusScope"); throwIf(!igGetCurrentFocusScope);
		*(cast(void**)&igGetCurrentTabBar) = GetProcAddress(handle, "igGetCurrentTabBar"); throwIf(!igGetCurrentTabBar);
		*(cast(void**)&igGetCurrentTable) = GetProcAddress(handle, "igGetCurrentTable"); throwIf(!igGetCurrentTable);
		*(cast(void**)&igGetCurrentWindow) = GetProcAddress(handle, "igGetCurrentWindow"); throwIf(!igGetCurrentWindow);
		*(cast(void**)&igGetCurrentWindowRead) = GetProcAddress(handle, "igGetCurrentWindowRead"); throwIf(!igGetCurrentWindowRead);
		*(cast(void**)&igGetCursorPos) = GetProcAddress(handle, "igGetCursorPos"); throwIf(!igGetCursorPos);
		*(cast(void**)&igGetCursorPosX) = GetProcAddress(handle, "igGetCursorPosX"); throwIf(!igGetCursorPosX);
		*(cast(void**)&igGetCursorPosY) = GetProcAddress(handle, "igGetCursorPosY"); throwIf(!igGetCursorPosY);
		*(cast(void**)&igGetCursorScreenPos) = GetProcAddress(handle, "igGetCursorScreenPos"); throwIf(!igGetCursorScreenPos);
		*(cast(void**)&igGetCursorStartPos) = GetProcAddress(handle, "igGetCursorStartPos"); throwIf(!igGetCursorStartPos);
		*(cast(void**)&igGetDefaultFont) = GetProcAddress(handle, "igGetDefaultFont"); throwIf(!igGetDefaultFont);
		*(cast(void**)&igGetDragDropPayload) = GetProcAddress(handle, "igGetDragDropPayload"); throwIf(!igGetDragDropPayload);
		*(cast(void**)&igGetDrawData) = GetProcAddress(handle, "igGetDrawData"); throwIf(!igGetDrawData);
		*(cast(void**)&igGetDrawListSharedData) = GetProcAddress(handle, "igGetDrawListSharedData"); throwIf(!igGetDrawListSharedData);
		*(cast(void**)&igGetFocusID) = GetProcAddress(handle, "igGetFocusID"); throwIf(!igGetFocusID);
		*(cast(void**)&igGetFont) = GetProcAddress(handle, "igGetFont"); throwIf(!igGetFont);
		*(cast(void**)&igGetFontSize) = GetProcAddress(handle, "igGetFontSize"); throwIf(!igGetFontSize);
		*(cast(void**)&igGetFontTexUvWhitePixel) = GetProcAddress(handle, "igGetFontTexUvWhitePixel"); throwIf(!igGetFontTexUvWhitePixel);
		*(cast(void**)&igGetForegroundDrawList_ViewportPtr) = GetProcAddress(handle, "igGetForegroundDrawList_ViewportPtr"); throwIf(!igGetForegroundDrawList_ViewportPtr);
		*(cast(void**)&igGetForegroundDrawList_WindowPtr) = GetProcAddress(handle, "igGetForegroundDrawList_WindowPtr"); throwIf(!igGetForegroundDrawList_WindowPtr);
		*(cast(void**)&igGetFrameCount) = GetProcAddress(handle, "igGetFrameCount"); throwIf(!igGetFrameCount);
		*(cast(void**)&igGetFrameHeight) = GetProcAddress(handle, "igGetFrameHeight"); throwIf(!igGetFrameHeight);
		*(cast(void**)&igGetFrameHeightWithSpacing) = GetProcAddress(handle, "igGetFrameHeightWithSpacing"); throwIf(!igGetFrameHeightWithSpacing);
		*(cast(void**)&igGetHoveredID) = GetProcAddress(handle, "igGetHoveredID"); throwIf(!igGetHoveredID);
		*(cast(void**)&igGetIDWithSeed_Int) = GetProcAddress(handle, "igGetIDWithSeed_Int"); throwIf(!igGetIDWithSeed_Int);
		*(cast(void**)&igGetIDWithSeed_Str) = GetProcAddress(handle, "igGetIDWithSeed_Str"); throwIf(!igGetIDWithSeed_Str);
		*(cast(void**)&igGetID_Int) = GetProcAddress(handle, "igGetID_Int"); throwIf(!igGetID_Int);
		*(cast(void**)&igGetID_Ptr) = GetProcAddress(handle, "igGetID_Ptr"); throwIf(!igGetID_Ptr);
		*(cast(void**)&igGetID_Str) = GetProcAddress(handle, "igGetID_Str"); throwIf(!igGetID_Str);
		*(cast(void**)&igGetID_StrStr) = GetProcAddress(handle, "igGetID_StrStr"); throwIf(!igGetID_StrStr);
		*(cast(void**)&igGetIO) = GetProcAddress(handle, "igGetIO"); throwIf(!igGetIO);
		*(cast(void**)&igGetInputTextState) = GetProcAddress(handle, "igGetInputTextState"); throwIf(!igGetInputTextState);
		*(cast(void**)&igGetItemFlags) = GetProcAddress(handle, "igGetItemFlags"); throwIf(!igGetItemFlags);
		*(cast(void**)&igGetItemID) = GetProcAddress(handle, "igGetItemID"); throwIf(!igGetItemID);
		*(cast(void**)&igGetItemRectMax) = GetProcAddress(handle, "igGetItemRectMax"); throwIf(!igGetItemRectMax);
		*(cast(void**)&igGetItemRectMin) = GetProcAddress(handle, "igGetItemRectMin"); throwIf(!igGetItemRectMin);
		*(cast(void**)&igGetItemRectSize) = GetProcAddress(handle, "igGetItemRectSize"); throwIf(!igGetItemRectSize);
		*(cast(void**)&igGetItemStatusFlags) = GetProcAddress(handle, "igGetItemStatusFlags"); throwIf(!igGetItemStatusFlags);
		*(cast(void**)&igGetKeyChordName) = GetProcAddress(handle, "igGetKeyChordName"); throwIf(!igGetKeyChordName);
		*(cast(void**)&igGetKeyData_ContextPtr) = GetProcAddress(handle, "igGetKeyData_ContextPtr"); throwIf(!igGetKeyData_ContextPtr);
		*(cast(void**)&igGetKeyData_Key) = GetProcAddress(handle, "igGetKeyData_Key"); throwIf(!igGetKeyData_Key);
		*(cast(void**)&igGetKeyMagnitude2d) = GetProcAddress(handle, "igGetKeyMagnitude2d"); throwIf(!igGetKeyMagnitude2d);
		*(cast(void**)&igGetKeyName) = GetProcAddress(handle, "igGetKeyName"); throwIf(!igGetKeyName);
		*(cast(void**)&igGetKeyOwner) = GetProcAddress(handle, "igGetKeyOwner"); throwIf(!igGetKeyOwner);
		*(cast(void**)&igGetKeyOwnerData) = GetProcAddress(handle, "igGetKeyOwnerData"); throwIf(!igGetKeyOwnerData);
		*(cast(void**)&igGetKeyPressedAmount) = GetProcAddress(handle, "igGetKeyPressedAmount"); throwIf(!igGetKeyPressedAmount);
		*(cast(void**)&igGetMainViewport) = GetProcAddress(handle, "igGetMainViewport"); throwIf(!igGetMainViewport);
		*(cast(void**)&igGetMouseClickedCount) = GetProcAddress(handle, "igGetMouseClickedCount"); throwIf(!igGetMouseClickedCount);
		*(cast(void**)&igGetMouseCursor) = GetProcAddress(handle, "igGetMouseCursor"); throwIf(!igGetMouseCursor);
		*(cast(void**)&igGetMouseDragDelta) = GetProcAddress(handle, "igGetMouseDragDelta"); throwIf(!igGetMouseDragDelta);
		*(cast(void**)&igGetMousePos) = GetProcAddress(handle, "igGetMousePos"); throwIf(!igGetMousePos);
		*(cast(void**)&igGetMousePosOnOpeningCurrentPopup) = GetProcAddress(handle, "igGetMousePosOnOpeningCurrentPopup"); throwIf(!igGetMousePosOnOpeningCurrentPopup);
		*(cast(void**)&igGetMultiSelectState) = GetProcAddress(handle, "igGetMultiSelectState"); throwIf(!igGetMultiSelectState);
		*(cast(void**)&igGetNavTweakPressedAmount) = GetProcAddress(handle, "igGetNavTweakPressedAmount"); throwIf(!igGetNavTweakPressedAmount);
		*(cast(void**)&igGetPlatformIO) = GetProcAddress(handle, "igGetPlatformIO"); throwIf(!igGetPlatformIO);
		*(cast(void**)&igGetPopupAllowedExtentRect) = GetProcAddress(handle, "igGetPopupAllowedExtentRect"); throwIf(!igGetPopupAllowedExtentRect);
		*(cast(void**)&igGetScrollMaxX) = GetProcAddress(handle, "igGetScrollMaxX"); throwIf(!igGetScrollMaxX);
		*(cast(void**)&igGetScrollMaxY) = GetProcAddress(handle, "igGetScrollMaxY"); throwIf(!igGetScrollMaxY);
		*(cast(void**)&igGetScrollX) = GetProcAddress(handle, "igGetScrollX"); throwIf(!igGetScrollX);
		*(cast(void**)&igGetScrollY) = GetProcAddress(handle, "igGetScrollY"); throwIf(!igGetScrollY);
		*(cast(void**)&igGetShortcutRoutingData) = GetProcAddress(handle, "igGetShortcutRoutingData"); throwIf(!igGetShortcutRoutingData);
		*(cast(void**)&igGetStateStorage) = GetProcAddress(handle, "igGetStateStorage"); throwIf(!igGetStateStorage);
		*(cast(void**)&igGetStyle) = GetProcAddress(handle, "igGetStyle"); throwIf(!igGetStyle);
		*(cast(void**)&igGetStyleColorName) = GetProcAddress(handle, "igGetStyleColorName"); throwIf(!igGetStyleColorName);
		*(cast(void**)&igGetStyleColorVec4) = GetProcAddress(handle, "igGetStyleColorVec4"); throwIf(!igGetStyleColorVec4);
		*(cast(void**)&igGetStyleVarInfo) = GetProcAddress(handle, "igGetStyleVarInfo"); throwIf(!igGetStyleVarInfo);
		*(cast(void**)&igGetTextLineHeight) = GetProcAddress(handle, "igGetTextLineHeight"); throwIf(!igGetTextLineHeight);
		*(cast(void**)&igGetTextLineHeightWithSpacing) = GetProcAddress(handle, "igGetTextLineHeightWithSpacing"); throwIf(!igGetTextLineHeightWithSpacing);
		*(cast(void**)&igGetTime) = GetProcAddress(handle, "igGetTime"); throwIf(!igGetTime);
		*(cast(void**)&igGetTopMostAndVisiblePopupModal) = GetProcAddress(handle, "igGetTopMostAndVisiblePopupModal"); throwIf(!igGetTopMostAndVisiblePopupModal);
		*(cast(void**)&igGetTopMostPopupModal) = GetProcAddress(handle, "igGetTopMostPopupModal"); throwIf(!igGetTopMostPopupModal);
		*(cast(void**)&igGetTreeNodeToLabelSpacing) = GetProcAddress(handle, "igGetTreeNodeToLabelSpacing"); throwIf(!igGetTreeNodeToLabelSpacing);
		*(cast(void**)&igGetTypematicRepeatRate) = GetProcAddress(handle, "igGetTypematicRepeatRate"); throwIf(!igGetTypematicRepeatRate);
		*(cast(void**)&igGetTypingSelectRequest) = GetProcAddress(handle, "igGetTypingSelectRequest"); throwIf(!igGetTypingSelectRequest);
		*(cast(void**)&igGetVersion) = GetProcAddress(handle, "igGetVersion"); throwIf(!igGetVersion);
		*(cast(void**)&igGetViewportPlatformMonitor) = GetProcAddress(handle, "igGetViewportPlatformMonitor"); throwIf(!igGetViewportPlatformMonitor);
		*(cast(void**)&igGetWindowAlwaysWantOwnTabBar) = GetProcAddress(handle, "igGetWindowAlwaysWantOwnTabBar"); throwIf(!igGetWindowAlwaysWantOwnTabBar);
		*(cast(void**)&igGetWindowDockID) = GetProcAddress(handle, "igGetWindowDockID"); throwIf(!igGetWindowDockID);
		*(cast(void**)&igGetWindowDockNode) = GetProcAddress(handle, "igGetWindowDockNode"); throwIf(!igGetWindowDockNode);
		*(cast(void**)&igGetWindowDpiScale) = GetProcAddress(handle, "igGetWindowDpiScale"); throwIf(!igGetWindowDpiScale);
		*(cast(void**)&igGetWindowDrawList) = GetProcAddress(handle, "igGetWindowDrawList"); throwIf(!igGetWindowDrawList);
		*(cast(void**)&igGetWindowHeight) = GetProcAddress(handle, "igGetWindowHeight"); throwIf(!igGetWindowHeight);
		*(cast(void**)&igGetWindowPos) = GetProcAddress(handle, "igGetWindowPos"); throwIf(!igGetWindowPos);
		*(cast(void**)&igGetWindowResizeBorderID) = GetProcAddress(handle, "igGetWindowResizeBorderID"); throwIf(!igGetWindowResizeBorderID);
		*(cast(void**)&igGetWindowResizeCornerID) = GetProcAddress(handle, "igGetWindowResizeCornerID"); throwIf(!igGetWindowResizeCornerID);
		*(cast(void**)&igGetWindowScrollbarID) = GetProcAddress(handle, "igGetWindowScrollbarID"); throwIf(!igGetWindowScrollbarID);
		*(cast(void**)&igGetWindowScrollbarRect) = GetProcAddress(handle, "igGetWindowScrollbarRect"); throwIf(!igGetWindowScrollbarRect);
		*(cast(void**)&igGetWindowSize) = GetProcAddress(handle, "igGetWindowSize"); throwIf(!igGetWindowSize);
		*(cast(void**)&igGetWindowViewport) = GetProcAddress(handle, "igGetWindowViewport"); throwIf(!igGetWindowViewport);
		*(cast(void**)&igGetWindowWidth) = GetProcAddress(handle, "igGetWindowWidth"); throwIf(!igGetWindowWidth);
		*(cast(void**)&igImAbs_Float) = GetProcAddress(handle, "igImAbs_Float"); throwIf(!igImAbs_Float);
		*(cast(void**)&igImAbs_Int) = GetProcAddress(handle, "igImAbs_Int"); throwIf(!igImAbs_Int);
		*(cast(void**)&igImAbs_double) = GetProcAddress(handle, "igImAbs_double"); throwIf(!igImAbs_double);
		*(cast(void**)&igImAlphaBlendColors) = GetProcAddress(handle, "igImAlphaBlendColors"); throwIf(!igImAlphaBlendColors);
		*(cast(void**)&igImBezierCubicCalc) = GetProcAddress(handle, "igImBezierCubicCalc"); throwIf(!igImBezierCubicCalc);
		*(cast(void**)&igImBezierCubicClosestPoint) = GetProcAddress(handle, "igImBezierCubicClosestPoint"); throwIf(!igImBezierCubicClosestPoint);
		*(cast(void**)&igImBezierCubicClosestPointCasteljau) = GetProcAddress(handle, "igImBezierCubicClosestPointCasteljau"); throwIf(!igImBezierCubicClosestPointCasteljau);
		*(cast(void**)&igImBezierQuadraticCalc) = GetProcAddress(handle, "igImBezierQuadraticCalc"); throwIf(!igImBezierQuadraticCalc);
		*(cast(void**)&igImBitArrayClearAllBits) = GetProcAddress(handle, "igImBitArrayClearAllBits"); throwIf(!igImBitArrayClearAllBits);
		*(cast(void**)&igImBitArrayClearBit) = GetProcAddress(handle, "igImBitArrayClearBit"); throwIf(!igImBitArrayClearBit);
		*(cast(void**)&igImBitArrayGetStorageSizeInBytes) = GetProcAddress(handle, "igImBitArrayGetStorageSizeInBytes"); throwIf(!igImBitArrayGetStorageSizeInBytes);
		*(cast(void**)&igImBitArraySetBit) = GetProcAddress(handle, "igImBitArraySetBit"); throwIf(!igImBitArraySetBit);
		*(cast(void**)&igImBitArraySetBitRange) = GetProcAddress(handle, "igImBitArraySetBitRange"); throwIf(!igImBitArraySetBitRange);
		*(cast(void**)&igImBitArrayTestBit) = GetProcAddress(handle, "igImBitArrayTestBit"); throwIf(!igImBitArrayTestBit);
		*(cast(void**)&igImCharIsBlankA) = GetProcAddress(handle, "igImCharIsBlankA"); throwIf(!igImCharIsBlankA);
		*(cast(void**)&igImCharIsBlankW) = GetProcAddress(handle, "igImCharIsBlankW"); throwIf(!igImCharIsBlankW);
		*(cast(void**)&igImCharIsXdigitA) = GetProcAddress(handle, "igImCharIsXdigitA"); throwIf(!igImCharIsXdigitA);
		*(cast(void**)&igImClamp) = GetProcAddress(handle, "igImClamp"); throwIf(!igImClamp);
		*(cast(void**)&igImDot) = GetProcAddress(handle, "igImDot"); throwIf(!igImDot);
		*(cast(void**)&igImExponentialMovingAverage) = GetProcAddress(handle, "igImExponentialMovingAverage"); throwIf(!igImExponentialMovingAverage);
		*(cast(void**)&igImFileClose) = GetProcAddress(handle, "igImFileClose"); throwIf(!igImFileClose);
		*(cast(void**)&igImFileGetSize) = GetProcAddress(handle, "igImFileGetSize"); throwIf(!igImFileGetSize);
		*(cast(void**)&igImFileLoadToMemory) = GetProcAddress(handle, "igImFileLoadToMemory"); throwIf(!igImFileLoadToMemory);
		*(cast(void**)&igImFileOpen) = GetProcAddress(handle, "igImFileOpen"); throwIf(!igImFileOpen);
		*(cast(void**)&igImFileRead) = GetProcAddress(handle, "igImFileRead"); throwIf(!igImFileRead);
		*(cast(void**)&igImFileWrite) = GetProcAddress(handle, "igImFileWrite"); throwIf(!igImFileWrite);
		*(cast(void**)&igImFloor_Float) = GetProcAddress(handle, "igImFloor_Float"); throwIf(!igImFloor_Float);
		*(cast(void**)&igImFloor_Vec2) = GetProcAddress(handle, "igImFloor_Vec2"); throwIf(!igImFloor_Vec2);
		*(cast(void**)&igImFontAtlasBuildFinish) = GetProcAddress(handle, "igImFontAtlasBuildFinish"); throwIf(!igImFontAtlasBuildFinish);
		*(cast(void**)&igImFontAtlasBuildInit) = GetProcAddress(handle, "igImFontAtlasBuildInit"); throwIf(!igImFontAtlasBuildInit);
		*(cast(void**)&igImFontAtlasBuildMultiplyCalcLookupTable) = GetProcAddress(handle, "igImFontAtlasBuildMultiplyCalcLookupTable"); throwIf(!igImFontAtlasBuildMultiplyCalcLookupTable);
		*(cast(void**)&igImFontAtlasBuildMultiplyRectAlpha8) = GetProcAddress(handle, "igImFontAtlasBuildMultiplyRectAlpha8"); throwIf(!igImFontAtlasBuildMultiplyRectAlpha8);
		*(cast(void**)&igImFontAtlasBuildPackCustomRects) = GetProcAddress(handle, "igImFontAtlasBuildPackCustomRects"); throwIf(!igImFontAtlasBuildPackCustomRects);
		*(cast(void**)&igImFontAtlasBuildRender32bppRectFromString) = GetProcAddress(handle, "igImFontAtlasBuildRender32bppRectFromString"); throwIf(!igImFontAtlasBuildRender32bppRectFromString);
		*(cast(void**)&igImFontAtlasBuildRender8bppRectFromString) = GetProcAddress(handle, "igImFontAtlasBuildRender8bppRectFromString"); throwIf(!igImFontAtlasBuildRender8bppRectFromString);
		*(cast(void**)&igImFontAtlasBuildSetupFont) = GetProcAddress(handle, "igImFontAtlasBuildSetupFont"); throwIf(!igImFontAtlasBuildSetupFont);
		*(cast(void**)&igImFontAtlasGetBuilderForStbTruetype) = GetProcAddress(handle, "igImFontAtlasGetBuilderForStbTruetype"); throwIf(!igImFontAtlasGetBuilderForStbTruetype);
		*(cast(void**)&igImFontAtlasUpdateConfigDataPointers) = GetProcAddress(handle, "igImFontAtlasUpdateConfigDataPointers"); throwIf(!igImFontAtlasUpdateConfigDataPointers);
		*(cast(void**)&igImFormatString) = GetProcAddress(handle, "igImFormatString"); throwIf(!igImFormatString);
		*(cast(void**)&igImFormatStringToTempBuffer) = GetProcAddress(handle, "igImFormatStringToTempBuffer"); throwIf(!igImFormatStringToTempBuffer);
		*(cast(void**)&igImFormatStringToTempBufferV) = GetProcAddress(handle, "igImFormatStringToTempBufferV"); throwIf(!igImFormatStringToTempBufferV);
		*(cast(void**)&igImFormatStringV) = GetProcAddress(handle, "igImFormatStringV"); throwIf(!igImFormatStringV);
		*(cast(void**)&igImHashData) = GetProcAddress(handle, "igImHashData"); throwIf(!igImHashData);
		*(cast(void**)&igImHashStr) = GetProcAddress(handle, "igImHashStr"); throwIf(!igImHashStr);
		*(cast(void**)&igImInvLength) = GetProcAddress(handle, "igImInvLength"); throwIf(!igImInvLength);
		*(cast(void**)&igImIsFloatAboveGuaranteedIntegerPrecision) = GetProcAddress(handle, "igImIsFloatAboveGuaranteedIntegerPrecision"); throwIf(!igImIsFloatAboveGuaranteedIntegerPrecision);
		*(cast(void**)&igImIsPowerOfTwo_Int) = GetProcAddress(handle, "igImIsPowerOfTwo_Int"); throwIf(!igImIsPowerOfTwo_Int);
		*(cast(void**)&igImIsPowerOfTwo_U64) = GetProcAddress(handle, "igImIsPowerOfTwo_U64"); throwIf(!igImIsPowerOfTwo_U64);
		*(cast(void**)&igImLengthSqr_Vec2) = GetProcAddress(handle, "igImLengthSqr_Vec2"); throwIf(!igImLengthSqr_Vec2);
		*(cast(void**)&igImLengthSqr_Vec4) = GetProcAddress(handle, "igImLengthSqr_Vec4"); throwIf(!igImLengthSqr_Vec4);
		*(cast(void**)&igImLerp_Vec2Float) = GetProcAddress(handle, "igImLerp_Vec2Float"); throwIf(!igImLerp_Vec2Float);
		*(cast(void**)&igImLerp_Vec2Vec2) = GetProcAddress(handle, "igImLerp_Vec2Vec2"); throwIf(!igImLerp_Vec2Vec2);
		*(cast(void**)&igImLerp_Vec4) = GetProcAddress(handle, "igImLerp_Vec4"); throwIf(!igImLerp_Vec4);
		*(cast(void**)&igImLineClosestPoint) = GetProcAddress(handle, "igImLineClosestPoint"); throwIf(!igImLineClosestPoint);
		*(cast(void**)&igImLinearRemapClamp) = GetProcAddress(handle, "igImLinearRemapClamp"); throwIf(!igImLinearRemapClamp);
		*(cast(void**)&igImLinearSweep) = GetProcAddress(handle, "igImLinearSweep"); throwIf(!igImLinearSweep);
		*(cast(void**)&igImLog_Float) = GetProcAddress(handle, "igImLog_Float"); throwIf(!igImLog_Float);
		*(cast(void**)&igImLog_double) = GetProcAddress(handle, "igImLog_double"); throwIf(!igImLog_double);
		*(cast(void**)&igImLowerBound) = GetProcAddress(handle, "igImLowerBound"); throwIf(!igImLowerBound);
		*(cast(void**)&igImMax) = GetProcAddress(handle, "igImMax"); throwIf(!igImMax);
		*(cast(void**)&igImMin) = GetProcAddress(handle, "igImMin"); throwIf(!igImMin);
		*(cast(void**)&igImModPositive) = GetProcAddress(handle, "igImModPositive"); throwIf(!igImModPositive);
		*(cast(void**)&igImMul) = GetProcAddress(handle, "igImMul"); throwIf(!igImMul);
		*(cast(void**)&igImParseFormatFindEnd) = GetProcAddress(handle, "igImParseFormatFindEnd"); throwIf(!igImParseFormatFindEnd);
		*(cast(void**)&igImParseFormatFindStart) = GetProcAddress(handle, "igImParseFormatFindStart"); throwIf(!igImParseFormatFindStart);
		*(cast(void**)&igImParseFormatPrecision) = GetProcAddress(handle, "igImParseFormatPrecision"); throwIf(!igImParseFormatPrecision);
		*(cast(void**)&igImParseFormatSanitizeForPrinting) = GetProcAddress(handle, "igImParseFormatSanitizeForPrinting"); throwIf(!igImParseFormatSanitizeForPrinting);
		*(cast(void**)&igImParseFormatSanitizeForScanning) = GetProcAddress(handle, "igImParseFormatSanitizeForScanning"); throwIf(!igImParseFormatSanitizeForScanning);
		*(cast(void**)&igImParseFormatTrimDecorations) = GetProcAddress(handle, "igImParseFormatTrimDecorations"); throwIf(!igImParseFormatTrimDecorations);
		*(cast(void**)&igImPow_Float) = GetProcAddress(handle, "igImPow_Float"); throwIf(!igImPow_Float);
		*(cast(void**)&igImPow_double) = GetProcAddress(handle, "igImPow_double"); throwIf(!igImPow_double);
		*(cast(void**)&igImQsort) = GetProcAddress(handle, "igImQsort"); throwIf(!igImQsort);
		*(cast(void**)&igImRotate) = GetProcAddress(handle, "igImRotate"); throwIf(!igImRotate);
		*(cast(void**)&igImRsqrt_Float) = GetProcAddress(handle, "igImRsqrt_Float"); throwIf(!igImRsqrt_Float);
		*(cast(void**)&igImRsqrt_double) = GetProcAddress(handle, "igImRsqrt_double"); throwIf(!igImRsqrt_double);
		*(cast(void**)&igImSaturate) = GetProcAddress(handle, "igImSaturate"); throwIf(!igImSaturate);
		*(cast(void**)&igImSign_Float) = GetProcAddress(handle, "igImSign_Float"); throwIf(!igImSign_Float);
		*(cast(void**)&igImSign_double) = GetProcAddress(handle, "igImSign_double"); throwIf(!igImSign_double);
		*(cast(void**)&igImStrSkipBlank) = GetProcAddress(handle, "igImStrSkipBlank"); throwIf(!igImStrSkipBlank);
		*(cast(void**)&igImStrTrimBlanks) = GetProcAddress(handle, "igImStrTrimBlanks"); throwIf(!igImStrTrimBlanks);
		*(cast(void**)&igImStrbolW) = GetProcAddress(handle, "igImStrbolW"); throwIf(!igImStrbolW);
		*(cast(void**)&igImStrchrRange) = GetProcAddress(handle, "igImStrchrRange"); throwIf(!igImStrchrRange);
		*(cast(void**)&igImStrdup) = GetProcAddress(handle, "igImStrdup"); throwIf(!igImStrdup);
		*(cast(void**)&igImStrdupcpy) = GetProcAddress(handle, "igImStrdupcpy"); throwIf(!igImStrdupcpy);
		*(cast(void**)&igImStreolRange) = GetProcAddress(handle, "igImStreolRange"); throwIf(!igImStreolRange);
		*(cast(void**)&igImStricmp) = GetProcAddress(handle, "igImStricmp"); throwIf(!igImStricmp);
		*(cast(void**)&igImStristr) = GetProcAddress(handle, "igImStristr"); throwIf(!igImStristr);
		*(cast(void**)&igImStrlenW) = GetProcAddress(handle, "igImStrlenW"); throwIf(!igImStrlenW);
		*(cast(void**)&igImStrncpy) = GetProcAddress(handle, "igImStrncpy"); throwIf(!igImStrncpy);
		*(cast(void**)&igImStrnicmp) = GetProcAddress(handle, "igImStrnicmp"); throwIf(!igImStrnicmp);
		*(cast(void**)&igImTextCharFromUtf8) = GetProcAddress(handle, "igImTextCharFromUtf8"); throwIf(!igImTextCharFromUtf8);
		*(cast(void**)&igImTextCharToUtf8) = GetProcAddress(handle, "igImTextCharToUtf8"); throwIf(!igImTextCharToUtf8);
		*(cast(void**)&igImTextCountCharsFromUtf8) = GetProcAddress(handle, "igImTextCountCharsFromUtf8"); throwIf(!igImTextCountCharsFromUtf8);
		*(cast(void**)&igImTextCountLines) = GetProcAddress(handle, "igImTextCountLines"); throwIf(!igImTextCountLines);
		*(cast(void**)&igImTextCountUtf8BytesFromChar) = GetProcAddress(handle, "igImTextCountUtf8BytesFromChar"); throwIf(!igImTextCountUtf8BytesFromChar);
		*(cast(void**)&igImTextCountUtf8BytesFromStr) = GetProcAddress(handle, "igImTextCountUtf8BytesFromStr"); throwIf(!igImTextCountUtf8BytesFromStr);
		*(cast(void**)&igImTextFindPreviousUtf8Codepoint) = GetProcAddress(handle, "igImTextFindPreviousUtf8Codepoint"); throwIf(!igImTextFindPreviousUtf8Codepoint);
		*(cast(void**)&igImTextStrFromUtf8) = GetProcAddress(handle, "igImTextStrFromUtf8"); throwIf(!igImTextStrFromUtf8);
		*(cast(void**)&igImTextStrToUtf8) = GetProcAddress(handle, "igImTextStrToUtf8"); throwIf(!igImTextStrToUtf8);
		*(cast(void**)&igImToUpper) = GetProcAddress(handle, "igImToUpper"); throwIf(!igImToUpper);
		*(cast(void**)&igImTriangleArea) = GetProcAddress(handle, "igImTriangleArea"); throwIf(!igImTriangleArea);
		*(cast(void**)&igImTriangleBarycentricCoords) = GetProcAddress(handle, "igImTriangleBarycentricCoords"); throwIf(!igImTriangleBarycentricCoords);
		*(cast(void**)&igImTriangleClosestPoint) = GetProcAddress(handle, "igImTriangleClosestPoint"); throwIf(!igImTriangleClosestPoint);
		*(cast(void**)&igImTriangleContainsPoint) = GetProcAddress(handle, "igImTriangleContainsPoint"); throwIf(!igImTriangleContainsPoint);
		*(cast(void**)&igImTriangleIsClockwise) = GetProcAddress(handle, "igImTriangleIsClockwise"); throwIf(!igImTriangleIsClockwise);
		*(cast(void**)&igImTrunc_Float) = GetProcAddress(handle, "igImTrunc_Float"); throwIf(!igImTrunc_Float);
		*(cast(void**)&igImTrunc_Vec2) = GetProcAddress(handle, "igImTrunc_Vec2"); throwIf(!igImTrunc_Vec2);
		*(cast(void**)&igImUpperPowerOfTwo) = GetProcAddress(handle, "igImUpperPowerOfTwo"); throwIf(!igImUpperPowerOfTwo);
		*(cast(void**)&igImage) = GetProcAddress(handle, "igImage"); throwIf(!igImage);
		*(cast(void**)&igImageButton) = GetProcAddress(handle, "igImageButton"); throwIf(!igImageButton);
		*(cast(void**)&igImageButtonEx) = GetProcAddress(handle, "igImageButtonEx"); throwIf(!igImageButtonEx);
		*(cast(void**)&igIndent) = GetProcAddress(handle, "igIndent"); throwIf(!igIndent);
		*(cast(void**)&igInitialize) = GetProcAddress(handle, "igInitialize"); throwIf(!igInitialize);
		*(cast(void**)&igInputDouble) = GetProcAddress(handle, "igInputDouble"); throwIf(!igInputDouble);
		*(cast(void**)&igInputFloat) = GetProcAddress(handle, "igInputFloat"); throwIf(!igInputFloat);
		*(cast(void**)&igInputFloat2) = GetProcAddress(handle, "igInputFloat2"); throwIf(!igInputFloat2);
		*(cast(void**)&igInputFloat3) = GetProcAddress(handle, "igInputFloat3"); throwIf(!igInputFloat3);
		*(cast(void**)&igInputFloat4) = GetProcAddress(handle, "igInputFloat4"); throwIf(!igInputFloat4);
		*(cast(void**)&igInputInt) = GetProcAddress(handle, "igInputInt"); throwIf(!igInputInt);
		*(cast(void**)&igInputInt2) = GetProcAddress(handle, "igInputInt2"); throwIf(!igInputInt2);
		*(cast(void**)&igInputInt3) = GetProcAddress(handle, "igInputInt3"); throwIf(!igInputInt3);
		*(cast(void**)&igInputInt4) = GetProcAddress(handle, "igInputInt4"); throwIf(!igInputInt4);
		*(cast(void**)&igInputScalar) = GetProcAddress(handle, "igInputScalar"); throwIf(!igInputScalar);
		*(cast(void**)&igInputScalarN) = GetProcAddress(handle, "igInputScalarN"); throwIf(!igInputScalarN);
		*(cast(void**)&igInputText) = GetProcAddress(handle, "igInputText"); throwIf(!igInputText);
		*(cast(void**)&igInputTextDeactivateHook) = GetProcAddress(handle, "igInputTextDeactivateHook"); throwIf(!igInputTextDeactivateHook);
		*(cast(void**)&igInputTextEx) = GetProcAddress(handle, "igInputTextEx"); throwIf(!igInputTextEx);
		*(cast(void**)&igInputTextMultiline) = GetProcAddress(handle, "igInputTextMultiline"); throwIf(!igInputTextMultiline);
		*(cast(void**)&igInputTextWithHint) = GetProcAddress(handle, "igInputTextWithHint"); throwIf(!igInputTextWithHint);
		*(cast(void**)&igInvisibleButton) = GetProcAddress(handle, "igInvisibleButton"); throwIf(!igInvisibleButton);
		*(cast(void**)&igIsActiveIdUsingNavDir) = GetProcAddress(handle, "igIsActiveIdUsingNavDir"); throwIf(!igIsActiveIdUsingNavDir);
		*(cast(void**)&igIsAliasKey) = GetProcAddress(handle, "igIsAliasKey"); throwIf(!igIsAliasKey);
		*(cast(void**)&igIsAnyItemActive) = GetProcAddress(handle, "igIsAnyItemActive"); throwIf(!igIsAnyItemActive);
		*(cast(void**)&igIsAnyItemFocused) = GetProcAddress(handle, "igIsAnyItemFocused"); throwIf(!igIsAnyItemFocused);
		*(cast(void**)&igIsAnyItemHovered) = GetProcAddress(handle, "igIsAnyItemHovered"); throwIf(!igIsAnyItemHovered);
		*(cast(void**)&igIsAnyMouseDown) = GetProcAddress(handle, "igIsAnyMouseDown"); throwIf(!igIsAnyMouseDown);
		*(cast(void**)&igIsClippedEx) = GetProcAddress(handle, "igIsClippedEx"); throwIf(!igIsClippedEx);
		*(cast(void**)&igIsDragDropActive) = GetProcAddress(handle, "igIsDragDropActive"); throwIf(!igIsDragDropActive);
		*(cast(void**)&igIsDragDropPayloadBeingAccepted) = GetProcAddress(handle, "igIsDragDropPayloadBeingAccepted"); throwIf(!igIsDragDropPayloadBeingAccepted);
		*(cast(void**)&igIsGamepadKey) = GetProcAddress(handle, "igIsGamepadKey"); throwIf(!igIsGamepadKey);
		*(cast(void**)&igIsItemActivated) = GetProcAddress(handle, "igIsItemActivated"); throwIf(!igIsItemActivated);
		*(cast(void**)&igIsItemActive) = GetProcAddress(handle, "igIsItemActive"); throwIf(!igIsItemActive);
		*(cast(void**)&igIsItemClicked) = GetProcAddress(handle, "igIsItemClicked"); throwIf(!igIsItemClicked);
		*(cast(void**)&igIsItemDeactivated) = GetProcAddress(handle, "igIsItemDeactivated"); throwIf(!igIsItemDeactivated);
		*(cast(void**)&igIsItemDeactivatedAfterEdit) = GetProcAddress(handle, "igIsItemDeactivatedAfterEdit"); throwIf(!igIsItemDeactivatedAfterEdit);
		*(cast(void**)&igIsItemEdited) = GetProcAddress(handle, "igIsItemEdited"); throwIf(!igIsItemEdited);
		*(cast(void**)&igIsItemFocused) = GetProcAddress(handle, "igIsItemFocused"); throwIf(!igIsItemFocused);
		*(cast(void**)&igIsItemHovered) = GetProcAddress(handle, "igIsItemHovered"); throwIf(!igIsItemHovered);
		*(cast(void**)&igIsItemToggledOpen) = GetProcAddress(handle, "igIsItemToggledOpen"); throwIf(!igIsItemToggledOpen);
		*(cast(void**)&igIsItemToggledSelection) = GetProcAddress(handle, "igIsItemToggledSelection"); throwIf(!igIsItemToggledSelection);
		*(cast(void**)&igIsItemVisible) = GetProcAddress(handle, "igIsItemVisible"); throwIf(!igIsItemVisible);
		*(cast(void**)&igIsKeyChordPressed_InputFlags) = GetProcAddress(handle, "igIsKeyChordPressed_InputFlags"); throwIf(!igIsKeyChordPressed_InputFlags);
		*(cast(void**)&igIsKeyChordPressed_Nil) = GetProcAddress(handle, "igIsKeyChordPressed_Nil"); throwIf(!igIsKeyChordPressed_Nil);
		*(cast(void**)&igIsKeyDown_ID) = GetProcAddress(handle, "igIsKeyDown_ID"); throwIf(!igIsKeyDown_ID);
		*(cast(void**)&igIsKeyDown_Nil) = GetProcAddress(handle, "igIsKeyDown_Nil"); throwIf(!igIsKeyDown_Nil);
		*(cast(void**)&igIsKeyPressed_Bool) = GetProcAddress(handle, "igIsKeyPressed_Bool"); throwIf(!igIsKeyPressed_Bool);
		*(cast(void**)&igIsKeyPressed_InputFlags) = GetProcAddress(handle, "igIsKeyPressed_InputFlags"); throwIf(!igIsKeyPressed_InputFlags);
		*(cast(void**)&igIsKeyReleased_ID) = GetProcAddress(handle, "igIsKeyReleased_ID"); throwIf(!igIsKeyReleased_ID);
		*(cast(void**)&igIsKeyReleased_Nil) = GetProcAddress(handle, "igIsKeyReleased_Nil"); throwIf(!igIsKeyReleased_Nil);
		*(cast(void**)&igIsKeyboardKey) = GetProcAddress(handle, "igIsKeyboardKey"); throwIf(!igIsKeyboardKey);
		*(cast(void**)&igIsLegacyKey) = GetProcAddress(handle, "igIsLegacyKey"); throwIf(!igIsLegacyKey);
		*(cast(void**)&igIsModKey) = GetProcAddress(handle, "igIsModKey"); throwIf(!igIsModKey);
		*(cast(void**)&igIsMouseClicked_Bool) = GetProcAddress(handle, "igIsMouseClicked_Bool"); throwIf(!igIsMouseClicked_Bool);
		*(cast(void**)&igIsMouseClicked_InputFlags) = GetProcAddress(handle, "igIsMouseClicked_InputFlags"); throwIf(!igIsMouseClicked_InputFlags);
		*(cast(void**)&igIsMouseDoubleClicked_ID) = GetProcAddress(handle, "igIsMouseDoubleClicked_ID"); throwIf(!igIsMouseDoubleClicked_ID);
		*(cast(void**)&igIsMouseDoubleClicked_Nil) = GetProcAddress(handle, "igIsMouseDoubleClicked_Nil"); throwIf(!igIsMouseDoubleClicked_Nil);
		*(cast(void**)&igIsMouseDown_ID) = GetProcAddress(handle, "igIsMouseDown_ID"); throwIf(!igIsMouseDown_ID);
		*(cast(void**)&igIsMouseDown_Nil) = GetProcAddress(handle, "igIsMouseDown_Nil"); throwIf(!igIsMouseDown_Nil);
		*(cast(void**)&igIsMouseDragPastThreshold) = GetProcAddress(handle, "igIsMouseDragPastThreshold"); throwIf(!igIsMouseDragPastThreshold);
		*(cast(void**)&igIsMouseDragging) = GetProcAddress(handle, "igIsMouseDragging"); throwIf(!igIsMouseDragging);
		*(cast(void**)&igIsMouseHoveringRect) = GetProcAddress(handle, "igIsMouseHoveringRect"); throwIf(!igIsMouseHoveringRect);
		*(cast(void**)&igIsMouseKey) = GetProcAddress(handle, "igIsMouseKey"); throwIf(!igIsMouseKey);
		*(cast(void**)&igIsMousePosValid) = GetProcAddress(handle, "igIsMousePosValid"); throwIf(!igIsMousePosValid);
		*(cast(void**)&igIsMouseReleased_ID) = GetProcAddress(handle, "igIsMouseReleased_ID"); throwIf(!igIsMouseReleased_ID);
		*(cast(void**)&igIsMouseReleased_Nil) = GetProcAddress(handle, "igIsMouseReleased_Nil"); throwIf(!igIsMouseReleased_Nil);
		*(cast(void**)&igIsNamedKey) = GetProcAddress(handle, "igIsNamedKey"); throwIf(!igIsNamedKey);
		*(cast(void**)&igIsNamedKeyOrMod) = GetProcAddress(handle, "igIsNamedKeyOrMod"); throwIf(!igIsNamedKeyOrMod);
		*(cast(void**)&igIsPopupOpen_ID) = GetProcAddress(handle, "igIsPopupOpen_ID"); throwIf(!igIsPopupOpen_ID);
		*(cast(void**)&igIsPopupOpen_Str) = GetProcAddress(handle, "igIsPopupOpen_Str"); throwIf(!igIsPopupOpen_Str);
		*(cast(void**)&igIsRectVisible_Nil) = GetProcAddress(handle, "igIsRectVisible_Nil"); throwIf(!igIsRectVisible_Nil);
		*(cast(void**)&igIsRectVisible_Vec2) = GetProcAddress(handle, "igIsRectVisible_Vec2"); throwIf(!igIsRectVisible_Vec2);
		*(cast(void**)&igIsWindowAbove) = GetProcAddress(handle, "igIsWindowAbove"); throwIf(!igIsWindowAbove);
		*(cast(void**)&igIsWindowAppearing) = GetProcAddress(handle, "igIsWindowAppearing"); throwIf(!igIsWindowAppearing);
		*(cast(void**)&igIsWindowChildOf) = GetProcAddress(handle, "igIsWindowChildOf"); throwIf(!igIsWindowChildOf);
		*(cast(void**)&igIsWindowCollapsed) = GetProcAddress(handle, "igIsWindowCollapsed"); throwIf(!igIsWindowCollapsed);
		*(cast(void**)&igIsWindowContentHoverable) = GetProcAddress(handle, "igIsWindowContentHoverable"); throwIf(!igIsWindowContentHoverable);
		*(cast(void**)&igIsWindowDocked) = GetProcAddress(handle, "igIsWindowDocked"); throwIf(!igIsWindowDocked);
		*(cast(void**)&igIsWindowFocused) = GetProcAddress(handle, "igIsWindowFocused"); throwIf(!igIsWindowFocused);
		*(cast(void**)&igIsWindowHovered) = GetProcAddress(handle, "igIsWindowHovered"); throwIf(!igIsWindowHovered);
		*(cast(void**)&igIsWindowNavFocusable) = GetProcAddress(handle, "igIsWindowNavFocusable"); throwIf(!igIsWindowNavFocusable);
		*(cast(void**)&igIsWindowWithinBeginStackOf) = GetProcAddress(handle, "igIsWindowWithinBeginStackOf"); throwIf(!igIsWindowWithinBeginStackOf);
		*(cast(void**)&igItemAdd) = GetProcAddress(handle, "igItemAdd"); throwIf(!igItemAdd);
		*(cast(void**)&igItemHoverable) = GetProcAddress(handle, "igItemHoverable"); throwIf(!igItemHoverable);
		*(cast(void**)&igItemSize_Rect) = GetProcAddress(handle, "igItemSize_Rect"); throwIf(!igItemSize_Rect);
		*(cast(void**)&igItemSize_Vec2) = GetProcAddress(handle, "igItemSize_Vec2"); throwIf(!igItemSize_Vec2);
		*(cast(void**)&igKeepAliveID) = GetProcAddress(handle, "igKeepAliveID"); throwIf(!igKeepAliveID);
		*(cast(void**)&igLabelText) = GetProcAddress(handle, "igLabelText"); throwIf(!igLabelText);
		*(cast(void**)&igLabelTextV) = GetProcAddress(handle, "igLabelTextV"); throwIf(!igLabelTextV);
		*(cast(void**)&igListBox_FnStrPtr) = GetProcAddress(handle, "igListBox_FnStrPtr"); throwIf(!igListBox_FnStrPtr);
		*(cast(void**)&igListBox_Str_arr) = GetProcAddress(handle, "igListBox_Str_arr"); throwIf(!igListBox_Str_arr);
		*(cast(void**)&igLoadIniSettingsFromDisk) = GetProcAddress(handle, "igLoadIniSettingsFromDisk"); throwIf(!igLoadIniSettingsFromDisk);
		*(cast(void**)&igLoadIniSettingsFromMemory) = GetProcAddress(handle, "igLoadIniSettingsFromMemory"); throwIf(!igLoadIniSettingsFromMemory);
		*(cast(void**)&igLocalizeGetMsg) = GetProcAddress(handle, "igLocalizeGetMsg"); throwIf(!igLocalizeGetMsg);
		*(cast(void**)&igLocalizeRegisterEntries) = GetProcAddress(handle, "igLocalizeRegisterEntries"); throwIf(!igLocalizeRegisterEntries);
		*(cast(void**)&igLogBegin) = GetProcAddress(handle, "igLogBegin"); throwIf(!igLogBegin);
		*(cast(void**)&igLogButtons) = GetProcAddress(handle, "igLogButtons"); throwIf(!igLogButtons);
		*(cast(void**)&igLogFinish) = GetProcAddress(handle, "igLogFinish"); throwIf(!igLogFinish);
		*(cast(void**)&igLogRenderedText) = GetProcAddress(handle, "igLogRenderedText"); throwIf(!igLogRenderedText);
		*(cast(void**)&igLogSetNextTextDecoration) = GetProcAddress(handle, "igLogSetNextTextDecoration"); throwIf(!igLogSetNextTextDecoration);
		*(cast(void**)&igLogText) = GetProcAddress(handle, "igLogText"); throwIf(!igLogText);
		*(cast(void**)&igLogTextV) = GetProcAddress(handle, "igLogTextV"); throwIf(!igLogTextV);
		*(cast(void**)&igLogToBuffer) = GetProcAddress(handle, "igLogToBuffer"); throwIf(!igLogToBuffer);
		*(cast(void**)&igLogToClipboard) = GetProcAddress(handle, "igLogToClipboard"); throwIf(!igLogToClipboard);
		*(cast(void**)&igLogToFile) = GetProcAddress(handle, "igLogToFile"); throwIf(!igLogToFile);
		*(cast(void**)&igLogToTTY) = GetProcAddress(handle, "igLogToTTY"); throwIf(!igLogToTTY);
		*(cast(void**)&igMarkIniSettingsDirty_Nil) = GetProcAddress(handle, "igMarkIniSettingsDirty_Nil"); throwIf(!igMarkIniSettingsDirty_Nil);
		*(cast(void**)&igMarkIniSettingsDirty_WindowPtr) = GetProcAddress(handle, "igMarkIniSettingsDirty_WindowPtr"); throwIf(!igMarkIniSettingsDirty_WindowPtr);
		*(cast(void**)&igMarkItemEdited) = GetProcAddress(handle, "igMarkItemEdited"); throwIf(!igMarkItemEdited);
		*(cast(void**)&igMemAlloc) = GetProcAddress(handle, "igMemAlloc"); throwIf(!igMemAlloc);
		*(cast(void**)&igMemFree) = GetProcAddress(handle, "igMemFree"); throwIf(!igMemFree);
		*(cast(void**)&igMenuItemEx) = GetProcAddress(handle, "igMenuItemEx"); throwIf(!igMenuItemEx);
		*(cast(void**)&igMenuItem_Bool) = GetProcAddress(handle, "igMenuItem_Bool"); throwIf(!igMenuItem_Bool);
		*(cast(void**)&igMenuItem_BoolPtr) = GetProcAddress(handle, "igMenuItem_BoolPtr"); throwIf(!igMenuItem_BoolPtr);
		*(cast(void**)&igMouseButtonToKey) = GetProcAddress(handle, "igMouseButtonToKey"); throwIf(!igMouseButtonToKey);
		*(cast(void**)&igMultiSelectAddSetAll) = GetProcAddress(handle, "igMultiSelectAddSetAll"); throwIf(!igMultiSelectAddSetAll);
		*(cast(void**)&igMultiSelectAddSetRange) = GetProcAddress(handle, "igMultiSelectAddSetRange"); throwIf(!igMultiSelectAddSetRange);
		*(cast(void**)&igMultiSelectItemFooter) = GetProcAddress(handle, "igMultiSelectItemFooter"); throwIf(!igMultiSelectItemFooter);
		*(cast(void**)&igMultiSelectItemHeader) = GetProcAddress(handle, "igMultiSelectItemHeader"); throwIf(!igMultiSelectItemHeader);
		*(cast(void**)&igNavClearPreferredPosForAxis) = GetProcAddress(handle, "igNavClearPreferredPosForAxis"); throwIf(!igNavClearPreferredPosForAxis);
		*(cast(void**)&igNavHighlightActivated) = GetProcAddress(handle, "igNavHighlightActivated"); throwIf(!igNavHighlightActivated);
		*(cast(void**)&igNavInitRequestApplyResult) = GetProcAddress(handle, "igNavInitRequestApplyResult"); throwIf(!igNavInitRequestApplyResult);
		*(cast(void**)&igNavInitWindow) = GetProcAddress(handle, "igNavInitWindow"); throwIf(!igNavInitWindow);
		*(cast(void**)&igNavMoveRequestApplyResult) = GetProcAddress(handle, "igNavMoveRequestApplyResult"); throwIf(!igNavMoveRequestApplyResult);
		*(cast(void**)&igNavMoveRequestButNoResultYet) = GetProcAddress(handle, "igNavMoveRequestButNoResultYet"); throwIf(!igNavMoveRequestButNoResultYet);
		*(cast(void**)&igNavMoveRequestCancel) = GetProcAddress(handle, "igNavMoveRequestCancel"); throwIf(!igNavMoveRequestCancel);
		*(cast(void**)&igNavMoveRequestForward) = GetProcAddress(handle, "igNavMoveRequestForward"); throwIf(!igNavMoveRequestForward);
		*(cast(void**)&igNavMoveRequestResolveWithLastItem) = GetProcAddress(handle, "igNavMoveRequestResolveWithLastItem"); throwIf(!igNavMoveRequestResolveWithLastItem);
		*(cast(void**)&igNavMoveRequestResolveWithPastTreeNode) = GetProcAddress(handle, "igNavMoveRequestResolveWithPastTreeNode"); throwIf(!igNavMoveRequestResolveWithPastTreeNode);
		*(cast(void**)&igNavMoveRequestSubmit) = GetProcAddress(handle, "igNavMoveRequestSubmit"); throwIf(!igNavMoveRequestSubmit);
		*(cast(void**)&igNavMoveRequestTryWrapping) = GetProcAddress(handle, "igNavMoveRequestTryWrapping"); throwIf(!igNavMoveRequestTryWrapping);
		*(cast(void**)&igNavRestoreHighlightAfterMove) = GetProcAddress(handle, "igNavRestoreHighlightAfterMove"); throwIf(!igNavRestoreHighlightAfterMove);
		*(cast(void**)&igNavUpdateCurrentWindowIsScrollPushableX) = GetProcAddress(handle, "igNavUpdateCurrentWindowIsScrollPushableX"); throwIf(!igNavUpdateCurrentWindowIsScrollPushableX);
		*(cast(void**)&igNewFrame) = GetProcAddress(handle, "igNewFrame"); throwIf(!igNewFrame);
		*(cast(void**)&igNewLine) = GetProcAddress(handle, "igNewLine"); throwIf(!igNewLine);
		*(cast(void**)&igNextColumn) = GetProcAddress(handle, "igNextColumn"); throwIf(!igNextColumn);
		*(cast(void**)&igOpenPopupEx) = GetProcAddress(handle, "igOpenPopupEx"); throwIf(!igOpenPopupEx);
		*(cast(void**)&igOpenPopupOnItemClick) = GetProcAddress(handle, "igOpenPopupOnItemClick"); throwIf(!igOpenPopupOnItemClick);
		*(cast(void**)&igOpenPopup_ID) = GetProcAddress(handle, "igOpenPopup_ID"); throwIf(!igOpenPopup_ID);
		*(cast(void**)&igOpenPopup_Str) = GetProcAddress(handle, "igOpenPopup_Str"); throwIf(!igOpenPopup_Str);
		*(cast(void**)&igPlotEx) = GetProcAddress(handle, "igPlotEx"); throwIf(!igPlotEx);
		*(cast(void**)&igPlotHistogram_FloatPtr) = GetProcAddress(handle, "igPlotHistogram_FloatPtr"); throwIf(!igPlotHistogram_FloatPtr);
		*(cast(void**)&igPlotHistogram_FnFloatPtr) = GetProcAddress(handle, "igPlotHistogram_FnFloatPtr"); throwIf(!igPlotHistogram_FnFloatPtr);
		*(cast(void**)&igPlotLines_FloatPtr) = GetProcAddress(handle, "igPlotLines_FloatPtr"); throwIf(!igPlotLines_FloatPtr);
		*(cast(void**)&igPlotLines_FnFloatPtr) = GetProcAddress(handle, "igPlotLines_FnFloatPtr"); throwIf(!igPlotLines_FnFloatPtr);
		*(cast(void**)&igPopClipRect) = GetProcAddress(handle, "igPopClipRect"); throwIf(!igPopClipRect);
		*(cast(void**)&igPopColumnsBackground) = GetProcAddress(handle, "igPopColumnsBackground"); throwIf(!igPopColumnsBackground);
		*(cast(void**)&igPopFocusScope) = GetProcAddress(handle, "igPopFocusScope"); throwIf(!igPopFocusScope);
		*(cast(void**)&igPopFont) = GetProcAddress(handle, "igPopFont"); throwIf(!igPopFont);
		*(cast(void**)&igPopID) = GetProcAddress(handle, "igPopID"); throwIf(!igPopID);
		*(cast(void**)&igPopItemFlag) = GetProcAddress(handle, "igPopItemFlag"); throwIf(!igPopItemFlag);
		*(cast(void**)&igPopItemWidth) = GetProcAddress(handle, "igPopItemWidth"); throwIf(!igPopItemWidth);
		*(cast(void**)&igPopStyleColor) = GetProcAddress(handle, "igPopStyleColor"); throwIf(!igPopStyleColor);
		*(cast(void**)&igPopStyleVar) = GetProcAddress(handle, "igPopStyleVar"); throwIf(!igPopStyleVar);
		*(cast(void**)&igPopTextWrapPos) = GetProcAddress(handle, "igPopTextWrapPos"); throwIf(!igPopTextWrapPos);
		*(cast(void**)&igProgressBar) = GetProcAddress(handle, "igProgressBar"); throwIf(!igProgressBar);
		*(cast(void**)&igPushClipRect) = GetProcAddress(handle, "igPushClipRect"); throwIf(!igPushClipRect);
		*(cast(void**)&igPushColumnClipRect) = GetProcAddress(handle, "igPushColumnClipRect"); throwIf(!igPushColumnClipRect);
		*(cast(void**)&igPushColumnsBackground) = GetProcAddress(handle, "igPushColumnsBackground"); throwIf(!igPushColumnsBackground);
		*(cast(void**)&igPushFocusScope) = GetProcAddress(handle, "igPushFocusScope"); throwIf(!igPushFocusScope);
		*(cast(void**)&igPushFont) = GetProcAddress(handle, "igPushFont"); throwIf(!igPushFont);
		*(cast(void**)&igPushID_Int) = GetProcAddress(handle, "igPushID_Int"); throwIf(!igPushID_Int);
		*(cast(void**)&igPushID_Ptr) = GetProcAddress(handle, "igPushID_Ptr"); throwIf(!igPushID_Ptr);
		*(cast(void**)&igPushID_Str) = GetProcAddress(handle, "igPushID_Str"); throwIf(!igPushID_Str);
		*(cast(void**)&igPushID_StrStr) = GetProcAddress(handle, "igPushID_StrStr"); throwIf(!igPushID_StrStr);
		*(cast(void**)&igPushItemFlag) = GetProcAddress(handle, "igPushItemFlag"); throwIf(!igPushItemFlag);
		*(cast(void**)&igPushItemWidth) = GetProcAddress(handle, "igPushItemWidth"); throwIf(!igPushItemWidth);
		*(cast(void**)&igPushMultiItemsWidths) = GetProcAddress(handle, "igPushMultiItemsWidths"); throwIf(!igPushMultiItemsWidths);
		*(cast(void**)&igPushOverrideID) = GetProcAddress(handle, "igPushOverrideID"); throwIf(!igPushOverrideID);
		*(cast(void**)&igPushStyleColor_U32) = GetProcAddress(handle, "igPushStyleColor_U32"); throwIf(!igPushStyleColor_U32);
		*(cast(void**)&igPushStyleColor_Vec4) = GetProcAddress(handle, "igPushStyleColor_Vec4"); throwIf(!igPushStyleColor_Vec4);
		*(cast(void**)&igPushStyleVar_Float) = GetProcAddress(handle, "igPushStyleVar_Float"); throwIf(!igPushStyleVar_Float);
		*(cast(void**)&igPushStyleVar_Vec2) = GetProcAddress(handle, "igPushStyleVar_Vec2"); throwIf(!igPushStyleVar_Vec2);
		*(cast(void**)&igPushTextWrapPos) = GetProcAddress(handle, "igPushTextWrapPos"); throwIf(!igPushTextWrapPos);
		*(cast(void**)&igRadioButton_Bool) = GetProcAddress(handle, "igRadioButton_Bool"); throwIf(!igRadioButton_Bool);
		*(cast(void**)&igRadioButton_IntPtr) = GetProcAddress(handle, "igRadioButton_IntPtr"); throwIf(!igRadioButton_IntPtr);
		*(cast(void**)&igRemoveContextHook) = GetProcAddress(handle, "igRemoveContextHook"); throwIf(!igRemoveContextHook);
		*(cast(void**)&igRemoveSettingsHandler) = GetProcAddress(handle, "igRemoveSettingsHandler"); throwIf(!igRemoveSettingsHandler);
		*(cast(void**)&igRender) = GetProcAddress(handle, "igRender"); throwIf(!igRender);
		*(cast(void**)&igRenderArrow) = GetProcAddress(handle, "igRenderArrow"); throwIf(!igRenderArrow);
		*(cast(void**)&igRenderArrowDockMenu) = GetProcAddress(handle, "igRenderArrowDockMenu"); throwIf(!igRenderArrowDockMenu);
		*(cast(void**)&igRenderArrowPointingAt) = GetProcAddress(handle, "igRenderArrowPointingAt"); throwIf(!igRenderArrowPointingAt);
		*(cast(void**)&igRenderBullet) = GetProcAddress(handle, "igRenderBullet"); throwIf(!igRenderBullet);
		*(cast(void**)&igRenderCheckMark) = GetProcAddress(handle, "igRenderCheckMark"); throwIf(!igRenderCheckMark);
		*(cast(void**)&igRenderColorRectWithAlphaCheckerboard) = GetProcAddress(handle, "igRenderColorRectWithAlphaCheckerboard"); throwIf(!igRenderColorRectWithAlphaCheckerboard);
		*(cast(void**)&igRenderDragDropTargetRect) = GetProcAddress(handle, "igRenderDragDropTargetRect"); throwIf(!igRenderDragDropTargetRect);
		*(cast(void**)&igRenderFrame) = GetProcAddress(handle, "igRenderFrame"); throwIf(!igRenderFrame);
		*(cast(void**)&igRenderFrameBorder) = GetProcAddress(handle, "igRenderFrameBorder"); throwIf(!igRenderFrameBorder);
		*(cast(void**)&igRenderMouseCursor) = GetProcAddress(handle, "igRenderMouseCursor"); throwIf(!igRenderMouseCursor);
		*(cast(void**)&igRenderNavHighlight) = GetProcAddress(handle, "igRenderNavHighlight"); throwIf(!igRenderNavHighlight);
		*(cast(void**)&igRenderPlatformWindowsDefault) = GetProcAddress(handle, "igRenderPlatformWindowsDefault"); throwIf(!igRenderPlatformWindowsDefault);
		*(cast(void**)&igRenderRectFilledRangeH) = GetProcAddress(handle, "igRenderRectFilledRangeH"); throwIf(!igRenderRectFilledRangeH);
		*(cast(void**)&igRenderRectFilledWithHole) = GetProcAddress(handle, "igRenderRectFilledWithHole"); throwIf(!igRenderRectFilledWithHole);
		*(cast(void**)&igRenderText) = GetProcAddress(handle, "igRenderText"); throwIf(!igRenderText);
		*(cast(void**)&igRenderTextClipped) = GetProcAddress(handle, "igRenderTextClipped"); throwIf(!igRenderTextClipped);
		*(cast(void**)&igRenderTextClippedEx) = GetProcAddress(handle, "igRenderTextClippedEx"); throwIf(!igRenderTextClippedEx);
		*(cast(void**)&igRenderTextEllipsis) = GetProcAddress(handle, "igRenderTextEllipsis"); throwIf(!igRenderTextEllipsis);
		*(cast(void**)&igRenderTextWrapped) = GetProcAddress(handle, "igRenderTextWrapped"); throwIf(!igRenderTextWrapped);
		*(cast(void**)&igResetMouseDragDelta) = GetProcAddress(handle, "igResetMouseDragDelta"); throwIf(!igResetMouseDragDelta);
		*(cast(void**)&igSameLine) = GetProcAddress(handle, "igSameLine"); throwIf(!igSameLine);
		*(cast(void**)&igSaveIniSettingsToDisk) = GetProcAddress(handle, "igSaveIniSettingsToDisk"); throwIf(!igSaveIniSettingsToDisk);
		*(cast(void**)&igSaveIniSettingsToMemory) = GetProcAddress(handle, "igSaveIniSettingsToMemory"); throwIf(!igSaveIniSettingsToMemory);
		*(cast(void**)&igScaleWindowsInViewport) = GetProcAddress(handle, "igScaleWindowsInViewport"); throwIf(!igScaleWindowsInViewport);
		*(cast(void**)&igScrollToBringRectIntoView) = GetProcAddress(handle, "igScrollToBringRectIntoView"); throwIf(!igScrollToBringRectIntoView);
		*(cast(void**)&igScrollToItem) = GetProcAddress(handle, "igScrollToItem"); throwIf(!igScrollToItem);
		*(cast(void**)&igScrollToRect) = GetProcAddress(handle, "igScrollToRect"); throwIf(!igScrollToRect);
		*(cast(void**)&igScrollToRectEx) = GetProcAddress(handle, "igScrollToRectEx"); throwIf(!igScrollToRectEx);
		*(cast(void**)&igScrollbar) = GetProcAddress(handle, "igScrollbar"); throwIf(!igScrollbar);
		*(cast(void**)&igScrollbarEx) = GetProcAddress(handle, "igScrollbarEx"); throwIf(!igScrollbarEx);
		*(cast(void**)&igSelectable_Bool) = GetProcAddress(handle, "igSelectable_Bool"); throwIf(!igSelectable_Bool);
		*(cast(void**)&igSelectable_BoolPtr) = GetProcAddress(handle, "igSelectable_BoolPtr"); throwIf(!igSelectable_BoolPtr);
		*(cast(void**)&igSeparator) = GetProcAddress(handle, "igSeparator"); throwIf(!igSeparator);
		*(cast(void**)&igSeparatorEx) = GetProcAddress(handle, "igSeparatorEx"); throwIf(!igSeparatorEx);
		*(cast(void**)&igSeparatorText) = GetProcAddress(handle, "igSeparatorText"); throwIf(!igSeparatorText);
		*(cast(void**)&igSeparatorTextEx) = GetProcAddress(handle, "igSeparatorTextEx"); throwIf(!igSeparatorTextEx);
		*(cast(void**)&igSetActiveID) = GetProcAddress(handle, "igSetActiveID"); throwIf(!igSetActiveID);
		*(cast(void**)&igSetActiveIdUsingAllKeyboardKeys) = GetProcAddress(handle, "igSetActiveIdUsingAllKeyboardKeys"); throwIf(!igSetActiveIdUsingAllKeyboardKeys);
		*(cast(void**)&igSetAllocatorFunctions) = GetProcAddress(handle, "igSetAllocatorFunctions"); throwIf(!igSetAllocatorFunctions);
		*(cast(void**)&igSetClipboardText) = GetProcAddress(handle, "igSetClipboardText"); throwIf(!igSetClipboardText);
		*(cast(void**)&igSetColorEditOptions) = GetProcAddress(handle, "igSetColorEditOptions"); throwIf(!igSetColorEditOptions);
		*(cast(void**)&igSetColumnOffset) = GetProcAddress(handle, "igSetColumnOffset"); throwIf(!igSetColumnOffset);
		*(cast(void**)&igSetColumnWidth) = GetProcAddress(handle, "igSetColumnWidth"); throwIf(!igSetColumnWidth);
		*(cast(void**)&igSetCurrentContext) = GetProcAddress(handle, "igSetCurrentContext"); throwIf(!igSetCurrentContext);
		*(cast(void**)&igSetCurrentFont) = GetProcAddress(handle, "igSetCurrentFont"); throwIf(!igSetCurrentFont);
		*(cast(void**)&igSetCurrentViewport) = GetProcAddress(handle, "igSetCurrentViewport"); throwIf(!igSetCurrentViewport);
		*(cast(void**)&igSetCursorPos) = GetProcAddress(handle, "igSetCursorPos"); throwIf(!igSetCursorPos);
		*(cast(void**)&igSetCursorPosX) = GetProcAddress(handle, "igSetCursorPosX"); throwIf(!igSetCursorPosX);
		*(cast(void**)&igSetCursorPosY) = GetProcAddress(handle, "igSetCursorPosY"); throwIf(!igSetCursorPosY);
		*(cast(void**)&igSetCursorScreenPos) = GetProcAddress(handle, "igSetCursorScreenPos"); throwIf(!igSetCursorScreenPos);
		*(cast(void**)&igSetDragDropPayload) = GetProcAddress(handle, "igSetDragDropPayload"); throwIf(!igSetDragDropPayload);
		*(cast(void**)&igSetFocusID) = GetProcAddress(handle, "igSetFocusID"); throwIf(!igSetFocusID);
		*(cast(void**)&igSetHoveredID) = GetProcAddress(handle, "igSetHoveredID"); throwIf(!igSetHoveredID);
		*(cast(void**)&igSetItemDefaultFocus) = GetProcAddress(handle, "igSetItemDefaultFocus"); throwIf(!igSetItemDefaultFocus);
		*(cast(void**)&igSetItemKeyOwner_InputFlags) = GetProcAddress(handle, "igSetItemKeyOwner_InputFlags"); throwIf(!igSetItemKeyOwner_InputFlags);
		*(cast(void**)&igSetItemKeyOwner_Nil) = GetProcAddress(handle, "igSetItemKeyOwner_Nil"); throwIf(!igSetItemKeyOwner_Nil);
		*(cast(void**)&igSetItemTooltip) = GetProcAddress(handle, "igSetItemTooltip"); throwIf(!igSetItemTooltip);
		*(cast(void**)&igSetItemTooltipV) = GetProcAddress(handle, "igSetItemTooltipV"); throwIf(!igSetItemTooltipV);
		*(cast(void**)&igSetKeyOwner) = GetProcAddress(handle, "igSetKeyOwner"); throwIf(!igSetKeyOwner);
		*(cast(void**)&igSetKeyOwnersForKeyChord) = GetProcAddress(handle, "igSetKeyOwnersForKeyChord"); throwIf(!igSetKeyOwnersForKeyChord);
		*(cast(void**)&igSetKeyboardFocusHere) = GetProcAddress(handle, "igSetKeyboardFocusHere"); throwIf(!igSetKeyboardFocusHere);
		*(cast(void**)&igSetLastItemData) = GetProcAddress(handle, "igSetLastItemData"); throwIf(!igSetLastItemData);
		*(cast(void**)&igSetMouseCursor) = GetProcAddress(handle, "igSetMouseCursor"); throwIf(!igSetMouseCursor);
		*(cast(void**)&igSetNavFocusScope) = GetProcAddress(handle, "igSetNavFocusScope"); throwIf(!igSetNavFocusScope);
		*(cast(void**)&igSetNavID) = GetProcAddress(handle, "igSetNavID"); throwIf(!igSetNavID);
		*(cast(void**)&igSetNavWindow) = GetProcAddress(handle, "igSetNavWindow"); throwIf(!igSetNavWindow);
		*(cast(void**)&igSetNextFrameWantCaptureKeyboard) = GetProcAddress(handle, "igSetNextFrameWantCaptureKeyboard"); throwIf(!igSetNextFrameWantCaptureKeyboard);
		*(cast(void**)&igSetNextFrameWantCaptureMouse) = GetProcAddress(handle, "igSetNextFrameWantCaptureMouse"); throwIf(!igSetNextFrameWantCaptureMouse);
		*(cast(void**)&igSetNextItemAllowOverlap) = GetProcAddress(handle, "igSetNextItemAllowOverlap"); throwIf(!igSetNextItemAllowOverlap);
		*(cast(void**)&igSetNextItemOpen) = GetProcAddress(handle, "igSetNextItemOpen"); throwIf(!igSetNextItemOpen);
		*(cast(void**)&igSetNextItemRefVal) = GetProcAddress(handle, "igSetNextItemRefVal"); throwIf(!igSetNextItemRefVal);
		*(cast(void**)&igSetNextItemSelectionUserData) = GetProcAddress(handle, "igSetNextItemSelectionUserData"); throwIf(!igSetNextItemSelectionUserData);
		*(cast(void**)&igSetNextItemShortcut) = GetProcAddress(handle, "igSetNextItemShortcut"); throwIf(!igSetNextItemShortcut);
		*(cast(void**)&igSetNextItemStorageID) = GetProcAddress(handle, "igSetNextItemStorageID"); throwIf(!igSetNextItemStorageID);
		*(cast(void**)&igSetNextItemWidth) = GetProcAddress(handle, "igSetNextItemWidth"); throwIf(!igSetNextItemWidth);
		*(cast(void**)&igSetNextWindowBgAlpha) = GetProcAddress(handle, "igSetNextWindowBgAlpha"); throwIf(!igSetNextWindowBgAlpha);
		*(cast(void**)&igSetNextWindowClass) = GetProcAddress(handle, "igSetNextWindowClass"); throwIf(!igSetNextWindowClass);
		*(cast(void**)&igSetNextWindowCollapsed) = GetProcAddress(handle, "igSetNextWindowCollapsed"); throwIf(!igSetNextWindowCollapsed);
		*(cast(void**)&igSetNextWindowContentSize) = GetProcAddress(handle, "igSetNextWindowContentSize"); throwIf(!igSetNextWindowContentSize);
		*(cast(void**)&igSetNextWindowDockID) = GetProcAddress(handle, "igSetNextWindowDockID"); throwIf(!igSetNextWindowDockID);
		*(cast(void**)&igSetNextWindowFocus) = GetProcAddress(handle, "igSetNextWindowFocus"); throwIf(!igSetNextWindowFocus);
		*(cast(void**)&igSetNextWindowPos) = GetProcAddress(handle, "igSetNextWindowPos"); throwIf(!igSetNextWindowPos);
		*(cast(void**)&igSetNextWindowRefreshPolicy) = GetProcAddress(handle, "igSetNextWindowRefreshPolicy"); throwIf(!igSetNextWindowRefreshPolicy);
		*(cast(void**)&igSetNextWindowScroll) = GetProcAddress(handle, "igSetNextWindowScroll"); throwIf(!igSetNextWindowScroll);
		*(cast(void**)&igSetNextWindowSize) = GetProcAddress(handle, "igSetNextWindowSize"); throwIf(!igSetNextWindowSize);
		*(cast(void**)&igSetNextWindowSizeConstraints) = GetProcAddress(handle, "igSetNextWindowSizeConstraints"); throwIf(!igSetNextWindowSizeConstraints);
		*(cast(void**)&igSetNextWindowViewport) = GetProcAddress(handle, "igSetNextWindowViewport"); throwIf(!igSetNextWindowViewport);
		*(cast(void**)&igSetScrollFromPosX_Float) = GetProcAddress(handle, "igSetScrollFromPosX_Float"); throwIf(!igSetScrollFromPosX_Float);
		*(cast(void**)&igSetScrollFromPosX_WindowPtr) = GetProcAddress(handle, "igSetScrollFromPosX_WindowPtr"); throwIf(!igSetScrollFromPosX_WindowPtr);
		*(cast(void**)&igSetScrollFromPosY_Float) = GetProcAddress(handle, "igSetScrollFromPosY_Float"); throwIf(!igSetScrollFromPosY_Float);
		*(cast(void**)&igSetScrollFromPosY_WindowPtr) = GetProcAddress(handle, "igSetScrollFromPosY_WindowPtr"); throwIf(!igSetScrollFromPosY_WindowPtr);
		*(cast(void**)&igSetScrollHereX) = GetProcAddress(handle, "igSetScrollHereX"); throwIf(!igSetScrollHereX);
		*(cast(void**)&igSetScrollHereY) = GetProcAddress(handle, "igSetScrollHereY"); throwIf(!igSetScrollHereY);
		*(cast(void**)&igSetScrollX_Float) = GetProcAddress(handle, "igSetScrollX_Float"); throwIf(!igSetScrollX_Float);
		*(cast(void**)&igSetScrollX_WindowPtr) = GetProcAddress(handle, "igSetScrollX_WindowPtr"); throwIf(!igSetScrollX_WindowPtr);
		*(cast(void**)&igSetScrollY_Float) = GetProcAddress(handle, "igSetScrollY_Float"); throwIf(!igSetScrollY_Float);
		*(cast(void**)&igSetScrollY_WindowPtr) = GetProcAddress(handle, "igSetScrollY_WindowPtr"); throwIf(!igSetScrollY_WindowPtr);
		*(cast(void**)&igSetShortcutRouting) = GetProcAddress(handle, "igSetShortcutRouting"); throwIf(!igSetShortcutRouting);
		*(cast(void**)&igSetStateStorage) = GetProcAddress(handle, "igSetStateStorage"); throwIf(!igSetStateStorage);
		*(cast(void**)&igSetTabItemClosed) = GetProcAddress(handle, "igSetTabItemClosed"); throwIf(!igSetTabItemClosed);
		*(cast(void**)&igSetTooltip) = GetProcAddress(handle, "igSetTooltip"); throwIf(!igSetTooltip);
		*(cast(void**)&igSetTooltipV) = GetProcAddress(handle, "igSetTooltipV"); throwIf(!igSetTooltipV);
		*(cast(void**)&igSetWindowClipRectBeforeSetChannel) = GetProcAddress(handle, "igSetWindowClipRectBeforeSetChannel"); throwIf(!igSetWindowClipRectBeforeSetChannel);
		*(cast(void**)&igSetWindowCollapsed_Bool) = GetProcAddress(handle, "igSetWindowCollapsed_Bool"); throwIf(!igSetWindowCollapsed_Bool);
		*(cast(void**)&igSetWindowCollapsed_Str) = GetProcAddress(handle, "igSetWindowCollapsed_Str"); throwIf(!igSetWindowCollapsed_Str);
		*(cast(void**)&igSetWindowCollapsed_WindowPtr) = GetProcAddress(handle, "igSetWindowCollapsed_WindowPtr"); throwIf(!igSetWindowCollapsed_WindowPtr);
		*(cast(void**)&igSetWindowDock) = GetProcAddress(handle, "igSetWindowDock"); throwIf(!igSetWindowDock);
		*(cast(void**)&igSetWindowFocus_Nil) = GetProcAddress(handle, "igSetWindowFocus_Nil"); throwIf(!igSetWindowFocus_Nil);
		*(cast(void**)&igSetWindowFocus_Str) = GetProcAddress(handle, "igSetWindowFocus_Str"); throwIf(!igSetWindowFocus_Str);
		*(cast(void**)&igSetWindowFontScale) = GetProcAddress(handle, "igSetWindowFontScale"); throwIf(!igSetWindowFontScale);
		*(cast(void**)&igSetWindowHiddenAndSkipItemsForCurrentFrame) = GetProcAddress(handle, "igSetWindowHiddenAndSkipItemsForCurrentFrame"); throwIf(!igSetWindowHiddenAndSkipItemsForCurrentFrame);
		*(cast(void**)&igSetWindowHitTestHole) = GetProcAddress(handle, "igSetWindowHitTestHole"); throwIf(!igSetWindowHitTestHole);
		*(cast(void**)&igSetWindowParentWindowForFocusRoute) = GetProcAddress(handle, "igSetWindowParentWindowForFocusRoute"); throwIf(!igSetWindowParentWindowForFocusRoute);
		*(cast(void**)&igSetWindowPos_Str) = GetProcAddress(handle, "igSetWindowPos_Str"); throwIf(!igSetWindowPos_Str);
		*(cast(void**)&igSetWindowPos_Vec2) = GetProcAddress(handle, "igSetWindowPos_Vec2"); throwIf(!igSetWindowPos_Vec2);
		*(cast(void**)&igSetWindowPos_WindowPtr) = GetProcAddress(handle, "igSetWindowPos_WindowPtr"); throwIf(!igSetWindowPos_WindowPtr);
		*(cast(void**)&igSetWindowSize_Str) = GetProcAddress(handle, "igSetWindowSize_Str"); throwIf(!igSetWindowSize_Str);
		*(cast(void**)&igSetWindowSize_Vec2) = GetProcAddress(handle, "igSetWindowSize_Vec2"); throwIf(!igSetWindowSize_Vec2);
		*(cast(void**)&igSetWindowSize_WindowPtr) = GetProcAddress(handle, "igSetWindowSize_WindowPtr"); throwIf(!igSetWindowSize_WindowPtr);
		*(cast(void**)&igSetWindowViewport) = GetProcAddress(handle, "igSetWindowViewport"); throwIf(!igSetWindowViewport);
		*(cast(void**)&igShadeVertsLinearColorGradientKeepAlpha) = GetProcAddress(handle, "igShadeVertsLinearColorGradientKeepAlpha"); throwIf(!igShadeVertsLinearColorGradientKeepAlpha);
		*(cast(void**)&igShadeVertsLinearUV) = GetProcAddress(handle, "igShadeVertsLinearUV"); throwIf(!igShadeVertsLinearUV);
		*(cast(void**)&igShadeVertsTransformPos) = GetProcAddress(handle, "igShadeVertsTransformPos"); throwIf(!igShadeVertsTransformPos);
		*(cast(void**)&igShortcut_ID) = GetProcAddress(handle, "igShortcut_ID"); throwIf(!igShortcut_ID);
		*(cast(void**)&igShortcut_Nil) = GetProcAddress(handle, "igShortcut_Nil"); throwIf(!igShortcut_Nil);
		*(cast(void**)&igShowAboutWindow) = GetProcAddress(handle, "igShowAboutWindow"); throwIf(!igShowAboutWindow);
		*(cast(void**)&igShowDebugLogWindow) = GetProcAddress(handle, "igShowDebugLogWindow"); throwIf(!igShowDebugLogWindow);
		*(cast(void**)&igShowDemoWindow) = GetProcAddress(handle, "igShowDemoWindow"); throwIf(!igShowDemoWindow);
		*(cast(void**)&igShowFontAtlas) = GetProcAddress(handle, "igShowFontAtlas"); throwIf(!igShowFontAtlas);
		*(cast(void**)&igShowFontSelector) = GetProcAddress(handle, "igShowFontSelector"); throwIf(!igShowFontSelector);
		*(cast(void**)&igShowIDStackToolWindow) = GetProcAddress(handle, "igShowIDStackToolWindow"); throwIf(!igShowIDStackToolWindow);
		*(cast(void**)&igShowMetricsWindow) = GetProcAddress(handle, "igShowMetricsWindow"); throwIf(!igShowMetricsWindow);
		*(cast(void**)&igShowStyleEditor) = GetProcAddress(handle, "igShowStyleEditor"); throwIf(!igShowStyleEditor);
		*(cast(void**)&igShowStyleSelector) = GetProcAddress(handle, "igShowStyleSelector"); throwIf(!igShowStyleSelector);
		*(cast(void**)&igShowUserGuide) = GetProcAddress(handle, "igShowUserGuide"); throwIf(!igShowUserGuide);
		*(cast(void**)&igShrinkWidths) = GetProcAddress(handle, "igShrinkWidths"); throwIf(!igShrinkWidths);
		*(cast(void**)&igShutdown) = GetProcAddress(handle, "igShutdown"); throwIf(!igShutdown);
		*(cast(void**)&igSliderAngle) = GetProcAddress(handle, "igSliderAngle"); throwIf(!igSliderAngle);
		*(cast(void**)&igSliderBehavior) = GetProcAddress(handle, "igSliderBehavior"); throwIf(!igSliderBehavior);
		*(cast(void**)&igSliderFloat) = GetProcAddress(handle, "igSliderFloat"); throwIf(!igSliderFloat);
		*(cast(void**)&igSliderFloat2) = GetProcAddress(handle, "igSliderFloat2"); throwIf(!igSliderFloat2);
		*(cast(void**)&igSliderFloat3) = GetProcAddress(handle, "igSliderFloat3"); throwIf(!igSliderFloat3);
		*(cast(void**)&igSliderFloat4) = GetProcAddress(handle, "igSliderFloat4"); throwIf(!igSliderFloat4);
		*(cast(void**)&igSliderInt) = GetProcAddress(handle, "igSliderInt"); throwIf(!igSliderInt);
		*(cast(void**)&igSliderInt2) = GetProcAddress(handle, "igSliderInt2"); throwIf(!igSliderInt2);
		*(cast(void**)&igSliderInt3) = GetProcAddress(handle, "igSliderInt3"); throwIf(!igSliderInt3);
		*(cast(void**)&igSliderInt4) = GetProcAddress(handle, "igSliderInt4"); throwIf(!igSliderInt4);
		*(cast(void**)&igSliderScalar) = GetProcAddress(handle, "igSliderScalar"); throwIf(!igSliderScalar);
		*(cast(void**)&igSliderScalarN) = GetProcAddress(handle, "igSliderScalarN"); throwIf(!igSliderScalarN);
		*(cast(void**)&igSmallButton) = GetProcAddress(handle, "igSmallButton"); throwIf(!igSmallButton);
		*(cast(void**)&igSpacing) = GetProcAddress(handle, "igSpacing"); throwIf(!igSpacing);
		*(cast(void**)&igSplitterBehavior) = GetProcAddress(handle, "igSplitterBehavior"); throwIf(!igSplitterBehavior);
		*(cast(void**)&igStartMouseMovingWindow) = GetProcAddress(handle, "igStartMouseMovingWindow"); throwIf(!igStartMouseMovingWindow);
		*(cast(void**)&igStartMouseMovingWindowOrNode) = GetProcAddress(handle, "igStartMouseMovingWindowOrNode"); throwIf(!igStartMouseMovingWindowOrNode);
		*(cast(void**)&igStyleColorsClassic) = GetProcAddress(handle, "igStyleColorsClassic"); throwIf(!igStyleColorsClassic);
		*(cast(void**)&igStyleColorsDark) = GetProcAddress(handle, "igStyleColorsDark"); throwIf(!igStyleColorsDark);
		*(cast(void**)&igStyleColorsLight) = GetProcAddress(handle, "igStyleColorsLight"); throwIf(!igStyleColorsLight);
		*(cast(void**)&igTabBarAddTab) = GetProcAddress(handle, "igTabBarAddTab"); throwIf(!igTabBarAddTab);
		*(cast(void**)&igTabBarCloseTab) = GetProcAddress(handle, "igTabBarCloseTab"); throwIf(!igTabBarCloseTab);
		*(cast(void**)&igTabBarFindMostRecentlySelectedTabForActiveWindow) = GetProcAddress(handle, "igTabBarFindMostRecentlySelectedTabForActiveWindow"); throwIf(!igTabBarFindMostRecentlySelectedTabForActiveWindow);
		*(cast(void**)&igTabBarFindTabByID) = GetProcAddress(handle, "igTabBarFindTabByID"); throwIf(!igTabBarFindTabByID);
		*(cast(void**)&igTabBarFindTabByOrder) = GetProcAddress(handle, "igTabBarFindTabByOrder"); throwIf(!igTabBarFindTabByOrder);
		*(cast(void**)&igTabBarGetCurrentTab) = GetProcAddress(handle, "igTabBarGetCurrentTab"); throwIf(!igTabBarGetCurrentTab);
		*(cast(void**)&igTabBarGetTabName) = GetProcAddress(handle, "igTabBarGetTabName"); throwIf(!igTabBarGetTabName);
		*(cast(void**)&igTabBarGetTabOrder) = GetProcAddress(handle, "igTabBarGetTabOrder"); throwIf(!igTabBarGetTabOrder);
		*(cast(void**)&igTabBarProcessReorder) = GetProcAddress(handle, "igTabBarProcessReorder"); throwIf(!igTabBarProcessReorder);
		*(cast(void**)&igTabBarQueueFocus) = GetProcAddress(handle, "igTabBarQueueFocus"); throwIf(!igTabBarQueueFocus);
		*(cast(void**)&igTabBarQueueReorder) = GetProcAddress(handle, "igTabBarQueueReorder"); throwIf(!igTabBarQueueReorder);
		*(cast(void**)&igTabBarQueueReorderFromMousePos) = GetProcAddress(handle, "igTabBarQueueReorderFromMousePos"); throwIf(!igTabBarQueueReorderFromMousePos);
		*(cast(void**)&igTabBarRemoveTab) = GetProcAddress(handle, "igTabBarRemoveTab"); throwIf(!igTabBarRemoveTab);
		*(cast(void**)&igTabItemBackground) = GetProcAddress(handle, "igTabItemBackground"); throwIf(!igTabItemBackground);
		*(cast(void**)&igTabItemButton) = GetProcAddress(handle, "igTabItemButton"); throwIf(!igTabItemButton);
		*(cast(void**)&igTabItemCalcSize_Str) = GetProcAddress(handle, "igTabItemCalcSize_Str"); throwIf(!igTabItemCalcSize_Str);
		*(cast(void**)&igTabItemCalcSize_WindowPtr) = GetProcAddress(handle, "igTabItemCalcSize_WindowPtr"); throwIf(!igTabItemCalcSize_WindowPtr);
		*(cast(void**)&igTabItemEx) = GetProcAddress(handle, "igTabItemEx"); throwIf(!igTabItemEx);
		*(cast(void**)&igTabItemLabelAndCloseButton) = GetProcAddress(handle, "igTabItemLabelAndCloseButton"); throwIf(!igTabItemLabelAndCloseButton);
		*(cast(void**)&igTableAngledHeadersRow) = GetProcAddress(handle, "igTableAngledHeadersRow"); throwIf(!igTableAngledHeadersRow);
		*(cast(void**)&igTableAngledHeadersRowEx) = GetProcAddress(handle, "igTableAngledHeadersRowEx"); throwIf(!igTableAngledHeadersRowEx);
		*(cast(void**)&igTableBeginApplyRequests) = GetProcAddress(handle, "igTableBeginApplyRequests"); throwIf(!igTableBeginApplyRequests);
		*(cast(void**)&igTableBeginCell) = GetProcAddress(handle, "igTableBeginCell"); throwIf(!igTableBeginCell);
		*(cast(void**)&igTableBeginContextMenuPopup) = GetProcAddress(handle, "igTableBeginContextMenuPopup"); throwIf(!igTableBeginContextMenuPopup);
		*(cast(void**)&igTableBeginInitMemory) = GetProcAddress(handle, "igTableBeginInitMemory"); throwIf(!igTableBeginInitMemory);
		*(cast(void**)&igTableBeginRow) = GetProcAddress(handle, "igTableBeginRow"); throwIf(!igTableBeginRow);
		*(cast(void**)&igTableDrawBorders) = GetProcAddress(handle, "igTableDrawBorders"); throwIf(!igTableDrawBorders);
		*(cast(void**)&igTableDrawDefaultContextMenu) = GetProcAddress(handle, "igTableDrawDefaultContextMenu"); throwIf(!igTableDrawDefaultContextMenu);
		*(cast(void**)&igTableEndCell) = GetProcAddress(handle, "igTableEndCell"); throwIf(!igTableEndCell);
		*(cast(void**)&igTableEndRow) = GetProcAddress(handle, "igTableEndRow"); throwIf(!igTableEndRow);
		*(cast(void**)&igTableFindByID) = GetProcAddress(handle, "igTableFindByID"); throwIf(!igTableFindByID);
		*(cast(void**)&igTableFixColumnSortDirection) = GetProcAddress(handle, "igTableFixColumnSortDirection"); throwIf(!igTableFixColumnSortDirection);
		*(cast(void**)&igTableGcCompactSettings) = GetProcAddress(handle, "igTableGcCompactSettings"); throwIf(!igTableGcCompactSettings);
		*(cast(void**)&igTableGcCompactTransientBuffers_TablePtr) = GetProcAddress(handle, "igTableGcCompactTransientBuffers_TablePtr"); throwIf(!igTableGcCompactTransientBuffers_TablePtr);
		*(cast(void**)&igTableGcCompactTransientBuffers_TableTempDataPtr) = GetProcAddress(handle, "igTableGcCompactTransientBuffers_TableTempDataPtr"); throwIf(!igTableGcCompactTransientBuffers_TableTempDataPtr);
		*(cast(void**)&igTableGetBoundSettings) = GetProcAddress(handle, "igTableGetBoundSettings"); throwIf(!igTableGetBoundSettings);
		*(cast(void**)&igTableGetCellBgRect) = GetProcAddress(handle, "igTableGetCellBgRect"); throwIf(!igTableGetCellBgRect);
		*(cast(void**)&igTableGetColumnCount) = GetProcAddress(handle, "igTableGetColumnCount"); throwIf(!igTableGetColumnCount);
		*(cast(void**)&igTableGetColumnFlags) = GetProcAddress(handle, "igTableGetColumnFlags"); throwIf(!igTableGetColumnFlags);
		*(cast(void**)&igTableGetColumnIndex) = GetProcAddress(handle, "igTableGetColumnIndex"); throwIf(!igTableGetColumnIndex);
		*(cast(void**)&igTableGetColumnName_Int) = GetProcAddress(handle, "igTableGetColumnName_Int"); throwIf(!igTableGetColumnName_Int);
		*(cast(void**)&igTableGetColumnName_TablePtr) = GetProcAddress(handle, "igTableGetColumnName_TablePtr"); throwIf(!igTableGetColumnName_TablePtr);
		*(cast(void**)&igTableGetColumnNextSortDirection) = GetProcAddress(handle, "igTableGetColumnNextSortDirection"); throwIf(!igTableGetColumnNextSortDirection);
		*(cast(void**)&igTableGetColumnResizeID) = GetProcAddress(handle, "igTableGetColumnResizeID"); throwIf(!igTableGetColumnResizeID);
		*(cast(void**)&igTableGetColumnWidthAuto) = GetProcAddress(handle, "igTableGetColumnWidthAuto"); throwIf(!igTableGetColumnWidthAuto);
		*(cast(void**)&igTableGetHeaderAngledMaxLabelWidth) = GetProcAddress(handle, "igTableGetHeaderAngledMaxLabelWidth"); throwIf(!igTableGetHeaderAngledMaxLabelWidth);
		*(cast(void**)&igTableGetHeaderRowHeight) = GetProcAddress(handle, "igTableGetHeaderRowHeight"); throwIf(!igTableGetHeaderRowHeight);
		*(cast(void**)&igTableGetHoveredColumn) = GetProcAddress(handle, "igTableGetHoveredColumn"); throwIf(!igTableGetHoveredColumn);
		*(cast(void**)&igTableGetHoveredRow) = GetProcAddress(handle, "igTableGetHoveredRow"); throwIf(!igTableGetHoveredRow);
		*(cast(void**)&igTableGetInstanceData) = GetProcAddress(handle, "igTableGetInstanceData"); throwIf(!igTableGetInstanceData);
		*(cast(void**)&igTableGetInstanceID) = GetProcAddress(handle, "igTableGetInstanceID"); throwIf(!igTableGetInstanceID);
		*(cast(void**)&igTableGetMaxColumnWidth) = GetProcAddress(handle, "igTableGetMaxColumnWidth"); throwIf(!igTableGetMaxColumnWidth);
		*(cast(void**)&igTableGetRowIndex) = GetProcAddress(handle, "igTableGetRowIndex"); throwIf(!igTableGetRowIndex);
		*(cast(void**)&igTableGetSortSpecs) = GetProcAddress(handle, "igTableGetSortSpecs"); throwIf(!igTableGetSortSpecs);
		*(cast(void**)&igTableHeader) = GetProcAddress(handle, "igTableHeader"); throwIf(!igTableHeader);
		*(cast(void**)&igTableHeadersRow) = GetProcAddress(handle, "igTableHeadersRow"); throwIf(!igTableHeadersRow);
		*(cast(void**)&igTableLoadSettings) = GetProcAddress(handle, "igTableLoadSettings"); throwIf(!igTableLoadSettings);
		*(cast(void**)&igTableMergeDrawChannels) = GetProcAddress(handle, "igTableMergeDrawChannels"); throwIf(!igTableMergeDrawChannels);
		*(cast(void**)&igTableNextColumn) = GetProcAddress(handle, "igTableNextColumn"); throwIf(!igTableNextColumn);
		*(cast(void**)&igTableNextRow) = GetProcAddress(handle, "igTableNextRow"); throwIf(!igTableNextRow);
		*(cast(void**)&igTableOpenContextMenu) = GetProcAddress(handle, "igTableOpenContextMenu"); throwIf(!igTableOpenContextMenu);
		*(cast(void**)&igTablePopBackgroundChannel) = GetProcAddress(handle, "igTablePopBackgroundChannel"); throwIf(!igTablePopBackgroundChannel);
		*(cast(void**)&igTablePushBackgroundChannel) = GetProcAddress(handle, "igTablePushBackgroundChannel"); throwIf(!igTablePushBackgroundChannel);
		*(cast(void**)&igTableRemove) = GetProcAddress(handle, "igTableRemove"); throwIf(!igTableRemove);
		*(cast(void**)&igTableResetSettings) = GetProcAddress(handle, "igTableResetSettings"); throwIf(!igTableResetSettings);
		*(cast(void**)&igTableSaveSettings) = GetProcAddress(handle, "igTableSaveSettings"); throwIf(!igTableSaveSettings);
		*(cast(void**)&igTableSetBgColor) = GetProcAddress(handle, "igTableSetBgColor"); throwIf(!igTableSetBgColor);
		*(cast(void**)&igTableSetColumnEnabled) = GetProcAddress(handle, "igTableSetColumnEnabled"); throwIf(!igTableSetColumnEnabled);
		*(cast(void**)&igTableSetColumnIndex) = GetProcAddress(handle, "igTableSetColumnIndex"); throwIf(!igTableSetColumnIndex);
		*(cast(void**)&igTableSetColumnSortDirection) = GetProcAddress(handle, "igTableSetColumnSortDirection"); throwIf(!igTableSetColumnSortDirection);
		*(cast(void**)&igTableSetColumnWidth) = GetProcAddress(handle, "igTableSetColumnWidth"); throwIf(!igTableSetColumnWidth);
		*(cast(void**)&igTableSetColumnWidthAutoAll) = GetProcAddress(handle, "igTableSetColumnWidthAutoAll"); throwIf(!igTableSetColumnWidthAutoAll);
		*(cast(void**)&igTableSetColumnWidthAutoSingle) = GetProcAddress(handle, "igTableSetColumnWidthAutoSingle"); throwIf(!igTableSetColumnWidthAutoSingle);
		*(cast(void**)&igTableSettingsAddSettingsHandler) = GetProcAddress(handle, "igTableSettingsAddSettingsHandler"); throwIf(!igTableSettingsAddSettingsHandler);
		*(cast(void**)&igTableSettingsCreate) = GetProcAddress(handle, "igTableSettingsCreate"); throwIf(!igTableSettingsCreate);
		*(cast(void**)&igTableSettingsFindByID) = GetProcAddress(handle, "igTableSettingsFindByID"); throwIf(!igTableSettingsFindByID);
		*(cast(void**)&igTableSetupColumn) = GetProcAddress(handle, "igTableSetupColumn"); throwIf(!igTableSetupColumn);
		*(cast(void**)&igTableSetupDrawChannels) = GetProcAddress(handle, "igTableSetupDrawChannels"); throwIf(!igTableSetupDrawChannels);
		*(cast(void**)&igTableSetupScrollFreeze) = GetProcAddress(handle, "igTableSetupScrollFreeze"); throwIf(!igTableSetupScrollFreeze);
		*(cast(void**)&igTableSortSpecsBuild) = GetProcAddress(handle, "igTableSortSpecsBuild"); throwIf(!igTableSortSpecsBuild);
		*(cast(void**)&igTableSortSpecsSanitize) = GetProcAddress(handle, "igTableSortSpecsSanitize"); throwIf(!igTableSortSpecsSanitize);
		*(cast(void**)&igTableUpdateBorders) = GetProcAddress(handle, "igTableUpdateBorders"); throwIf(!igTableUpdateBorders);
		*(cast(void**)&igTableUpdateColumnsWeightFromWidth) = GetProcAddress(handle, "igTableUpdateColumnsWeightFromWidth"); throwIf(!igTableUpdateColumnsWeightFromWidth);
		*(cast(void**)&igTableUpdateLayout) = GetProcAddress(handle, "igTableUpdateLayout"); throwIf(!igTableUpdateLayout);
		*(cast(void**)&igTeleportMousePos) = GetProcAddress(handle, "igTeleportMousePos"); throwIf(!igTeleportMousePos);
		*(cast(void**)&igTempInputIsActive) = GetProcAddress(handle, "igTempInputIsActive"); throwIf(!igTempInputIsActive);
		*(cast(void**)&igTempInputScalar) = GetProcAddress(handle, "igTempInputScalar"); throwIf(!igTempInputScalar);
		*(cast(void**)&igTempInputText) = GetProcAddress(handle, "igTempInputText"); throwIf(!igTempInputText);
		*(cast(void**)&igTestKeyOwner) = GetProcAddress(handle, "igTestKeyOwner"); throwIf(!igTestKeyOwner);
		*(cast(void**)&igTestShortcutRouting) = GetProcAddress(handle, "igTestShortcutRouting"); throwIf(!igTestShortcutRouting);
		*(cast(void**)&igText) = GetProcAddress(handle, "igText"); throwIf(!igText);
		*(cast(void**)&igTextColored) = GetProcAddress(handle, "igTextColored"); throwIf(!igTextColored);
		*(cast(void**)&igTextColoredV) = GetProcAddress(handle, "igTextColoredV"); throwIf(!igTextColoredV);
		*(cast(void**)&igTextDisabled) = GetProcAddress(handle, "igTextDisabled"); throwIf(!igTextDisabled);
		*(cast(void**)&igTextDisabledV) = GetProcAddress(handle, "igTextDisabledV"); throwIf(!igTextDisabledV);
		*(cast(void**)&igTextEx) = GetProcAddress(handle, "igTextEx"); throwIf(!igTextEx);
		*(cast(void**)&igTextLink) = GetProcAddress(handle, "igTextLink"); throwIf(!igTextLink);
		*(cast(void**)&igTextLinkOpenURL) = GetProcAddress(handle, "igTextLinkOpenURL"); throwIf(!igTextLinkOpenURL);
		*(cast(void**)&igTextUnformatted) = GetProcAddress(handle, "igTextUnformatted"); throwIf(!igTextUnformatted);
		*(cast(void**)&igTextV) = GetProcAddress(handle, "igTextV"); throwIf(!igTextV);
		*(cast(void**)&igTextWrapped) = GetProcAddress(handle, "igTextWrapped"); throwIf(!igTextWrapped);
		*(cast(void**)&igTextWrappedV) = GetProcAddress(handle, "igTextWrappedV"); throwIf(!igTextWrappedV);
		*(cast(void**)&igTranslateWindowsInViewport) = GetProcAddress(handle, "igTranslateWindowsInViewport"); throwIf(!igTranslateWindowsInViewport);
		*(cast(void**)&igTreeNodeBehavior) = GetProcAddress(handle, "igTreeNodeBehavior"); throwIf(!igTreeNodeBehavior);
		*(cast(void**)&igTreeNodeExV_Ptr) = GetProcAddress(handle, "igTreeNodeExV_Ptr"); throwIf(!igTreeNodeExV_Ptr);
		*(cast(void**)&igTreeNodeExV_Str) = GetProcAddress(handle, "igTreeNodeExV_Str"); throwIf(!igTreeNodeExV_Str);
		*(cast(void**)&igTreeNodeEx_Ptr) = GetProcAddress(handle, "igTreeNodeEx_Ptr"); throwIf(!igTreeNodeEx_Ptr);
		*(cast(void**)&igTreeNodeEx_Str) = GetProcAddress(handle, "igTreeNodeEx_Str"); throwIf(!igTreeNodeEx_Str);
		*(cast(void**)&igTreeNodeEx_StrStr) = GetProcAddress(handle, "igTreeNodeEx_StrStr"); throwIf(!igTreeNodeEx_StrStr);
		*(cast(void**)&igTreeNodeGetOpen) = GetProcAddress(handle, "igTreeNodeGetOpen"); throwIf(!igTreeNodeGetOpen);
		*(cast(void**)&igTreeNodeSetOpen) = GetProcAddress(handle, "igTreeNodeSetOpen"); throwIf(!igTreeNodeSetOpen);
		*(cast(void**)&igTreeNodeUpdateNextOpen) = GetProcAddress(handle, "igTreeNodeUpdateNextOpen"); throwIf(!igTreeNodeUpdateNextOpen);
		*(cast(void**)&igTreeNodeV_Ptr) = GetProcAddress(handle, "igTreeNodeV_Ptr"); throwIf(!igTreeNodeV_Ptr);
		*(cast(void**)&igTreeNodeV_Str) = GetProcAddress(handle, "igTreeNodeV_Str"); throwIf(!igTreeNodeV_Str);
		*(cast(void**)&igTreeNode_Ptr) = GetProcAddress(handle, "igTreeNode_Ptr"); throwIf(!igTreeNode_Ptr);
		*(cast(void**)&igTreeNode_Str) = GetProcAddress(handle, "igTreeNode_Str"); throwIf(!igTreeNode_Str);
		*(cast(void**)&igTreeNode_StrStr) = GetProcAddress(handle, "igTreeNode_StrStr"); throwIf(!igTreeNode_StrStr);
		*(cast(void**)&igTreePop) = GetProcAddress(handle, "igTreePop"); throwIf(!igTreePop);
		*(cast(void**)&igTreePushOverrideID) = GetProcAddress(handle, "igTreePushOverrideID"); throwIf(!igTreePushOverrideID);
		*(cast(void**)&igTreePush_Ptr) = GetProcAddress(handle, "igTreePush_Ptr"); throwIf(!igTreePush_Ptr);
		*(cast(void**)&igTreePush_Str) = GetProcAddress(handle, "igTreePush_Str"); throwIf(!igTreePush_Str);
		*(cast(void**)&igTypingSelectFindBestLeadingMatch) = GetProcAddress(handle, "igTypingSelectFindBestLeadingMatch"); throwIf(!igTypingSelectFindBestLeadingMatch);
		*(cast(void**)&igTypingSelectFindMatch) = GetProcAddress(handle, "igTypingSelectFindMatch"); throwIf(!igTypingSelectFindMatch);
		*(cast(void**)&igTypingSelectFindNextSingleCharMatch) = GetProcAddress(handle, "igTypingSelectFindNextSingleCharMatch"); throwIf(!igTypingSelectFindNextSingleCharMatch);
		*(cast(void**)&igUnindent) = GetProcAddress(handle, "igUnindent"); throwIf(!igUnindent);
		*(cast(void**)&igUpdateHoveredWindowAndCaptureFlags) = GetProcAddress(handle, "igUpdateHoveredWindowAndCaptureFlags"); throwIf(!igUpdateHoveredWindowAndCaptureFlags);
		*(cast(void**)&igUpdateInputEvents) = GetProcAddress(handle, "igUpdateInputEvents"); throwIf(!igUpdateInputEvents);
		*(cast(void**)&igUpdateMouseMovingWindowEndFrame) = GetProcAddress(handle, "igUpdateMouseMovingWindowEndFrame"); throwIf(!igUpdateMouseMovingWindowEndFrame);
		*(cast(void**)&igUpdateMouseMovingWindowNewFrame) = GetProcAddress(handle, "igUpdateMouseMovingWindowNewFrame"); throwIf(!igUpdateMouseMovingWindowNewFrame);
		*(cast(void**)&igUpdatePlatformWindows) = GetProcAddress(handle, "igUpdatePlatformWindows"); throwIf(!igUpdatePlatformWindows);
		*(cast(void**)&igUpdateWindowParentAndRootLinks) = GetProcAddress(handle, "igUpdateWindowParentAndRootLinks"); throwIf(!igUpdateWindowParentAndRootLinks);
		*(cast(void**)&igUpdateWindowSkipRefresh) = GetProcAddress(handle, "igUpdateWindowSkipRefresh"); throwIf(!igUpdateWindowSkipRefresh);
		*(cast(void**)&igVSliderFloat) = GetProcAddress(handle, "igVSliderFloat"); throwIf(!igVSliderFloat);
		*(cast(void**)&igVSliderInt) = GetProcAddress(handle, "igVSliderInt"); throwIf(!igVSliderInt);
		*(cast(void**)&igVSliderScalar) = GetProcAddress(handle, "igVSliderScalar"); throwIf(!igVSliderScalar);
		*(cast(void**)&igValue_Bool) = GetProcAddress(handle, "igValue_Bool"); throwIf(!igValue_Bool);
		*(cast(void**)&igValue_Float) = GetProcAddress(handle, "igValue_Float"); throwIf(!igValue_Float);
		*(cast(void**)&igValue_Int) = GetProcAddress(handle, "igValue_Int"); throwIf(!igValue_Int);
		*(cast(void**)&igValue_Uint) = GetProcAddress(handle, "igValue_Uint"); throwIf(!igValue_Uint);
		*(cast(void**)&igWindowPosAbsToRel) = GetProcAddress(handle, "igWindowPosAbsToRel"); throwIf(!igWindowPosAbsToRel);
		*(cast(void**)&igWindowPosRelToAbs) = GetProcAddress(handle, "igWindowPosRelToAbs"); throwIf(!igWindowPosRelToAbs);
		*(cast(void**)&igWindowRectAbsToRel) = GetProcAddress(handle, "igWindowRectAbsToRel"); throwIf(!igWindowRectAbsToRel);
		*(cast(void**)&igWindowRectRelToAbs) = GetProcAddress(handle, "igWindowRectRelToAbs"); throwIf(!igWindowRectRelToAbs);
	}
	void unload() {
		if(handle) FreeLibrary(handle);
	}
}
__gshared _CImguiLoader CImguiLoader;
// End of CImguiLoader

// ImVector template

struct ImVector(T) {
    import core.stdc.string : memcpy;
    
    int                 Size;
    int                 Capacity;
    T*                  Data;

    void clear() { if (Data) { Size = Capacity = 0; igMemFree(Data); Data = null; } }
    bool empty() { return Size == 0; }

    void push_back(T* v) { if (Size == Capacity) reserve(_grow_capacity(Size + 1)); memcpy(&Data[Size], v, T.sizeof); Size++; }

    void reserve(int new_capacity) {
        if (new_capacity <= Capacity) return; T* new_data = cast(T*)igMemAlloc(cast(size_t)new_capacity * T.sizeof); if (Data) { memcpy(new_data, Data, cast(size_t)Size * T.sizeof); igMemFree(Data); } Data = new_data; Capacity = new_capacity;
    }

    int _grow_capacity(int sz) { int new_capacity = Capacity ? (Capacity + Capacity / 2) : 8; return new_capacity > sz ? new_capacity : sz; }

    void resize(int new_size) { if (new_size > Capacity) reserve(_grow_capacity(new_size)); Size = new_size; }
}
struct ImPool(T) {
    ImVector!T      Buf;        // Contiguous data
    ImGuiStorage    Map;        // ID->Index
    ImPoolIdx       FreeIdx;    // Next free idx to use
    ImPoolIdx       AliveCount; // Number of active/alive items (for display purpose)
}
struct ImChunkStream(T) {
    ImVector!char  Buf;
}
struct ImSpan(T) {
    T*                  Data;
    T*                  DataEnd;
}
struct ImVec2 {
    float x;
    float y;

    ImVec2 opBinary(string op)(ImVec2 a) if (op=="+" || op=="-") {
        static if (op == "+") {
            return ImVec2(x+a.x, y+a.y);
        }
        static if (op == "-") {
            return ImVec2(x-a.x, y-a.y);
        }
    }
}
// Aliases
alias ImBitArrayForNamedKeys = ImBitArray_ImGuiKey_NamedKey_COUNT__lessImGuiKey_NamedKey_BEGIN;
alias ImBitArrayPtr = ImU32*;
alias ImDrawCallback = extern(C) void function(ImDrawList* parent_list, ImDrawCmd* cmd) nothrow;
alias ImDrawFlags = int;
alias ImDrawIdx = ushort;
alias ImDrawListFlags = int;
alias ImFileHandle = FILE*;
alias ImFontAtlasFlags = int;
alias ImGuiActivateFlags = int;
alias ImGuiBackendFlags = int;
alias ImGuiButtonFlags = int;
alias ImGuiChildFlags = int;
alias ImGuiCol = int;
alias ImGuiColorEditFlags = int;
alias ImGuiComboFlags = int;
alias ImGuiCond = int;
alias ImGuiConfigFlags = int;
alias ImGuiContextHookCallback = extern(C) void function(ImGuiContext* ctx, ImGuiContextHook* hook) nothrow;
alias ImGuiDataAuthority = int;
alias ImGuiDataType = int;
alias ImGuiDebugLogFlags = int;
alias ImGuiDockNodeFlags = int;
alias ImGuiDragDropFlags = int;
alias ImGuiErrorLogCallback = extern(C) void function(void* user_data, immutable(char)* fmt, ...) nothrow;
alias ImGuiFocusRequestFlags = int;
alias ImGuiFocusedFlags = int;
alias ImGuiHoveredFlags = int;
alias ImGuiID = uint;
alias ImGuiInputFlags = int;
alias ImGuiInputTextCallback = extern(C) int function(ImGuiInputTextCallbackData* data) nothrow;
alias ImGuiInputTextFlags = int;
alias ImGuiItemFlags = int;
alias ImGuiItemStatusFlags = int;
alias ImGuiKeyChord = int;
alias ImGuiKeyRoutingIndex = ImS16;
alias ImGuiLayoutType = int;
alias ImGuiMemAllocFunc = extern(C) void* function(size_t sz, void* user_data) nothrow;
alias ImGuiMemFreeFunc = extern(C) void function(void* ptr, void* user_data) nothrow;
alias ImGuiMouseButton = int;
alias ImGuiMouseCursor = int;
alias ImGuiMultiSelectFlags = int;
alias ImGuiNavHighlightFlags = int;
alias ImGuiNavMoveFlags = int;
alias ImGuiNextItemDataFlags = int;
alias ImGuiNextWindowDataFlags = int;
alias ImGuiOldColumnFlags = int;
alias ImGuiPopupFlags = int;
alias ImGuiScrollFlags = int;
alias ImGuiSelectableFlags = int;
alias ImGuiSelectionUserData = ImS64;
alias ImGuiSeparatorFlags = int;
alias ImGuiSizeCallback = extern(C) void function(ImGuiSizeCallbackData* data) nothrow;
alias ImGuiSliderFlags = int;
alias ImGuiStyleVar = int;
alias ImGuiTabBarFlags = int;
alias ImGuiTabItemFlags = int;
alias ImGuiTableBgTarget = int;
alias ImGuiTableColumnFlags = int;
alias ImGuiTableColumnIdx = ImS16;
alias ImGuiTableDrawChannelIdx = ImU16;
alias ImGuiTableFlags = int;
alias ImGuiTableRowFlags = int;
alias ImGuiTextFlags = int;
alias ImGuiTooltipFlags = int;
alias ImGuiTreeNodeFlags = int;
alias ImGuiTypingSelectFlags = int;
alias ImGuiViewportFlags = int;
alias ImGuiWindowFlags = int;
alias ImGuiWindowRefreshFlags = int;
alias ImPoolIdx = int;
alias ImS16 = short;
alias ImS32 = int;
alias ImS64 = long;
alias ImS8 = char;
alias ImTextureID = void*;
alias ImU16 = ushort;
alias ImU32 = uint;
alias ImU64 = ulong;
alias ImU8 = ubyte;
alias ImWchar = ImWchar16;
alias ImWchar16 = ushort;
alias __time64_t = long;
alias errno_t = int;
alias fpos_t = long;
alias size_t = ulong;
alias uintptr_t = ulong;
alias va_list = immutable(char)*;
alias wchar_t = ushort;
alias wint_t = ushort;

// Enums
enum ImDrawFlags_ {
	ImDrawFlags_None = 0,
	ImDrawFlags_Closed = 1 << 0,
	ImDrawFlags_RoundCornersTopLeft = 1 << 4,
	ImDrawFlags_RoundCornersTopRight = 1 << 5,
	ImDrawFlags_RoundCornersBottomLeft = 1 << 6,
	ImDrawFlags_RoundCornersBottomRight = 1 << 7,
	ImDrawFlags_RoundCornersNone = 1 << 8,
	ImDrawFlags_RoundCornersTop = ImDrawFlags_RoundCornersTopLeft | ImDrawFlags_RoundCornersTopRight,
	ImDrawFlags_RoundCornersBottom = ImDrawFlags_RoundCornersBottomLeft | ImDrawFlags_RoundCornersBottomRight,
	ImDrawFlags_RoundCornersLeft = ImDrawFlags_RoundCornersBottomLeft | ImDrawFlags_RoundCornersTopLeft,
	ImDrawFlags_RoundCornersRight = ImDrawFlags_RoundCornersBottomRight | ImDrawFlags_RoundCornersTopRight,
	ImDrawFlags_RoundCornersAll = ImDrawFlags_RoundCornersTopLeft | ImDrawFlags_RoundCornersTopRight | ImDrawFlags_RoundCornersBottomLeft | ImDrawFlags_RoundCornersBottomRight,
	ImDrawFlags_RoundCornersDefault_ = ImDrawFlags_RoundCornersAll,
	ImDrawFlags_RoundCornersMask_ = ImDrawFlags_RoundCornersAll | ImDrawFlags_RoundCornersNone,
}
enum : ImDrawFlags_ {
	ImDrawFlags_None = ImDrawFlags_.ImDrawFlags_None,
	ImDrawFlags_Closed = ImDrawFlags_.ImDrawFlags_Closed,
	ImDrawFlags_RoundCornersTopLeft = ImDrawFlags_.ImDrawFlags_RoundCornersTopLeft,
	ImDrawFlags_RoundCornersTopRight = ImDrawFlags_.ImDrawFlags_RoundCornersTopRight,
	ImDrawFlags_RoundCornersBottomLeft = ImDrawFlags_.ImDrawFlags_RoundCornersBottomLeft,
	ImDrawFlags_RoundCornersBottomRight = ImDrawFlags_.ImDrawFlags_RoundCornersBottomRight,
	ImDrawFlags_RoundCornersNone = ImDrawFlags_.ImDrawFlags_RoundCornersNone,
	ImDrawFlags_RoundCornersTop = ImDrawFlags_.ImDrawFlags_RoundCornersTop,
	ImDrawFlags_RoundCornersBottom = ImDrawFlags_.ImDrawFlags_RoundCornersBottom,
	ImDrawFlags_RoundCornersLeft = ImDrawFlags_.ImDrawFlags_RoundCornersLeft,
	ImDrawFlags_RoundCornersRight = ImDrawFlags_.ImDrawFlags_RoundCornersRight,
	ImDrawFlags_RoundCornersAll = ImDrawFlags_.ImDrawFlags_RoundCornersAll,
	ImDrawFlags_RoundCornersDefault_ = ImDrawFlags_.ImDrawFlags_RoundCornersDefault_,
	ImDrawFlags_RoundCornersMask_ = ImDrawFlags_.ImDrawFlags_RoundCornersMask_,
}
enum ImDrawListFlags_ {
	ImDrawListFlags_None = 0,
	ImDrawListFlags_AntiAliasedLines = 1 << 0,
	ImDrawListFlags_AntiAliasedLinesUseTex = 1 << 1,
	ImDrawListFlags_AntiAliasedFill = 1 << 2,
	ImDrawListFlags_AllowVtxOffset = 1 << 3,
}
enum : ImDrawListFlags_ {
	ImDrawListFlags_None = ImDrawListFlags_.ImDrawListFlags_None,
	ImDrawListFlags_AntiAliasedLines = ImDrawListFlags_.ImDrawListFlags_AntiAliasedLines,
	ImDrawListFlags_AntiAliasedLinesUseTex = ImDrawListFlags_.ImDrawListFlags_AntiAliasedLinesUseTex,
	ImDrawListFlags_AntiAliasedFill = ImDrawListFlags_.ImDrawListFlags_AntiAliasedFill,
	ImDrawListFlags_AllowVtxOffset = ImDrawListFlags_.ImDrawListFlags_AllowVtxOffset,
}
enum ImFontAtlasFlags_ {
	ImFontAtlasFlags_None = 0,
	ImFontAtlasFlags_NoPowerOfTwoHeight = 1 << 0,
	ImFontAtlasFlags_NoMouseCursors = 1 << 1,
	ImFontAtlasFlags_NoBakedLines = 1 << 2,
}
enum : ImFontAtlasFlags_ {
	ImFontAtlasFlags_None = ImFontAtlasFlags_.ImFontAtlasFlags_None,
	ImFontAtlasFlags_NoPowerOfTwoHeight = ImFontAtlasFlags_.ImFontAtlasFlags_NoPowerOfTwoHeight,
	ImFontAtlasFlags_NoMouseCursors = ImFontAtlasFlags_.ImFontAtlasFlags_NoMouseCursors,
	ImFontAtlasFlags_NoBakedLines = ImFontAtlasFlags_.ImFontAtlasFlags_NoBakedLines,
}
enum ImGuiActivateFlags_ {
	ImGuiActivateFlags_None = 0,
	ImGuiActivateFlags_PreferInput = 1 << 0,
	ImGuiActivateFlags_PreferTweak = 1 << 1,
	ImGuiActivateFlags_TryToPreserveState = 1 << 2,
	ImGuiActivateFlags_FromTabbing = 1 << 3,
	ImGuiActivateFlags_FromShortcut = 1 << 4,
}
enum : ImGuiActivateFlags_ {
	ImGuiActivateFlags_None = ImGuiActivateFlags_.ImGuiActivateFlags_None,
	ImGuiActivateFlags_PreferInput = ImGuiActivateFlags_.ImGuiActivateFlags_PreferInput,
	ImGuiActivateFlags_PreferTweak = ImGuiActivateFlags_.ImGuiActivateFlags_PreferTweak,
	ImGuiActivateFlags_TryToPreserveState = ImGuiActivateFlags_.ImGuiActivateFlags_TryToPreserveState,
	ImGuiActivateFlags_FromTabbing = ImGuiActivateFlags_.ImGuiActivateFlags_FromTabbing,
	ImGuiActivateFlags_FromShortcut = ImGuiActivateFlags_.ImGuiActivateFlags_FromShortcut,
}
enum ImGuiAxis {
	ImGuiAxis_None = -1,
	ImGuiAxis_X = 0,
	ImGuiAxis_Y = 1,
}
enum : ImGuiAxis {
	ImGuiAxis_None = ImGuiAxis.ImGuiAxis_None,
	ImGuiAxis_X = ImGuiAxis.ImGuiAxis_X,
	ImGuiAxis_Y = ImGuiAxis.ImGuiAxis_Y,
}
enum ImGuiBackendFlags_ {
	ImGuiBackendFlags_None = 0,
	ImGuiBackendFlags_HasGamepad = 1 << 0,
	ImGuiBackendFlags_HasMouseCursors = 1 << 1,
	ImGuiBackendFlags_HasSetMousePos = 1 << 2,
	ImGuiBackendFlags_RendererHasVtxOffset = 1 << 3,
	ImGuiBackendFlags_PlatformHasViewports = 1 << 10,
	ImGuiBackendFlags_HasMouseHoveredViewport = 1 << 11,
	ImGuiBackendFlags_RendererHasViewports = 1 << 12,
}
enum : ImGuiBackendFlags_ {
	ImGuiBackendFlags_None = ImGuiBackendFlags_.ImGuiBackendFlags_None,
	ImGuiBackendFlags_HasGamepad = ImGuiBackendFlags_.ImGuiBackendFlags_HasGamepad,
	ImGuiBackendFlags_HasMouseCursors = ImGuiBackendFlags_.ImGuiBackendFlags_HasMouseCursors,
	ImGuiBackendFlags_HasSetMousePos = ImGuiBackendFlags_.ImGuiBackendFlags_HasSetMousePos,
	ImGuiBackendFlags_RendererHasVtxOffset = ImGuiBackendFlags_.ImGuiBackendFlags_RendererHasVtxOffset,
	ImGuiBackendFlags_PlatformHasViewports = ImGuiBackendFlags_.ImGuiBackendFlags_PlatformHasViewports,
	ImGuiBackendFlags_HasMouseHoveredViewport = ImGuiBackendFlags_.ImGuiBackendFlags_HasMouseHoveredViewport,
	ImGuiBackendFlags_RendererHasViewports = ImGuiBackendFlags_.ImGuiBackendFlags_RendererHasViewports,
}
enum ImGuiButtonFlagsPrivate_ {
	ImGuiButtonFlags_PressedOnClick = 1 << 4,
	ImGuiButtonFlags_PressedOnClickRelease = 1 << 5,
	ImGuiButtonFlags_PressedOnClickReleaseAnywhere = 1 << 6,
	ImGuiButtonFlags_PressedOnRelease = 1 << 7,
	ImGuiButtonFlags_PressedOnDoubleClick = 1 << 8,
	ImGuiButtonFlags_PressedOnDragDropHold = 1 << 9,
	ImGuiButtonFlags_Repeat = 1 << 10,
	ImGuiButtonFlags_FlattenChildren = 1 << 11,
	ImGuiButtonFlags_AllowOverlap = 1 << 12,
	ImGuiButtonFlags_DontClosePopups = 1 << 13,
	ImGuiButtonFlags_AlignTextBaseLine = 1 << 15,
	ImGuiButtonFlags_NoKeyModifiers = 1 << 16,
	ImGuiButtonFlags_NoHoldingActiveId = 1 << 17,
	ImGuiButtonFlags_NoNavFocus = 1 << 18,
	ImGuiButtonFlags_NoHoveredOnFocus = 1 << 19,
	ImGuiButtonFlags_NoSetKeyOwner = 1 << 20,
	ImGuiButtonFlags_NoTestKeyOwner = 1 << 21,
	ImGuiButtonFlags_PressedOnMask_ = ImGuiButtonFlags_PressedOnClick | ImGuiButtonFlags_PressedOnClickRelease | ImGuiButtonFlags_PressedOnClickReleaseAnywhere | ImGuiButtonFlags_PressedOnRelease | ImGuiButtonFlags_PressedOnDoubleClick | ImGuiButtonFlags_PressedOnDragDropHold,
	ImGuiButtonFlags_PressedOnDefault_ = ImGuiButtonFlags_PressedOnClickRelease,
}
enum : ImGuiButtonFlagsPrivate_ {
	ImGuiButtonFlags_PressedOnClick = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_PressedOnClick,
	ImGuiButtonFlags_PressedOnClickRelease = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_PressedOnClickRelease,
	ImGuiButtonFlags_PressedOnClickReleaseAnywhere = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_PressedOnClickReleaseAnywhere,
	ImGuiButtonFlags_PressedOnRelease = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_PressedOnRelease,
	ImGuiButtonFlags_PressedOnDoubleClick = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_PressedOnDoubleClick,
	ImGuiButtonFlags_PressedOnDragDropHold = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_PressedOnDragDropHold,
	ImGuiButtonFlags_Repeat = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_Repeat,
	ImGuiButtonFlags_FlattenChildren = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_FlattenChildren,
	ImGuiButtonFlags_AllowOverlap = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_AllowOverlap,
	ImGuiButtonFlags_DontClosePopups = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_DontClosePopups,
	ImGuiButtonFlags_AlignTextBaseLine = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_AlignTextBaseLine,
	ImGuiButtonFlags_NoKeyModifiers = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_NoKeyModifiers,
	ImGuiButtonFlags_NoHoldingActiveId = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_NoHoldingActiveId,
	ImGuiButtonFlags_NoNavFocus = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_NoNavFocus,
	ImGuiButtonFlags_NoHoveredOnFocus = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_NoHoveredOnFocus,
	ImGuiButtonFlags_NoSetKeyOwner = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_NoSetKeyOwner,
	ImGuiButtonFlags_NoTestKeyOwner = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_NoTestKeyOwner,
	ImGuiButtonFlags_PressedOnMask_ = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_PressedOnMask_,
	ImGuiButtonFlags_PressedOnDefault_ = ImGuiButtonFlagsPrivate_.ImGuiButtonFlags_PressedOnDefault_,
}
enum ImGuiButtonFlags_ {
	ImGuiButtonFlags_None = 0,
	ImGuiButtonFlags_MouseButtonLeft = 1 << 0,
	ImGuiButtonFlags_MouseButtonRight = 1 << 1,
	ImGuiButtonFlags_MouseButtonMiddle = 1 << 2,
	ImGuiButtonFlags_MouseButtonMask_ = ImGuiButtonFlags_MouseButtonLeft | ImGuiButtonFlags_MouseButtonRight | ImGuiButtonFlags_MouseButtonMiddle,
}
enum : ImGuiButtonFlags_ {
	ImGuiButtonFlags_None = ImGuiButtonFlags_.ImGuiButtonFlags_None,
	ImGuiButtonFlags_MouseButtonLeft = ImGuiButtonFlags_.ImGuiButtonFlags_MouseButtonLeft,
	ImGuiButtonFlags_MouseButtonRight = ImGuiButtonFlags_.ImGuiButtonFlags_MouseButtonRight,
	ImGuiButtonFlags_MouseButtonMiddle = ImGuiButtonFlags_.ImGuiButtonFlags_MouseButtonMiddle,
	ImGuiButtonFlags_MouseButtonMask_ = ImGuiButtonFlags_.ImGuiButtonFlags_MouseButtonMask_,
}
enum ImGuiChildFlags_ {
	ImGuiChildFlags_None = 0,
	ImGuiChildFlags_Border = 1 << 0,
	ImGuiChildFlags_AlwaysUseWindowPadding = 1 << 1,
	ImGuiChildFlags_ResizeX = 1 << 2,
	ImGuiChildFlags_ResizeY = 1 << 3,
	ImGuiChildFlags_AutoResizeX = 1 << 4,
	ImGuiChildFlags_AutoResizeY = 1 << 5,
	ImGuiChildFlags_AlwaysAutoResize = 1 << 6,
	ImGuiChildFlags_FrameStyle = 1 << 7,
	ImGuiChildFlags_NavFlattened = 1 << 8,
}
enum : ImGuiChildFlags_ {
	ImGuiChildFlags_None = ImGuiChildFlags_.ImGuiChildFlags_None,
	ImGuiChildFlags_Border = ImGuiChildFlags_.ImGuiChildFlags_Border,
	ImGuiChildFlags_AlwaysUseWindowPadding = ImGuiChildFlags_.ImGuiChildFlags_AlwaysUseWindowPadding,
	ImGuiChildFlags_ResizeX = ImGuiChildFlags_.ImGuiChildFlags_ResizeX,
	ImGuiChildFlags_ResizeY = ImGuiChildFlags_.ImGuiChildFlags_ResizeY,
	ImGuiChildFlags_AutoResizeX = ImGuiChildFlags_.ImGuiChildFlags_AutoResizeX,
	ImGuiChildFlags_AutoResizeY = ImGuiChildFlags_.ImGuiChildFlags_AutoResizeY,
	ImGuiChildFlags_AlwaysAutoResize = ImGuiChildFlags_.ImGuiChildFlags_AlwaysAutoResize,
	ImGuiChildFlags_FrameStyle = ImGuiChildFlags_.ImGuiChildFlags_FrameStyle,
	ImGuiChildFlags_NavFlattened = ImGuiChildFlags_.ImGuiChildFlags_NavFlattened,
}
enum ImGuiCol_ {
	ImGuiCol_Text,
	ImGuiCol_TextDisabled,
	ImGuiCol_WindowBg,
	ImGuiCol_ChildBg,
	ImGuiCol_PopupBg,
	ImGuiCol_Border,
	ImGuiCol_BorderShadow,
	ImGuiCol_FrameBg,
	ImGuiCol_FrameBgHovered,
	ImGuiCol_FrameBgActive,
	ImGuiCol_TitleBg,
	ImGuiCol_TitleBgActive,
	ImGuiCol_TitleBgCollapsed,
	ImGuiCol_MenuBarBg,
	ImGuiCol_ScrollbarBg,
	ImGuiCol_ScrollbarGrab,
	ImGuiCol_ScrollbarGrabHovered,
	ImGuiCol_ScrollbarGrabActive,
	ImGuiCol_CheckMark,
	ImGuiCol_SliderGrab,
	ImGuiCol_SliderGrabActive,
	ImGuiCol_Button,
	ImGuiCol_ButtonHovered,
	ImGuiCol_ButtonActive,
	ImGuiCol_Header,
	ImGuiCol_HeaderHovered,
	ImGuiCol_HeaderActive,
	ImGuiCol_Separator,
	ImGuiCol_SeparatorHovered,
	ImGuiCol_SeparatorActive,
	ImGuiCol_ResizeGrip,
	ImGuiCol_ResizeGripHovered,
	ImGuiCol_ResizeGripActive,
	ImGuiCol_TabHovered,
	ImGuiCol_Tab,
	ImGuiCol_TabSelected,
	ImGuiCol_TabSelectedOverline,
	ImGuiCol_TabDimmed,
	ImGuiCol_TabDimmedSelected,
	ImGuiCol_TabDimmedSelectedOverline,
	ImGuiCol_DockingPreview,
	ImGuiCol_DockingEmptyBg,
	ImGuiCol_PlotLines,
	ImGuiCol_PlotLinesHovered,
	ImGuiCol_PlotHistogram,
	ImGuiCol_PlotHistogramHovered,
	ImGuiCol_TableHeaderBg,
	ImGuiCol_TableBorderStrong,
	ImGuiCol_TableBorderLight,
	ImGuiCol_TableRowBg,
	ImGuiCol_TableRowBgAlt,
	ImGuiCol_TextLink,
	ImGuiCol_TextSelectedBg,
	ImGuiCol_DragDropTarget,
	ImGuiCol_NavHighlight,
	ImGuiCol_NavWindowingHighlight,
	ImGuiCol_NavWindowingDimBg,
	ImGuiCol_ModalWindowDimBg,
	ImGuiCol_COUNT,
}
enum : ImGuiCol_ {
	ImGuiCol_Text = ImGuiCol_.ImGuiCol_Text,
	ImGuiCol_TextDisabled = ImGuiCol_.ImGuiCol_TextDisabled,
	ImGuiCol_WindowBg = ImGuiCol_.ImGuiCol_WindowBg,
	ImGuiCol_ChildBg = ImGuiCol_.ImGuiCol_ChildBg,
	ImGuiCol_PopupBg = ImGuiCol_.ImGuiCol_PopupBg,
	ImGuiCol_Border = ImGuiCol_.ImGuiCol_Border,
	ImGuiCol_BorderShadow = ImGuiCol_.ImGuiCol_BorderShadow,
	ImGuiCol_FrameBg = ImGuiCol_.ImGuiCol_FrameBg,
	ImGuiCol_FrameBgHovered = ImGuiCol_.ImGuiCol_FrameBgHovered,
	ImGuiCol_FrameBgActive = ImGuiCol_.ImGuiCol_FrameBgActive,
	ImGuiCol_TitleBg = ImGuiCol_.ImGuiCol_TitleBg,
	ImGuiCol_TitleBgActive = ImGuiCol_.ImGuiCol_TitleBgActive,
	ImGuiCol_TitleBgCollapsed = ImGuiCol_.ImGuiCol_TitleBgCollapsed,
	ImGuiCol_MenuBarBg = ImGuiCol_.ImGuiCol_MenuBarBg,
	ImGuiCol_ScrollbarBg = ImGuiCol_.ImGuiCol_ScrollbarBg,
	ImGuiCol_ScrollbarGrab = ImGuiCol_.ImGuiCol_ScrollbarGrab,
	ImGuiCol_ScrollbarGrabHovered = ImGuiCol_.ImGuiCol_ScrollbarGrabHovered,
	ImGuiCol_ScrollbarGrabActive = ImGuiCol_.ImGuiCol_ScrollbarGrabActive,
	ImGuiCol_CheckMark = ImGuiCol_.ImGuiCol_CheckMark,
	ImGuiCol_SliderGrab = ImGuiCol_.ImGuiCol_SliderGrab,
	ImGuiCol_SliderGrabActive = ImGuiCol_.ImGuiCol_SliderGrabActive,
	ImGuiCol_Button = ImGuiCol_.ImGuiCol_Button,
	ImGuiCol_ButtonHovered = ImGuiCol_.ImGuiCol_ButtonHovered,
	ImGuiCol_ButtonActive = ImGuiCol_.ImGuiCol_ButtonActive,
	ImGuiCol_Header = ImGuiCol_.ImGuiCol_Header,
	ImGuiCol_HeaderHovered = ImGuiCol_.ImGuiCol_HeaderHovered,
	ImGuiCol_HeaderActive = ImGuiCol_.ImGuiCol_HeaderActive,
	ImGuiCol_Separator = ImGuiCol_.ImGuiCol_Separator,
	ImGuiCol_SeparatorHovered = ImGuiCol_.ImGuiCol_SeparatorHovered,
	ImGuiCol_SeparatorActive = ImGuiCol_.ImGuiCol_SeparatorActive,
	ImGuiCol_ResizeGrip = ImGuiCol_.ImGuiCol_ResizeGrip,
	ImGuiCol_ResizeGripHovered = ImGuiCol_.ImGuiCol_ResizeGripHovered,
	ImGuiCol_ResizeGripActive = ImGuiCol_.ImGuiCol_ResizeGripActive,
	ImGuiCol_TabHovered = ImGuiCol_.ImGuiCol_TabHovered,
	ImGuiCol_Tab = ImGuiCol_.ImGuiCol_Tab,
	ImGuiCol_TabSelected = ImGuiCol_.ImGuiCol_TabSelected,
	ImGuiCol_TabSelectedOverline = ImGuiCol_.ImGuiCol_TabSelectedOverline,
	ImGuiCol_TabDimmed = ImGuiCol_.ImGuiCol_TabDimmed,
	ImGuiCol_TabDimmedSelected = ImGuiCol_.ImGuiCol_TabDimmedSelected,
	ImGuiCol_TabDimmedSelectedOverline = ImGuiCol_.ImGuiCol_TabDimmedSelectedOverline,
	ImGuiCol_DockingPreview = ImGuiCol_.ImGuiCol_DockingPreview,
	ImGuiCol_DockingEmptyBg = ImGuiCol_.ImGuiCol_DockingEmptyBg,
	ImGuiCol_PlotLines = ImGuiCol_.ImGuiCol_PlotLines,
	ImGuiCol_PlotLinesHovered = ImGuiCol_.ImGuiCol_PlotLinesHovered,
	ImGuiCol_PlotHistogram = ImGuiCol_.ImGuiCol_PlotHistogram,
	ImGuiCol_PlotHistogramHovered = ImGuiCol_.ImGuiCol_PlotHistogramHovered,
	ImGuiCol_TableHeaderBg = ImGuiCol_.ImGuiCol_TableHeaderBg,
	ImGuiCol_TableBorderStrong = ImGuiCol_.ImGuiCol_TableBorderStrong,
	ImGuiCol_TableBorderLight = ImGuiCol_.ImGuiCol_TableBorderLight,
	ImGuiCol_TableRowBg = ImGuiCol_.ImGuiCol_TableRowBg,
	ImGuiCol_TableRowBgAlt = ImGuiCol_.ImGuiCol_TableRowBgAlt,
	ImGuiCol_TextLink = ImGuiCol_.ImGuiCol_TextLink,
	ImGuiCol_TextSelectedBg = ImGuiCol_.ImGuiCol_TextSelectedBg,
	ImGuiCol_DragDropTarget = ImGuiCol_.ImGuiCol_DragDropTarget,
	ImGuiCol_NavHighlight = ImGuiCol_.ImGuiCol_NavHighlight,
	ImGuiCol_NavWindowingHighlight = ImGuiCol_.ImGuiCol_NavWindowingHighlight,
	ImGuiCol_NavWindowingDimBg = ImGuiCol_.ImGuiCol_NavWindowingDimBg,
	ImGuiCol_ModalWindowDimBg = ImGuiCol_.ImGuiCol_ModalWindowDimBg,
	ImGuiCol_COUNT = ImGuiCol_.ImGuiCol_COUNT,
}
enum ImGuiColorEditFlags_ {
	ImGuiColorEditFlags_None = 0,
	ImGuiColorEditFlags_NoAlpha = 1 << 1,
	ImGuiColorEditFlags_NoPicker = 1 << 2,
	ImGuiColorEditFlags_NoOptions = 1 << 3,
	ImGuiColorEditFlags_NoSmallPreview = 1 << 4,
	ImGuiColorEditFlags_NoInputs = 1 << 5,
	ImGuiColorEditFlags_NoTooltip = 1 << 6,
	ImGuiColorEditFlags_NoLabel = 1 << 7,
	ImGuiColorEditFlags_NoSidePreview = 1 << 8,
	ImGuiColorEditFlags_NoDragDrop = 1 << 9,
	ImGuiColorEditFlags_NoBorder = 1 << 10,
	ImGuiColorEditFlags_AlphaBar = 1 << 16,
	ImGuiColorEditFlags_AlphaPreview = 1 << 17,
	ImGuiColorEditFlags_AlphaPreviewHalf = 1 << 18,
	ImGuiColorEditFlags_HDR = 1 << 19,
	ImGuiColorEditFlags_DisplayRGB = 1 << 20,
	ImGuiColorEditFlags_DisplayHSV = 1 << 21,
	ImGuiColorEditFlags_DisplayHex = 1 << 22,
	ImGuiColorEditFlags_Uint8 = 1 << 23,
	ImGuiColorEditFlags_Float = 1 << 24,
	ImGuiColorEditFlags_PickerHueBar = 1 << 25,
	ImGuiColorEditFlags_PickerHueWheel = 1 << 26,
	ImGuiColorEditFlags_InputRGB = 1 << 27,
	ImGuiColorEditFlags_InputHSV = 1 << 28,
	ImGuiColorEditFlags_DefaultOptions_ = ImGuiColorEditFlags_Uint8 | ImGuiColorEditFlags_DisplayRGB | ImGuiColorEditFlags_InputRGB | ImGuiColorEditFlags_PickerHueBar,
	ImGuiColorEditFlags_DisplayMask_ = ImGuiColorEditFlags_DisplayRGB | ImGuiColorEditFlags_DisplayHSV | ImGuiColorEditFlags_DisplayHex,
	ImGuiColorEditFlags_DataTypeMask_ = ImGuiColorEditFlags_Uint8 | ImGuiColorEditFlags_Float,
	ImGuiColorEditFlags_PickerMask_ = ImGuiColorEditFlags_PickerHueWheel | ImGuiColorEditFlags_PickerHueBar,
	ImGuiColorEditFlags_InputMask_ = ImGuiColorEditFlags_InputRGB | ImGuiColorEditFlags_InputHSV,
}
enum : ImGuiColorEditFlags_ {
	ImGuiColorEditFlags_None = ImGuiColorEditFlags_.ImGuiColorEditFlags_None,
	ImGuiColorEditFlags_NoAlpha = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoAlpha,
	ImGuiColorEditFlags_NoPicker = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoPicker,
	ImGuiColorEditFlags_NoOptions = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoOptions,
	ImGuiColorEditFlags_NoSmallPreview = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoSmallPreview,
	ImGuiColorEditFlags_NoInputs = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoInputs,
	ImGuiColorEditFlags_NoTooltip = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoTooltip,
	ImGuiColorEditFlags_NoLabel = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoLabel,
	ImGuiColorEditFlags_NoSidePreview = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoSidePreview,
	ImGuiColorEditFlags_NoDragDrop = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoDragDrop,
	ImGuiColorEditFlags_NoBorder = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoBorder,
	ImGuiColorEditFlags_AlphaBar = ImGuiColorEditFlags_.ImGuiColorEditFlags_AlphaBar,
	ImGuiColorEditFlags_AlphaPreview = ImGuiColorEditFlags_.ImGuiColorEditFlags_AlphaPreview,
	ImGuiColorEditFlags_AlphaPreviewHalf = ImGuiColorEditFlags_.ImGuiColorEditFlags_AlphaPreviewHalf,
	ImGuiColorEditFlags_HDR = ImGuiColorEditFlags_.ImGuiColorEditFlags_HDR,
	ImGuiColorEditFlags_DisplayRGB = ImGuiColorEditFlags_.ImGuiColorEditFlags_DisplayRGB,
	ImGuiColorEditFlags_DisplayHSV = ImGuiColorEditFlags_.ImGuiColorEditFlags_DisplayHSV,
	ImGuiColorEditFlags_DisplayHex = ImGuiColorEditFlags_.ImGuiColorEditFlags_DisplayHex,
	ImGuiColorEditFlags_Uint8 = ImGuiColorEditFlags_.ImGuiColorEditFlags_Uint8,
	ImGuiColorEditFlags_Float = ImGuiColorEditFlags_.ImGuiColorEditFlags_Float,
	ImGuiColorEditFlags_PickerHueBar = ImGuiColorEditFlags_.ImGuiColorEditFlags_PickerHueBar,
	ImGuiColorEditFlags_PickerHueWheel = ImGuiColorEditFlags_.ImGuiColorEditFlags_PickerHueWheel,
	ImGuiColorEditFlags_InputRGB = ImGuiColorEditFlags_.ImGuiColorEditFlags_InputRGB,
	ImGuiColorEditFlags_InputHSV = ImGuiColorEditFlags_.ImGuiColorEditFlags_InputHSV,
	ImGuiColorEditFlags_DefaultOptions_ = ImGuiColorEditFlags_.ImGuiColorEditFlags_DefaultOptions_,
	ImGuiColorEditFlags_DisplayMask_ = ImGuiColorEditFlags_.ImGuiColorEditFlags_DisplayMask_,
	ImGuiColorEditFlags_DataTypeMask_ = ImGuiColorEditFlags_.ImGuiColorEditFlags_DataTypeMask_,
	ImGuiColorEditFlags_PickerMask_ = ImGuiColorEditFlags_.ImGuiColorEditFlags_PickerMask_,
	ImGuiColorEditFlags_InputMask_ = ImGuiColorEditFlags_.ImGuiColorEditFlags_InputMask_,
}
enum ImGuiComboFlagsPrivate_ {
	ImGuiComboFlags_CustomPreview = 1 << 20,
}
enum : ImGuiComboFlagsPrivate_ {
	ImGuiComboFlags_CustomPreview = ImGuiComboFlagsPrivate_.ImGuiComboFlags_CustomPreview,
}
enum ImGuiComboFlags_ {
	ImGuiComboFlags_None = 0,
	ImGuiComboFlags_PopupAlignLeft = 1 << 0,
	ImGuiComboFlags_HeightSmall = 1 << 1,
	ImGuiComboFlags_HeightRegular = 1 << 2,
	ImGuiComboFlags_HeightLarge = 1 << 3,
	ImGuiComboFlags_HeightLargest = 1 << 4,
	ImGuiComboFlags_NoArrowButton = 1 << 5,
	ImGuiComboFlags_NoPreview = 1 << 6,
	ImGuiComboFlags_WidthFitPreview = 1 << 7,
	ImGuiComboFlags_HeightMask_ = ImGuiComboFlags_HeightSmall | ImGuiComboFlags_HeightRegular | ImGuiComboFlags_HeightLarge | ImGuiComboFlags_HeightLargest,
}
enum : ImGuiComboFlags_ {
	ImGuiComboFlags_None = ImGuiComboFlags_.ImGuiComboFlags_None,
	ImGuiComboFlags_PopupAlignLeft = ImGuiComboFlags_.ImGuiComboFlags_PopupAlignLeft,
	ImGuiComboFlags_HeightSmall = ImGuiComboFlags_.ImGuiComboFlags_HeightSmall,
	ImGuiComboFlags_HeightRegular = ImGuiComboFlags_.ImGuiComboFlags_HeightRegular,
	ImGuiComboFlags_HeightLarge = ImGuiComboFlags_.ImGuiComboFlags_HeightLarge,
	ImGuiComboFlags_HeightLargest = ImGuiComboFlags_.ImGuiComboFlags_HeightLargest,
	ImGuiComboFlags_NoArrowButton = ImGuiComboFlags_.ImGuiComboFlags_NoArrowButton,
	ImGuiComboFlags_NoPreview = ImGuiComboFlags_.ImGuiComboFlags_NoPreview,
	ImGuiComboFlags_WidthFitPreview = ImGuiComboFlags_.ImGuiComboFlags_WidthFitPreview,
	ImGuiComboFlags_HeightMask_ = ImGuiComboFlags_.ImGuiComboFlags_HeightMask_,
}
enum ImGuiCond_ {
	ImGuiCond_None = 0,
	ImGuiCond_Always = 1 << 0,
	ImGuiCond_Once = 1 << 1,
	ImGuiCond_FirstUseEver = 1 << 2,
	ImGuiCond_Appearing = 1 << 3,
}
enum : ImGuiCond_ {
	ImGuiCond_None = ImGuiCond_.ImGuiCond_None,
	ImGuiCond_Always = ImGuiCond_.ImGuiCond_Always,
	ImGuiCond_Once = ImGuiCond_.ImGuiCond_Once,
	ImGuiCond_FirstUseEver = ImGuiCond_.ImGuiCond_FirstUseEver,
	ImGuiCond_Appearing = ImGuiCond_.ImGuiCond_Appearing,
}
enum ImGuiConfigFlags_ {
	ImGuiConfigFlags_None = 0,
	ImGuiConfigFlags_NavEnableKeyboard = 1 << 0,
	ImGuiConfigFlags_NavEnableGamepad = 1 << 1,
	ImGuiConfigFlags_NavEnableSetMousePos = 1 << 2,
	ImGuiConfigFlags_NavNoCaptureKeyboard = 1 << 3,
	ImGuiConfigFlags_NoMouse = 1 << 4,
	ImGuiConfigFlags_NoMouseCursorChange = 1 << 5,
	ImGuiConfigFlags_NoKeyboard = 1 << 6,
	ImGuiConfigFlags_DockingEnable = 1 << 7,
	ImGuiConfigFlags_ViewportsEnable = 1 << 10,
	ImGuiConfigFlags_DpiEnableScaleViewports = 1 << 14,
	ImGuiConfigFlags_DpiEnableScaleFonts = 1 << 15,
	ImGuiConfigFlags_IsSRGB = 1 << 20,
	ImGuiConfigFlags_IsTouchScreen = 1 << 21,
}
enum : ImGuiConfigFlags_ {
	ImGuiConfigFlags_None = ImGuiConfigFlags_.ImGuiConfigFlags_None,
	ImGuiConfigFlags_NavEnableKeyboard = ImGuiConfigFlags_.ImGuiConfigFlags_NavEnableKeyboard,
	ImGuiConfigFlags_NavEnableGamepad = ImGuiConfigFlags_.ImGuiConfigFlags_NavEnableGamepad,
	ImGuiConfigFlags_NavEnableSetMousePos = ImGuiConfigFlags_.ImGuiConfigFlags_NavEnableSetMousePos,
	ImGuiConfigFlags_NavNoCaptureKeyboard = ImGuiConfigFlags_.ImGuiConfigFlags_NavNoCaptureKeyboard,
	ImGuiConfigFlags_NoMouse = ImGuiConfigFlags_.ImGuiConfigFlags_NoMouse,
	ImGuiConfigFlags_NoMouseCursorChange = ImGuiConfigFlags_.ImGuiConfigFlags_NoMouseCursorChange,
	ImGuiConfigFlags_NoKeyboard = ImGuiConfigFlags_.ImGuiConfigFlags_NoKeyboard,
	ImGuiConfigFlags_DockingEnable = ImGuiConfigFlags_.ImGuiConfigFlags_DockingEnable,
	ImGuiConfigFlags_ViewportsEnable = ImGuiConfigFlags_.ImGuiConfigFlags_ViewportsEnable,
	ImGuiConfigFlags_DpiEnableScaleViewports = ImGuiConfigFlags_.ImGuiConfigFlags_DpiEnableScaleViewports,
	ImGuiConfigFlags_DpiEnableScaleFonts = ImGuiConfigFlags_.ImGuiConfigFlags_DpiEnableScaleFonts,
	ImGuiConfigFlags_IsSRGB = ImGuiConfigFlags_.ImGuiConfigFlags_IsSRGB,
	ImGuiConfigFlags_IsTouchScreen = ImGuiConfigFlags_.ImGuiConfigFlags_IsTouchScreen,
}
enum ImGuiContextHookType {
	ImGuiContextHookType_NewFramePre,
	ImGuiContextHookType_NewFramePost,
	ImGuiContextHookType_EndFramePre,
	ImGuiContextHookType_EndFramePost,
	ImGuiContextHookType_RenderPre,
	ImGuiContextHookType_RenderPost,
	ImGuiContextHookType_Shutdown,
	ImGuiContextHookType_PendingRemoval_,
}
enum : ImGuiContextHookType {
	ImGuiContextHookType_NewFramePre = ImGuiContextHookType.ImGuiContextHookType_NewFramePre,
	ImGuiContextHookType_NewFramePost = ImGuiContextHookType.ImGuiContextHookType_NewFramePost,
	ImGuiContextHookType_EndFramePre = ImGuiContextHookType.ImGuiContextHookType_EndFramePre,
	ImGuiContextHookType_EndFramePost = ImGuiContextHookType.ImGuiContextHookType_EndFramePost,
	ImGuiContextHookType_RenderPre = ImGuiContextHookType.ImGuiContextHookType_RenderPre,
	ImGuiContextHookType_RenderPost = ImGuiContextHookType.ImGuiContextHookType_RenderPost,
	ImGuiContextHookType_Shutdown = ImGuiContextHookType.ImGuiContextHookType_Shutdown,
	ImGuiContextHookType_PendingRemoval_ = ImGuiContextHookType.ImGuiContextHookType_PendingRemoval_,
}
enum ImGuiDataAuthority_ {
	ImGuiDataAuthority_Auto,
	ImGuiDataAuthority_DockNode,
	ImGuiDataAuthority_Window,
}
enum : ImGuiDataAuthority_ {
	ImGuiDataAuthority_Auto = ImGuiDataAuthority_.ImGuiDataAuthority_Auto,
	ImGuiDataAuthority_DockNode = ImGuiDataAuthority_.ImGuiDataAuthority_DockNode,
	ImGuiDataAuthority_Window = ImGuiDataAuthority_.ImGuiDataAuthority_Window,
}
enum ImGuiDataTypePrivate_ {
	ImGuiDataType_String = ImGuiDataType_COUNT + 1,
	ImGuiDataType_Pointer,
	ImGuiDataType_ID,
}
enum : ImGuiDataTypePrivate_ {
	ImGuiDataType_String = ImGuiDataTypePrivate_.ImGuiDataType_String,
	ImGuiDataType_Pointer = ImGuiDataTypePrivate_.ImGuiDataType_Pointer,
	ImGuiDataType_ID = ImGuiDataTypePrivate_.ImGuiDataType_ID,
}
enum ImGuiDataType_ {
	ImGuiDataType_S8,
	ImGuiDataType_U8,
	ImGuiDataType_S16,
	ImGuiDataType_U16,
	ImGuiDataType_S32,
	ImGuiDataType_U32,
	ImGuiDataType_S64,
	ImGuiDataType_U64,
	ImGuiDataType_Float,
	ImGuiDataType_Double,
	ImGuiDataType_Bool,
	ImGuiDataType_COUNT,
}
enum : ImGuiDataType_ {
	ImGuiDataType_S8 = ImGuiDataType_.ImGuiDataType_S8,
	ImGuiDataType_U8 = ImGuiDataType_.ImGuiDataType_U8,
	ImGuiDataType_S16 = ImGuiDataType_.ImGuiDataType_S16,
	ImGuiDataType_U16 = ImGuiDataType_.ImGuiDataType_U16,
	ImGuiDataType_S32 = ImGuiDataType_.ImGuiDataType_S32,
	ImGuiDataType_U32 = ImGuiDataType_.ImGuiDataType_U32,
	ImGuiDataType_S64 = ImGuiDataType_.ImGuiDataType_S64,
	ImGuiDataType_U64 = ImGuiDataType_.ImGuiDataType_U64,
	ImGuiDataType_Float = ImGuiDataType_.ImGuiDataType_Float,
	ImGuiDataType_Double = ImGuiDataType_.ImGuiDataType_Double,
	ImGuiDataType_Bool = ImGuiDataType_.ImGuiDataType_Bool,
	ImGuiDataType_COUNT = ImGuiDataType_.ImGuiDataType_COUNT,
}
enum ImGuiDebugLogFlags_ {
	ImGuiDebugLogFlags_None = 0,
	ImGuiDebugLogFlags_EventActiveId = 1 << 0,
	ImGuiDebugLogFlags_EventFocus = 1 << 1,
	ImGuiDebugLogFlags_EventPopup = 1 << 2,
	ImGuiDebugLogFlags_EventNav = 1 << 3,
	ImGuiDebugLogFlags_EventClipper = 1 << 4,
	ImGuiDebugLogFlags_EventSelection = 1 << 5,
	ImGuiDebugLogFlags_EventIO = 1 << 6,
	ImGuiDebugLogFlags_EventInputRouting = 1 << 7,
	ImGuiDebugLogFlags_EventDocking = 1 << 8,
	ImGuiDebugLogFlags_EventViewport = 1 << 9,
	ImGuiDebugLogFlags_EventMask_ = ImGuiDebugLogFlags_EventActiveId | ImGuiDebugLogFlags_EventFocus | ImGuiDebugLogFlags_EventPopup | ImGuiDebugLogFlags_EventNav | ImGuiDebugLogFlags_EventClipper | ImGuiDebugLogFlags_EventSelection | ImGuiDebugLogFlags_EventIO | ImGuiDebugLogFlags_EventInputRouting | ImGuiDebugLogFlags_EventDocking | ImGuiDebugLogFlags_EventViewport,
	ImGuiDebugLogFlags_OutputToTTY = 1 << 20,
	ImGuiDebugLogFlags_OutputToTestEngine = 1 << 21,
}
enum : ImGuiDebugLogFlags_ {
	ImGuiDebugLogFlags_None = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_None,
	ImGuiDebugLogFlags_EventActiveId = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_EventActiveId,
	ImGuiDebugLogFlags_EventFocus = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_EventFocus,
	ImGuiDebugLogFlags_EventPopup = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_EventPopup,
	ImGuiDebugLogFlags_EventNav = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_EventNav,
	ImGuiDebugLogFlags_EventClipper = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_EventClipper,
	ImGuiDebugLogFlags_EventSelection = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_EventSelection,
	ImGuiDebugLogFlags_EventIO = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_EventIO,
	ImGuiDebugLogFlags_EventInputRouting = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_EventInputRouting,
	ImGuiDebugLogFlags_EventDocking = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_EventDocking,
	ImGuiDebugLogFlags_EventViewport = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_EventViewport,
	ImGuiDebugLogFlags_EventMask_ = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_EventMask_,
	ImGuiDebugLogFlags_OutputToTTY = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_OutputToTTY,
	ImGuiDebugLogFlags_OutputToTestEngine = ImGuiDebugLogFlags_.ImGuiDebugLogFlags_OutputToTestEngine,
}
enum ImGuiDir {
	ImGuiDir_None = -1,
	ImGuiDir_Left = 0,
	ImGuiDir_Right = 1,
	ImGuiDir_Up = 2,
	ImGuiDir_Down = 3,
	ImGuiDir_COUNT = 4,
}
enum : ImGuiDir {
	ImGuiDir_None = ImGuiDir.ImGuiDir_None,
	ImGuiDir_Left = ImGuiDir.ImGuiDir_Left,
	ImGuiDir_Right = ImGuiDir.ImGuiDir_Right,
	ImGuiDir_Up = ImGuiDir.ImGuiDir_Up,
	ImGuiDir_Down = ImGuiDir.ImGuiDir_Down,
	ImGuiDir_COUNT = ImGuiDir.ImGuiDir_COUNT,
}
enum ImGuiDockNodeFlagsPrivate_ {
	ImGuiDockNodeFlags_DockSpace = 1 << 10,
	ImGuiDockNodeFlags_CentralNode = 1 << 11,
	ImGuiDockNodeFlags_NoTabBar = 1 << 12,
	ImGuiDockNodeFlags_HiddenTabBar = 1 << 13,
	ImGuiDockNodeFlags_NoWindowMenuButton = 1 << 14,
	ImGuiDockNodeFlags_NoCloseButton = 1 << 15,
	ImGuiDockNodeFlags_NoResizeX = 1 << 16,
	ImGuiDockNodeFlags_NoResizeY = 1 << 17,
	ImGuiDockNodeFlags_DockedWindowsInFocusRoute = 1 << 18,
	ImGuiDockNodeFlags_NoDockingSplitOther = 1 << 19,
	ImGuiDockNodeFlags_NoDockingOverMe = 1 << 20,
	ImGuiDockNodeFlags_NoDockingOverOther = 1 << 21,
	ImGuiDockNodeFlags_NoDockingOverEmpty = 1 << 22,
	ImGuiDockNodeFlags_NoDocking = ImGuiDockNodeFlags_NoDockingOverMe | ImGuiDockNodeFlags_NoDockingOverOther | ImGuiDockNodeFlags_NoDockingOverEmpty | ImGuiDockNodeFlags_NoDockingSplit | ImGuiDockNodeFlags_NoDockingSplitOther,
	ImGuiDockNodeFlags_SharedFlagsInheritMask_ = ~0,
	ImGuiDockNodeFlags_NoResizeFlagsMask_ = ImGuiDockNodeFlags_NoResize | ImGuiDockNodeFlags_NoResizeX | ImGuiDockNodeFlags_NoResizeY,
	ImGuiDockNodeFlags_LocalFlagsTransferMask_ = ImGuiDockNodeFlags_NoDockingSplit | ImGuiDockNodeFlags_NoResizeFlagsMask_ | ImGuiDockNodeFlags_AutoHideTabBar | ImGuiDockNodeFlags_CentralNode | ImGuiDockNodeFlags_NoTabBar | ImGuiDockNodeFlags_HiddenTabBar | ImGuiDockNodeFlags_NoWindowMenuButton | ImGuiDockNodeFlags_NoCloseButton,
	ImGuiDockNodeFlags_SavedFlagsMask_ = ImGuiDockNodeFlags_NoResizeFlagsMask_ | ImGuiDockNodeFlags_DockSpace | ImGuiDockNodeFlags_CentralNode | ImGuiDockNodeFlags_NoTabBar | ImGuiDockNodeFlags_HiddenTabBar | ImGuiDockNodeFlags_NoWindowMenuButton | ImGuiDockNodeFlags_NoCloseButton,
}
enum : ImGuiDockNodeFlagsPrivate_ {
	ImGuiDockNodeFlags_DockSpace = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_DockSpace,
	ImGuiDockNodeFlags_CentralNode = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_CentralNode,
	ImGuiDockNodeFlags_NoTabBar = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_NoTabBar,
	ImGuiDockNodeFlags_HiddenTabBar = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_HiddenTabBar,
	ImGuiDockNodeFlags_NoWindowMenuButton = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_NoWindowMenuButton,
	ImGuiDockNodeFlags_NoCloseButton = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_NoCloseButton,
	ImGuiDockNodeFlags_NoResizeX = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_NoResizeX,
	ImGuiDockNodeFlags_NoResizeY = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_NoResizeY,
	ImGuiDockNodeFlags_DockedWindowsInFocusRoute = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_DockedWindowsInFocusRoute,
	ImGuiDockNodeFlags_NoDockingSplitOther = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_NoDockingSplitOther,
	ImGuiDockNodeFlags_NoDockingOverMe = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_NoDockingOverMe,
	ImGuiDockNodeFlags_NoDockingOverOther = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_NoDockingOverOther,
	ImGuiDockNodeFlags_NoDockingOverEmpty = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_NoDockingOverEmpty,
	ImGuiDockNodeFlags_NoDocking = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_NoDocking,
	ImGuiDockNodeFlags_SharedFlagsInheritMask_ = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_SharedFlagsInheritMask_,
	ImGuiDockNodeFlags_NoResizeFlagsMask_ = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_NoResizeFlagsMask_,
	ImGuiDockNodeFlags_LocalFlagsTransferMask_ = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_LocalFlagsTransferMask_,
	ImGuiDockNodeFlags_SavedFlagsMask_ = ImGuiDockNodeFlagsPrivate_.ImGuiDockNodeFlags_SavedFlagsMask_,
}
enum ImGuiDockNodeFlags_ {
	ImGuiDockNodeFlags_None = 0,
	ImGuiDockNodeFlags_KeepAliveOnly = 1 << 0,
	ImGuiDockNodeFlags_NoDockingOverCentralNode = 1 << 2,
	ImGuiDockNodeFlags_PassthruCentralNode = 1 << 3,
	ImGuiDockNodeFlags_NoDockingSplit = 1 << 4,
	ImGuiDockNodeFlags_NoResize = 1 << 5,
	ImGuiDockNodeFlags_AutoHideTabBar = 1 << 6,
	ImGuiDockNodeFlags_NoUndocking = 1 << 7,
}
enum : ImGuiDockNodeFlags_ {
	ImGuiDockNodeFlags_None = ImGuiDockNodeFlags_.ImGuiDockNodeFlags_None,
	ImGuiDockNodeFlags_KeepAliveOnly = ImGuiDockNodeFlags_.ImGuiDockNodeFlags_KeepAliveOnly,
	ImGuiDockNodeFlags_NoDockingOverCentralNode = ImGuiDockNodeFlags_.ImGuiDockNodeFlags_NoDockingOverCentralNode,
	ImGuiDockNodeFlags_PassthruCentralNode = ImGuiDockNodeFlags_.ImGuiDockNodeFlags_PassthruCentralNode,
	ImGuiDockNodeFlags_NoDockingSplit = ImGuiDockNodeFlags_.ImGuiDockNodeFlags_NoDockingSplit,
	ImGuiDockNodeFlags_NoResize = ImGuiDockNodeFlags_.ImGuiDockNodeFlags_NoResize,
	ImGuiDockNodeFlags_AutoHideTabBar = ImGuiDockNodeFlags_.ImGuiDockNodeFlags_AutoHideTabBar,
	ImGuiDockNodeFlags_NoUndocking = ImGuiDockNodeFlags_.ImGuiDockNodeFlags_NoUndocking,
}
enum ImGuiDockNodeState {
	ImGuiDockNodeState_Unknown,
	ImGuiDockNodeState_HostWindowHiddenBecauseSingleWindow,
	ImGuiDockNodeState_HostWindowHiddenBecauseWindowsAreResizing,
	ImGuiDockNodeState_HostWindowVisible,
}
enum : ImGuiDockNodeState {
	ImGuiDockNodeState_Unknown = ImGuiDockNodeState.ImGuiDockNodeState_Unknown,
	ImGuiDockNodeState_HostWindowHiddenBecauseSingleWindow = ImGuiDockNodeState.ImGuiDockNodeState_HostWindowHiddenBecauseSingleWindow,
	ImGuiDockNodeState_HostWindowHiddenBecauseWindowsAreResizing = ImGuiDockNodeState.ImGuiDockNodeState_HostWindowHiddenBecauseWindowsAreResizing,
	ImGuiDockNodeState_HostWindowVisible = ImGuiDockNodeState.ImGuiDockNodeState_HostWindowVisible,
}
enum ImGuiDragDropFlags_ {
	ImGuiDragDropFlags_None = 0,
	ImGuiDragDropFlags_SourceNoPreviewTooltip = 1 << 0,
	ImGuiDragDropFlags_SourceNoDisableHover = 1 << 1,
	ImGuiDragDropFlags_SourceNoHoldToOpenOthers = 1 << 2,
	ImGuiDragDropFlags_SourceAllowNullID = 1 << 3,
	ImGuiDragDropFlags_SourceExtern = 1 << 4,
	ImGuiDragDropFlags_PayloadAutoExpire = 1 << 5,
	ImGuiDragDropFlags_PayloadNoCrossContext = 1 << 6,
	ImGuiDragDropFlags_PayloadNoCrossProcess = 1 << 7,
	ImGuiDragDropFlags_AcceptBeforeDelivery = 1 << 10,
	ImGuiDragDropFlags_AcceptNoDrawDefaultRect = 1 << 11,
	ImGuiDragDropFlags_AcceptNoPreviewTooltip = 1 << 12,
	ImGuiDragDropFlags_AcceptPeekOnly = ImGuiDragDropFlags_AcceptBeforeDelivery | ImGuiDragDropFlags_AcceptNoDrawDefaultRect,
}
enum : ImGuiDragDropFlags_ {
	ImGuiDragDropFlags_None = ImGuiDragDropFlags_.ImGuiDragDropFlags_None,
	ImGuiDragDropFlags_SourceNoPreviewTooltip = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceNoPreviewTooltip,
	ImGuiDragDropFlags_SourceNoDisableHover = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceNoDisableHover,
	ImGuiDragDropFlags_SourceNoHoldToOpenOthers = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceNoHoldToOpenOthers,
	ImGuiDragDropFlags_SourceAllowNullID = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceAllowNullID,
	ImGuiDragDropFlags_SourceExtern = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceExtern,
	ImGuiDragDropFlags_PayloadAutoExpire = ImGuiDragDropFlags_.ImGuiDragDropFlags_PayloadAutoExpire,
	ImGuiDragDropFlags_PayloadNoCrossContext = ImGuiDragDropFlags_.ImGuiDragDropFlags_PayloadNoCrossContext,
	ImGuiDragDropFlags_PayloadNoCrossProcess = ImGuiDragDropFlags_.ImGuiDragDropFlags_PayloadNoCrossProcess,
	ImGuiDragDropFlags_AcceptBeforeDelivery = ImGuiDragDropFlags_.ImGuiDragDropFlags_AcceptBeforeDelivery,
	ImGuiDragDropFlags_AcceptNoDrawDefaultRect = ImGuiDragDropFlags_.ImGuiDragDropFlags_AcceptNoDrawDefaultRect,
	ImGuiDragDropFlags_AcceptNoPreviewTooltip = ImGuiDragDropFlags_.ImGuiDragDropFlags_AcceptNoPreviewTooltip,
	ImGuiDragDropFlags_AcceptPeekOnly = ImGuiDragDropFlags_.ImGuiDragDropFlags_AcceptPeekOnly,
}
enum ImGuiFocusRequestFlags_ {
	ImGuiFocusRequestFlags_None = 0,
	ImGuiFocusRequestFlags_RestoreFocusedChild = 1 << 0,
	ImGuiFocusRequestFlags_UnlessBelowModal = 1 << 1,
}
enum : ImGuiFocusRequestFlags_ {
	ImGuiFocusRequestFlags_None = ImGuiFocusRequestFlags_.ImGuiFocusRequestFlags_None,
	ImGuiFocusRequestFlags_RestoreFocusedChild = ImGuiFocusRequestFlags_.ImGuiFocusRequestFlags_RestoreFocusedChild,
	ImGuiFocusRequestFlags_UnlessBelowModal = ImGuiFocusRequestFlags_.ImGuiFocusRequestFlags_UnlessBelowModal,
}
enum ImGuiFocusedFlags_ {
	ImGuiFocusedFlags_None = 0,
	ImGuiFocusedFlags_ChildWindows = 1 << 0,
	ImGuiFocusedFlags_RootWindow = 1 << 1,
	ImGuiFocusedFlags_AnyWindow = 1 << 2,
	ImGuiFocusedFlags_NoPopupHierarchy = 1 << 3,
	ImGuiFocusedFlags_DockHierarchy = 1 << 4,
	ImGuiFocusedFlags_RootAndChildWindows = ImGuiFocusedFlags_RootWindow | ImGuiFocusedFlags_ChildWindows,
}
enum : ImGuiFocusedFlags_ {
	ImGuiFocusedFlags_None = ImGuiFocusedFlags_.ImGuiFocusedFlags_None,
	ImGuiFocusedFlags_ChildWindows = ImGuiFocusedFlags_.ImGuiFocusedFlags_ChildWindows,
	ImGuiFocusedFlags_RootWindow = ImGuiFocusedFlags_.ImGuiFocusedFlags_RootWindow,
	ImGuiFocusedFlags_AnyWindow = ImGuiFocusedFlags_.ImGuiFocusedFlags_AnyWindow,
	ImGuiFocusedFlags_NoPopupHierarchy = ImGuiFocusedFlags_.ImGuiFocusedFlags_NoPopupHierarchy,
	ImGuiFocusedFlags_DockHierarchy = ImGuiFocusedFlags_.ImGuiFocusedFlags_DockHierarchy,
	ImGuiFocusedFlags_RootAndChildWindows = ImGuiFocusedFlags_.ImGuiFocusedFlags_RootAndChildWindows,
}
enum ImGuiHoveredFlagsPrivate_ {
	ImGuiHoveredFlags_DelayMask_ = cast(uint)ImGuiHoveredFlags_DelayNone | ImGuiHoveredFlags_DelayShort | ImGuiHoveredFlags_DelayNormal | ImGuiHoveredFlags_NoSharedDelay,
	ImGuiHoveredFlags_AllowedMaskForIsWindowHovered = ImGuiHoveredFlags_ChildWindows | ImGuiHoveredFlags_RootWindow | ImGuiHoveredFlags_AnyWindow | ImGuiHoveredFlags_NoPopupHierarchy | ImGuiHoveredFlags_DockHierarchy | ImGuiHoveredFlags_AllowWhenBlockedByPopup | ImGuiHoveredFlags_AllowWhenBlockedByActiveItem | ImGuiHoveredFlags_ForTooltip | ImGuiHoveredFlags_Stationary,
	ImGuiHoveredFlags_AllowedMaskForIsItemHovered = ImGuiHoveredFlags_AllowWhenBlockedByPopup | ImGuiHoveredFlags_AllowWhenBlockedByActiveItem | ImGuiHoveredFlags_AllowWhenOverlapped | ImGuiHoveredFlags_AllowWhenDisabled | ImGuiHoveredFlags_NoNavOverride | ImGuiHoveredFlags_ForTooltip | ImGuiHoveredFlags_Stationary | ImGuiHoveredFlags_DelayMask_,
}
enum : ImGuiHoveredFlagsPrivate_ {
	ImGuiHoveredFlags_DelayMask_ = ImGuiHoveredFlagsPrivate_.ImGuiHoveredFlags_DelayMask_,
	ImGuiHoveredFlags_AllowedMaskForIsWindowHovered = ImGuiHoveredFlagsPrivate_.ImGuiHoveredFlags_AllowedMaskForIsWindowHovered,
	ImGuiHoveredFlags_AllowedMaskForIsItemHovered = ImGuiHoveredFlagsPrivate_.ImGuiHoveredFlags_AllowedMaskForIsItemHovered,
}
enum ImGuiHoveredFlags_ {
	ImGuiHoveredFlags_None = 0,
	ImGuiHoveredFlags_ChildWindows = 1 << 0,
	ImGuiHoveredFlags_RootWindow = 1 << 1,
	ImGuiHoveredFlags_AnyWindow = 1 << 2,
	ImGuiHoveredFlags_NoPopupHierarchy = 1 << 3,
	ImGuiHoveredFlags_DockHierarchy = 1 << 4,
	ImGuiHoveredFlags_AllowWhenBlockedByPopup = 1 << 5,
	ImGuiHoveredFlags_AllowWhenBlockedByActiveItem = 1 << 7,
	ImGuiHoveredFlags_AllowWhenOverlappedByItem = 1 << 8,
	ImGuiHoveredFlags_AllowWhenOverlappedByWindow = 1 << 9,
	ImGuiHoveredFlags_AllowWhenDisabled = 1 << 10,
	ImGuiHoveredFlags_NoNavOverride = 1 << 11,
	ImGuiHoveredFlags_AllowWhenOverlapped = ImGuiHoveredFlags_AllowWhenOverlappedByItem | ImGuiHoveredFlags_AllowWhenOverlappedByWindow,
	ImGuiHoveredFlags_RectOnly = ImGuiHoveredFlags_AllowWhenBlockedByPopup | ImGuiHoveredFlags_AllowWhenBlockedByActiveItem | ImGuiHoveredFlags_AllowWhenOverlapped,
	ImGuiHoveredFlags_RootAndChildWindows = ImGuiHoveredFlags_RootWindow | ImGuiHoveredFlags_ChildWindows,
	ImGuiHoveredFlags_ForTooltip = 1 << 12,
	ImGuiHoveredFlags_Stationary = 1 << 13,
	ImGuiHoveredFlags_DelayNone = 1 << 14,
	ImGuiHoveredFlags_DelayShort = 1 << 15,
	ImGuiHoveredFlags_DelayNormal = 1 << 16,
	ImGuiHoveredFlags_NoSharedDelay = 1 << 17,
}
enum : ImGuiHoveredFlags_ {
	ImGuiHoveredFlags_None = ImGuiHoveredFlags_.ImGuiHoveredFlags_None,
	ImGuiHoveredFlags_ChildWindows = ImGuiHoveredFlags_.ImGuiHoveredFlags_ChildWindows,
	ImGuiHoveredFlags_RootWindow = ImGuiHoveredFlags_.ImGuiHoveredFlags_RootWindow,
	ImGuiHoveredFlags_AnyWindow = ImGuiHoveredFlags_.ImGuiHoveredFlags_AnyWindow,
	ImGuiHoveredFlags_NoPopupHierarchy = ImGuiHoveredFlags_.ImGuiHoveredFlags_NoPopupHierarchy,
	ImGuiHoveredFlags_DockHierarchy = ImGuiHoveredFlags_.ImGuiHoveredFlags_DockHierarchy,
	ImGuiHoveredFlags_AllowWhenBlockedByPopup = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenBlockedByPopup,
	ImGuiHoveredFlags_AllowWhenBlockedByActiveItem = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenBlockedByActiveItem,
	ImGuiHoveredFlags_AllowWhenOverlappedByItem = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenOverlappedByItem,
	ImGuiHoveredFlags_AllowWhenOverlappedByWindow = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenOverlappedByWindow,
	ImGuiHoveredFlags_AllowWhenDisabled = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenDisabled,
	ImGuiHoveredFlags_NoNavOverride = ImGuiHoveredFlags_.ImGuiHoveredFlags_NoNavOverride,
	ImGuiHoveredFlags_AllowWhenOverlapped = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenOverlapped,
	ImGuiHoveredFlags_RectOnly = ImGuiHoveredFlags_.ImGuiHoveredFlags_RectOnly,
	ImGuiHoveredFlags_RootAndChildWindows = ImGuiHoveredFlags_.ImGuiHoveredFlags_RootAndChildWindows,
	ImGuiHoveredFlags_ForTooltip = ImGuiHoveredFlags_.ImGuiHoveredFlags_ForTooltip,
	ImGuiHoveredFlags_Stationary = ImGuiHoveredFlags_.ImGuiHoveredFlags_Stationary,
	ImGuiHoveredFlags_DelayNone = ImGuiHoveredFlags_.ImGuiHoveredFlags_DelayNone,
	ImGuiHoveredFlags_DelayShort = ImGuiHoveredFlags_.ImGuiHoveredFlags_DelayShort,
	ImGuiHoveredFlags_DelayNormal = ImGuiHoveredFlags_.ImGuiHoveredFlags_DelayNormal,
	ImGuiHoveredFlags_NoSharedDelay = ImGuiHoveredFlags_.ImGuiHoveredFlags_NoSharedDelay,
}
enum ImGuiInputEventType {
	ImGuiInputEventType_None = 0,
	ImGuiInputEventType_MousePos,
	ImGuiInputEventType_MouseWheel,
	ImGuiInputEventType_MouseButton,
	ImGuiInputEventType_MouseViewport,
	ImGuiInputEventType_Key,
	ImGuiInputEventType_Text,
	ImGuiInputEventType_Focus,
	ImGuiInputEventType_COUNT,
}
enum : ImGuiInputEventType {
	ImGuiInputEventType_None = ImGuiInputEventType.ImGuiInputEventType_None,
	ImGuiInputEventType_MousePos = ImGuiInputEventType.ImGuiInputEventType_MousePos,
	ImGuiInputEventType_MouseWheel = ImGuiInputEventType.ImGuiInputEventType_MouseWheel,
	ImGuiInputEventType_MouseButton = ImGuiInputEventType.ImGuiInputEventType_MouseButton,
	ImGuiInputEventType_MouseViewport = ImGuiInputEventType.ImGuiInputEventType_MouseViewport,
	ImGuiInputEventType_Key = ImGuiInputEventType.ImGuiInputEventType_Key,
	ImGuiInputEventType_Text = ImGuiInputEventType.ImGuiInputEventType_Text,
	ImGuiInputEventType_Focus = ImGuiInputEventType.ImGuiInputEventType_Focus,
	ImGuiInputEventType_COUNT = ImGuiInputEventType.ImGuiInputEventType_COUNT,
}
enum ImGuiInputFlagsPrivate_ {
	ImGuiInputFlags_RepeatRateDefault = 1 << 1,
	ImGuiInputFlags_RepeatRateNavMove = 1 << 2,
	ImGuiInputFlags_RepeatRateNavTweak = 1 << 3,
	ImGuiInputFlags_RepeatUntilRelease = 1 << 4,
	ImGuiInputFlags_RepeatUntilKeyModsChange = 1 << 5,
	ImGuiInputFlags_RepeatUntilKeyModsChangeFromNone = 1 << 6,
	ImGuiInputFlags_RepeatUntilOtherKeyPress = 1 << 7,
	ImGuiInputFlags_LockThisFrame = 1 << 20,
	ImGuiInputFlags_LockUntilRelease = 1 << 21,
	ImGuiInputFlags_CondHovered = 1 << 22,
	ImGuiInputFlags_CondActive = 1 << 23,
	ImGuiInputFlags_CondDefault_ = ImGuiInputFlags_CondHovered | ImGuiInputFlags_CondActive,
	ImGuiInputFlags_RepeatRateMask_ = ImGuiInputFlags_RepeatRateDefault | ImGuiInputFlags_RepeatRateNavMove | ImGuiInputFlags_RepeatRateNavTweak,
	ImGuiInputFlags_RepeatUntilMask_ = ImGuiInputFlags_RepeatUntilRelease | ImGuiInputFlags_RepeatUntilKeyModsChange | ImGuiInputFlags_RepeatUntilKeyModsChangeFromNone | ImGuiInputFlags_RepeatUntilOtherKeyPress,
	ImGuiInputFlags_RepeatMask_ = ImGuiInputFlags_Repeat | ImGuiInputFlags_RepeatRateMask_ | ImGuiInputFlags_RepeatUntilMask_,
	ImGuiInputFlags_CondMask_ = ImGuiInputFlags_CondHovered | ImGuiInputFlags_CondActive,
	ImGuiInputFlags_RouteTypeMask_ = ImGuiInputFlags_RouteActive | ImGuiInputFlags_RouteFocused | ImGuiInputFlags_RouteGlobal | ImGuiInputFlags_RouteAlways,
	ImGuiInputFlags_RouteOptionsMask_ = ImGuiInputFlags_RouteOverFocused | ImGuiInputFlags_RouteOverActive | ImGuiInputFlags_RouteUnlessBgFocused | ImGuiInputFlags_RouteFromRootWindow,
	ImGuiInputFlags_SupportedByIsKeyPressed = ImGuiInputFlags_RepeatMask_,
	ImGuiInputFlags_SupportedByIsMouseClicked = ImGuiInputFlags_Repeat,
	ImGuiInputFlags_SupportedByShortcut = ImGuiInputFlags_RepeatMask_ | ImGuiInputFlags_RouteTypeMask_ | ImGuiInputFlags_RouteOptionsMask_,
	ImGuiInputFlags_SupportedBySetNextItemShortcut = ImGuiInputFlags_RepeatMask_ | ImGuiInputFlags_RouteTypeMask_ | ImGuiInputFlags_RouteOptionsMask_ | ImGuiInputFlags_Tooltip,
	ImGuiInputFlags_SupportedBySetKeyOwner = ImGuiInputFlags_LockThisFrame | ImGuiInputFlags_LockUntilRelease,
	ImGuiInputFlags_SupportedBySetItemKeyOwner = ImGuiInputFlags_SupportedBySetKeyOwner | ImGuiInputFlags_CondMask_,
}
enum : ImGuiInputFlagsPrivate_ {
	ImGuiInputFlags_RepeatRateDefault = ImGuiInputFlagsPrivate_.ImGuiInputFlags_RepeatRateDefault,
	ImGuiInputFlags_RepeatRateNavMove = ImGuiInputFlagsPrivate_.ImGuiInputFlags_RepeatRateNavMove,
	ImGuiInputFlags_RepeatRateNavTweak = ImGuiInputFlagsPrivate_.ImGuiInputFlags_RepeatRateNavTweak,
	ImGuiInputFlags_RepeatUntilRelease = ImGuiInputFlagsPrivate_.ImGuiInputFlags_RepeatUntilRelease,
	ImGuiInputFlags_RepeatUntilKeyModsChange = ImGuiInputFlagsPrivate_.ImGuiInputFlags_RepeatUntilKeyModsChange,
	ImGuiInputFlags_RepeatUntilKeyModsChangeFromNone = ImGuiInputFlagsPrivate_.ImGuiInputFlags_RepeatUntilKeyModsChangeFromNone,
	ImGuiInputFlags_RepeatUntilOtherKeyPress = ImGuiInputFlagsPrivate_.ImGuiInputFlags_RepeatUntilOtherKeyPress,
	ImGuiInputFlags_LockThisFrame = ImGuiInputFlagsPrivate_.ImGuiInputFlags_LockThisFrame,
	ImGuiInputFlags_LockUntilRelease = ImGuiInputFlagsPrivate_.ImGuiInputFlags_LockUntilRelease,
	ImGuiInputFlags_CondHovered = ImGuiInputFlagsPrivate_.ImGuiInputFlags_CondHovered,
	ImGuiInputFlags_CondActive = ImGuiInputFlagsPrivate_.ImGuiInputFlags_CondActive,
	ImGuiInputFlags_CondDefault_ = ImGuiInputFlagsPrivate_.ImGuiInputFlags_CondDefault_,
	ImGuiInputFlags_RepeatRateMask_ = ImGuiInputFlagsPrivate_.ImGuiInputFlags_RepeatRateMask_,
	ImGuiInputFlags_RepeatUntilMask_ = ImGuiInputFlagsPrivate_.ImGuiInputFlags_RepeatUntilMask_,
	ImGuiInputFlags_RepeatMask_ = ImGuiInputFlagsPrivate_.ImGuiInputFlags_RepeatMask_,
	ImGuiInputFlags_CondMask_ = ImGuiInputFlagsPrivate_.ImGuiInputFlags_CondMask_,
	ImGuiInputFlags_RouteTypeMask_ = ImGuiInputFlagsPrivate_.ImGuiInputFlags_RouteTypeMask_,
	ImGuiInputFlags_RouteOptionsMask_ = ImGuiInputFlagsPrivate_.ImGuiInputFlags_RouteOptionsMask_,
	ImGuiInputFlags_SupportedByIsKeyPressed = ImGuiInputFlagsPrivate_.ImGuiInputFlags_SupportedByIsKeyPressed,
	ImGuiInputFlags_SupportedByIsMouseClicked = ImGuiInputFlagsPrivate_.ImGuiInputFlags_SupportedByIsMouseClicked,
	ImGuiInputFlags_SupportedByShortcut = ImGuiInputFlagsPrivate_.ImGuiInputFlags_SupportedByShortcut,
	ImGuiInputFlags_SupportedBySetNextItemShortcut = ImGuiInputFlagsPrivate_.ImGuiInputFlags_SupportedBySetNextItemShortcut,
	ImGuiInputFlags_SupportedBySetKeyOwner = ImGuiInputFlagsPrivate_.ImGuiInputFlags_SupportedBySetKeyOwner,
	ImGuiInputFlags_SupportedBySetItemKeyOwner = ImGuiInputFlagsPrivate_.ImGuiInputFlags_SupportedBySetItemKeyOwner,
}
enum ImGuiInputFlags_ {
	ImGuiInputFlags_None = 0,
	ImGuiInputFlags_Repeat = 1 << 0,
	ImGuiInputFlags_RouteActive = 1 << 10,
	ImGuiInputFlags_RouteFocused = 1 << 11,
	ImGuiInputFlags_RouteGlobal = 1 << 12,
	ImGuiInputFlags_RouteAlways = 1 << 13,
	ImGuiInputFlags_RouteOverFocused = 1 << 14,
	ImGuiInputFlags_RouteOverActive = 1 << 15,
	ImGuiInputFlags_RouteUnlessBgFocused = 1 << 16,
	ImGuiInputFlags_RouteFromRootWindow = 1 << 17,
	ImGuiInputFlags_Tooltip = 1 << 18,
}
enum : ImGuiInputFlags_ {
	ImGuiInputFlags_None = ImGuiInputFlags_.ImGuiInputFlags_None,
	ImGuiInputFlags_Repeat = ImGuiInputFlags_.ImGuiInputFlags_Repeat,
	ImGuiInputFlags_RouteActive = ImGuiInputFlags_.ImGuiInputFlags_RouteActive,
	ImGuiInputFlags_RouteFocused = ImGuiInputFlags_.ImGuiInputFlags_RouteFocused,
	ImGuiInputFlags_RouteGlobal = ImGuiInputFlags_.ImGuiInputFlags_RouteGlobal,
	ImGuiInputFlags_RouteAlways = ImGuiInputFlags_.ImGuiInputFlags_RouteAlways,
	ImGuiInputFlags_RouteOverFocused = ImGuiInputFlags_.ImGuiInputFlags_RouteOverFocused,
	ImGuiInputFlags_RouteOverActive = ImGuiInputFlags_.ImGuiInputFlags_RouteOverActive,
	ImGuiInputFlags_RouteUnlessBgFocused = ImGuiInputFlags_.ImGuiInputFlags_RouteUnlessBgFocused,
	ImGuiInputFlags_RouteFromRootWindow = ImGuiInputFlags_.ImGuiInputFlags_RouteFromRootWindow,
	ImGuiInputFlags_Tooltip = ImGuiInputFlags_.ImGuiInputFlags_Tooltip,
}
enum ImGuiInputSource {
	ImGuiInputSource_None = 0,
	ImGuiInputSource_Mouse,
	ImGuiInputSource_Keyboard,
	ImGuiInputSource_Gamepad,
	ImGuiInputSource_COUNT,
}
enum : ImGuiInputSource {
	ImGuiInputSource_None = ImGuiInputSource.ImGuiInputSource_None,
	ImGuiInputSource_Mouse = ImGuiInputSource.ImGuiInputSource_Mouse,
	ImGuiInputSource_Keyboard = ImGuiInputSource.ImGuiInputSource_Keyboard,
	ImGuiInputSource_Gamepad = ImGuiInputSource.ImGuiInputSource_Gamepad,
	ImGuiInputSource_COUNT = ImGuiInputSource.ImGuiInputSource_COUNT,
}
enum ImGuiInputTextFlagsPrivate_ {
	ImGuiInputTextFlags_Multiline = 1 << 26,
	ImGuiInputTextFlags_NoMarkEdited = 1 << 27,
	ImGuiInputTextFlags_MergedItem = 1 << 28,
	ImGuiInputTextFlags_LocalizeDecimalPoint = 1 << 29,
}
enum : ImGuiInputTextFlagsPrivate_ {
	ImGuiInputTextFlags_Multiline = ImGuiInputTextFlagsPrivate_.ImGuiInputTextFlags_Multiline,
	ImGuiInputTextFlags_NoMarkEdited = ImGuiInputTextFlagsPrivate_.ImGuiInputTextFlags_NoMarkEdited,
	ImGuiInputTextFlags_MergedItem = ImGuiInputTextFlagsPrivate_.ImGuiInputTextFlags_MergedItem,
	ImGuiInputTextFlags_LocalizeDecimalPoint = ImGuiInputTextFlagsPrivate_.ImGuiInputTextFlags_LocalizeDecimalPoint,
}
enum ImGuiInputTextFlags_ {
	ImGuiInputTextFlags_None = 0,
	ImGuiInputTextFlags_CharsDecimal = 1 << 0,
	ImGuiInputTextFlags_CharsHexadecimal = 1 << 1,
	ImGuiInputTextFlags_CharsScientific = 1 << 2,
	ImGuiInputTextFlags_CharsUppercase = 1 << 3,
	ImGuiInputTextFlags_CharsNoBlank = 1 << 4,
	ImGuiInputTextFlags_AllowTabInput = 1 << 5,
	ImGuiInputTextFlags_EnterReturnsTrue = 1 << 6,
	ImGuiInputTextFlags_EscapeClearsAll = 1 << 7,
	ImGuiInputTextFlags_CtrlEnterForNewLine = 1 << 8,
	ImGuiInputTextFlags_ReadOnly = 1 << 9,
	ImGuiInputTextFlags_Password = 1 << 10,
	ImGuiInputTextFlags_AlwaysOverwrite = 1 << 11,
	ImGuiInputTextFlags_AutoSelectAll = 1 << 12,
	ImGuiInputTextFlags_ParseEmptyRefVal = 1 << 13,
	ImGuiInputTextFlags_DisplayEmptyRefVal = 1 << 14,
	ImGuiInputTextFlags_NoHorizontalScroll = 1 << 15,
	ImGuiInputTextFlags_NoUndoRedo = 1 << 16,
	ImGuiInputTextFlags_CallbackCompletion = 1 << 17,
	ImGuiInputTextFlags_CallbackHistory = 1 << 18,
	ImGuiInputTextFlags_CallbackAlways = 1 << 19,
	ImGuiInputTextFlags_CallbackCharFilter = 1 << 20,
	ImGuiInputTextFlags_CallbackResize = 1 << 21,
	ImGuiInputTextFlags_CallbackEdit = 1 << 22,
}
enum : ImGuiInputTextFlags_ {
	ImGuiInputTextFlags_None = ImGuiInputTextFlags_.ImGuiInputTextFlags_None,
	ImGuiInputTextFlags_CharsDecimal = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsDecimal,
	ImGuiInputTextFlags_CharsHexadecimal = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsHexadecimal,
	ImGuiInputTextFlags_CharsScientific = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsScientific,
	ImGuiInputTextFlags_CharsUppercase = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsUppercase,
	ImGuiInputTextFlags_CharsNoBlank = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsNoBlank,
	ImGuiInputTextFlags_AllowTabInput = ImGuiInputTextFlags_.ImGuiInputTextFlags_AllowTabInput,
	ImGuiInputTextFlags_EnterReturnsTrue = ImGuiInputTextFlags_.ImGuiInputTextFlags_EnterReturnsTrue,
	ImGuiInputTextFlags_EscapeClearsAll = ImGuiInputTextFlags_.ImGuiInputTextFlags_EscapeClearsAll,
	ImGuiInputTextFlags_CtrlEnterForNewLine = ImGuiInputTextFlags_.ImGuiInputTextFlags_CtrlEnterForNewLine,
	ImGuiInputTextFlags_ReadOnly = ImGuiInputTextFlags_.ImGuiInputTextFlags_ReadOnly,
	ImGuiInputTextFlags_Password = ImGuiInputTextFlags_.ImGuiInputTextFlags_Password,
	ImGuiInputTextFlags_AlwaysOverwrite = ImGuiInputTextFlags_.ImGuiInputTextFlags_AlwaysOverwrite,
	ImGuiInputTextFlags_AutoSelectAll = ImGuiInputTextFlags_.ImGuiInputTextFlags_AutoSelectAll,
	ImGuiInputTextFlags_ParseEmptyRefVal = ImGuiInputTextFlags_.ImGuiInputTextFlags_ParseEmptyRefVal,
	ImGuiInputTextFlags_DisplayEmptyRefVal = ImGuiInputTextFlags_.ImGuiInputTextFlags_DisplayEmptyRefVal,
	ImGuiInputTextFlags_NoHorizontalScroll = ImGuiInputTextFlags_.ImGuiInputTextFlags_NoHorizontalScroll,
	ImGuiInputTextFlags_NoUndoRedo = ImGuiInputTextFlags_.ImGuiInputTextFlags_NoUndoRedo,
	ImGuiInputTextFlags_CallbackCompletion = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackCompletion,
	ImGuiInputTextFlags_CallbackHistory = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackHistory,
	ImGuiInputTextFlags_CallbackAlways = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackAlways,
	ImGuiInputTextFlags_CallbackCharFilter = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackCharFilter,
	ImGuiInputTextFlags_CallbackResize = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackResize,
	ImGuiInputTextFlags_CallbackEdit = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackEdit,
}
enum ImGuiItemFlagsPrivate_ {
	ImGuiItemFlags_Disabled = 1 << 10,
	ImGuiItemFlags_ReadOnly = 1 << 11,
	ImGuiItemFlags_MixedValue = 1 << 12,
	ImGuiItemFlags_NoWindowHoverableCheck = 1 << 13,
	ImGuiItemFlags_AllowOverlap = 1 << 14,
	ImGuiItemFlags_Inputable = 1 << 20,
	ImGuiItemFlags_HasSelectionUserData = 1 << 21,
	ImGuiItemFlags_IsMultiSelect = 1 << 22,
	ImGuiItemFlags_Default_ = ImGuiItemFlags_AutoClosePopups,
}
enum : ImGuiItemFlagsPrivate_ {
	ImGuiItemFlags_Disabled = ImGuiItemFlagsPrivate_.ImGuiItemFlags_Disabled,
	ImGuiItemFlags_ReadOnly = ImGuiItemFlagsPrivate_.ImGuiItemFlags_ReadOnly,
	ImGuiItemFlags_MixedValue = ImGuiItemFlagsPrivate_.ImGuiItemFlags_MixedValue,
	ImGuiItemFlags_NoWindowHoverableCheck = ImGuiItemFlagsPrivate_.ImGuiItemFlags_NoWindowHoverableCheck,
	ImGuiItemFlags_AllowOverlap = ImGuiItemFlagsPrivate_.ImGuiItemFlags_AllowOverlap,
	ImGuiItemFlags_Inputable = ImGuiItemFlagsPrivate_.ImGuiItemFlags_Inputable,
	ImGuiItemFlags_HasSelectionUserData = ImGuiItemFlagsPrivate_.ImGuiItemFlags_HasSelectionUserData,
	ImGuiItemFlags_IsMultiSelect = ImGuiItemFlagsPrivate_.ImGuiItemFlags_IsMultiSelect,
	ImGuiItemFlags_Default_ = ImGuiItemFlagsPrivate_.ImGuiItemFlags_Default_,
}
enum ImGuiItemFlags_ {
	ImGuiItemFlags_None = 0,
	ImGuiItemFlags_NoTabStop = 1 << 0,
	ImGuiItemFlags_NoNav = 1 << 1,
	ImGuiItemFlags_NoNavDefaultFocus = 1 << 2,
	ImGuiItemFlags_ButtonRepeat = 1 << 3,
	ImGuiItemFlags_AutoClosePopups = 1 << 4,
}
enum : ImGuiItemFlags_ {
	ImGuiItemFlags_None = ImGuiItemFlags_.ImGuiItemFlags_None,
	ImGuiItemFlags_NoTabStop = ImGuiItemFlags_.ImGuiItemFlags_NoTabStop,
	ImGuiItemFlags_NoNav = ImGuiItemFlags_.ImGuiItemFlags_NoNav,
	ImGuiItemFlags_NoNavDefaultFocus = ImGuiItemFlags_.ImGuiItemFlags_NoNavDefaultFocus,
	ImGuiItemFlags_ButtonRepeat = ImGuiItemFlags_.ImGuiItemFlags_ButtonRepeat,
	ImGuiItemFlags_AutoClosePopups = ImGuiItemFlags_.ImGuiItemFlags_AutoClosePopups,
}
enum ImGuiItemStatusFlags_ {
	ImGuiItemStatusFlags_None = 0,
	ImGuiItemStatusFlags_HoveredRect = 1 << 0,
	ImGuiItemStatusFlags_HasDisplayRect = 1 << 1,
	ImGuiItemStatusFlags_Edited = 1 << 2,
	ImGuiItemStatusFlags_ToggledSelection = 1 << 3,
	ImGuiItemStatusFlags_ToggledOpen = 1 << 4,
	ImGuiItemStatusFlags_HasDeactivated = 1 << 5,
	ImGuiItemStatusFlags_Deactivated = 1 << 6,
	ImGuiItemStatusFlags_HoveredWindow = 1 << 7,
	ImGuiItemStatusFlags_Visible = 1 << 8,
	ImGuiItemStatusFlags_HasClipRect = 1 << 9,
	ImGuiItemStatusFlags_HasShortcut = 1 << 10,
}
enum : ImGuiItemStatusFlags_ {
	ImGuiItemStatusFlags_None = ImGuiItemStatusFlags_.ImGuiItemStatusFlags_None,
	ImGuiItemStatusFlags_HoveredRect = ImGuiItemStatusFlags_.ImGuiItemStatusFlags_HoveredRect,
	ImGuiItemStatusFlags_HasDisplayRect = ImGuiItemStatusFlags_.ImGuiItemStatusFlags_HasDisplayRect,
	ImGuiItemStatusFlags_Edited = ImGuiItemStatusFlags_.ImGuiItemStatusFlags_Edited,
	ImGuiItemStatusFlags_ToggledSelection = ImGuiItemStatusFlags_.ImGuiItemStatusFlags_ToggledSelection,
	ImGuiItemStatusFlags_ToggledOpen = ImGuiItemStatusFlags_.ImGuiItemStatusFlags_ToggledOpen,
	ImGuiItemStatusFlags_HasDeactivated = ImGuiItemStatusFlags_.ImGuiItemStatusFlags_HasDeactivated,
	ImGuiItemStatusFlags_Deactivated = ImGuiItemStatusFlags_.ImGuiItemStatusFlags_Deactivated,
	ImGuiItemStatusFlags_HoveredWindow = ImGuiItemStatusFlags_.ImGuiItemStatusFlags_HoveredWindow,
	ImGuiItemStatusFlags_Visible = ImGuiItemStatusFlags_.ImGuiItemStatusFlags_Visible,
	ImGuiItemStatusFlags_HasClipRect = ImGuiItemStatusFlags_.ImGuiItemStatusFlags_HasClipRect,
	ImGuiItemStatusFlags_HasShortcut = ImGuiItemStatusFlags_.ImGuiItemStatusFlags_HasShortcut,
}
enum ImGuiKey {
	ImGuiKey_None = 0,
	ImGuiKey_Tab = 512,
	ImGuiKey_LeftArrow = 513,
	ImGuiKey_RightArrow = 514,
	ImGuiKey_UpArrow = 515,
	ImGuiKey_DownArrow = 516,
	ImGuiKey_PageUp = 517,
	ImGuiKey_PageDown = 518,
	ImGuiKey_Home = 519,
	ImGuiKey_End = 520,
	ImGuiKey_Insert = 521,
	ImGuiKey_Delete = 522,
	ImGuiKey_Backspace = 523,
	ImGuiKey_Space = 524,
	ImGuiKey_Enter = 525,
	ImGuiKey_Escape = 526,
	ImGuiKey_LeftCtrl = 527,
	ImGuiKey_LeftShift = 528,
	ImGuiKey_LeftAlt = 529,
	ImGuiKey_LeftSuper = 530,
	ImGuiKey_RightCtrl = 531,
	ImGuiKey_RightShift = 532,
	ImGuiKey_RightAlt = 533,
	ImGuiKey_RightSuper = 534,
	ImGuiKey_Menu = 535,
	ImGuiKey_0 = 536,
	ImGuiKey_1 = 537,
	ImGuiKey_2 = 538,
	ImGuiKey_3 = 539,
	ImGuiKey_4 = 540,
	ImGuiKey_5 = 541,
	ImGuiKey_6 = 542,
	ImGuiKey_7 = 543,
	ImGuiKey_8 = 544,
	ImGuiKey_9 = 545,
	ImGuiKey_A = 546,
	ImGuiKey_B = 547,
	ImGuiKey_C = 548,
	ImGuiKey_D = 549,
	ImGuiKey_E = 550,
	ImGuiKey_F = 551,
	ImGuiKey_G = 552,
	ImGuiKey_H = 553,
	ImGuiKey_I = 554,
	ImGuiKey_J = 555,
	ImGuiKey_K = 556,
	ImGuiKey_L = 557,
	ImGuiKey_M = 558,
	ImGuiKey_N = 559,
	ImGuiKey_O = 560,
	ImGuiKey_P = 561,
	ImGuiKey_Q = 562,
	ImGuiKey_R = 563,
	ImGuiKey_S = 564,
	ImGuiKey_T = 565,
	ImGuiKey_U = 566,
	ImGuiKey_V = 567,
	ImGuiKey_W = 568,
	ImGuiKey_X = 569,
	ImGuiKey_Y = 570,
	ImGuiKey_Z = 571,
	ImGuiKey_F1 = 572,
	ImGuiKey_F2 = 573,
	ImGuiKey_F3 = 574,
	ImGuiKey_F4 = 575,
	ImGuiKey_F5 = 576,
	ImGuiKey_F6 = 577,
	ImGuiKey_F7 = 578,
	ImGuiKey_F8 = 579,
	ImGuiKey_F9 = 580,
	ImGuiKey_F10 = 581,
	ImGuiKey_F11 = 582,
	ImGuiKey_F12 = 583,
	ImGuiKey_F13 = 584,
	ImGuiKey_F14 = 585,
	ImGuiKey_F15 = 586,
	ImGuiKey_F16 = 587,
	ImGuiKey_F17 = 588,
	ImGuiKey_F18 = 589,
	ImGuiKey_F19 = 590,
	ImGuiKey_F20 = 591,
	ImGuiKey_F21 = 592,
	ImGuiKey_F22 = 593,
	ImGuiKey_F23 = 594,
	ImGuiKey_F24 = 595,
	ImGuiKey_Apostrophe = 596,
	ImGuiKey_Comma = 597,
	ImGuiKey_Minus = 598,
	ImGuiKey_Period = 599,
	ImGuiKey_Slash = 600,
	ImGuiKey_Semicolon = 601,
	ImGuiKey_Equal = 602,
	ImGuiKey_LeftBracket = 603,
	ImGuiKey_Backslash = 604,
	ImGuiKey_RightBracket = 605,
	ImGuiKey_GraveAccent = 606,
	ImGuiKey_CapsLock = 607,
	ImGuiKey_ScrollLock = 608,
	ImGuiKey_NumLock = 609,
	ImGuiKey_PrintScreen = 610,
	ImGuiKey_Pause = 611,
	ImGuiKey_Keypad0 = 612,
	ImGuiKey_Keypad1 = 613,
	ImGuiKey_Keypad2 = 614,
	ImGuiKey_Keypad3 = 615,
	ImGuiKey_Keypad4 = 616,
	ImGuiKey_Keypad5 = 617,
	ImGuiKey_Keypad6 = 618,
	ImGuiKey_Keypad7 = 619,
	ImGuiKey_Keypad8 = 620,
	ImGuiKey_Keypad9 = 621,
	ImGuiKey_KeypadDecimal = 622,
	ImGuiKey_KeypadDivide = 623,
	ImGuiKey_KeypadMultiply = 624,
	ImGuiKey_KeypadSubtract = 625,
	ImGuiKey_KeypadAdd = 626,
	ImGuiKey_KeypadEnter = 627,
	ImGuiKey_KeypadEqual = 628,
	ImGuiKey_AppBack = 629,
	ImGuiKey_AppForward = 630,
	ImGuiKey_GamepadStart = 631,
	ImGuiKey_GamepadBack = 632,
	ImGuiKey_GamepadFaceLeft = 633,
	ImGuiKey_GamepadFaceRight = 634,
	ImGuiKey_GamepadFaceUp = 635,
	ImGuiKey_GamepadFaceDown = 636,
	ImGuiKey_GamepadDpadLeft = 637,
	ImGuiKey_GamepadDpadRight = 638,
	ImGuiKey_GamepadDpadUp = 639,
	ImGuiKey_GamepadDpadDown = 640,
	ImGuiKey_GamepadL1 = 641,
	ImGuiKey_GamepadR1 = 642,
	ImGuiKey_GamepadL2 = 643,
	ImGuiKey_GamepadR2 = 644,
	ImGuiKey_GamepadL3 = 645,
	ImGuiKey_GamepadR3 = 646,
	ImGuiKey_GamepadLStickLeft = 647,
	ImGuiKey_GamepadLStickRight = 648,
	ImGuiKey_GamepadLStickUp = 649,
	ImGuiKey_GamepadLStickDown = 650,
	ImGuiKey_GamepadRStickLeft = 651,
	ImGuiKey_GamepadRStickRight = 652,
	ImGuiKey_GamepadRStickUp = 653,
	ImGuiKey_GamepadRStickDown = 654,
	ImGuiKey_MouseLeft = 655,
	ImGuiKey_MouseRight = 656,
	ImGuiKey_MouseMiddle = 657,
	ImGuiKey_MouseX1 = 658,
	ImGuiKey_MouseX2 = 659,
	ImGuiKey_MouseWheelX = 660,
	ImGuiKey_MouseWheelY = 661,
	ImGuiKey_ReservedForModCtrl = 662,
	ImGuiKey_ReservedForModShift = 663,
	ImGuiKey_ReservedForModAlt = 664,
	ImGuiKey_ReservedForModSuper = 665,
	ImGuiKey_COUNT = 666,
	ImGuiMod_None = 0,
	ImGuiMod_Ctrl = 1 << 12,
	ImGuiMod_Shift = 1 << 13,
	ImGuiMod_Alt = 1 << 14,
	ImGuiMod_Super = 1 << 15,
	ImGuiMod_Mask_ = 0xF000,
	ImGuiKey_NamedKey_BEGIN = 512,
	ImGuiKey_NamedKey_END = ImGuiKey_COUNT,
	ImGuiKey_NamedKey_COUNT = ImGuiKey_NamedKey_END - ImGuiKey_NamedKey_BEGIN,
	ImGuiKey_KeysData_SIZE = ImGuiKey_NamedKey_COUNT,
	ImGuiKey_KeysData_OFFSET = ImGuiKey_NamedKey_BEGIN,
}
enum : ImGuiKey {
	ImGuiKey_None = ImGuiKey.ImGuiKey_None,
	ImGuiKey_Tab = ImGuiKey.ImGuiKey_Tab,
	ImGuiKey_LeftArrow = ImGuiKey.ImGuiKey_LeftArrow,
	ImGuiKey_RightArrow = ImGuiKey.ImGuiKey_RightArrow,
	ImGuiKey_UpArrow = ImGuiKey.ImGuiKey_UpArrow,
	ImGuiKey_DownArrow = ImGuiKey.ImGuiKey_DownArrow,
	ImGuiKey_PageUp = ImGuiKey.ImGuiKey_PageUp,
	ImGuiKey_PageDown = ImGuiKey.ImGuiKey_PageDown,
	ImGuiKey_Home = ImGuiKey.ImGuiKey_Home,
	ImGuiKey_End = ImGuiKey.ImGuiKey_End,
	ImGuiKey_Insert = ImGuiKey.ImGuiKey_Insert,
	ImGuiKey_Delete = ImGuiKey.ImGuiKey_Delete,
	ImGuiKey_Backspace = ImGuiKey.ImGuiKey_Backspace,
	ImGuiKey_Space = ImGuiKey.ImGuiKey_Space,
	ImGuiKey_Enter = ImGuiKey.ImGuiKey_Enter,
	ImGuiKey_Escape = ImGuiKey.ImGuiKey_Escape,
	ImGuiKey_LeftCtrl = ImGuiKey.ImGuiKey_LeftCtrl,
	ImGuiKey_LeftShift = ImGuiKey.ImGuiKey_LeftShift,
	ImGuiKey_LeftAlt = ImGuiKey.ImGuiKey_LeftAlt,
	ImGuiKey_LeftSuper = ImGuiKey.ImGuiKey_LeftSuper,
	ImGuiKey_RightCtrl = ImGuiKey.ImGuiKey_RightCtrl,
	ImGuiKey_RightShift = ImGuiKey.ImGuiKey_RightShift,
	ImGuiKey_RightAlt = ImGuiKey.ImGuiKey_RightAlt,
	ImGuiKey_RightSuper = ImGuiKey.ImGuiKey_RightSuper,
	ImGuiKey_Menu = ImGuiKey.ImGuiKey_Menu,
	ImGuiKey_0 = ImGuiKey.ImGuiKey_0,
	ImGuiKey_1 = ImGuiKey.ImGuiKey_1,
	ImGuiKey_2 = ImGuiKey.ImGuiKey_2,
	ImGuiKey_3 = ImGuiKey.ImGuiKey_3,
	ImGuiKey_4 = ImGuiKey.ImGuiKey_4,
	ImGuiKey_5 = ImGuiKey.ImGuiKey_5,
	ImGuiKey_6 = ImGuiKey.ImGuiKey_6,
	ImGuiKey_7 = ImGuiKey.ImGuiKey_7,
	ImGuiKey_8 = ImGuiKey.ImGuiKey_8,
	ImGuiKey_9 = ImGuiKey.ImGuiKey_9,
	ImGuiKey_A = ImGuiKey.ImGuiKey_A,
	ImGuiKey_B = ImGuiKey.ImGuiKey_B,
	ImGuiKey_C = ImGuiKey.ImGuiKey_C,
	ImGuiKey_D = ImGuiKey.ImGuiKey_D,
	ImGuiKey_E = ImGuiKey.ImGuiKey_E,
	ImGuiKey_F = ImGuiKey.ImGuiKey_F,
	ImGuiKey_G = ImGuiKey.ImGuiKey_G,
	ImGuiKey_H = ImGuiKey.ImGuiKey_H,
	ImGuiKey_I = ImGuiKey.ImGuiKey_I,
	ImGuiKey_J = ImGuiKey.ImGuiKey_J,
	ImGuiKey_K = ImGuiKey.ImGuiKey_K,
	ImGuiKey_L = ImGuiKey.ImGuiKey_L,
	ImGuiKey_M = ImGuiKey.ImGuiKey_M,
	ImGuiKey_N = ImGuiKey.ImGuiKey_N,
	ImGuiKey_O = ImGuiKey.ImGuiKey_O,
	ImGuiKey_P = ImGuiKey.ImGuiKey_P,
	ImGuiKey_Q = ImGuiKey.ImGuiKey_Q,
	ImGuiKey_R = ImGuiKey.ImGuiKey_R,
	ImGuiKey_S = ImGuiKey.ImGuiKey_S,
	ImGuiKey_T = ImGuiKey.ImGuiKey_T,
	ImGuiKey_U = ImGuiKey.ImGuiKey_U,
	ImGuiKey_V = ImGuiKey.ImGuiKey_V,
	ImGuiKey_W = ImGuiKey.ImGuiKey_W,
	ImGuiKey_X = ImGuiKey.ImGuiKey_X,
	ImGuiKey_Y = ImGuiKey.ImGuiKey_Y,
	ImGuiKey_Z = ImGuiKey.ImGuiKey_Z,
	ImGuiKey_F1 = ImGuiKey.ImGuiKey_F1,
	ImGuiKey_F2 = ImGuiKey.ImGuiKey_F2,
	ImGuiKey_F3 = ImGuiKey.ImGuiKey_F3,
	ImGuiKey_F4 = ImGuiKey.ImGuiKey_F4,
	ImGuiKey_F5 = ImGuiKey.ImGuiKey_F5,
	ImGuiKey_F6 = ImGuiKey.ImGuiKey_F6,
	ImGuiKey_F7 = ImGuiKey.ImGuiKey_F7,
	ImGuiKey_F8 = ImGuiKey.ImGuiKey_F8,
	ImGuiKey_F9 = ImGuiKey.ImGuiKey_F9,
	ImGuiKey_F10 = ImGuiKey.ImGuiKey_F10,
	ImGuiKey_F11 = ImGuiKey.ImGuiKey_F11,
	ImGuiKey_F12 = ImGuiKey.ImGuiKey_F12,
	ImGuiKey_F13 = ImGuiKey.ImGuiKey_F13,
	ImGuiKey_F14 = ImGuiKey.ImGuiKey_F14,
	ImGuiKey_F15 = ImGuiKey.ImGuiKey_F15,
	ImGuiKey_F16 = ImGuiKey.ImGuiKey_F16,
	ImGuiKey_F17 = ImGuiKey.ImGuiKey_F17,
	ImGuiKey_F18 = ImGuiKey.ImGuiKey_F18,
	ImGuiKey_F19 = ImGuiKey.ImGuiKey_F19,
	ImGuiKey_F20 = ImGuiKey.ImGuiKey_F20,
	ImGuiKey_F21 = ImGuiKey.ImGuiKey_F21,
	ImGuiKey_F22 = ImGuiKey.ImGuiKey_F22,
	ImGuiKey_F23 = ImGuiKey.ImGuiKey_F23,
	ImGuiKey_F24 = ImGuiKey.ImGuiKey_F24,
	ImGuiKey_Apostrophe = ImGuiKey.ImGuiKey_Apostrophe,
	ImGuiKey_Comma = ImGuiKey.ImGuiKey_Comma,
	ImGuiKey_Minus = ImGuiKey.ImGuiKey_Minus,
	ImGuiKey_Period = ImGuiKey.ImGuiKey_Period,
	ImGuiKey_Slash = ImGuiKey.ImGuiKey_Slash,
	ImGuiKey_Semicolon = ImGuiKey.ImGuiKey_Semicolon,
	ImGuiKey_Equal = ImGuiKey.ImGuiKey_Equal,
	ImGuiKey_LeftBracket = ImGuiKey.ImGuiKey_LeftBracket,
	ImGuiKey_Backslash = ImGuiKey.ImGuiKey_Backslash,
	ImGuiKey_RightBracket = ImGuiKey.ImGuiKey_RightBracket,
	ImGuiKey_GraveAccent = ImGuiKey.ImGuiKey_GraveAccent,
	ImGuiKey_CapsLock = ImGuiKey.ImGuiKey_CapsLock,
	ImGuiKey_ScrollLock = ImGuiKey.ImGuiKey_ScrollLock,
	ImGuiKey_NumLock = ImGuiKey.ImGuiKey_NumLock,
	ImGuiKey_PrintScreen = ImGuiKey.ImGuiKey_PrintScreen,
	ImGuiKey_Pause = ImGuiKey.ImGuiKey_Pause,
	ImGuiKey_Keypad0 = ImGuiKey.ImGuiKey_Keypad0,
	ImGuiKey_Keypad1 = ImGuiKey.ImGuiKey_Keypad1,
	ImGuiKey_Keypad2 = ImGuiKey.ImGuiKey_Keypad2,
	ImGuiKey_Keypad3 = ImGuiKey.ImGuiKey_Keypad3,
	ImGuiKey_Keypad4 = ImGuiKey.ImGuiKey_Keypad4,
	ImGuiKey_Keypad5 = ImGuiKey.ImGuiKey_Keypad5,
	ImGuiKey_Keypad6 = ImGuiKey.ImGuiKey_Keypad6,
	ImGuiKey_Keypad7 = ImGuiKey.ImGuiKey_Keypad7,
	ImGuiKey_Keypad8 = ImGuiKey.ImGuiKey_Keypad8,
	ImGuiKey_Keypad9 = ImGuiKey.ImGuiKey_Keypad9,
	ImGuiKey_KeypadDecimal = ImGuiKey.ImGuiKey_KeypadDecimal,
	ImGuiKey_KeypadDivide = ImGuiKey.ImGuiKey_KeypadDivide,
	ImGuiKey_KeypadMultiply = ImGuiKey.ImGuiKey_KeypadMultiply,
	ImGuiKey_KeypadSubtract = ImGuiKey.ImGuiKey_KeypadSubtract,
	ImGuiKey_KeypadAdd = ImGuiKey.ImGuiKey_KeypadAdd,
	ImGuiKey_KeypadEnter = ImGuiKey.ImGuiKey_KeypadEnter,
	ImGuiKey_KeypadEqual = ImGuiKey.ImGuiKey_KeypadEqual,
	ImGuiKey_AppBack = ImGuiKey.ImGuiKey_AppBack,
	ImGuiKey_AppForward = ImGuiKey.ImGuiKey_AppForward,
	ImGuiKey_GamepadStart = ImGuiKey.ImGuiKey_GamepadStart,
	ImGuiKey_GamepadBack = ImGuiKey.ImGuiKey_GamepadBack,
	ImGuiKey_GamepadFaceLeft = ImGuiKey.ImGuiKey_GamepadFaceLeft,
	ImGuiKey_GamepadFaceRight = ImGuiKey.ImGuiKey_GamepadFaceRight,
	ImGuiKey_GamepadFaceUp = ImGuiKey.ImGuiKey_GamepadFaceUp,
	ImGuiKey_GamepadFaceDown = ImGuiKey.ImGuiKey_GamepadFaceDown,
	ImGuiKey_GamepadDpadLeft = ImGuiKey.ImGuiKey_GamepadDpadLeft,
	ImGuiKey_GamepadDpadRight = ImGuiKey.ImGuiKey_GamepadDpadRight,
	ImGuiKey_GamepadDpadUp = ImGuiKey.ImGuiKey_GamepadDpadUp,
	ImGuiKey_GamepadDpadDown = ImGuiKey.ImGuiKey_GamepadDpadDown,
	ImGuiKey_GamepadL1 = ImGuiKey.ImGuiKey_GamepadL1,
	ImGuiKey_GamepadR1 = ImGuiKey.ImGuiKey_GamepadR1,
	ImGuiKey_GamepadL2 = ImGuiKey.ImGuiKey_GamepadL2,
	ImGuiKey_GamepadR2 = ImGuiKey.ImGuiKey_GamepadR2,
	ImGuiKey_GamepadL3 = ImGuiKey.ImGuiKey_GamepadL3,
	ImGuiKey_GamepadR3 = ImGuiKey.ImGuiKey_GamepadR3,
	ImGuiKey_GamepadLStickLeft = ImGuiKey.ImGuiKey_GamepadLStickLeft,
	ImGuiKey_GamepadLStickRight = ImGuiKey.ImGuiKey_GamepadLStickRight,
	ImGuiKey_GamepadLStickUp = ImGuiKey.ImGuiKey_GamepadLStickUp,
	ImGuiKey_GamepadLStickDown = ImGuiKey.ImGuiKey_GamepadLStickDown,
	ImGuiKey_GamepadRStickLeft = ImGuiKey.ImGuiKey_GamepadRStickLeft,
	ImGuiKey_GamepadRStickRight = ImGuiKey.ImGuiKey_GamepadRStickRight,
	ImGuiKey_GamepadRStickUp = ImGuiKey.ImGuiKey_GamepadRStickUp,
	ImGuiKey_GamepadRStickDown = ImGuiKey.ImGuiKey_GamepadRStickDown,
	ImGuiKey_MouseLeft = ImGuiKey.ImGuiKey_MouseLeft,
	ImGuiKey_MouseRight = ImGuiKey.ImGuiKey_MouseRight,
	ImGuiKey_MouseMiddle = ImGuiKey.ImGuiKey_MouseMiddle,
	ImGuiKey_MouseX1 = ImGuiKey.ImGuiKey_MouseX1,
	ImGuiKey_MouseX2 = ImGuiKey.ImGuiKey_MouseX2,
	ImGuiKey_MouseWheelX = ImGuiKey.ImGuiKey_MouseWheelX,
	ImGuiKey_MouseWheelY = ImGuiKey.ImGuiKey_MouseWheelY,
	ImGuiKey_ReservedForModCtrl = ImGuiKey.ImGuiKey_ReservedForModCtrl,
	ImGuiKey_ReservedForModShift = ImGuiKey.ImGuiKey_ReservedForModShift,
	ImGuiKey_ReservedForModAlt = ImGuiKey.ImGuiKey_ReservedForModAlt,
	ImGuiKey_ReservedForModSuper = ImGuiKey.ImGuiKey_ReservedForModSuper,
	ImGuiKey_COUNT = ImGuiKey.ImGuiKey_COUNT,
	ImGuiMod_None = ImGuiKey.ImGuiMod_None,
	ImGuiMod_Ctrl = ImGuiKey.ImGuiMod_Ctrl,
	ImGuiMod_Shift = ImGuiKey.ImGuiMod_Shift,
	ImGuiMod_Alt = ImGuiKey.ImGuiMod_Alt,
	ImGuiMod_Super = ImGuiKey.ImGuiMod_Super,
	ImGuiMod_Mask_ = ImGuiKey.ImGuiMod_Mask_,
	ImGuiKey_NamedKey_BEGIN = ImGuiKey.ImGuiKey_NamedKey_BEGIN,
	ImGuiKey_NamedKey_END = ImGuiKey.ImGuiKey_NamedKey_END,
	ImGuiKey_NamedKey_COUNT = ImGuiKey.ImGuiKey_NamedKey_COUNT,
	ImGuiKey_KeysData_SIZE = ImGuiKey.ImGuiKey_KeysData_SIZE,
	ImGuiKey_KeysData_OFFSET = ImGuiKey.ImGuiKey_KeysData_OFFSET,
}
enum ImGuiLayoutType_ {
	ImGuiLayoutType_Horizontal = 0,
	ImGuiLayoutType_Vertical = 1,
}
enum : ImGuiLayoutType_ {
	ImGuiLayoutType_Horizontal = ImGuiLayoutType_.ImGuiLayoutType_Horizontal,
	ImGuiLayoutType_Vertical = ImGuiLayoutType_.ImGuiLayoutType_Vertical,
}
enum ImGuiLocKey {
	ImGuiLocKey_VersionStr = 0,
	ImGuiLocKey_TableSizeOne = 1,
	ImGuiLocKey_TableSizeAllFit = 2,
	ImGuiLocKey_TableSizeAllDefault = 3,
	ImGuiLocKey_TableResetOrder = 4,
	ImGuiLocKey_WindowingMainMenuBar = 5,
	ImGuiLocKey_WindowingPopup = 6,
	ImGuiLocKey_WindowingUntitled = 7,
	ImGuiLocKey_CopyLink = 8,
	ImGuiLocKey_DockingHideTabBar = 9,
	ImGuiLocKey_DockingHoldShiftToDock = 10,
	ImGuiLocKey_DockingDragToUndockOrMoveNode = 11,
	ImGuiLocKey_COUNT = 12,
}
enum : ImGuiLocKey {
	ImGuiLocKey_VersionStr = ImGuiLocKey.ImGuiLocKey_VersionStr,
	ImGuiLocKey_TableSizeOne = ImGuiLocKey.ImGuiLocKey_TableSizeOne,
	ImGuiLocKey_TableSizeAllFit = ImGuiLocKey.ImGuiLocKey_TableSizeAllFit,
	ImGuiLocKey_TableSizeAllDefault = ImGuiLocKey.ImGuiLocKey_TableSizeAllDefault,
	ImGuiLocKey_TableResetOrder = ImGuiLocKey.ImGuiLocKey_TableResetOrder,
	ImGuiLocKey_WindowingMainMenuBar = ImGuiLocKey.ImGuiLocKey_WindowingMainMenuBar,
	ImGuiLocKey_WindowingPopup = ImGuiLocKey.ImGuiLocKey_WindowingPopup,
	ImGuiLocKey_WindowingUntitled = ImGuiLocKey.ImGuiLocKey_WindowingUntitled,
	ImGuiLocKey_CopyLink = ImGuiLocKey.ImGuiLocKey_CopyLink,
	ImGuiLocKey_DockingHideTabBar = ImGuiLocKey.ImGuiLocKey_DockingHideTabBar,
	ImGuiLocKey_DockingHoldShiftToDock = ImGuiLocKey.ImGuiLocKey_DockingHoldShiftToDock,
	ImGuiLocKey_DockingDragToUndockOrMoveNode = ImGuiLocKey.ImGuiLocKey_DockingDragToUndockOrMoveNode,
	ImGuiLocKey_COUNT = ImGuiLocKey.ImGuiLocKey_COUNT,
}
enum ImGuiLogType {
	ImGuiLogType_None = 0,
	ImGuiLogType_TTY,
	ImGuiLogType_File,
	ImGuiLogType_Buffer,
	ImGuiLogType_Clipboard,
}
enum : ImGuiLogType {
	ImGuiLogType_None = ImGuiLogType.ImGuiLogType_None,
	ImGuiLogType_TTY = ImGuiLogType.ImGuiLogType_TTY,
	ImGuiLogType_File = ImGuiLogType.ImGuiLogType_File,
	ImGuiLogType_Buffer = ImGuiLogType.ImGuiLogType_Buffer,
	ImGuiLogType_Clipboard = ImGuiLogType.ImGuiLogType_Clipboard,
}
enum ImGuiMouseButton_ {
	ImGuiMouseButton_Left = 0,
	ImGuiMouseButton_Right = 1,
	ImGuiMouseButton_Middle = 2,
	ImGuiMouseButton_COUNT = 5,
}
enum : ImGuiMouseButton_ {
	ImGuiMouseButton_Left = ImGuiMouseButton_.ImGuiMouseButton_Left,
	ImGuiMouseButton_Right = ImGuiMouseButton_.ImGuiMouseButton_Right,
	ImGuiMouseButton_Middle = ImGuiMouseButton_.ImGuiMouseButton_Middle,
	ImGuiMouseButton_COUNT = ImGuiMouseButton_.ImGuiMouseButton_COUNT,
}
enum ImGuiMouseCursor_ {
	ImGuiMouseCursor_None = -1,
	ImGuiMouseCursor_Arrow = 0,
	ImGuiMouseCursor_TextInput,
	ImGuiMouseCursor_ResizeAll,
	ImGuiMouseCursor_ResizeNS,
	ImGuiMouseCursor_ResizeEW,
	ImGuiMouseCursor_ResizeNESW,
	ImGuiMouseCursor_ResizeNWSE,
	ImGuiMouseCursor_Hand,
	ImGuiMouseCursor_NotAllowed,
	ImGuiMouseCursor_COUNT,
}
enum : ImGuiMouseCursor_ {
	ImGuiMouseCursor_None = ImGuiMouseCursor_.ImGuiMouseCursor_None,
	ImGuiMouseCursor_Arrow = ImGuiMouseCursor_.ImGuiMouseCursor_Arrow,
	ImGuiMouseCursor_TextInput = ImGuiMouseCursor_.ImGuiMouseCursor_TextInput,
	ImGuiMouseCursor_ResizeAll = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeAll,
	ImGuiMouseCursor_ResizeNS = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeNS,
	ImGuiMouseCursor_ResizeEW = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeEW,
	ImGuiMouseCursor_ResizeNESW = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeNESW,
	ImGuiMouseCursor_ResizeNWSE = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeNWSE,
	ImGuiMouseCursor_Hand = ImGuiMouseCursor_.ImGuiMouseCursor_Hand,
	ImGuiMouseCursor_NotAllowed = ImGuiMouseCursor_.ImGuiMouseCursor_NotAllowed,
	ImGuiMouseCursor_COUNT = ImGuiMouseCursor_.ImGuiMouseCursor_COUNT,
}
enum ImGuiMouseSource {
	ImGuiMouseSource_Mouse = 0,
	ImGuiMouseSource_TouchScreen = 1,
	ImGuiMouseSource_Pen = 2,
	ImGuiMouseSource_COUNT = 3,
}
enum : ImGuiMouseSource {
	ImGuiMouseSource_Mouse = ImGuiMouseSource.ImGuiMouseSource_Mouse,
	ImGuiMouseSource_TouchScreen = ImGuiMouseSource.ImGuiMouseSource_TouchScreen,
	ImGuiMouseSource_Pen = ImGuiMouseSource.ImGuiMouseSource_Pen,
	ImGuiMouseSource_COUNT = ImGuiMouseSource.ImGuiMouseSource_COUNT,
}
enum ImGuiMultiSelectFlags_ {
	ImGuiMultiSelectFlags_None = 0,
	ImGuiMultiSelectFlags_SingleSelect = 1 << 0,
	ImGuiMultiSelectFlags_NoSelectAll = 1 << 1,
	ImGuiMultiSelectFlags_NoRangeSelect = 1 << 2,
	ImGuiMultiSelectFlags_NoAutoSelect = 1 << 3,
	ImGuiMultiSelectFlags_NoAutoClear = 1 << 4,
	ImGuiMultiSelectFlags_NoAutoClearOnReselect = 1 << 5,
	ImGuiMultiSelectFlags_BoxSelect1d = 1 << 6,
	ImGuiMultiSelectFlags_BoxSelect2d = 1 << 7,
	ImGuiMultiSelectFlags_BoxSelectNoScroll = 1 << 8,
	ImGuiMultiSelectFlags_ClearOnEscape = 1 << 9,
	ImGuiMultiSelectFlags_ClearOnClickVoid = 1 << 10,
	ImGuiMultiSelectFlags_ScopeWindow = 1 << 11,
	ImGuiMultiSelectFlags_ScopeRect = 1 << 12,
	ImGuiMultiSelectFlags_SelectOnClick = 1 << 13,
	ImGuiMultiSelectFlags_SelectOnClickRelease = 1 << 14,
	ImGuiMultiSelectFlags_NavWrapX = 1 << 16,
}
enum : ImGuiMultiSelectFlags_ {
	ImGuiMultiSelectFlags_None = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_None,
	ImGuiMultiSelectFlags_SingleSelect = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_SingleSelect,
	ImGuiMultiSelectFlags_NoSelectAll = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_NoSelectAll,
	ImGuiMultiSelectFlags_NoRangeSelect = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_NoRangeSelect,
	ImGuiMultiSelectFlags_NoAutoSelect = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_NoAutoSelect,
	ImGuiMultiSelectFlags_NoAutoClear = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_NoAutoClear,
	ImGuiMultiSelectFlags_NoAutoClearOnReselect = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_NoAutoClearOnReselect,
	ImGuiMultiSelectFlags_BoxSelect1d = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_BoxSelect1d,
	ImGuiMultiSelectFlags_BoxSelect2d = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_BoxSelect2d,
	ImGuiMultiSelectFlags_BoxSelectNoScroll = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_BoxSelectNoScroll,
	ImGuiMultiSelectFlags_ClearOnEscape = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_ClearOnEscape,
	ImGuiMultiSelectFlags_ClearOnClickVoid = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_ClearOnClickVoid,
	ImGuiMultiSelectFlags_ScopeWindow = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_ScopeWindow,
	ImGuiMultiSelectFlags_ScopeRect = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_ScopeRect,
	ImGuiMultiSelectFlags_SelectOnClick = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_SelectOnClick,
	ImGuiMultiSelectFlags_SelectOnClickRelease = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_SelectOnClickRelease,
	ImGuiMultiSelectFlags_NavWrapX = ImGuiMultiSelectFlags_.ImGuiMultiSelectFlags_NavWrapX,
}
enum ImGuiNavHighlightFlags_ {
	ImGuiNavHighlightFlags_None = 0,
	ImGuiNavHighlightFlags_Compact = 1 << 1,
	ImGuiNavHighlightFlags_AlwaysDraw = 1 << 2,
	ImGuiNavHighlightFlags_NoRounding = 1 << 3,
}
enum : ImGuiNavHighlightFlags_ {
	ImGuiNavHighlightFlags_None = ImGuiNavHighlightFlags_.ImGuiNavHighlightFlags_None,
	ImGuiNavHighlightFlags_Compact = ImGuiNavHighlightFlags_.ImGuiNavHighlightFlags_Compact,
	ImGuiNavHighlightFlags_AlwaysDraw = ImGuiNavHighlightFlags_.ImGuiNavHighlightFlags_AlwaysDraw,
	ImGuiNavHighlightFlags_NoRounding = ImGuiNavHighlightFlags_.ImGuiNavHighlightFlags_NoRounding,
}
enum ImGuiNavLayer {
	ImGuiNavLayer_Main = 0,
	ImGuiNavLayer_Menu = 1,
	ImGuiNavLayer_COUNT,
}
enum : ImGuiNavLayer {
	ImGuiNavLayer_Main = ImGuiNavLayer.ImGuiNavLayer_Main,
	ImGuiNavLayer_Menu = ImGuiNavLayer.ImGuiNavLayer_Menu,
	ImGuiNavLayer_COUNT = ImGuiNavLayer.ImGuiNavLayer_COUNT,
}
enum ImGuiNavMoveFlags_ {
	ImGuiNavMoveFlags_None = 0,
	ImGuiNavMoveFlags_LoopX = 1 << 0,
	ImGuiNavMoveFlags_LoopY = 1 << 1,
	ImGuiNavMoveFlags_WrapX = 1 << 2,
	ImGuiNavMoveFlags_WrapY = 1 << 3,
	ImGuiNavMoveFlags_WrapMask_ = ImGuiNavMoveFlags_LoopX | ImGuiNavMoveFlags_LoopY | ImGuiNavMoveFlags_WrapX | ImGuiNavMoveFlags_WrapY,
	ImGuiNavMoveFlags_AllowCurrentNavId = 1 << 4,
	ImGuiNavMoveFlags_AlsoScoreVisibleSet = 1 << 5,
	ImGuiNavMoveFlags_ScrollToEdgeY = 1 << 6,
	ImGuiNavMoveFlags_Forwarded = 1 << 7,
	ImGuiNavMoveFlags_DebugNoResult = 1 << 8,
	ImGuiNavMoveFlags_FocusApi = 1 << 9,
	ImGuiNavMoveFlags_IsTabbing = 1 << 10,
	ImGuiNavMoveFlags_IsPageMove = 1 << 11,
	ImGuiNavMoveFlags_Activate = 1 << 12,
	ImGuiNavMoveFlags_NoSelect = 1 << 13,
	ImGuiNavMoveFlags_NoSetNavHighlight = 1 << 14,
	ImGuiNavMoveFlags_NoClearActiveId = 1 << 15,
}
enum : ImGuiNavMoveFlags_ {
	ImGuiNavMoveFlags_None = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_None,
	ImGuiNavMoveFlags_LoopX = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_LoopX,
	ImGuiNavMoveFlags_LoopY = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_LoopY,
	ImGuiNavMoveFlags_WrapX = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_WrapX,
	ImGuiNavMoveFlags_WrapY = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_WrapY,
	ImGuiNavMoveFlags_WrapMask_ = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_WrapMask_,
	ImGuiNavMoveFlags_AllowCurrentNavId = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_AllowCurrentNavId,
	ImGuiNavMoveFlags_AlsoScoreVisibleSet = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_AlsoScoreVisibleSet,
	ImGuiNavMoveFlags_ScrollToEdgeY = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_ScrollToEdgeY,
	ImGuiNavMoveFlags_Forwarded = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_Forwarded,
	ImGuiNavMoveFlags_DebugNoResult = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_DebugNoResult,
	ImGuiNavMoveFlags_FocusApi = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_FocusApi,
	ImGuiNavMoveFlags_IsTabbing = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_IsTabbing,
	ImGuiNavMoveFlags_IsPageMove = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_IsPageMove,
	ImGuiNavMoveFlags_Activate = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_Activate,
	ImGuiNavMoveFlags_NoSelect = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_NoSelect,
	ImGuiNavMoveFlags_NoSetNavHighlight = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_NoSetNavHighlight,
	ImGuiNavMoveFlags_NoClearActiveId = ImGuiNavMoveFlags_.ImGuiNavMoveFlags_NoClearActiveId,
}
enum ImGuiNextItemDataFlags_ {
	ImGuiNextItemDataFlags_None = 0,
	ImGuiNextItemDataFlags_HasWidth = 1 << 0,
	ImGuiNextItemDataFlags_HasOpen = 1 << 1,
	ImGuiNextItemDataFlags_HasShortcut = 1 << 2,
	ImGuiNextItemDataFlags_HasRefVal = 1 << 3,
	ImGuiNextItemDataFlags_HasStorageID = 1 << 4,
}
enum : ImGuiNextItemDataFlags_ {
	ImGuiNextItemDataFlags_None = ImGuiNextItemDataFlags_.ImGuiNextItemDataFlags_None,
	ImGuiNextItemDataFlags_HasWidth = ImGuiNextItemDataFlags_.ImGuiNextItemDataFlags_HasWidth,
	ImGuiNextItemDataFlags_HasOpen = ImGuiNextItemDataFlags_.ImGuiNextItemDataFlags_HasOpen,
	ImGuiNextItemDataFlags_HasShortcut = ImGuiNextItemDataFlags_.ImGuiNextItemDataFlags_HasShortcut,
	ImGuiNextItemDataFlags_HasRefVal = ImGuiNextItemDataFlags_.ImGuiNextItemDataFlags_HasRefVal,
	ImGuiNextItemDataFlags_HasStorageID = ImGuiNextItemDataFlags_.ImGuiNextItemDataFlags_HasStorageID,
}
enum ImGuiNextWindowDataFlags_ {
	ImGuiNextWindowDataFlags_None = 0,
	ImGuiNextWindowDataFlags_HasPos = 1 << 0,
	ImGuiNextWindowDataFlags_HasSize = 1 << 1,
	ImGuiNextWindowDataFlags_HasContentSize = 1 << 2,
	ImGuiNextWindowDataFlags_HasCollapsed = 1 << 3,
	ImGuiNextWindowDataFlags_HasSizeConstraint = 1 << 4,
	ImGuiNextWindowDataFlags_HasFocus = 1 << 5,
	ImGuiNextWindowDataFlags_HasBgAlpha = 1 << 6,
	ImGuiNextWindowDataFlags_HasScroll = 1 << 7,
	ImGuiNextWindowDataFlags_HasChildFlags = 1 << 8,
	ImGuiNextWindowDataFlags_HasRefreshPolicy = 1 << 9,
	ImGuiNextWindowDataFlags_HasViewport = 1 << 10,
	ImGuiNextWindowDataFlags_HasDock = 1 << 11,
	ImGuiNextWindowDataFlags_HasWindowClass = 1 << 12,
}
enum : ImGuiNextWindowDataFlags_ {
	ImGuiNextWindowDataFlags_None = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_None,
	ImGuiNextWindowDataFlags_HasPos = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_HasPos,
	ImGuiNextWindowDataFlags_HasSize = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_HasSize,
	ImGuiNextWindowDataFlags_HasContentSize = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_HasContentSize,
	ImGuiNextWindowDataFlags_HasCollapsed = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_HasCollapsed,
	ImGuiNextWindowDataFlags_HasSizeConstraint = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_HasSizeConstraint,
	ImGuiNextWindowDataFlags_HasFocus = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_HasFocus,
	ImGuiNextWindowDataFlags_HasBgAlpha = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_HasBgAlpha,
	ImGuiNextWindowDataFlags_HasScroll = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_HasScroll,
	ImGuiNextWindowDataFlags_HasChildFlags = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_HasChildFlags,
	ImGuiNextWindowDataFlags_HasRefreshPolicy = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_HasRefreshPolicy,
	ImGuiNextWindowDataFlags_HasViewport = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_HasViewport,
	ImGuiNextWindowDataFlags_HasDock = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_HasDock,
	ImGuiNextWindowDataFlags_HasWindowClass = ImGuiNextWindowDataFlags_.ImGuiNextWindowDataFlags_HasWindowClass,
}
enum ImGuiOldColumnFlags_ {
	ImGuiOldColumnFlags_None = 0,
	ImGuiOldColumnFlags_NoBorder = 1 << 0,
	ImGuiOldColumnFlags_NoResize = 1 << 1,
	ImGuiOldColumnFlags_NoPreserveWidths = 1 << 2,
	ImGuiOldColumnFlags_NoForceWithinWindow = 1 << 3,
	ImGuiOldColumnFlags_GrowParentContentsSize = 1 << 4,
}
enum : ImGuiOldColumnFlags_ {
	ImGuiOldColumnFlags_None = ImGuiOldColumnFlags_.ImGuiOldColumnFlags_None,
	ImGuiOldColumnFlags_NoBorder = ImGuiOldColumnFlags_.ImGuiOldColumnFlags_NoBorder,
	ImGuiOldColumnFlags_NoResize = ImGuiOldColumnFlags_.ImGuiOldColumnFlags_NoResize,
	ImGuiOldColumnFlags_NoPreserveWidths = ImGuiOldColumnFlags_.ImGuiOldColumnFlags_NoPreserveWidths,
	ImGuiOldColumnFlags_NoForceWithinWindow = ImGuiOldColumnFlags_.ImGuiOldColumnFlags_NoForceWithinWindow,
	ImGuiOldColumnFlags_GrowParentContentsSize = ImGuiOldColumnFlags_.ImGuiOldColumnFlags_GrowParentContentsSize,
}
enum ImGuiPlotType {
	ImGuiPlotType_Lines,
	ImGuiPlotType_Histogram,
}
enum : ImGuiPlotType {
	ImGuiPlotType_Lines = ImGuiPlotType.ImGuiPlotType_Lines,
	ImGuiPlotType_Histogram = ImGuiPlotType.ImGuiPlotType_Histogram,
}
enum ImGuiPopupFlags_ {
	ImGuiPopupFlags_None = 0,
	ImGuiPopupFlags_MouseButtonLeft = 0,
	ImGuiPopupFlags_MouseButtonRight = 1,
	ImGuiPopupFlags_MouseButtonMiddle = 2,
	ImGuiPopupFlags_MouseButtonMask_ = 0x1F,
	ImGuiPopupFlags_MouseButtonDefault_ = 1,
	ImGuiPopupFlags_NoReopen = 1 << 5,
	ImGuiPopupFlags_NoOpenOverExistingPopup = 1 << 7,
	ImGuiPopupFlags_NoOpenOverItems = 1 << 8,
	ImGuiPopupFlags_AnyPopupId = 1 << 10,
	ImGuiPopupFlags_AnyPopupLevel = 1 << 11,
	ImGuiPopupFlags_AnyPopup = ImGuiPopupFlags_AnyPopupId | ImGuiPopupFlags_AnyPopupLevel,
}
enum : ImGuiPopupFlags_ {
	ImGuiPopupFlags_None = ImGuiPopupFlags_.ImGuiPopupFlags_None,
	ImGuiPopupFlags_MouseButtonLeft = ImGuiPopupFlags_.ImGuiPopupFlags_MouseButtonLeft,
	ImGuiPopupFlags_MouseButtonRight = ImGuiPopupFlags_.ImGuiPopupFlags_MouseButtonRight,
	ImGuiPopupFlags_MouseButtonMiddle = ImGuiPopupFlags_.ImGuiPopupFlags_MouseButtonMiddle,
	ImGuiPopupFlags_MouseButtonMask_ = ImGuiPopupFlags_.ImGuiPopupFlags_MouseButtonMask_,
	ImGuiPopupFlags_MouseButtonDefault_ = ImGuiPopupFlags_.ImGuiPopupFlags_MouseButtonDefault_,
	ImGuiPopupFlags_NoReopen = ImGuiPopupFlags_.ImGuiPopupFlags_NoReopen,
	ImGuiPopupFlags_NoOpenOverExistingPopup = ImGuiPopupFlags_.ImGuiPopupFlags_NoOpenOverExistingPopup,
	ImGuiPopupFlags_NoOpenOverItems = ImGuiPopupFlags_.ImGuiPopupFlags_NoOpenOverItems,
	ImGuiPopupFlags_AnyPopupId = ImGuiPopupFlags_.ImGuiPopupFlags_AnyPopupId,
	ImGuiPopupFlags_AnyPopupLevel = ImGuiPopupFlags_.ImGuiPopupFlags_AnyPopupLevel,
	ImGuiPopupFlags_AnyPopup = ImGuiPopupFlags_.ImGuiPopupFlags_AnyPopup,
}
enum ImGuiPopupPositionPolicy {
	ImGuiPopupPositionPolicy_Default,
	ImGuiPopupPositionPolicy_ComboBox,
	ImGuiPopupPositionPolicy_Tooltip,
}
enum : ImGuiPopupPositionPolicy {
	ImGuiPopupPositionPolicy_Default = ImGuiPopupPositionPolicy.ImGuiPopupPositionPolicy_Default,
	ImGuiPopupPositionPolicy_ComboBox = ImGuiPopupPositionPolicy.ImGuiPopupPositionPolicy_ComboBox,
	ImGuiPopupPositionPolicy_Tooltip = ImGuiPopupPositionPolicy.ImGuiPopupPositionPolicy_Tooltip,
}
enum ImGuiScrollFlags_ {
	ImGuiScrollFlags_None = 0,
	ImGuiScrollFlags_KeepVisibleEdgeX = 1 << 0,
	ImGuiScrollFlags_KeepVisibleEdgeY = 1 << 1,
	ImGuiScrollFlags_KeepVisibleCenterX = 1 << 2,
	ImGuiScrollFlags_KeepVisibleCenterY = 1 << 3,
	ImGuiScrollFlags_AlwaysCenterX = 1 << 4,
	ImGuiScrollFlags_AlwaysCenterY = 1 << 5,
	ImGuiScrollFlags_NoScrollParent = 1 << 6,
	ImGuiScrollFlags_MaskX_ = ImGuiScrollFlags_KeepVisibleEdgeX | ImGuiScrollFlags_KeepVisibleCenterX | ImGuiScrollFlags_AlwaysCenterX,
	ImGuiScrollFlags_MaskY_ = ImGuiScrollFlags_KeepVisibleEdgeY | ImGuiScrollFlags_KeepVisibleCenterY | ImGuiScrollFlags_AlwaysCenterY,
}
enum : ImGuiScrollFlags_ {
	ImGuiScrollFlags_None = ImGuiScrollFlags_.ImGuiScrollFlags_None,
	ImGuiScrollFlags_KeepVisibleEdgeX = ImGuiScrollFlags_.ImGuiScrollFlags_KeepVisibleEdgeX,
	ImGuiScrollFlags_KeepVisibleEdgeY = ImGuiScrollFlags_.ImGuiScrollFlags_KeepVisibleEdgeY,
	ImGuiScrollFlags_KeepVisibleCenterX = ImGuiScrollFlags_.ImGuiScrollFlags_KeepVisibleCenterX,
	ImGuiScrollFlags_KeepVisibleCenterY = ImGuiScrollFlags_.ImGuiScrollFlags_KeepVisibleCenterY,
	ImGuiScrollFlags_AlwaysCenterX = ImGuiScrollFlags_.ImGuiScrollFlags_AlwaysCenterX,
	ImGuiScrollFlags_AlwaysCenterY = ImGuiScrollFlags_.ImGuiScrollFlags_AlwaysCenterY,
	ImGuiScrollFlags_NoScrollParent = ImGuiScrollFlags_.ImGuiScrollFlags_NoScrollParent,
	ImGuiScrollFlags_MaskX_ = ImGuiScrollFlags_.ImGuiScrollFlags_MaskX_,
	ImGuiScrollFlags_MaskY_ = ImGuiScrollFlags_.ImGuiScrollFlags_MaskY_,
}
enum ImGuiSelectableFlagsPrivate_ {
	ImGuiSelectableFlags_NoHoldingActiveID = 1 << 20,
	ImGuiSelectableFlags_SelectOnNav = 1 << 21,
	ImGuiSelectableFlags_SelectOnClick = 1 << 22,
	ImGuiSelectableFlags_SelectOnRelease = 1 << 23,
	ImGuiSelectableFlags_SpanAvailWidth = 1 << 24,
	ImGuiSelectableFlags_SetNavIdOnHover = 1 << 25,
	ImGuiSelectableFlags_NoPadWithHalfSpacing = 1 << 26,
	ImGuiSelectableFlags_NoSetKeyOwner = 1 << 27,
}
enum : ImGuiSelectableFlagsPrivate_ {
	ImGuiSelectableFlags_NoHoldingActiveID = ImGuiSelectableFlagsPrivate_.ImGuiSelectableFlags_NoHoldingActiveID,
	ImGuiSelectableFlags_SelectOnNav = ImGuiSelectableFlagsPrivate_.ImGuiSelectableFlags_SelectOnNav,
	ImGuiSelectableFlags_SelectOnClick = ImGuiSelectableFlagsPrivate_.ImGuiSelectableFlags_SelectOnClick,
	ImGuiSelectableFlags_SelectOnRelease = ImGuiSelectableFlagsPrivate_.ImGuiSelectableFlags_SelectOnRelease,
	ImGuiSelectableFlags_SpanAvailWidth = ImGuiSelectableFlagsPrivate_.ImGuiSelectableFlags_SpanAvailWidth,
	ImGuiSelectableFlags_SetNavIdOnHover = ImGuiSelectableFlagsPrivate_.ImGuiSelectableFlags_SetNavIdOnHover,
	ImGuiSelectableFlags_NoPadWithHalfSpacing = ImGuiSelectableFlagsPrivate_.ImGuiSelectableFlags_NoPadWithHalfSpacing,
	ImGuiSelectableFlags_NoSetKeyOwner = ImGuiSelectableFlagsPrivate_.ImGuiSelectableFlags_NoSetKeyOwner,
}
enum ImGuiSelectableFlags_ {
	ImGuiSelectableFlags_None = 0,
	ImGuiSelectableFlags_NoAutoClosePopups = 1 << 0,
	ImGuiSelectableFlags_SpanAllColumns = 1 << 1,
	ImGuiSelectableFlags_AllowDoubleClick = 1 << 2,
	ImGuiSelectableFlags_Disabled = 1 << 3,
	ImGuiSelectableFlags_AllowOverlap = 1 << 4,
	ImGuiSelectableFlags_Highlight = 1 << 5,
}
enum : ImGuiSelectableFlags_ {
	ImGuiSelectableFlags_None = ImGuiSelectableFlags_.ImGuiSelectableFlags_None,
	ImGuiSelectableFlags_NoAutoClosePopups = ImGuiSelectableFlags_.ImGuiSelectableFlags_NoAutoClosePopups,
	ImGuiSelectableFlags_SpanAllColumns = ImGuiSelectableFlags_.ImGuiSelectableFlags_SpanAllColumns,
	ImGuiSelectableFlags_AllowDoubleClick = ImGuiSelectableFlags_.ImGuiSelectableFlags_AllowDoubleClick,
	ImGuiSelectableFlags_Disabled = ImGuiSelectableFlags_.ImGuiSelectableFlags_Disabled,
	ImGuiSelectableFlags_AllowOverlap = ImGuiSelectableFlags_.ImGuiSelectableFlags_AllowOverlap,
	ImGuiSelectableFlags_Highlight = ImGuiSelectableFlags_.ImGuiSelectableFlags_Highlight,
}
enum ImGuiSelectionRequestType {
	ImGuiSelectionRequestType_None = 0,
	ImGuiSelectionRequestType_SetAll,
	ImGuiSelectionRequestType_SetRange,
}
enum : ImGuiSelectionRequestType {
	ImGuiSelectionRequestType_None = ImGuiSelectionRequestType.ImGuiSelectionRequestType_None,
	ImGuiSelectionRequestType_SetAll = ImGuiSelectionRequestType.ImGuiSelectionRequestType_SetAll,
	ImGuiSelectionRequestType_SetRange = ImGuiSelectionRequestType.ImGuiSelectionRequestType_SetRange,
}
enum ImGuiSeparatorFlags_ {
	ImGuiSeparatorFlags_None = 0,
	ImGuiSeparatorFlags_Horizontal = 1 << 0,
	ImGuiSeparatorFlags_Vertical = 1 << 1,
	ImGuiSeparatorFlags_SpanAllColumns = 1 << 2,
}
enum : ImGuiSeparatorFlags_ {
	ImGuiSeparatorFlags_None = ImGuiSeparatorFlags_.ImGuiSeparatorFlags_None,
	ImGuiSeparatorFlags_Horizontal = ImGuiSeparatorFlags_.ImGuiSeparatorFlags_Horizontal,
	ImGuiSeparatorFlags_Vertical = ImGuiSeparatorFlags_.ImGuiSeparatorFlags_Vertical,
	ImGuiSeparatorFlags_SpanAllColumns = ImGuiSeparatorFlags_.ImGuiSeparatorFlags_SpanAllColumns,
}
enum ImGuiSliderFlagsPrivate_ {
	ImGuiSliderFlags_Vertical = 1 << 20,
	ImGuiSliderFlags_ReadOnly = 1 << 21,
}
enum : ImGuiSliderFlagsPrivate_ {
	ImGuiSliderFlags_Vertical = ImGuiSliderFlagsPrivate_.ImGuiSliderFlags_Vertical,
	ImGuiSliderFlags_ReadOnly = ImGuiSliderFlagsPrivate_.ImGuiSliderFlags_ReadOnly,
}
enum ImGuiSliderFlags_ {
	ImGuiSliderFlags_None = 0,
	ImGuiSliderFlags_AlwaysClamp = 1 << 4,
	ImGuiSliderFlags_Logarithmic = 1 << 5,
	ImGuiSliderFlags_NoRoundToFormat = 1 << 6,
	ImGuiSliderFlags_NoInput = 1 << 7,
	ImGuiSliderFlags_WrapAround = 1 << 8,
	ImGuiSliderFlags_InvalidMask_ = 0x7000000F,
}
enum : ImGuiSliderFlags_ {
	ImGuiSliderFlags_None = ImGuiSliderFlags_.ImGuiSliderFlags_None,
	ImGuiSliderFlags_AlwaysClamp = ImGuiSliderFlags_.ImGuiSliderFlags_AlwaysClamp,
	ImGuiSliderFlags_Logarithmic = ImGuiSliderFlags_.ImGuiSliderFlags_Logarithmic,
	ImGuiSliderFlags_NoRoundToFormat = ImGuiSliderFlags_.ImGuiSliderFlags_NoRoundToFormat,
	ImGuiSliderFlags_NoInput = ImGuiSliderFlags_.ImGuiSliderFlags_NoInput,
	ImGuiSliderFlags_WrapAround = ImGuiSliderFlags_.ImGuiSliderFlags_WrapAround,
	ImGuiSliderFlags_InvalidMask_ = ImGuiSliderFlags_.ImGuiSliderFlags_InvalidMask_,
}
enum ImGuiSortDirection {
	ImGuiSortDirection_None = 0,
	ImGuiSortDirection_Ascending = 1,
	ImGuiSortDirection_Descending = 2,
}
enum : ImGuiSortDirection {
	ImGuiSortDirection_None = ImGuiSortDirection.ImGuiSortDirection_None,
	ImGuiSortDirection_Ascending = ImGuiSortDirection.ImGuiSortDirection_Ascending,
	ImGuiSortDirection_Descending = ImGuiSortDirection.ImGuiSortDirection_Descending,
}
enum ImGuiStyleVar_ {
	ImGuiStyleVar_Alpha,
	ImGuiStyleVar_DisabledAlpha,
	ImGuiStyleVar_WindowPadding,
	ImGuiStyleVar_WindowRounding,
	ImGuiStyleVar_WindowBorderSize,
	ImGuiStyleVar_WindowMinSize,
	ImGuiStyleVar_WindowTitleAlign,
	ImGuiStyleVar_ChildRounding,
	ImGuiStyleVar_ChildBorderSize,
	ImGuiStyleVar_PopupRounding,
	ImGuiStyleVar_PopupBorderSize,
	ImGuiStyleVar_FramePadding,
	ImGuiStyleVar_FrameRounding,
	ImGuiStyleVar_FrameBorderSize,
	ImGuiStyleVar_ItemSpacing,
	ImGuiStyleVar_ItemInnerSpacing,
	ImGuiStyleVar_IndentSpacing,
	ImGuiStyleVar_CellPadding,
	ImGuiStyleVar_ScrollbarSize,
	ImGuiStyleVar_ScrollbarRounding,
	ImGuiStyleVar_GrabMinSize,
	ImGuiStyleVar_GrabRounding,
	ImGuiStyleVar_TabRounding,
	ImGuiStyleVar_TabBorderSize,
	ImGuiStyleVar_TabBarBorderSize,
	ImGuiStyleVar_TabBarOverlineSize,
	ImGuiStyleVar_TableAngledHeadersAngle,
	ImGuiStyleVar_TableAngledHeadersTextAlign,
	ImGuiStyleVar_ButtonTextAlign,
	ImGuiStyleVar_SelectableTextAlign,
	ImGuiStyleVar_SeparatorTextBorderSize,
	ImGuiStyleVar_SeparatorTextAlign,
	ImGuiStyleVar_SeparatorTextPadding,
	ImGuiStyleVar_DockingSeparatorSize,
	ImGuiStyleVar_COUNT,
}
enum : ImGuiStyleVar_ {
	ImGuiStyleVar_Alpha = ImGuiStyleVar_.ImGuiStyleVar_Alpha,
	ImGuiStyleVar_DisabledAlpha = ImGuiStyleVar_.ImGuiStyleVar_DisabledAlpha,
	ImGuiStyleVar_WindowPadding = ImGuiStyleVar_.ImGuiStyleVar_WindowPadding,
	ImGuiStyleVar_WindowRounding = ImGuiStyleVar_.ImGuiStyleVar_WindowRounding,
	ImGuiStyleVar_WindowBorderSize = ImGuiStyleVar_.ImGuiStyleVar_WindowBorderSize,
	ImGuiStyleVar_WindowMinSize = ImGuiStyleVar_.ImGuiStyleVar_WindowMinSize,
	ImGuiStyleVar_WindowTitleAlign = ImGuiStyleVar_.ImGuiStyleVar_WindowTitleAlign,
	ImGuiStyleVar_ChildRounding = ImGuiStyleVar_.ImGuiStyleVar_ChildRounding,
	ImGuiStyleVar_ChildBorderSize = ImGuiStyleVar_.ImGuiStyleVar_ChildBorderSize,
	ImGuiStyleVar_PopupRounding = ImGuiStyleVar_.ImGuiStyleVar_PopupRounding,
	ImGuiStyleVar_PopupBorderSize = ImGuiStyleVar_.ImGuiStyleVar_PopupBorderSize,
	ImGuiStyleVar_FramePadding = ImGuiStyleVar_.ImGuiStyleVar_FramePadding,
	ImGuiStyleVar_FrameRounding = ImGuiStyleVar_.ImGuiStyleVar_FrameRounding,
	ImGuiStyleVar_FrameBorderSize = ImGuiStyleVar_.ImGuiStyleVar_FrameBorderSize,
	ImGuiStyleVar_ItemSpacing = ImGuiStyleVar_.ImGuiStyleVar_ItemSpacing,
	ImGuiStyleVar_ItemInnerSpacing = ImGuiStyleVar_.ImGuiStyleVar_ItemInnerSpacing,
	ImGuiStyleVar_IndentSpacing = ImGuiStyleVar_.ImGuiStyleVar_IndentSpacing,
	ImGuiStyleVar_CellPadding = ImGuiStyleVar_.ImGuiStyleVar_CellPadding,
	ImGuiStyleVar_ScrollbarSize = ImGuiStyleVar_.ImGuiStyleVar_ScrollbarSize,
	ImGuiStyleVar_ScrollbarRounding = ImGuiStyleVar_.ImGuiStyleVar_ScrollbarRounding,
	ImGuiStyleVar_GrabMinSize = ImGuiStyleVar_.ImGuiStyleVar_GrabMinSize,
	ImGuiStyleVar_GrabRounding = ImGuiStyleVar_.ImGuiStyleVar_GrabRounding,
	ImGuiStyleVar_TabRounding = ImGuiStyleVar_.ImGuiStyleVar_TabRounding,
	ImGuiStyleVar_TabBorderSize = ImGuiStyleVar_.ImGuiStyleVar_TabBorderSize,
	ImGuiStyleVar_TabBarBorderSize = ImGuiStyleVar_.ImGuiStyleVar_TabBarBorderSize,
	ImGuiStyleVar_TabBarOverlineSize = ImGuiStyleVar_.ImGuiStyleVar_TabBarOverlineSize,
	ImGuiStyleVar_TableAngledHeadersAngle = ImGuiStyleVar_.ImGuiStyleVar_TableAngledHeadersAngle,
	ImGuiStyleVar_TableAngledHeadersTextAlign = ImGuiStyleVar_.ImGuiStyleVar_TableAngledHeadersTextAlign,
	ImGuiStyleVar_ButtonTextAlign = ImGuiStyleVar_.ImGuiStyleVar_ButtonTextAlign,
	ImGuiStyleVar_SelectableTextAlign = ImGuiStyleVar_.ImGuiStyleVar_SelectableTextAlign,
	ImGuiStyleVar_SeparatorTextBorderSize = ImGuiStyleVar_.ImGuiStyleVar_SeparatorTextBorderSize,
	ImGuiStyleVar_SeparatorTextAlign = ImGuiStyleVar_.ImGuiStyleVar_SeparatorTextAlign,
	ImGuiStyleVar_SeparatorTextPadding = ImGuiStyleVar_.ImGuiStyleVar_SeparatorTextPadding,
	ImGuiStyleVar_DockingSeparatorSize = ImGuiStyleVar_.ImGuiStyleVar_DockingSeparatorSize,
	ImGuiStyleVar_COUNT = ImGuiStyleVar_.ImGuiStyleVar_COUNT,
}
enum ImGuiTabBarFlagsPrivate_ {
	ImGuiTabBarFlags_DockNode = 1 << 20,
	ImGuiTabBarFlags_IsFocused = 1 << 21,
	ImGuiTabBarFlags_SaveSettings = 1 << 22,
}
enum : ImGuiTabBarFlagsPrivate_ {
	ImGuiTabBarFlags_DockNode = ImGuiTabBarFlagsPrivate_.ImGuiTabBarFlags_DockNode,
	ImGuiTabBarFlags_IsFocused = ImGuiTabBarFlagsPrivate_.ImGuiTabBarFlags_IsFocused,
	ImGuiTabBarFlags_SaveSettings = ImGuiTabBarFlagsPrivate_.ImGuiTabBarFlags_SaveSettings,
}
enum ImGuiTabBarFlags_ {
	ImGuiTabBarFlags_None = 0,
	ImGuiTabBarFlags_Reorderable = 1 << 0,
	ImGuiTabBarFlags_AutoSelectNewTabs = 1 << 1,
	ImGuiTabBarFlags_TabListPopupButton = 1 << 2,
	ImGuiTabBarFlags_NoCloseWithMiddleMouseButton = 1 << 3,
	ImGuiTabBarFlags_NoTabListScrollingButtons = 1 << 4,
	ImGuiTabBarFlags_NoTooltip = 1 << 5,
	ImGuiTabBarFlags_DrawSelectedOverline = 1 << 6,
	ImGuiTabBarFlags_FittingPolicyResizeDown = 1 << 7,
	ImGuiTabBarFlags_FittingPolicyScroll = 1 << 8,
	ImGuiTabBarFlags_FittingPolicyMask_ = ImGuiTabBarFlags_FittingPolicyResizeDown | ImGuiTabBarFlags_FittingPolicyScroll,
	ImGuiTabBarFlags_FittingPolicyDefault_ = ImGuiTabBarFlags_FittingPolicyResizeDown,
}
enum : ImGuiTabBarFlags_ {
	ImGuiTabBarFlags_None = ImGuiTabBarFlags_.ImGuiTabBarFlags_None,
	ImGuiTabBarFlags_Reorderable = ImGuiTabBarFlags_.ImGuiTabBarFlags_Reorderable,
	ImGuiTabBarFlags_AutoSelectNewTabs = ImGuiTabBarFlags_.ImGuiTabBarFlags_AutoSelectNewTabs,
	ImGuiTabBarFlags_TabListPopupButton = ImGuiTabBarFlags_.ImGuiTabBarFlags_TabListPopupButton,
	ImGuiTabBarFlags_NoCloseWithMiddleMouseButton = ImGuiTabBarFlags_.ImGuiTabBarFlags_NoCloseWithMiddleMouseButton,
	ImGuiTabBarFlags_NoTabListScrollingButtons = ImGuiTabBarFlags_.ImGuiTabBarFlags_NoTabListScrollingButtons,
	ImGuiTabBarFlags_NoTooltip = ImGuiTabBarFlags_.ImGuiTabBarFlags_NoTooltip,
	ImGuiTabBarFlags_DrawSelectedOverline = ImGuiTabBarFlags_.ImGuiTabBarFlags_DrawSelectedOverline,
	ImGuiTabBarFlags_FittingPolicyResizeDown = ImGuiTabBarFlags_.ImGuiTabBarFlags_FittingPolicyResizeDown,
	ImGuiTabBarFlags_FittingPolicyScroll = ImGuiTabBarFlags_.ImGuiTabBarFlags_FittingPolicyScroll,
	ImGuiTabBarFlags_FittingPolicyMask_ = ImGuiTabBarFlags_.ImGuiTabBarFlags_FittingPolicyMask_,
	ImGuiTabBarFlags_FittingPolicyDefault_ = ImGuiTabBarFlags_.ImGuiTabBarFlags_FittingPolicyDefault_,
}
enum ImGuiTabItemFlagsPrivate_ {
	ImGuiTabItemFlags_SectionMask_ = cast(uint)ImGuiTabItemFlags_Leading | ImGuiTabItemFlags_Trailing,
	ImGuiTabItemFlags_NoCloseButton = 1 << 20,
	ImGuiTabItemFlags_Button = 1 << 21,
	ImGuiTabItemFlags_Unsorted = 1 << 22,
}
enum : ImGuiTabItemFlagsPrivate_ {
	ImGuiTabItemFlags_SectionMask_ = ImGuiTabItemFlagsPrivate_.ImGuiTabItemFlags_SectionMask_,
	ImGuiTabItemFlags_NoCloseButton = ImGuiTabItemFlagsPrivate_.ImGuiTabItemFlags_NoCloseButton,
	ImGuiTabItemFlags_Button = ImGuiTabItemFlagsPrivate_.ImGuiTabItemFlags_Button,
	ImGuiTabItemFlags_Unsorted = ImGuiTabItemFlagsPrivate_.ImGuiTabItemFlags_Unsorted,
}
enum ImGuiTabItemFlags_ {
	ImGuiTabItemFlags_None = 0,
	ImGuiTabItemFlags_UnsavedDocument = 1 << 0,
	ImGuiTabItemFlags_SetSelected = 1 << 1,
	ImGuiTabItemFlags_NoCloseWithMiddleMouseButton = 1 << 2,
	ImGuiTabItemFlags_NoPushId = 1 << 3,
	ImGuiTabItemFlags_NoTooltip = 1 << 4,
	ImGuiTabItemFlags_NoReorder = 1 << 5,
	ImGuiTabItemFlags_Leading = 1 << 6,
	ImGuiTabItemFlags_Trailing = 1 << 7,
	ImGuiTabItemFlags_NoAssumedClosure = 1 << 8,
}
enum : ImGuiTabItemFlags_ {
	ImGuiTabItemFlags_None = ImGuiTabItemFlags_.ImGuiTabItemFlags_None,
	ImGuiTabItemFlags_UnsavedDocument = ImGuiTabItemFlags_.ImGuiTabItemFlags_UnsavedDocument,
	ImGuiTabItemFlags_SetSelected = ImGuiTabItemFlags_.ImGuiTabItemFlags_SetSelected,
	ImGuiTabItemFlags_NoCloseWithMiddleMouseButton = ImGuiTabItemFlags_.ImGuiTabItemFlags_NoCloseWithMiddleMouseButton,
	ImGuiTabItemFlags_NoPushId = ImGuiTabItemFlags_.ImGuiTabItemFlags_NoPushId,
	ImGuiTabItemFlags_NoTooltip = ImGuiTabItemFlags_.ImGuiTabItemFlags_NoTooltip,
	ImGuiTabItemFlags_NoReorder = ImGuiTabItemFlags_.ImGuiTabItemFlags_NoReorder,
	ImGuiTabItemFlags_Leading = ImGuiTabItemFlags_.ImGuiTabItemFlags_Leading,
	ImGuiTabItemFlags_Trailing = ImGuiTabItemFlags_.ImGuiTabItemFlags_Trailing,
	ImGuiTabItemFlags_NoAssumedClosure = ImGuiTabItemFlags_.ImGuiTabItemFlags_NoAssumedClosure,
}
enum ImGuiTableBgTarget_ {
	ImGuiTableBgTarget_None = 0,
	ImGuiTableBgTarget_RowBg0 = 1,
	ImGuiTableBgTarget_RowBg1 = 2,
	ImGuiTableBgTarget_CellBg = 3,
}
enum : ImGuiTableBgTarget_ {
	ImGuiTableBgTarget_None = ImGuiTableBgTarget_.ImGuiTableBgTarget_None,
	ImGuiTableBgTarget_RowBg0 = ImGuiTableBgTarget_.ImGuiTableBgTarget_RowBg0,
	ImGuiTableBgTarget_RowBg1 = ImGuiTableBgTarget_.ImGuiTableBgTarget_RowBg1,
	ImGuiTableBgTarget_CellBg = ImGuiTableBgTarget_.ImGuiTableBgTarget_CellBg,
}
enum ImGuiTableColumnFlags_ {
	ImGuiTableColumnFlags_None = 0,
	ImGuiTableColumnFlags_Disabled = 1 << 0,
	ImGuiTableColumnFlags_DefaultHide = 1 << 1,
	ImGuiTableColumnFlags_DefaultSort = 1 << 2,
	ImGuiTableColumnFlags_WidthStretch = 1 << 3,
	ImGuiTableColumnFlags_WidthFixed = 1 << 4,
	ImGuiTableColumnFlags_NoResize = 1 << 5,
	ImGuiTableColumnFlags_NoReorder = 1 << 6,
	ImGuiTableColumnFlags_NoHide = 1 << 7,
	ImGuiTableColumnFlags_NoClip = 1 << 8,
	ImGuiTableColumnFlags_NoSort = 1 << 9,
	ImGuiTableColumnFlags_NoSortAscending = 1 << 10,
	ImGuiTableColumnFlags_NoSortDescending = 1 << 11,
	ImGuiTableColumnFlags_NoHeaderLabel = 1 << 12,
	ImGuiTableColumnFlags_NoHeaderWidth = 1 << 13,
	ImGuiTableColumnFlags_PreferSortAscending = 1 << 14,
	ImGuiTableColumnFlags_PreferSortDescending = 1 << 15,
	ImGuiTableColumnFlags_IndentEnable = 1 << 16,
	ImGuiTableColumnFlags_IndentDisable = 1 << 17,
	ImGuiTableColumnFlags_AngledHeader = 1 << 18,
	ImGuiTableColumnFlags_IsEnabled = 1 << 24,
	ImGuiTableColumnFlags_IsVisible = 1 << 25,
	ImGuiTableColumnFlags_IsSorted = 1 << 26,
	ImGuiTableColumnFlags_IsHovered = 1 << 27,
	ImGuiTableColumnFlags_WidthMask_ = ImGuiTableColumnFlags_WidthStretch | ImGuiTableColumnFlags_WidthFixed,
	ImGuiTableColumnFlags_IndentMask_ = ImGuiTableColumnFlags_IndentEnable | ImGuiTableColumnFlags_IndentDisable,
	ImGuiTableColumnFlags_StatusMask_ = ImGuiTableColumnFlags_IsEnabled | ImGuiTableColumnFlags_IsVisible | ImGuiTableColumnFlags_IsSorted | ImGuiTableColumnFlags_IsHovered,
	ImGuiTableColumnFlags_NoDirectResize_ = 1 << 30,
}
enum : ImGuiTableColumnFlags_ {
	ImGuiTableColumnFlags_None = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_None,
	ImGuiTableColumnFlags_Disabled = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_Disabled,
	ImGuiTableColumnFlags_DefaultHide = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_DefaultHide,
	ImGuiTableColumnFlags_DefaultSort = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_DefaultSort,
	ImGuiTableColumnFlags_WidthStretch = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_WidthStretch,
	ImGuiTableColumnFlags_WidthFixed = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_WidthFixed,
	ImGuiTableColumnFlags_NoResize = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoResize,
	ImGuiTableColumnFlags_NoReorder = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoReorder,
	ImGuiTableColumnFlags_NoHide = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoHide,
	ImGuiTableColumnFlags_NoClip = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoClip,
	ImGuiTableColumnFlags_NoSort = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoSort,
	ImGuiTableColumnFlags_NoSortAscending = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoSortAscending,
	ImGuiTableColumnFlags_NoSortDescending = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoSortDescending,
	ImGuiTableColumnFlags_NoHeaderLabel = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoHeaderLabel,
	ImGuiTableColumnFlags_NoHeaderWidth = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoHeaderWidth,
	ImGuiTableColumnFlags_PreferSortAscending = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_PreferSortAscending,
	ImGuiTableColumnFlags_PreferSortDescending = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_PreferSortDescending,
	ImGuiTableColumnFlags_IndentEnable = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IndentEnable,
	ImGuiTableColumnFlags_IndentDisable = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IndentDisable,
	ImGuiTableColumnFlags_AngledHeader = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_AngledHeader,
	ImGuiTableColumnFlags_IsEnabled = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IsEnabled,
	ImGuiTableColumnFlags_IsVisible = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IsVisible,
	ImGuiTableColumnFlags_IsSorted = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IsSorted,
	ImGuiTableColumnFlags_IsHovered = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IsHovered,
	ImGuiTableColumnFlags_WidthMask_ = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_WidthMask_,
	ImGuiTableColumnFlags_IndentMask_ = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IndentMask_,
	ImGuiTableColumnFlags_StatusMask_ = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_StatusMask_,
	ImGuiTableColumnFlags_NoDirectResize_ = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoDirectResize_,
}
enum ImGuiTableFlags_ {
	ImGuiTableFlags_None = 0,
	ImGuiTableFlags_Resizable = 1 << 0,
	ImGuiTableFlags_Reorderable = 1 << 1,
	ImGuiTableFlags_Hideable = 1 << 2,
	ImGuiTableFlags_Sortable = 1 << 3,
	ImGuiTableFlags_NoSavedSettings = 1 << 4,
	ImGuiTableFlags_ContextMenuInBody = 1 << 5,
	ImGuiTableFlags_RowBg = 1 << 6,
	ImGuiTableFlags_BordersInnerH = 1 << 7,
	ImGuiTableFlags_BordersOuterH = 1 << 8,
	ImGuiTableFlags_BordersInnerV = 1 << 9,
	ImGuiTableFlags_BordersOuterV = 1 << 10,
	ImGuiTableFlags_BordersH = ImGuiTableFlags_BordersInnerH | ImGuiTableFlags_BordersOuterH,
	ImGuiTableFlags_BordersV = ImGuiTableFlags_BordersInnerV | ImGuiTableFlags_BordersOuterV,
	ImGuiTableFlags_BordersInner = ImGuiTableFlags_BordersInnerV | ImGuiTableFlags_BordersInnerH,
	ImGuiTableFlags_BordersOuter = ImGuiTableFlags_BordersOuterV | ImGuiTableFlags_BordersOuterH,
	ImGuiTableFlags_Borders = ImGuiTableFlags_BordersInner | ImGuiTableFlags_BordersOuter,
	ImGuiTableFlags_NoBordersInBody = 1 << 11,
	ImGuiTableFlags_NoBordersInBodyUntilResize = 1 << 12,
	ImGuiTableFlags_SizingFixedFit = 1 << 13,
	ImGuiTableFlags_SizingFixedSame = 2 << 13,
	ImGuiTableFlags_SizingStretchProp = 3 << 13,
	ImGuiTableFlags_SizingStretchSame = 4 << 13,
	ImGuiTableFlags_NoHostExtendX = 1 << 16,
	ImGuiTableFlags_NoHostExtendY = 1 << 17,
	ImGuiTableFlags_NoKeepColumnsVisible = 1 << 18,
	ImGuiTableFlags_PreciseWidths = 1 << 19,
	ImGuiTableFlags_NoClip = 1 << 20,
	ImGuiTableFlags_PadOuterX = 1 << 21,
	ImGuiTableFlags_NoPadOuterX = 1 << 22,
	ImGuiTableFlags_NoPadInnerX = 1 << 23,
	ImGuiTableFlags_ScrollX = 1 << 24,
	ImGuiTableFlags_ScrollY = 1 << 25,
	ImGuiTableFlags_SortMulti = 1 << 26,
	ImGuiTableFlags_SortTristate = 1 << 27,
	ImGuiTableFlags_HighlightHoveredColumn = 1 << 28,
	ImGuiTableFlags_SizingMask_ = ImGuiTableFlags_SizingFixedFit | ImGuiTableFlags_SizingFixedSame | ImGuiTableFlags_SizingStretchProp | ImGuiTableFlags_SizingStretchSame,
}
enum : ImGuiTableFlags_ {
	ImGuiTableFlags_None = ImGuiTableFlags_.ImGuiTableFlags_None,
	ImGuiTableFlags_Resizable = ImGuiTableFlags_.ImGuiTableFlags_Resizable,
	ImGuiTableFlags_Reorderable = ImGuiTableFlags_.ImGuiTableFlags_Reorderable,
	ImGuiTableFlags_Hideable = ImGuiTableFlags_.ImGuiTableFlags_Hideable,
	ImGuiTableFlags_Sortable = ImGuiTableFlags_.ImGuiTableFlags_Sortable,
	ImGuiTableFlags_NoSavedSettings = ImGuiTableFlags_.ImGuiTableFlags_NoSavedSettings,
	ImGuiTableFlags_ContextMenuInBody = ImGuiTableFlags_.ImGuiTableFlags_ContextMenuInBody,
	ImGuiTableFlags_RowBg = ImGuiTableFlags_.ImGuiTableFlags_RowBg,
	ImGuiTableFlags_BordersInnerH = ImGuiTableFlags_.ImGuiTableFlags_BordersInnerH,
	ImGuiTableFlags_BordersOuterH = ImGuiTableFlags_.ImGuiTableFlags_BordersOuterH,
	ImGuiTableFlags_BordersInnerV = ImGuiTableFlags_.ImGuiTableFlags_BordersInnerV,
	ImGuiTableFlags_BordersOuterV = ImGuiTableFlags_.ImGuiTableFlags_BordersOuterV,
	ImGuiTableFlags_BordersH = ImGuiTableFlags_.ImGuiTableFlags_BordersH,
	ImGuiTableFlags_BordersV = ImGuiTableFlags_.ImGuiTableFlags_BordersV,
	ImGuiTableFlags_BordersInner = ImGuiTableFlags_.ImGuiTableFlags_BordersInner,
	ImGuiTableFlags_BordersOuter = ImGuiTableFlags_.ImGuiTableFlags_BordersOuter,
	ImGuiTableFlags_Borders = ImGuiTableFlags_.ImGuiTableFlags_Borders,
	ImGuiTableFlags_NoBordersInBody = ImGuiTableFlags_.ImGuiTableFlags_NoBordersInBody,
	ImGuiTableFlags_NoBordersInBodyUntilResize = ImGuiTableFlags_.ImGuiTableFlags_NoBordersInBodyUntilResize,
	ImGuiTableFlags_SizingFixedFit = ImGuiTableFlags_.ImGuiTableFlags_SizingFixedFit,
	ImGuiTableFlags_SizingFixedSame = ImGuiTableFlags_.ImGuiTableFlags_SizingFixedSame,
	ImGuiTableFlags_SizingStretchProp = ImGuiTableFlags_.ImGuiTableFlags_SizingStretchProp,
	ImGuiTableFlags_SizingStretchSame = ImGuiTableFlags_.ImGuiTableFlags_SizingStretchSame,
	ImGuiTableFlags_NoHostExtendX = ImGuiTableFlags_.ImGuiTableFlags_NoHostExtendX,
	ImGuiTableFlags_NoHostExtendY = ImGuiTableFlags_.ImGuiTableFlags_NoHostExtendY,
	ImGuiTableFlags_NoKeepColumnsVisible = ImGuiTableFlags_.ImGuiTableFlags_NoKeepColumnsVisible,
	ImGuiTableFlags_PreciseWidths = ImGuiTableFlags_.ImGuiTableFlags_PreciseWidths,
	ImGuiTableFlags_NoClip = ImGuiTableFlags_.ImGuiTableFlags_NoClip,
	ImGuiTableFlags_PadOuterX = ImGuiTableFlags_.ImGuiTableFlags_PadOuterX,
	ImGuiTableFlags_NoPadOuterX = ImGuiTableFlags_.ImGuiTableFlags_NoPadOuterX,
	ImGuiTableFlags_NoPadInnerX = ImGuiTableFlags_.ImGuiTableFlags_NoPadInnerX,
	ImGuiTableFlags_ScrollX = ImGuiTableFlags_.ImGuiTableFlags_ScrollX,
	ImGuiTableFlags_ScrollY = ImGuiTableFlags_.ImGuiTableFlags_ScrollY,
	ImGuiTableFlags_SortMulti = ImGuiTableFlags_.ImGuiTableFlags_SortMulti,
	ImGuiTableFlags_SortTristate = ImGuiTableFlags_.ImGuiTableFlags_SortTristate,
	ImGuiTableFlags_HighlightHoveredColumn = ImGuiTableFlags_.ImGuiTableFlags_HighlightHoveredColumn,
	ImGuiTableFlags_SizingMask_ = ImGuiTableFlags_.ImGuiTableFlags_SizingMask_,
}
enum ImGuiTableRowFlags_ {
	ImGuiTableRowFlags_None = 0,
	ImGuiTableRowFlags_Headers = 1 << 0,
}
enum : ImGuiTableRowFlags_ {
	ImGuiTableRowFlags_None = ImGuiTableRowFlags_.ImGuiTableRowFlags_None,
	ImGuiTableRowFlags_Headers = ImGuiTableRowFlags_.ImGuiTableRowFlags_Headers,
}
enum ImGuiTextFlags_ {
	ImGuiTextFlags_None = 0,
	ImGuiTextFlags_NoWidthForLargeClippedText = 1 << 0,
}
enum : ImGuiTextFlags_ {
	ImGuiTextFlags_None = ImGuiTextFlags_.ImGuiTextFlags_None,
	ImGuiTextFlags_NoWidthForLargeClippedText = ImGuiTextFlags_.ImGuiTextFlags_NoWidthForLargeClippedText,
}
enum ImGuiTooltipFlags_ {
	ImGuiTooltipFlags_None = 0,
	ImGuiTooltipFlags_OverridePrevious = 1 << 1,
}
enum : ImGuiTooltipFlags_ {
	ImGuiTooltipFlags_None = ImGuiTooltipFlags_.ImGuiTooltipFlags_None,
	ImGuiTooltipFlags_OverridePrevious = ImGuiTooltipFlags_.ImGuiTooltipFlags_OverridePrevious,
}
enum ImGuiTreeNodeFlagsPrivate_ {
	ImGuiTreeNodeFlags_ClipLabelForTrailingButton = 1 << 28,
	ImGuiTreeNodeFlags_UpsideDownArrow = 1 << 29,
}
enum : ImGuiTreeNodeFlagsPrivate_ {
	ImGuiTreeNodeFlags_ClipLabelForTrailingButton = ImGuiTreeNodeFlagsPrivate_.ImGuiTreeNodeFlags_ClipLabelForTrailingButton,
	ImGuiTreeNodeFlags_UpsideDownArrow = ImGuiTreeNodeFlagsPrivate_.ImGuiTreeNodeFlags_UpsideDownArrow,
}
enum ImGuiTreeNodeFlags_ {
	ImGuiTreeNodeFlags_None = 0,
	ImGuiTreeNodeFlags_Selected = 1 << 0,
	ImGuiTreeNodeFlags_Framed = 1 << 1,
	ImGuiTreeNodeFlags_AllowOverlap = 1 << 2,
	ImGuiTreeNodeFlags_NoTreePushOnOpen = 1 << 3,
	ImGuiTreeNodeFlags_NoAutoOpenOnLog = 1 << 4,
	ImGuiTreeNodeFlags_DefaultOpen = 1 << 5,
	ImGuiTreeNodeFlags_OpenOnDoubleClick = 1 << 6,
	ImGuiTreeNodeFlags_OpenOnArrow = 1 << 7,
	ImGuiTreeNodeFlags_Leaf = 1 << 8,
	ImGuiTreeNodeFlags_Bullet = 1 << 9,
	ImGuiTreeNodeFlags_FramePadding = 1 << 10,
	ImGuiTreeNodeFlags_SpanAvailWidth = 1 << 11,
	ImGuiTreeNodeFlags_SpanFullWidth = 1 << 12,
	ImGuiTreeNodeFlags_SpanTextWidth = 1 << 13,
	ImGuiTreeNodeFlags_SpanAllColumns = 1 << 14,
	ImGuiTreeNodeFlags_NavLeftJumpsBackHere = 1 << 15,
	ImGuiTreeNodeFlags_CollapsingHeader = ImGuiTreeNodeFlags_Framed | ImGuiTreeNodeFlags_NoTreePushOnOpen | ImGuiTreeNodeFlags_NoAutoOpenOnLog,
}
enum : ImGuiTreeNodeFlags_ {
	ImGuiTreeNodeFlags_None = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_None,
	ImGuiTreeNodeFlags_Selected = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_Selected,
	ImGuiTreeNodeFlags_Framed = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_Framed,
	ImGuiTreeNodeFlags_AllowOverlap = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_AllowOverlap,
	ImGuiTreeNodeFlags_NoTreePushOnOpen = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_NoTreePushOnOpen,
	ImGuiTreeNodeFlags_NoAutoOpenOnLog = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_NoAutoOpenOnLog,
	ImGuiTreeNodeFlags_DefaultOpen = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_DefaultOpen,
	ImGuiTreeNodeFlags_OpenOnDoubleClick = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_OpenOnDoubleClick,
	ImGuiTreeNodeFlags_OpenOnArrow = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_OpenOnArrow,
	ImGuiTreeNodeFlags_Leaf = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_Leaf,
	ImGuiTreeNodeFlags_Bullet = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_Bullet,
	ImGuiTreeNodeFlags_FramePadding = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_FramePadding,
	ImGuiTreeNodeFlags_SpanAvailWidth = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_SpanAvailWidth,
	ImGuiTreeNodeFlags_SpanFullWidth = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_SpanFullWidth,
	ImGuiTreeNodeFlags_SpanTextWidth = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_SpanTextWidth,
	ImGuiTreeNodeFlags_SpanAllColumns = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_SpanAllColumns,
	ImGuiTreeNodeFlags_NavLeftJumpsBackHere = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_NavLeftJumpsBackHere,
	ImGuiTreeNodeFlags_CollapsingHeader = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_CollapsingHeader,
}
enum ImGuiTypingSelectFlags_ {
	ImGuiTypingSelectFlags_None = 0,
	ImGuiTypingSelectFlags_AllowBackspace = 1 << 0,
	ImGuiTypingSelectFlags_AllowSingleCharMode = 1 << 1,
}
enum : ImGuiTypingSelectFlags_ {
	ImGuiTypingSelectFlags_None = ImGuiTypingSelectFlags_.ImGuiTypingSelectFlags_None,
	ImGuiTypingSelectFlags_AllowBackspace = ImGuiTypingSelectFlags_.ImGuiTypingSelectFlags_AllowBackspace,
	ImGuiTypingSelectFlags_AllowSingleCharMode = ImGuiTypingSelectFlags_.ImGuiTypingSelectFlags_AllowSingleCharMode,
}
enum ImGuiViewportFlags_ {
	ImGuiViewportFlags_None = 0,
	ImGuiViewportFlags_IsPlatformWindow = 1 << 0,
	ImGuiViewportFlags_IsPlatformMonitor = 1 << 1,
	ImGuiViewportFlags_OwnedByApp = 1 << 2,
	ImGuiViewportFlags_NoDecoration = 1 << 3,
	ImGuiViewportFlags_NoTaskBarIcon = 1 << 4,
	ImGuiViewportFlags_NoFocusOnAppearing = 1 << 5,
	ImGuiViewportFlags_NoFocusOnClick = 1 << 6,
	ImGuiViewportFlags_NoInputs = 1 << 7,
	ImGuiViewportFlags_NoRendererClear = 1 << 8,
	ImGuiViewportFlags_NoAutoMerge = 1 << 9,
	ImGuiViewportFlags_TopMost = 1 << 10,
	ImGuiViewportFlags_CanHostOtherWindows = 1 << 11,
	ImGuiViewportFlags_IsMinimized = 1 << 12,
	ImGuiViewportFlags_IsFocused = 1 << 13,
}
enum : ImGuiViewportFlags_ {
	ImGuiViewportFlags_None = ImGuiViewportFlags_.ImGuiViewportFlags_None,
	ImGuiViewportFlags_IsPlatformWindow = ImGuiViewportFlags_.ImGuiViewportFlags_IsPlatformWindow,
	ImGuiViewportFlags_IsPlatformMonitor = ImGuiViewportFlags_.ImGuiViewportFlags_IsPlatformMonitor,
	ImGuiViewportFlags_OwnedByApp = ImGuiViewportFlags_.ImGuiViewportFlags_OwnedByApp,
	ImGuiViewportFlags_NoDecoration = ImGuiViewportFlags_.ImGuiViewportFlags_NoDecoration,
	ImGuiViewportFlags_NoTaskBarIcon = ImGuiViewportFlags_.ImGuiViewportFlags_NoTaskBarIcon,
	ImGuiViewportFlags_NoFocusOnAppearing = ImGuiViewportFlags_.ImGuiViewportFlags_NoFocusOnAppearing,
	ImGuiViewportFlags_NoFocusOnClick = ImGuiViewportFlags_.ImGuiViewportFlags_NoFocusOnClick,
	ImGuiViewportFlags_NoInputs = ImGuiViewportFlags_.ImGuiViewportFlags_NoInputs,
	ImGuiViewportFlags_NoRendererClear = ImGuiViewportFlags_.ImGuiViewportFlags_NoRendererClear,
	ImGuiViewportFlags_NoAutoMerge = ImGuiViewportFlags_.ImGuiViewportFlags_NoAutoMerge,
	ImGuiViewportFlags_TopMost = ImGuiViewportFlags_.ImGuiViewportFlags_TopMost,
	ImGuiViewportFlags_CanHostOtherWindows = ImGuiViewportFlags_.ImGuiViewportFlags_CanHostOtherWindows,
	ImGuiViewportFlags_IsMinimized = ImGuiViewportFlags_.ImGuiViewportFlags_IsMinimized,
	ImGuiViewportFlags_IsFocused = ImGuiViewportFlags_.ImGuiViewportFlags_IsFocused,
}
enum ImGuiWindowDockStyleCol {
	ImGuiWindowDockStyleCol_Text,
	ImGuiWindowDockStyleCol_TabHovered,
	ImGuiWindowDockStyleCol_TabFocused,
	ImGuiWindowDockStyleCol_TabSelected,
	ImGuiWindowDockStyleCol_TabSelectedOverline,
	ImGuiWindowDockStyleCol_TabDimmed,
	ImGuiWindowDockStyleCol_TabDimmedSelected,
	ImGuiWindowDockStyleCol_TabDimmedSelectedOverline,
	ImGuiWindowDockStyleCol_COUNT,
}
enum : ImGuiWindowDockStyleCol {
	ImGuiWindowDockStyleCol_Text = ImGuiWindowDockStyleCol.ImGuiWindowDockStyleCol_Text,
	ImGuiWindowDockStyleCol_TabHovered = ImGuiWindowDockStyleCol.ImGuiWindowDockStyleCol_TabHovered,
	ImGuiWindowDockStyleCol_TabFocused = ImGuiWindowDockStyleCol.ImGuiWindowDockStyleCol_TabFocused,
	ImGuiWindowDockStyleCol_TabSelected = ImGuiWindowDockStyleCol.ImGuiWindowDockStyleCol_TabSelected,
	ImGuiWindowDockStyleCol_TabSelectedOverline = ImGuiWindowDockStyleCol.ImGuiWindowDockStyleCol_TabSelectedOverline,
	ImGuiWindowDockStyleCol_TabDimmed = ImGuiWindowDockStyleCol.ImGuiWindowDockStyleCol_TabDimmed,
	ImGuiWindowDockStyleCol_TabDimmedSelected = ImGuiWindowDockStyleCol.ImGuiWindowDockStyleCol_TabDimmedSelected,
	ImGuiWindowDockStyleCol_TabDimmedSelectedOverline = ImGuiWindowDockStyleCol.ImGuiWindowDockStyleCol_TabDimmedSelectedOverline,
	ImGuiWindowDockStyleCol_COUNT = ImGuiWindowDockStyleCol.ImGuiWindowDockStyleCol_COUNT,
}
enum ImGuiWindowFlags_ {
	ImGuiWindowFlags_None = 0,
	ImGuiWindowFlags_NoTitleBar = 1 << 0,
	ImGuiWindowFlags_NoResize = 1 << 1,
	ImGuiWindowFlags_NoMove = 1 << 2,
	ImGuiWindowFlags_NoScrollbar = 1 << 3,
	ImGuiWindowFlags_NoScrollWithMouse = 1 << 4,
	ImGuiWindowFlags_NoCollapse = 1 << 5,
	ImGuiWindowFlags_AlwaysAutoResize = 1 << 6,
	ImGuiWindowFlags_NoBackground = 1 << 7,
	ImGuiWindowFlags_NoSavedSettings = 1 << 8,
	ImGuiWindowFlags_NoMouseInputs = 1 << 9,
	ImGuiWindowFlags_MenuBar = 1 << 10,
	ImGuiWindowFlags_HorizontalScrollbar = 1 << 11,
	ImGuiWindowFlags_NoFocusOnAppearing = 1 << 12,
	ImGuiWindowFlags_NoBringToFrontOnFocus = 1 << 13,
	ImGuiWindowFlags_AlwaysVerticalScrollbar = 1 << 14,
	ImGuiWindowFlags_AlwaysHorizontalScrollbar = 1 << 15,
	ImGuiWindowFlags_NoNavInputs = 1 << 16,
	ImGuiWindowFlags_NoNavFocus = 1 << 17,
	ImGuiWindowFlags_UnsavedDocument = 1 << 18,
	ImGuiWindowFlags_NoDocking = 1 << 19,
	ImGuiWindowFlags_NoNav = ImGuiWindowFlags_NoNavInputs | ImGuiWindowFlags_NoNavFocus,
	ImGuiWindowFlags_NoDecoration = ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse,
	ImGuiWindowFlags_NoInputs = ImGuiWindowFlags_NoMouseInputs | ImGuiWindowFlags_NoNavInputs | ImGuiWindowFlags_NoNavFocus,
	ImGuiWindowFlags_ChildWindow = 1 << 24,
	ImGuiWindowFlags_Tooltip = 1 << 25,
	ImGuiWindowFlags_Popup = 1 << 26,
	ImGuiWindowFlags_Modal = 1 << 27,
	ImGuiWindowFlags_ChildMenu = 1 << 28,
	ImGuiWindowFlags_DockNodeHost = 1 << 29,
}
enum : ImGuiWindowFlags_ {
	ImGuiWindowFlags_None = ImGuiWindowFlags_.ImGuiWindowFlags_None,
	ImGuiWindowFlags_NoTitleBar = ImGuiWindowFlags_.ImGuiWindowFlags_NoTitleBar,
	ImGuiWindowFlags_NoResize = ImGuiWindowFlags_.ImGuiWindowFlags_NoResize,
	ImGuiWindowFlags_NoMove = ImGuiWindowFlags_.ImGuiWindowFlags_NoMove,
	ImGuiWindowFlags_NoScrollbar = ImGuiWindowFlags_.ImGuiWindowFlags_NoScrollbar,
	ImGuiWindowFlags_NoScrollWithMouse = ImGuiWindowFlags_.ImGuiWindowFlags_NoScrollWithMouse,
	ImGuiWindowFlags_NoCollapse = ImGuiWindowFlags_.ImGuiWindowFlags_NoCollapse,
	ImGuiWindowFlags_AlwaysAutoResize = ImGuiWindowFlags_.ImGuiWindowFlags_AlwaysAutoResize,
	ImGuiWindowFlags_NoBackground = ImGuiWindowFlags_.ImGuiWindowFlags_NoBackground,
	ImGuiWindowFlags_NoSavedSettings = ImGuiWindowFlags_.ImGuiWindowFlags_NoSavedSettings,
	ImGuiWindowFlags_NoMouseInputs = ImGuiWindowFlags_.ImGuiWindowFlags_NoMouseInputs,
	ImGuiWindowFlags_MenuBar = ImGuiWindowFlags_.ImGuiWindowFlags_MenuBar,
	ImGuiWindowFlags_HorizontalScrollbar = ImGuiWindowFlags_.ImGuiWindowFlags_HorizontalScrollbar,
	ImGuiWindowFlags_NoFocusOnAppearing = ImGuiWindowFlags_.ImGuiWindowFlags_NoFocusOnAppearing,
	ImGuiWindowFlags_NoBringToFrontOnFocus = ImGuiWindowFlags_.ImGuiWindowFlags_NoBringToFrontOnFocus,
	ImGuiWindowFlags_AlwaysVerticalScrollbar = ImGuiWindowFlags_.ImGuiWindowFlags_AlwaysVerticalScrollbar,
	ImGuiWindowFlags_AlwaysHorizontalScrollbar = ImGuiWindowFlags_.ImGuiWindowFlags_AlwaysHorizontalScrollbar,
	ImGuiWindowFlags_NoNavInputs = ImGuiWindowFlags_.ImGuiWindowFlags_NoNavInputs,
	ImGuiWindowFlags_NoNavFocus = ImGuiWindowFlags_.ImGuiWindowFlags_NoNavFocus,
	ImGuiWindowFlags_UnsavedDocument = ImGuiWindowFlags_.ImGuiWindowFlags_UnsavedDocument,
	ImGuiWindowFlags_NoDocking = ImGuiWindowFlags_.ImGuiWindowFlags_NoDocking,
	ImGuiWindowFlags_NoNav = ImGuiWindowFlags_.ImGuiWindowFlags_NoNav,
	ImGuiWindowFlags_NoDecoration = ImGuiWindowFlags_.ImGuiWindowFlags_NoDecoration,
	ImGuiWindowFlags_NoInputs = ImGuiWindowFlags_.ImGuiWindowFlags_NoInputs,
	ImGuiWindowFlags_ChildWindow = ImGuiWindowFlags_.ImGuiWindowFlags_ChildWindow,
	ImGuiWindowFlags_Tooltip = ImGuiWindowFlags_.ImGuiWindowFlags_Tooltip,
	ImGuiWindowFlags_Popup = ImGuiWindowFlags_.ImGuiWindowFlags_Popup,
	ImGuiWindowFlags_Modal = ImGuiWindowFlags_.ImGuiWindowFlags_Modal,
	ImGuiWindowFlags_ChildMenu = ImGuiWindowFlags_.ImGuiWindowFlags_ChildMenu,
	ImGuiWindowFlags_DockNodeHost = ImGuiWindowFlags_.ImGuiWindowFlags_DockNodeHost,
}
enum ImGuiWindowRefreshFlags_ {
	ImGuiWindowRefreshFlags_None = 0,
	ImGuiWindowRefreshFlags_TryToAvoidRefresh = 1 << 0,
	ImGuiWindowRefreshFlags_RefreshOnHover = 1 << 1,
	ImGuiWindowRefreshFlags_RefreshOnFocus = 1 << 2,
}
enum : ImGuiWindowRefreshFlags_ {
	ImGuiWindowRefreshFlags_None = ImGuiWindowRefreshFlags_.ImGuiWindowRefreshFlags_None,
	ImGuiWindowRefreshFlags_TryToAvoidRefresh = ImGuiWindowRefreshFlags_.ImGuiWindowRefreshFlags_TryToAvoidRefresh,
	ImGuiWindowRefreshFlags_RefreshOnHover = ImGuiWindowRefreshFlags_.ImGuiWindowRefreshFlags_RefreshOnHover,
	ImGuiWindowRefreshFlags_RefreshOnFocus = ImGuiWindowRefreshFlags_.ImGuiWindowRefreshFlags_RefreshOnFocus,
}

// Unions

// Structs
struct ImBitArray_ImGuiKey_NamedKey_COUNT__lessImGuiKey_NamedKey_BEGIN {
	ImU32[(ImGuiKey_NamedKey_COUNT + 31) >> 5] Storage;
}
struct ImBitVector {
	ImVector!ImU32 Storage;
}
struct ImColor {
	ImVec4 Value;
}
struct ImDrawChannel {
	ImVector!ImDrawCmd _CmdBuffer;
	ImVector!ImDrawIdx _IdxBuffer;
}
struct ImDrawCmd {
	ImVec4 ClipRect;
	ImTextureID TextureId;
	uint VtxOffset;
	uint IdxOffset;
	uint ElemCount;
	ImDrawCallback UserCallback;
	void* UserCallbackData;
}
struct ImDrawCmdHeader {
	ImVec4 ClipRect;
	ImTextureID TextureId;
	uint VtxOffset;
}
struct ImDrawData {
	bool Valid;
	int CmdListsCount;
	int TotalIdxCount;
	int TotalVtxCount;
	ImVector!(ImDrawList*) CmdLists;
	ImVec2 DisplayPos;
	ImVec2 DisplaySize;
	ImVec2 FramebufferScale;
	ImGuiViewport* OwnerViewport;
}
struct ImDrawDataBuilder {
	ImVector!(ImDrawList*)*[2] Layers;
	ImVector!(ImDrawList*) LayerData1;
}
struct ImDrawList {
	ImVector!ImDrawCmd CmdBuffer;
	ImVector!ImDrawIdx IdxBuffer;
	ImVector!ImDrawVert VtxBuffer;
	ImDrawListFlags Flags;
	uint _VtxCurrentIdx;
	ImDrawListSharedData* _Data;
	ImDrawVert* _VtxWritePtr;
	ImDrawIdx* _IdxWritePtr;
	ImVector!ImVec2 _Path;
	ImDrawCmdHeader _CmdHeader;
	ImDrawListSplitter _Splitter;
	ImVector!ImVec4 _ClipRectStack;
	ImVector!ImTextureID _TextureIdStack;
	float _FringeScale;
	immutable(char)* _OwnerName;
}
struct ImDrawListSharedData {
	ImVec2 TexUvWhitePixel;
	ImFont* Font;
	float FontSize;
	float FontScale;
	float CurveTessellationTol;
	float CircleSegmentMaxError;
	ImVec4 ClipRectFullscreen;
	ImDrawListFlags InitialFlags;
	ImVector!ImVec2 TempBuffer;
	ImVec2[48] ArcFastVtx;
	float ArcFastRadiusCutoff;
	ImU8[64] CircleSegmentCounts;
	ImVec4* TexUvLines;
}
struct ImDrawListSplitter {
	int _Current;
	int _Count;
	ImVector!ImDrawChannel _Channels;
}
struct ImDrawVert {
	ImVec2 pos;
	ImVec2 uv;
	ImU32 col;
}
struct ImFont {
	ImVector!float IndexAdvanceX;
	float FallbackAdvanceX;
	float FontSize;
	ImVector!ImWchar IndexLookup;
	ImVector!ImFontGlyph Glyphs;
	ImFontGlyph* FallbackGlyph;
	ImFontAtlas* ContainerAtlas;
	ImFontConfig* ConfigData;
	short ConfigDataCount;
	ImWchar FallbackChar;
	ImWchar EllipsisChar;
	short EllipsisCharCount;
	float EllipsisWidth;
	float EllipsisCharStep;
	bool DirtyLookupTables;
	float Scale;
	float Ascent;
	float Descent;
	int MetricsTotalSurface;
	ImU8[(0xFFFF + 1) / 4096 / 8] Used4kPagesMap;
}
struct ImFontAtlas {
	ImFontAtlasFlags Flags;
	ImTextureID TexID;
	int TexDesiredWidth;
	int TexGlyphPadding;
	bool Locked;
	void* UserData;
	bool TexReady;
	bool TexPixelsUseColors;
	ubyte* TexPixelsAlpha8;
	uint* TexPixelsRGBA32;
	int TexWidth;
	int TexHeight;
	ImVec2 TexUvScale;
	ImVec2 TexUvWhitePixel;
	ImVector!(ImFont*) Fonts;
	ImVector!ImFontAtlasCustomRect CustomRects;
	ImVector!ImFontConfig ConfigData;
	ImVec4[(63) + 1] TexUvLines;
	ImFontBuilderIO* FontBuilderIO;
	uint FontBuilderFlags;
	int PackIdMouseCursors;
	int PackIdLines;
}
struct ImFontAtlasCustomRect {
	ushort Width;
	ushort Height;
	ushort X;
	ushort Y;
	uint GlyphID;
	float GlyphAdvanceX;
	ImVec2 GlyphOffset;
	ImFont* Font;
}
struct ImFontBuilderIO {
	extern(C) bool function(ImFontAtlas* atlas) nothrow FontBuilder_Build;
}
struct ImFontConfig {
	void* FontData;
	int FontDataSize;
	bool FontDataOwnedByAtlas;
	int FontNo;
	float SizePixels;
	int OversampleH;
	int OversampleV;
	bool PixelSnapH;
	ImVec2 GlyphExtraSpacing;
	ImVec2 GlyphOffset;
	ImWchar* GlyphRanges;
	float GlyphMinAdvanceX;
	float GlyphMaxAdvanceX;
	bool MergeMode;
	uint FontBuilderFlags;
	float RasterizerMultiply;
	float RasterizerDensity;
	ImWchar EllipsisChar;
	char[40] Name;
	ImFont* DstFont;
}
struct ImFontGlyph {
	uint Colored;
	uint Visible;
	uint Codepoint;
	float AdvanceX;
	float X0;
	float Y0;
	float X1;
	float Y1;
	float U0;
	float V0;
	float U1;
	float V1;
}
struct ImFontGlyphRangesBuilder {
	ImVector!ImU32 UsedChars;
}
struct ImGuiBoxSelectState {
	ImGuiID ID;
	bool IsActive;
	bool IsStarting;
	bool IsStartedFromVoid;
	bool IsStartedSetNavIdOnce;
	bool RequestClear;
	ImGuiKeyChord KeyMods;
	ImVec2 StartPosRel;
	ImVec2 EndPosRel;
	ImVec2 ScrollAccum;
	ImGuiWindow* Window;
	bool UnclipMode;
	ImRect UnclipRect;
	ImRect BoxSelectRectPrev;
	ImRect BoxSelectRectCurr;
}
struct ImGuiColorMod {
	ImGuiCol Col;
	ImVec4 BackupValue;
}
struct ImGuiComboPreviewData {
	ImRect PreviewRect;
	ImVec2 BackupCursorPos;
	ImVec2 BackupCursorMaxPos;
	ImVec2 BackupCursorPosPrevLine;
	float BackupPrevLineTextBaseOffset;
	ImGuiLayoutType BackupLayout;
}
struct ImGuiContext {
	bool Initialized;
	bool FontAtlasOwnedByContext;
	ImGuiIO IO;
	ImGuiPlatformIO PlatformIO;
	ImGuiStyle Style;
	ImGuiConfigFlags ConfigFlagsCurrFrame;
	ImGuiConfigFlags ConfigFlagsLastFrame;
	ImFont* Font;
	float FontSize;
	float FontBaseSize;
	float FontScale;
	float CurrentDpiScale;
	ImDrawListSharedData DrawListSharedData;
	double Time;
	int FrameCount;
	int FrameCountEnded;
	int FrameCountPlatformEnded;
	int FrameCountRendered;
	bool WithinFrameScope;
	bool WithinFrameScopeWithImplicitWindow;
	bool WithinEndChild;
	bool GcCompactAll;
	bool TestEngineHookItems;
	void* TestEngine;
	char[16] ContextName;
	ImVector!ImGuiInputEvent InputEventsQueue;
	ImVector!ImGuiInputEvent InputEventsTrail;
	ImGuiMouseSource InputEventsNextMouseSource;
	ImU32 InputEventsNextEventId;
	ImVector!(ImGuiWindow*) Windows;
	ImVector!(ImGuiWindow*) WindowsFocusOrder;
	ImVector!(ImGuiWindow*) WindowsTempSortBuffer;
	ImVector!ImGuiWindowStackData CurrentWindowStack;
	ImGuiStorage WindowsById;
	int WindowsActiveCount;
	ImVec2 WindowsHoverPadding;
	ImGuiID DebugBreakInWindow;
	ImGuiWindow* CurrentWindow;
	ImGuiWindow* HoveredWindow;
	ImGuiWindow* HoveredWindowUnderMovingWindow;
	ImGuiWindow* HoveredWindowBeforeClear;
	ImGuiWindow* MovingWindow;
	ImGuiWindow* WheelingWindow;
	ImVec2 WheelingWindowRefMousePos;
	int WheelingWindowStartFrame;
	int WheelingWindowScrolledFrame;
	float WheelingWindowReleaseTimer;
	ImVec2 WheelingWindowWheelRemainder;
	ImVec2 WheelingAxisAvg;
	ImGuiID DebugHookIdInfo;
	ImGuiID HoveredId;
	ImGuiID HoveredIdPreviousFrame;
	float HoveredIdTimer;
	float HoveredIdNotActiveTimer;
	bool HoveredIdAllowOverlap;
	bool HoveredIdIsDisabled;
	bool ItemUnclipByLog;
	ImGuiID ActiveId;
	ImGuiID ActiveIdIsAlive;
	float ActiveIdTimer;
	bool ActiveIdIsJustActivated;
	bool ActiveIdAllowOverlap;
	bool ActiveIdNoClearOnFocusLoss;
	bool ActiveIdHasBeenPressedBefore;
	bool ActiveIdHasBeenEditedBefore;
	bool ActiveIdHasBeenEditedThisFrame;
	bool ActiveIdFromShortcut;
	int ActiveIdMouseButton;
	ImVec2 ActiveIdClickOffset;
	ImGuiWindow* ActiveIdWindow;
	ImGuiInputSource ActiveIdSource;
	ImGuiID ActiveIdPreviousFrame;
	bool ActiveIdPreviousFrameIsAlive;
	bool ActiveIdPreviousFrameHasBeenEditedBefore;
	ImGuiWindow* ActiveIdPreviousFrameWindow;
	ImGuiID LastActiveId;
	float LastActiveIdTimer;
	double LastKeyModsChangeTime;
	double LastKeyModsChangeFromNoneTime;
	double LastKeyboardKeyPressTime;
	ImBitArrayForNamedKeys KeysMayBeCharInput;
	ImGuiKeyOwnerData[ImGuiKey_NamedKey_COUNT] KeysOwnerData;
	ImGuiKeyRoutingTable KeysRoutingTable;
	ImU32 ActiveIdUsingNavDirMask;
	bool ActiveIdUsingAllKeyboardKeys;
	ImGuiKeyChord DebugBreakInShortcutRouting;
	ImGuiID CurrentFocusScopeId;
	ImGuiItemFlags CurrentItemFlags;
	ImGuiID DebugLocateId;
	ImGuiNextItemData NextItemData;
	ImGuiLastItemData LastItemData;
	ImGuiNextWindowData NextWindowData;
	bool DebugShowGroupRects;
	ImGuiCol DebugFlashStyleColorIdx;
	ImVector!ImGuiColorMod ColorStack;
	ImVector!ImGuiStyleMod StyleVarStack;
	ImVector!(ImFont*) FontStack;
	ImVector!ImGuiFocusScopeData FocusScopeStack;
	ImVector!ImGuiItemFlags ItemFlagsStack;
	ImVector!ImGuiGroupData GroupStack;
	ImVector!ImGuiPopupData OpenPopupStack;
	ImVector!ImGuiPopupData BeginPopupStack;
	ImVector!ImGuiTreeNodeStackData TreeNodeStack;
	ImVector!(ImGuiViewportP*) Viewports;
	ImGuiViewportP* CurrentViewport;
	ImGuiViewportP* MouseViewport;
	ImGuiViewportP* MouseLastHoveredViewport;
	ImGuiID PlatformLastFocusedViewportId;
	ImGuiPlatformMonitor FallbackMonitor;
	ImRect PlatformMonitorsFullWorkRect;
	int ViewportCreatedCount;
	int PlatformWindowsCreatedCount;
	int ViewportFocusedStampCount;
	ImGuiWindow* NavWindow;
	ImGuiID NavId;
	ImGuiID NavFocusScopeId;
	ImGuiNavLayer NavLayer;
	ImGuiID NavActivateId;
	ImGuiID NavActivateDownId;
	ImGuiID NavActivatePressedId;
	ImGuiActivateFlags NavActivateFlags;
	ImVector!ImGuiFocusScopeData NavFocusRoute;
	ImGuiID NavHighlightActivatedId;
	float NavHighlightActivatedTimer;
	ImGuiID NavNextActivateId;
	ImGuiActivateFlags NavNextActivateFlags;
	ImGuiInputSource NavInputSource;
	ImGuiSelectionUserData NavLastValidSelectionUserData;
	bool NavIdIsAlive;
	bool NavMousePosDirty;
	bool NavDisableHighlight;
	bool NavDisableMouseHover;
	bool NavAnyRequest;
	bool NavInitRequest;
	bool NavInitRequestFromMove;
	ImGuiNavItemData NavInitResult;
	bool NavMoveSubmitted;
	bool NavMoveScoringItems;
	bool NavMoveForwardToNextFrame;
	ImGuiNavMoveFlags NavMoveFlags;
	ImGuiScrollFlags NavMoveScrollFlags;
	ImGuiKeyChord NavMoveKeyMods;
	ImGuiDir NavMoveDir;
	ImGuiDir NavMoveDirForDebug;
	ImGuiDir NavMoveClipDir;
	ImRect NavScoringRect;
	ImRect NavScoringNoClipRect;
	int NavScoringDebugCount;
	int NavTabbingDir;
	int NavTabbingCounter;
	ImGuiNavItemData NavMoveResultLocal;
	ImGuiNavItemData NavMoveResultLocalVisible;
	ImGuiNavItemData NavMoveResultOther;
	ImGuiNavItemData NavTabbingResultFirst;
	ImGuiID NavJustMovedFromFocusScopeId;
	ImGuiID NavJustMovedToId;
	ImGuiID NavJustMovedToFocusScopeId;
	ImGuiKeyChord NavJustMovedToKeyMods;
	bool NavJustMovedToIsTabbing;
	bool NavJustMovedToHasSelectionData;
	ImGuiKeyChord ConfigNavWindowingKeyNext;
	ImGuiKeyChord ConfigNavWindowingKeyPrev;
	ImGuiWindow* NavWindowingTarget;
	ImGuiWindow* NavWindowingTargetAnim;
	ImGuiWindow* NavWindowingListWindow;
	float NavWindowingTimer;
	float NavWindowingHighlightAlpha;
	bool NavWindowingToggleLayer;
	ImGuiKey NavWindowingToggleKey;
	ImVec2 NavWindowingAccumDeltaPos;
	ImVec2 NavWindowingAccumDeltaSize;
	float DimBgRatio;
	bool DragDropActive;
	bool DragDropWithinSource;
	bool DragDropWithinTarget;
	ImGuiDragDropFlags DragDropSourceFlags;
	int DragDropSourceFrameCount;
	int DragDropMouseButton;
	ImGuiPayload DragDropPayload;
	ImRect DragDropTargetRect;
	ImRect DragDropTargetClipRect;
	ImGuiID DragDropTargetId;
	ImGuiDragDropFlags DragDropAcceptFlags;
	float DragDropAcceptIdCurrRectSurface;
	ImGuiID DragDropAcceptIdCurr;
	ImGuiID DragDropAcceptIdPrev;
	int DragDropAcceptFrameCount;
	ImGuiID DragDropHoldJustPressedId;
	ImVector!ubyte DragDropPayloadBufHeap;
	ubyte[16] DragDropPayloadBufLocal;
	int ClipperTempDataStacked;
	ImVector!ImGuiListClipperData ClipperTempData;
	ImGuiTable* CurrentTable;
	ImGuiID DebugBreakInTable;
	int TablesTempDataStacked;
	ImVector!ImGuiTableTempData TablesTempData;
	ImPool!ImGuiTable Tables;
	ImVector!float TablesLastTimeActive;
	ImVector!ImDrawChannel DrawChannelsTempMergeBuffer;
	ImGuiTabBar* CurrentTabBar;
	ImPool!ImGuiTabBar TabBars;
	ImVector!ImGuiPtrOrIndex CurrentTabBarStack;
	ImVector!ImGuiShrinkWidthItem ShrinkWidthBuffer;
	ImGuiBoxSelectState BoxSelectState;
	ImGuiMultiSelectTempData* CurrentMultiSelect;
	int MultiSelectTempDataStacked;
	ImVector!ImGuiMultiSelectTempData MultiSelectTempData;
	ImPool!ImGuiMultiSelectState MultiSelectStorage;
	ImGuiID HoverItemDelayId;
	ImGuiID HoverItemDelayIdPreviousFrame;
	float HoverItemDelayTimer;
	float HoverItemDelayClearTimer;
	ImGuiID HoverItemUnlockedStationaryId;
	ImGuiID HoverWindowUnlockedStationaryId;
	ImGuiMouseCursor MouseCursor;
	float MouseStationaryTimer;
	ImVec2 MouseLastValidPos;
	ImGuiInputTextState InputTextState;
	ImGuiInputTextDeactivatedState InputTextDeactivatedState;
	ImFont InputTextPasswordFont;
	ImGuiID TempInputId;
	ImGuiDataTypeStorage DataTypeZeroValue;
	int BeginMenuDepth;
	int BeginComboDepth;
	ImGuiColorEditFlags ColorEditOptions;
	ImGuiID ColorEditCurrentID;
	ImGuiID ColorEditSavedID;
	float ColorEditSavedHue;
	float ColorEditSavedSat;
	ImU32 ColorEditSavedColor;
	ImVec4 ColorPickerRef;
	ImGuiComboPreviewData ComboPreviewData;
	ImRect WindowResizeBorderExpectedRect;
	bool WindowResizeRelativeMode;
	short ScrollbarSeekMode;
	float ScrollbarClickDeltaToGrabCenter;
	float SliderGrabClickOffset;
	float SliderCurrentAccum;
	bool SliderCurrentAccumDirty;
	bool DragCurrentAccumDirty;
	float DragCurrentAccum;
	float DragSpeedDefaultRatio;
	float DisabledAlphaBackup;
	short DisabledStackSize;
	short LockMarkEdited;
	short TooltipOverrideCount;
	ImVector!char ClipboardHandlerData;
	ImVector!ImGuiID MenusIdSubmittedThisFrame;
	ImGuiTypingSelectState TypingSelectState;
	ImGuiPlatformImeData PlatformImeData;
	ImGuiPlatformImeData PlatformImeDataPrev;
	ImGuiID PlatformImeViewport;
	ImGuiDockContext DockContext;
	extern(C) void function(ImGuiContext* ctx, ImGuiDockNode* node, ImGuiTabBar* tab_bar) nothrow DockNodeWindowMenuHandler;
	bool SettingsLoaded;
	float SettingsDirtyTimer;
	ImGuiTextBuffer SettingsIniData;
	ImVector!ImGuiSettingsHandler SettingsHandlers;
	ImChunkStream!ImGuiWindowSettings SettingsWindows;
	ImChunkStream!ImGuiTableSettings SettingsTables;
	ImVector!ImGuiContextHook Hooks;
	ImGuiID HookIdNext;
	immutable(char)*[ImGuiLocKey_COUNT] LocalizationTable;
	bool LogEnabled;
	ImGuiLogType LogType;
	ImFileHandle LogFile;
	ImGuiTextBuffer LogBuffer;
	immutable(char)* LogNextPrefix;
	immutable(char)* LogNextSuffix;
	float LogLinePosY;
	bool LogLineFirstItem;
	int LogDepthRef;
	int LogDepthToExpand;
	int LogDepthToExpandDefault;
	ImGuiDebugLogFlags DebugLogFlags;
	ImGuiTextBuffer DebugLogBuf;
	ImGuiTextIndex DebugLogIndex;
	ImGuiDebugLogFlags DebugLogAutoDisableFlags;
	ImU8 DebugLogAutoDisableFrames;
	ImU8 DebugLocateFrames;
	bool DebugBreakInLocateId;
	ImGuiKeyChord DebugBreakKeyChord;
	ImS8 DebugBeginReturnValueCullDepth;
	bool DebugItemPickerActive;
	ImU8 DebugItemPickerMouseButton;
	ImGuiID DebugItemPickerBreakId;
	float DebugFlashStyleColorTime;
	ImVec4 DebugFlashStyleColorBackup;
	ImGuiMetricsConfig DebugMetricsConfig;
	ImGuiIDStackTool DebugIDStackTool;
	ImGuiDebugAllocInfo DebugAllocInfo;
	ImGuiDockNode* DebugHoveredDockNode;
	float[60] FramerateSecPerFrame;
	int FramerateSecPerFrameIdx;
	int FramerateSecPerFrameCount;
	float FramerateSecPerFrameAccum;
	int WantCaptureMouseNextFrame;
	int WantCaptureKeyboardNextFrame;
	int WantTextInputNextFrame;
	ImVector!char TempBuffer;
	char[64] TempKeychordName;
}
struct ImGuiContextHook {
	ImGuiID HookId;
	ImGuiContextHookType Type;
	ImGuiID Owner;
	ImGuiContextHookCallback Callback;
	void* UserData;
}
struct ImGuiDataTypeInfo {
	size_t Size;
	immutable(char)* Name;
	immutable(char)* PrintFmt;
	immutable(char)* ScanFmt;
}
struct ImGuiDataTypeStorage {
	ImU8[8] Data;
}
struct ImGuiDataVarInfo {
	ImGuiDataType Type;
	ImU32 Count;
	ImU32 Offset;
}
struct ImGuiDebugAllocEntry {
	int FrameCount;
	ImS16 AllocCount;
	ImS16 FreeCount;
}
struct ImGuiDebugAllocInfo {
	int TotalAllocCount;
	int TotalFreeCount;
	ImS16 LastEntriesIdx;
	ImGuiDebugAllocEntry[6] LastEntriesBuf;
}
struct ImGuiDockContext {
	ImGuiStorage Nodes;
	ImVector!ImGuiDockRequest Requests;
	ImVector!ImGuiDockNodeSettings NodesSettings;
	bool WantFullRebuild;
}
struct ImGuiDockNode {
	ImGuiID ID;
	ImGuiDockNodeFlags SharedFlags;
	ImGuiDockNodeFlags LocalFlags;
	ImGuiDockNodeFlags LocalFlagsInWindows;
	ImGuiDockNodeFlags MergedFlags;
	ImGuiDockNodeState State;
	ImGuiDockNode* ParentNode;
	ImGuiDockNode*[2] ChildNodes;
	ImVector!(ImGuiWindow*) Windows;
	ImGuiTabBar* TabBar;
	ImVec2 Pos;
	ImVec2 Size;
	ImVec2 SizeRef;
	ImGuiAxis SplitAxis;
	ImGuiWindowClass WindowClass;
	ImU32 LastBgColor;
	ImGuiWindow* HostWindow;
	ImGuiWindow* VisibleWindow;
	ImGuiDockNode* CentralNode;
	ImGuiDockNode* OnlyNodeWithWindows;
	int CountNodeWithWindows;
	int LastFrameAlive;
	int LastFrameActive;
	int LastFrameFocused;
	ImGuiID LastFocusedNodeId;
	ImGuiID SelectedTabId;
	ImGuiID WantCloseTabId;
	ImGuiID RefViewportId;
	ImGuiDataAuthority AuthorityForPos;
	ImGuiDataAuthority AuthorityForSize;
	ImGuiDataAuthority AuthorityForViewport;
	bool IsVisible;
	bool IsFocused;
	bool IsBgDrawnThisFrame;
	bool HasCloseButton;
	bool HasWindowMenuButton;
	bool HasCentralNodeChild;
	bool WantCloseAll;
	bool WantLockSizeOnce;
	bool WantMouseMove;
	bool WantHiddenTabBarUpdate;
	bool WantHiddenTabBarToggle;
}
struct ImGuiDockNodeSettings {
}
struct ImGuiDockRequest {
}
struct ImGuiFocusScopeData {
	ImGuiID ID;
	ImGuiID WindowID;
}
struct ImGuiGroupData {
	ImGuiID WindowID;
	ImVec2 BackupCursorPos;
	ImVec2 BackupCursorMaxPos;
	ImVec2 BackupCursorPosPrevLine;
	ImVec1 BackupIndent;
	ImVec1 BackupGroupOffset;
	ImVec2 BackupCurrLineSize;
	float BackupCurrLineTextBaseOffset;
	ImGuiID BackupActiveIdIsAlive;
	bool BackupActiveIdPreviousFrameIsAlive;
	bool BackupHoveredIdIsAlive;
	bool BackupIsSameLine;
	bool EmitItem;
}
struct ImGuiIDStackTool {
	int LastActiveFrame;
	int StackLevel;
	ImGuiID QueryId;
	ImVector!ImGuiStackLevelInfo Results;
	bool CopyToClipboardOnCtrlC;
	float CopyToClipboardLastTime;
}
struct ImGuiIO {
	ImGuiConfigFlags ConfigFlags;
	ImGuiBackendFlags BackendFlags;
	ImVec2 DisplaySize;
	float DeltaTime;
	float IniSavingRate;
	immutable(char)* IniFilename;
	immutable(char)* LogFilename;
	void* UserData;
	ImFontAtlas* Fonts;
	float FontGlobalScale;
	bool FontAllowUserScaling;
	ImFont* FontDefault;
	ImVec2 DisplayFramebufferScale;
	bool ConfigDockingNoSplit;
	bool ConfigDockingWithShift;
	bool ConfigDockingAlwaysTabBar;
	bool ConfigDockingTransparentPayload;
	bool ConfigViewportsNoAutoMerge;
	bool ConfigViewportsNoTaskBarIcon;
	bool ConfigViewportsNoDecoration;
	bool ConfigViewportsNoDefaultParent;
	bool MouseDrawCursor;
	bool ConfigMacOSXBehaviors;
	bool ConfigNavSwapGamepadButtons;
	bool ConfigInputTrickleEventQueue;
	bool ConfigInputTextCursorBlink;
	bool ConfigInputTextEnterKeepActive;
	bool ConfigDragClickToInputText;
	bool ConfigWindowsResizeFromEdges;
	bool ConfigWindowsMoveFromTitleBarOnly;
	float ConfigMemoryCompactTimer;
	float MouseDoubleClickTime;
	float MouseDoubleClickMaxDist;
	float MouseDragThreshold;
	float KeyRepeatDelay;
	float KeyRepeatRate;
	bool ConfigDebugIsDebuggerPresent;
	bool ConfigDebugBeginReturnValueOnce;
	bool ConfigDebugBeginReturnValueLoop;
	bool ConfigDebugIgnoreFocusLoss;
	bool ConfigDebugIniSettings;
	immutable(char)* BackendPlatformName;
	immutable(char)* BackendRendererName;
	void* BackendPlatformUserData;
	void* BackendRendererUserData;
	void* BackendLanguageUserData;
	extern(C) immutable(char)* function(void* user_data) nothrow GetClipboardTextFn;
	extern(C) void function(void* user_data, immutable(char)* text) nothrow SetClipboardTextFn;
	void* ClipboardUserData;
	extern(C) bool function(ImGuiContext* ctx, immutable(char)* path) nothrow PlatformOpenInShellFn;
	void* PlatformOpenInShellUserData;
	extern(C) void function(ImGuiContext* ctx, ImGuiViewport* viewport, ImGuiPlatformImeData* data) nothrow PlatformSetImeDataFn;
	ImWchar PlatformLocaleDecimalPoint;
	bool WantCaptureMouse;
	bool WantCaptureKeyboard;
	bool WantTextInput;
	bool WantSetMousePos;
	bool WantSaveIniSettings;
	bool NavActive;
	bool NavVisible;
	float Framerate;
	int MetricsRenderVertices;
	int MetricsRenderIndices;
	int MetricsRenderWindows;
	int MetricsActiveWindows;
	ImVec2 MouseDelta;
	ImGuiContext* Ctx;
	ImVec2 MousePos;
	bool[5] MouseDown;
	float MouseWheel;
	float MouseWheelH;
	ImGuiMouseSource MouseSource;
	ImGuiID MouseHoveredViewport;
	bool KeyCtrl;
	bool KeyShift;
	bool KeyAlt;
	bool KeySuper;
	ImGuiKeyChord KeyMods;
	ImGuiKeyData[ImGuiKey_KeysData_SIZE] KeysData;
	bool WantCaptureMouseUnlessPopupClose;
	ImVec2 MousePosPrev;
	ImVec2[5] MouseClickedPos;
	double[5] MouseClickedTime;
	bool[5] MouseClicked;
	bool[5] MouseDoubleClicked;
	ImU16[5] MouseClickedCount;
	ImU16[5] MouseClickedLastCount;
	bool[5] MouseReleased;
	bool[5] MouseDownOwned;
	bool[5] MouseDownOwnedUnlessPopupClose;
	bool MouseWheelRequestAxisSwap;
	bool MouseCtrlLeftAsRightClick;
	float[5] MouseDownDuration;
	float[5] MouseDownDurationPrev;
	ImVec2[5] MouseDragMaxDistanceAbs;
	float[5] MouseDragMaxDistanceSqr;
	float PenPressure;
	bool AppFocusLost;
	bool AppAcceptingEvents;
	ImS8 BackendUsingLegacyKeyArrays;
	bool BackendUsingLegacyNavInputArray;
	ImWchar16 InputQueueSurrogate;
	ImVector!ImWchar InputQueueCharacters;
}
struct ImGuiInputEvent {
	ImGuiInputEventType Type;
	ImGuiInputSource Source;
	ImU32 EventId;
	union {
		ImGuiInputEventMousePos MousePos;
		ImGuiInputEventMouseWheel MouseWheel;
		ImGuiInputEventMouseButton MouseButton;
		ImGuiInputEventMouseViewport MouseViewport;
		ImGuiInputEventKey Key;
		ImGuiInputEventText Text;
		ImGuiInputEventAppFocused AppFocused;
	}
 	bool AddedByTestEngine;
}
struct ImGuiInputEventAppFocused {
	bool Focused;
}
struct ImGuiInputEventKey {
	ImGuiKey Key;
	bool Down;
	float AnalogValue;
}
struct ImGuiInputEventMouseButton {
	int Button;
	bool Down;
	ImGuiMouseSource MouseSource;
}
struct ImGuiInputEventMousePos {
	float PosX;
	float PosY;
	ImGuiMouseSource MouseSource;
}
struct ImGuiInputEventMouseViewport {
	ImGuiID HoveredViewportID;
}
struct ImGuiInputEventMouseWheel {
	float WheelX;
	float WheelY;
	ImGuiMouseSource MouseSource;
}
struct ImGuiInputEventText {
	uint Char;
}
struct ImGuiInputTextCallbackData {
	ImGuiContext* Ctx;
	ImGuiInputTextFlags EventFlag;
	ImGuiInputTextFlags Flags;
	void* UserData;
	ImWchar EventChar;
	ImGuiKey EventKey;
	immutable(char)* Buf;
	int BufTextLen;
	int BufSize;
	bool BufDirty;
	int CursorPos;
	int SelectionStart;
	int SelectionEnd;
}
struct ImGuiInputTextDeactivateData {
}
struct ImGuiInputTextDeactivatedState {
	ImGuiID ID;
	ImVector!char TextA;
}
struct ImGuiInputTextState {
	ImGuiContext* Ctx;
	ImGuiID ID;
	int CurLenW;
	int CurLenA;
	ImVector!ImWchar TextW;
	ImVector!char TextA;
	ImVector!char InitialTextA;
	bool TextAIsValid;
	int BufCapacityA;
	float ScrollX;
	STB_TexteditState Stb;
	float CursorAnim;
	bool CursorFollow;
	bool SelectedAllMouseLock;
	bool Edited;
	ImGuiInputTextFlags Flags;
	bool ReloadUserBuf;
	int ReloadSelectionStart;
	int ReloadSelectionEnd;
}
struct ImGuiKeyData {
	bool Down;
	float DownDuration;
	float DownDurationPrev;
	float AnalogValue;
}
struct ImGuiKeyOwnerData {
	ImGuiID OwnerCurr;
	ImGuiID OwnerNext;
	bool LockThisFrame;
	bool LockUntilRelease;
}
struct ImGuiKeyRoutingData {
	ImGuiKeyRoutingIndex NextEntryIndex;
	ImU16 Mods;
	ImU8 RoutingCurrScore;
	ImU8 RoutingNextScore;
	ImGuiID RoutingCurr;
	ImGuiID RoutingNext;
}
struct ImGuiKeyRoutingTable {
	ImGuiKeyRoutingIndex[ImGuiKey_NamedKey_COUNT] Index;
	ImVector!ImGuiKeyRoutingData Entries;
	ImVector!ImGuiKeyRoutingData EntriesNext;
}
struct ImGuiLastItemData {
	ImGuiID ID;
	ImGuiItemFlags InFlags;
	ImGuiItemStatusFlags StatusFlags;
	ImRect Rect;
	ImRect NavRect;
	ImRect DisplayRect;
	ImRect ClipRect;
	ImGuiKeyChord Shortcut;
}
struct ImGuiListClipper {
	ImGuiContext* Ctx;
	int DisplayStart;
	int DisplayEnd;
	int ItemsCount;
	float ItemsHeight;
	float StartPosY;
	double StartSeekOffsetY;
	void* TempData;
}
struct ImGuiListClipperData {
	ImGuiListClipper* ListClipper;
	float LossynessOffset;
	int StepNo;
	int ItemsFrozen;
	ImVector!ImGuiListClipperRange Ranges;
}
struct ImGuiListClipperRange {
	int Min;
	int Max;
	bool PosToIndexConvert;
	ImS8 PosToIndexOffsetMin;
	ImS8 PosToIndexOffsetMax;
}
struct ImGuiLocEntry {
	ImGuiLocKey Key;
	immutable(char)* Text;
}
struct ImGuiMenuColumns {
	ImU32 TotalWidth;
	ImU32 NextTotalWidth;
	ImU16 Spacing;
	ImU16 OffsetIcon;
	ImU16 OffsetLabel;
	ImU16 OffsetShortcut;
	ImU16 OffsetMark;
	ImU16[4] Widths;
}
struct ImGuiMetricsConfig {
	bool ShowDebugLog;
	bool ShowIDStackTool;
	bool ShowWindowsRects;
	bool ShowWindowsBeginOrder;
	bool ShowTablesRects;
	bool ShowDrawCmdMesh;
	bool ShowDrawCmdBoundingBoxes;
	bool ShowTextEncodingViewer;
	bool ShowAtlasTintedWithTextColor;
	bool ShowDockingNodes;
	int ShowWindowsRectsType;
	int ShowTablesRectsType;
	int HighlightMonitorIdx;
	ImGuiID HighlightViewportID;
}
struct ImGuiMultiSelectIO {
	ImVector!ImGuiSelectionRequest Requests;
	ImGuiSelectionUserData RangeSrcItem;
	ImGuiSelectionUserData NavIdItem;
	bool NavIdSelected;
	bool RangeSrcReset;
	int ItemsCount;
}
struct ImGuiMultiSelectState {
	ImGuiWindow* Window;
	ImGuiID ID;
	int LastFrameActive;
	int LastSelectionSize;
	ImS8 RangeSelected;
	ImS8 NavIdSelected;
	ImGuiSelectionUserData RangeSrcItem;
	ImGuiSelectionUserData NavIdItem;
}
struct ImGuiMultiSelectTempData {
	ImGuiMultiSelectIO IO;
	ImGuiMultiSelectState* Storage;
	ImGuiID FocusScopeId;
	ImGuiMultiSelectFlags Flags;
	ImVec2 ScopeRectMin;
	ImVec2 BackupCursorMaxPos;
	ImGuiSelectionUserData LastSubmittedItem;
	ImGuiID BoxSelectId;
	ImGuiKeyChord KeyMods;
	ImS8 LoopRequestSetAll;
	bool IsEndIO;
	bool IsFocused;
	bool IsKeyboardSetRange;
	bool NavIdPassedBy;
	bool RangeSrcPassedBy;
	bool RangeDstPassedBy;
}
struct ImGuiNavItemData {
	ImGuiWindow* Window;
	ImGuiID ID;
	ImGuiID FocusScopeId;
	ImRect RectRel;
	ImGuiItemFlags InFlags;
	float DistBox;
	float DistCenter;
	float DistAxial;
	ImGuiSelectionUserData SelectionUserData;
}
struct ImGuiNextItemData {
	ImGuiNextItemDataFlags Flags;
	ImGuiItemFlags ItemFlags;
	ImGuiID FocusScopeId;
	ImGuiSelectionUserData SelectionUserData;
	float Width;
	ImGuiKeyChord Shortcut;
	ImGuiInputFlags ShortcutFlags;
	bool OpenVal;
	ImU8 OpenCond;
	ImGuiDataTypeStorage RefVal;
	ImGuiID StorageId;
}
struct ImGuiNextWindowData {
	ImGuiNextWindowDataFlags Flags;
	ImGuiCond PosCond;
	ImGuiCond SizeCond;
	ImGuiCond CollapsedCond;
	ImGuiCond DockCond;
	ImVec2 PosVal;
	ImVec2 PosPivotVal;
	ImVec2 SizeVal;
	ImVec2 ContentSizeVal;
	ImVec2 ScrollVal;
	ImGuiChildFlags ChildFlags;
	bool PosUndock;
	bool CollapsedVal;
	ImRect SizeConstraintRect;
	ImGuiSizeCallback SizeCallback;
	void* SizeCallbackUserData;
	float BgAlphaVal;
	ImGuiID ViewportId;
	ImGuiID DockId;
	ImGuiWindowClass WindowClass;
	ImVec2 MenuBarOffsetMinVal;
	ImGuiWindowRefreshFlags RefreshFlagsVal;
}
struct ImGuiOldColumnData {
	float OffsetNorm;
	float OffsetNormBeforeResize;
	ImGuiOldColumnFlags Flags;
	ImRect ClipRect;
}
struct ImGuiOldColumns {
	ImGuiID ID;
	ImGuiOldColumnFlags Flags;
	bool IsFirstFrame;
	bool IsBeingResized;
	int Current;
	int Count;
	float OffMinX;
	float OffMaxX;
	float LineMinY;
	float LineMaxY;
	float HostCursorPosY;
	float HostCursorMaxPosX;
	ImRect HostInitialClipRect;
	ImRect HostBackupClipRect;
	ImRect HostBackupParentWorkRect;
	ImVector!ImGuiOldColumnData Columns;
	ImDrawListSplitter Splitter;
}
struct ImGuiOnceUponAFrame {
	int RefFrame;
}
struct ImGuiPayload {
	void* Data;
	int DataSize;
	ImGuiID SourceId;
	ImGuiID SourceParentId;
	int DataFrameCount;
	char[32 + 1] DataType;
	bool Preview;
	bool Delivery;
}
struct ImGuiPlatformIO {
	extern(C) void function(ImGuiViewport* vp) nothrow Platform_CreateWindow;
	extern(C) void function(ImGuiViewport* vp) nothrow Platform_DestroyWindow;
	extern(C) void function(ImGuiViewport* vp) nothrow Platform_ShowWindow;
	extern(C) void function(ImGuiViewport* vp, ImVec2 pos) nothrow Platform_SetWindowPos;
	extern(C) ImVec2 function(ImGuiViewport* vp) nothrow Platform_GetWindowPos;
	extern(C) void function(ImGuiViewport* vp, ImVec2 size) nothrow Platform_SetWindowSize;
	extern(C) ImVec2 function(ImGuiViewport* vp) nothrow Platform_GetWindowSize;
	extern(C) void function(ImGuiViewport* vp) nothrow Platform_SetWindowFocus;
	extern(C) bool function(ImGuiViewport* vp) nothrow Platform_GetWindowFocus;
	extern(C) bool function(ImGuiViewport* vp) nothrow Platform_GetWindowMinimized;
	extern(C) void function(ImGuiViewport* vp, immutable(char)* str) nothrow Platform_SetWindowTitle;
	extern(C) void function(ImGuiViewport* vp, float alpha) nothrow Platform_SetWindowAlpha;
	extern(C) void function(ImGuiViewport* vp) nothrow Platform_UpdateWindow;
	extern(C) void function(ImGuiViewport* vp, void* render_arg) nothrow Platform_RenderWindow;
	extern(C) void function(ImGuiViewport* vp, void* render_arg) nothrow Platform_SwapBuffers;
	extern(C) float function(ImGuiViewport* vp) nothrow Platform_GetWindowDpiScale;
	extern(C) void function(ImGuiViewport* vp) nothrow Platform_OnChangedViewport;
	extern(C) int function(ImGuiViewport* vp, ImU64 vk_inst, void* vk_allocators, ImU64* out_vk_surface) nothrow Platform_CreateVkSurface;
	extern(C) void function(ImGuiViewport* vp) nothrow Renderer_CreateWindow;
	extern(C) void function(ImGuiViewport* vp) nothrow Renderer_DestroyWindow;
	extern(C) void function(ImGuiViewport* vp, ImVec2 size) nothrow Renderer_SetWindowSize;
	extern(C) void function(ImGuiViewport* vp, void* render_arg) nothrow Renderer_RenderWindow;
	extern(C) void function(ImGuiViewport* vp, void* render_arg) nothrow Renderer_SwapBuffers;
	ImVector!ImGuiPlatformMonitor Monitors;
	ImVector!(ImGuiViewport*) Viewports;
}
struct ImGuiPlatformImeData {
	bool WantVisible;
	ImVec2 InputPos;
	float InputLineHeight;
}
struct ImGuiPlatformMonitor {
	ImVec2 MainPos;
	ImVec2 MainSize;
	ImVec2 WorkPos;
	ImVec2 WorkSize;
	float DpiScale;
	void* PlatformHandle;
}
struct ImGuiPopupData {
	ImGuiID PopupId;
	ImGuiWindow* Window;
	ImGuiWindow* RestoreNavWindow;
	int ParentNavLayer;
	int OpenFrameCount;
	ImGuiID OpenParentId;
	ImVec2 OpenPopupPos;
	ImVec2 OpenMousePos;
}
struct ImGuiPtrOrIndex {
	void* Ptr;
	int Index;
}
struct ImGuiSelectionBasicStorage {
	int Size;
	bool PreserveOrder;
	void* UserData;
	extern(C) ImGuiID function(ImGuiSelectionBasicStorage* self, int idx) nothrow AdapterIndexToStorageId;
	int _SelectionOrder;
	ImGuiStorage _Storage;
}
struct ImGuiSelectionExternalStorage {
	void* UserData;
	extern(C) void function(ImGuiSelectionExternalStorage* self, int idx, bool selected) nothrow AdapterSetItemSelected;
}
struct ImGuiSelectionRequest {
	ImGuiSelectionRequestType Type;
	bool Selected;
	ImS8 RangeDirection;
	ImGuiSelectionUserData RangeFirstItem;
	ImGuiSelectionUserData RangeLastItem;
}
struct ImGuiSettingsHandler {
	immutable(char)* TypeName;
	ImGuiID TypeHash;
	extern(C) void function(ImGuiContext* ctx, ImGuiSettingsHandler* handler) nothrow ClearAllFn;
	extern(C) void function(ImGuiContext* ctx, ImGuiSettingsHandler* handler) nothrow ReadInitFn;
	extern(C) void* function(ImGuiContext* ctx, ImGuiSettingsHandler* handler, immutable(char)* name) nothrow ReadOpenFn;
	extern(C) void function(ImGuiContext* ctx, ImGuiSettingsHandler* handler, void* entry, immutable(char)* line) nothrow ReadLineFn;
	extern(C) void function(ImGuiContext* ctx, ImGuiSettingsHandler* handler) nothrow ApplyAllFn;
	extern(C) void function(ImGuiContext* ctx, ImGuiSettingsHandler* handler, ImGuiTextBuffer* out_buf) nothrow WriteAllFn;
	void* UserData;
}
struct ImGuiShrinkWidthItem {
	int Index;
	float Width;
	float InitialWidth;
}
struct ImGuiSizeCallbackData {
	void* UserData;
	ImVec2 Pos;
	ImVec2 CurrentSize;
	ImVec2 DesiredSize;
}
struct ImGuiStackLevelInfo {
	ImGuiID ID;
	ImS8 QueryFrameCount;
	bool QuerySuccess;
	ImGuiDataType DataType;
	char[57] Desc;
}
struct ImGuiStackSizes {
	short SizeOfIDStack;
	short SizeOfColorStack;
	short SizeOfStyleVarStack;
	short SizeOfFontStack;
	short SizeOfFocusScopeStack;
	short SizeOfGroupStack;
	short SizeOfItemFlagsStack;
	short SizeOfBeginPopupStack;
	short SizeOfDisabledStack;
}
struct ImGuiStorage {
	ImVector!ImGuiStoragePair Data;
}
struct ImGuiStoragePair {
	ImGuiID key;
	union {
		int val_i;
		float val_f;
		void* val_p;
	}
 }
struct ImGuiStyle {
	float Alpha;
	float DisabledAlpha;
	ImVec2 WindowPadding;
	float WindowRounding;
	float WindowBorderSize;
	ImVec2 WindowMinSize;
	ImVec2 WindowTitleAlign;
	ImGuiDir WindowMenuButtonPosition;
	float ChildRounding;
	float ChildBorderSize;
	float PopupRounding;
	float PopupBorderSize;
	ImVec2 FramePadding;
	float FrameRounding;
	float FrameBorderSize;
	ImVec2 ItemSpacing;
	ImVec2 ItemInnerSpacing;
	ImVec2 CellPadding;
	ImVec2 TouchExtraPadding;
	float IndentSpacing;
	float ColumnsMinSpacing;
	float ScrollbarSize;
	float ScrollbarRounding;
	float GrabMinSize;
	float GrabRounding;
	float LogSliderDeadzone;
	float TabRounding;
	float TabBorderSize;
	float TabMinWidthForCloseButton;
	float TabBarBorderSize;
	float TabBarOverlineSize;
	float TableAngledHeadersAngle;
	ImVec2 TableAngledHeadersTextAlign;
	ImGuiDir ColorButtonPosition;
	ImVec2 ButtonTextAlign;
	ImVec2 SelectableTextAlign;
	float SeparatorTextBorderSize;
	ImVec2 SeparatorTextAlign;
	ImVec2 SeparatorTextPadding;
	ImVec2 DisplayWindowPadding;
	ImVec2 DisplaySafeAreaPadding;
	float DockingSeparatorSize;
	float MouseCursorScale;
	bool AntiAliasedLines;
	bool AntiAliasedLinesUseTex;
	bool AntiAliasedFill;
	float CurveTessellationTol;
	float CircleTessellationMaxError;
	ImVec4[ImGuiCol_COUNT] Colors;
	float HoverStationaryDelay;
	float HoverDelayShort;
	float HoverDelayNormal;
	ImGuiHoveredFlags HoverFlagsForTooltipMouse;
	ImGuiHoveredFlags HoverFlagsForTooltipNav;
}
struct ImGuiStyleMod {
	ImGuiStyleVar VarIdx;
	union {
		int[2] BackupInt;
		float[2] BackupFloat;
	}
 }
struct ImGuiTabBar {
	ImVector!ImGuiTabItem Tabs;
	ImGuiTabBarFlags Flags;
	ImGuiID ID;
	ImGuiID SelectedTabId;
	ImGuiID NextSelectedTabId;
	ImGuiID VisibleTabId;
	int CurrFrameVisible;
	int PrevFrameVisible;
	ImRect BarRect;
	float CurrTabsContentsHeight;
	float PrevTabsContentsHeight;
	float WidthAllTabs;
	float WidthAllTabsIdeal;
	float ScrollingAnim;
	float ScrollingTarget;
	float ScrollingTargetDistToVisibility;
	float ScrollingSpeed;
	float ScrollingRectMinX;
	float ScrollingRectMaxX;
	float SeparatorMinX;
	float SeparatorMaxX;
	ImGuiID ReorderRequestTabId;
	ImS16 ReorderRequestOffset;
	ImS8 BeginCount;
	bool WantLayout;
	bool VisibleTabWasSubmitted;
	bool TabsAddedNew;
	ImS16 TabsActiveCount;
	ImS16 LastTabItemIdx;
	float ItemSpacingY;
	ImVec2 FramePadding;
	ImVec2 BackupCursorPos;
	ImGuiTextBuffer TabsNames;
}
struct ImGuiTabItem {
	ImGuiID ID;
	ImGuiTabItemFlags Flags;
	ImGuiWindow* Window;
	int LastFrameVisible;
	int LastFrameSelected;
	float Offset;
	float Width;
	float ContentWidth;
	float RequestedWidth;
	ImS32 NameOffset;
	ImS16 BeginOrder;
	ImS16 IndexDuringLayout;
	bool WantClose;
}
struct ImGuiTable {
	ImGuiID ID;
	ImGuiTableFlags Flags;
	void* RawData;
	ImGuiTableTempData* TempData;
	ImSpan!ImGuiTableColumn Columns;
	ImSpan!ImGuiTableColumnIdx DisplayOrderToIndex;
	ImSpan!ImGuiTableCellData RowCellData;
	ImBitArrayPtr EnabledMaskByDisplayOrder;
	ImBitArrayPtr EnabledMaskByIndex;
	ImBitArrayPtr VisibleMaskByIndex;
	ImGuiTableFlags SettingsLoadedFlags;
	int SettingsOffset;
	int LastFrameActive;
	int ColumnsCount;
	int CurrentRow;
	int CurrentColumn;
	ImS16 InstanceCurrent;
	ImS16 InstanceInteracted;
	float RowPosY1;
	float RowPosY2;
	float RowMinHeight;
	float RowCellPaddingY;
	float RowTextBaseline;
	float RowIndentOffsetX;
	ImGuiTableRowFlags RowFlags;
	ImGuiTableRowFlags LastRowFlags;
	int RowBgColorCounter;
	ImU32[2] RowBgColor;
	ImU32 BorderColorStrong;
	ImU32 BorderColorLight;
	float BorderX1;
	float BorderX2;
	float HostIndentX;
	float MinColumnWidth;
	float OuterPaddingX;
	float CellPaddingX;
	float CellSpacingX1;
	float CellSpacingX2;
	float InnerWidth;
	float ColumnsGivenWidth;
	float ColumnsAutoFitWidth;
	float ColumnsStretchSumWeights;
	float ResizedColumnNextWidth;
	float ResizeLockMinContentsX2;
	float RefScale;
	float AngledHeadersHeight;
	float AngledHeadersSlope;
	ImRect OuterRect;
	ImRect InnerRect;
	ImRect WorkRect;
	ImRect InnerClipRect;
	ImRect BgClipRect;
	ImRect Bg0ClipRectForDrawCmd;
	ImRect Bg2ClipRectForDrawCmd;
	ImRect HostClipRect;
	ImRect HostBackupInnerClipRect;
	ImGuiWindow* OuterWindow;
	ImGuiWindow* InnerWindow;
	ImGuiTextBuffer ColumnsNames;
	ImDrawListSplitter* DrawSplitter;
	ImGuiTableInstanceData InstanceDataFirst;
	ImVector!ImGuiTableInstanceData InstanceDataExtra;
	ImGuiTableColumnSortSpecs SortSpecsSingle;
	ImVector!ImGuiTableColumnSortSpecs SortSpecsMulti;
	ImGuiTableSortSpecs SortSpecs;
	ImGuiTableColumnIdx SortSpecsCount;
	ImGuiTableColumnIdx ColumnsEnabledCount;
	ImGuiTableColumnIdx ColumnsEnabledFixedCount;
	ImGuiTableColumnIdx DeclColumnsCount;
	ImGuiTableColumnIdx AngledHeadersCount;
	ImGuiTableColumnIdx HoveredColumnBody;
	ImGuiTableColumnIdx HoveredColumnBorder;
	ImGuiTableColumnIdx HighlightColumnHeader;
	ImGuiTableColumnIdx AutoFitSingleColumn;
	ImGuiTableColumnIdx ResizedColumn;
	ImGuiTableColumnIdx LastResizedColumn;
	ImGuiTableColumnIdx HeldHeaderColumn;
	ImGuiTableColumnIdx ReorderColumn;
	ImGuiTableColumnIdx ReorderColumnDir;
	ImGuiTableColumnIdx LeftMostEnabledColumn;
	ImGuiTableColumnIdx RightMostEnabledColumn;
	ImGuiTableColumnIdx LeftMostStretchedColumn;
	ImGuiTableColumnIdx RightMostStretchedColumn;
	ImGuiTableColumnIdx ContextPopupColumn;
	ImGuiTableColumnIdx FreezeRowsRequest;
	ImGuiTableColumnIdx FreezeRowsCount;
	ImGuiTableColumnIdx FreezeColumnsRequest;
	ImGuiTableColumnIdx FreezeColumnsCount;
	ImGuiTableColumnIdx RowCellDataCurrent;
	ImGuiTableDrawChannelIdx DummyDrawChannel;
	ImGuiTableDrawChannelIdx Bg2DrawChannelCurrent;
	ImGuiTableDrawChannelIdx Bg2DrawChannelUnfrozen;
	bool IsLayoutLocked;
	bool IsInsideRow;
	bool IsInitializing;
	bool IsSortSpecsDirty;
	bool IsUsingHeaders;
	bool IsContextPopupOpen;
	bool DisableDefaultContextMenu;
	bool IsSettingsRequestLoad;
	bool IsSettingsDirty;
	bool IsDefaultDisplayOrder;
	bool IsResetAllRequest;
	bool IsResetDisplayOrderRequest;
	bool IsUnfrozenRows;
	bool IsDefaultSizingPolicy;
	bool IsActiveIdAliveBeforeTable;
	bool IsActiveIdInTable;
	bool HasScrollbarYCurr;
	bool HasScrollbarYPrev;
	bool MemoryCompacted;
	bool HostSkipItems;
}
struct ImGuiTableCellData {
	ImU32 BgColor;
	ImGuiTableColumnIdx Column;
}
struct ImGuiTableColumn {
	ImGuiTableColumnFlags Flags;
	float WidthGiven;
	float MinX;
	float MaxX;
	float WidthRequest;
	float WidthAuto;
	float StretchWeight;
	float InitStretchWeightOrWidth;
	ImRect ClipRect;
	ImGuiID UserID;
	float WorkMinX;
	float WorkMaxX;
	float ItemWidth;
	float ContentMaxXFrozen;
	float ContentMaxXUnfrozen;
	float ContentMaxXHeadersUsed;
	float ContentMaxXHeadersIdeal;
	ImS16 NameOffset;
	ImGuiTableColumnIdx DisplayOrder;
	ImGuiTableColumnIdx IndexWithinEnabledSet;
	ImGuiTableColumnIdx PrevEnabledColumn;
	ImGuiTableColumnIdx NextEnabledColumn;
	ImGuiTableColumnIdx SortOrder;
	ImGuiTableDrawChannelIdx DrawChannelCurrent;
	ImGuiTableDrawChannelIdx DrawChannelFrozen;
	ImGuiTableDrawChannelIdx DrawChannelUnfrozen;
	bool IsEnabled;
	bool IsUserEnabled;
	bool IsUserEnabledNextFrame;
	bool IsVisibleX;
	bool IsVisibleY;
	bool IsRequestOutput;
	bool IsSkipItems;
	bool IsPreserveWidthAuto;
	ImS8 NavLayerCurrent;
	ImU8 AutoFitQueue;
	ImU8 CannotSkipItemsQueue;
	ImU8 SortDirection;
	ImU8 SortDirectionsAvailCount;
	ImU8 SortDirectionsAvailMask;
	ImU8 SortDirectionsAvailList;
}
struct ImGuiTableColumnSettings {
	float WidthOrWeight;
	ImGuiID UserID;
	ImGuiTableColumnIdx Index;
	ImGuiTableColumnIdx DisplayOrder;
	ImGuiTableColumnIdx SortOrder;
	ImU8 SortDirection;
	ImU8 IsEnabled;
	ImU8 IsStretch;
}
struct ImGuiTableColumnSortSpecs {
	ImGuiID ColumnUserID;
	ImS16 ColumnIndex;
	ImS16 SortOrder;
	ImGuiSortDirection SortDirection;
}
struct ImGuiTableColumnsSettings {
}
struct ImGuiTableHeaderData {
	ImGuiTableColumnIdx Index;
	ImU32 TextColor;
	ImU32 BgColor0;
	ImU32 BgColor1;
}
struct ImGuiTableInstanceData {
	ImGuiID TableInstanceID;
	float LastOuterHeight;
	float LastTopHeadersRowHeight;
	float LastFrozenHeight;
	int HoveredRowLast;
	int HoveredRowNext;
}
struct ImGuiTableSettings {
	ImGuiID ID;
	ImGuiTableFlags SaveFlags;
	float RefScale;
	ImGuiTableColumnIdx ColumnsCount;
	ImGuiTableColumnIdx ColumnsCountMax;
	bool WantApply;
}
struct ImGuiTableSortSpecs {
	ImGuiTableColumnSortSpecs* Specs;
	int SpecsCount;
	bool SpecsDirty;
}
struct ImGuiTableTempData {
	int TableIndex;
	float LastTimeActive;
	float AngledHeadersExtraWidth;
	ImVector!ImGuiTableHeaderData AngledHeadersRequests;
	ImVec2 UserOuterSize;
	ImDrawListSplitter DrawSplitter;
	ImRect HostBackupWorkRect;
	ImRect HostBackupParentWorkRect;
	ImVec2 HostBackupPrevLineSize;
	ImVec2 HostBackupCurrLineSize;
	ImVec2 HostBackupCursorMaxPos;
	ImVec1 HostBackupColumnsOffset;
	float HostBackupItemWidth;
	int HostBackupItemWidthStackSize;
}
struct ImGuiTextBuffer {
	ImVector!char Buf;
}
struct ImGuiTextFilter {
	char[256] InputBuf;
	ImVector!ImGuiTextRange Filters;
	int CountGrep;
}
struct ImGuiTextIndex {
	ImVector!int LineOffsets;
	int EndOffset;
}
struct ImGuiTextRange {
	immutable(char)* b;
	immutable(char)* e;
}
struct ImGuiTreeNodeStackData {
	ImGuiID ID;
	ImGuiTreeNodeFlags TreeFlags;
	ImGuiItemFlags InFlags;
	ImRect NavRect;
}
struct ImGuiTypingSelectRequest {
	ImGuiTypingSelectFlags Flags;
	int SearchBufferLen;
	immutable(char)* SearchBuffer;
	bool SelectRequest;
	bool SingleCharMode;
	ImS8 SingleCharSize;
}
struct ImGuiTypingSelectState {
	ImGuiTypingSelectRequest Request;
	char[64] SearchBuffer;
	ImGuiID FocusScope;
	int LastRequestFrame;
	float LastRequestTime;
	bool SingleCharModeLock;
}
struct ImGuiViewport {
	ImGuiID ID;
	ImGuiViewportFlags Flags;
	ImVec2 Pos;
	ImVec2 Size;
	ImVec2 WorkPos;
	ImVec2 WorkSize;
	float DpiScale;
	ImGuiID ParentViewportId;
	ImDrawData* DrawData;
	void* RendererUserData;
	void* PlatformUserData;
	void* PlatformHandle;
	void* PlatformHandleRaw;
	bool PlatformWindowCreated;
	bool PlatformRequestMove;
	bool PlatformRequestResize;
	bool PlatformRequestClose;
}
struct ImGuiViewportP {
	ImGuiViewport _ImGuiViewport;
	ImGuiWindow* Window;
	int Idx;
	int LastFrameActive;
	int LastFocusedStampCount;
	ImGuiID LastNameHash;
	ImVec2 LastPos;
	float Alpha;
	float LastAlpha;
	bool LastFocusedHadNavWindow;
	short PlatformMonitor;
	int[2] BgFgDrawListsLastFrame;
	ImDrawList*[2] BgFgDrawLists;
	ImDrawData DrawDataP;
	ImDrawDataBuilder DrawDataBuilder;
	ImVec2 LastPlatformPos;
	ImVec2 LastPlatformSize;
	ImVec2 LastRendererSize;
	ImVec2 WorkOffsetMin;
	ImVec2 WorkOffsetMax;
	ImVec2 BuildWorkOffsetMin;
	ImVec2 BuildWorkOffsetMax;
}
struct ImGuiWindow {
	ImGuiContext* Ctx;
	immutable(char)* Name;
	ImGuiID ID;
	ImGuiWindowFlags Flags;
	ImGuiWindowFlags FlagsPreviousFrame;
	ImGuiChildFlags ChildFlags;
	ImGuiWindowClass WindowClass;
	ImGuiViewportP* Viewport;
	ImGuiID ViewportId;
	ImVec2 ViewportPos;
	int ViewportAllowPlatformMonitorExtend;
	ImVec2 Pos;
	ImVec2 Size;
	ImVec2 SizeFull;
	ImVec2 ContentSize;
	ImVec2 ContentSizeIdeal;
	ImVec2 ContentSizeExplicit;
	ImVec2 WindowPadding;
	float WindowRounding;
	float WindowBorderSize;
	float TitleBarHeight;
	float MenuBarHeight;
	float DecoOuterSizeX1;
	float DecoOuterSizeY1;
	float DecoOuterSizeX2;
	float DecoOuterSizeY2;
	float DecoInnerSizeX1;
	float DecoInnerSizeY1;
	int NameBufLen;
	ImGuiID MoveId;
	ImGuiID TabId;
	ImGuiID ChildId;
	ImGuiID PopupId;
	ImVec2 Scroll;
	ImVec2 ScrollMax;
	ImVec2 ScrollTarget;
	ImVec2 ScrollTargetCenterRatio;
	ImVec2 ScrollTargetEdgeSnapDist;
	ImVec2 ScrollbarSizes;
	bool ScrollbarX;
	bool ScrollbarY;
	bool ViewportOwned;
	bool Active;
	bool WasActive;
	bool WriteAccessed;
	bool Collapsed;
	bool WantCollapseToggle;
	bool SkipItems;
	bool SkipRefresh;
	bool Appearing;
	bool Hidden;
	bool IsFallbackWindow;
	bool IsExplicitChild;
	bool HasCloseButton;
	char ResizeBorderHovered;
	char ResizeBorderHeld;
	short BeginCount;
	short BeginCountPreviousFrame;
	short BeginOrderWithinParent;
	short BeginOrderWithinContext;
	short FocusOrder;
	ImS8 AutoFitFramesX;
	ImS8 AutoFitFramesY;
	bool AutoFitOnlyGrows;
	ImGuiDir AutoPosLastDirection;
	ImS8 HiddenFramesCanSkipItems;
	ImS8 HiddenFramesCannotSkipItems;
	ImS8 HiddenFramesForRenderOnly;
	ImS8 DisableInputsFrames;
	ImGuiCond SetWindowPosAllowFlags;
	ImGuiCond SetWindowSizeAllowFlags;
	ImGuiCond SetWindowCollapsedAllowFlags;
	ImGuiCond SetWindowDockAllowFlags;
	ImVec2 SetWindowPosVal;
	ImVec2 SetWindowPosPivot;
	ImVector!ImGuiID IDStack;
	ImGuiWindowTempData DC;
	ImRect OuterRectClipped;
	ImRect InnerRect;
	ImRect InnerClipRect;
	ImRect WorkRect;
	ImRect ParentWorkRect;
	ImRect ClipRect;
	ImRect ContentRegionRect;
	ImVec2ih HitTestHoleSize;
	ImVec2ih HitTestHoleOffset;
	int LastFrameActive;
	int LastFrameJustFocused;
	float LastTimeActive;
	float ItemWidthDefault;
	ImGuiStorage StateStorage;
	ImVector!ImGuiOldColumns ColumnsStorage;
	float FontWindowScale;
	float FontDpiScale;
	int SettingsOffset;
	ImDrawList* DrawList;
	ImDrawList DrawListInst;
	ImGuiWindow* ParentWindow;
	ImGuiWindow* ParentWindowInBeginStack;
	ImGuiWindow* RootWindow;
	ImGuiWindow* RootWindowPopupTree;
	ImGuiWindow* RootWindowDockTree;
	ImGuiWindow* RootWindowForTitleBarHighlight;
	ImGuiWindow* RootWindowForNav;
	ImGuiWindow* ParentWindowForFocusRoute;
	ImGuiWindow* NavLastChildNavWindow;
	ImGuiID[ImGuiNavLayer_COUNT] NavLastIds;
	ImRect[ImGuiNavLayer_COUNT] NavRectRel;
	ImVec2[ImGuiNavLayer_COUNT] NavPreferredScoringPosRel;
	ImGuiID NavRootFocusScopeId;
	int MemoryDrawListIdxCapacity;
	int MemoryDrawListVtxCapacity;
	bool MemoryCompacted;
	bool DockIsActive;
	bool DockNodeIsVisible;
	bool DockTabIsVisible;
	bool DockTabWantClose;
	short DockOrder;
	ImGuiWindowDockStyle DockStyle;
	ImGuiDockNode* DockNode;
	ImGuiDockNode* DockNodeAsHost;
	ImGuiID DockId;
	ImGuiItemStatusFlags DockTabItemStatusFlags;
	ImRect DockTabItemRect;
}
struct ImGuiWindowClass {
	ImGuiID ClassId;
	ImGuiID ParentViewportId;
	ImGuiID FocusRouteParentWindowId;
	ImGuiViewportFlags ViewportFlagsOverrideSet;
	ImGuiViewportFlags ViewportFlagsOverrideClear;
	ImGuiTabItemFlags TabItemFlagsOverrideSet;
	ImGuiDockNodeFlags DockNodeFlagsOverrideSet;
	bool DockingAlwaysTabBar;
	bool DockingAllowUnclassed;
}
struct ImGuiWindowDockStyle {
	ImU32[ImGuiWindowDockStyleCol_COUNT] Colors;
}
struct ImGuiWindowSettings {
	ImGuiID ID;
	ImVec2ih Pos;
	ImVec2ih Size;
	ImVec2ih ViewportPos;
	ImGuiID ViewportId;
	ImGuiID DockId;
	ImGuiID ClassId;
	short DockOrder;
	bool Collapsed;
	bool IsChild;
	bool WantApply;
	bool WantDelete;
}
struct ImGuiWindowStackData {
	ImGuiWindow* Window;
	ImGuiLastItemData ParentLastItemDataBackup;
	ImGuiStackSizes StackSizesOnBegin;
	bool DisabledOverrideReenable;
}
struct ImGuiWindowTempData {
	ImVec2 CursorPos;
	ImVec2 CursorPosPrevLine;
	ImVec2 CursorStartPos;
	ImVec2 CursorMaxPos;
	ImVec2 IdealMaxPos;
	ImVec2 CurrLineSize;
	ImVec2 PrevLineSize;
	float CurrLineTextBaseOffset;
	float PrevLineTextBaseOffset;
	bool IsSameLine;
	bool IsSetPos;
	ImVec1 Indent;
	ImVec1 ColumnsOffset;
	ImVec1 GroupOffset;
	ImVec2 CursorStartPosLossyness;
	ImGuiNavLayer NavLayerCurrent;
	short NavLayersActiveMask;
	short NavLayersActiveMaskNext;
	bool NavIsScrollPushableX;
	bool NavHideHighlightOneFrame;
	bool NavWindowHasScrollY;
	bool MenuBarAppending;
	ImVec2 MenuBarOffset;
	ImGuiMenuColumns MenuColumns;
	int TreeDepth;
	ImU32 TreeHasStackDataDepthMask;
	ImVector!(ImGuiWindow*) ChildWindows;
	ImGuiStorage* StateStorage;
	ImGuiOldColumns* CurrentColumns;
	int CurrentTableIdx;
	ImGuiLayoutType LayoutType;
	ImGuiLayoutType ParentLayoutType;
	ImU32 ModalDimBgColor;
	float ItemWidth;
	float TextWrapPos;
	ImVector!float ItemWidthStack;
	ImVector!float TextWrapPosStack;
}
struct ImRect {
	ImVec2 Min;
	ImVec2 Max;
}
struct ImVec1 {
	float x;
}
struct ImVec2ih {
	short x;
	short y;
}
struct ImVec4 {
	float x;
	float y;
	float z;
	float w;
}
struct STB_TexteditState {
	int cursor;
	int select_start;
	int select_end;
	ubyte insert_mode;
	int row_count_per_page;
	ubyte cursor_at_end_of_line;
	ubyte initialized;
	ubyte has_preferred_x;
	ubyte single_line;
	ubyte padding1;
	ubyte padding2;
	ubyte padding3;
	float preferred_x;
	StbUndoState undostate;
}
struct StbTexteditRow {
	float x0;
	float x1;
	float baseline_y_delta;
	float ymin;
	float ymax;
	int num_chars;
}
struct StbUndoRecord {
	int where;
	int insert_length;
	int delete_length;
	int char_storage;
}
struct StbUndoState {
	StbUndoRecord[99] undo_rec;
	ImWchar[999] undo_char;
	short undo_point;
	short redo_point;
	int undo_char_point;
	int redo_char_point;
}

// Global variables

extern(Windows) { nothrow __gshared {

}} // extern(Windows), __gshared

extern(C) { nothrow __gshared {

void function(ImBitVector* self)
	ImBitVector_Clear;

void function(ImBitVector* self, int n)
	ImBitVector_ClearBit;

void function(ImBitVector* self, int sz)
	ImBitVector_Create;

void function(ImBitVector* self, int n)
	ImBitVector_SetBit;

bool function(ImBitVector* self, int n)
	ImBitVector_TestBit;

void function(ImColor* pOut, float h, float s, float v, float a)
	ImColor_HSV;

ImColor* function(float r, float g, float b, float a)
	ImColor_ImColor_Float;

ImColor* function(int r, int g, int b, int a)
	ImColor_ImColor_Int;

ImColor* function()
	ImColor_ImColor_Nil;

ImColor* function(ImU32 rgba)
	ImColor_ImColor_U32;

ImColor* function(ImVec4 col)
	ImColor_ImColor_Vec4;

void function(ImColor* self, float h, float s, float v, float a)
	ImColor_SetHSV;

void function(ImColor* self)
	ImColor_destroy;

ImTextureID function(ImDrawCmd* self)
	ImDrawCmd_GetTexID;

ImDrawCmd* function()
	ImDrawCmd_ImDrawCmd;

void function(ImDrawCmd* self)
	ImDrawCmd_destroy;

ImDrawDataBuilder* function()
	ImDrawDataBuilder_ImDrawDataBuilder;

void function(ImDrawDataBuilder* self)
	ImDrawDataBuilder_destroy;

void function(ImDrawData* self, ImDrawList* draw_list)
	ImDrawData_AddDrawList;

void function(ImDrawData* self)
	ImDrawData_Clear;

void function(ImDrawData* self)
	ImDrawData_DeIndexAllBuffers;

ImDrawData* function()
	ImDrawData_ImDrawData;

void function(ImDrawData* self, ImVec2 fb_scale)
	ImDrawData_ScaleClipRects;

void function(ImDrawData* self)
	ImDrawData_destroy;

ImDrawListSharedData* function()
	ImDrawListSharedData_ImDrawListSharedData;

void function(ImDrawListSharedData* self, float max_error)
	ImDrawListSharedData_SetCircleTessellationMaxError;

void function(ImDrawListSharedData* self)
	ImDrawListSharedData_destroy;

void function(ImDrawListSplitter* self)
	ImDrawListSplitter_Clear;

void function(ImDrawListSplitter* self)
	ImDrawListSplitter_ClearFreeMemory;

ImDrawListSplitter* function()
	ImDrawListSplitter_ImDrawListSplitter;

void function(ImDrawListSplitter* self, ImDrawList* draw_list)
	ImDrawListSplitter_Merge;

void function(ImDrawListSplitter* self, ImDrawList* draw_list, int channel_idx)
	ImDrawListSplitter_SetCurrentChannel;

void function(ImDrawListSplitter* self, ImDrawList* draw_list, int count)
	ImDrawListSplitter_Split;

void function(ImDrawListSplitter* self)
	ImDrawListSplitter_destroy;

void function(ImDrawList* self, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, ImU32 col, float thickness, int num_segments)
	ImDrawList_AddBezierCubic;

void function(ImDrawList* self, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImU32 col, float thickness, int num_segments)
	ImDrawList_AddBezierQuadratic;

void function(ImDrawList* self, ImDrawCallback callback, void* callback_data)
	ImDrawList_AddCallback;

void function(ImDrawList* self, ImVec2 center, float radius, ImU32 col, int num_segments, float thickness)
	ImDrawList_AddCircle;

void function(ImDrawList* self, ImVec2 center, float radius, ImU32 col, int num_segments)
	ImDrawList_AddCircleFilled;

void function(ImDrawList* self, ImVec2* points, int num_points, ImU32 col)
	ImDrawList_AddConcavePolyFilled;

void function(ImDrawList* self, ImVec2* points, int num_points, ImU32 col)
	ImDrawList_AddConvexPolyFilled;

void function(ImDrawList* self)
	ImDrawList_AddDrawCmd;

void function(ImDrawList* self, ImVec2 center, ImVec2 radius, ImU32 col, float rot, int num_segments, float thickness)
	ImDrawList_AddEllipse;

void function(ImDrawList* self, ImVec2 center, ImVec2 radius, ImU32 col, float rot, int num_segments)
	ImDrawList_AddEllipseFilled;

void function(ImDrawList* self, ImTextureID user_texture_id, ImVec2 p_min, ImVec2 p_max, ImVec2 uv_min, ImVec2 uv_max, ImU32 col)
	ImDrawList_AddImage;

void function(ImDrawList* self, ImTextureID user_texture_id, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, ImVec2 uv1, ImVec2 uv2, ImVec2 uv3, ImVec2 uv4, ImU32 col)
	ImDrawList_AddImageQuad;

void function(ImDrawList* self, ImTextureID user_texture_id, ImVec2 p_min, ImVec2 p_max, ImVec2 uv_min, ImVec2 uv_max, ImU32 col, float rounding, ImDrawFlags flags)
	ImDrawList_AddImageRounded;

void function(ImDrawList* self, ImVec2 p1, ImVec2 p2, ImU32 col, float thickness)
	ImDrawList_AddLine;

void function(ImDrawList* self, ImVec2 center, float radius, ImU32 col, int num_segments, float thickness)
	ImDrawList_AddNgon;

void function(ImDrawList* self, ImVec2 center, float radius, ImU32 col, int num_segments)
	ImDrawList_AddNgonFilled;

void function(ImDrawList* self, ImVec2* points, int num_points, ImU32 col, ImDrawFlags flags, float thickness)
	ImDrawList_AddPolyline;

void function(ImDrawList* self, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, ImU32 col, float thickness)
	ImDrawList_AddQuad;

void function(ImDrawList* self, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, ImU32 col)
	ImDrawList_AddQuadFilled;

void function(ImDrawList* self, ImVec2 p_min, ImVec2 p_max, ImU32 col, float rounding, ImDrawFlags flags, float thickness)
	ImDrawList_AddRect;

void function(ImDrawList* self, ImVec2 p_min, ImVec2 p_max, ImU32 col, float rounding, ImDrawFlags flags)
	ImDrawList_AddRectFilled;

void function(ImDrawList* self, ImVec2 p_min, ImVec2 p_max, ImU32 col_upr_left, ImU32 col_upr_right, ImU32 col_bot_right, ImU32 col_bot_left)
	ImDrawList_AddRectFilledMultiColor;

void function(ImDrawList* self, ImFont* font, float font_size, ImVec2 pos, ImU32 col, immutable(char)* text_begin, immutable(char)* text_end, float wrap_width, ImVec4* cpu_fine_clip_rect)
	ImDrawList_AddText_FontPtr;

void function(ImDrawList* self, ImVec2 pos, ImU32 col, immutable(char)* text_begin, immutable(char)* text_end)
	ImDrawList_AddText_Vec2;

void function(ImDrawList* self, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImU32 col, float thickness)
	ImDrawList_AddTriangle;

void function(ImDrawList* self, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImU32 col)
	ImDrawList_AddTriangleFilled;

void function(ImDrawList* self)
	ImDrawList_ChannelsMerge;

void function(ImDrawList* self, int n)
	ImDrawList_ChannelsSetCurrent;

void function(ImDrawList* self, int count)
	ImDrawList_ChannelsSplit;

ImDrawList* function(ImDrawList* self)
	ImDrawList_CloneOutput;

void function(ImVec2* pOut, ImDrawList* self)
	ImDrawList_GetClipRectMax;

void function(ImVec2* pOut, ImDrawList* self)
	ImDrawList_GetClipRectMin;

ImDrawList* function(ImDrawListSharedData* shared_data)
	ImDrawList_ImDrawList;

void function(ImDrawList* self, ImVec2 center, float radius, float a_min, float a_max, int num_segments)
	ImDrawList_PathArcTo;

void function(ImDrawList* self, ImVec2 center, float radius, int a_min_of_12, int a_max_of_12)
	ImDrawList_PathArcToFast;

void function(ImDrawList* self, ImVec2 p2, ImVec2 p3, ImVec2 p4, int num_segments)
	ImDrawList_PathBezierCubicCurveTo;

void function(ImDrawList* self, ImVec2 p2, ImVec2 p3, int num_segments)
	ImDrawList_PathBezierQuadraticCurveTo;

void function(ImDrawList* self)
	ImDrawList_PathClear;

void function(ImDrawList* self, ImVec2 center, ImVec2 radius, float rot, float a_min, float a_max, int num_segments)
	ImDrawList_PathEllipticalArcTo;

void function(ImDrawList* self, ImU32 col)
	ImDrawList_PathFillConcave;

void function(ImDrawList* self, ImU32 col)
	ImDrawList_PathFillConvex;

void function(ImDrawList* self, ImVec2 pos)
	ImDrawList_PathLineTo;

void function(ImDrawList* self, ImVec2 pos)
	ImDrawList_PathLineToMergeDuplicate;

void function(ImDrawList* self, ImVec2 rect_min, ImVec2 rect_max, float rounding, ImDrawFlags flags)
	ImDrawList_PathRect;

void function(ImDrawList* self, ImU32 col, ImDrawFlags flags, float thickness)
	ImDrawList_PathStroke;

void function(ImDrawList* self)
	ImDrawList_PopClipRect;

void function(ImDrawList* self)
	ImDrawList_PopTextureID;

void function(ImDrawList* self, ImVec2 a, ImVec2 b, ImVec2 c, ImVec2 d, ImVec2 uv_a, ImVec2 uv_b, ImVec2 uv_c, ImVec2 uv_d, ImU32 col)
	ImDrawList_PrimQuadUV;

void function(ImDrawList* self, ImVec2 a, ImVec2 b, ImU32 col)
	ImDrawList_PrimRect;

void function(ImDrawList* self, ImVec2 a, ImVec2 b, ImVec2 uv_a, ImVec2 uv_b, ImU32 col)
	ImDrawList_PrimRectUV;

void function(ImDrawList* self, int idx_count, int vtx_count)
	ImDrawList_PrimReserve;

void function(ImDrawList* self, int idx_count, int vtx_count)
	ImDrawList_PrimUnreserve;

void function(ImDrawList* self, ImVec2 pos, ImVec2 uv, ImU32 col)
	ImDrawList_PrimVtx;

void function(ImDrawList* self, ImDrawIdx idx)
	ImDrawList_PrimWriteIdx;

void function(ImDrawList* self, ImVec2 pos, ImVec2 uv, ImU32 col)
	ImDrawList_PrimWriteVtx;

void function(ImDrawList* self, ImVec2 clip_rect_min, ImVec2 clip_rect_max, bool intersect_with_current_clip_rect)
	ImDrawList_PushClipRect;

void function(ImDrawList* self)
	ImDrawList_PushClipRectFullScreen;

void function(ImDrawList* self, ImTextureID texture_id)
	ImDrawList_PushTextureID;

int function(ImDrawList* self, float radius)
	ImDrawList__CalcCircleAutoSegmentCount;

void function(ImDrawList* self)
	ImDrawList__ClearFreeMemory;

void function(ImDrawList* self)
	ImDrawList__OnChangedClipRect;

void function(ImDrawList* self)
	ImDrawList__OnChangedTextureID;

void function(ImDrawList* self)
	ImDrawList__OnChangedVtxOffset;

void function(ImDrawList* self, ImVec2 center, float radius, int a_min_sample, int a_max_sample, int a_step)
	ImDrawList__PathArcToFastEx;

void function(ImDrawList* self, ImVec2 center, float radius, float a_min, float a_max, int num_segments)
	ImDrawList__PathArcToN;

void function(ImDrawList* self)
	ImDrawList__PopUnusedDrawCmd;

void function(ImDrawList* self)
	ImDrawList__ResetForNewFrame;

void function(ImDrawList* self)
	ImDrawList__TryMergeDrawCmds;

void function(ImDrawList* self)
	ImDrawList_destroy;

ImFontAtlasCustomRect* function()
	ImFontAtlasCustomRect_ImFontAtlasCustomRect;

bool function(ImFontAtlasCustomRect* self)
	ImFontAtlasCustomRect_IsPacked;

void function(ImFontAtlasCustomRect* self)
	ImFontAtlasCustomRect_destroy;

int function(ImFontAtlas* self, ImFont* font, ImWchar id, int width, int height, float advance_x, ImVec2 offset)
	ImFontAtlas_AddCustomRectFontGlyph;

int function(ImFontAtlas* self, int width, int height)
	ImFontAtlas_AddCustomRectRegular;

ImFont* function(ImFontAtlas* self, ImFontConfig* font_cfg)
	ImFontAtlas_AddFont;

ImFont* function(ImFontAtlas* self, ImFontConfig* font_cfg)
	ImFontAtlas_AddFontDefault;

ImFont* function(ImFontAtlas* self, immutable(char)* filename, float size_pixels, ImFontConfig* font_cfg, ImWchar* glyph_ranges)
	ImFontAtlas_AddFontFromFileTTF;

ImFont* function(ImFontAtlas* self, immutable(char)* compressed_font_data_base85, float size_pixels, ImFontConfig* font_cfg, ImWchar* glyph_ranges)
	ImFontAtlas_AddFontFromMemoryCompressedBase85TTF;

ImFont* function(ImFontAtlas* self, void* compressed_font_data, int compressed_font_data_size, float size_pixels, ImFontConfig* font_cfg, ImWchar* glyph_ranges)
	ImFontAtlas_AddFontFromMemoryCompressedTTF;

ImFont* function(ImFontAtlas* self, void* font_data, int font_data_size, float size_pixels, ImFontConfig* font_cfg, ImWchar* glyph_ranges)
	ImFontAtlas_AddFontFromMemoryTTF;

bool function(ImFontAtlas* self)
	ImFontAtlas_Build;

void function(ImFontAtlas* self, ImFontAtlasCustomRect* rect, ImVec2* out_uv_min, ImVec2* out_uv_max)
	ImFontAtlas_CalcCustomRectUV;

void function(ImFontAtlas* self)
	ImFontAtlas_Clear;

void function(ImFontAtlas* self)
	ImFontAtlas_ClearFonts;

void function(ImFontAtlas* self)
	ImFontAtlas_ClearInputData;

void function(ImFontAtlas* self)
	ImFontAtlas_ClearTexData;

ImFontAtlasCustomRect* function(ImFontAtlas* self, int index)
	ImFontAtlas_GetCustomRectByIndex;

ImWchar* function(ImFontAtlas* self)
	ImFontAtlas_GetGlyphRangesChineseFull;

ImWchar* function(ImFontAtlas* self)
	ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon;

ImWchar* function(ImFontAtlas* self)
	ImFontAtlas_GetGlyphRangesCyrillic;

ImWchar* function(ImFontAtlas* self)
	ImFontAtlas_GetGlyphRangesDefault;

ImWchar* function(ImFontAtlas* self)
	ImFontAtlas_GetGlyphRangesGreek;

ImWchar* function(ImFontAtlas* self)
	ImFontAtlas_GetGlyphRangesJapanese;

ImWchar* function(ImFontAtlas* self)
	ImFontAtlas_GetGlyphRangesKorean;

ImWchar* function(ImFontAtlas* self)
	ImFontAtlas_GetGlyphRangesThai;

ImWchar* function(ImFontAtlas* self)
	ImFontAtlas_GetGlyphRangesVietnamese;

bool function(ImFontAtlas* self, ImGuiMouseCursor cursor, ImVec2* out_offset, ImVec2* out_size, ref ImVec2[2] out_uv_border, ref ImVec2[2] out_uv_fill)
	ImFontAtlas_GetMouseCursorTexData;

void function(ImFontAtlas* self, ubyte** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel)
	ImFontAtlas_GetTexDataAsAlpha8;

void function(ImFontAtlas* self, ubyte** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel)
	ImFontAtlas_GetTexDataAsRGBA32;

ImFontAtlas* function()
	ImFontAtlas_ImFontAtlas;

bool function(ImFontAtlas* self)
	ImFontAtlas_IsBuilt;

void function(ImFontAtlas* self, ImTextureID id)
	ImFontAtlas_SetTexID;

void function(ImFontAtlas* self)
	ImFontAtlas_destroy;

ImFontConfig* function()
	ImFontConfig_ImFontConfig;

void function(ImFontConfig* self)
	ImFontConfig_destroy;

void function(ImFontGlyphRangesBuilder* self, ImWchar c)
	ImFontGlyphRangesBuilder_AddChar;

void function(ImFontGlyphRangesBuilder* self, ImWchar* ranges)
	ImFontGlyphRangesBuilder_AddRanges;

void function(ImFontGlyphRangesBuilder* self, immutable(char)* text, immutable(char)* text_end)
	ImFontGlyphRangesBuilder_AddText;

void function(ImFontGlyphRangesBuilder* self, ImVector!ImWchar* out_ranges)
	ImFontGlyphRangesBuilder_BuildRanges;

void function(ImFontGlyphRangesBuilder* self)
	ImFontGlyphRangesBuilder_Clear;

bool function(ImFontGlyphRangesBuilder* self, size_t n)
	ImFontGlyphRangesBuilder_GetBit;

ImFontGlyphRangesBuilder* function()
	ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder;

void function(ImFontGlyphRangesBuilder* self, size_t n)
	ImFontGlyphRangesBuilder_SetBit;

void function(ImFontGlyphRangesBuilder* self)
	ImFontGlyphRangesBuilder_destroy;

void function(ImFont* self, ImFontConfig* src_cfg, ImWchar c, float x0, float y0, float x1, float y1, float u0, float v0, float u1, float v1, float advance_x)
	ImFont_AddGlyph;

void function(ImFont* self, ImWchar dst, ImWchar src, bool overwrite_dst)
	ImFont_AddRemapChar;

void function(ImFont* self)
	ImFont_BuildLookupTable;

void function(ImVec2* pOut, ImFont* self, float size, float max_width, float wrap_width, immutable(char)* text_begin, immutable(char)* text_end, immutable(char)** remaining)
	ImFont_CalcTextSizeA;

immutable(char)* function(ImFont* self, float scale, immutable(char)* text, immutable(char)* text_end, float wrap_width)
	ImFont_CalcWordWrapPositionA;

void function(ImFont* self)
	ImFont_ClearOutputData;

ImFontGlyph* function(ImFont* self, ImWchar c)
	ImFont_FindGlyph;

ImFontGlyph* function(ImFont* self, ImWchar c)
	ImFont_FindGlyphNoFallback;

float function(ImFont* self, ImWchar c)
	ImFont_GetCharAdvance;

immutable(char)* function(ImFont* self)
	ImFont_GetDebugName;

void function(ImFont* self, int new_size)
	ImFont_GrowIndex;

ImFont* function()
	ImFont_ImFont;

bool function(ImFont* self, uint c_begin, uint c_last)
	ImFont_IsGlyphRangeUnused;

bool function(ImFont* self)
	ImFont_IsLoaded;

void function(ImFont* self, ImDrawList* draw_list, float size, ImVec2 pos, ImU32 col, ImWchar c)
	ImFont_RenderChar;

void function(ImFont* self, ImDrawList* draw_list, float size, ImVec2 pos, ImU32 col, ImVec4 clip_rect, immutable(char)* text_begin, immutable(char)* text_end, float wrap_width, bool cpu_fine_clip)
	ImFont_RenderText;

void function(ImFont* self, ImWchar c, bool visible)
	ImFont_SetGlyphVisible;

void function(ImFont* self)
	ImFont_destroy;

ImGuiBoxSelectState* function()
	ImGuiBoxSelectState_ImGuiBoxSelectState;

void function(ImGuiBoxSelectState* self)
	ImGuiBoxSelectState_destroy;

ImGuiComboPreviewData* function()
	ImGuiComboPreviewData_ImGuiComboPreviewData;

void function(ImGuiComboPreviewData* self)
	ImGuiComboPreviewData_destroy;

ImGuiContextHook* function()
	ImGuiContextHook_ImGuiContextHook;

void function(ImGuiContextHook* self)
	ImGuiContextHook_destroy;

ImGuiContext* function(ImFontAtlas* shared_font_atlas)
	ImGuiContext_ImGuiContext;

void function(ImGuiContext* self)
	ImGuiContext_destroy;

void* function(ImGuiDataVarInfo* self, void* parent)
	ImGuiDataVarInfo_GetVarPtr;

ImGuiDebugAllocInfo* function()
	ImGuiDebugAllocInfo_ImGuiDebugAllocInfo;

void function(ImGuiDebugAllocInfo* self)
	ImGuiDebugAllocInfo_destroy;

ImGuiDockContext* function()
	ImGuiDockContext_ImGuiDockContext;

void function(ImGuiDockContext* self)
	ImGuiDockContext_destroy;

ImGuiDockNode* function(ImGuiID id)
	ImGuiDockNode_ImGuiDockNode;

bool function(ImGuiDockNode* self)
	ImGuiDockNode_IsCentralNode;

bool function(ImGuiDockNode* self)
	ImGuiDockNode_IsDockSpace;

bool function(ImGuiDockNode* self)
	ImGuiDockNode_IsEmpty;

bool function(ImGuiDockNode* self)
	ImGuiDockNode_IsFloatingNode;

bool function(ImGuiDockNode* self)
	ImGuiDockNode_IsHiddenTabBar;

bool function(ImGuiDockNode* self)
	ImGuiDockNode_IsLeafNode;

bool function(ImGuiDockNode* self)
	ImGuiDockNode_IsNoTabBar;

bool function(ImGuiDockNode* self)
	ImGuiDockNode_IsRootNode;

bool function(ImGuiDockNode* self)
	ImGuiDockNode_IsSplitNode;

void function(ImRect* pOut, ImGuiDockNode* self)
	ImGuiDockNode_Rect;

void function(ImGuiDockNode* self, ImGuiDockNodeFlags flags)
	ImGuiDockNode_SetLocalFlags;

void function(ImGuiDockNode* self)
	ImGuiDockNode_UpdateMergedFlags;

void function(ImGuiDockNode* self)
	ImGuiDockNode_destroy;

ImGuiIDStackTool* function()
	ImGuiIDStackTool_ImGuiIDStackTool;

void function(ImGuiIDStackTool* self)
	ImGuiIDStackTool_destroy;

void function(ImGuiIO* self, bool focused)
	ImGuiIO_AddFocusEvent;

void function(ImGuiIO* self, uint c)
	ImGuiIO_AddInputCharacter;

void function(ImGuiIO* self, ImWchar16 c)
	ImGuiIO_AddInputCharacterUTF16;

void function(ImGuiIO* self, immutable(char)* str)
	ImGuiIO_AddInputCharactersUTF8;

void function(ImGuiIO* self, ImGuiKey key, bool down, float v)
	ImGuiIO_AddKeyAnalogEvent;

void function(ImGuiIO* self, ImGuiKey key, bool down)
	ImGuiIO_AddKeyEvent;

void function(ImGuiIO* self, int button, bool down)
	ImGuiIO_AddMouseButtonEvent;

void function(ImGuiIO* self, float x, float y)
	ImGuiIO_AddMousePosEvent;

void function(ImGuiIO* self, ImGuiMouseSource source)
	ImGuiIO_AddMouseSourceEvent;

void function(ImGuiIO* self, ImGuiID id)
	ImGuiIO_AddMouseViewportEvent;

void function(ImGuiIO* self, float wheel_x, float wheel_y)
	ImGuiIO_AddMouseWheelEvent;

void function(ImGuiIO* self)
	ImGuiIO_ClearEventsQueue;

void function(ImGuiIO* self)
	ImGuiIO_ClearInputKeys;

void function(ImGuiIO* self)
	ImGuiIO_ClearInputMouse;

ImGuiIO* function()
	ImGuiIO_ImGuiIO;

void function(ImGuiIO* self, bool accepting_events)
	ImGuiIO_SetAppAcceptingEvents;

void function(ImGuiIO* self, ImGuiKey key, int native_keycode, int native_scancode, int native_legacy_index)
	ImGuiIO_SetKeyEventNativeData;

void function(ImGuiIO* self)
	ImGuiIO_destroy;

ImGuiInputEvent* function()
	ImGuiInputEvent_ImGuiInputEvent;

void function(ImGuiInputEvent* self)
	ImGuiInputEvent_destroy;

void function(ImGuiInputTextCallbackData* self)
	ImGuiInputTextCallbackData_ClearSelection;

void function(ImGuiInputTextCallbackData* self, int pos, int bytes_count)
	ImGuiInputTextCallbackData_DeleteChars;

bool function(ImGuiInputTextCallbackData* self)
	ImGuiInputTextCallbackData_HasSelection;

ImGuiInputTextCallbackData* function()
	ImGuiInputTextCallbackData_ImGuiInputTextCallbackData;

void function(ImGuiInputTextCallbackData* self, int pos, immutable(char)* text, immutable(char)* text_end)
	ImGuiInputTextCallbackData_InsertChars;

void function(ImGuiInputTextCallbackData* self)
	ImGuiInputTextCallbackData_SelectAll;

void function(ImGuiInputTextCallbackData* self)
	ImGuiInputTextCallbackData_destroy;

void function(ImGuiInputTextDeactivatedState* self)
	ImGuiInputTextDeactivatedState_ClearFreeMemory;

ImGuiInputTextDeactivatedState* function()
	ImGuiInputTextDeactivatedState_ImGuiInputTextDeactivatedState;

void function(ImGuiInputTextDeactivatedState* self)
	ImGuiInputTextDeactivatedState_destroy;

void function(ImGuiInputTextState* self)
	ImGuiInputTextState_ClearFreeMemory;

void function(ImGuiInputTextState* self)
	ImGuiInputTextState_ClearSelection;

void function(ImGuiInputTextState* self)
	ImGuiInputTextState_ClearText;

void function(ImGuiInputTextState* self)
	ImGuiInputTextState_CursorAnimReset;

void function(ImGuiInputTextState* self)
	ImGuiInputTextState_CursorClamp;

int function(ImGuiInputTextState* self)
	ImGuiInputTextState_GetCursorPos;

int function(ImGuiInputTextState* self)
	ImGuiInputTextState_GetRedoAvailCount;

int function(ImGuiInputTextState* self)
	ImGuiInputTextState_GetSelectionEnd;

int function(ImGuiInputTextState* self)
	ImGuiInputTextState_GetSelectionStart;

int function(ImGuiInputTextState* self)
	ImGuiInputTextState_GetUndoAvailCount;

bool function(ImGuiInputTextState* self)
	ImGuiInputTextState_HasSelection;

ImGuiInputTextState* function()
	ImGuiInputTextState_ImGuiInputTextState;

void function(ImGuiInputTextState* self, int key)
	ImGuiInputTextState_OnKeyPressed;

void function(ImGuiInputTextState* self)
	ImGuiInputTextState_ReloadUserBufAndKeepSelection;

void function(ImGuiInputTextState* self)
	ImGuiInputTextState_ReloadUserBufAndMoveToEnd;

void function(ImGuiInputTextState* self)
	ImGuiInputTextState_ReloadUserBufAndSelectAll;

void function(ImGuiInputTextState* self)
	ImGuiInputTextState_SelectAll;

void function(ImGuiInputTextState* self)
	ImGuiInputTextState_destroy;

ImGuiKeyOwnerData* function()
	ImGuiKeyOwnerData_ImGuiKeyOwnerData;

void function(ImGuiKeyOwnerData* self)
	ImGuiKeyOwnerData_destroy;

ImGuiKeyRoutingData* function()
	ImGuiKeyRoutingData_ImGuiKeyRoutingData;

void function(ImGuiKeyRoutingData* self)
	ImGuiKeyRoutingData_destroy;

void function(ImGuiKeyRoutingTable* self)
	ImGuiKeyRoutingTable_Clear;

ImGuiKeyRoutingTable* function()
	ImGuiKeyRoutingTable_ImGuiKeyRoutingTable;

void function(ImGuiKeyRoutingTable* self)
	ImGuiKeyRoutingTable_destroy;

ImGuiLastItemData* function()
	ImGuiLastItemData_ImGuiLastItemData;

void function(ImGuiLastItemData* self)
	ImGuiLastItemData_destroy;

ImGuiListClipperData* function()
	ImGuiListClipperData_ImGuiListClipperData;

void function(ImGuiListClipperData* self, ImGuiListClipper* clipper)
	ImGuiListClipperData_Reset;

void function(ImGuiListClipperData* self)
	ImGuiListClipperData_destroy;

ImGuiListClipperRange function(int min, int max)
	ImGuiListClipperRange_FromIndices;

ImGuiListClipperRange function(float y1, float y2, int off_min, int off_max)
	ImGuiListClipperRange_FromPositions;

void function(ImGuiListClipper* self, int items_count, float items_height)
	ImGuiListClipper_Begin;

void function(ImGuiListClipper* self)
	ImGuiListClipper_End;

ImGuiListClipper* function()
	ImGuiListClipper_ImGuiListClipper;

void function(ImGuiListClipper* self, int item_index)
	ImGuiListClipper_IncludeItemByIndex;

void function(ImGuiListClipper* self, int item_begin, int item_end)
	ImGuiListClipper_IncludeItemsByIndex;

void function(ImGuiListClipper* self, int item_index)
	ImGuiListClipper_SeekCursorForItem;

bool function(ImGuiListClipper* self)
	ImGuiListClipper_Step;

void function(ImGuiListClipper* self)
	ImGuiListClipper_destroy;

void function(ImGuiMenuColumns* self, bool update_offsets)
	ImGuiMenuColumns_CalcNextTotalWidth;

float function(ImGuiMenuColumns* self, float w_icon, float w_label, float w_shortcut, float w_mark)
	ImGuiMenuColumns_DeclColumns;

ImGuiMenuColumns* function()
	ImGuiMenuColumns_ImGuiMenuColumns;

void function(ImGuiMenuColumns* self, float spacing, bool window_reappearing)
	ImGuiMenuColumns_Update;

void function(ImGuiMenuColumns* self)
	ImGuiMenuColumns_destroy;

ImGuiMultiSelectState* function()
	ImGuiMultiSelectState_ImGuiMultiSelectState;

void function(ImGuiMultiSelectState* self)
	ImGuiMultiSelectState_destroy;

void function(ImGuiMultiSelectTempData* self)
	ImGuiMultiSelectTempData_Clear;

void function(ImGuiMultiSelectTempData* self)
	ImGuiMultiSelectTempData_ClearIO;

ImGuiMultiSelectTempData* function()
	ImGuiMultiSelectTempData_ImGuiMultiSelectTempData;

void function(ImGuiMultiSelectTempData* self)
	ImGuiMultiSelectTempData_destroy;

void function(ImGuiNavItemData* self)
	ImGuiNavItemData_Clear;

ImGuiNavItemData* function()
	ImGuiNavItemData_ImGuiNavItemData;

void function(ImGuiNavItemData* self)
	ImGuiNavItemData_destroy;

void function(ImGuiNextItemData* self)
	ImGuiNextItemData_ClearFlags;

ImGuiNextItemData* function()
	ImGuiNextItemData_ImGuiNextItemData;

void function(ImGuiNextItemData* self)
	ImGuiNextItemData_destroy;

void function(ImGuiNextWindowData* self)
	ImGuiNextWindowData_ClearFlags;

ImGuiNextWindowData* function()
	ImGuiNextWindowData_ImGuiNextWindowData;

void function(ImGuiNextWindowData* self)
	ImGuiNextWindowData_destroy;

ImGuiOldColumnData* function()
	ImGuiOldColumnData_ImGuiOldColumnData;

void function(ImGuiOldColumnData* self)
	ImGuiOldColumnData_destroy;

ImGuiOldColumns* function()
	ImGuiOldColumns_ImGuiOldColumns;

void function(ImGuiOldColumns* self)
	ImGuiOldColumns_destroy;

ImGuiOnceUponAFrame* function()
	ImGuiOnceUponAFrame_ImGuiOnceUponAFrame;

void function(ImGuiOnceUponAFrame* self)
	ImGuiOnceUponAFrame_destroy;

void function(ImGuiPayload* self)
	ImGuiPayload_Clear;

ImGuiPayload* function()
	ImGuiPayload_ImGuiPayload;

bool function(ImGuiPayload* self, immutable(char)* type)
	ImGuiPayload_IsDataType;

bool function(ImGuiPayload* self)
	ImGuiPayload_IsDelivery;

bool function(ImGuiPayload* self)
	ImGuiPayload_IsPreview;

void function(ImGuiPayload* self)
	ImGuiPayload_destroy;

ImGuiPlatformIO* function()
	ImGuiPlatformIO_ImGuiPlatformIO;

void function(ImGuiPlatformIO* platform_io, void function(ImGuiViewport* vp, ImVec2* out_pos) nothrow user_callback)
	ImGuiPlatformIO_Set_Platform_GetWindowPos;

void function(ImGuiPlatformIO* platform_io, void function(ImGuiViewport* vp, ImVec2* out_size) nothrow user_callback)
	ImGuiPlatformIO_Set_Platform_GetWindowSize;

void function(ImGuiPlatformIO* self)
	ImGuiPlatformIO_destroy;

ImGuiPlatformImeData* function()
	ImGuiPlatformImeData_ImGuiPlatformImeData;

void function(ImGuiPlatformImeData* self)
	ImGuiPlatformImeData_destroy;

ImGuiPlatformMonitor* function()
	ImGuiPlatformMonitor_ImGuiPlatformMonitor;

void function(ImGuiPlatformMonitor* self)
	ImGuiPlatformMonitor_destroy;

ImGuiPopupData* function()
	ImGuiPopupData_ImGuiPopupData;

void function(ImGuiPopupData* self)
	ImGuiPopupData_destroy;

ImGuiPtrOrIndex* function(int index)
	ImGuiPtrOrIndex_ImGuiPtrOrIndex_Int;

ImGuiPtrOrIndex* function(void* ptr)
	ImGuiPtrOrIndex_ImGuiPtrOrIndex_Ptr;

void function(ImGuiPtrOrIndex* self)
	ImGuiPtrOrIndex_destroy;

void function(ImGuiSelectionBasicStorage* self, ImGuiMultiSelectIO* ms_io)
	ImGuiSelectionBasicStorage_ApplyRequests;

void function(ImGuiSelectionBasicStorage* self)
	ImGuiSelectionBasicStorage_Clear;

bool function(ImGuiSelectionBasicStorage* self, ImGuiID id)
	ImGuiSelectionBasicStorage_Contains;

bool function(ImGuiSelectionBasicStorage* self, void** opaque_it, ImGuiID* out_id)
	ImGuiSelectionBasicStorage_GetNextSelectedItem;

ImGuiID function(ImGuiSelectionBasicStorage* self, int idx)
	ImGuiSelectionBasicStorage_GetStorageIdFromIndex;

ImGuiSelectionBasicStorage* function()
	ImGuiSelectionBasicStorage_ImGuiSelectionBasicStorage;

void function(ImGuiSelectionBasicStorage* self, ImGuiID id, bool selected)
	ImGuiSelectionBasicStorage_SetItemSelected;

void function(ImGuiSelectionBasicStorage* self, ImGuiSelectionBasicStorage* r)
	ImGuiSelectionBasicStorage_Swap;

void function(ImGuiSelectionBasicStorage* self)
	ImGuiSelectionBasicStorage_destroy;

void function(ImGuiSelectionExternalStorage* self, ImGuiMultiSelectIO* ms_io)
	ImGuiSelectionExternalStorage_ApplyRequests;

ImGuiSelectionExternalStorage* function()
	ImGuiSelectionExternalStorage_ImGuiSelectionExternalStorage;

void function(ImGuiSelectionExternalStorage* self)
	ImGuiSelectionExternalStorage_destroy;

ImGuiSettingsHandler* function()
	ImGuiSettingsHandler_ImGuiSettingsHandler;

void function(ImGuiSettingsHandler* self)
	ImGuiSettingsHandler_destroy;

ImGuiStackLevelInfo* function()
	ImGuiStackLevelInfo_ImGuiStackLevelInfo;

void function(ImGuiStackLevelInfo* self)
	ImGuiStackLevelInfo_destroy;

void function(ImGuiStackSizes* self, ImGuiContext* ctx)
	ImGuiStackSizes_CompareWithContextState;

ImGuiStackSizes* function()
	ImGuiStackSizes_ImGuiStackSizes;

void function(ImGuiStackSizes* self, ImGuiContext* ctx)
	ImGuiStackSizes_SetToContextState;

void function(ImGuiStackSizes* self)
	ImGuiStackSizes_destroy;

ImGuiStoragePair* function(ImGuiID _key, float _val)
	ImGuiStoragePair_ImGuiStoragePair_Float;

ImGuiStoragePair* function(ImGuiID _key, int _val)
	ImGuiStoragePair_ImGuiStoragePair_Int;

ImGuiStoragePair* function(ImGuiID _key, void* _val)
	ImGuiStoragePair_ImGuiStoragePair_Ptr;

void function(ImGuiStoragePair* self)
	ImGuiStoragePair_destroy;

void function(ImGuiStorage* self)
	ImGuiStorage_BuildSortByKey;

void function(ImGuiStorage* self)
	ImGuiStorage_Clear;

bool function(ImGuiStorage* self, ImGuiID key, bool default_val)
	ImGuiStorage_GetBool;

bool* function(ImGuiStorage* self, ImGuiID key, bool default_val)
	ImGuiStorage_GetBoolRef;

float function(ImGuiStorage* self, ImGuiID key, float default_val)
	ImGuiStorage_GetFloat;

float* function(ImGuiStorage* self, ImGuiID key, float default_val)
	ImGuiStorage_GetFloatRef;

int function(ImGuiStorage* self, ImGuiID key, int default_val)
	ImGuiStorage_GetInt;

int* function(ImGuiStorage* self, ImGuiID key, int default_val)
	ImGuiStorage_GetIntRef;

void* function(ImGuiStorage* self, ImGuiID key)
	ImGuiStorage_GetVoidPtr;

void** function(ImGuiStorage* self, ImGuiID key, void* default_val)
	ImGuiStorage_GetVoidPtrRef;

void function(ImGuiStorage* self, int val)
	ImGuiStorage_SetAllInt;

void function(ImGuiStorage* self, ImGuiID key, bool val)
	ImGuiStorage_SetBool;

void function(ImGuiStorage* self, ImGuiID key, float val)
	ImGuiStorage_SetFloat;

void function(ImGuiStorage* self, ImGuiID key, int val)
	ImGuiStorage_SetInt;

void function(ImGuiStorage* self, ImGuiID key, void* val)
	ImGuiStorage_SetVoidPtr;

ImGuiStyleMod* function(ImGuiStyleVar idx, float v)
	ImGuiStyleMod_ImGuiStyleMod_Float;

ImGuiStyleMod* function(ImGuiStyleVar idx, int v)
	ImGuiStyleMod_ImGuiStyleMod_Int;

ImGuiStyleMod* function(ImGuiStyleVar idx, ImVec2 v)
	ImGuiStyleMod_ImGuiStyleMod_Vec2;

void function(ImGuiStyleMod* self)
	ImGuiStyleMod_destroy;

ImGuiStyle* function()
	ImGuiStyle_ImGuiStyle;

void function(ImGuiStyle* self, float scale_factor)
	ImGuiStyle_ScaleAllSizes;

void function(ImGuiStyle* self)
	ImGuiStyle_destroy;

ImGuiTabBar* function()
	ImGuiTabBar_ImGuiTabBar;

void function(ImGuiTabBar* self)
	ImGuiTabBar_destroy;

ImGuiTabItem* function()
	ImGuiTabItem_ImGuiTabItem;

void function(ImGuiTabItem* self)
	ImGuiTabItem_destroy;

ImGuiTableColumnSettings* function()
	ImGuiTableColumnSettings_ImGuiTableColumnSettings;

void function(ImGuiTableColumnSettings* self)
	ImGuiTableColumnSettings_destroy;

ImGuiTableColumnSortSpecs* function()
	ImGuiTableColumnSortSpecs_ImGuiTableColumnSortSpecs;

void function(ImGuiTableColumnSortSpecs* self)
	ImGuiTableColumnSortSpecs_destroy;

ImGuiTableColumn* function()
	ImGuiTableColumn_ImGuiTableColumn;

void function(ImGuiTableColumn* self)
	ImGuiTableColumn_destroy;

ImGuiTableInstanceData* function()
	ImGuiTableInstanceData_ImGuiTableInstanceData;

void function(ImGuiTableInstanceData* self)
	ImGuiTableInstanceData_destroy;

ImGuiTableColumnSettings* function(ImGuiTableSettings* self)
	ImGuiTableSettings_GetColumnSettings;

ImGuiTableSettings* function()
	ImGuiTableSettings_ImGuiTableSettings;

void function(ImGuiTableSettings* self)
	ImGuiTableSettings_destroy;

ImGuiTableSortSpecs* function()
	ImGuiTableSortSpecs_ImGuiTableSortSpecs;

void function(ImGuiTableSortSpecs* self)
	ImGuiTableSortSpecs_destroy;

ImGuiTableTempData* function()
	ImGuiTableTempData_ImGuiTableTempData;

void function(ImGuiTableTempData* self)
	ImGuiTableTempData_destroy;

ImGuiTable* function()
	ImGuiTable_ImGuiTable;

void function(ImGuiTable* self)
	ImGuiTable_destroy;

ImGuiTextBuffer* function()
	ImGuiTextBuffer_ImGuiTextBuffer;

void function(ImGuiTextBuffer* self, immutable(char)* str, immutable(char)* str_end)
	ImGuiTextBuffer_append;

void function(ImGuiTextBuffer* buffer, immutable(char)* fmt, ...)
	ImGuiTextBuffer_appendf;

void function(ImGuiTextBuffer* self, immutable(char)* fmt, va_list args)
	ImGuiTextBuffer_appendfv;

immutable(char)* function(ImGuiTextBuffer* self)
	ImGuiTextBuffer_begin;

immutable(char)* function(ImGuiTextBuffer* self)
	ImGuiTextBuffer_c_str;

void function(ImGuiTextBuffer* self)
	ImGuiTextBuffer_clear;

void function(ImGuiTextBuffer* self)
	ImGuiTextBuffer_destroy;

bool function(ImGuiTextBuffer* self)
	ImGuiTextBuffer_empty;

immutable(char)* function(ImGuiTextBuffer* self)
	ImGuiTextBuffer_end;

void function(ImGuiTextBuffer* self, int capacity)
	ImGuiTextBuffer_reserve;

int function(ImGuiTextBuffer* self)
	ImGuiTextBuffer_size;

void function(ImGuiTextFilter* self)
	ImGuiTextFilter_Build;

void function(ImGuiTextFilter* self)
	ImGuiTextFilter_Clear;

bool function(ImGuiTextFilter* self, immutable(char)* label, float width)
	ImGuiTextFilter_Draw;

ImGuiTextFilter* function(immutable(char)* default_filter)
	ImGuiTextFilter_ImGuiTextFilter;

bool function(ImGuiTextFilter* self)
	ImGuiTextFilter_IsActive;

bool function(ImGuiTextFilter* self, immutable(char)* text, immutable(char)* text_end)
	ImGuiTextFilter_PassFilter;

void function(ImGuiTextFilter* self)
	ImGuiTextFilter_destroy;

void function(ImGuiTextIndex* self, immutable(char)* base, int old_size, int new_size)
	ImGuiTextIndex_append;

void function(ImGuiTextIndex* self)
	ImGuiTextIndex_clear;

immutable(char)* function(ImGuiTextIndex* self, immutable(char)* base, int n)
	ImGuiTextIndex_get_line_begin;

immutable(char)* function(ImGuiTextIndex* self, immutable(char)* base, int n)
	ImGuiTextIndex_get_line_end;

int function(ImGuiTextIndex* self)
	ImGuiTextIndex_size;

ImGuiTextRange* function()
	ImGuiTextRange_ImGuiTextRange_Nil;

ImGuiTextRange* function(immutable(char)* _b, immutable(char)* _e)
	ImGuiTextRange_ImGuiTextRange_Str;

void function(ImGuiTextRange* self)
	ImGuiTextRange_destroy;

bool function(ImGuiTextRange* self)
	ImGuiTextRange_empty;

void function(ImGuiTextRange* self, char separator, ImVector!ImGuiTextRange* out_)
	ImGuiTextRange_split;

void function(ImGuiTypingSelectState* self)
	ImGuiTypingSelectState_Clear;

ImGuiTypingSelectState* function()
	ImGuiTypingSelectState_ImGuiTypingSelectState;

void function(ImGuiTypingSelectState* self)
	ImGuiTypingSelectState_destroy;

void function(ImVec2* pOut, ImGuiViewportP* self, ImVec2 off_min)
	ImGuiViewportP_CalcWorkRectPos;

void function(ImVec2* pOut, ImGuiViewportP* self, ImVec2 off_min, ImVec2 off_max)
	ImGuiViewportP_CalcWorkRectSize;

void function(ImGuiViewportP* self)
	ImGuiViewportP_ClearRequestFlags;

void function(ImRect* pOut, ImGuiViewportP* self)
	ImGuiViewportP_GetBuildWorkRect;

void function(ImRect* pOut, ImGuiViewportP* self)
	ImGuiViewportP_GetMainRect;

void function(ImRect* pOut, ImGuiViewportP* self)
	ImGuiViewportP_GetWorkRect;

ImGuiViewportP* function()
	ImGuiViewportP_ImGuiViewportP;

void function(ImGuiViewportP* self)
	ImGuiViewportP_UpdateWorkRect;

void function(ImGuiViewportP* self)
	ImGuiViewportP_destroy;

void function(ImVec2* pOut, ImGuiViewport* self)
	ImGuiViewport_GetCenter;

void function(ImVec2* pOut, ImGuiViewport* self)
	ImGuiViewport_GetWorkCenter;

ImGuiViewport* function()
	ImGuiViewport_ImGuiViewport;

void function(ImGuiViewport* self)
	ImGuiViewport_destroy;

ImGuiWindowClass* function()
	ImGuiWindowClass_ImGuiWindowClass;

void function(ImGuiWindowClass* self)
	ImGuiWindowClass_destroy;

immutable(char)* function(ImGuiWindowSettings* self)
	ImGuiWindowSettings_GetName;

ImGuiWindowSettings* function()
	ImGuiWindowSettings_ImGuiWindowSettings;

void function(ImGuiWindowSettings* self)
	ImGuiWindowSettings_destroy;

float function(ImGuiWindow* self)
	ImGuiWindow_CalcFontSize;

ImGuiID function(ImGuiWindow* self, ImRect r_abs)
	ImGuiWindow_GetIDFromRectangle;

ImGuiID function(ImGuiWindow* self, int n)
	ImGuiWindow_GetID_Int;

ImGuiID function(ImGuiWindow* self, void* ptr)
	ImGuiWindow_GetID_Ptr;

ImGuiID function(ImGuiWindow* self, immutable(char)* str, immutable(char)* str_end)
	ImGuiWindow_GetID_Str;

ImGuiWindow* function(ImGuiContext* context, immutable(char)* name)
	ImGuiWindow_ImGuiWindow;

void function(ImRect* pOut, ImGuiWindow* self)
	ImGuiWindow_MenuBarRect;

void function(ImRect* pOut, ImGuiWindow* self)
	ImGuiWindow_Rect;

void function(ImRect* pOut, ImGuiWindow* self)
	ImGuiWindow_TitleBarRect;

void function(ImGuiWindow* self)
	ImGuiWindow_destroy;

void function(ImRect* self, ImRect r)
	ImRect_Add_Rect;

void function(ImRect* self, ImVec2 p)
	ImRect_Add_Vec2;

void function(ImRect* self, ImRect r)
	ImRect_ClipWith;

void function(ImRect* self, ImRect r)
	ImRect_ClipWithFull;

bool function(ImRect* self, ImVec2 p, ImVec2 pad)
	ImRect_ContainsWithPad;

bool function(ImRect* self, ImRect r)
	ImRect_Contains_Rect;

bool function(ImRect* self, ImVec2 p)
	ImRect_Contains_Vec2;

void function(ImRect* self, float amount)
	ImRect_Expand_Float;

void function(ImRect* self, ImVec2 amount)
	ImRect_Expand_Vec2;

void function(ImRect* self)
	ImRect_Floor;

float function(ImRect* self)
	ImRect_GetArea;

void function(ImVec2* pOut, ImRect* self)
	ImRect_GetBL;

void function(ImVec2* pOut, ImRect* self)
	ImRect_GetBR;

void function(ImVec2* pOut, ImRect* self)
	ImRect_GetCenter;

float function(ImRect* self)
	ImRect_GetHeight;

void function(ImVec2* pOut, ImRect* self)
	ImRect_GetSize;

void function(ImVec2* pOut, ImRect* self)
	ImRect_GetTL;

void function(ImVec2* pOut, ImRect* self)
	ImRect_GetTR;

float function(ImRect* self)
	ImRect_GetWidth;

ImRect* function(float x1, float y1, float x2, float y2)
	ImRect_ImRect_Float;

ImRect* function()
	ImRect_ImRect_Nil;

ImRect* function(ImVec2 min, ImVec2 max)
	ImRect_ImRect_Vec2;

ImRect* function(ImVec4 v)
	ImRect_ImRect_Vec4;

bool function(ImRect* self)
	ImRect_IsInverted;

bool function(ImRect* self, ImRect r)
	ImRect_Overlaps;

void function(ImVec4* pOut, ImRect* self)
	ImRect_ToVec4;

void function(ImRect* self, ImVec2 d)
	ImRect_Translate;

void function(ImRect* self, float dx)
	ImRect_TranslateX;

void function(ImRect* self, float dy)
	ImRect_TranslateY;

void function(ImRect* self)
	ImRect_destroy;

ImVec1* function(float _x)
	ImVec1_ImVec1_Float;

ImVec1* function()
	ImVec1_ImVec1_Nil;

void function(ImVec1* self)
	ImVec1_destroy;

ImVec2* function(float _x, float _y)
	ImVec2_ImVec2_Float;

ImVec2* function()
	ImVec2_ImVec2_Nil;

void function(ImVec2* self)
	ImVec2_destroy;

ImVec2ih* function()
	ImVec2ih_ImVec2ih_Nil;

ImVec2ih* function(ImVec2 rhs)
	ImVec2ih_ImVec2ih_Vec2;

ImVec2ih* function(short _x, short _y)
	ImVec2ih_ImVec2ih_short;

void function(ImVec2ih* self)
	ImVec2ih_destroy;

ImVec4* function(float _x, float _y, float _z, float _w)
	ImVec4_ImVec4_Float;

ImVec4* function()
	ImVec4_ImVec4_Nil;

void function(ImVec4* self)
	ImVec4_destroy;

void function(ImVector!ImWchar* p)
	ImVector_ImWchar_Init;

void function(ImVector!ImWchar* p)
	ImVector_ImWchar_UnInit;

ImVector!ImWchar* function()
	ImVector_ImWchar_create;

void function(ImVector!ImWchar* self)
	ImVector_ImWchar_destroy;

ImGuiPayload* function(immutable(char)* type, ImGuiDragDropFlags flags)
	igAcceptDragDropPayload;

void function(ImGuiID id)
	igActivateItemByID;

ImGuiID function(ImGuiContext* context, ImGuiContextHook* hook)
	igAddContextHook;

void function(ImDrawData* draw_data, ImVector!(ImDrawList*)* out_list, ImDrawList* draw_list)
	igAddDrawListToDrawDataEx;

void function(ImGuiSettingsHandler* handler)
	igAddSettingsHandler;

void function()
	igAlignTextToFramePadding;

bool function(immutable(char)* str_id, ImGuiDir dir)
	igArrowButton;

bool function(immutable(char)* str_id, ImGuiDir dir, ImVec2 size_arg, ImGuiButtonFlags flags)
	igArrowButtonEx;

bool function(immutable(char)* name, bool* p_open, ImGuiWindowFlags flags)
	igBegin;

bool function(ImRect scope_rect, ImGuiWindow* window, ImGuiID box_select_id, ImGuiMultiSelectFlags ms_flags)
	igBeginBoxSelect;

bool function(immutable(char)* name, ImGuiID id, ImVec2 size_arg, ImGuiChildFlags child_flags, ImGuiWindowFlags window_flags)
	igBeginChildEx;

bool function(ImGuiID id, ImVec2 size, ImGuiChildFlags child_flags, ImGuiWindowFlags window_flags)
	igBeginChild_ID;

bool function(immutable(char)* str_id, ImVec2 size, ImGuiChildFlags child_flags, ImGuiWindowFlags window_flags)
	igBeginChild_Str;

void function(immutable(char)* str_id, int count, ImGuiOldColumnFlags flags)
	igBeginColumns;

bool function(immutable(char)* label, immutable(char)* preview_value, ImGuiComboFlags flags)
	igBeginCombo;

bool function(ImGuiID popup_id, ImRect bb, ImGuiComboFlags flags)
	igBeginComboPopup;

bool function()
	igBeginComboPreview;

void function(bool disabled)
	igBeginDisabled;

void function()
	igBeginDisabledOverrideReenable;

void function(ImGuiWindow* window)
	igBeginDockableDragDropSource;

void function(ImGuiWindow* window)
	igBeginDockableDragDropTarget;

void function(ImGuiWindow* window, bool* p_open)
	igBeginDocked;

bool function(ImGuiDragDropFlags flags)
	igBeginDragDropSource;

bool function()
	igBeginDragDropTarget;

bool function(ImRect bb, ImGuiID id)
	igBeginDragDropTargetCustom;

void function()
	igBeginGroup;

bool function()
	igBeginItemTooltip;

bool function(immutable(char)* label, ImVec2 size)
	igBeginListBox;

bool function()
	igBeginMainMenuBar;

bool function(immutable(char)* label, bool enabled)
	igBeginMenu;

bool function()
	igBeginMenuBar;

bool function(immutable(char)* label, immutable(char)* icon, bool enabled)
	igBeginMenuEx;

ImGuiMultiSelectIO* function(ImGuiMultiSelectFlags flags, int selection_size, int items_count)
	igBeginMultiSelect;

bool function(immutable(char)* str_id, ImGuiWindowFlags flags)
	igBeginPopup;

bool function(immutable(char)* str_id, ImGuiPopupFlags popup_flags)
	igBeginPopupContextItem;

bool function(immutable(char)* str_id, ImGuiPopupFlags popup_flags)
	igBeginPopupContextVoid;

bool function(immutable(char)* str_id, ImGuiPopupFlags popup_flags)
	igBeginPopupContextWindow;

bool function(ImGuiID id, ImGuiWindowFlags extra_window_flags)
	igBeginPopupEx;

bool function(immutable(char)* name, bool* p_open, ImGuiWindowFlags flags)
	igBeginPopupModal;

bool function(immutable(char)* str_id, ImGuiTabBarFlags flags)
	igBeginTabBar;

bool function(ImGuiTabBar* tab_bar, ImRect bb, ImGuiTabBarFlags flags)
	igBeginTabBarEx;

bool function(immutable(char)* label, bool* p_open, ImGuiTabItemFlags flags)
	igBeginTabItem;

bool function(immutable(char)* str_id, int columns, ImGuiTableFlags flags, ImVec2 outer_size, float inner_width)
	igBeginTable;

bool function(immutable(char)* name, ImGuiID id, int columns_count, ImGuiTableFlags flags, ImVec2 outer_size, float inner_width)
	igBeginTableEx;

bool function()
	igBeginTooltip;

bool function(ImGuiTooltipFlags tooltip_flags, ImGuiWindowFlags extra_window_flags)
	igBeginTooltipEx;

bool function()
	igBeginTooltipHidden;

bool function(immutable(char)* name, ImGuiViewport* viewport, ImGuiDir dir, float size, ImGuiWindowFlags window_flags)
	igBeginViewportSideBar;

void function(ImGuiWindow* window)
	igBringWindowToDisplayBack;

void function(ImGuiWindow* window, ImGuiWindow* above_window)
	igBringWindowToDisplayBehind;

void function(ImGuiWindow* window)
	igBringWindowToDisplayFront;

void function(ImGuiWindow* window)
	igBringWindowToFocusFront;

void function()
	igBullet;

void function(immutable(char)* fmt, ...)
	igBulletText;

void function(immutable(char)* fmt, va_list args)
	igBulletTextV;

bool function(immutable(char)* label, ImVec2 size)
	igButton;

bool function(ImRect bb, ImGuiID id, bool* out_hovered, bool* out_held, ImGuiButtonFlags flags)
	igButtonBehavior;

bool function(immutable(char)* label, ImVec2 size_arg, ImGuiButtonFlags flags)
	igButtonEx;

void function(ImVec2* pOut, ImVec2 size, float default_w, float default_h)
	igCalcItemSize;

float function()
	igCalcItemWidth;

ImDrawFlags function(ImRect r_in, ImRect r_outer, float threshold)
	igCalcRoundingFlagsForRectInRect;

void function(ImVec2* pOut, immutable(char)* text, immutable(char)* text_end, bool hide_text_after_double_hash, float wrap_width)
	igCalcTextSize;

int function(float t0, float t1, float repeat_delay, float repeat_rate)
	igCalcTypematicRepeatAmount;

void function(ImVec2* pOut, ImGuiWindow* window)
	igCalcWindowNextAutoFitSize;

float function(ImVec2 pos, float wrap_pos_x)
	igCalcWrapWidthForPos;

void function(ImGuiContext* context, ImGuiContextHookType type)
	igCallContextHooks;

bool function(immutable(char)* label, bool* v)
	igCheckbox;

bool function(immutable(char)* label, int* flags, int flags_value)
	igCheckboxFlags_IntPtr;

bool function(immutable(char)* label, ImS64* flags, ImS64 flags_value)
	igCheckboxFlags_S64Ptr;

bool function(immutable(char)* label, ImU64* flags, ImU64 flags_value)
	igCheckboxFlags_U64Ptr;

bool function(immutable(char)* label, uint* flags, uint flags_value)
	igCheckboxFlags_UintPtr;

void function()
	igClearActiveID;

void function()
	igClearDragDrop;

void function()
	igClearIniSettings;

void function(immutable(char)* name)
	igClearWindowSettings;

bool function(ImGuiID id, ImVec2 pos)
	igCloseButton;

void function()
	igCloseCurrentPopup;

void function(int remaining, bool restore_focus_to_window_under_popup)
	igClosePopupToLevel;

void function()
	igClosePopupsExceptModals;

void function(ImGuiWindow* ref_window, bool restore_focus_to_window_under_popup)
	igClosePopupsOverWindow;

bool function(ImGuiID id, ImVec2 pos, ImGuiDockNode* dock_node)
	igCollapseButton;

bool function(immutable(char)* label, bool* p_visible, ImGuiTreeNodeFlags flags)
	igCollapsingHeader_BoolPtr;

bool function(immutable(char)* label, ImGuiTreeNodeFlags flags)
	igCollapsingHeader_TreeNodeFlags;

bool function(immutable(char)* desc_id, ImVec4 col, ImGuiColorEditFlags flags, ImVec2 size)
	igColorButton;

ImU32 function(ImVec4 in_)
	igColorConvertFloat4ToU32;

void function(float h, float s, float v, float* out_r, float* out_g, float* out_b)
	igColorConvertHSVtoRGB;

void function(float r, float g, float b, float* out_h, float* out_s, float* out_v)
	igColorConvertRGBtoHSV;

void function(ImVec4* pOut, ImU32 in_)
	igColorConvertU32ToFloat4;

bool function(immutable(char)* label, ref float[3] col, ImGuiColorEditFlags flags)
	igColorEdit3;

bool function(immutable(char)* label, ref float[4] col, ImGuiColorEditFlags flags)
	igColorEdit4;

void function(float* col, ImGuiColorEditFlags flags)
	igColorEditOptionsPopup;

bool function(immutable(char)* label, ref float[3] col, ImGuiColorEditFlags flags)
	igColorPicker3;

bool function(immutable(char)* label, ref float[4] col, ImGuiColorEditFlags flags, float* ref_col)
	igColorPicker4;

void function(float* ref_col, ImGuiColorEditFlags flags)
	igColorPickerOptionsPopup;

void function(immutable(char)* text, float* col, ImGuiColorEditFlags flags)
	igColorTooltip;

void function(int count, immutable(char)* id, bool border)
	igColumns;

bool function(immutable(char)* label, int* current_item, immutable(char)* function(void* user_data, int idx) nothrow getter, void* user_data, int items_count, int popup_max_height_in_items)
	igCombo_FnStrPtr;

bool function(immutable(char)* label, int* current_item, immutable(char)* items_separated_by_zeros, int popup_max_height_in_items)
	igCombo_Str;

bool function(immutable(char)* label, int* current_item, immutable(char)** items, int items_count, int popup_max_height_in_items)
	igCombo_Str_arr;

ImGuiKey function(ImGuiKey key)
	igConvertSingleModFlagToKey;

ImGuiContext* function(ImFontAtlas* shared_font_atlas)
	igCreateContext;

ImGuiWindowSettings* function(immutable(char)* name)
	igCreateNewWindowSettings;

bool function(immutable(char)* buf, ImGuiDataType data_type, void* p_data, immutable(char)* format, void* p_data_when_empty)
	igDataTypeApplyFromText;

void function(ImGuiDataType data_type, int op, void* output, void* arg_1, void* arg_2)
	igDataTypeApplyOp;

bool function(ImGuiDataType data_type, void* p_data, void* p_min, void* p_max)
	igDataTypeClamp;

int function(ImGuiDataType data_type, void* arg_1, void* arg_2)
	igDataTypeCompare;

int function(immutable(char)* buf, int buf_size, ImGuiDataType data_type, void* p_data, immutable(char)* format)
	igDataTypeFormatString;

ImGuiDataTypeInfo* function(ImGuiDataType data_type)
	igDataTypeGetInfo;

void function(ImGuiDebugAllocInfo* info, int frame_count, void* ptr, size_t size)
	igDebugAllocHook;

bool function(immutable(char)* label, immutable(char)* description_of_location)
	igDebugBreakButton;

void function(bool keyboard_only, immutable(char)* description_of_location)
	igDebugBreakButtonTooltip;

void function()
	igDebugBreakClearData;

bool function(immutable(char)* version_str, size_t sz_io, size_t sz_style, size_t sz_vec2, size_t sz_vec4, size_t sz_drawvert, size_t sz_drawidx)
	igDebugCheckVersionAndDataLayout;

void function(ImU32 col)
	igDebugDrawCursorPos;

void function(ImU32 col)
	igDebugDrawItemRect;

void function(ImU32 col)
	igDebugDrawLineExtents;

void function(ImGuiCol idx)
	igDebugFlashStyleColor;

void function(ImGuiID id, ImGuiDataType data_type, void* data_id, void* data_id_end)
	igDebugHookIdInfo;

void function(ImGuiID target_id)
	igDebugLocateItem;

void function(ImGuiID target_id)
	igDebugLocateItemOnHover;

void function()
	igDebugLocateItemResolveWithLastItem;

void function(immutable(char)* fmt, ...)
	igDebugLog;

void function(immutable(char)* fmt, va_list args)
	igDebugLogV;

void function(ImGuiOldColumns* columns)
	igDebugNodeColumns;

void function(ImGuiDockNode* node, immutable(char)* label)
	igDebugNodeDockNode;

void function(ImDrawList* out_draw_list, ImDrawList* draw_list, ImDrawCmd* draw_cmd, bool show_mesh, bool show_aabb)
	igDebugNodeDrawCmdShowMeshAndBoundingBox;

void function(ImGuiWindow* window, ImGuiViewportP* viewport, ImDrawList* draw_list, immutable(char)* label)
	igDebugNodeDrawList;

void function(ImFont* font)
	igDebugNodeFont;

void function(ImFont* font, ImFontGlyph* glyph)
	igDebugNodeFontGlyph;

void function(ImGuiInputTextState* state)
	igDebugNodeInputTextState;

void function(ImGuiMultiSelectState* state)
	igDebugNodeMultiSelectState;

void function(ImGuiPlatformMonitor* monitor, immutable(char)* label, int idx)
	igDebugNodePlatformMonitor;

void function(ImGuiStorage* storage, immutable(char)* label)
	igDebugNodeStorage;

void function(ImGuiTabBar* tab_bar, immutable(char)* label)
	igDebugNodeTabBar;

void function(ImGuiTable* table)
	igDebugNodeTable;

void function(ImGuiTableSettings* settings)
	igDebugNodeTableSettings;

void function(ImGuiTypingSelectState* state)
	igDebugNodeTypingSelectState;

void function(ImGuiViewportP* viewport)
	igDebugNodeViewport;

void function(ImGuiWindow* window, immutable(char)* label)
	igDebugNodeWindow;

void function(ImGuiWindowSettings* settings)
	igDebugNodeWindowSettings;

void function(ImVector!(ImGuiWindow*)* windows, immutable(char)* label)
	igDebugNodeWindowsList;

void function(ImGuiWindow** windows, int windows_size, ImGuiWindow* parent_in_begin_stack)
	igDebugNodeWindowsListByBeginStackParent;

void function(ImDrawList* draw_list)
	igDebugRenderKeyboardPreview;

void function(ImDrawList* draw_list, ImGuiViewportP* viewport, ImRect bb)
	igDebugRenderViewportThumbnail;

void function()
	igDebugStartItemPicker;

void function(immutable(char)* text)
	igDebugTextEncoding;

void function(immutable(char)* line_begin, immutable(char)* line_end)
	igDebugTextUnformattedWithLocateItem;

void function(ImGuiContext* ctx)
	igDestroyContext;

void function(ImGuiViewportP* viewport)
	igDestroyPlatformWindow;

void function()
	igDestroyPlatformWindows;

ImGuiID function(ImGuiID node_id, ImGuiDockNodeFlags flags)
	igDockBuilderAddNode;

void function(ImGuiID src_dockspace_id, ImGuiID dst_dockspace_id, ImVector!(char)* in_window_remap_pairs)
	igDockBuilderCopyDockSpace;

void function(ImGuiID src_node_id, ImGuiID dst_node_id, ImVector!ImGuiID* out_node_remap_pairs)
	igDockBuilderCopyNode;

void function(immutable(char)* src_name, immutable(char)* dst_name)
	igDockBuilderCopyWindowSettings;

void function(immutable(char)* window_name, ImGuiID node_id)
	igDockBuilderDockWindow;

void function(ImGuiID node_id)
	igDockBuilderFinish;

ImGuiDockNode* function(ImGuiID node_id)
	igDockBuilderGetCentralNode;

ImGuiDockNode* function(ImGuiID node_id)
	igDockBuilderGetNode;

void function(ImGuiID node_id)
	igDockBuilderRemoveNode;

void function(ImGuiID node_id)
	igDockBuilderRemoveNodeChildNodes;

void function(ImGuiID node_id, bool clear_settings_refs)
	igDockBuilderRemoveNodeDockedWindows;

void function(ImGuiID node_id, ImVec2 pos)
	igDockBuilderSetNodePos;

void function(ImGuiID node_id, ImVec2 size)
	igDockBuilderSetNodeSize;

ImGuiID function(ImGuiID node_id, ImGuiDir split_dir, float size_ratio_for_node_at_dir, ImGuiID* out_id_at_dir, ImGuiID* out_id_at_opposite_dir)
	igDockBuilderSplitNode;

bool function(ImGuiWindow* target, ImGuiDockNode* target_node, ImGuiWindow* payload_window, ImGuiDockNode* payload_node, ImGuiDir split_dir, bool split_outer, ImVec2* out_pos)
	igDockContextCalcDropPosForDocking;

void function(ImGuiContext* ctx, ImGuiID root_id, bool clear_settings_refs)
	igDockContextClearNodes;

void function(ImGuiContext* ctx)
	igDockContextEndFrame;

ImGuiDockNode* function(ImGuiContext* ctx, ImGuiID id)
	igDockContextFindNodeByID;

ImGuiID function(ImGuiContext* ctx)
	igDockContextGenNodeID;

void function(ImGuiContext* ctx)
	igDockContextInitialize;

void function(ImGuiContext* ctx)
	igDockContextNewFrameUpdateDocking;

void function(ImGuiContext* ctx)
	igDockContextNewFrameUpdateUndocking;

void function(ImGuiContext* ctx, ImGuiDockNode* node)
	igDockContextProcessUndockNode;

void function(ImGuiContext* ctx, ImGuiWindow* window, bool clear_persistent_docking_ref)
	igDockContextProcessUndockWindow;

void function(ImGuiContext* ctx, ImGuiWindow* target, ImGuiDockNode* target_node, ImGuiWindow* payload, ImGuiDir split_dir, float split_ratio, bool split_outer)
	igDockContextQueueDock;

void function(ImGuiContext* ctx, ImGuiDockNode* node)
	igDockContextQueueUndockNode;

void function(ImGuiContext* ctx, ImGuiWindow* window)
	igDockContextQueueUndockWindow;

void function(ImGuiContext* ctx)
	igDockContextRebuildNodes;

void function(ImGuiContext* ctx)
	igDockContextShutdown;

bool function(ImGuiDockNode* node)
	igDockNodeBeginAmendTabBar;

void function()
	igDockNodeEndAmendTabBar;

int function(ImGuiDockNode* node)
	igDockNodeGetDepth;

ImGuiDockNode* function(ImGuiDockNode* node)
	igDockNodeGetRootNode;

ImGuiID function(ImGuiDockNode* node)
	igDockNodeGetWindowMenuButtonId;

bool function(ImGuiDockNode* node, ImGuiDockNode* parent)
	igDockNodeIsInHierarchyOf;

void function(ImGuiContext* ctx, ImGuiDockNode* node, ImGuiTabBar* tab_bar)
	igDockNodeWindowMenuHandler_Default;

ImGuiID function(ImGuiID dockspace_id, ImVec2 size, ImGuiDockNodeFlags flags, ImGuiWindowClass* window_class)
	igDockSpace;

ImGuiID function(ImGuiID dockspace_id, ImGuiViewport* viewport, ImGuiDockNodeFlags flags, ImGuiWindowClass* window_class)
	igDockSpaceOverViewport;

bool function(ImGuiID id, ImGuiDataType data_type, void* p_v, float v_speed, void* p_min, void* p_max, immutable(char)* format, ImGuiSliderFlags flags)
	igDragBehavior;

bool function(immutable(char)* label, float* v, float v_speed, float v_min, float v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igDragFloat;

bool function(immutable(char)* label, ref float[2] v, float v_speed, float v_min, float v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igDragFloat2;

bool function(immutable(char)* label, ref float[3] v, float v_speed, float v_min, float v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igDragFloat3;

bool function(immutable(char)* label, ref float[4] v, float v_speed, float v_min, float v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igDragFloat4;

bool function(immutable(char)* label, float* v_current_min, float* v_current_max, float v_speed, float v_min, float v_max, immutable(char)* format, immutable(char)* format_max, ImGuiSliderFlags flags)
	igDragFloatRange2;

bool function(immutable(char)* label, int* v, float v_speed, int v_min, int v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igDragInt;

bool function(immutable(char)* label, ref int[2] v, float v_speed, int v_min, int v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igDragInt2;

bool function(immutable(char)* label, ref int[3] v, float v_speed, int v_min, int v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igDragInt3;

bool function(immutable(char)* label, ref int[4] v, float v_speed, int v_min, int v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igDragInt4;

bool function(immutable(char)* label, int* v_current_min, int* v_current_max, float v_speed, int v_min, int v_max, immutable(char)* format, immutable(char)* format_max, ImGuiSliderFlags flags)
	igDragIntRange2;

bool function(immutable(char)* label, ImGuiDataType data_type, void* p_data, float v_speed, void* p_min, void* p_max, immutable(char)* format, ImGuiSliderFlags flags)
	igDragScalar;

bool function(immutable(char)* label, ImGuiDataType data_type, void* p_data, int components, float v_speed, void* p_min, void* p_max, immutable(char)* format, ImGuiSliderFlags flags)
	igDragScalarN;

void function(ImVec2 size)
	igDummy;

void function()
	igEnd;

void function(ImRect scope_rect, ImGuiMultiSelectFlags ms_flags)
	igEndBoxSelect;

void function()
	igEndChild;

void function()
	igEndColumns;

void function()
	igEndCombo;

void function()
	igEndComboPreview;

void function()
	igEndDisabled;

void function()
	igEndDisabledOverrideReenable;

void function()
	igEndDragDropSource;

void function()
	igEndDragDropTarget;

void function()
	igEndFrame;

void function()
	igEndGroup;

void function()
	igEndListBox;

void function()
	igEndMainMenuBar;

void function()
	igEndMenu;

void function()
	igEndMenuBar;

ImGuiMultiSelectIO* function()
	igEndMultiSelect;

void function()
	igEndPopup;

void function()
	igEndTabBar;

void function()
	igEndTabItem;

void function()
	igEndTable;

void function()
	igEndTooltip;

void function(ImGuiErrorLogCallback log_callback, void* user_data)
	igErrorCheckEndFrameRecover;

void function(ImGuiErrorLogCallback log_callback, void* user_data)
	igErrorCheckEndWindowRecover;

void function()
	igErrorCheckUsingSetCursorPosToExtendParentBoundaries;

void function(ImVec2* pOut, ImGuiWindow* window)
	igFindBestWindowPosForPopup;

void function(ImVec2* pOut, ImVec2 ref_pos, ImVec2 size, ImGuiDir* last_dir, ImRect r_outer, ImRect r_avoid, ImGuiPopupPositionPolicy policy)
	igFindBestWindowPosForPopupEx;

ImGuiWindow* function(ImGuiWindow* window)
	igFindBlockingModal;

ImGuiWindow* function(ImGuiWindow* window)
	igFindBottomMostVisibleWindowWithinBeginStack;

ImGuiViewportP* function(ImVec2 mouse_platform_pos)
	igFindHoveredViewportFromPlatformWindowStack;

void function(ImVec2 pos, bool find_first_and_in_any_viewport, ImGuiWindow** out_hovered_window, ImGuiWindow** out_hovered_window_under_moving_window)
	igFindHoveredWindowEx;

ImGuiOldColumns* function(ImGuiWindow* window, ImGuiID id)
	igFindOrCreateColumns;

immutable(char)* function(immutable(char)* text, immutable(char)* text_end)
	igFindRenderedTextEnd;

ImGuiSettingsHandler* function(immutable(char)* type_name)
	igFindSettingsHandler;

ImGuiViewport* function(ImGuiID id)
	igFindViewportByID;

ImGuiViewport* function(void* platform_handle)
	igFindViewportByPlatformHandle;

ImGuiWindow* function(ImGuiID id)
	igFindWindowByID;

ImGuiWindow* function(immutable(char)* name)
	igFindWindowByName;

int function(ImGuiWindow* window)
	igFindWindowDisplayIndex;

ImGuiWindowSettings* function(ImGuiID id)
	igFindWindowSettingsByID;

ImGuiWindowSettings* function(ImGuiWindow* window)
	igFindWindowSettingsByWindow;

ImGuiKeyChord function(ImGuiKeyChord key_chord)
	igFixupKeyChord;

void function()
	igFocusItem;

void function(ImGuiWindow* under_this_window, ImGuiWindow* ignore_window, ImGuiViewport* filter_viewport, ImGuiFocusRequestFlags flags)
	igFocusTopMostWindowUnderOne;

void function(ImGuiWindow* window, ImGuiFocusRequestFlags flags)
	igFocusWindow;

float function()
	igGET_FLT_MAX;

float function()
	igGET_FLT_MIN;

void function(ImGuiWindow* window)
	igGcAwakeTransientWindowBuffers;

void function()
	igGcCompactTransientMiscBuffers;

void function(ImGuiWindow* window)
	igGcCompactTransientWindowBuffers;

ImGuiID function()
	igGetActiveID;

void function(ImGuiMemAllocFunc* p_alloc_func, ImGuiMemFreeFunc* p_free_func, void** p_user_data)
	igGetAllocatorFunctions;

ImDrawList* function(ImGuiViewport* viewport)
	igGetBackgroundDrawList;

ImGuiBoxSelectState* function(ImGuiID id)
	igGetBoxSelectState;

immutable(char)* function()
	igGetClipboardText;

ImU32 function(ImGuiCol idx, float alpha_mul)
	igGetColorU32_Col;

ImU32 function(ImU32 col, float alpha_mul)
	igGetColorU32_U32;

ImU32 function(ImVec4 col)
	igGetColorU32_Vec4;

int function()
	igGetColumnIndex;

float function(ImGuiOldColumns* columns, float offset)
	igGetColumnNormFromOffset;

float function(int column_index)
	igGetColumnOffset;

float function(ImGuiOldColumns* columns, float offset_norm)
	igGetColumnOffsetFromNorm;

float function(int column_index)
	igGetColumnWidth;

int function()
	igGetColumnsCount;

ImGuiID function(immutable(char)* str_id, int count)
	igGetColumnsID;

void function(ImVec2* pOut)
	igGetContentRegionAvail;

ImGuiContext* function()
	igGetCurrentContext;

ImGuiID function()
	igGetCurrentFocusScope;

ImGuiTabBar* function()
	igGetCurrentTabBar;

ImGuiTable* function()
	igGetCurrentTable;

ImGuiWindow* function()
	igGetCurrentWindow;

ImGuiWindow* function()
	igGetCurrentWindowRead;

void function(ImVec2* pOut)
	igGetCursorPos;

float function()
	igGetCursorPosX;

float function()
	igGetCursorPosY;

void function(ImVec2* pOut)
	igGetCursorScreenPos;

void function(ImVec2* pOut)
	igGetCursorStartPos;

ImFont* function()
	igGetDefaultFont;

ImGuiPayload* function()
	igGetDragDropPayload;

ImDrawData* function()
	igGetDrawData;

ImDrawListSharedData* function()
	igGetDrawListSharedData;

ImGuiID function()
	igGetFocusID;

ImFont* function()
	igGetFont;

float function()
	igGetFontSize;

void function(ImVec2* pOut)
	igGetFontTexUvWhitePixel;

ImDrawList* function(ImGuiViewport* viewport)
	igGetForegroundDrawList_ViewportPtr;

ImDrawList* function(ImGuiWindow* window)
	igGetForegroundDrawList_WindowPtr;

int function()
	igGetFrameCount;

float function()
	igGetFrameHeight;

float function()
	igGetFrameHeightWithSpacing;

ImGuiID function()
	igGetHoveredID;

ImGuiID function(int n, ImGuiID seed)
	igGetIDWithSeed_Int;

ImGuiID function(immutable(char)* str_id_begin, immutable(char)* str_id_end, ImGuiID seed)
	igGetIDWithSeed_Str;

ImGuiID function(int int_id)
	igGetID_Int;

ImGuiID function(void* ptr_id)
	igGetID_Ptr;

ImGuiID function(immutable(char)* str_id)
	igGetID_Str;

ImGuiID function(immutable(char)* str_id_begin, immutable(char)* str_id_end)
	igGetID_StrStr;

ImGuiIO* function()
	igGetIO;

ImGuiInputTextState* function(ImGuiID id)
	igGetInputTextState;

ImGuiItemFlags function()
	igGetItemFlags;

ImGuiID function()
	igGetItemID;

void function(ImVec2* pOut)
	igGetItemRectMax;

void function(ImVec2* pOut)
	igGetItemRectMin;

void function(ImVec2* pOut)
	igGetItemRectSize;

ImGuiItemStatusFlags function()
	igGetItemStatusFlags;

immutable(char)* function(ImGuiKeyChord key_chord)
	igGetKeyChordName;

ImGuiKeyData* function(ImGuiContext* ctx, ImGuiKey key)
	igGetKeyData_ContextPtr;

ImGuiKeyData* function(ImGuiKey key)
	igGetKeyData_Key;

void function(ImVec2* pOut, ImGuiKey key_left, ImGuiKey key_right, ImGuiKey key_up, ImGuiKey key_down)
	igGetKeyMagnitude2d;

immutable(char)* function(ImGuiKey key)
	igGetKeyName;

ImGuiID function(ImGuiKey key)
	igGetKeyOwner;

ImGuiKeyOwnerData* function(ImGuiContext* ctx, ImGuiKey key)
	igGetKeyOwnerData;

int function(ImGuiKey key, float repeat_delay, float rate)
	igGetKeyPressedAmount;

ImGuiViewport* function()
	igGetMainViewport;

int function(ImGuiMouseButton button)
	igGetMouseClickedCount;

ImGuiMouseCursor function()
	igGetMouseCursor;

void function(ImVec2* pOut, ImGuiMouseButton button, float lock_threshold)
	igGetMouseDragDelta;

void function(ImVec2* pOut)
	igGetMousePos;

void function(ImVec2* pOut)
	igGetMousePosOnOpeningCurrentPopup;

ImGuiMultiSelectState* function(ImGuiID id)
	igGetMultiSelectState;

float function(ImGuiAxis axis)
	igGetNavTweakPressedAmount;

ImGuiPlatformIO* function()
	igGetPlatformIO;

void function(ImRect* pOut, ImGuiWindow* window)
	igGetPopupAllowedExtentRect;

float function()
	igGetScrollMaxX;

float function()
	igGetScrollMaxY;

float function()
	igGetScrollX;

float function()
	igGetScrollY;

ImGuiKeyRoutingData* function(ImGuiKeyChord key_chord)
	igGetShortcutRoutingData;

ImGuiStorage* function()
	igGetStateStorage;

ImGuiStyle* function()
	igGetStyle;

immutable(char)* function(ImGuiCol idx)
	igGetStyleColorName;

ImVec4* function(ImGuiCol idx)
	igGetStyleColorVec4;

ImGuiDataVarInfo* function(ImGuiStyleVar idx)
	igGetStyleVarInfo;

float function()
	igGetTextLineHeight;

float function()
	igGetTextLineHeightWithSpacing;

double function()
	igGetTime;

ImGuiWindow* function()
	igGetTopMostAndVisiblePopupModal;

ImGuiWindow* function()
	igGetTopMostPopupModal;

float function()
	igGetTreeNodeToLabelSpacing;

void function(ImGuiInputFlags flags, float* repeat_delay, float* repeat_rate)
	igGetTypematicRepeatRate;

ImGuiTypingSelectRequest* function(ImGuiTypingSelectFlags flags)
	igGetTypingSelectRequest;

immutable(char)* function()
	igGetVersion;

ImGuiPlatformMonitor* function(ImGuiViewport* viewport)
	igGetViewportPlatformMonitor;

bool function(ImGuiWindow* window)
	igGetWindowAlwaysWantOwnTabBar;

ImGuiID function()
	igGetWindowDockID;

ImGuiDockNode* function()
	igGetWindowDockNode;

float function()
	igGetWindowDpiScale;

ImDrawList* function()
	igGetWindowDrawList;

float function()
	igGetWindowHeight;

void function(ImVec2* pOut)
	igGetWindowPos;

ImGuiID function(ImGuiWindow* window, ImGuiDir dir)
	igGetWindowResizeBorderID;

ImGuiID function(ImGuiWindow* window, int n)
	igGetWindowResizeCornerID;

ImGuiID function(ImGuiWindow* window, ImGuiAxis axis)
	igGetWindowScrollbarID;

void function(ImRect* pOut, ImGuiWindow* window, ImGuiAxis axis)
	igGetWindowScrollbarRect;

void function(ImVec2* pOut)
	igGetWindowSize;

ImGuiViewport* function()
	igGetWindowViewport;

float function()
	igGetWindowWidth;

float function(float x)
	igImAbs_Float;

int function(int x)
	igImAbs_Int;

double function(double x)
	igImAbs_double;

ImU32 function(ImU32 col_a, ImU32 col_b)
	igImAlphaBlendColors;

void function(ImVec2* pOut, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, float t)
	igImBezierCubicCalc;

void function(ImVec2* pOut, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, ImVec2 p, int num_segments)
	igImBezierCubicClosestPoint;

void function(ImVec2* pOut, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, ImVec2 p, float tess_tol)
	igImBezierCubicClosestPointCasteljau;

void function(ImVec2* pOut, ImVec2 p1, ImVec2 p2, ImVec2 p3, float t)
	igImBezierQuadraticCalc;

void function(ImU32* arr, int bitcount)
	igImBitArrayClearAllBits;

void function(ImU32* arr, int n)
	igImBitArrayClearBit;

size_t function(int bitcount)
	igImBitArrayGetStorageSizeInBytes;

void function(ImU32* arr, int n)
	igImBitArraySetBit;

void function(ImU32* arr, int n, int n2)
	igImBitArraySetBitRange;

bool function(ImU32* arr, int n)
	igImBitArrayTestBit;

bool function(char c)
	igImCharIsBlankA;

bool function(uint c)
	igImCharIsBlankW;

bool function(char c)
	igImCharIsXdigitA;

void function(ImVec2* pOut, ImVec2 v, ImVec2 mn, ImVec2 mx)
	igImClamp;

float function(ImVec2 a, ImVec2 b)
	igImDot;

float function(float avg, float sample, int n)
	igImExponentialMovingAverage;

bool function(ImFileHandle file)
	igImFileClose;

ImU64 function(ImFileHandle file)
	igImFileGetSize;

void* function(immutable(char)* filename, immutable(char)* mode, size_t* out_file_size, int padding_bytes)
	igImFileLoadToMemory;

ImFileHandle function(immutable(char)* filename, immutable(char)* mode)
	igImFileOpen;

ImU64 function(void* data, ImU64 size, ImU64 count, ImFileHandle file)
	igImFileRead;

ImU64 function(void* data, ImU64 size, ImU64 count, ImFileHandle file)
	igImFileWrite;

float function(float f)
	igImFloor_Float;

void function(ImVec2* pOut, ImVec2 v)
	igImFloor_Vec2;

void function(ImFontAtlas* atlas)
	igImFontAtlasBuildFinish;

void function(ImFontAtlas* atlas)
	igImFontAtlasBuildInit;

void function(ref ubyte[256] out_table, float in_multiply_factor)
	igImFontAtlasBuildMultiplyCalcLookupTable;

void function(ref ubyte[256] table, ubyte* pixels, int x, int y, int w, int h, int stride)
	igImFontAtlasBuildMultiplyRectAlpha8;

void function(ImFontAtlas* atlas, void* stbrp_context_opaque)
	igImFontAtlasBuildPackCustomRects;

void function(ImFontAtlas* atlas, int x, int y, int w, int h, immutable(char)* in_str, char in_marker_char, uint in_marker_pixel_value)
	igImFontAtlasBuildRender32bppRectFromString;

void function(ImFontAtlas* atlas, int x, int y, int w, int h, immutable(char)* in_str, char in_marker_char, ubyte in_marker_pixel_value)
	igImFontAtlasBuildRender8bppRectFromString;

void function(ImFontAtlas* atlas, ImFont* font, ImFontConfig* font_config, float ascent, float descent)
	igImFontAtlasBuildSetupFont;

ImFontBuilderIO* function()
	igImFontAtlasGetBuilderForStbTruetype;

void function(ImFontAtlas* atlas)
	igImFontAtlasUpdateConfigDataPointers;

int function(immutable(char)* buf, size_t buf_size, immutable(char)* fmt, ...)
	igImFormatString;

void function(immutable(char)** out_buf, immutable(char)** out_buf_end, immutable(char)* fmt, ...)
	igImFormatStringToTempBuffer;

void function(immutable(char)** out_buf, immutable(char)** out_buf_end, immutable(char)* fmt, va_list args)
	igImFormatStringToTempBufferV;

int function(immutable(char)* buf, size_t buf_size, immutable(char)* fmt, va_list args)
	igImFormatStringV;

ImGuiID function(void* data, size_t data_size, ImGuiID seed)
	igImHashData;

ImGuiID function(immutable(char)* data, size_t data_size, ImGuiID seed)
	igImHashStr;

float function(ImVec2 lhs, float fail_value)
	igImInvLength;

bool function(float f)
	igImIsFloatAboveGuaranteedIntegerPrecision;

bool function(int v)
	igImIsPowerOfTwo_Int;

bool function(ImU64 v)
	igImIsPowerOfTwo_U64;

float function(ImVec2 lhs)
	igImLengthSqr_Vec2;

float function(ImVec4 lhs)
	igImLengthSqr_Vec4;

void function(ImVec2* pOut, ImVec2 a, ImVec2 b, float t)
	igImLerp_Vec2Float;

void function(ImVec2* pOut, ImVec2 a, ImVec2 b, ImVec2 t)
	igImLerp_Vec2Vec2;

void function(ImVec4* pOut, ImVec4 a, ImVec4 b, float t)
	igImLerp_Vec4;

void function(ImVec2* pOut, ImVec2 a, ImVec2 b, ImVec2 p)
	igImLineClosestPoint;

float function(float s0, float s1, float d0, float d1, float x)
	igImLinearRemapClamp;

float function(float current, float target, float speed)
	igImLinearSweep;

float function(float x)
	igImLog_Float;

double function(double x)
	igImLog_double;

ImGuiStoragePair* function(ImGuiStoragePair* in_begin, ImGuiStoragePair* in_end, ImGuiID key)
	igImLowerBound;

void function(ImVec2* pOut, ImVec2 lhs, ImVec2 rhs)
	igImMax;

void function(ImVec2* pOut, ImVec2 lhs, ImVec2 rhs)
	igImMin;

int function(int a, int b)
	igImModPositive;

void function(ImVec2* pOut, ImVec2 lhs, ImVec2 rhs)
	igImMul;

immutable(char)* function(immutable(char)* format)
	igImParseFormatFindEnd;

immutable(char)* function(immutable(char)* format)
	igImParseFormatFindStart;

int function(immutable(char)* format, int default_value)
	igImParseFormatPrecision;

void function(immutable(char)* fmt_in, immutable(char)* fmt_out, size_t fmt_out_size)
	igImParseFormatSanitizeForPrinting;

immutable(char)* function(immutable(char)* fmt_in, immutable(char)* fmt_out, size_t fmt_out_size)
	igImParseFormatSanitizeForScanning;

immutable(char)* function(immutable(char)* format, immutable(char)* buf, size_t buf_size)
	igImParseFormatTrimDecorations;

float function(float x, float y)
	igImPow_Float;

double function(double x, double y)
	igImPow_double;

void function(void* base, size_t count, size_t size_of_element, int function(void* , void* ) nothrow compare_func)
	igImQsort;

void function(ImVec2* pOut, ImVec2 v, float cos_a, float sin_a)
	igImRotate;

float function(float x)
	igImRsqrt_Float;

double function(double x)
	igImRsqrt_double;

float function(float f)
	igImSaturate;

float function(float x)
	igImSign_Float;

double function(double x)
	igImSign_double;

immutable(char)* function(immutable(char)* str)
	igImStrSkipBlank;

void function(immutable(char)* str)
	igImStrTrimBlanks;

ImWchar* function(ImWchar* buf_mid_line, ImWchar* buf_begin)
	igImStrbolW;

immutable(char)* function(immutable(char)* str_begin, immutable(char)* str_end, char c)
	igImStrchrRange;

immutable(char)* function(immutable(char)* str)
	igImStrdup;

immutable(char)* function(immutable(char)* dst, size_t* p_dst_size, immutable(char)* str)
	igImStrdupcpy;

immutable(char)* function(immutable(char)* str, immutable(char)* str_end)
	igImStreolRange;

int function(immutable(char)* str1, immutable(char)* str2)
	igImStricmp;

immutable(char)* function(immutable(char)* haystack, immutable(char)* haystack_end, immutable(char)* needle, immutable(char)* needle_end)
	igImStristr;

int function(ImWchar* str)
	igImStrlenW;

void function(immutable(char)* dst, immutable(char)* src, size_t count)
	igImStrncpy;

int function(immutable(char)* str1, immutable(char)* str2, size_t count)
	igImStrnicmp;

int function(uint* out_char, immutable(char)* in_text, immutable(char)* in_text_end)
	igImTextCharFromUtf8;

immutable(char)* function(ref char[5] out_buf, uint c)
	igImTextCharToUtf8;

int function(immutable(char)* in_text, immutable(char)* in_text_end)
	igImTextCountCharsFromUtf8;

int function(immutable(char)* in_text, immutable(char)* in_text_end)
	igImTextCountLines;

int function(immutable(char)* in_text, immutable(char)* in_text_end)
	igImTextCountUtf8BytesFromChar;

int function(ImWchar* in_text, ImWchar* in_text_end)
	igImTextCountUtf8BytesFromStr;

immutable(char)* function(immutable(char)* in_text_start, immutable(char)* in_text_curr)
	igImTextFindPreviousUtf8Codepoint;

int function(ImWchar* out_buf, int out_buf_size, immutable(char)* in_text, immutable(char)* in_text_end, immutable(char)** in_remaining)
	igImTextStrFromUtf8;

int function(immutable(char)* out_buf, int out_buf_size, ImWchar* in_text, ImWchar* in_text_end)
	igImTextStrToUtf8;

char function(char c)
	igImToUpper;

float function(ImVec2 a, ImVec2 b, ImVec2 c)
	igImTriangleArea;

void function(ImVec2 a, ImVec2 b, ImVec2 c, ImVec2 p, float* out_u, float* out_v, float* out_w)
	igImTriangleBarycentricCoords;

void function(ImVec2* pOut, ImVec2 a, ImVec2 b, ImVec2 c, ImVec2 p)
	igImTriangleClosestPoint;

bool function(ImVec2 a, ImVec2 b, ImVec2 c, ImVec2 p)
	igImTriangleContainsPoint;

bool function(ImVec2 a, ImVec2 b, ImVec2 c)
	igImTriangleIsClockwise;

float function(float f)
	igImTrunc_Float;

void function(ImVec2* pOut, ImVec2 v)
	igImTrunc_Vec2;

int function(int v)
	igImUpperPowerOfTwo;

void function(ImTextureID user_texture_id, ImVec2 image_size, ImVec2 uv0, ImVec2 uv1, ImVec4 tint_col, ImVec4 border_col)
	igImage;

bool function(immutable(char)* str_id, ImTextureID user_texture_id, ImVec2 image_size, ImVec2 uv0, ImVec2 uv1, ImVec4 bg_col, ImVec4 tint_col)
	igImageButton;

bool function(ImGuiID id, ImTextureID texture_id, ImVec2 image_size, ImVec2 uv0, ImVec2 uv1, ImVec4 bg_col, ImVec4 tint_col, ImGuiButtonFlags flags)
	igImageButtonEx;

void function(float indent_w)
	igIndent;

void function()
	igInitialize;

bool function(immutable(char)* label, double* v, double step, double step_fast, immutable(char)* format, ImGuiInputTextFlags flags)
	igInputDouble;

bool function(immutable(char)* label, float* v, float step, float step_fast, immutable(char)* format, ImGuiInputTextFlags flags)
	igInputFloat;

bool function(immutable(char)* label, ref float[2] v, immutable(char)* format, ImGuiInputTextFlags flags)
	igInputFloat2;

bool function(immutable(char)* label, ref float[3] v, immutable(char)* format, ImGuiInputTextFlags flags)
	igInputFloat3;

bool function(immutable(char)* label, ref float[4] v, immutable(char)* format, ImGuiInputTextFlags flags)
	igInputFloat4;

bool function(immutable(char)* label, int* v, int step, int step_fast, ImGuiInputTextFlags flags)
	igInputInt;

bool function(immutable(char)* label, ref int[2] v, ImGuiInputTextFlags flags)
	igInputInt2;

bool function(immutable(char)* label, ref int[3] v, ImGuiInputTextFlags flags)
	igInputInt3;

bool function(immutable(char)* label, ref int[4] v, ImGuiInputTextFlags flags)
	igInputInt4;

bool function(immutable(char)* label, ImGuiDataType data_type, void* p_data, void* p_step, void* p_step_fast, immutable(char)* format, ImGuiInputTextFlags flags)
	igInputScalar;

bool function(immutable(char)* label, ImGuiDataType data_type, void* p_data, int components, void* p_step, void* p_step_fast, immutable(char)* format, ImGuiInputTextFlags flags)
	igInputScalarN;

bool function(immutable(char)* label, immutable(char)* buf, size_t buf_size, ImGuiInputTextFlags flags, ImGuiInputTextCallback callback, void* user_data)
	igInputText;

void function(ImGuiID id)
	igInputTextDeactivateHook;

bool function(immutable(char)* label, immutable(char)* hint, immutable(char)* buf, int buf_size, ImVec2 size_arg, ImGuiInputTextFlags flags, ImGuiInputTextCallback callback, void* user_data)
	igInputTextEx;

bool function(immutable(char)* label, immutable(char)* buf, size_t buf_size, ImVec2 size, ImGuiInputTextFlags flags, ImGuiInputTextCallback callback, void* user_data)
	igInputTextMultiline;

bool function(immutable(char)* label, immutable(char)* hint, immutable(char)* buf, size_t buf_size, ImGuiInputTextFlags flags, ImGuiInputTextCallback callback, void* user_data)
	igInputTextWithHint;

bool function(immutable(char)* str_id, ImVec2 size, ImGuiButtonFlags flags)
	igInvisibleButton;

bool function(ImGuiDir dir)
	igIsActiveIdUsingNavDir;

bool function(ImGuiKey key)
	igIsAliasKey;

bool function()
	igIsAnyItemActive;

bool function()
	igIsAnyItemFocused;

bool function()
	igIsAnyItemHovered;

bool function()
	igIsAnyMouseDown;

bool function(ImRect bb, ImGuiID id)
	igIsClippedEx;

bool function()
	igIsDragDropActive;

bool function()
	igIsDragDropPayloadBeingAccepted;

bool function(ImGuiKey key)
	igIsGamepadKey;

bool function()
	igIsItemActivated;

bool function()
	igIsItemActive;

bool function(ImGuiMouseButton mouse_button)
	igIsItemClicked;

bool function()
	igIsItemDeactivated;

bool function()
	igIsItemDeactivatedAfterEdit;

bool function()
	igIsItemEdited;

bool function()
	igIsItemFocused;

bool function(ImGuiHoveredFlags flags)
	igIsItemHovered;

bool function()
	igIsItemToggledOpen;

bool function()
	igIsItemToggledSelection;

bool function()
	igIsItemVisible;

bool function(ImGuiKeyChord key_chord, ImGuiInputFlags flags, ImGuiID owner_id)
	igIsKeyChordPressed_InputFlags;

bool function(ImGuiKeyChord key_chord)
	igIsKeyChordPressed_Nil;

bool function(ImGuiKey key, ImGuiID owner_id)
	igIsKeyDown_ID;

bool function(ImGuiKey key)
	igIsKeyDown_Nil;

bool function(ImGuiKey key, bool repeat)
	igIsKeyPressed_Bool;

bool function(ImGuiKey key, ImGuiInputFlags flags, ImGuiID owner_id)
	igIsKeyPressed_InputFlags;

bool function(ImGuiKey key, ImGuiID owner_id)
	igIsKeyReleased_ID;

bool function(ImGuiKey key)
	igIsKeyReleased_Nil;

bool function(ImGuiKey key)
	igIsKeyboardKey;

bool function(ImGuiKey key)
	igIsLegacyKey;

bool function(ImGuiKey key)
	igIsModKey;

bool function(ImGuiMouseButton button, bool repeat)
	igIsMouseClicked_Bool;

bool function(ImGuiMouseButton button, ImGuiInputFlags flags, ImGuiID owner_id)
	igIsMouseClicked_InputFlags;

bool function(ImGuiMouseButton button, ImGuiID owner_id)
	igIsMouseDoubleClicked_ID;

bool function(ImGuiMouseButton button)
	igIsMouseDoubleClicked_Nil;

bool function(ImGuiMouseButton button, ImGuiID owner_id)
	igIsMouseDown_ID;

bool function(ImGuiMouseButton button)
	igIsMouseDown_Nil;

bool function(ImGuiMouseButton button, float lock_threshold)
	igIsMouseDragPastThreshold;

bool function(ImGuiMouseButton button, float lock_threshold)
	igIsMouseDragging;

bool function(ImVec2 r_min, ImVec2 r_max, bool clip)
	igIsMouseHoveringRect;

bool function(ImGuiKey key)
	igIsMouseKey;

bool function(ImVec2* mouse_pos)
	igIsMousePosValid;

bool function(ImGuiMouseButton button, ImGuiID owner_id)
	igIsMouseReleased_ID;

bool function(ImGuiMouseButton button)
	igIsMouseReleased_Nil;

bool function(ImGuiKey key)
	igIsNamedKey;

bool function(ImGuiKey key)
	igIsNamedKeyOrMod;

bool function(ImGuiID id, ImGuiPopupFlags popup_flags)
	igIsPopupOpen_ID;

bool function(immutable(char)* str_id, ImGuiPopupFlags flags)
	igIsPopupOpen_Str;

bool function(ImVec2 size)
	igIsRectVisible_Nil;

bool function(ImVec2 rect_min, ImVec2 rect_max)
	igIsRectVisible_Vec2;

bool function(ImGuiWindow* potential_above, ImGuiWindow* potential_below)
	igIsWindowAbove;

bool function()
	igIsWindowAppearing;

bool function(ImGuiWindow* window, ImGuiWindow* potential_parent, bool popup_hierarchy, bool dock_hierarchy)
	igIsWindowChildOf;

bool function()
	igIsWindowCollapsed;

bool function(ImGuiWindow* window, ImGuiHoveredFlags flags)
	igIsWindowContentHoverable;

bool function()
	igIsWindowDocked;

bool function(ImGuiFocusedFlags flags)
	igIsWindowFocused;

bool function(ImGuiHoveredFlags flags)
	igIsWindowHovered;

bool function(ImGuiWindow* window)
	igIsWindowNavFocusable;

bool function(ImGuiWindow* window, ImGuiWindow* potential_parent)
	igIsWindowWithinBeginStackOf;

bool function(ImRect bb, ImGuiID id, ImRect* nav_bb, ImGuiItemFlags extra_flags)
	igItemAdd;

bool function(ImRect bb, ImGuiID id, ImGuiItemFlags item_flags)
	igItemHoverable;

void function(ImRect bb, float text_baseline_y)
	igItemSize_Rect;

void function(ImVec2 size, float text_baseline_y)
	igItemSize_Vec2;

void function(ImGuiID id)
	igKeepAliveID;

void function(immutable(char)* label, immutable(char)* fmt, ...)
	igLabelText;

void function(immutable(char)* label, immutable(char)* fmt, va_list args)
	igLabelTextV;

bool function(immutable(char)* label, int* current_item, immutable(char)* function(void* user_data, int idx) nothrow getter, void* user_data, int items_count, int height_in_items)
	igListBox_FnStrPtr;

bool function(immutable(char)* label, int* current_item, immutable(char)** items, int items_count, int height_in_items)
	igListBox_Str_arr;

void function(immutable(char)* ini_filename)
	igLoadIniSettingsFromDisk;

void function(immutable(char)* ini_data, size_t ini_size)
	igLoadIniSettingsFromMemory;

immutable(char)* function(ImGuiLocKey key)
	igLocalizeGetMsg;

void function(ImGuiLocEntry* entries, int count)
	igLocalizeRegisterEntries;

void function(ImGuiLogType type, int auto_open_depth)
	igLogBegin;

void function()
	igLogButtons;

void function()
	igLogFinish;

void function(ImVec2* ref_pos, immutable(char)* text, immutable(char)* text_end)
	igLogRenderedText;

void function(immutable(char)* prefix, immutable(char)* suffix)
	igLogSetNextTextDecoration;

void function(immutable(char)* fmt, ...)
	igLogText;

void function(immutable(char)* fmt, va_list args)
	igLogTextV;

void function(int auto_open_depth)
	igLogToBuffer;

void function(int auto_open_depth)
	igLogToClipboard;

void function(int auto_open_depth, immutable(char)* filename)
	igLogToFile;

void function(int auto_open_depth)
	igLogToTTY;

void function()
	igMarkIniSettingsDirty_Nil;

void function(ImGuiWindow* window)
	igMarkIniSettingsDirty_WindowPtr;

void function(ImGuiID id)
	igMarkItemEdited;

void* function(size_t size)
	igMemAlloc;

void function(void* ptr)
	igMemFree;

bool function(immutable(char)* label, immutable(char)* icon, immutable(char)* shortcut, bool selected, bool enabled)
	igMenuItemEx;

bool function(immutable(char)* label, immutable(char)* shortcut, bool selected, bool enabled)
	igMenuItem_Bool;

bool function(immutable(char)* label, immutable(char)* shortcut, bool* p_selected, bool enabled)
	igMenuItem_BoolPtr;

ImGuiKey function(ImGuiMouseButton button)
	igMouseButtonToKey;

void function(ImGuiMultiSelectTempData* ms, bool selected)
	igMultiSelectAddSetAll;

void function(ImGuiMultiSelectTempData* ms, bool selected, int range_dir, ImGuiSelectionUserData first_item, ImGuiSelectionUserData last_item)
	igMultiSelectAddSetRange;

void function(ImGuiID id, bool* p_selected, bool* p_pressed)
	igMultiSelectItemFooter;

void function(ImGuiID id, bool* p_selected, ImGuiButtonFlags* p_button_flags)
	igMultiSelectItemHeader;

void function(ImGuiAxis axis)
	igNavClearPreferredPosForAxis;

void function(ImGuiID id)
	igNavHighlightActivated;

void function()
	igNavInitRequestApplyResult;

void function(ImGuiWindow* window, bool force_reinit)
	igNavInitWindow;

void function()
	igNavMoveRequestApplyResult;

bool function()
	igNavMoveRequestButNoResultYet;

void function()
	igNavMoveRequestCancel;

void function(ImGuiDir move_dir, ImGuiDir clip_dir, ImGuiNavMoveFlags move_flags, ImGuiScrollFlags scroll_flags)
	igNavMoveRequestForward;

void function(ImGuiNavItemData* result)
	igNavMoveRequestResolveWithLastItem;

void function(ImGuiNavItemData* result, ImGuiTreeNodeStackData* tree_node_data)
	igNavMoveRequestResolveWithPastTreeNode;

void function(ImGuiDir move_dir, ImGuiDir clip_dir, ImGuiNavMoveFlags move_flags, ImGuiScrollFlags scroll_flags)
	igNavMoveRequestSubmit;

void function(ImGuiWindow* window, ImGuiNavMoveFlags move_flags)
	igNavMoveRequestTryWrapping;

void function()
	igNavRestoreHighlightAfterMove;

void function()
	igNavUpdateCurrentWindowIsScrollPushableX;

void function()
	igNewFrame;

void function()
	igNewLine;

void function()
	igNextColumn;

void function(ImGuiID id, ImGuiPopupFlags popup_flags)
	igOpenPopupEx;

void function(immutable(char)* str_id, ImGuiPopupFlags popup_flags)
	igOpenPopupOnItemClick;

void function(ImGuiID id, ImGuiPopupFlags popup_flags)
	igOpenPopup_ID;

void function(immutable(char)* str_id, ImGuiPopupFlags popup_flags)
	igOpenPopup_Str;

int function(ImGuiPlotType plot_type, immutable(char)* label, float function(void* data, int idx) nothrow values_getter, void* data, int values_count, int values_offset, immutable(char)* overlay_text, float scale_min, float scale_max, ImVec2 size_arg)
	igPlotEx;

void function(immutable(char)* label, float* values, int values_count, int values_offset, immutable(char)* overlay_text, float scale_min, float scale_max, ImVec2 graph_size, int stride)
	igPlotHistogram_FloatPtr;

void function(immutable(char)* label, float function(void* data, int idx) nothrow values_getter, void* data, int values_count, int values_offset, immutable(char)* overlay_text, float scale_min, float scale_max, ImVec2 graph_size)
	igPlotHistogram_FnFloatPtr;

void function(immutable(char)* label, float* values, int values_count, int values_offset, immutable(char)* overlay_text, float scale_min, float scale_max, ImVec2 graph_size, int stride)
	igPlotLines_FloatPtr;

void function(immutable(char)* label, float function(void* data, int idx) nothrow values_getter, void* data, int values_count, int values_offset, immutable(char)* overlay_text, float scale_min, float scale_max, ImVec2 graph_size)
	igPlotLines_FnFloatPtr;

void function()
	igPopClipRect;

void function()
	igPopColumnsBackground;

void function()
	igPopFocusScope;

void function()
	igPopFont;

void function()
	igPopID;

void function()
	igPopItemFlag;

void function()
	igPopItemWidth;

void function(int count)
	igPopStyleColor;

void function(int count)
	igPopStyleVar;

void function()
	igPopTextWrapPos;

void function(float fraction, ImVec2 size_arg, immutable(char)* overlay)
	igProgressBar;

void function(ImVec2 clip_rect_min, ImVec2 clip_rect_max, bool intersect_with_current_clip_rect)
	igPushClipRect;

void function(int column_index)
	igPushColumnClipRect;

void function()
	igPushColumnsBackground;

void function(ImGuiID id)
	igPushFocusScope;

void function(ImFont* font)
	igPushFont;

void function(int int_id)
	igPushID_Int;

void function(void* ptr_id)
	igPushID_Ptr;

void function(immutable(char)* str_id)
	igPushID_Str;

void function(immutable(char)* str_id_begin, immutable(char)* str_id_end)
	igPushID_StrStr;

void function(ImGuiItemFlags option, bool enabled)
	igPushItemFlag;

void function(float item_width)
	igPushItemWidth;

void function(int components, float width_full)
	igPushMultiItemsWidths;

void function(ImGuiID id)
	igPushOverrideID;

void function(ImGuiCol idx, ImU32 col)
	igPushStyleColor_U32;

void function(ImGuiCol idx, ImVec4 col)
	igPushStyleColor_Vec4;

void function(ImGuiStyleVar idx, float val)
	igPushStyleVar_Float;

void function(ImGuiStyleVar idx, ImVec2 val)
	igPushStyleVar_Vec2;

void function(float wrap_local_pos_x)
	igPushTextWrapPos;

bool function(immutable(char)* label, bool active)
	igRadioButton_Bool;

bool function(immutable(char)* label, int* v, int v_button)
	igRadioButton_IntPtr;

void function(ImGuiContext* context, ImGuiID hook_to_remove)
	igRemoveContextHook;

void function(immutable(char)* type_name)
	igRemoveSettingsHandler;

void function()
	igRender;

void function(ImDrawList* draw_list, ImVec2 pos, ImU32 col, ImGuiDir dir, float scale)
	igRenderArrow;

void function(ImDrawList* draw_list, ImVec2 p_min, float sz, ImU32 col)
	igRenderArrowDockMenu;

void function(ImDrawList* draw_list, ImVec2 pos, ImVec2 half_sz, ImGuiDir direction, ImU32 col)
	igRenderArrowPointingAt;

void function(ImDrawList* draw_list, ImVec2 pos, ImU32 col)
	igRenderBullet;

void function(ImDrawList* draw_list, ImVec2 pos, ImU32 col, float sz)
	igRenderCheckMark;

void function(ImDrawList* draw_list, ImVec2 p_min, ImVec2 p_max, ImU32 fill_col, float grid_step, ImVec2 grid_off, float rounding, ImDrawFlags flags)
	igRenderColorRectWithAlphaCheckerboard;

void function(ImRect bb, ImRect item_clip_rect)
	igRenderDragDropTargetRect;

void function(ImVec2 p_min, ImVec2 p_max, ImU32 fill_col, bool border, float rounding)
	igRenderFrame;

void function(ImVec2 p_min, ImVec2 p_max, float rounding)
	igRenderFrameBorder;

void function(ImVec2 pos, float scale, ImGuiMouseCursor mouse_cursor, ImU32 col_fill, ImU32 col_border, ImU32 col_shadow)
	igRenderMouseCursor;

void function(ImRect bb, ImGuiID id, ImGuiNavHighlightFlags flags)
	igRenderNavHighlight;

void function(void* platform_render_arg, void* renderer_render_arg)
	igRenderPlatformWindowsDefault;

void function(ImDrawList* draw_list, ImRect rect, ImU32 col, float x_start_norm, float x_end_norm, float rounding)
	igRenderRectFilledRangeH;

void function(ImDrawList* draw_list, ImRect outer, ImRect inner, ImU32 col, float rounding)
	igRenderRectFilledWithHole;

void function(ImVec2 pos, immutable(char)* text, immutable(char)* text_end, bool hide_text_after_hash)
	igRenderText;

void function(ImVec2 pos_min, ImVec2 pos_max, immutable(char)* text, immutable(char)* text_end, ImVec2* text_size_if_known, ImVec2 align_, ImRect* clip_rect)
	igRenderTextClipped;

void function(ImDrawList* draw_list, ImVec2 pos_min, ImVec2 pos_max, immutable(char)* text, immutable(char)* text_end, ImVec2* text_size_if_known, ImVec2 align_, ImRect* clip_rect)
	igRenderTextClippedEx;

void function(ImDrawList* draw_list, ImVec2 pos_min, ImVec2 pos_max, float clip_max_x, float ellipsis_max_x, immutable(char)* text, immutable(char)* text_end, ImVec2* text_size_if_known)
	igRenderTextEllipsis;

void function(ImVec2 pos, immutable(char)* text, immutable(char)* text_end, float wrap_width)
	igRenderTextWrapped;

void function(ImGuiMouseButton button)
	igResetMouseDragDelta;

void function(float offset_from_start_x, float spacing)
	igSameLine;

void function(immutable(char)* ini_filename)
	igSaveIniSettingsToDisk;

immutable(char)* function(size_t* out_ini_size)
	igSaveIniSettingsToMemory;

void function(ImGuiViewportP* viewport, float scale)
	igScaleWindowsInViewport;

void function(ImGuiWindow* window, ImRect rect)
	igScrollToBringRectIntoView;

void function(ImGuiScrollFlags flags)
	igScrollToItem;

void function(ImGuiWindow* window, ImRect rect, ImGuiScrollFlags flags)
	igScrollToRect;

void function(ImVec2* pOut, ImGuiWindow* window, ImRect rect, ImGuiScrollFlags flags)
	igScrollToRectEx;

void function(ImGuiAxis axis)
	igScrollbar;

bool function(ImRect bb, ImGuiID id, ImGuiAxis axis, ImS64* p_scroll_v, ImS64 avail_v, ImS64 contents_v, ImDrawFlags flags)
	igScrollbarEx;

bool function(immutable(char)* label, bool selected, ImGuiSelectableFlags flags, ImVec2 size)
	igSelectable_Bool;

bool function(immutable(char)* label, bool* p_selected, ImGuiSelectableFlags flags, ImVec2 size)
	igSelectable_BoolPtr;

void function()
	igSeparator;

void function(ImGuiSeparatorFlags flags, float thickness)
	igSeparatorEx;

void function(immutable(char)* label)
	igSeparatorText;

void function(ImGuiID id, immutable(char)* label, immutable(char)* label_end, float extra_width)
	igSeparatorTextEx;

void function(ImGuiID id, ImGuiWindow* window)
	igSetActiveID;

void function()
	igSetActiveIdUsingAllKeyboardKeys;

void function(ImGuiMemAllocFunc alloc_func, ImGuiMemFreeFunc free_func, void* user_data)
	igSetAllocatorFunctions;

void function(immutable(char)* text)
	igSetClipboardText;

void function(ImGuiColorEditFlags flags)
	igSetColorEditOptions;

void function(int column_index, float offset_x)
	igSetColumnOffset;

void function(int column_index, float width)
	igSetColumnWidth;

void function(ImGuiContext* ctx)
	igSetCurrentContext;

void function(ImFont* font)
	igSetCurrentFont;

void function(ImGuiWindow* window, ImGuiViewportP* viewport)
	igSetCurrentViewport;

void function(ImVec2 local_pos)
	igSetCursorPos;

void function(float local_x)
	igSetCursorPosX;

void function(float local_y)
	igSetCursorPosY;

void function(ImVec2 pos)
	igSetCursorScreenPos;

bool function(immutable(char)* type, void* data, size_t sz, ImGuiCond cond)
	igSetDragDropPayload;

void function(ImGuiID id, ImGuiWindow* window)
	igSetFocusID;

void function(ImGuiID id)
	igSetHoveredID;

void function()
	igSetItemDefaultFocus;

void function(ImGuiKey key, ImGuiInputFlags flags)
	igSetItemKeyOwner_InputFlags;

void function(ImGuiKey key)
	igSetItemKeyOwner_Nil;

void function(immutable(char)* fmt, ...)
	igSetItemTooltip;

void function(immutable(char)* fmt, va_list args)
	igSetItemTooltipV;

void function(ImGuiKey key, ImGuiID owner_id, ImGuiInputFlags flags)
	igSetKeyOwner;

void function(ImGuiKeyChord key, ImGuiID owner_id, ImGuiInputFlags flags)
	igSetKeyOwnersForKeyChord;

void function(int offset)
	igSetKeyboardFocusHere;

void function(ImGuiID item_id, ImGuiItemFlags in_flags, ImGuiItemStatusFlags status_flags, ImRect item_rect)
	igSetLastItemData;

void function(ImGuiMouseCursor cursor_type)
	igSetMouseCursor;

void function(ImGuiID focus_scope_id)
	igSetNavFocusScope;

void function(ImGuiID id, ImGuiNavLayer nav_layer, ImGuiID focus_scope_id, ImRect rect_rel)
	igSetNavID;

void function(ImGuiWindow* window)
	igSetNavWindow;

void function(bool want_capture_keyboard)
	igSetNextFrameWantCaptureKeyboard;

void function(bool want_capture_mouse)
	igSetNextFrameWantCaptureMouse;

void function()
	igSetNextItemAllowOverlap;

void function(bool is_open, ImGuiCond cond)
	igSetNextItemOpen;

void function(ImGuiDataType data_type, void* p_data)
	igSetNextItemRefVal;

void function(ImGuiSelectionUserData selection_user_data)
	igSetNextItemSelectionUserData;

void function(ImGuiKeyChord key_chord, ImGuiInputFlags flags)
	igSetNextItemShortcut;

void function(ImGuiID storage_id)
	igSetNextItemStorageID;

void function(float item_width)
	igSetNextItemWidth;

void function(float alpha)
	igSetNextWindowBgAlpha;

void function(ImGuiWindowClass* window_class)
	igSetNextWindowClass;

void function(bool collapsed, ImGuiCond cond)
	igSetNextWindowCollapsed;

void function(ImVec2 size)
	igSetNextWindowContentSize;

void function(ImGuiID dock_id, ImGuiCond cond)
	igSetNextWindowDockID;

void function()
	igSetNextWindowFocus;

void function(ImVec2 pos, ImGuiCond cond, ImVec2 pivot)
	igSetNextWindowPos;

void function(ImGuiWindowRefreshFlags flags)
	igSetNextWindowRefreshPolicy;

void function(ImVec2 scroll)
	igSetNextWindowScroll;

void function(ImVec2 size, ImGuiCond cond)
	igSetNextWindowSize;

void function(ImVec2 size_min, ImVec2 size_max, ImGuiSizeCallback custom_callback, void* custom_callback_data)
	igSetNextWindowSizeConstraints;

void function(ImGuiID viewport_id)
	igSetNextWindowViewport;

void function(float local_x, float center_x_ratio)
	igSetScrollFromPosX_Float;

void function(ImGuiWindow* window, float local_x, float center_x_ratio)
	igSetScrollFromPosX_WindowPtr;

void function(float local_y, float center_y_ratio)
	igSetScrollFromPosY_Float;

void function(ImGuiWindow* window, float local_y, float center_y_ratio)
	igSetScrollFromPosY_WindowPtr;

void function(float center_x_ratio)
	igSetScrollHereX;

void function(float center_y_ratio)
	igSetScrollHereY;

void function(float scroll_x)
	igSetScrollX_Float;

void function(ImGuiWindow* window, float scroll_x)
	igSetScrollX_WindowPtr;

void function(float scroll_y)
	igSetScrollY_Float;

void function(ImGuiWindow* window, float scroll_y)
	igSetScrollY_WindowPtr;

bool function(ImGuiKeyChord key_chord, ImGuiInputFlags flags, ImGuiID owner_id)
	igSetShortcutRouting;

void function(ImGuiStorage* storage)
	igSetStateStorage;

void function(immutable(char)* tab_or_docked_window_label)
	igSetTabItemClosed;

void function(immutable(char)* fmt, ...)
	igSetTooltip;

void function(immutable(char)* fmt, va_list args)
	igSetTooltipV;

void function(ImGuiWindow* window, ImRect clip_rect)
	igSetWindowClipRectBeforeSetChannel;

void function(bool collapsed, ImGuiCond cond)
	igSetWindowCollapsed_Bool;

void function(immutable(char)* name, bool collapsed, ImGuiCond cond)
	igSetWindowCollapsed_Str;

void function(ImGuiWindow* window, bool collapsed, ImGuiCond cond)
	igSetWindowCollapsed_WindowPtr;

void function(ImGuiWindow* window, ImGuiID dock_id, ImGuiCond cond)
	igSetWindowDock;

void function()
	igSetWindowFocus_Nil;

void function(immutable(char)* name)
	igSetWindowFocus_Str;

void function(float scale)
	igSetWindowFontScale;

void function(ImGuiWindow* window)
	igSetWindowHiddenAndSkipItemsForCurrentFrame;

void function(ImGuiWindow* window, ImVec2 pos, ImVec2 size)
	igSetWindowHitTestHole;

void function(ImGuiWindow* window, ImGuiWindow* parent_window)
	igSetWindowParentWindowForFocusRoute;

void function(immutable(char)* name, ImVec2 pos, ImGuiCond cond)
	igSetWindowPos_Str;

void function(ImVec2 pos, ImGuiCond cond)
	igSetWindowPos_Vec2;

void function(ImGuiWindow* window, ImVec2 pos, ImGuiCond cond)
	igSetWindowPos_WindowPtr;

void function(immutable(char)* name, ImVec2 size, ImGuiCond cond)
	igSetWindowSize_Str;

void function(ImVec2 size, ImGuiCond cond)
	igSetWindowSize_Vec2;

void function(ImGuiWindow* window, ImVec2 size, ImGuiCond cond)
	igSetWindowSize_WindowPtr;

void function(ImGuiWindow* window, ImGuiViewportP* viewport)
	igSetWindowViewport;

void function(ImDrawList* draw_list, int vert_start_idx, int vert_end_idx, ImVec2 gradient_p0, ImVec2 gradient_p1, ImU32 col0, ImU32 col1)
	igShadeVertsLinearColorGradientKeepAlpha;

void function(ImDrawList* draw_list, int vert_start_idx, int vert_end_idx, ImVec2 a, ImVec2 b, ImVec2 uv_a, ImVec2 uv_b, bool clamp)
	igShadeVertsLinearUV;

void function(ImDrawList* draw_list, int vert_start_idx, int vert_end_idx, ImVec2 pivot_in, float cos_a, float sin_a, ImVec2 pivot_out)
	igShadeVertsTransformPos;

bool function(ImGuiKeyChord key_chord, ImGuiInputFlags flags, ImGuiID owner_id)
	igShortcut_ID;

bool function(ImGuiKeyChord key_chord, ImGuiInputFlags flags)
	igShortcut_Nil;

void function(bool* p_open)
	igShowAboutWindow;

void function(bool* p_open)
	igShowDebugLogWindow;

void function(bool* p_open)
	igShowDemoWindow;

void function(ImFontAtlas* atlas)
	igShowFontAtlas;

void function(immutable(char)* label)
	igShowFontSelector;

void function(bool* p_open)
	igShowIDStackToolWindow;

void function(bool* p_open)
	igShowMetricsWindow;

void function(ImGuiStyle* ref_)
	igShowStyleEditor;

bool function(immutable(char)* label)
	igShowStyleSelector;

void function()
	igShowUserGuide;

void function(ImGuiShrinkWidthItem* items, int count, float width_excess)
	igShrinkWidths;

void function()
	igShutdown;

bool function(immutable(char)* label, float* v_rad, float v_degrees_min, float v_degrees_max, immutable(char)* format, ImGuiSliderFlags flags)
	igSliderAngle;

bool function(ImRect bb, ImGuiID id, ImGuiDataType data_type, void* p_v, void* p_min, void* p_max, immutable(char)* format, ImGuiSliderFlags flags, ImRect* out_grab_bb)
	igSliderBehavior;

bool function(immutable(char)* label, float* v, float v_min, float v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igSliderFloat;

bool function(immutable(char)* label, ref float[2] v, float v_min, float v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igSliderFloat2;

bool function(immutable(char)* label, ref float[3] v, float v_min, float v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igSliderFloat3;

bool function(immutable(char)* label, ref float[4] v, float v_min, float v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igSliderFloat4;

bool function(immutable(char)* label, int* v, int v_min, int v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igSliderInt;

bool function(immutable(char)* label, ref int[2] v, int v_min, int v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igSliderInt2;

bool function(immutable(char)* label, ref int[3] v, int v_min, int v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igSliderInt3;

bool function(immutable(char)* label, ref int[4] v, int v_min, int v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igSliderInt4;

bool function(immutable(char)* label, ImGuiDataType data_type, void* p_data, void* p_min, void* p_max, immutable(char)* format, ImGuiSliderFlags flags)
	igSliderScalar;

bool function(immutable(char)* label, ImGuiDataType data_type, void* p_data, int components, void* p_min, void* p_max, immutable(char)* format, ImGuiSliderFlags flags)
	igSliderScalarN;

bool function(immutable(char)* label)
	igSmallButton;

void function()
	igSpacing;

bool function(ImRect bb, ImGuiID id, ImGuiAxis axis, float* size1, float* size2, float min_size1, float min_size2, float hover_extend, float hover_visibility_delay, ImU32 bg_col)
	igSplitterBehavior;

void function(ImGuiWindow* window)
	igStartMouseMovingWindow;

void function(ImGuiWindow* window, ImGuiDockNode* node, bool undock)
	igStartMouseMovingWindowOrNode;

void function(ImGuiStyle* dst)
	igStyleColorsClassic;

void function(ImGuiStyle* dst)
	igStyleColorsDark;

void function(ImGuiStyle* dst)
	igStyleColorsLight;

void function(ImGuiTabBar* tab_bar, ImGuiTabItemFlags tab_flags, ImGuiWindow* window)
	igTabBarAddTab;

void function(ImGuiTabBar* tab_bar, ImGuiTabItem* tab)
	igTabBarCloseTab;

ImGuiTabItem* function(ImGuiTabBar* tab_bar)
	igTabBarFindMostRecentlySelectedTabForActiveWindow;

ImGuiTabItem* function(ImGuiTabBar* tab_bar, ImGuiID tab_id)
	igTabBarFindTabByID;

ImGuiTabItem* function(ImGuiTabBar* tab_bar, int order)
	igTabBarFindTabByOrder;

ImGuiTabItem* function(ImGuiTabBar* tab_bar)
	igTabBarGetCurrentTab;

immutable(char)* function(ImGuiTabBar* tab_bar, ImGuiTabItem* tab)
	igTabBarGetTabName;

int function(ImGuiTabBar* tab_bar, ImGuiTabItem* tab)
	igTabBarGetTabOrder;

bool function(ImGuiTabBar* tab_bar)
	igTabBarProcessReorder;

void function(ImGuiTabBar* tab_bar, ImGuiTabItem* tab)
	igTabBarQueueFocus;

void function(ImGuiTabBar* tab_bar, ImGuiTabItem* tab, int offset)
	igTabBarQueueReorder;

void function(ImGuiTabBar* tab_bar, ImGuiTabItem* tab, ImVec2 mouse_pos)
	igTabBarQueueReorderFromMousePos;

void function(ImGuiTabBar* tab_bar, ImGuiID tab_id)
	igTabBarRemoveTab;

void function(ImDrawList* draw_list, ImRect bb, ImGuiTabItemFlags flags, ImU32 col)
	igTabItemBackground;

bool function(immutable(char)* label, ImGuiTabItemFlags flags)
	igTabItemButton;

void function(ImVec2* pOut, immutable(char)* label, bool has_close_button_or_unsaved_marker)
	igTabItemCalcSize_Str;

void function(ImVec2* pOut, ImGuiWindow* window)
	igTabItemCalcSize_WindowPtr;

bool function(ImGuiTabBar* tab_bar, immutable(char)* label, bool* p_open, ImGuiTabItemFlags flags, ImGuiWindow* docked_window)
	igTabItemEx;

void function(ImDrawList* draw_list, ImRect bb, ImGuiTabItemFlags flags, ImVec2 frame_padding, immutable(char)* label, ImGuiID tab_id, ImGuiID close_button_id, bool is_contents_visible, bool* out_just_closed, bool* out_text_clipped)
	igTabItemLabelAndCloseButton;

void function()
	igTableAngledHeadersRow;

void function(ImGuiID row_id, float angle, float max_label_width, ImGuiTableHeaderData* data, int data_count)
	igTableAngledHeadersRowEx;

void function(ImGuiTable* table)
	igTableBeginApplyRequests;

void function(ImGuiTable* table, int column_n)
	igTableBeginCell;

bool function(ImGuiTable* table)
	igTableBeginContextMenuPopup;

void function(ImGuiTable* table, int columns_count)
	igTableBeginInitMemory;

void function(ImGuiTable* table)
	igTableBeginRow;

void function(ImGuiTable* table)
	igTableDrawBorders;

void function(ImGuiTable* table, ImGuiTableFlags flags_for_section_to_display)
	igTableDrawDefaultContextMenu;

void function(ImGuiTable* table)
	igTableEndCell;

void function(ImGuiTable* table)
	igTableEndRow;

ImGuiTable* function(ImGuiID id)
	igTableFindByID;

void function(ImGuiTable* table, ImGuiTableColumn* column)
	igTableFixColumnSortDirection;

void function()
	igTableGcCompactSettings;

void function(ImGuiTable* table)
	igTableGcCompactTransientBuffers_TablePtr;

void function(ImGuiTableTempData* table)
	igTableGcCompactTransientBuffers_TableTempDataPtr;

ImGuiTableSettings* function(ImGuiTable* table)
	igTableGetBoundSettings;

void function(ImRect* pOut, ImGuiTable* table, int column_n)
	igTableGetCellBgRect;

int function()
	igTableGetColumnCount;

ImGuiTableColumnFlags function(int column_n)
	igTableGetColumnFlags;

int function()
	igTableGetColumnIndex;

immutable(char)* function(int column_n)
	igTableGetColumnName_Int;

immutable(char)* function(ImGuiTable* table, int column_n)
	igTableGetColumnName_TablePtr;

ImGuiSortDirection function(ImGuiTableColumn* column)
	igTableGetColumnNextSortDirection;

ImGuiID function(ImGuiTable* table, int column_n, int instance_no)
	igTableGetColumnResizeID;

float function(ImGuiTable* table, ImGuiTableColumn* column)
	igTableGetColumnWidthAuto;

float function()
	igTableGetHeaderAngledMaxLabelWidth;

float function()
	igTableGetHeaderRowHeight;

int function()
	igTableGetHoveredColumn;

int function()
	igTableGetHoveredRow;

ImGuiTableInstanceData* function(ImGuiTable* table, int instance_no)
	igTableGetInstanceData;

ImGuiID function(ImGuiTable* table, int instance_no)
	igTableGetInstanceID;

float function(ImGuiTable* table, int column_n)
	igTableGetMaxColumnWidth;

int function()
	igTableGetRowIndex;

ImGuiTableSortSpecs* function()
	igTableGetSortSpecs;

void function(immutable(char)* label)
	igTableHeader;

void function()
	igTableHeadersRow;

void function(ImGuiTable* table)
	igTableLoadSettings;

void function(ImGuiTable* table)
	igTableMergeDrawChannels;

bool function()
	igTableNextColumn;

void function(ImGuiTableRowFlags row_flags, float min_row_height)
	igTableNextRow;

void function(int column_n)
	igTableOpenContextMenu;

void function()
	igTablePopBackgroundChannel;

void function()
	igTablePushBackgroundChannel;

void function(ImGuiTable* table)
	igTableRemove;

void function(ImGuiTable* table)
	igTableResetSettings;

void function(ImGuiTable* table)
	igTableSaveSettings;

void function(ImGuiTableBgTarget target, ImU32 color, int column_n)
	igTableSetBgColor;

void function(int column_n, bool v)
	igTableSetColumnEnabled;

bool function(int column_n)
	igTableSetColumnIndex;

void function(int column_n, ImGuiSortDirection sort_direction, bool append_to_sort_specs)
	igTableSetColumnSortDirection;

void function(int column_n, float width)
	igTableSetColumnWidth;

void function(ImGuiTable* table)
	igTableSetColumnWidthAutoAll;

void function(ImGuiTable* table, int column_n)
	igTableSetColumnWidthAutoSingle;

void function()
	igTableSettingsAddSettingsHandler;

ImGuiTableSettings* function(ImGuiID id, int columns_count)
	igTableSettingsCreate;

ImGuiTableSettings* function(ImGuiID id)
	igTableSettingsFindByID;

void function(immutable(char)* label, ImGuiTableColumnFlags flags, float init_width_or_weight, ImGuiID user_id)
	igTableSetupColumn;

void function(ImGuiTable* table)
	igTableSetupDrawChannels;

void function(int cols, int rows)
	igTableSetupScrollFreeze;

void function(ImGuiTable* table)
	igTableSortSpecsBuild;

void function(ImGuiTable* table)
	igTableSortSpecsSanitize;

void function(ImGuiTable* table)
	igTableUpdateBorders;

void function(ImGuiTable* table)
	igTableUpdateColumnsWeightFromWidth;

void function(ImGuiTable* table)
	igTableUpdateLayout;

void function(ImVec2 pos)
	igTeleportMousePos;

bool function(ImGuiID id)
	igTempInputIsActive;

bool function(ImRect bb, ImGuiID id, immutable(char)* label, ImGuiDataType data_type, void* p_data, immutable(char)* format, void* p_clamp_min, void* p_clamp_max)
	igTempInputScalar;

bool function(ImRect bb, ImGuiID id, immutable(char)* label, immutable(char)* buf, int buf_size, ImGuiInputTextFlags flags)
	igTempInputText;

bool function(ImGuiKey key, ImGuiID owner_id)
	igTestKeyOwner;

bool function(ImGuiKeyChord key_chord, ImGuiID owner_id)
	igTestShortcutRouting;

void function(immutable(char)* fmt, ...)
	igText;

void function(ImVec4 col, immutable(char)* fmt, ...)
	igTextColored;

void function(ImVec4 col, immutable(char)* fmt, va_list args)
	igTextColoredV;

void function(immutable(char)* fmt, ...)
	igTextDisabled;

void function(immutable(char)* fmt, va_list args)
	igTextDisabledV;

void function(immutable(char)* text, immutable(char)* text_end, ImGuiTextFlags flags)
	igTextEx;

bool function(immutable(char)* label)
	igTextLink;

void function(immutable(char)* label, immutable(char)* url)
	igTextLinkOpenURL;

void function(immutable(char)* text, immutable(char)* text_end)
	igTextUnformatted;

void function(immutable(char)* fmt, va_list args)
	igTextV;

void function(immutable(char)* fmt, ...)
	igTextWrapped;

void function(immutable(char)* fmt, va_list args)
	igTextWrappedV;

void function(ImGuiViewportP* viewport, ImVec2 old_pos, ImVec2 new_pos)
	igTranslateWindowsInViewport;

bool function(ImGuiID id, ImGuiTreeNodeFlags flags, immutable(char)* label, immutable(char)* label_end)
	igTreeNodeBehavior;

bool function(void* ptr_id, ImGuiTreeNodeFlags flags, immutable(char)* fmt, va_list args)
	igTreeNodeExV_Ptr;

bool function(immutable(char)* str_id, ImGuiTreeNodeFlags flags, immutable(char)* fmt, va_list args)
	igTreeNodeExV_Str;

bool function(void* ptr_id, ImGuiTreeNodeFlags flags, immutable(char)* fmt, ...)
	igTreeNodeEx_Ptr;

bool function(immutable(char)* label, ImGuiTreeNodeFlags flags)
	igTreeNodeEx_Str;

bool function(immutable(char)* str_id, ImGuiTreeNodeFlags flags, immutable(char)* fmt, ...)
	igTreeNodeEx_StrStr;

bool function(ImGuiID storage_id)
	igTreeNodeGetOpen;

void function(ImGuiID storage_id, bool open)
	igTreeNodeSetOpen;

bool function(ImGuiID storage_id, ImGuiTreeNodeFlags flags)
	igTreeNodeUpdateNextOpen;

bool function(void* ptr_id, immutable(char)* fmt, va_list args)
	igTreeNodeV_Ptr;

bool function(immutable(char)* str_id, immutable(char)* fmt, va_list args)
	igTreeNodeV_Str;

bool function(void* ptr_id, immutable(char)* fmt, ...)
	igTreeNode_Ptr;

bool function(immutable(char)* label)
	igTreeNode_Str;

bool function(immutable(char)* str_id, immutable(char)* fmt, ...)
	igTreeNode_StrStr;

void function()
	igTreePop;

void function(ImGuiID id)
	igTreePushOverrideID;

void function(void* ptr_id)
	igTreePush_Ptr;

void function(immutable(char)* str_id)
	igTreePush_Str;

int function(ImGuiTypingSelectRequest* req, int items_count, immutable(char)* function(void* , int ) nothrow get_item_name_func, void* user_data)
	igTypingSelectFindBestLeadingMatch;

int function(ImGuiTypingSelectRequest* req, int items_count, immutable(char)* function(void* , int ) nothrow get_item_name_func, void* user_data, int nav_item_idx)
	igTypingSelectFindMatch;

int function(ImGuiTypingSelectRequest* req, int items_count, immutable(char)* function(void* , int ) nothrow get_item_name_func, void* user_data, int nav_item_idx)
	igTypingSelectFindNextSingleCharMatch;

void function(float indent_w)
	igUnindent;

void function()
	igUpdateHoveredWindowAndCaptureFlags;

void function(bool trickle_fast_inputs)
	igUpdateInputEvents;

void function()
	igUpdateMouseMovingWindowEndFrame;

void function()
	igUpdateMouseMovingWindowNewFrame;

void function()
	igUpdatePlatformWindows;

void function(ImGuiWindow* window, ImGuiWindowFlags flags, ImGuiWindow* parent_window)
	igUpdateWindowParentAndRootLinks;

void function(ImGuiWindow* window)
	igUpdateWindowSkipRefresh;

bool function(immutable(char)* label, ImVec2 size, float* v, float v_min, float v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igVSliderFloat;

bool function(immutable(char)* label, ImVec2 size, int* v, int v_min, int v_max, immutable(char)* format, ImGuiSliderFlags flags)
	igVSliderInt;

bool function(immutable(char)* label, ImVec2 size, ImGuiDataType data_type, void* p_data, void* p_min, void* p_max, immutable(char)* format, ImGuiSliderFlags flags)
	igVSliderScalar;

void function(immutable(char)* prefix, bool b)
	igValue_Bool;

void function(immutable(char)* prefix, float v, immutable(char)* float_format)
	igValue_Float;

void function(immutable(char)* prefix, int v)
	igValue_Int;

void function(immutable(char)* prefix, uint v)
	igValue_Uint;

void function(ImVec2* pOut, ImGuiWindow* window, ImVec2 p)
	igWindowPosAbsToRel;

void function(ImVec2* pOut, ImGuiWindow* window, ImVec2 p)
	igWindowPosRelToAbs;

void function(ImRect* pOut, ImGuiWindow* window, ImRect r)
	igWindowRectAbsToRel;

void function(ImRect* pOut, ImGuiWindow* window, ImRect r)
	igWindowRectRelToAbs;

}} // extern(C), __gshared

