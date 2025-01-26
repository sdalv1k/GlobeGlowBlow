shader_type spatial;

// We don't want lighting or shading from the scene, so "unshaded" is helpful.
// We also disable culling so we can see it regardless of facing.
render_mode unshaded, cull_disabled, depth_draw_always;

// ----------------------------------------------------
// Screen texture uniform
// ----------------------------------------------------
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;

// ----------------------------------------------------
// General uniforms
// ----------------------------------------------------
uniform float u_time : hint_range(0, 10000) = 0.0;
uniform vec2 u_screen_size = vec2(1280.0, 720.0);

// ----------------------------------------------------
// 0) NEW: Grayscale Option
// ----------------------------------------------------
uniform bool enable_grayscale = false;
uniform float color_blend_factor : hint_range(0.0, 1.0) = 0.2;// Adjust this value (0.0 to 1.0) to control the mix

// ----------------------------------------------------
// 1) Pixelation
// ----------------------------------------------------
uniform bool enable_pixelation = true;
uniform vec2 pixel_resolution = vec2(320.0, 180.0);

// ----------------------------------------------------
// 2) Barrel (or Pincushion) Distortion
// ----------------------------------------------------
uniform bool enable_barrel_distortion = false;
uniform float barrel_distortion_strength : hint_range(-1.0, 1.0) = 0.1;

// ----------------------------------------------------
// 3) Chromatic Aberration / Color Bleeding
// ----------------------------------------------------
uniform bool enable_chromatic_aberration = false;
uniform float aberration_strength : hint_range(0.0, 0.01) = 0.003;

// ----------------------------------------------------
// 4) Bloom (naive single-pass approach)
// ----------------------------------------------------
uniform bool enable_bloom = false;
uniform float bloom_threshold : hint_range(0.0, 1.0) = 0.7;
uniform float bloom_intensity : hint_range(0.0, 2.0) = 0.3;

// ----------------------------------------------------
// 5) Film Grain
// ----------------------------------------------------
uniform bool enable_film_grain = false;
uniform float grain_intensity : hint_range(0.0, 0.5) = 0.05;

// ----------------------------------------------------
// 6) Scan Lines
// ----------------------------------------------------
uniform bool enable_scan_lines = false;
uniform float scan_line_count : hint_range(50.0, 1500.0) = 400.0;
uniform float scan_line_intensity : hint_range(0.0, 1.0) = 0.2;

// ----------------------------------------------------
// 7) Noise / Distortion (Static, Screen Tearing, etc.)
// ----------------------------------------------------
uniform bool enable_distortion = false;
uniform float distortion_intensity : hint_range(0.0, 0.1) = 0.02;

// ----------------------------------------------------
// 8) Dark Desaturation
// ----------------------------------------------------
uniform float saturation : hint_range(0.0, 1.0) = 0.5;
uniform float brightness : hint_range(0.0, 2.0) = 1.0;

// ----------------------------------------------------
// 9) Vignette
// ----------------------------------------------------
uniform bool enable_vignette = false;
uniform float vignette_radius : hint_range(0.0, 1.0) = 0.5;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.5;

// ----------------------------------------------------
// 10) Depth of Field (Simulated / Without True Depth)
// ----------------------------------------------------
uniform bool enable_dof = false;
uniform float dof_focus : hint_range(0.0, 1.0) = 0.5;
uniform float dof_range : hint_range(0.0, 1.0) = 0.2;

// ----------------------------------------------------
// Helper function: random noise
// ----------------------------------------------------
float rand(vec2 co) {
    // A common inline 2D random function
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233)) + u_time) * 43758.5453);
}

// ----------------------------------------------------
// The fragment() function applies all effects
// ----------------------------------------------------
void fragment() 
{
    // Base UV for sampling the screen
    vec2 uv = SCREEN_UV;

    // ---------------------------------------------
    // 1) Pixelation
    // ---------------------------------------------
    if (enable_pixelation) {
        uv = floor(uv * pixel_resolution) / pixel_resolution;
    }

    // ---------------------------------------------
    // 2) Barrel (or pincushion) distortion
    // ---------------------------------------------
    if (enable_barrel_distortion) {
        vec2 center = vec2(0.5, 0.5);
        vec2 pos = uv - center;
        float r2 = dot(pos, pos);
        pos *= 1.0 + barrel_distortion_strength * r2;
        uv = pos + center;
    }

    // ---------------------------------------------
    // 3) Chromatic Aberration / Color Bleeding
    // ---------------------------------------------
    vec2 offset = enable_chromatic_aberration 
        ? vec2(aberration_strength, 0.0) 
        : vec2(0.0);

    // For alpha preservation, sample the base screen color once:
    vec4 base_screen_col = texture(SCREEN_TEXTURE, uv);
    
    // Now sample R/G/B with slight offset
    float rChan = texture(SCREEN_TEXTURE, uv + offset).r;
    float gChan = base_screen_col.g;
    float bChan = texture(SCREEN_TEXTURE, uv - offset).b;
    
    // Start our color with the combined channels and original alpha
    vec4 color = vec4(rChan, gChan, bChan, base_screen_col.a);

    // ---------------------------------------------
    // 4) Bloom (naive single-pass)
    // ---------------------------------------------
    if (enable_bloom) {
        vec4 bloom_col = vec4(0.0);
        float sample_off = 1.0 / 600.0;  // Offset for adjacent samples

        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                vec2 sample_uv = uv + vec2(float(x), float(y)) * sample_off;
                bloom_col += texture(SCREEN_TEXTURE, sample_uv);
            }
        }
        bloom_col /= 9.0; // average

        float brightness_val = max(color.r, max(color.g, color.b));
        float bloom_factor = brightness_val > bloom_threshold
            ? (brightness_val - bloom_threshold) / (1.0 - bloom_threshold)
            : 0.0;

        color.rgb += bloom_col.rgb * bloom_factor * bloom_intensity;
    }

    // ---------------------------------------------
    // 5) Film Grain
    // ---------------------------------------------
    if (enable_film_grain) {
        float n = rand(uv * u_screen_size);
        float grain = (n - 0.5) * 2.0 * grain_intensity;
        color.rgb += grain;
    }

    // ---------------------------------------------
    // 6) Horizontal Scan Lines
    // ---------------------------------------------
    if (enable_scan_lines) {
        float scan = sin(uv.y * scan_line_count);
        float intensity = (scan * 0.5 + 0.5);
        color.rgb *= 1.0 - intensity * scan_line_intensity;
    }

    // ---------------------------------------------
    // 7) Noise & Distortion (Static / Tearing)
    // ---------------------------------------------
    if (enable_distortion) {
        float distortion_noise = rand(uv * u_screen_size * 0.5 + u_time * 5.0);
        vec2 distorted_uv = uv;
        distorted_uv.x += (distortion_noise - 0.5) * distortion_intensity;
        color = texture(SCREEN_TEXTURE, distorted_uv);
    }

    // ---------------------------------------------
    // 8) Dark Desaturation
    // ---------------------------------------------
    float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(vec3(luma), color.rgb, saturation);
    color.rgb *= brightness;

    // ---------------------------------------------
    // 9) Vignette
    // ---------------------------------------------
    if (enable_vignette) {
        vec2 center = vec2(0.5, 0.5);
        float dist = distance(uv, center);
        float vign = smoothstep(vignette_radius, vignette_radius - vignette_softness, dist);
        color.rgb *= 1.0 - vign;
    }

    // ---------------------------------------------
    // 10) Depth of Field (Approximation)
    // ---------------------------------------------
    if (enable_dof) {
        float dist_from_center = distance(uv, vec2(0.5));
        float dof_blur_amount = clamp((dist_from_center - dof_focus) / dof_range, 0.0, 1.0);

        if (dof_blur_amount > 0.0) {
            vec4 blur_col = vec4(0.0);
            int samples = 5;
            float radius = 0.002 * dof_blur_amount;
            for (int i = 0; i < samples; i++) {
                float angle = 6.2831 * float(i) / float(samples); // 2*pi
                vec2 offset = vec2(cos(angle), sin(angle)) * radius;
                blur_col += texture(SCREEN_TEXTURE, uv + offset);
            }
            blur_col /= float(samples);
            color = mix(color, blur_col, dof_blur_amount);
        }
    }

// ---------------------------------------------
// 0) NEW: Grayscale with color retention
// ---------------------------------------------
	if (enable_grayscale) {
	    // Convert color to grayscale using the luminance formula
	    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	    vec3 grayscale = vec3(gray);

	    // Blend between original color and grayscale
	    color.rgb = mix(grayscale, color.rgb, color_blend_factor);

	    // Keep alpha from the original sampling (or from `color.a` above)
	    // color.a remains unchanged
	}

    // Output final color
    ALBEDO = color.rgb;
    ALPHA = color.a; // If you need the alpha from the screen, keep it. Otherwise 1.0
}
