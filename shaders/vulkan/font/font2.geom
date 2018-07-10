#version 430 core
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

// inputs
layout(location = 0) in vec4 in_posdim[];
layout(location = 1) in vec4 in_uvs[];
layout(location = 2) in vec4 in_colour[];
layout(location = 3) in float in_size[];

// outputs
layout(location = 0) out vec2 out_uvs;
layout(location = 1) out vec4 out_colour;
layout(location = 2) out float out_size;

// bindings
layout(binding = 0, std140) uniform UBO {
    mat4 viewProj;
    vec4 dsColour;
    vec2 dsOffset;  // 16 bytes
} ubo;

mat4 getTranslationMatrix() {
    mat4 m = mat4(1);
    m[3][0] = in_posdim[0].x;
    m[3][1] = in_posdim[0].y;
    return m;
}
mat4 getModelMatrix() {
    return getTranslationMatrix();
}

void main() {
    float w = in_posdim[0].z;
    float h = in_posdim[0].w;

    vec4 v0 = vec4(0, 0, 0, 1);
    vec4 v1 = vec4(0, h, 0, 1);
    vec4 v2 = vec4(w, h, 0, 1);
    vec4 v3 = vec4(w, 0, 0, 1);

    mat4 MVP = ubo.viewProj * getModelMatrix();
    vec4 v0_transformed = MVP * v0;
    vec4 v1_transformed = MVP * v1;
    vec4 v2_transformed = MVP * v2;
    vec4 v3_transformed = MVP * v3;

    gl_Position = v0_transformed;
    out_uvs     = in_uvs[0].xy; //xy
    out_colour  = in_colour[0];
    out_size    = in_size[0];
    EmitVertex();

    gl_Position = v1_transformed;
    out_uvs     = in_uvs[0].xw; // xw
    out_colour  = in_colour[0];
    out_size    = in_size[0];
    EmitVertex();

    gl_Position = v3_transformed;
    out_uvs     = in_uvs[0].zy; // zy
    out_colour  = in_colour[0];
    out_size    = in_size[0];
    EmitVertex();

    gl_Position = v2_transformed;
    out_uvs     = in_uvs[0].zw; // zw
    out_colour  = in_colour[0];
    out_size    = in_size[0];
    EmitVertex();

    EndPrimitive();
}