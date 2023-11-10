shader_type canvas_item;
render_mode blend_mix;

uniform vec4  outline_color : source_color;
uniform vec4  fill_color : source_color;

void fragment()
{
    vec4 tcol = texture(TEXTURE, UV);
    if (tcol.a == 0.0)
    {
        float size_x = 1.0/float(textureSize(TEXTURE, 0).x);
        float size_y = 1.0/float(textureSize(TEXTURE, 0).y);
        float alpha = 0.0;
        alpha += texture(TEXTURE, UV + vec2(size_x, 0)).a;
        alpha += texture(TEXTURE, UV + vec2(-size_x, 0)).a;
        alpha += texture(TEXTURE, UV + vec2(0, size_y)).a;
        alpha += texture(TEXTURE, UV + vec2(0, -size_y)).a;
        if (alpha > 0.1)
        {
            COLOR = outline_color;
        }
        
    }
    else
    {
        COLOR = fill_color;
    }
}