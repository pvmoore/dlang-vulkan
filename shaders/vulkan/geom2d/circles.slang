#language slang 2026

struct PointVertexOut {
   float2 pos;
   float4 fillColour;
   float4 edgeColour;
   float radius;
   float edgeThickness;
};
struct TriangleVertexOut {
    float4 position : SV_POSITION;
    float2 pos;
    float4 fillColour;
    float4 edgeColour;
    float radius;
    float edgeThickness;
};
struct UBO {
    matrix viewProj;
};

[[vk::binding(0, 0)]] ConstantBuffer<UBO> ubo;

[shader("vertex")]
PointVertexOut vsmain(float4 posRadiusBorderRadius,  // xy, radius, borderRadius
                      float4 fillColour, 
                      float4 edgeColour) 
{
    return PointVertexOut(posRadiusBorderRadius.xy, fillColour, edgeColour, posRadiusBorderRadius.z, posRadiusBorderRadius.w);
}

[shader("geometry")]
[maxvertexcount(4)]
void gsmain(point PointVertexOut input[1], inout TriangleStream<TriangleVertexOut> outStream) {
    float2 centre = input[0].pos;
    float r		  = input[0].radius + (input[0].edgeThickness*0.5);

    // Generate a triangle strip of 2 triangles (4 vertices)

    // 0---3
    // |  /|
    // | C |  C = centre
    // |/  |
    // 1---2

    float4 pos0 = float4(centre-r, 0, 1);
    float4 pos2 = float4(centre+r, 0, 1);
    float4 pos1 = float4(centre.x-r, centre.y+r, 0, 1);
    float4 pos3 = float4(centre.x+r, centre.y-r, 0, 1);

    outStream.Append(TriangleVertexOut(
        mul(ubo.viewProj, pos0),
        pos0.xy-centre, 
        input[0].fillColour, 
        input[0].edgeColour, 
        input[0].radius, 
        input[0].edgeThickness
    ));
    outStream.Append(TriangleVertexOut(
        mul(ubo.viewProj, pos1),
        pos1.xy-centre, 
        input[0].fillColour, 
        input[0].edgeColour, 
        input[0].radius, 
        input[0].edgeThickness
    ));
    outStream.Append(TriangleVertexOut(
        mul(ubo.viewProj, pos3),
        pos3.xy-centre, 
        input[0].fillColour, 
        input[0].edgeColour, 
        input[0].radius, 
        input[0].edgeThickness
    ));
    outStream.Append(TriangleVertexOut(
        mul(ubo.viewProj, pos2),
        pos2.xy-centre, 
        input[0].fillColour, 
        input[0].edgeColour, 
        input[0].radius, 
        input[0].edgeThickness
    ));
    outStream.RestartStrip();
}

[shader("fragment")]
float4 fsmain(TriangleVertexOut fs_in) : SV_TARGET {

    // The distance from the center of the circle 
    float dist = length(fs_in.pos);

    float f = clamp(fs_in.radius - dist, 0, 1);

    float a = abs(dist - fs_in.radius) / (fs_in.edgeThickness*0.5);
    float p = pow(a, max(5, fs_in.edgeThickness*20));
    float e = clamp(1 - p, 0, 1);

    float4 fill = lerp(float4(0), fs_in.fillColour, f);
    float4 edge = lerp(float4(0), fs_in.edgeColour, e);

    return lerp(fill, edge, e);
}
