
struct UBO {
    float4x4 viewInverse;
    float4x4 projInverse;
    float3 lightPos;
    uint option;
};
struct Sphere {
    float3 center;
    float radius;
    float4 colour;

    float intersect(float3 ro, float3 rd) {
        float3 oc = ro - center;
        float b = dot(oc, rd);
        float c = dot(oc, oc) - radius * radius;
        float h = b * b - c;
        if (h < 0.0) {
            return -1.0;
        }
        h = sqrt(h);
        return -b - h;
    }
};
struct [raypayload] RayPayload {
    float4 colour : read(caller) : write(caller, closesthit, miss);
};

[[vk::binding(0, 0)]] RaytracingAccelerationStructure tlas;
[[vk::binding(1, 0)]] [format("rgba8")] RWTexture2D<float4> image;
[[vk::binding(2, 0)]] ConstantBuffer<UBO> ubo;
[[vk::binding(3, 0)]] StructuredBuffer<Sphere> spheres;

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
    ray.Origin    = origin.xyz;
    ray.Direction = direction.xyz;
    ray.TMin      = 0.001f;
    ray.TMax      = 10000.0f;

    RayPayload payload = { float4(0, 0, 0, 0) };

    TraceRay(tlas, RAY_FLAG_FORCE_OPAQUE, 0xff, 0, 0, 0, ray, payload);

    image[launchID] = payload.colour;
}

[shader("closesthit")]
void closesthit(inout RayPayload p) {
    // * Option 1 : Multiple primitives, single instance
    // * Option 2 : Single primitive, multiple instances

    const uint id = ubo.option == 1 ? PrimitiveIndex() : InstanceIndex();
    Sphere sphere = spheres[id];

    float3 worldPos    = WorldRayOrigin() + WorldRayDirection() * RayTCurrent();
    float3 worldNormal = normalize(worldPos - sphere.center);

    // Basic lighting
    float3 lightVector = normalize(ubo.lightPos);
    float dotProduct = max(dot(lightVector, worldNormal), 0.2);

    p.colour = float4(sphere.colour.rgb * dotProduct, 1);
}

[shader("miss")]
void miss(inout RayPayload p) {
    p.colour = float4(0.1, 0.1, 0.0, 1);
}

[shader("intersection")]
void intersection() {
    // * Option 1 : Multiple primitives, single instance
    // * Option 2 : Single primitive, multiple instances
    const uint id = ubo.option == 1 ? PrimitiveIndex() : InstanceIndex();
    Sphere sphere = spheres[id];

    float t = sphere.intersect(WorldRayOrigin(), WorldRayDirection());

    if (t > 0) {
        ReportHit(t, 0, 0);
    }
}
