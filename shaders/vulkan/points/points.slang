#language slang 2026

struct PointOut {
    float2 pos;
    float size;
    float enabled;
    float4 colour;
};
struct TriangleVertex {
    float4 position : SV_POSITION;
    float2 pos;
    nointerpolation float4 colour;
    nointerpolation float size;
};
struct UBO {
    matrix viewProj;
};

[[vk::binding(0, 0)]] ConstantBuffer<UBO> ubo;


[shader("vertex")]
PointOut vsmain(float2 pos, 
                float size, 
                float enabled, 
                float4 colour) 
{
    return PointOut(pos, size, enabled, colour);
}

[shader("geometry")]
[maxvertexcount(4)]
void gsmain(point PointOut input[1], inout TriangleStream<TriangleVertex> outStream) {
    if(input[0].enabled == 1) {
        float2 pp = input[0].pos;
        float r	  = input[0].size;

        // Generate a triangle strip of 2 triangles (4 vertices)

        // 0---3
        // |  /|
        // | C |  C = centre
        // |/  |
        // 1---2

        float4 pos0    = float4(pp-r, 0, 1);
        float4 pos2    = float4(pp+r, 0, 1);
        float4 pos1    = float4(pp.x-r, pp.y+r, 0, 1);
        float4 pos3    = float4(pp.x+r, pp.y-r, 0, 1);

        outStream.Append(TriangleVertex(
            mul(ubo.viewProj, pos0),
            pos0.xy-pp, 
            input[0].colour, 
            input[0].size
        ));
        outStream.Append(TriangleVertex(
            mul(ubo.viewProj, pos1),
            pos1.xy-pp, 
            input[0].colour, 
            input[0].size
        ));
        outStream.Append(TriangleVertex(
            mul(ubo.viewProj, pos3),
            pos3.xy-pp, 
            input[0].colour, 
            input[0].size
        ));
        outStream.Append(TriangleVertex(
            mul(ubo.viewProj, pos2),
            pos2.xy-pp, 
            input[0].colour, 
            input[0].size
        ));
        outStream.RestartStrip();
    }
}

[shader("fragment")]
float4 fsmain(TriangleVertex fs_in) : SV_TARGET {
    float dist = length(fs_in.pos);

    if(dist > fs_in.size) discard;

    float f = 1 - (dist / fs_in.size);

    return float4(fs_in.colour.rgb, fs_in.colour.a * f);
}
