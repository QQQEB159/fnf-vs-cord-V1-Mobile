package states.minigames.wanted;

import objects.Bopper;

class Heart extends Bopper
{
	public var twn:Null<FlxTween> = null;
	
	var isDead:Bool = false;
	
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		scalableOffsets = true;
		loadSparrowFrames('minigames/findcord/heart');
		
		animation.addByPrefix('idle', 'heart instance 1', 24);
		animation.addByPrefix('dead', 'loseHeart instance 1', 24, false);
		animation.addByPrefix('blush', 'heartBlush instance 1', 24, false);
		
		addOffset('idle');
		addOffset('dead', 66, 125);
		
		scale.scale(0.5);
		updateHitbox();
		
		playAnim('idle');
		
		origin.set(frameWidth / 2, frameHeight);
		
		angle = 20;
		twn = FlxTween.tween(this, {angle: -20}, 0.25, {ease: FlxEase.sineInOut, type: PINGPONG});
	}
	
	public function die()
	{
		twn?.cancel();
		
		playAnim('dead');
		angle = 0;
		isDead = true;
	}
	
	public function reviveHeart()
	{
		twn?.cancel();
		playAnim('idle');
		
		angle = 20;
		twn = FlxTween.tween(this, {angle: -20}, 0.25, {ease: FlxEase.sineInOut, type: PINGPONG});
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!isDead)
		{
			this.playAnim(FlxMath.mouseInFlxRect(true, getScreenBounds()) ? 'blush' : 'idle');
		}
	}
	
	override function destroy()
	{
		twn?.cancel();
		twn?.destroy();
		
		super.destroy();
	}
}
