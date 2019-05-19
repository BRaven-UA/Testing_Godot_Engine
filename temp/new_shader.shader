shader_type canvas_item;

uniform sampler2D picture : hint_texture;

void fragment() {

    vec4 scr_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	vec4 pic_color = texture(picture, UV, 0.0);
//	if (tex_color.r > 0.25) {tex_color.r = 1.0}
//    vec4 outlineColor = vec4(1.0, 0.0, 0.0, 1.0);
//    vec2 pixel_size = vec2(1.0, 1.0);
//
//    vec4 up_pixel    = textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, 1.0), 0.0);
//    vec4 down_pixel  = textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, -1.0), 0.0);
//    vec4 left_pixel  = textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(1.0, 0.0), 0.0);
//    vec4 right_pixel = textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(-1.0, 0.0), 0.0);

//    if(up_pixel.a != 0.0 && up_pixel.a != tex_color.a ||
//    down_pixel.a != 0.0 && down_pixel.a != tex_color.a ||
//    left_pixel.a != 0.0 && left_pixel.a != tex_color.a ||
//    right_pixel.a != 0.0 && right_pixel.a != tex_color.a )
//    {
//             tex_color = outlineColor;
//    }
    COLOR = pic_color;
}