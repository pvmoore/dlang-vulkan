# Converting GLSL to Slang

## Useful links

[Microsoft GLSL-to-HLSL reference](https://learn.microsoft.com/en-us/windows/uwp/gaming/glsl-to-hlsl-reference)
[Slang Standard Library Reference](https://shader-slang.org/stdlib-reference/index.html)

## Types
  
| GLSL        | Slang       | Comment   |
|-------------|-------------|-----------|
| vec2        | float2      |           |
| vec3        | float3      |           |
| vec4        | float4      |           |
| mat2        | float2x2    |           |
| mat3        | float3x3    |           |
| mat4        | float4x4    | or matrix |
| sampler2D   | Sampler2D   |           |
| sampler3D   | Sampler3D   |           |
| samplerCube | SamplerCube |           |


## Functions

| GLSL        | Slang       | Comment                                        |
|-------------|-------------|------------------------------------------------|
| mod         | fmod        |                                                |  
| atan        | atan2       | swap the arguments eg. atan(y,x) -> atan2(x,y) |       
| mix         | lerp        |                                                |

## Bindings

### Constant buffers and Uniform buffers

```glsl
layout(binding=0, set=0) uniform UBO { ... }  
```

```slang
struct UBO { ... };
[[vk::binding(0, 0)]] ConstantBuffer<UBO> ubo; 
```
## Matrix Multiplication

Multiplying matrices in Slang requires the 'mul' function.
eg.
```Slang
matrix viewProj = mul(ubo.proj, ubo.view);
```
Note that if you are multiplying a matrix by a vector then the matrix must be the first argument if you are using column major matrices.






