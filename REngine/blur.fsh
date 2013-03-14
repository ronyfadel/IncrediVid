precision mediump float;
uniform sampler2D input_texture;

varying vec2 texture_coordinate;
varying vec2 left_texture_coordinate;
varying vec2 right_texture_coordinate;

varying vec2 top_texture_coordinate;
varying vec2 top_left_texture_coordinate;
varying vec2 top_right_texture_coordinate;

varying vec2 bottom_texture_coordinate;
varying vec2 bottom_left_texture_coordinate;
varying vec2 bottom_right_texture_coordinate;

void main()
{
    lowp vec4 sum = vec4(0.0);
    
    sum += texture2D(input_texture, texture_coordinate) * 0.111;
    sum += texture2D(input_texture, left_texture_coordinate) * 0.111;
    sum += texture2D(input_texture, right_texture_coordinate) * 0.111;
    sum += texture2D(input_texture, top_texture_coordinate) * 0.111;
    sum += texture2D(input_texture, top_left_texture_coordinate) * 0.111;
    sum += texture2D(input_texture, top_right_texture_coordinate) * 0.111;
    sum += texture2D(input_texture, bottom_texture_coordinate) * 0.111;
    sum += texture2D(input_texture, bottom_left_texture_coordinate) * 0.111;
    sum += texture2D(input_texture, bottom_right_texture_coordinate) * 0.111;
    
    gl_FragColor = sum.rgba;
}