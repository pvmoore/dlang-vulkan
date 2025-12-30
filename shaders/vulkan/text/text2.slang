#language slang 2026

struct UBO {
    matrix viewProj;
    float4 dsColour;
    float2 dsOffset;
}
struct SpanData {
    float2 translation;
    float2 offsetToAlignment;
    float rotation;
    float scale;
}
struct VertexOut {
    float4 position : SV_POSITION;
    float2 uv;
    nointerpolation float scale;
    nointerpolation float4 colour;
}
struct PushConstants {
    uint doShadow;               
}

[[vk::binding(0, 0)]] ConstantBuffer<UBO, ScalarDataLayout> ubo;
[[vk::binding(1, 0)]] Sampler2D sampler0; 
[[vk::binding(2, 0)]] StructuredBuffer<SpanData, ScalarDataLayout> spanData;

[[vk::push_constant]] ConstantBuffer<PushConstants> pc;

[shader("vertex")]
VertexOut vsmain(float2 objectPos, 
                 float2 uv, 
                 float4 colour,
                 uint span)
                 //uint vid : SV_VertexID) 
{
    let sd = spanData[span];
    let t = sd.translation;
    let r = sd.rotation;
    let s = sd.scale;

    // Translate to alignment
    matrix toAlignmentMatrix = {
        1, 0, 0, sd.offsetToAlignment.x,
        0, 1, 0, sd.offsetToAlignment.y,
        0, 0, 1, 0,
        0, 0, 0, 1
    };
    float4 p = mul(toAlignmentMatrix, float4(objectPos, 0, 1));

    // Rotate (optional) 
    if(r != 0) {
        matrix rotation = {
            cos(r), sin(r), 0, 0,
            -sin(r), cos(r), 0, 0,
            0,0,1,0,
            0,0,0,1
        };
        p = mul(rotation, p);
    }

    // Translate to world position and scale
    matrix translateAndScale = {
        s, 0, 0, t.x,
        0, s, 0, t.y,
        0, 0, 1, 0,
        0, 0, 0, 1
    };
    
    let worldPos  = mul(translateAndScale, p);  
    let screenPos = mul(ubo.viewProj, worldPos);

    return VertexOut(screenPos, uv, s, colour);
}

[shader("fragment")]
float4 fsmain(VertexOut input) : SV_TARGET {

    // Exit if colour is 0 (this character is not currently in use)
    if(all(input.colour == float4(0))) discard;

    float s = input.scale+3;
    float size = s*s*s*0.8;

    float4 colour;
    if(pc.doShadow != 0) {
        float2 offset   = ubo.dsOffset;
        float smoothing = (1.0 / (0.25*size)) * size/12;
        float distance  = sampler0.Sample(input.uv-offset).r;
        float4 col      = ubo.dsColour;
        float alpha     = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
        colour          = float4(col.rgb, col.a * alpha);
    } else {
        float smoothing = (1.0 / (0.25*size));
        float distance  = sampler0.Sample(input.uv).r;
        float alpha     = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
        colour          = float4(input.colour.rgb, input.colour.a * alpha);
    }

    return colour;
}
