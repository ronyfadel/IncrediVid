precision mediump float;
varying vec2 texture_coordinate;
 
uniform sampler2D input_texture;
uniform sampler2D lookup_texture;
 
void main()
{
    lowp vec4 texture_color = texture2D(input_texture, texture_coordinate);

    mediump float blue_color = texture_color.b * 63.0;

    mediump vec2 quad1;
    quad1.y = floor(floor(blue_color) / 8.0);
    quad1.x = floor(blue_color) - (quad1.y * 8.0);

    mediump vec2 quad2;
    quad2.y = floor(ceil(blue_color) / 8.0);
    quad2.x = ceil(blue_color) - (quad2.y * 8.0);

    highp vec2 texPos1;
    texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * texture_color.r);
    texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * texture_color.g);

    highp vec2 texPos2;
    texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * texture_color.r);
    texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * texture_color.g);

    lowp vec4 new_color1 = texture2D(lookup_texture, texPos1);
    lowp vec4 new_color2 = texture2D(lookup_texture, texPos2);

    lowp vec4 new_color = mix(new_color1, new_color2, fract(blue_color));
    
    gl_FragColor = vec4(new_color.rgb, texture_color.w);
}
