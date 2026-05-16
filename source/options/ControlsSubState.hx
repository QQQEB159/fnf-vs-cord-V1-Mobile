package options;

import backend.InputFormatter;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

// most of these values arent used probably should clean it up later i just did it so it was a easier migration
private class ControlsOptionsText extends OptionsText
{
	public var blockSizeAdd:FlxPoint = new FlxPoint();
	public var blockOffset:FlxPoint = new FlxPoint();
	
	public final bgBlock:FlxSprite;
	public var isActive:Bool = false;
	
	public var isMenuItem:Bool = false;
	public var targetY:Int = 0;
	public var changeX:Bool = true;
	public var changeY:Bool = true;
	
	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0); // for the calculations
	
	public function new(x:Float = 0, y:Float = 0, txt:String)
	{
		super(x, y, 0, txt);
		
		startPosition.set(x, y);
		
		bgBlock = new FlxSprite().makeGraphic(1, 1, 0xFF999999);
	}
	
	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var lerpVal:Float = FlxMath.bound(elapsed * 9.6, 0, 1);
			if (changeX) x = FlxMath.lerp(x, (targetY * distancePerItem.x) + startPosition.x, lerpVal);
			if (changeY) y = FlxMath.lerp(y, (targetY * 1.3 * distancePerItem.y) + startPosition.y, lerpVal);
		}
		super.update(elapsed);
		
		bgBlock.scale.set(width + 8 + blockSizeAdd.x, 22 + blockSizeAdd.y);
		bgBlock.updateHitbox();
		bgBlock.x = x - 4 + blockOffset.x;
		bgBlock.y = y - 2 + blockOffset.y;
		
		color = isActive ? FlxColor.BLACK : 0xFF999999;
	}
	
	override function draw()
	{
		if (isActive) bgBlock.draw();
		super.draw();
	}
	
	override function destroy()
	{
		bgBlock.destroy();
		super.destroy();
	}
	
	public function snapToPosition()
	{
		if (isMenuItem)
		{
			if (changeX) x = (targetY * distancePerItem.x) + startPosition.x;
			if (changeY) y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
		}
	}
}

class ControlsSubState extends MusicBeatSubstate
{
	var curSelected:Int = 0;
	var curAlt:Bool = false;
	
	// Show on gamepad - Display name - Save file key - Rebind display name
	var options:Array<Dynamic> = [
		[true, 'NOTES'],
		[true, 'Left', 'note_left', 'Note Left'],
		[true, 'Down', 'note_down', 'Note Down'],
		[true, 'Up', 'note_up', 'Note Up'],
		[true, 'Right', 'note_right', 'Note Right'],
		[true, 'UI'],
		[true, 'Left', 'ui_left', 'UI Left'],
		[true, 'Down', 'ui_down', 'UI Down'],
		[true, 'Up', 'ui_up', 'UI Up'],
		[true, 'Right', 'ui_right', 'UI Right'],
		[true, 'Reset', 'reset', 'Reset'],
		[true, 'Accept', 'accept', 'Accept'],
		[true, 'Back', 'back', 'Back'],
		[true, 'Pause', 'pause', 'Pause'],
		[false, 'VOLUME'],
		[false, 'Mute', 'volume_mute', 'Volume Mute'],
		[false, 'Up', 'volume_up', 'Volume Up'],
		[false, 'Down', 'volume_down', 'Volume Down'],
		[false, 'DEBUG'],
		[false, 'Key 1', 'debug_1', 'Debug Key #1'],
		[false, 'Key 2', 'debug_2', 'Debug Key #2']
	];
	var curOptions:Array<Int>;
	var curOptionsValid:Array<Int>;
	
	static var defaultKey:String = 'Reset to Default Keys';
	
	var grpDisplay:FlxTypedGroup<ControlsOptionsText>;
	var grpOptions:FlxTypedGroup<ControlsOptionsText>;
	var grpBinds:FlxTypedGroup<ControlsOptionsText>;
	
	var onKeyboardMode:Bool = true;
	
	var controllerModeTxt:ControlsOptionsText;
	
	public function new()
	{
		super();
		
		options.push([true]);
		options.push([true]);
		options.push([true, defaultKey]);
		
		grpDisplay = new FlxTypedGroup<ControlsOptionsText>();
		add(grpDisplay);
		grpOptions = new FlxTypedGroup<ControlsOptionsText>();
		add(grpOptions);
		grpBinds = new FlxTypedGroup<ControlsOptionsText>();
		add(grpBinds);
		
		controllerModeTxt = new ControlsOptionsText(OptionsState.X_PADDING, OptionsState.Y_PADDING * 3, 'MODE: '
			+ (onKeyboardMode ? 'KEYBOARD' : 'CONTROLLER')
			+ ' : PRESS CTRL TO CHANGE MODE');
		add(controllerModeTxt);
		
		createTexts();
		
		(cast FlxG.state : OptionsState).description.typer.startTyping('');
		
		addTouchPad("NONE", "B");
	}
	
	var lastID:Int = 0;
	
	function createTexts()
	{
		curOptions = [];
		curOptionsValid = [];
		grpDisplay.forEachAlive(function(text:ControlsOptionsText) text.destroy());
		grpOptions.forEachAlive(function(text:ControlsOptionsText) text.destroy());
		grpBinds.forEachAlive(function(text:ControlsOptionsText) text.destroy());
		grpDisplay.clear();
		grpOptions.clear();
		grpBinds.clear();
		
		var myID:Int = 0;
		for (i in 0...options.length)
		{
			var option:Array<Dynamic> = options[i];
			if (option[0] || onKeyboardMode)
			{
				if (option.length > 1)
				{
					var isCentered:Bool = (option.length < 3);
					var isDefaultKey:Bool = (option[1] == defaultKey);
					var isDisplayKey:Bool = (isCentered && !isDefaultKey);
					
					var text:ControlsOptionsText = new ControlsOptionsText(OptionsState.X_PADDING * 2, (OptionsState.Y_PADDING * 4) + (22 * i), option[1]);
					text.targetY = myID;
					if (isDisplayKey) grpDisplay.add(text);
					else
					{
						if (!isCentered)
						{
							text.blockSizeAdd.x = OptionsState.X_PADDING;
							text.blockOffset.x = -OptionsState.X_PADDING;
						}
						
						grpOptions.add(text);
						curOptions.push(i);
						curOptionsValid.push(myID);
					}
					text.ID = myID;
					lastID = myID;
					
					if (isCentered) addCenteredText(text, option, myID);
					else addKeyText(text, option, myID);
				}
				myID++;
			}
		}
		updateText();
	}
	
	function addCenteredText(text:ControlsOptionsText, option:Array<Dynamic>, id:Int) // lies
	{
		text.x = OptionsState.X_PADDING;
		text.blockSizeAdd.x += OptionsState.X_PADDING;
	}
	
	function addKeyText(text:ControlsOptionsText, option:Array<Dynamic>, id:Int)
	{
		for (n in 0...2)
		{
			var textX:Float = 150 + n * 250;
			
			var key:String = null;
			if (onKeyboardMode)
			{
				var savKey:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get(option[2]);
				key = InputFormatter.getKeyName((savKey[n] != null) ? savKey[n] : NONE);
			}
			else
			{
				var savKey:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(option[2]);
				key = InputFormatter.getGamepadName((savKey[n] != null) ? savKey[n] : NONE);
			}
			
			var attach:ControlsOptionsText = new ControlsOptionsText(textX + 210, text.y, n == 1 ? '/ $key' : key);
			attach.targetY = text.targetY;
			attach.ID = Math.floor(grpBinds.length / 2);
			
			grpBinds.add(attach);
		}
	}
	
	function updateBind(num:Int, text:String)
	{
		var bind:ControlsOptionsText = grpBinds.members[num];
		var attach:ControlsOptionsText = new ControlsOptionsText(150 + (num % 2) * 250, bind.y, bind.text.contains('/ ') ? '/ $text' : text);
		attach.targetY = bind.targetY;
		attach.ID = bind.ID;
		attach.x = bind.x;
		attach.y = bind.y;
		
		bind.kill();
		grpBinds.remove(bind);
		grpBinds.insert(num, attach);
		bind.destroy();
		
		updateAlt();
	}
	
	var binding:Bool = false;
	var holdingEsc:Float = 0;
	var bindingBlack:FlxSprite;
	var bindingText:ControlsOptionsText;
	var bindingText2:ControlsOptionsText;
	
	var timeForMoving:Float = 0.1;
	
	override function update(elapsed:Float)
	{
		if (timeForMoving > 0) // Fix controller bug
		{
			timeForMoving = Math.max(0, timeForMoving - elapsed);
			super.update(elapsed);
			return;
		}
		
		if (!binding)
		{
			if (controls.BACK || FlxG.gamepads.anyJustPressed(B))
			{
				close();
				return;
			}
			if (FlxG.keys.justPressed.CONTROL
				|| FlxG.gamepads.anyJustPressed(LEFT_SHOULDER)
				|| FlxG.gamepads.anyJustPressed(RIGHT_SHOULDER)) swapMode();
				
			if (FlxG.keys.justPressed.LEFT
				|| FlxG.keys.justPressed.RIGHT
				|| FlxG.gamepads.anyJustPressed(DPAD_LEFT)
				|| FlxG.gamepads.anyJustPressed(DPAD_RIGHT)
				|| FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_LEFT)
				|| FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_RIGHT)) updateAlt(true);
				
			if (FlxG.keys.justPressed.UP
				|| FlxG.gamepads.anyJustPressed(DPAD_UP)
				|| FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_UP)) updateText(-1);
			else if (FlxG.keys.justPressed.DOWN
				|| FlxG.gamepads.anyJustPressed(DPAD_DOWN)
				|| FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_DOWN)) updateText(1);
				
			if (FlxG.keys.justPressed.ENTER || FlxG.gamepads.anyJustPressed(START) || FlxG.gamepads.anyJustPressed(A))
			{
				if (options[curOptions[curSelected]][1] != defaultKey)
				{
					// i dont like this do smth different later
					bindingBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
					bindingBlack.scale.set(FlxG.width, FlxG.height);
					bindingBlack.updateHitbox();
					bindingBlack.alpha = 1;
					add(bindingBlack);
					
					bindingText = new ControlsOptionsText(0, 160, "Rebinding " + options[curOptions[curSelected]][3]);
					bindingText.fieldWidth = FlxG.width;
					bindingText.alignment = CENTER;
					add(bindingText);
					
					bindingText2 = new ControlsOptionsText(0, 340, "Hold ESC to Cancel\nHold Backspace to Delete");
					bindingText2.fieldWidth = FlxG.width;
					bindingText2.alignment = CENTER;
					add(bindingText2);
					
					binding = true;
					holdingEsc = 0;
					ClientPrefs.toggleVolumeKeys(false);
					FlxG.sound.play(Paths.sound('settingsScroll'));
				}
				else
				{
					// Reset to Default
					ClientPrefs.resetKeys(!onKeyboardMode);
					ClientPrefs.reloadVolumeKeys();
					var lastSel:Int = curSelected;
					createTexts();
					curSelected = lastSel;
					updateText();
					FlxG.sound.play(Paths.sound('settingsBack'));
				}
			}
		}
		else
		{
			var altNum:Int = curAlt ? 1 : 0;
			var curOption:Array<Dynamic> = options[curOptions[curSelected]];
			if (FlxG.keys.pressed.ESCAPE || FlxG.gamepads.anyPressed(B))
			{
				holdingEsc += elapsed;
				if (holdingEsc > 0.5)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					closeBinding();
				}
			}
			else if (FlxG.keys.pressed.BACKSPACE || FlxG.gamepads.anyPressed(BACK))
			{
				holdingEsc += elapsed;
				if (holdingEsc > 0.5)
				{
					ClientPrefs.keyBinds.get(curOption[2])[altNum] = NONE;
					ClientPrefs.clearInvalidKeys(curOption[2]);
					updateBind(Math.floor(curSelected * 2) + altNum, onKeyboardMode ? InputFormatter.getKeyName(NONE) : InputFormatter.getGamepadName(NONE));
					FlxG.sound.play(Paths.sound('cancelMenu'));
					closeBinding();
				}
			}
			else
			{
				holdingEsc = 0;
				var changed:Bool = false;
				var curKeys:Array<FlxKey> = ClientPrefs.keyBinds.get(curOption[2]);
				var curButtons:Array<FlxGamepadInputID> = ClientPrefs.gamepadBinds.get(curOption[2]);
				
				if (onKeyboardMode)
				{
					if (FlxG.keys.justPressed.ANY || FlxG.keys.justReleased.ANY)
					{
						var keyPressed:Int = FlxG.keys.firstJustPressed();
						var keyReleased:Int = FlxG.keys.firstJustReleased();
						if (keyPressed > -1 && keyPressed != FlxKey.ESCAPE && keyPressed != FlxKey.BACKSPACE)
						{
							curKeys[altNum] = keyPressed;
							changed = true;
						}
						else if (keyReleased > -1 && (keyReleased == FlxKey.ESCAPE || keyReleased == FlxKey.BACKSPACE))
						{
							curKeys[altNum] = keyReleased;
							changed = true;
						}
					}
				}
				else if (FlxG.gamepads.anyJustPressed(ANY)
					|| FlxG.gamepads.anyJustPressed(LEFT_TRIGGER)
					|| FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER)
					|| FlxG.gamepads.anyJustReleased(ANY))
				{
					var keyPressed:Null<FlxGamepadInputID> = NONE;
					var keyReleased:Null<FlxGamepadInputID> = NONE;
					if (FlxG.gamepads.anyJustPressed(LEFT_TRIGGER)) keyPressed = LEFT_TRIGGER; // it wasnt working for some reason
					else if (FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER)) keyPressed = RIGHT_TRIGGER; // it wasnt working for some reason
					else
					{
						for (i in 0...FlxG.gamepads.numActiveGamepads)
						{
							var gamepad:FlxGamepad = FlxG.gamepads.getByID(i);
							if (gamepad != null)
							{
								keyPressed = gamepad.firstJustPressedID();
								keyReleased = gamepad.firstJustReleasedID();
								
								if (keyPressed == null) keyPressed = NONE;
								if (keyReleased == null) keyReleased = NONE;
								if (keyPressed != NONE || keyReleased != NONE) break;
							}
						}
					}
					
					if (keyPressed != NONE && keyPressed != FlxGamepadInputID.BACK && keyPressed != FlxGamepadInputID.B)
					{
						curButtons[altNum] = keyPressed;
						changed = true;
					}
					else if (keyReleased != NONE && (keyReleased == FlxGamepadInputID.BACK || keyReleased == FlxGamepadInputID.B))
					{
						curButtons[altNum] = keyReleased;
						changed = true;
					}
				}
				
				if (changed)
				{
					if (onKeyboardMode)
					{
						if (curKeys[altNum] == curKeys[1 - altNum]) curKeys[1 - altNum] = FlxKey.NONE;
					}
					else
					{
						if (curButtons[altNum] == curButtons[1 - altNum]) curButtons[1 - altNum] = FlxGamepadInputID.NONE;
					}
					
					var option:String = options[curOptions[curSelected]][2];
					ClientPrefs.clearInvalidKeys(option);
					for (n in 0...2)
					{
						var key:String = null;
						if (onKeyboardMode)
						{
							var savKey:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get(option);
							key = InputFormatter.getKeyName(savKey[n] != null ? savKey[n] : NONE);
						}
						else
						{
							var savKey:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(option);
							key = InputFormatter.getGamepadName(savKey[n] != null ? savKey[n] : NONE);
						}
						updateBind(Math.floor(curSelected * 2) + n, key);
					}
					FlxG.sound.play(Paths.sound('settingsConfirm'));
					closeBinding();
				}
			}
		}
		super.update(elapsed);
	}
	
	function closeBinding()
	{
		binding = false;
		bindingBlack.destroy();
		remove(bindingBlack);
		
		bindingText.destroy();
		remove(bindingText);
		
		bindingText2.destroy();
		remove(bindingText2);
		ClientPrefs.reloadVolumeKeys();
	}
	
	function updateText(?move:Int = 0)
	{
		if (move != 0)
		{
			curSelected += move;
			
			if (curSelected < 0) curSelected = curOptions.length - 1;
			else if (curSelected >= curOptions.length) curSelected = 0;
		}
		
		var num:Int = curOptionsValid[curSelected];
		var addNum:Int = 0;
		if (num < 3) addNum = 3 - num;
		else if (num > lastID - 4) addNum = (lastID - 4) - num;
		
		grpDisplay.forEachAlive(function(item:ControlsOptionsText) {
			item.targetY = item.ID - num - addNum;
		});
		
		grpOptions.forEachAlive(function(item:ControlsOptionsText) {
			item.targetY = item.ID - num - addNum;
			
			item.isActive = item.ID - num == 0;
		});
		grpBinds.forEachAlive(function(item:ControlsOptionsText) {
			var parent:ControlsOptionsText = grpOptions.members[item.ID];
			item.targetY = parent.targetY;
			
			item.isActive = false;
		});
		
		updateAlt();
		FlxG.sound.play(Paths.sound('settingsScroll'));
	}
	
	function swapMode()
	{
		onKeyboardMode = !onKeyboardMode;
		
		controllerModeTxt.text = 'MODE: ' + (onKeyboardMode ? 'KEYBOARD' : 'CONTROLLER') + ' : PRESS CTRL TO CHANGE MODE';
		
		curSelected = 0;
		curAlt = false;
		createTexts();
	}
	
	function updateAlt(?doSwap:Bool = false)
	{
		final oldHook = grpBinds.members[Math.floor(curSelected * 2) + (curAlt ? 1 : 0)];
		if (oldHook != null)
		{
			oldHook.isActive = false;
		}
		
		if (doSwap)
		{
			curAlt = !curAlt;
			FlxG.sound.play(Paths.sound('settingsScroll'));
		}
		
		final hook = grpBinds.members[Math.floor(curSelected * 2) + (curAlt ? 1 : 0)];
		if (hook != null)
		{
			hook.isActive = true;
		}
	}
}
