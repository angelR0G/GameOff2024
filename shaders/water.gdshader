shader_type spatial;
uniform sampler2D noise_texture;
uniform float wave_scale = 0.002;
uniform float wave_strength = 0.01;
//uniform sampler2D tex;
uniform vec4 color : source_color;


void vertex() {
	vec2 global_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
    float noise_value = texture(noise_texture, global_position * wave_scale).r;
    float wave = sin(global_position.x * 0.2 + global_position.y * 0.2 + TIME + noise_value * 10.0) * wave_strength;
    VERTEX.y += wave;
}

void fragment() {
	//vec4 water_color = texture(tex, UV);
	ALBEDO = color.rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
