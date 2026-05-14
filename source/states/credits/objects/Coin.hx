package states.credits.objects;

import flixel.math.FlxRect;
import flixel.FlxObject;

class Coin extends FlxSprite
{
	public var collected:Bool = false;
	
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		frames = Paths.getAtlas('menuassets/credits/coin');
		animation.addByPrefix('spin', 'spin', 12, true);
		animation.addByPrefix('get', 'get', 12, false);
		animation.play('spin');
		scale.set(3, 3);
		updateHitbox();
		animation.onFinish.add((anim) -> if (anim == 'get') kill());
	}
	
	public function grab()
	{
		if (collected) return;
		animation.play('get');
		collected = true;
		FlxG.sound.play(Paths.sound('credits/coinCollect'));
	}
	
	var _hitbox:FlxRect = null;
	
	public function objectOverlaps(obj:FlxObject):Bool
	{
		_hitbox = getHitbox(_hitbox);
		
		inline function trimBox(rect:FlxRect)
		{
			rect.width /= 2;
			rect.x += _hitbox.width / 2;
		}
		
		var objHitbox = obj.getHitbox();
		trimBox(_hitbox);
		trimBox(objHitbox);
		
		return _hitbox.overlaps(objHitbox);
	}
}
