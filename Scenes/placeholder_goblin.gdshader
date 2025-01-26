shader_type spatial;

// Disable standard lighting, ensure it's always drawn on top.
render_mode unshaded, cull_disabled, depth_draw_always;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;
// Center of the swirl in normalized screen space (0.5,0.5 is screen center).

uniform vec2 swirl_center = vec2(0.5, 0.5);

// How strongly the image swirls near the center.
uniform float swirl_strength : hint_range(0.0, 10.0) = 3.0;

// Distance from center at which the swirl effect tapers out (0 to 1).
uniform float swirl_radius : hint_range(0.0, 1.0) = 0.5;

// Optionally animate the swirl over time
uniform float swirl_speed : hint_range(0.0, 5.0) = 1.0;

// Threshold for black/white cutoff (0.0 to 1.0).
uniform float threshold : hint_range(0.0, 1.0) = 0.5;

// Godot 4 usually provides TIME as a built-in. If not, pass it manually via script.
void fragment() {
    // Screen UV coordinate
    vec2 uv = SCREEN_UV;
    
    // Move UV so the swirl_center is the origin (0,0)
    uv -= swirl_center;

    // Distance and angle from swirl_center
    float r = length(uv);
    float angle = atan(uv.y, uv.x);

    // We only swirl within swirl_radius. Outside that, effect tapers to zero.
    // factor = 0 at center, 1 at swirl_radius
    float factor = clamp(r / swirl_radius, 0.0, 1.0);

    // The swirl amount decreases as we move away from the center.
    float swirl_amount = swirl_strength * (1.0 - factor);

    // Optionally add time-based rotation
    // This adds a global spin so the swirl rotates continuously.
    angle += swirl_amount + (swirl_speed * TIME);

    // Recompute the coordinates after swirl rotation
    vec2 new_uv = vec2(cos(angle), sin(angle)) * r;

    // Move UV back to original coordinate space
    new_uv += swirl_center;

    // Sample the screen texture at our distorted UV
    vec4 color = texture(SCREEN_TEXTURE, new_uv);

    // Convert sampled color to grayscale (luminance)
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));

    // High-contrast threshold:
    // Below threshold => black, above threshold => white
    float final_val = (gray < threshold) ? 0.0 : 1.0;

    // Output as black or white
    ALBEDO = vec3(final_val);
    ALPHA = 1.0;
	}