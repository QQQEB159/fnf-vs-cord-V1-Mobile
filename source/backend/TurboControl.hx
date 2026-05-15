package backend;

import flixel.FlxBasic;

class TurboControl extends FlxBasic
{
	public var buttons:Null<Array<Int>> = null;
	public var mobileButtons:Null<Array<Int>> = null;
	public var keys:Array<Int>;
	public var rate:Float = 0.1;
	public var initialDelay:Float = 0.5;
	
	var _pressedElapsed:Float = 0;
	
	var _pressed:Bool = false;
	
	public function new(keys:Array<Int>, rate:Float = 0.1)
	{
		super();
		this.keys = keys;
		this.rate = rate;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var isPressing = false;
		if (buttons != null)
		{
			for (button in buttons)
			{
				if (!isPressing && FlxG.gamepads.anyPressed(button))
				{
					isPressing = true;
					break;
				}
			}
		}
		
		if (mobileButtons != null)
		{
			for (mobileButton in mobileButtons)
			{
				if (!isPressing && MobileInputManager.instance != null && MobileInputManager.instance.exists && MobileInputManager.instance.buttonPressed(mobileButton))
				{
					isPressing = true;
					break;
				}
			}
		}
		
		if (!isPressing) isPressing = FlxG.keys.anyPressed(keys);
		
		if (isPressing)
		{
			if (_pressedElapsed == 0)
			{
				_pressed = true;
			}
			else if (_pressedElapsed > (initialDelay + rate))
			{
				_pressed = true;
				_pressedElapsed -= rate;
			}
			else
			{
				_pressed = false;
			}
			
			_pressedElapsed += elapsed;
		}
		else
		{
			_pressedElapsed = 0;
			_pressed = false;
		}
	}
	
	public var PRESSED(get, never):Bool;
	
	function get_PRESSED():Bool
	{
		return _pressed;
	}
	
	public static function fromControl(action:String, rate:Float = 0.1)
	{
		var keys = ClientPrefs.keyBinds.get(action);
		if (keys == null) throw 'what. $action keybinds doesnt exist.';
		
		var instance = new TurboControl(keys, rate);
		
		instance.buttons = ClientPrefs.gamepadBinds.get(action);
		instance.mobileButtons = ClientPrefs.mobileBinds.get(action);
		
		return instance;
	}
}