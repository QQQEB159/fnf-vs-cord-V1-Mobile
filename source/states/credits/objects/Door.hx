package states.credits.objects;

import flixel.math.FlxRect;

import shaders.WiggleEffect;

class Door extends FlxSpriteGroup
{
	var wiggle:WiggleEffect = new WiggleEffect();
	
	var sky:FlxSprite;
	var sky_dupe:FlxSprite;
	var facingRight:Bool = false;
	
	public var white:FlxSprite;
	public var back:FlxSprite;
	public var front:FlxSprite;
	
	public var collider:FlxSprite;
	
	override public function new(x:Float, y:Float, facingRight:Bool)
	{
		super(x, y);
		this.facingRight = facingRight;
		
		wiggle.effectType = WiggleEffectType.DREAMY;
		wiggle.waveAmplitude = 0.2;
		wiggle.waveFrequency = 7;
		wiggle.waveSpeed = 1;
		
		sky = new FlxSprite(5, 60).loadGraphic(Paths.image("menuassets/credits/exitSky"));
		add(sky);
		sky.scale.set(1.85, 1.85);
		sky.updateHitbox();
		
		sky_dupe = new FlxSprite(sky.x, sky.y).loadGraphic(Paths.image("menuassets/credits/exitSky"));
		add(sky_dupe);
		sky_dupe.scale.set(1.85, 1.85);
		sky_dupe.updateHitbox();
		sky_dupe.blend = MULTIPLY;
		sky_dupe.shader = sky.shader = wiggle.shader;
		sky_dupe.clipRect = new FlxRect(facingRight ? 0 : 15, 0, 175, Std.int(sky_dupe.height));
		sky_dupe.clipRect = sky_dupe.clipRect;
		
		white = new FlxSprite(x, 0).makeGraphic(Std.int(sky.width), 300);
		add(white);
		white.alpha = 0;
		
		back = new FlxSprite(0, 0).loadGraphic(Paths.image("menuassets/credits/backExit"));
		add(back);
		back.scale.set(3, 3);
		back.updateHitbox();
		back.antialiasing = false;
		back.flipX = facingRight;
		
		collider = new FlxSprite(0, 0).makeGraphic(10, Std.int(back.height), FlxColor.BLACK);
		add(collider);
		
		front = new FlxSprite(0, 0).loadGraphic(Paths.image("menuassets/credits/frontExit"));
		//	add(front);
		front.scale.set(3, 3);
		front.updateHitbox();
		front.antialiasing = false;
		
		if (facingRight)
		{
			front.flipX = true;
			front.x = 0;
			back.x = front.width;
			collider.x = 60;
		}
		else
		{
			front.x = x + back.width;
			collider.x = ((front.x + front.width) - collider.width) - 60;
			white.x = back.x;
		}
		
		FlxTween.circularMotion(sky_dupe, sky.x + ((sky.width / 2) - (sky.width / 2)), sky.y + ((sky.height / 2) - (sky.height / 2)), 10, 0, true, 3, true, {type: LOOPING});
	}
	
	override public function update(elapsed:Float)
	{
		wiggle.update(elapsed);
		super.update(elapsed);
	}
}
