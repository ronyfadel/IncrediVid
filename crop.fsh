precision lowp float;

uniform sampler2D input_texture;

varying vec2 texture_coordinate;

void main()
{
    gl_FragColor = texture2D(input_texture, texture_coordinate).bgra;
}