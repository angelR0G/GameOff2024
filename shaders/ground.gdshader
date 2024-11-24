shader_type spatial;
render_mode world_vertex_coords;
uniform vec4 base_color: source_color;
uniform vec4 detail_color: source_color;
uniform sampler2D noise_texture;
uniform sampler2D noise_texturesmooth;
uniform float edge_fade : hint_range(0.0, 1.0, 0.01) = 0.1;

varying vec2 vertex_uv;

float calculate_edge_fade(vec2 uv) {
	vec2 fade = vec2(1.0);
	if (uv.x < edge_fade){
		fade.x  = smoothstep(0.0, edge_fade, uv.x);
	}
	else if (uv.x > 1.0-edge_fade){
		fade.x  = 1.0-smoothstep(1.0-edge_fade, 1.0, uv.x);
	}
	
	if (uv.y < edge_fade){
		fade.y  = smoothstep(0.0, edge_fade, uv.y);
	}
	else if (uv.y > 1.0-edge_fade){
		fade.y  = 1.0-smoothstep(1.0-edge_fade, 1.0, uv.y);
	}
	
	//
      //smoothstep(vec2(0.0), vec2(edge_fade), uv) *
                //smoothstep(vec2(0.0), vec2(edge_fade), 1.0-uv) *
				//(vec2(1.0)-smoothstep(vec2(1.0), vec2(0.9), uv));
    return min(fade.x,fade.y);
}

void vertex() {
	vertex_uv = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
	vec2 uv = vec2(UV.x + vertex_uv.x/1000.0, UV.y + vertex_uv.y/1000.0);
	vec4 noise = texture(noise_texture, uv);
	vec4 noise2 = texture(noise_texturesmooth, uv);
	float avg = (noise.r+noise.g+noise.b)/3.0;
	float avg2 = (noise2.r+noise2.g+noise2.b)/3.0;
	
	if ( avg < 0.45){
		ALBEDO = detail_color.rgb;
		if ( avg2 < 0.2){
			ALBEDO = base_color.rgb;
		}
		//float edge_alpha = calculate_edge_fade(UV);
		//ALBEDO = mix(base_color.rgb, detail_color.rgb, edge_alpha);
		
	} else {
		ALBEDO = base_color.rgb;
	}
	//float edge_alpha = calculate_edge_fade(UV);
	//ALPHA = edge_alpha;
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
