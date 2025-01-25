
shader_type spatial;
render_mode unshaded;


uniform vec4 color_0 : source_color = vec4(1,1,1,1);
uniform vec4 color_1 : source_color = vec4(0,0,0,1);


uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;

vec3 rgb_to_yuv(vec4 rgba) {
    float R = rgba.r;
	float G = rgba.g;
	float B = rgba.b;
    float Y = 0.299 * R + 0.587 * G + 0.114 * B;
    float U = -0.147 * R - 0.289 * G + 0.436 * B;
    float V = 0.615 * R - 0.515 * G - 0.100 * B;
    return vec3(Y, U, V);
}

uniform sampler2D depth_texture : source_color, hint_depth_texture;

void fragment() {


	vec4 colors[2] = {color_0,color_1};
	float min_diff = -1.0;
	vec4 min_color = vec4(0.0, 0.0, 0.0, 1.0);

	vec2 uv = SCREEN_UV;


	vec4 temp = textureLod(SCREEN_TEXTURE, uv, 0.0);

	min_diff = 1000.0;
	for (int i = 0; i < colors.length(); i++) {

		float curr_dist = distance(rgb_to_yuv(colors[i]), rgb_to_yuv(temp));
		if (curr_dist < min_diff) {
			min_diff = curr_dist;
			min_color = colors[i];
		}
	}
		
	
	ALBEDO.rgb = min_color.rgb;
}

void vertex() {
  POSITION = vec4(VERTEX, 1.0);
}


	