package plugins;

import flixel.FlxBasic;

class AchievementTestPlugin extends FlxBasic
{
	static var instance:Null<AchievementTestPlugin> = null;
	
	public static function init()
	{
		if (instance == null) FlxG.plugins.addPlugin(instance = new AchievementTestPlugin());
	}
	
	private function new()
	{
		super();
		visible = false;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (FlxG.keys.pressed.F8)
		{
			for (k => i in Achievements.achievements)
			{
				Achievements.unlock(k);
			}
			// if (FlxG.keys.justPressed.A) Achievements.unlock('blueBalled10');
			// if (FlxG.keys.justPressed.D) Achievements.unlock('miss100');
			// if (FlxG.keys.justPressed.F) Achievements.unlock('menuMusic');
			// if (FlxG.keys.justPressed.G) Achievements.unlock('cordFC');
		}
	}
}
