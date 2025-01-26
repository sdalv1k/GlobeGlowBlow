shader_type spatial;

// We don't want lighting or shading from the scene, so "unshaded" is helpful.
// We also disable culling so we can see it from one side or both sides.
render_mode unshaded, cull_disabled, depth_draw_always;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;

void fragment() {
    // 1) Sample the already-rendered screen behind this object.
    //    SCREEN_TEXTURE is the entire screen; SCREEN_UV is the UV coordinate.
    vec4 screen_col = texture(SCREEN_TEXTURE, SCREEN_UV);

    // 2) Convert to grayscale using a common luminance formula.
    float gray = dot(screen_col.rgb, vec3(0.299, 0.587, 0.114));

    // 3) Assign to the built-in material properties.
    ALBEDO = vec3(gray);
    ALPHA = screen_col.a; // Keep the same alpha from the screen texture.
}
