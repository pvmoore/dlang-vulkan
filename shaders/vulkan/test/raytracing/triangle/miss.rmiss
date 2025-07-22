#version 460 core
#extension GL_EXT_ray_tracing : require
#extension GL_GOOGLE_include_directive : require

layout(location = 0) rayPayloadInEXT vec3 ResultColor;

void main() {
    ResultColor = vec3(0.1f, 0.1f, 0.0f);
}
