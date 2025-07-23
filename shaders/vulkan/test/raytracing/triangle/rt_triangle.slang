
struct UBO {
    float4x4 viewInverse;
    float4x4 projInverse;
};
struct [raypayload] RayPayload {
    float4 colour : read(caller) : write(caller, closesthit, miss);
};

[[vk::binding(0, 0)]] RaytracingAccelerationStructure tlas;
[[vk::binding(1, 0)]] [format("rgba8")] RWTexture2D<float4> image;
[[vk::binding(2, 0)]] ConstantBuffer<UBO> ubo;


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

    RayPayload payload = { float4(0, 0, 0, 0) };

    TraceRay(tlas, RAY_FLAG_FORCE_OPAQUE, 0xff, 0, 0, 0, ray, payload);

    image[launchID] = payload.colour;
}

[shader("closesthit")]
void closesthit(inout RayPayload p, in BuiltInTriangleIntersectionAttributes attribs) {
    float3 barycentricCoords = float3(1.0f - attribs.barycentrics.x - attribs.barycentrics.y, attribs.barycentrics.x, attribs.barycentrics.y);
    p.colour = float4(barycentricCoords, 1);
}

[shader("miss")]
void miss(inout RayPayload p) {
    p.colour = float4(0.1, 0.1, 0.0, 1);
}
