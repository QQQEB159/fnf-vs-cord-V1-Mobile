package states;

import backend.Native;

import flixel.system.scaleModes.RatioScaleMode;
import flixel.addons.transition.FlxTransitionableState;

class CopyrightState extends MusicBeatState
{
	var options:Array<FlxText> = [];
	var canInteract:Bool = true;
	var sel:Bool = false;
	
	static final FAKE_WIDTH:Int = 1026;
	
	override function create()
	{
		super.create();
		
		// no need to replace the scalemode instance just change its fill mode
		@:privateAccess
		(cast FlxG.scaleMode : RatioScaleMode).fillScreen = true;
		FlxG.resizeWindow(Std.int(FAKE_WIDTH * Native.dpiScale), Native.windowHeight);
		FlxG.stage.window.resizable = false;
		
		CoolUtil.centerWindow();
		
		var direct = 'Hey!\n\n\nThis Mod contains slight copyrighted audio in some sections.\n\n\nWould you like to turn on Streamer Mode?\n(This option can be disabled in settings later)';
		
		var message = new FlxText(250 / 2, 150, FlxG.width - 250, direct, 18);
		message.font = Paths.font('PixelOperator8.ttf');
		message.alignment = CENTER;
		
		add(message);
		
		var option = new FlxText(0, message.y + message.height + 25, 220, '> No <', message.size + 4);
		option.font = message.font;
		option.alignment = CENTER;
		add(option);
		options.push(option);
		
		option.screenCenter(X);
		option.x -= option.width / 2;
		
		var option = new FlxText(0, message.y + message.height + 25, 220, 'Yes', message.size + 4);
		option.font = message.font;
		option.alignment = CENTER;
		
		add(option);
		options.push(option);
		
		option.screenCenter(X);
		option.x += option.width / 2;
		
		var drawing = new FlxSprite(Paths.image('menuassets/demonetized'));
		add(drawing);
		drawing.screenCenter(X);
		
		drawing.y = FlxG.height - drawing.height - 80;
		
		addTouchPad("LEFT_RIGHT", "A");
		addTouchPadCamera();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (canInteract)
		{
			if (controls.ACCEPT)
			{
				canInteract = false;
				ClientPrefs.data.streamerMode = sel;
				// ClientPrefs.saveSettings();
				
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.switchState(() -> new TitleState());
			}
			
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('main/txtblip'));
				sel = !sel;
				
				if (!sel)
				{
					options[0].text = '> No <';
					options[1].text = 'Yes';
				}
				else
				{
					options[0].text = 'No';
					options[1].text = '> Yes <';
				}
			}
		}
	}
}
