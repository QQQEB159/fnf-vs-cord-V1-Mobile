package options;

import backend.InputFormatter;

import states.TitleState;

import flixel.FlxSubState;
import flixel.group.FlxContainer;
import flixel.FlxBasic;

import objects.FlxTextTyper;

import flixel.group.FlxContainer.FlxTypedContainer;

import states.MainMenuState;

import options.OptionsText;

import backend.StageData;

class OptionsState extends MusicBeatState
{
	public static var onPlayState:Bool = false;
	
	public static final X_PADDING = 50;
	
	public static final Y_PADDING = 30;
	
	static var curSelected:Int = 0;
	
	var canInteract:Bool = false;
	
	final options:Array<
		{
			t:String,
			d:String,
			?addSpacing:Bool,
			?optionsOnly:Bool
		}> = [
		{
			t: 'Controls',
			d: 'Change your controls.'
		},
		{
			t: 'Adjust Delay and Combo',
			d: 'Adjust the delay and combo positions on your screen.'
		},
		{
			t: 'Graphics',
			d: 'Change your graphic settings.',
			addSpacing: true
		},
		{
			t: 'Visuals and UI',
			d: 'Adjust visuals and UI.'
		},
		{
			t: 'Gameplay',
			d: 'Adjust the gameplay.'
		},
		{
			t: 'Mobile Options',
			d: 'Change Options related to Mobile or Touch Controls.',
			addSpacing: true
		},
		{
			t: 'Debug Test',
			d: 'Access developer mode features.',
			addSpacing: true,
			optionsOnly: true
		},
		{
			t: 'Menu Music',
			d: 'Change the menu music.',
			optionsOnly: true
		},
		{
			t: 'Reboot Game',
			d: 'Restart the game without closing the application.',
			addSpacing: true,
			optionsOnly: true
		},
		{
			t: 'Reset Data',
			d: 'Resets your game data (WARNING: THIS CANNOT BE UNDONE)',
			addSpacing: true,
			optionsOnly: true
		}
	];
	
	var grpOptions:FlxTypedContainer<OptionsText>;
	
	var bottom:FlxTypedContainer<FlxBasic>;
	
	var selectorBG:FlxSprite;
	
	public var description:OptionsText;
	
	function openSelectedSubstate(label:String)
	{
		if (label != "Adjust Delay and Combo") removeTouchPad();
		switch (label)
		{
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Menu Music':
				openSubState(new options.MenuMusicSettingsSubState());
			case 'Adjust Delay and Combo':
				FlxG.switchState(() -> new options.NoteOffsetState());
			case 'Mobile Options':
				openSubState(new mobile.options.MobileOptionsSubState());
			case 'Debug Test':
				openSubState(new options.DebugMenu());
			case 'Reboot Game':
				CoolUtil.setTransitionSkip(true, true);
				@:privateAccess
				MainMenuState.seenIntro = false;
				FlxG.sound.music.volume = 0;
				FlxG.sound.music.stop();
				FlxG.switchState(() -> new TitleState());
			case 'Reset Data':
				openSubState(new ResetState());
		}
	}
	
	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
		
		persistentUpdate = true;
		
		FlxG.sound.play(Paths.sound('main/settings_boot'));
		
		final topTxt = new OptionsText(X_PADDING, Y_PADDING, 0);
		add(topTxt);
		
		selectorBG = new FlxSprite().makeGraphic(1, 1, 0xFF999999);
		add(selectorBG);
		
		selectorBG.visible = false;
		
		grpOptions = new FlxTypedContainer();
		add(grpOptions);
		
		var _reference:Null<OptionsText> = null;
		for (k => i in options)
		{
			if (OptionsState.onPlayState && (i.optionsOnly == true)) continue;
			final spr = new OptionsText((X_PADDING * 2) + 4, Y_PADDING * 4, FlxG.width, i.t);
			spr.visible = false;
			
			if (_reference != null)
			{
				spr.y = _reference.y + _reference.height + (i?.addSpacing ?? false ? 22 : 0);
			}
			_reference = spr;
			grpOptions.add(spr);
		}
		
		curSelected = FlxMath.minInt(curSelected, grpOptions.members.length - 1);
		
		// bottom stuff
		
		bottom = new FlxContainer();
		add(bottom);
		bottom.visible = false;
		
		final bg = new FlxSprite(X_PADDING, FlxG.height - 35 - Y_PADDING).makeGraphic(1, 1, 0xFF999999);
		bg.scale.set(FlxG.width - (X_PADDING * 2), 35);
		bg.updateHitbox();
		bottom.add(bg);
		
		final txtL = new OptionsText(X_PADDING, bg.y + (bg.height - 22) / 2, FlxG.width, 'ENTER=Choose');
		txtL.color = FlxColor.BLACK;
		bottom.add(txtL);
		
		final txtR = new OptionsText(X_PADDING, bg.y + (bg.height - 22) / 2, FlxG.width - (X_PADDING * 2), 'ESC=Cancel');
		txtR.alignment = RIGHT;
		txtR.color = FlxColor.BLACK;
		bottom.add(txtR);
		
		description = new OptionsText(X_PADDING, bg.y - Y_PADDING - (22 * 2), FlxG.width - (X_PADDING * 2), '');
		add(description);
		
		FlxTimer.wait(#if !debug 1 #else 0 #end, () -> {
			topTxt.typer.startTyping('Choose Advanced Options for: Vs Cord\nUse the up and down arrow keys to move the highlight to your choice.');
		});
		
		topTxt.typer.onTypingComplete.addOnce(() -> typeAll());
		
		ClientPrefs.saveSettings();
		
		CoolUtil.setTransitionSkip(true, true);
		
		addTouchPad("UP_DOWN", "A_B");
		
		super.create();
	}
	
	function typeAll(customRate:Float = 1)
	{
		for (k => i in grpOptions.members)
		{
			i.visible = false;
			i.color = 0xFF999999;
			FlxTimer.wait(k * (0.15 / customRate), () -> {
				final txt = i.text;
				i.text = '';
				i.typer.startTyping(txt);
				i.visible = true;
				
				if (i == grpOptions.members[grpOptions.length - 1])
				{
					bottom.visible = true;
					changeSelection();
					canInteract = true;
				}
			});
		}
	}
	
	override function openSubState(SubState:FlxSubState)
	{
		if (SubState is BaseOptionsMenu || SubState is DebugMenu || SubState is ControlsSubState || SubState is ResetState) grpOptions.visible = selectorBG.visible = false;
		super.openSubState(SubState);
	}
	
	override function closeSubState()
	{
		if (!grpOptions.visible)
		{
			canInteract = false;
			typeAll(2);
			
			selectorBG.x = -9999; // abit cheap but it does the job
			description.typer.startTyping('');
		}
		grpOptions.visible = selectorBG.visible = true;
		super.closeSubState();
		ClientPrefs.saveSettings();
		
		controls.isInSubstate = false;
        removeTouchPad();
		addTouchPad("UP_DOWN", "A_B");
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (canInteract && grpOptions.visible)
		{
			if (controls.UI_DOWN_P || controls.UI_UP_P) changeSelection(controls.UI_DOWN_P ? 1 : -1);
			
			if (controls.BACK)
			{
				CoolUtil.playPersistentSound(Paths.sound('settingsBack'));
				if (onPlayState)
				{
					StageData.loadDirectory(PlayState.SONG);
					FlxG.switchState(() -> new PlayState());
					FlxG.sound.music.volume = 0;
					
					MusicBeatState.currentTransition = STICKERS;
				}
				else FlxG.switchState(() -> new MainMenuState());
			}
			else if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('settingsConfirm'));
				
				openSelectedSubstate(options[curSelected].t);
			}
		}
		
		if (grpOptions.members[curSelected] != null)
		{
			selectorBG.scale.set(grpOptions.members[curSelected].textField.textWidth + 8 + X_PADDING, 22);
			
			selectorBG.updateHitbox();
		}
	}
	
	function changeSelection(change:Int = 0)
	{
		if (change != 0) FlxG.sound.play(Paths.sound('settingsScroll'));
		grpOptions.members[curSelected].color = 0xFF999999;
		curSelected = FlxMath.wrap(curSelected + change, 0, grpOptions.members.length - 1);
		
		final cur = grpOptions.members[curSelected];
		cur.color = FlxColor.BLACK;
		cur.updateHitbox();
		
		selectorBG.visible = true;
		selectorBG.scale.set(cur.textField.textWidth + 8 + X_PADDING, 22);
		selectorBG.updateHitbox();
		
		selectorBG.x = cur.x - 4 - X_PADDING;
		selectorBG.y = cur.y + -2 + (cur.height - selectorBG.height) / 2;
		
		description.typer.startTyping('Description: ' + options[curSelected].d);
		
		// trace(cur.textField.textWidth);
		// trace(cur.width);
	}
	
	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}

private class ResetState extends MusicBeatSubstate
{
	var tick:Float = 0;
	
	override function create()
	{
		super.create();
		
		var bg = new FlxSprite().makeScaledGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		
		var a = InputFormatter.getKeyName(ClientPrefs.keyBinds.get('accept')[0]);
		var b = InputFormatter.getKeyName(ClientPrefs.keyBinds.get('back')[0]);
		
		final text = new OptionsText(OptionsState.X_PADDING, OptionsState.Y_PADDING, FlxG.width, 'Are you sure?\nResetting data will clear all progression and cannot be undone.\n\nPress ['
			+ a
			+ '] to Continue or ['
			+ b
			+ '] to return to menu.');
		text.color = 0xFF999999;
		add(text);
		
		addTouchPad("NONE", "A_B");
		addTouchPadCamera();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (tick > 0)
		{
			if (controls.ACCEPT)
			{
				FlxG.save.erase();
				FlxG.save.flush();
				
				ClientPrefs.data = {};
				
				ClientPrefs.resetKeys();
				
				@:privateAccess
				(cast FlxG.state : OptionsState).openSelectedSubstate('Reboot Game');
			}
			else if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('settingsBack'));
				close();
			}
		}
		
		tick += elapsed;
		tick = FlxMath.bound(tick, 0, 1);
	}
}
