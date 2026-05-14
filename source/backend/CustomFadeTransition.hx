package backend;

import flixel.util.FlxGradient;

import backend.MusicBeatSubstate;

class CustomFadeTransition extends MusicBeatSubstate
{
	public var finishCallback:Null<Void->Void>;
	
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;
	
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
		transGradient = new extensions.flixel.FlxUniformSprite();
		transGradient.loadGraphic(FlxGradient.createGradientBitmapData(1, FlxG.height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0])));
		transGradient.scale.x = FlxG.width;
		transGradient.updateHitbox();
		transGradient.scrollFactor.set();
		transGradient.screenCenter(X);
		add(transGradient);
		
		transBlack = new extensions.flixel.FlxUniformSprite().makeGraphic(1, 1, FlxColor.BLACK);
		transBlack.scale.set(FlxG.width, FlxG.height + 400);
		transBlack.updateHitbox();
		transBlack.scrollFactor.set();
		transBlack.screenCenter(X);
		add(transBlack);
		
		if (isTransIn) transGradient.y = transBlack.y - transBlack.height;
		else transGradient.y = -transGradient.height;
		
		super.create();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		
		final height:Float = FlxG.height;
		final targetPos:Float = transGradient.height + 50;
		if (duration > 0) transGradient.y += (height + targetPos) * elapsed / duration;
		else transGradient.y = (targetPos) * elapsed;
		
		if (isTransIn) transBlack.y = transGradient.y + transGradient.height;
		else transBlack.y = transGradient.y - transBlack.height;
		
		if (transGradient.y >= targetPos)
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
