#language slang 2026

// 
// Line renderer using task and mesh shaders.
// 

#define MESHLET_SIZE 32

struct UBO {
    float4x4 viewProj;
    uint numMeshlets;
};

struct Meshlet {
    uint numLines;
    uint lineDataOffset;
};

struct LineInput {
    float2 from;
    float2 to;
    float4 fromColour;
    float4 toColour;
    float fromThickness;
    float toThickness;
};

[[vk::binding(0, 0)]] ConstantBuffer<UBO> ubo;
[[vk::binding(1, 0)]] StructuredBuffer<Meshlet, ScalarDataLayout> meshlets;
[[vk::binding(2, 0)]] StructuredBuffer<LineInput, ScalarDataLayout> lineData;

struct VertexOutput {
    float4 position : SV_POSITION;
    float4 colour;
    float2 pos;
    nointerpolation float2 from;               
    nointerpolation float2 to;                 
    nointerpolation float halfFromThickness;   
    nointerpolation float halfToThickness;  
};

// We don't use the payload but it is required
struct MeshletPayLoad {
    uint nothing;
};
groupshared MeshletPayLoad mashletPayLoad;

// A single task shader group with 1 thread will be dispatched by the app. We don't do any culling
// so we will just dispatch 1 mesh group per meshlet here.
[shader("task")]
[numthreads(1, 1, 1)]
void taskmain() {
    // Dispatch a mesh shader group for each meshlet
    DispatchMesh(ubo.numMeshlets, 1, 1, mashletPayLoad);
}

/** 
 * Process a meshlet of up to MESHLET_SIZE lines.
 * 
 * Each thread will generate 1 line => 2 triangles and 4 vertices.
 */
[shader("mesh")]
[outputtopology("triangle")]
[numthreads(MESHLET_SIZE, 1, 1)]
void meshmain(out indices uint3 triangles[MESHLET_SIZE*2],          // each line has 2 triangles 
              out vertices VertexOutput vertices[MESHLET_SIZE*4],   // each line has 4 vertices 
              uint groupId  : SV_GroupID,                           // the meshlet index
              uint threadId : SV_GroupIndex)                        // the thread index within the group (0..MESHLET_SIZE-1)
{   

    Meshlet m = meshlets[groupId];

    // Set the number of vertices and triangles for this group
    SetMeshOutputCounts(m.numLines*4, m.numLines*2);

    // Skip if this meshlet does not have a line for this thread
    if(threadId >= m.numLines) {
        return;
    }

    uint i = m.lineDataOffset + threadId;
    uint t = threadId * 2;
    uint v = threadId * 4;

    float2 pos0    = lineData[i].from;
    float2 pos1    = lineData[i].to;
    float2 forward = normalize(pos1 - pos0);

    // stretch the line to account for thickness
    pos0 -= forward * lineData[i].fromThickness * 0.5;
    pos1 += forward * lineData[i].toThickness * 0.5;

    float2 right   = float2(-forward.y, forward.x);
    float2 offset0 = (float2(lineData[i].fromThickness) / 2) * right;
    float2 offset1 = (float2(lineData[i].toThickness) / 2) * right;

    // 0---1
    // |\  |
    // | \ |
    // |  \|
    // 3---2

    // Generate 2 triangles
    triangles[t]   = uint3(v, v+1, v+2);    // 0,1,2
    triangles[t+1] = uint3(v, v+2, v+3);    // 0,2,3

    // Generate 4 vertices
    vertices[v] = VertexOutput(
        mul(ubo.viewProj, float4(pos0 + offset0, 0, 1)),
        lineData[i].fromColour,
        pos0 + offset0,
        lineData[i].from,
        lineData[i].to,
        lineData[i].fromThickness * 0.5,
        lineData[i].toThickness * 0.5
    );
    vertices[v+1] = VertexOutput(
        mul(ubo.viewProj, float4(pos0 - offset0, 0, 1)),
        lineData[i].fromColour,
        pos0 - offset0,
        lineData[i].from,
        lineData[i].to,
        lineData[i].fromThickness * 0.5,
        lineData[i].toThickness * 0.5
    );
    vertices[v+2] = VertexOutput(
        mul(ubo.viewProj, float4(pos1 + offset1, 0, 1)),
        lineData[i].toColour,
        pos1 + offset1,
        lineData[i].from,
        lineData[i].to,
        lineData[i].fromThickness * 0.5,
        lineData[i].toThickness * 0.5
    );
    vertices[v+3] = VertexOutput(
        mul(ubo.viewProj, float4(pos1 - offset1, 0, 1)),
        lineData[i].toColour,
        pos1 - offset1,
        lineData[i].from,
        lineData[i].to,
        lineData[i].fromThickness * 0.5,
        lineData[i].toThickness * 0.5
    );
}

[shader("fragment")]
float4 fsmain(VertexOutput input) : SV_TARGET {
    float2 up = normalize(input.from - input.to);

    if(dot(up, normalize(input.pos - input.from)) > 0) {
        if(distance(input.pos, input.from) > input.halfFromThickness) {
            discard;
        }
    }
    if(dot(up, normalize(input.pos - input.to)) < 0) {
        if(distance(input.pos, input.to) > input.halfToThickness) {
            discard;
        }
    }

    return input.colour;
}
