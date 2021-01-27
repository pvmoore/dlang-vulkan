
struct VS_OUT {
    vec2 pos;
    vec2 size;
    vec4 uv;
    vec4 colour;
    float rotation;
    float enabled;
};

struct GS_OUT {
    vec2 uv;
    vec4 colour;
    float enabled;
};
