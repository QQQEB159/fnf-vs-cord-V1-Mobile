package states.minigames.wanted.modifiers;

class IconSpeedModifier extends Modifier
{
	//
	public function getEffect():Float
	{
		return FlxG.random.float(2, 3);
	}
}
