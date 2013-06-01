precision mediump float;
varying vec2 texture_coordinate;

uniform sampler2D input_texture;
uniform sampler2D lookup_texture;

void main()
{
    mediump vec4 texture_color = texture2D(input_texture, texture_coordinate);
    float luminance = dot(texture_color.rgb, vec3(0.2126, 0.7152, 0.0722));
    gl_FragColor = vec4(vec3(luminance), texture_color.a);
}