package backend;

import flixel.util.FlxGradient;

import backend.MusicBeatSubstate;

class FadeTransition extends MusicBeatSubstate
{
	public var finishCallback:Null<Void->Void>;
	
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	
	var duration:Float;
	
	public function new(duration:Float, isTransIn:Bool, ?finishCallback:Void->Void)
	{
		this.duration = duration;
		this.isTransIn = isTransIn;
		this.finishCallback = finishCallback;
		super();
	}
	
	override function create():Void
	{
		transBlack = new extensions.flixel.FlxUniformSprite().makeScaledGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		transBlack.scrollFactor.set();
		transBlack.screenCenter(X);
		add(transBlack);
		
		transBlack.alpha = isTransIn ? 1 : 0;
		
		super.create();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		
		var add = (elapsed / duration) * (isTransIn ? -1 : 1);
		transBlack.alpha += add;
		
		if (isTransIn && transBlack.alpha <= 0 || !isTransIn && transBlack.alpha >= 1)
		{
			close();
		}
	}
	
	// Don't delete this
	override function close():Void
	{
		super.close();
		
		if (finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}
}
