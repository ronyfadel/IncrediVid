attribute vec2 position;
attribute vec2 tex_coord_in;

varying vec2 texture_coordinate;

void main()
{
    texture_coordinate = tex_coord_in;
	gl_Position = vec4(position, 0, 1);
}