
struct UBO {
    float4x4 model;
    float4x4 viewProj;
};

[[vk::binding(0, 0)]] ConstantBuffer<UBO> ubo;


[shader("vertex")]
VSOutput vsmain(float3 modelPos, 
                float3 colour) 
{
    float4 worldPos = mul(ubo.model, float4(modelPos, 1));
    float4 clipspacePos = mul(ubo.viewProj, worldPos);

    return VSOutput(clipspacePos, colour);
}

struct VSOutput {
    float4 position  : SV_POSITION;
    float3 fragColor;
};

[shader("fragment")]
float4 fsmain(VSOutput input) : SV_TARGET {
    return float4(input.fragColor, 0.5);
}
