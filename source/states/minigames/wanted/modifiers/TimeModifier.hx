package states.minigames.wanted.modifiers;

class TimeModifier extends Modifier
{
	public var time:Int = -10;
	
	public function new(?time:Int)
	{
		super();
		this.time = time ?? this.time; // im actually getting really tempted to write a macro help
	}
	
	public function getEffect():Int
	{
		return time;
	}
	
	override function getModScore():Int
	{
		// i dont know how to value this..
		return Math.round(FlxMath.lerp(100, 500, FlxMath.remapToRange(Math.abs(time), 5, 10, 0, 1)));
	}
}
