package objects;

import flixel.addons.display.FlxPieDial;

class FunkinVideoCutscene extends FunkinVideoSprite
{
	public var skipIndicator:FlxPieDial;
	public var skipHoldTime:Float = 2;
	public var skipElapsed:Float = 0;
	
	public var fadeSpr:FlxSprite;
	
	public function new(skippable:Bool = true)
	{
		super(0, 0, true, skippable);
		skipIndicator = new FlxPieDial(0, 0, 40, FlxColor.WHITE, 48, null, true, 20);
		fadeSpr = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		fadeSpr.alpha = 0;
	}
	
	override function update(elapsed:Float)
	{
		if (exists)
		{
			if (canSkip && bitmap != null && bitmap.isPlaying)
			{
				if (Controls.instance.pressed('accept'))
				{
					if (skipElapsed >= skipHoldTime)
					{
						skipElegantly();
					}
					skipElapsed += elapsed;
				}
				else
				{
					skipElapsed -= elapsed;
				}
			}
			
			skipElapsed = FlxMath.bound(skipElapsed, 0, skipHoldTime);
			
			if (skipIndicator != null && skipIndicator.exists)
			{
				skipIndicator.update(elapsed);
				
				skipIndicator.alpha = Math.min(skipElapsed, 1) * this.alpha;
				skipIndicator.amount = FlxMath.remapToRange(skipElapsed, 0, skipHoldTime, 0, 1);
			}
		}
	}
	
	override function draw()
	{
		super.draw();
		
		if (skipIndicator != null && skipIndicator.exists)
		{
			skipIndicator.camera = camera;
			skipIndicator.x = this.x + this.width - skipIndicator.width - 10;
			skipIndicator.y = this.y + this.height - skipIndicator.height - 10;
			skipIndicator.draw();
		}
		
		if (fadeSpr != null && fadeSpr.exists)
		{
			fadeSpr.camera = camera;
			
			fadeSpr.x = x;
			fadeSpr.y = y;
			fadeSpr.scale.x = width;
			fadeSpr.scale.y = height;
			fadeSpr.updateHitbox();
			fadeSpr.draw();
		}
	}
	
	public function skipElegantly()
	{
		canSkip = false;
		
		FlxTween.tween(fadeSpr, {alpha: 1}, 0.2, {onComplete: Void -> skip()});
	}
	
	override function destroy()
	{
		super.destroy();
		skipIndicator?.destroy();
		fadeSpr?.destroy();
	}
	
	override function kill()
	{
		super.kill();
		skipIndicator?.kill();
		fadeSpr?.kill();
	}
	
	override function revive()
	{
		super.revive();
		skipIndicator?.revive();
		fadeSpr?.revive();
	}
}
