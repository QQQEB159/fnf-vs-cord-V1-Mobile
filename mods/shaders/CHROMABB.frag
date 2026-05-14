#pragma header

uniform float intensity;

void main() {
    float offset = distance(openfl_TextureCoordv, vec2(0.5, 0.5)) * (0.01 * intensity);

    gl_FragColor = vec4(
        flixel_texture2D(
            bitmap, 
            openfl_TextureCoordv + vec2(offset, 0.0)
        ).r,
        flixel_texture2D(
            bitmap,
            openfl_TextureCoordv + vec2(-offset, 0.0)
        ).g,
        flixel_texture2D(
            bitmap,
            openfl_TextureCoordv
        ).b,
        1.0
    );
}