#version 450 core
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive     : require

// inputs
layout(location = 0) in vec4 colour;
layout(location = 1) in vec2 pos;
layout(location = 2) in flat vec2 from;
layout(location = 3) in flat vec2 to;
layout(location = 4) in flat float halfFromThickness;
layout(location = 5) in flat float halfToThickness;

// outputs
layout(location = 0) out vec4 color;


void main() {

    vec2 up = normalize(from - to);

    if(dot(up, normalize(pos - from)) > 0) {
        if(distance(pos, from) > halfFromThickness) {
            discard;
        }
    }
    if(dot(up, normalize(pos - to)) < 0) {
        if(distance(pos, to) > halfToThickness) {
            discard;
        }
    }

    color = colour;
}