package shaders;

import flixel.system.FlxAssets.FlxShader;

/**
 * No memory leakage due to constant recompilation
 * 
 * and additions
 */
class ColorSwapImproved extends FlxShader
{
	public var hue(default, set):Float = 0;
	
	public var saturation(default, set):Float = 0;
	
	public var brightness(default, set):Float = 0;
	
	public var mix(default, set):Float = 1;
	
	function set_hue(value:Float)
	{
		return (hue = this.u_hue.value[0] = value);
	}
	
	function set_saturation(value:Float)
	{
		return (saturation = this.u_saturation.value[0] = value);
	}
	
	function set_brightness(value:Float)
	{
		return (brightness = this.u_brightness.value[0] = value);
	}
	
	function set_mix(value:Float)
	{
		return (mix = this.u_mix.value[0] = value);
	}
	
	@:glFragmentSource('
		#pragma header

		uniform float u_brightness;

		uniform float u_saturation;

		uniform float u_hue;

		uniform float u_mix;

		const float offset = 1.0 / 128.0;

		vec3 normalizeColor(vec3 color)
		{
			return vec3(
				color[0] / 255.0,
				color[1] / 255.0,
				color[2] / 255.0
			);
		}

		vec3 rgb2hsv(vec3 c)
		{
			vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
			vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

			float d = q.x - min(q.w, q.y);
			float e = 1.0e-10;
			return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		vec3 hsv2rgb(vec3 c)
		{
			vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
			vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
			return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
		}

		void main()
		{
			vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

			vec4 swagColor = vec4(rgb2hsv(vec3(color[0], color[1], color[2])), color[3]);

			swagColor.r += u_hue;
			swagColor.g = swagColor.g + clamp(u_saturation,-1.0,1.0);
			swagColor.b = swagColor.b * (1.0 + u_brightness);

			vec4 tex = vec4(hsv2rgb(vec3(swagColor[0], swagColor[1], swagColor[2])), swagColor[3]);

			tex = mix(color, tex, u_mix);

			gl_FragColor = tex;
		}
		')
	public function new()
	{
		super();
		
		this.u_hue.value = [0, 0];
		this.u_saturation.value = [0, 0];
		this.u_brightness.value = [0, 0];
		this.u_mix.value = [1, 1];
	}
}
