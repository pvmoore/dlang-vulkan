
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
    float4 pos = float4(worldPos, 0, 1);
    matrix viewProj = mul(ubo.proj, ubo.view);

    // Note that mul(m,v) is for column major matrices
    //           mul(v,m) is for row major matrices  
    float4 pos2 = mul(ubo.model, pos);
    float4 pos3 = mul(viewProj, pos2);

    return VSOutput(pos3, colour, uv);
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
