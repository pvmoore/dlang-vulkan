
struct VS_OUT {
    vec2 pos;
    float size;
    float enabled;
    vec4 colour;
};

struct GS_OUT {
    vec2 pos;
    vec4 colour;
    float size;
};