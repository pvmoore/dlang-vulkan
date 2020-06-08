#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

// input
layout(location = 0) in vec3 inPosition;

// output
layout(location = 0) out vec3 outUvs;

// bindings
layout(set = 0, binding = 0, std140) uniform UBO {
    mat4 view;
    mat4 proj;
} ubo;

mat4 translatedToOrigin(mat4 m) {
    mat4 m2 = m;
    m2[3].x = 0;
    m2[3].y = 0;
    m2[3].z = 0;
    return m2;
}

void main() {
    mat4 view   = translatedToOrigin(ubo.view);
    gl_Position	= ubo.proj * view * vec4(inPosition, 1);
    outUvs      = inPosition;
}