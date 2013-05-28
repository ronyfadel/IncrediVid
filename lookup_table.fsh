precision mediump float;
varying vec2 texture_coordinate;

uniform sampler2D input_texture;
uniform sampler2D lookup_texture;

void main()
{
    mediump vec4 texture_color = texture2D(input_texture, texture_coordinate);
    mediump float r = texture2D(lookup_texture, vec2(texture_color.r, 0.16)).r;
    mediump float g = texture2D(lookup_texture, vec2(texture_color.g, 0.5)).r;
    mediump float b = texture2D(lookup_texture, vec2(texture_color.b, 0.8333)).r;
    
    gl_FragColor = vec4(vec3(r, g, b), texture_color.a);
//    gl_FragColor = vec4(vec3(texture2D(lookup_texture,vec2(texture_coordinate.x, 0)).r, 0, 0), 1);
//    gl_FragColor = vec4(vec3(texture2D(lookup_texture, vec2(texture_color.r, 0)).r, 0, 0), 1);
}
