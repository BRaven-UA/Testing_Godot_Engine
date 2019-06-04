// outline has small shadow
// outline has alpha
// outline grows both outside and inside
// has artifacts on corners

shader_type canvas_item;

uniform vec4 outlineColor : hint_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float width : hint_range(0.0, 5.0) = 1.0;

void fragment()
{
	vec4 col = texture(TEXTURE, UV);
	vec2 ps = TEXTURE_PIXEL_SIZE;
	float a;
	float min_a = col.a;
	float max_a = col.a;
	
	a = texture(TEXTURE, UV + vec2(0.0, width) * ps).a;
	min_a = min(a, min_a);
	max_a = max(a, max_a);
	
	a = texture(TEXTURE, UV + vec2(0.0, -width) * ps).a;
	min_a = min(a, min_a);
	max_a = max(a, max_a);
	
	a = texture(TEXTURE, UV + vec2(width, 0.0) * ps).a;
	min_a = min(a, min_a);
	max_a = max(a, max_a);
	
	a = texture(TEXTURE, UV + vec2(-width, 0.0) * ps).a;
	min_a = min(a, min_a);
	max_a = max(a, max_a);
	
	COLOR = mix(col, outlineColor, max_a - min_a);
}