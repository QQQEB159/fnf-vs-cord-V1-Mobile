package objects;

class CheckboxThingie extends FlxText
{
	public var sprTracker:FlxSprite;
	public var daValue(default, set):Bool;
	public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	
	public function new(x:Float = 0, y:Float = 0, ?checked = false)
	{
		super(x, y);
		
		this.font = Paths.font('KidpixiesRegular-p0Z1.ttf');
		
		daValue = checked;
	}
	
	override function update(elapsed:Float)
	{
		if (sprTracker != null)
		{
			setPosition(sprTracker.x + offsetX, sprTracker.y + offsetY);
			if (copyAlpha)
			{
				alpha = sprTracker.alpha;
			}
			if (sprTracker is FlxText) size = (cast sprTracker : FlxText).size;
		}
		super.update(elapsed);
	}
	
	private function set_daValue(check:Bool):Bool
	{
		text = check ? 'True' : 'False';
		return daValue = check;
	}
}
