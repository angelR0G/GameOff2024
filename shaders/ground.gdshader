shader_type spatial;

uniform vec4 base_color: source_color;
uniform vec4 detail_color: source_color;
uniform sampler2D noise_texture;
varying flat int a;
void vertex() {
	a = INSTANCE_ID;
}

float random (vec2 uv) {
	return fract(sin(dot(uv,vec2(12.9898,78.233)))*43758.5453123);
}
void fragment() {
	vec2 uv = vec2(UV.x * float(a), UV.y * float(a));
	vec2 uvNorm = normalize(uv);
	vec4 noise = texture(noise_texture, uv);
	float avg = (noise.r+noise.g+noise.b)/3.0;
	
	if ( avg < 0.5){
		ALBEDO = detail_color.rgb;
	} else {
		ALBEDO = base_color.rgb;
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
