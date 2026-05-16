package options;

import flixel.input.keyboard.FlxKey;

import backend.InputFormatter;

class DebugMenu extends MusicBeatSubstate
{
	final MAX_LENGTH:Int = 939;
	var typingTxt:OptionsText;
	
	var cursor:FlxSprite;
	
	var cursorTimer:Float = 0;
	
	var canType:Bool = false;
	
	override function create()
	{
		super.create();
		
		// super();
		
		var txt = new OptionsText(OptionsState.X_PADDING, OptionsState.Y_PADDING * 3, 0, 'Enter Code:');
		add(txt);
		
		typingTxt = new OptionsText(OptionsState.X_PADDING, OptionsState.Y_PADDING * 4, FlxG.width - (OptionsState.X_PADDING * 2), '');
		add(typingTxt);
		
		cursor = new FlxSprite().makeGraphic(16, 22, 0xFF999999);
		add(cursor);
		
		(cast FlxG.state : OptionsState).description.typer.startTyping('For testing purposes only.');
		
		FlxTimer.wait(0.1, () -> {
			canType = true;
		}); // just to be safe
		
		addTouchPad("NONE", "B");
		addTouchPadCamera();
	}
	
	var holdBackTime:Float = 0;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (canType)
		{
			if (typingTxt.text.length == 0 && controls.BACK)
			{
				FlxG.sound.play(Paths.sound('settingsBack'));
				close();
			}
			
			final key:FlxKey = FlxG.keys.firstJustPressed();
			
			if (key != -1)
			{
				FlxG.sound.play(Paths.sound('main/txtblip'));
				// abit more manual
				switch (key)
				{
					case NUMPADZERO | NUMPADONE | NUMPADTWO | NUMPADTHREE | NUMPADFOUR | NUMPADFIVE | NUMPADSIX | NUMPADSEVEN | NUMPADEIGHT | NUMPADNINE | NUMPADMINUS | NUMPADPLUS | NUMPADMULTIPLY | NUMPADPERIOD:
						var txt = InputFormatter.getKeyName(key);
						typingTxt.text += txt.substr(1);
						
					case ESCAPE:
						// ?
					case SLASH | NUMPADSLASH:
						typingTxt.text += '/';
					case BACKSLASH:
						typingTxt.text += '\\';
					case SPACE:
						typingTxt.text += ' ';
					case ENTER:
						final txt = typingTxt.text;
						typingTxt.text = '';
						
						entered(txt);
					case PERIOD:
						typingTxt.text += '.';
					case BACKSPACE:
						typingTxt.text = typingTxt.text.substring(0, typingTxt.text.length - 1);
						holdBackTime = -0.5;
					// exclusions
					case TAB | CAPSLOCK | SHIFT | CONTROL | ALT | DELETE | HOME | END | PAGEDOWN | PAGEUP | NUMLOCK | WINDOWS | LEFT | DOWN | UP | RIGHT:
					default:
						typingTxt.text += InputFormatter.getKeyName(key);
				}
				if (typingTxt.text.length > MAX_LENGTH) typingTxt.text = typingTxt.text.substring(0, MAX_LENGTH);
			}
			
			if (FlxG.keys.pressed.BACKSPACE)
			{
				holdBackTime += elapsed;
				
				if (holdBackTime > 0 && ((holdBackTime % 0.4) / 0.4 > 0.5) && typingTxt.text.length > 0)
				{
					typingTxt.text = typingTxt.text.substring(0, typingTxt.text.length - 1);
				}
			}
		}
		
		cursorTimer += elapsed;
		
		cursor.visible = (cursorTimer % 0.5) / 0.5 > 0.5;
		
		// abit scuffed
		cursor.x = typingTxt.x + (typingTxt.text.length > 0 ? (typingTxt.textField.getLineLength(typingTxt.textField.numLines - 1) * 15) : 0);
		cursor.y = typingTxt.y + (18 * (typingTxt.textField.numLines - 1));
	}
	
	function entered(txt:String)
	{
		if (txt.length == MAX_LENGTH || txt.toLowerCase() == 'pneumonoultramicroscopicsilicovolcanoconiosis')
		{
			canType = false;
			typingTxt.text = 'fuck you';
			
			FlxG.state.forEach(b -> b.visible = false);
			forEach(b -> b.visible = false);
			cursor.alpha = 0;
			
			typingTxt.visible = true;
			
			typingTxt.alignment = CENTER;
			typingTxt.screenCenter(Y);
			
			FlxTimer.wait(2, FlxG.stage.window.close);
			return;
		}
		
		var songToLoad:String = null;
		switch (txt.toLowerCase())
		{
			case 'penkaru':
				#if DISCORD_ALLOWED
				if (DiscordClient.userID != "318841033322528769") return;
				#end
				canType = false;
				
				FlxG.state.forEach(b -> b.visible = false);
				forEach(b -> b.visible = false);
				cursor.alpha = 0;
				
				var pen = new FlxSprite().loadGraphic(Paths.image('menuassets/secret/pen'));
				add(pen);
				
				pen.setGraphicSize(300);
				pen.updateHitbox();
				pen.screenCenter();
				pen.x -= (pen.width / 2) + 150;
				pen.alpha = 0;
				
				var hi = new FlxText(0, 0, 0, 'hi ', 280);
				hi.setFormat(Paths.font('ITCEDSCR.TTF'), 280);
				add(hi);
				hi.screenCenter();
				hi.x += (hi.width / 2) + 150;
				hi.alpha = 0;
				
				FlxTween.tween(pen, {alpha: 1}, 2, {startDelay: 1});
				
				FlxTween.tween(hi, {alpha: 1}, 2, {startDelay: 2});
				
				FlxTimer.wait(3, () -> {
					FlxG.sound.play(Paths.sound('hiPenkaru'));
				});
				
				FlxTimer.wait(6, () -> {
					FlxG.state.forEach(b -> b.visible = true);
					close();
				});
				
			case 'pico':
				songToLoad = 'pico';
				
			case 'packman':
				songToLoad = 'packman';
				
			case 'confident':
				songToLoad = 'confident';
				
			case 'wanted':
				canType = false;
				FlxG.switchState(() -> new states.minigames.FindCord());
				FlxG.sound.music.volume = 0;
			case 'clicking':
				canType = false;
				FlxG.switchState(() -> new states.minigames.RosieSimV2());
				FlxG.sound.music.volume = 0;
				
			case 'pooo':
				for (i in 0...MAX_LENGTH)
					typingTxt.text += '$i';
		}
		if (songToLoad != null)
		{
			canType = false;
			Difficulty.resetList();
			
			final formattedSong:String = Paths.formatToSongPath(songToLoad);
			final diffFormatted:String = backend.Highscore.formatSong(formattedSong, 1);
			
			PlayState.SONG = backend.Song.loadFromJson(diffFormatted, formattedSong);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 0;
			Difficulty.list = ['Normal'];
			
			LoadingState.loadAndSwitchState(() -> new PlayState());
			
			FlxG.sound.music.volume = 0;
		}
	}
}
