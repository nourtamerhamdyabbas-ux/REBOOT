shader_type canvas_item;
uniform vec4 left_color : source_color = vec4(0.0, 0.9, 1.0, 1.0);
uniform vec4 right_color : source_color = vec4(1.0, 0.18, 0.67, 1.0);

uniform vec2 panel_size = vec2(372.0, 102.0);
uniform float border_width_px = 3.0;
uniform float corner_radius = 12.0;
uniform float edge_softness_px = 0.8;

float rounded_box_sdf(vec2 p, vec2 half_size, float radius) {
	vec2 q = abs(p) - half_size + vec2(radius);
	return length(max(q, vec2(0, 0))) + min(max(q.x, q.y), 0.0) - radius;
}

void fragment() {
	vec2 p = UV * panel_size - panel_size * 0.5;
	vec2 half_size = panel_size * 0.5;
	float distance_to_edge = rounded_box_sdf(p, half_size, corner_radius);
	float outer_alpha = 1.0 - smoothstep(0.0, edge_softness_px, distance_to_edge);
	float inner_radius = max(0.0, corner_radius - border_width_px);
	vec2 inner_half_size = half_size - vec2(border_width_px);
	float inner_distance = rounded_box_sdf(p, inner_half_size, inner_radius);
	float inner_alpha = 1.0 - smoothstep(0.0, edge_softness_px, inner_distance);
	float border_alpha = outer_alpha * (1.0 - inner_alpha);
	vec4 gradient = mix(left_color, right_color, UV.x);
	COLOR = vec4(gradient.rgb, gradient.a * border_alpha);
}