#pragma header

uniform vec2 u_res; // resolution in px

void main() {
    gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv * u_res) / u_res);
}