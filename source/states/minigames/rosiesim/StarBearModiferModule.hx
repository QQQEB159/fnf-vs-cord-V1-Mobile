package states.minigames.rosiesim;

import Init.RosieClickerCursor;

import flixel.FlxBasic;

enum abstract ConnectionStatus(Int)
{
	var CONNECTED;
	var DISCONNECTED;
}

@:access(states.minigames.RosieSimV2)
class StarBearModifierModule extends FlxBasic
{
	public var connectionStatus(default, null):ConnectionStatus = DISCONNECTED;
	
	public function getCore():RosieSimV2
	{
		return cast FlxG.state;
	}
	
	public function new()
	{
		super();
		this.visible = false;
	}
	
	public function connect()
	{
		connectionStatus = CONNECTED;
		
		getCore().backgroundGradient.loadGraphic(Paths.image('minigames/rosieclicker/bg-star'));
		getCore().tiledPattern.loadGraphic(Paths.image('minigames/rosieclicker/patternAlpha25Multiply-star'));
	}
	
	public function disconnect()
	{
		connectionStatus = DISCONNECTED;
		getCore().backgroundGradient.loadGraphic(Paths.image('minigames/rosieclicker/bg'));
		getCore().tiledPattern.loadGraphic(Paths.image('minigames/rosieclicker/patternAlpha25Multiply'));
		FlxG.camera.flash();
		
		trace('disconnected??');
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		updateModule(elapsed);
	}
	
	function updateModule(elapsed:Float)
	{
		if (connectionStatus == CONNECTED)
		{
			Conductor.songPosition += 1000 * elapsed * FlxG.sound.music.pitch;
			
			var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);
			
			var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
			final curStep = lastChange.stepTime + Math.floor(shit);
			
			curBeat = Math.floor(curStep / 4);
			
			if (curStep % 4 == 0)
			{
				// curBeat++;
				if (curBeat != lastBeat)
				{
					bump();
				}
			}
		}
	}
	
	var lastBeat:Int = 0;
	var curBeat:Int = 0;
	
	var toggle:Bool = false;
	
	function bump()
	{
		lastBeat = curBeat;
		toggle = !toggle;
		
		var rosie = getCore().rosie;
		@:privateAccess
		if (rosie.spinTwn == null || !rosie.spinTwn.active) rosie.angle = toggle ? 5 : -8;
		FlxTween.tween(rosie,
			{
				y: rosie.getDefaultCamera().viewTop + (rosie.getDefaultCamera().viewHeight - rosie.height) / 2 - 50
			}, Conductor.stepCrochet / 1000 * FlxG.sound.music.pitch,
			{
				ease: FlxEase.sineOut,
				onComplete: Void -> {
					FlxTween.tween(getCore().rosie, {
						y: rosie.getDefaultCamera().viewTop + (rosie.getDefaultCamera().viewHeight - rosie.height) / 2
					}, Conductor.stepCrochet / 1000 * FlxG.sound.music.pitch, {ease: FlxEase.sineIn});
				}
			});
	}
	
	public static function isStarPlush(outfit:Outfit):Bool
	{
		return outfit == STARBEAR;
	}
}
