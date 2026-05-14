package states.minigames.wanted.modifiers;

import flixel.system.FlxAssets.FlxShader;

import shaders.ColorSwap;

class GreyScaleModifier extends Modifier
{
	var greyShader:ColorSwap;
	
	public function new()
	{
		//
		super();
		greyShader = new ColorSwap();
		greyShader.saturation = -1;
	}
	
	public function getEffect():FlxShader
	{
		return greyShader.shader;
	}
	
	override function destroy()
	{
		greyShader = null;
		super.destroy();
	}
}
