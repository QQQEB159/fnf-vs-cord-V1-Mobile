package options;

import objects.FlxTextTyper;

class OptionsText extends FlxText
{
	public final typer:FlxTextTyper;
	
	public var parent:OptionsText;
	
	public function new(x:Float = 0, y:Float = 0, fw:Float = 0, txt:String = '', size:Int = 18)
	{
		typer = new FlxTextTyper();
		typer.delay = CONST(0.01);
		typer.onChange.add(_updateTxt);
		
		super(x, y, fw, txt, size);
		font = Paths.font('VGA.ttf');
		color = 0xFF999999;
		textField.antiAliasType = ADVANCED;
		textField.sharpness = 400;
	}
	
	function _updateTxt()
	{
		text = typer.text;
		FlxG.sound.play(Paths.sound('main/txtblip'), 0.2);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		typer.update(elapsed);
		
		if (parent != null)
		{
			this.x = parent.x;
			this.y = parent.y;
			this.color = parent.color;
		}
	}
	
	override function destroy()
	{
		typer.destroy();
		super.destroy();
	}
}
