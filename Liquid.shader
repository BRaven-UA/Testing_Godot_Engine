shader_type canvas_item;

float height(in vec2 p, float time) {
    vec2 uv = p;
	float res = 1.;
    for (int i = 0; i < 3; i++) {
        res += cos(uv.y*12.345 - time + cos(res*12.234)*.2 + cos(uv.x*32.2345 + cos(uv.y*17.234)) ) + cos(uv.x*12.345);
    	uv = uv.yx;
        uv.x += res*.1;
    }
    return res;
}
vec2 normal(in vec2 p, float time) {
    vec2 NE = vec2(.1,0.);
    return normalize(vec2( height(p+NE, time)-height(p-NE, time),
                           height(p+NE.yx, time)-height(p-NE.yx, time) ));
}
void fragment()
{
	vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy * 3.;
    vec3 norm3d = normalize(vec3(normal(uv, TIME), 1.).xzy);
    vec3 view = normalize(vec3(uv, -1.).xzy);
	float r = mix(.6, .8, max(0.,dot(-norm3d, view)));
	COLOR = vec4(r, 0.0, 0.0, 1.0);
}