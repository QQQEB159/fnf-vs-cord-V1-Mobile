#pragma header

uniform float u_skew;

void main()
{
	vec2 uv = openfl_TextureCoordv;

	vec2 pos = uv;

	pos.x = uv.x + (u_skew * uv.y);

	if (pos.x > 0.0 && pos.x < 1.0)
	{
		gl_FragColor = flixel_texture2D(bitmap,pos);
	}
	
}
