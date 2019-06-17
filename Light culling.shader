shader_type canvas_item;

void fragment() {
	COLOR = vec4(texture(TEXTURE, UV).rgb, float(AT_LIGHT_PASS));
	}