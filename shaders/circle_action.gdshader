shader_type spatial;

uniform vec4 color : source_color = vec4(1.0);
uniform float diameter = 1.0; // Circle Diameter
uniform float thickness = 0.05; // Outline thickness
uniform float frequency = 20.0; // Controls the number of dots
uniform float phase = 0.0; // Controls the rotation of the circle
uniform float rad = 1.0;


void vertex() {
	// Called for every vertex the material is visible on.
}


void fragment() {

	vec2 pos = UV - vec2(0.5);
	float outer_radius = diameter / 2.0;
	float inner_radius = outer_radius - thickness/rad;
	float outer_circle = step(length(pos), outer_radius);
	float inner_circle = step(length(pos), inner_radius);


	float angle = atan(pos.y, pos.x);
	if (angle < 0.0) {
		angle += 2.0 * PI;
	}

	float wave = 0.5 * sin(frequency * angle + phase) + 0.5;


	float ring = outer_circle - inner_circle;
	ring *= step(0.5, wave);

	ALBEDO = color.rgb;
	ALPHA = ring * color.a;
}

//void light() {
// Called for every pixel for every light affecting the material.
// Uncomment to replace the default light processing function with this one.
//}
