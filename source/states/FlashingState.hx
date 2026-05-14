package states;

import flixel.FlxSubState;
import flixel.effects.FlxFlicker;

import lime.app.Application;

import flixel.addons.transition.FlxTransitionableState;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;
	
	var warnText:FlxText;
	
	override function create()
	{
		super.create();
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		
		warnText = new FlxText(0, 0, FlxG.width, "This Mod contains flashing lights in certain sections\n(seriously).\n\nPress ENTER to disable them now\n\nPress ESCAPE to ignore this message.\n\n(This can be changed in the options menu anytime)\nProceed with caution!", 18);
		warnText.setFormat(Paths.font('PixelOperator8.ttf'), 18, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}
	
	override function update(elapsed:Float)
	{
		if (!leftState)
		{
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back)
			{
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if (!back)
				{
					ClientPrefs.data.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('main/txtblip'));
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(1, function(tmr:FlxTimer) {
							FlxG.switchState(() -> new TitleState());
							
							ClientPrefs.saveSettings();
						});
					});
				}
				else
				{
					ClientPrefs.data.flashing = true;
					ClientPrefs.saveSettings();
					
					FlxG.sound.play(Paths.sound('main/txtblip'));
					FlxTween.tween(warnText, {alpha: 0}, 1,
						{
							onComplete: function(twn:FlxTween) {
								FlxG.switchState(() -> new TitleState());
							}
						});
				}
			}
		}
		super.update(elapsed);
	}
}
