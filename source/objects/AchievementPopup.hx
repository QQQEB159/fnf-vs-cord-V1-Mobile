package objects;

#if ACHIEVEMENTS_ALLOWED
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.Lib;

class AchievementPopup extends openfl.display.Sprite
{
	public static final HEIGHT:Int = 93;
	public static final WIDTH:Int = 416;
	
	public var onFinish:Void->Void = null;
	
	var alphaTween:FlxTween;
	var lastScale:Float = 1;
	
	public function new(achieve:String, onFinish:Void->Void)
	{
		super();
		
		// bg
		graphics.beginFill(FlxColor.BLACK);
		graphics.drawRect(0, 0, WIDTH, HEIGHT);
		
		// achievement icon
		var graphic = null;
		var hasAntialias:Bool = ClientPrefs.data.antialiasing;
		var image:String = 'achievements/$achieve';
		
		var achievement:Achievement = null;
		if (Achievements.exists(achieve)) achievement = Achievements.get(achieve);
		
		#if MODS_ALLOWED
		var lastMod = Mods.currentModDirectory;
		if (achievement != null) Mods.currentModDirectory = achievement.mod != null ? achievement.mod : '';
		#end
		
		if (Paths.fileExists('images/$image-pixel.png', IMAGE))
		{
			graphic = Paths.image('$image-pixel', false);
			hasAntialias = false;
		}
		else graphic = Paths.image(image, false);
		
		#if MODS_ALLOWED
		Mods.currentModDirectory = lastMod;
		#end
		
		if (graphic == null) graphic = Paths.image('unknownMod', false);
		
		final sizeX = 75;
		final sizeY = 75;
		
		final imgX = 6;
		final imgY = 9;
		
		var image = graphic.bitmap.clone();
		
		graphics.beginBitmapFill(image, new Matrix(sizeX / image.width, 0, 0, sizeY / image.height, imgX, imgY), false, hasAntialias);
		graphics.drawRect(imgX, imgY, sizeX + 10, sizeY + 10);
		
		// achievement name/description
		var name:String = 'Unknown';
		var desc:String = 'Description not found';
		if (achievement != null)
		{
			if (achievement.name != null) name = achievement.name;
			if (achievement.description != null) desc = achievement.description;
		}
		
		final textX = 90;
		final textY = 14;
		
		var text:FlxText = new FlxText(0, 0, 300, 'TEST!!!', 14);
		text.setFormat(Paths.font("VGA.ttf"), 14, achievement?.textColour ?? FlxColor.WHITE, LEFT);
		drawTextAt(text, name, textX, textY);
		text.setFormat(Paths.font("VGA.ttf"), 10, 0xFF989898, LEFT);
		drawTextAt(text, desc, textX, textY + 28);
		graphics.endFill();
		
		text.graphic.bitmap.dispose();
		text.graphic.bitmap.disposeImage();
		text.destroy();
		
		// other stuff
		FlxG.stage.addEventListener(Event.RESIZE, onResize);
		addEventListener(Event.ENTER_FRAME, update);
		
		FlxG.game.addChild(this); // Don't add it below mouse, or it will disappear once the game changes states
		
		// fix scale
		lastScale = (FlxG.stage.stageHeight / FlxG.height);
		
		// this.y = -HEIGHT * lastScale;
		this.y = FlxG.scaleMode.gameSize.y;
		
		this.scaleX = lastScale;
		this.scaleY = lastScale;
		intendedY = 0;
	}
	
	var bitmaps:Array<BitmapData> = [];
	
	function drawTextAt(text:FlxText, str:String, textX:Float, textY:Float)
	{
		text.text = str;
		text.updateHitbox();
		
		var clonedBitmap:BitmapData = text.graphic.bitmap.clone();
		bitmaps.push(clonedBitmap);
		graphics.beginBitmapFill(clonedBitmap, new Matrix(1, 0, 0, 1, textX, textY), false, false);
		graphics.drawRect(textX, textY, text.width + textX, text.height + textY);
	}
	
	var lerpTime:Float = 0;
	var countedTime:Float = 0;
	var timePassed:Float = -1;
	
	public var intendedY:Float = 0;
	
	function update(e:Event)
	{
		if (timePassed < 0)
		{
			timePassed = Lib.getTimer();
			return;
		}
		
		var time = Lib.getTimer();
		var elapsed:Float = (time - timePassed) / 1000;
		timePassed = time;
		// trace('update called! $elapsed');
		
		if (elapsed >= 0.5) return; // most likely passed through a loading
		
		// x = FlxG.scaleMode.gameSize.x - (WIDTH * scaleX);
		
		this.x = FlxG.scaleMode.gameSize.x - (WIDTH * scaleX);
		
		countedTime += elapsed;
		if (countedTime < 3)
		{
			lerpTime = Math.min(1, lerpTime + elapsed * 5);
			final nextY = FlxG.scaleMode.gameSize.y + ((lerpTime * (intendedY - HEIGHT)) * lastScale);
			
			y = CoolUtil.decayLerp(y, nextY, 36, elapsed);
			// y = CoolUtil.decayLerp(y, ((lerpTime * (intendedY + HEIGHT)) - HEIGHT) * lastScale, 36, elapsed);
		}
		else
		{
			y += HEIGHT * 5 * elapsed * lastScale;
			
			if (y > FlxG.scaleMode.gameSize.y) destroy();
		}
	}
	
	private function onResize(e:Event)
	{
		final mult:Float = Math.max(1, Math.min(FlxG.stage.stageWidth / FlxG.width, FlxG.stage.stageHeight / FlxG.height));
		
		// var mult = (FlxG.stage.stageHeight / FlxG.height);
		scaleX = mult;
		scaleY = mult;
		
		x = (mult / lastScale) * x;
		y = (mult / lastScale) * y;
		lastScale = mult;
	}
	
	public function destroy()
	{
		Achievements._popups.remove(this);
		// trace('destroyed achievement, new count: ' + Achievements._popups.length);
		
		if (FlxG.game.contains(this))
		{
			FlxG.game.removeChild(this);
		}
		FlxG.stage.removeEventListener(Event.RESIZE, onResize);
		removeEventListener(Event.ENTER_FRAME, update);
		deleteClonedBitmaps();
	}
	
	function deleteClonedBitmaps()
	{
		for (clonedBitmap in bitmaps)
		{
			if (clonedBitmap != null)
			{
				clonedBitmap.dispose();
				clonedBitmap.disposeImage();
			}
		}
		bitmaps = null;
	}
}
#end
