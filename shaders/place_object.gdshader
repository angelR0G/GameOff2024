shader_type spatial;

uniform sampler2D albedo_texture : source_color;
uniform vec4 cant_place_color:source_color = vec4(0.8, 0.0, 0.0, 1.0);
uniform	vec4 can_place_color:source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform bool can_place = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 view_dir = normalize(VIEW);
	vec3 normal = normalize(NORMAL);
	vec4 tex = texture(albedo_texture, UV);
	float fresnel = pow(1.0 - dot(normal, view_dir), 0.8);
	// Called for every pixel the material is visible on.
	//vec4 current_color = texture(screen_texture, UV);
	//ALBEDO = vec3(current_color.rgb);
	float effect = mix(0.1, 1.0, fresnel);
	vec4 final_color = can_place_color;
	if (!can_place){
		final_color = cant_place_color;
	}
	
	final_color*=effect;
	ALBEDO = final_color.rgb;
	ALPHA = clamp(effect*1.5, 0.0, 1.0);

}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
