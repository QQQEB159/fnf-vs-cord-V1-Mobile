package states.minigames.rosiesim;

import states.minigames.rosiesim.StarBearModiferModule.StarBearModifierModule;

@:access(states.minigames.RosieSimV2)
class NolimeModifierModule extends StarBearModifierModule
{
	override function connect()
	{
		connectionStatus = CONNECTED;
		
		getCore().backgroundGradient.loadGraphic(Paths.image('minigames/rosieclicker/bg-nolime'));
		getCore().tiledPattern.loadGraphic(Paths.image('minigames/rosieclicker/patternAlpha25Multiply-nolime'));
	}
	
	override function disconnect()
	{
		connectionStatus = DISCONNECTED;
		getCore().backgroundGradient.loadGraphic(Paths.image('minigames/rosieclicker/bg'));
		getCore().tiledPattern.loadGraphic(Paths.image('minigames/rosieclicker/patternAlpha25Multiply'));
		FlxG.camera.flash();
		
		trace('disconnected??');
	}
	
	override function updateModule(elapsed:Float)
	{
		// super.updateModule(elapsed);
	}
	
	public static function isNolime(outfit:Outfit):Bool
	{
		return outfit == NOLIME;
	}
}
