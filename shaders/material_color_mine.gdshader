shader_type spatial;

uniform vec4 color = vec4(1.0);
uniform bool special_mat = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(!special_mat){
		ALBEDO = color.rgb;
		//EMISSION = color.rgb;
	}else{
		ALBEDO = color.rgb;
		EMISSION = color.rgb;
	}
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
