shader_type canvas_item;
render_mode blend_mix;

uniform float outLineSize  = 0.01;
uniform float alphaThreshold  = 0.1;
uniform vec4  outLineColor = vec4(1.0, 1.0, 1.0, 1.0);

void fragment()
{
    vec4 tcol = texture(TEXTURE, UV);
    
    if (tcol.a == alphaThreshold)
    {
        if (texture(TEXTURE, UV + vec2(0.0,          outLineSize)).a  >= alphaThreshold ||
            texture(TEXTURE, UV + vec2(0.0,         -outLineSize)).a  >= alphaThreshold ||
            texture(TEXTURE, UV + vec2(outLineSize,  0.0)).a          >= alphaThreshold ||
            texture(TEXTURE, UV + vec2(-outLineSize, 0.0)).a          >= alphaThreshold ||
            texture(TEXTURE, UV + vec2(-outLineSize, outLineSize)).a  >= alphaThreshold ||
            texture(TEXTURE, UV + vec2(-outLineSize, -outLineSize)).a >= alphaThreshold ||
            texture(TEXTURE, UV + vec2(outLineSize,  outLineSize)).a  >= alphaThreshold ||
            texture(TEXTURE, UV + vec2(outLineSize,  -outLineSize)).a >= alphaThreshold) 
            tcol = outLineColor;
    }
    
    COLOR = tcol;
}