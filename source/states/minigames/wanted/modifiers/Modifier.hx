package states.minigames.wanted.modifiers;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

// this method is over engineered but idc i dont want modifier code in the findcord class
abstract class Modifier implements IFlxDestroyable
{
	public function new() {}
	
	abstract public function getEffect():Any;
	
	public function getModScore():Int
	{
		throw "oh ok";
	}
	
	public function destroy() {}
}
