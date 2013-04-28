precision mediump float;
uniform sampler2D input_texture;

varying vec2 texture_coordinate;
varying vec4 left_right_coordinate;
varying vec4 top_bottom_coordinate;
varying vec4 top_left_top_right_coordinate;
varying vec4 bottom_left_bottom_right_coordinate;

void main()
{
    vec4 color = texture2D(input_texture, texture_coordinate);
    mediump vec4 sum = color;

    sum += texture2D(input_texture, left_right_coordinate.xy);
    sum += texture2D(input_texture, left_right_coordinate.zw);
    sum += texture2D(input_texture, top_bottom_coordinate.xy);
    sum += texture2D(input_texture, top_left_top_right_coordinate.xy);
    sum += texture2D(input_texture, top_left_top_right_coordinate.zw);
    sum += texture2D(input_texture, top_bottom_coordinate.zw);
    sum += texture2D(input_texture, bottom_left_bottom_right_coordinate.xy);
    sum += texture2D(input_texture, bottom_left_bottom_right_coordinate.zw);
    
    sum /= 9.0;
    
//    gl_FragColor = color + sum;
//    gl_FragColor = sum;
    gl_FragColor = color + sum * 0.5;
}