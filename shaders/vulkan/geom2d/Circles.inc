

struct VS_OUT {
   vec2 pos;
   vec4 fillColour;
   vec4 edgeColour;
   float radius;
   float edgeThickness;
};

struct GS_OUT {
    vec2 pos;
    vec4 fillColour;
    vec4 edgeColour;
    float radius;
    float edgeThickness;
};
