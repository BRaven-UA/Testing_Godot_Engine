// outline color's alpha is ignored
// outline grows only outside
// outline with no shadow

shader_type canvas_item;

uniform vec4 outlineColor : hint_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float width : hint_range(0.0, 10.0) = 1.0;

void fragment()
{
	vec4 col = texture(TEXTURE, UV);
	vec2 ps = TEXTURE_PIXEL_SIZE;
	float max_a = col.a;
	
	max_a = max(texture(TEXTURE, UV + vec2(0.0, width) * ps).a, max_a);
	max_a = max(texture(TEXTURE, UV + vec2(width, width) * ps).a, max_a);
	max_a = max(texture(TEXTURE, UV + vec2(width, 0.0) * ps).a, max_a);
	max_a = max(texture(TEXTURE, UV + vec2(width, -width) * ps).a, max_a);
	max_a = max(texture(TEXTURE, UV + vec2(0.0, -width) * ps).a, max_a);
	max_a = max(texture(TEXTURE, UV + vec2(-width, -width) * ps).a, max_a);
	max_a = max(texture(TEXTURE, UV + vec2(-width, 0.0) * ps).a, max_a);
	max_a = max(texture(TEXTURE, UV + vec2(-width, width) * ps).a, max_a);
	
	COLOR = mix(vec4(outlineColor.rgb, max_a), col, col.a);
}