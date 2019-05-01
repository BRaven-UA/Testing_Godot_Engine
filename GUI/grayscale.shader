shader_type canvas_item;

uniform float brightness = 0.5;

void fragment()
{
	vec3 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	COLOR.rgb = vec3(dot(c.rgb, vec3(0.299, 0.587, 0.114)) * brightness);
}