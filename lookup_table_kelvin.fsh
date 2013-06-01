precision lowp float;
varying vec2 texture_coordinate;

uniform sampler2D input_texture;
uniform sampler2D lookup_texture;

void main()
{
    vec4 texture_color = texture2D(input_texture, texture_coordinate);
    float r = texture2D(lookup_texture, vec2(texture_color.r, 0.16)).r;
    float g = texture2D(lookup_texture, vec2(texture_color.g, 0.5)).r;
    float b = texture2D(lookup_texture, vec2(texture_color.b, 0.8333)).r;
    

    gl_FragColor = vec4(vec3(r, g, b), texture_color.a);
//    gl_FragColor = vec4(pow(vec3(r, g, b), vec3(0.94,0.94,0.94)), texture_color.a);
}