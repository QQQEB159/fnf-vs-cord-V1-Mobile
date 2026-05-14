package states.minigames.wanted.modifiers;

class AdditionalIconsModifer extends Modifier
{
	public function getEffect():Int
	{
		return FlxG.random.int(10, 50);
	}
}
