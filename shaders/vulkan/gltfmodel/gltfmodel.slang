#language slang 2026

[require(GL_EXT_debug_printf)]

struct UBO {
    float4x4 viewInverse;
    float4x4 projInverse;
    float3 lightPos;
}
struct [raypayload] RayPayload {
    float3 colour : read(caller) : write(caller, closesthit, miss);
};

struct Triangle {
    float3 normal;
    float3 colour;
}
struct Vertex {
    float3 pos;
    float3 normal;
    float3 colour;
    float2 uv;
}
struct Geometry {
    uint triangleOffset;    // index into triangles[] (*3 for indices[])
    uint vertexOffset;      // index into vertices[]
    uint textureOffset;     // index into samplers[]
    uint numTextures;
}

[[vk::binding(0, 0)]] RaytracingAccelerationStructure tlas;
[[vk::binding(1, 0)]] [format("rgba8")] RWTexture2D<float4> image;
[[vk::binding(2, 0)]] ConstantBuffer<UBO, ScalarDataLayout> ubo;
[[vk::binding(3, 0)]] StructuredBuffer<Triangle, ScalarDataLayout> triangles; // currently unused
[[vk::binding(4, 0)]] StructuredBuffer<Vertex, ScalarDataLayout> vertices; 
[[vk::binding(5, 0)]] StructuredBuffer<uint, ScalarDataLayout> indices; 
[[vk::binding(6, 0)]] StructuredBuffer<Geometry, ScalarDataLayout> geometries;
[[vk::binding(7, 0)]] [format("rgba8")] Sampler2D<float4> samplers[]; // combined texture and sampler

[shader("raygeneration")]
void raygen() {
    uint2 launchID   = DispatchRaysIndex().xy;
    uint3 launchSize = DispatchRaysDimensions();

    float2 pixelCenter = float2(launchID) + float2(0.5);
	float2 inUV        = pixelCenter/float2(launchSize.xy);
	float2 d           = inUV * 2.0 - 1.0;
    
    float4 origin    = mul(ubo.viewInverse, float4(0,0,0,1));
	float4 target    = mul(ubo.projInverse, float4(d.x, d.y, 1, 1));
	float4 direction = mul(ubo.viewInverse, float4(normalize(target.xyz), 0));

    RayDesc ray;
    ray.Direction = direction.xyz;
    ray.Origin    = origin.xyz;
    ray.TMin      = 0.001f;
    ray.TMax      = 10000.0f;

    RayPayload payload = {};

    TraceRay(tlas, RAY_FLAG_FORCE_OPAQUE, 0xff, 0, 0, 0, ray, payload);

    image[launchID] = float4(payload.colour, 1);
}

[shader("closesthit")]
void closesthit(inout RayPayload p, in BuiltInTriangleIntersectionAttributes attribs) {

    // InstanceID contains the index into the geometries array (per instance)
    let geometry = geometries[InstanceID() + GeometryIndex()];

    let triangleOffset = geometry.triangleOffset + PrimitiveIndex();
    let vertexBase     = geometry.vertexOffset;

    let triangle = triangles[triangleOffset];

    let indicesIndex = triangleOffset * 3;

    let i0 = indices[indicesIndex]   + vertexBase;
    let i1 = indices[indicesIndex+1] + vertexBase;
    let i2 = indices[indicesIndex+2] + vertexBase;

    let v0 = vertices[i0];
    let v1 = vertices[i1];
    let v2 = vertices[i2];

    let worldPos = WorldRayOrigin() + WorldRayDirection() * RayTCurrent();

    // Per vertex 
    let bary = float3(1.0f - attribs.barycentrics.x - attribs.barycentrics.y, attribs.barycentrics.x, attribs.barycentrics.y);
    let worldNormal = normalize(v0.normal * bary.x + v1.normal * bary.y + v2.normal * bary.z);
    let uv = v0.uv * bary.x + v1.uv * bary.y + v2.uv * bary.z;
    
    var colour = v0.colour * bary.x + v1.colour * bary.y + v2.colour * bary.z;

    for(uint i = 0; i < geometry.numTextures; i++) {
        colour *= samplers[geometry.textureOffset + i].Sample(uv).rgb;
    }

    // Per triangle 
    //float3 worldNormal = tri.normal;
    //colour = tri.colour;

    // Basic lighting
    let toLight = normalize(ubo.lightPos-worldPos);
    let ndotl   = max(dot(toLight, worldNormal), 0);

    p.colour = colour * ndotl; 
}

[shader("miss")]
void miss(inout RayPayload p) {
    p.colour = float3(0.1, 0.2, 0.0);
}
