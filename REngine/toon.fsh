precision mediump float;

uniform sampler2D input_texture;
uniform sampler2D blurred_texture;
uniform float coefficient;

varying vec2 texture_coordinate;
varying vec4 left_right_coordinate;
varying vec4 top_bottom_coordinate;
varying vec4 top_left_top_right_coordinate;
varying vec4 bottom_left_bottom_right_coordinate;

float grad()
{
    vec3 left           = texture2D(blurred_texture, left_right_coordinate.xy).rgb;
    vec3 right          = texture2D(blurred_texture, left_right_coordinate.zw).rgb;
    vec3 top            = texture2D(blurred_texture, top_bottom_coordinate.xy).rgb;
    vec3 top_left       = texture2D(blurred_texture, top_left_top_right_coordinate.xy).rgb;
    vec3 top_right      = texture2D(blurred_texture, top_left_top_right_coordinate.zw).rgb;
    vec3 bottom         = texture2D(blurred_texture, top_bottom_coordinate.zw).rgb;
    vec3 bottom_left    = texture2D(blurred_texture, bottom_left_bottom_right_coordinate.xy).rgb;
    vec3 bottom_right   = texture2D(blurred_texture, bottom_left_bottom_right_coordinate.zw).rgb;
    
    vec3 grayscale = vec3(0.3, 0.59, 0.11);
    
    left           = vec3(dot(grayscale, left));
    right          = vec3(dot(grayscale, right));
    top            = vec3(dot(grayscale, top));
    top_left       = vec3(dot(grayscale, top_left));
    top_right      = vec3(dot(grayscale, top_right));
    bottom         = vec3(dot(grayscale, bottom));
    bottom_left    = vec3(dot(grayscale, bottom_left));
    bottom_right   = vec3(dot(grayscale, bottom_right));
    
    float dX = -top_left.r - 2.0*left.r - bottom_left.r + top_right.r + 2.0*right.r + bottom_right.r;
    float dY = -top_left.r - 2.0*top.r - top_right.r + bottom_left.r + 2.0*bottom.r + bottom_right.r;
    
    float grad = abs(dX) + abs(dY);
    return 1.0-clamp(grad * coefficient, 0.0, 1.0);
    
    //    float mag = length(vec2(dX, dY));
    //    float thresholdTest = 1.0 - step(coefficient, mag);
    //    return thresholdTest;
}

void main()
{
    float gradient = grad();
    gl_FragColor = vec4(texture2D(input_texture, texture_coordinate).rgb * gradient, 1.0);
    
    //    float quantization_levels = 32.0;
    //    vec3 original_fragment_color = texture2D(original_texture, vec2(texture_coordinate.x, 1.0 - texture_coordinate.y)).bgr;
    //    vec3 posterized_image_color = floor((original_fragment_color.rgb * quantization_levels) + 0.5) / quantization_levels;
    //    gl_FragColor = vec4(posterized_image_color * gradient, 1.0);
}