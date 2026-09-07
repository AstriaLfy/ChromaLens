#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

// Uniforms set by Flutter engine and application
uniform vec2 u_size;

// 3x3 Daltonization Matrix D
uniform float u_m00;
uniform float u_m01;
uniform float u_m02;
uniform float u_m10;
uniform float u_m11;
uniform float u_m12;
uniform float u_m20;
uniform float u_m21;
uniform float u_m22;

// Filter severity intensity (0.0 = Natural/Identity, 1.0 = Full Assist)
uniform float u_intensity;

// Input camera texture sampler
uniform sampler2D u_texture_input;

// Output fragment color
out vec4 frag_color;

// Decodes sRGB color channel to linear RGB
float srgb_to_linear(float c) {
    return (c <= 0.04045) ? (c / 12.92) : pow((c + 0.055) / 1.055, 2.4);
}

vec3 srgb_to_linear(vec3 rgb) {
    return vec3(
        srgb_to_linear(rgb.r),
        srgb_to_linear(rgb.g),
        srgb_to_linear(rgb.b)
    );
}

// Encodes linear color channel to sRGB
float linear_to_srgb(float c) {
    if (c <= 0.0) {
        return 0.0;
    }
    return (c <= 0.0031308) ? (12.92 * c) : (1.055 * pow(c, 1.0 / 2.4) - 0.055);
}

vec3 linear_to_srgb(vec3 rgb) {
    return vec3(
        linear_to_srgb(rgb.r),
        linear_to_srgb(rgb.g),
        linear_to_srgb(rgb.b)
    );
}

void main() {
    vec2 uv = FlutterFragCoord().xy / u_size;
    vec4 color = texture(u_texture_input, uv);

    // 1. Decode gamma-encoded sRGB from camera to linear space
    vec3 linear_rgb = srgb_to_linear(color.rgb);

    // 2. Apply 3x3 linear Daltonization matrix
    vec3 daltonized = vec3(
        u_m00 * linear_rgb.r + u_m01 * linear_rgb.g + u_m02 * linear_rgb.b,
        u_m10 * linear_rgb.r + u_m11 * linear_rgb.g + u_m12 * linear_rgb.b,
        u_m20 * linear_rgb.r + u_m21 * linear_rgb.g + u_m22 * linear_rgb.b
    );

    // 3. Interpolate with linear original based on severity intensity
    vec3 blended_linear = mix(linear_rgb, daltonized, clamp(u_intensity, 0.0, 1.0));

    // 4. Encode back to sRGB
    vec3 srgb_out = linear_to_srgb(blended_linear);

    // 5. Clamp strictly to [0.0, 1.0] to prevent chromatic overflow
    vec3 clamped_out = clamp(srgb_out, 0.0, 1.0);

    frag_color = vec4(clamped_out, color.a);
}
