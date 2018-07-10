#version 430
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

// inputs
layout(location = 0) in vec2 in_uvs;
layout(location = 1) in vec4 in_colour;
layout(location = 2) in float in_size;

// outputs
layout(location = 0) out vec4 color;

// bindings
layout(binding = 0, std140) uniform UBO {
    mat4 viewProj;
    vec4 dsColour;
    vec2 dsOffset;
} ubo;
layout(binding = 1) uniform sampler2D SAMPLER;

// push constants
layout(std140, push_constant) uniform PC {
	bool doShadow;  // 4 bytes
} pc;

void main() {
    if(pc.doShadow) {
        vec2 offset     = ubo.dsOffset;
        float smoothing = (1.0 / (0.25*in_size)) * in_size/12;
        float distance  = texture(SAMPLER, in_uvs-offset).r;
        vec4 col        = ubo.dsColour;
        float alpha     = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
        color           = vec4(col.rgb, col.a * alpha);
    } else {
        float smoothing = (1.0 / (0.25*in_size));
        float distance  = texture(SAMPLER, in_uvs).r;
        float alpha     = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
        color           = vec4(in_colour.rgb, in_colour.a * alpha);
    }
}
