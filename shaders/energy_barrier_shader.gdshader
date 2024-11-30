shader_type spatial;
render_mode cull_disabled, unshaded;


uniform vec4 base_color : source_color = vec4(0.792, 0.494, 0.949, 0.8);
uniform vec4 detail_color : source_color = vec4(0.639, 0.365, 0.851, 0.8);
uniform sampler2D noise_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {

	
	vec4 noise = texture(noise_texture, UV+vec2(TIME*0.1, 0.0));
	ALBEDO = mix(base_color, detail_color, noise).rgb;
	ALPHA = mix(base_color.a,detail_color.a, noise.r);
	EMISSION = base_color.rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
