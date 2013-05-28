precision lowp float;
varying vec2 texture_coordinate;

uniform sampler2D input_texture;
uniform sampler2D lookup_texture;

vec3 screen(vec3 c, vec3 v, float a)
{
    return vec3(1.0 - (1.0 - c.r) * (1.0 - v.r * a),
                1.0 - (1.0 - c.g) * (1.0 - v.g * a),
                1.0 - (1.0 - c.b) * (1.0 - v.b * a));
}

vec3 color_burn(vec3 c, vec3 v)
{
    return vec3(1.0 - (1.0 - c.r) / v.r,
                1.0 - (1.0 - c.g) / v.g,
                1.0 - (1.0 - c.b) / v.b);
}

vec3 multiply(vec3 c, vec3 v)
{
    return c * v;
}

void main()
{
    lowp vec3 rgb = texture2D(input_texture, texture_coordinate).rgb;
    lowp vec3 lookup_color = texture2D(lookup_texture, texture_coordinate).rgb;
    
    rgb = screen(rgb, vec3(0.89, 0.047, 0.66), 0.15);
    rgb = multiply(rgb, lookup_color);
//    rgb = color_burn(rgb, lookup_color);
    
    gl_FragColor = vec4(rgb, 1);
}
