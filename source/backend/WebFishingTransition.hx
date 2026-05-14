package backend;

import flixel.system.FlxAssets.FlxShader;

class WebFishingTransition extends MusicBeatSubstate
{
	var finishCallback:Null<Void->Void>;
	
	var blue:FlxSprite;
	
	var shader:CircleShader;
	
	final isTransIn:Bool;
	final duration:Float;
	
	public function new(duration:Float, isTransIn:Bool, ?finishCallback:Void->Void)
	{
		this.duration = duration;
		this.isTransIn = isTransIn;
		this.finishCallback = finishCallback;
		super();
	}
	
	override function create()
	{
		super.create();
		
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		
		blue = new FlxSprite().makeGraphic(FlxG.width, FlxG.width, 0xFF101C31);
		add(blue);
		blue.shader = shader = new CircleShader();
		blue.screenCenter();
		
		blue.scrollFactor.set();
		
		shader.radius = isTransIn ? 0 : 1;
		
		FlxG.sound.play(Paths.sound(isTransIn ? 'webfishEnter' : 'webfishExit'));
		
		FlxTween.tween(shader, {radius: isTransIn ? 1 : 0}, duration,
			{
				onComplete: Void -> {
					dispatchFinish();
				}
			});
	}
	
	/**
	 * ends the transition
	 */
	public function dispatchFinish()
	{
		if (finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
		FlxTimer.wait(0, close);
	}
}

class CircleShader extends FlxShader
{
	public var radius(default, set):Float = 0;
	
	@:glFragmentSource('
		#pragma header


		uniform float u_radius;
		
		vec3 drawCircle(vec2 uv, float radius)
		{
			float uvLength = length(uv);

			vec3 circle = vec3(smoothstep(radius, radius - 2.0 / openfl_TextureSize.y , uvLength));

			return vec3(circle);
		}

		void main()
		{
			vec2 uv = openfl_TextureCoordv;

			vec4 tex = flixel_texture2D(bitmap, uv);

			uv -= vec2(0.5);

			vec3 circle = drawCircle(uv, u_radius);

			tex.rgba *= 1.0 - circle.r;

			gl_FragColor = tex;
		}
			
		
		')
	public function new()
	{
		super();
		
		u_radius.value = [0, 0];
	}
	
	function set_radius(value:Float):Float
	{
		return this.u_radius.value[0] = radius = value;
	}
}
