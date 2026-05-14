package states.minigames.wanted.modifiers;

class FlippedModifier extends Modifier
{
	public function getEffect():Bool
	{
		return FlxG.random.bool();
	}
}
