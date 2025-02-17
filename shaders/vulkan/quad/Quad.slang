
struct UBO {
    float4x4 model;
    float4x4 view;
    float4x4 proj;
};

[[vk::binding(0, 0)]] ConstantBuffer<UBO> ubo;
[[vk::binding(1, 0)]] Sampler2D sampler0; 


[shader("vertex")]
VSOutput vsmain(float2 worldPos, 
                float4 colour, 
                float2 uv) 
{
    float4x4 trans = ubo.proj * ubo.view * ubo.model;

    return VSOutput(mul(float4(worldPos, 0, 1), trans), colour, uv);
}

struct VSOutput {
    float4 position  : SV_POSITION;
    float4 fragColor;
    float2 fragUV    : TEXCOORD0;
};

[shader("fragment")]
float4 fsmain(VSOutput input) : SV_TARGET {
    return sampler0.Sample(input.fragUV) * input.fragColor;
}
