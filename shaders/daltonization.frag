#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

// ── Uniforms ─────────────────────────────────────────────────────────────

uniform vec2 u_size;

// 3x3 Daltonization Matrix D (for matrix-type filters)
uniform float u_m00, u_m01, u_m02;
uniform float u_m10, u_m11, u_m12;
uniform float u_m20, u_m21, u_m22;

// Filter severity intensity (0.0 = identity, 1.0 = full effect)
uniform float u_intensity;

// Filter type: 0.0 = normal, 1.0 = matrix, 2.0 = achromat (full), 3.0 = achromat (partial)
uniform float u_type;

// Grayscale blend ratio for partial achromatopsia (0.0–1.0)
uniform float u_achromat_blend;

// Input camera texture sampler
uniform sampler2D u_texture_input;

// Output fragment color
out vec4 frag_color;

// ── sRGB ↔ Linear conversion ────────────────────────────────────────────

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

float linear_to_srgb(float c) {
    if (c <= 0.0) return 0.0;
    return (c <= 0.0031308) ? (12.92 * c) : (1.055 * pow(c, 1.0 / 2.4) - 0.055);
}

vec3 linear_to_srgb(vec3 rgb) {
    return vec3(
        linear_to_srgb(rgb.r),
        linear_to_srgb(rgb.g),
        linear_to_srgb(rgb.b)
    );
}

// ── Main pipeline ────────────────────────────────────────────────────────

void main() {
    vec2 uv = FlutterFragCoord().xy / u_size;
    vec4 color = texture(u_texture_input, uv);

    // Pass-through for normal mode
    if (u_type < 0.5) {
        frag_color = color;
        return;
    }

    float intensity = clamp(u_intensity, 0.0, 1.0);

    // 1. Decode sRGB → linear
    vec3 linear_rgb = srgb_to_linear(color.rgb);

    vec3 processed;

    if (u_type < 1.5) {
        // u_type == 1.0: Matrix-based filter (protanomaly, protanopia, deuteranomaly, etc.)
        vec3 daltonized = vec3(
            u_m00 * linear_rgb.r + u_m01 * linear_rgb.g + u_m02 * linear_rgb.b,
            u_m10 * linear_rgb.r + u_m11 * linear_rgb.g + u_m12 * linear_rgb.b,
            u_m20 * linear_rgb.r + u_m21 * linear_rgb.g + u_m22 * linear_rgb.b
        );
        processed = mix(linear_rgb, daltonized, intensity);

    } else if (u_type < 2.5) {
        // u_type == 2.0: Achromatopsia (full): luminance + contrast boost
        float y = 0.2126 * linear_rgb.r + 0.7152 * linear_rgb.g + 0.0722 * linear_rgb.b;
        float contrast_diag = mix(1.0, u_m00, intensity);
        float boosted = contrast_diag * y;
        processed = mix(linear_rgb, vec3(boosted), intensity);

    } else {
        // u_type == 3.0: Achromatomaly (partial): luminance + reduced contrast + partial blend
        float y = 0.2126 * linear_rgb.r + 0.7152 * linear_rgb.g + 0.0722 * linear_rgb.b;
        float contrast_diag = mix(1.0, u_m00, intensity);
        float boosted = contrast_diag * y;
        float blend = u_achromat_blend * intensity;
        processed = mix(linear_rgb, vec3(boosted), blend);
    }

    // 2. Encode linear → sRGB
    vec3 srgb_out = linear_to_srgb(processed);

    // 3. Clamp to [0, 1]
    vec3 clamped_out = clamp(srgb_out, 0.0, 1.0);

    frag_color = vec4(clamped_out, color.a);
}
