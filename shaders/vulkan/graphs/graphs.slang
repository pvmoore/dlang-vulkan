#language slang 2026
[require(GL_EXT_debug_printf)]

struct VertexOut {
    float4 clipspacePos : SV_POSITION;
    float2 pos;
};

struct UBO {
    matrix model;
    matrix viewProj;
    uint selector;
};

[[vk::binding(0, 0)]] ConstantBuffer<UBO, ScalarDataLayout> ubo;

[shader("vertex")]
VertexOut vsmain(float2 worldPos) {

    let pos      = float4(worldPos, 0, 1);
    let pos2     = mul(ubo.model, pos);
    let clipPos  = mul(ubo.viewProj, pos2);

    return VertexOut(clipPos, worldPos);
}

[shader("fragment")]
float4 fsmain(VertexOut v) : SV_TARGET {

    // v.pos goes from (0,0) to (1,1) from top left to bottom right

    float x = v.pos.x;
    float y = 1 - v.pos.y;

    //  1
    //  |
    // y|
    //  |
    //  0------1
    //      x

    float f = func(x);

    if(f >= y) {
        return float4(1,1,1,1);
    }

    return float4(0.2,0.2,0.2,1);
}

float func(float x) {
    switch(ubo.selector) {
        case 1: return x*x;
        case 2: return x*x*x;
        case 3: return x*x*x*x;
        case 4: return 1-x;
        case 5: return 1-x*x;
        case 6: return 1-x*x*x;
        case 7: return (1-x)*(1-x);
        case 8: return 1 - (1-x)*(1-x);
        case 9: return 1 - (1-x)*(1-x)*(1-x);
        default: return x;
    }
}
