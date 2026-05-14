package states;

import lime.app.Application;

import flixel.system.scaleModes.RatioScaleMode;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;

import objects.Bopper;

import states.MainMenuState;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	
	public static var initialized:Bool = false;
	
	static var FAKE_WIDTH(get, never):Int;
	
	var pStart:FlxText;
	
	override public function create():Void
	{
		Paths.clearStoredMemory();
		
		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();
		
		super.create();
		
		FlxG.mouse.visible = false;
		
		if (FlxG.save.data.flashing == null && !FlashingState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.switchState(() -> new FlashingState());
		}
		else
		{
			startIntro();
		}
	}
	
	function startIntro()
	{
		// no need to replace the scalemode instance just change its fill mode
		@:privateAccess
		(cast FlxG.scaleMode : RatioScaleMode).fillScreen = true;
		FlxG.resizeWindow(FAKE_WIDTH, backend.Native.windowHeight);
		FlxG.stage.window.resizable = false;
		
		CoolUtil.centerWindow();
		
		persistentUpdate = true;
		
		var template:Bopper = cast new Bopper().loadSparrowFrames('menuassets/main/intro');
		template.animation.addByPrefix('i', 'machine_IntroFrame0');
		template.animation.addByPrefix('out', 'machine_transitionOutIntro', 24, false);
		
		template.addOffset('i', 134, 143);
		template.addOffset('out', 141, 148);
		
		template.playAnim('i');
		add(template);
		
		pStart = new FlxText(0, 0, FlxG.width, '', 20);
		pStart.setFormat(Paths.font('title.ttf'), 20, FlxColor.WHITE, CENTER);
		pStart.text = 'PRESS START';
		pStart.screenCenter(Y);
		pStart.y += 150;
		add(pStart);
		
		Paths.clearUnusedMemory();
	}
	
	var timer:Float = 0;
	final blinkRate = 0.5;
	var previousBlink = false;
	
	var can = true;
	
	override function update(elapsed:Float)
	{
		timer += elapsed;
		
		if (((timer % blinkRate) / blinkRate > 0.5) != previousBlink)
		{
			previousBlink = !previousBlink;
			pStart.text = previousBlink ? '> PRESS START <' : 'PRESS START';
		}
		
		if (controls.ACCEPT && can)
		{
			can = false;
			FlxG.sound.play(Paths.sound('main/select'));
			
			FlxFlicker.flicker(pStart, 1, 0.05, false);
			FlxTimer.wait(1, () -> {
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				
				FlxG.switchState(() -> new MainMenuState());
			});
		}
		
		super.update(elapsed);
	}
	
	static function get_FAKE_WIDTH():Int
	{
		return Std.int(1026 * backend.Native.dpiScale);
	}
}
