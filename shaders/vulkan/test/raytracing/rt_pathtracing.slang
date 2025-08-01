
[require(GL_EXT_debug_printf)]

import common;

struct UBO {
    float4x4 viewInverse;
    float4x4 projInverse;
    float3 lightPos;
};

struct [raypayload] RayPayload {
    float3 colour      : read(caller) : write(caller, closesthit);
    float distance     : read(caller) : write(caller, closesthit);
    float3 normal      : read(caller) : write(caller, closesthit);
    bool hit           : read(caller) : write(caller, closesthit, miss);
    uint materialIndex : read(caller) : write(caller, closesthit);
};

[[vk::push_constant]] ConstantBuffer<PushConstants> pc;

struct PushConstants {
    uint frameNumber;               // 0..n
    uint imageIteration;            // 1..n
};

struct Material {
    bool specular;
    bool refractive;
    float emission;
}

static const Material materials[] = {
    { false, false, 0 }, // cube
    { false, false, 30}, // light cube 
    { true, false, 0 },  // sphere 0
    { false, true, 0 },  // sphere 1
    { false, false, 0 }, // sphere 2
};

[[vk::binding(0, 0)]] RaytracingAccelerationStructure tlas;
[[vk::binding(1, 0)]] [format("rgba8")] RWTexture2D<float4> image;
[[vk::binding(2, 0)]] ConstantBuffer<UBO, ScalarDataLayout> ubo; 
[[vk::binding(3, 0)]] StructuredBuffer<Cube, ScalarDataLayout> cubes; 
[[vk::binding(4, 0)]] StructuredBuffer<Sphere, ScalarDataLayout> spheres; 
[[vk::binding(5, 0)]] RWStructuredBuffer<float3, ScalarDataLayout> accumulatedColours;

[shader("raygeneration")]
void raygen() {
    uint2 launchID   = DispatchRaysIndex().xy;
    uint3 launchSize = DispatchRaysDimensions();
    uint index       = launchID.y * launchSize.x + launchID.x;

    uint seed = pc.frameNumber * launchSize.x * launchSize.y + index * pc.imageIteration;

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

    float3 colour      = float3(0);
    float3 reflectance = float3(1);

    let maxBounces = 6;
    RayPayload payload;

    for(int i = 0; i <= maxBounces; i++) {

        seed++;

        TraceRay(tlas, RAY_FLAG_FORCE_OPAQUE, 0xff, 0, 0, 0, ray, payload);

        // If we didn't hit anything, we can exit 
        if(!payload.hit) break;

        // We hit something
        Material mat    = materials[payload.materialIndex];
        float3 emission = float3(mat.emission);
        float3 diffuse  = payload.colour;

        float maxReflectance = vmax(diffuse);

        if(random01(seed) >= maxReflectance) {
            break;
        }

        colour += reflectance * emission;

        float3 f = diffuse / maxReflectance;
        reflectance *= f;

        float3 hitPos = ray.Origin + ray.Direction * payload.distance;
        ray.Origin    = hitPos + payload.normal * 0.001f;

        // properly oriented surface normal
        float reflectAngle = dot(payload.normal, ray.Direction);
        float3 nl          = reflectAngle<0 ? payload.normal : payload.normal*-1;
        float3 direction;

        ray.TMin = 0.001f;

        if(mat.specular) {
            // specular reflection
            direction = ray.Direction - payload.normal*2*reflectAngle;
        } else if(mat.refractive) {
            // refractive reflection

            // Ray from outside going in?
            bool into = dot(payload.normal, nl) > 0;

            // refractive index
            float fromRI = 1;   // air
            float toRI   = 1.5; // glass
            float nnt    = into ? fromRI/toRI : toRI/fromRI;
            float ddn    = dot(ray.Direction, nl);
            float cos2t  = 1-nnt*nnt*(1-ddn*ddn);

            // cos2t < 0 is Total internal reflection
            if(cos2t >= 0) {
                // Choose reflection or refraction
                float3 tdir = normalize(ray.Direction*nnt - payload.normal*((into?1:-1)*(ddn*nnt+sqrt(cos2t))));
                float a   = toRI-fromRI;
                float b   = toRI+fromRI;
                float R0  = (a*a)/(b*b);
                float c   = 1.0-(into ? -ddn : dot(tdir, payload.normal));
                float Re  = R0+(1.0-R0)*c*c*c*c*c;
                float Tr  = 1.0-Re;

                float P = 0.25 + 0.5*Re;

                // Choose reflect or refract
                bool reflect = random01(seed) < P;

                reflectance *= reflect ? Re/P : Tr/(1.0-P);
                direction    = reflect ? direction : tdir;

                ray.TMin = 0.01f;
            }
        } else {
            // diffuse reflection
            float r1  = 2*PI*random01(seed);
            float r2  = random01(seed);
            float r2s = sqrt(r2);
            float3 w  = nl;
            float3 u  = normalize(cross(abs(w.x)>0.1 ? float3(0,1,0) : float3(1,0,0), w));
            float3 v  = cross(w, u);

            direction = u*cos(r1)*r2s +
                        v*sin(r1)*r2s +
                        w*sqrt(1-r2);
        }

        ray.Direction = direction;
    }

    float3 currentColour;

    // Set the accumulated colour, reset if this is the first iteration
    if(pc.imageIteration == 1) {
        accumulatedColours[index] = colour;
        currentColour = colour;
    } else {
        accumulatedColours[index] += colour;
        currentColour = accumulatedColours[index] / pc.imageIteration;
    }

    currentColour = gamma(currentColour);

    image[launchID] = float4(currentColour, 1);
}

static const float3 normals[6] = {
    float3(0, 1, 0),  // top
    float3(0,-1, 0),  // bottom
    float3(0, 0, 1),  // front
    float3(0, 0,-1),  // back
    float3(-1, 0, 0), // left
    float3(1, 0, 0)   // right
};

[shader("closesthit")]
void closesthitCube(inout RayPayload p, in BuiltInTriangleIntersectionAttributes attribs) {
    // If we get here we hit a Cube (hit group 0)
    // Get the instance id from the instance.instanceCustomIndex
    Cube cube = cubes[InstanceID()];

    // Calculate the cube side
    uint normalIndex = (PrimitiveIndex() / 2) % 6;

    float3 worldPos = WorldRayOrigin() + WorldRayDirection() * RayTCurrent();
    float3 worldNormal = normals[normalIndex];

    p.hit           = true;
    p.normal        = worldNormal;
    p.distance      = RayTCurrent();
    p.colour        = cube.colour;
    p.materialIndex = InstanceID() == 7 ? 1 : 0;
}

[shader("closesthit")]
void closesthitSphere(inout RayPayload p) {
    // If we get here we hit a Sphere (hit group 1)
    // Get the instance id from the instance.instanceCustomIndex
    Sphere sphere = spheres[InstanceID()];

    float3 worldPos = WorldRayOrigin() + WorldRayDirection() * RayTCurrent();
    float3 worldNormal = normalize(worldPos - sphere.center);

    p.hit           = true;
    p.normal        = worldNormal;
    p.distance      = RayTCurrent();
    p.colour        = sphere.colour;
    p.materialIndex = InstanceID() + 2;
}

[shader("intersection")]
void intersection() {
    // If we get here this instance must be an AABB of a Sphere
    // Get the instance id from the instance.instanceCustomIndex
    Sphere sphere = spheres[InstanceID()];

    float t = sphere.intersect(WorldRayOrigin(), WorldRayDirection());

    if(t > 0) {
        ReportHit(t, 0, 0);
    }
}

[shader("miss")]
void miss(inout RayPayload p) {
    p.hit = false;
}
