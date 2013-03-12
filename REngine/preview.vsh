attribute vec4 position;
attribute vec2 tex_coord_in;

uniform highp float texel_width; 
uniform highp float texel_height;

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
	gl_Position = position;
    
    vec2 widthStep = vec2(texel_width, 0.0);
    vec2 heightStep = vec2(0.0, texel_height);
    vec2 width_height_step = vec2(texel_width, texel_height);
    vec2 width_negative_height_step = vec2(texel_width, -texel_height);
    
    texture_coordinate = tex_coord_in;
    left_texture_coordinate = tex_coord_in - widthStep;
    right_texture_coordinate = tex_coord_in + widthStep;
    
    top_texture_coordinate = tex_coord_in - heightStep;
    top_left_texture_coordinate = tex_coord_in - width_height_step;
    top_right_texture_coordinate = tex_coord_in + width_negative_height_step;
    
    bottom_texture_coordinate = tex_coord_in + heightStep;
    bottom_left_texture_coordinate = tex_coord_in - width_negative_height_step;
    bottom_right_texture_coordinate = tex_coord_in + width_height_step;
}