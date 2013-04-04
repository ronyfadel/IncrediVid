attribute vec2 position;
attribute vec2 tex_coord_in;

uniform highp float texel_width;
uniform highp float texel_height;

varying vec2 texture_coordinate;
varying vec4 left_right_coordinate;
varying vec4 top_bottom_coordinate;
varying vec4 top_left_top_right_coordinate;
varying vec4 bottom_left_bottom_right_coordinate;

void main()
{
	gl_Position = vec4(position, 0, 1);
    
    vec2 width_step = vec2(texel_width, 0.0);
    vec2 height_step = vec2(0.0, texel_height);
    vec2 width_height_step = vec2(texel_width, texel_height);
    vec2 width_negative_height_step = vec2(texel_width, -texel_height);
    
    texture_coordinate = tex_coord_in;
    left_right_coordinate.xy = tex_coord_in - width_step;
    left_right_coordinate.zw = tex_coord_in + width_step;
    top_bottom_coordinate.xy = tex_coord_in - height_step;
    top_bottom_coordinate.zw = tex_coord_in + height_step;
    top_left_top_right_coordinate.xy = tex_coord_in - width_height_step;
    top_left_top_right_coordinate.zw = tex_coord_in + width_negative_height_step;
    bottom_left_bottom_right_coordinate.xy = tex_coord_in - width_negative_height_step;
    bottom_left_bottom_right_coordinate.zw = tex_coord_in + width_height_step;
}