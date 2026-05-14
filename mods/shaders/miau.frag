#pragma header

uniform float u_sinStrength;
uniform float u_mosaic;
uniform float iTime;

void main()
{
	vec2 scalar = openfl_TextureSize / u_mosaic;

	vec2 uv = floor(openfl_TextureCoordv * scalar) / scalar;

	uv.y += sin(uv.x / 0.1 + iTime) * (u_sinStrength / 10.0);

	gl_FragColor = flixel_texture2D(bitmap, uv);
}
