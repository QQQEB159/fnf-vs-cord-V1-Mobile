package states.minigames.wanted;

import flixel.math.FlxRect;

import objects.Bopper;

class FlickerIcon extends Bopper
{
	public var startingPos:FlxPoint = FlxPoint.get();
	
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		startingPos.set(x, y);
	}
	
	var FLICKER_RATE:Float = 0.1;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (flickerTicks > 0)
		{
			flickerTimer += elapsed;
			if ((flickerTimer % FLICKER_RATE) / FLICKER_RATE > 0.5 != visible)
			{
				visible = !visible;
				flickerTicks--;
			}
		}
	}
	
	var flickerTimer:Float = 0;
	var flickerTicks:Int = 0;
	
	public function flicker()
	{
		flickerTicks = 5;
		visible = !visible;
	}
	
	public function wrapAroundRect(rect:FlxRect, clearence:Int = 5)
	{
		if (((this.x + getVisualWidth() + clearence) <= rect.left))
		{
			this.x = rect.right;
		}
		else if ((this.x >= rect.right + clearence))
		{
			this.x = rect.left - getVisualWidth();
		}
		
		if (((this.y + getVisualHeight() + clearence) <= rect.top))
		{
			this.y = rect.bottom;
		}
		else if ((this.y >= rect.bottom + clearence))
		{
			this.y = rect.top - getVisualHeight();
		}
	}
	
	inline public function getVisualWidth() return this.frameWidth * scale.x;
	
	inline public function getVisualHeight() return this.frameHeight * scale.y;
}
