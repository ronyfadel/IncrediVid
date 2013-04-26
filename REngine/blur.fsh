precision mediump float;
uniform sampler2D input_texture;

varying vec2 texture_coordinate;
varying vec4 left_right_coordinate;
varying vec4 top_bottom_coordinate;
varying vec4 top_left_top_right_coordinate;
varying vec4 bottom_left_bottom_right_coordinate;

void main()
{
    lowp vec4 sum = vec4(0.0);
    
    sum += texture2D(input_texture, texture_coordinate) * 0.111;
    sum += texture2D(input_texture, left_right_coordinate.xy) * 0.111;
    sum += texture2D(input_texture, left_right_coordinate.zw) * 0.111;
    sum += texture2D(input_texture, top_bottom_coordinate.xy) * 0.111;
    sum += texture2D(input_texture, top_left_top_right_coordinate.xy) * 0.111;
    sum += texture2D(input_texture, top_left_top_right_coordinate.zw) * 0.111;
    sum += texture2D(input_texture, top_bottom_coordinate.zw) * 0.111;
    sum += texture2D(input_texture, bottom_left_bottom_right_coordinate.xy) * 0.111;
    sum += texture2D(input_texture, bottom_left_bottom_right_coordinate.zw) * 0.111;
    
    gl_FragColor = sum.bgra;
}