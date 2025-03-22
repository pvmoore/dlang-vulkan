# Slang Cheatsheet

[Standard Library Reference](https://shader-slang.org/stdlib-reference/index.html)

```bash
slangc -target spirv \
       -profile spirv_1_2 \
       -lang glsl \
       -stage vertex \
       -fvk-use-entrypoint-name \
       -I includeDirectory \
       -O3 \
       -matrix-layout-column-major \
       -o here.hlsl \
       here.spv
```

## Layouts

When compiling GLSL, slang will default to std140 for constant buffers and std430 for storage buffers.
Use -fvk-use-scalar-layout to use scalare layout instead.

## Descriptor Bindings

        


    ConstantBuffer<T>

    StructuredBuffer<T, Std140DataLayout>
    StructuredBuffer<T, Std430DataLayout>
    StructuredBuffer<T, ScalarDataLayout>
    RWStructuredBuffer<T>

    ByteAddressBuffer
    RWByteAddressBuffer

    SamplerState : register(s0)

    Texture2D
    RWTexture2D<unorm float4>

## Attributes

    [Attributes](https://shader-slang.org/stdlib-reference/attributes/index.html)

    [shader(stage)] eg. [shader("vertex")]
    [numthreads(x : int, y : int, z : int)] eg. [numthreads(256, 1, 1)]
    [outputtopology("triangle")]   // Hull shader
    [vk::binding(binding : int, set : int)] 
    [vk::image_format(format : String)]
    [maxvertexcount(count : int)]       // geometry shader
    [vk::constant_id(1)]

## Semantics: (SV = system value)

#### Vertex shader

    - float4 BINORMAL    (per vertex binormal)
    - uint BLENDINDICES  (vertex blend indices)
    - float BLENDWEIGHT  (vertex blend weights)
    - float4 NORMAL[n]   (per vertex normal)
    - float4 POSITION[n] (object space)
    - float4 POSITIONT   (transformed)
    - float PSIZE        (point size)
    - float4 TANGENT[n]  (per vertex tangent)
    - float FOG
    - float TESSFACTOR[n]

#### Pixel shader   
    - float4 COLOR[n]    (diffuse and specular colour)
    - float4 TEXCOORD[n] (texture coordinates)
    - float VFACE        (neg = back facing, pos = front facing)
    - float2 VPOS        (screen space position)

    - float SV_ClipDistance[n]
    - float SV_CullDistance[n]
    - uint SV_Coverage
    - float SV_Depth                 (aka DEPTH)
    - float SV_DepthGreaterEqual
    - float SV_DepthLessEqual
    - uint3 SV_DispatchThreadID
    - float2 SV_DomainLocation
    - uint3 SV_GroupID
    - uint SV_GroupIndex
    - uint3 SV_GroupThreadID
    - uint SV_GSInstanceID
    - uint SV_InnerCoverage
    - float SV_InsideTessFactor
    - uint SV_InstanceID
    - bool SV_IsFrontFace            (aka VFACE)
    - uint SV_OutputControlPointID
    - float4 SV_Position             (aka POSITION, VPOS)
    - uint SV_PrimitiveID
    - uint SV_RenderTargetArrayIndex
    - uint SV_SampleIndex
    - uint SV_StencilRef
    - float(2|3|4) SV_Target[n]      (aka COLOR)
    - float(2|3|4) SV_TessFactor
    - uint SV_VertexID
    - uint SV_ViewportArrayIndex
    - uint SV_ShadingRate

## Atomics

[Atomics](https://shader-slang.org/stdlib-reference/global-decls/atomic.html)

    uint result;
    InterlockedCompareExchange(lock, 0, 1, result);
    if(result == 0) {
        printf("hello");
    }

## Push Constants

    [[vk::constant_id(0)]] const uint value = 0;
