package;

import haxe.io.Bytes;
import haxe.io.Path;

import lime.app.Application;

import openfl.display.BitmapData;

import hxvlc.flixel.FlxVideoSprite;

import flixel.FlxState;
import flixel.FlxBasic;

class DragAndDrop extends FlxBasic
{
	static var instance:Null<DragAndDrop> = null;
	
	var children:Array<FlxSprite> = [];
	
	var hovered:Null<FlxSprite> = null;
	
	public static function init()
	{
		if (instance != null) return;
		FlxG.plugins.addPlugin(instance = new DragAndDrop());
	}
	
	function clear()
	{
		hovered = null;
		#if VIDEOS_ALLOWED
		for (i in children)
		{
			if (i is FlxVideoSprite)
			{
				var vid:FlxVideoSprite = cast i;
				if (vid.bitmap.isPlaying) vid.stop();
			}
		}
		#end
		children.resize(0);
	}
	
	public function new()
	{
		super();
		this.visible = false;
		
		FlxG.signals.preStateSwitch.add(clear);
		
		Application.current.window.onDropFile.add((path) -> {
			trace(path);
			
			#if flxgif
			if (path.endsWith('.gif'))
			{
				final bytes = File.getBytes(path);
				
				if (bytes == null) return;
				
				var spr = new flxgif.FlxGifSprite(0, 0, bytes);
				FlxG.state.add(spr);
				spr.x = FlxG.mouse.gameX - (spr.width / 2);
				spr.y = FlxG.mouse.gameY - (spr.height / 2);
				spr.scrollFactor.set();
				
				children.push(spr);
			}
			else
			#end
			if (path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.webm'))
			{
				var spr = new FlxVideoSprite();
				if (!spr.load(path))
				{
					spr.destroy();
					return;
				}
				else
				{
					FlxG.state.add(spr);
					children.push(spr);
					
					spr.bitmap.onEndReached.add(() -> {
						spr.kill();
					}, true);
					
					spr.bitmap.onFormatSetup.add(() -> {
						spr.x = FlxG.mouse.gameX - (spr.width / 2);
						spr.y = FlxG.mouse.gameY - (spr.height / 2);
						spr.scrollFactor.set();
					}, true);
					spr.play();
				}
			}
			else
			{
				var bitmap:Null<BitmapData> = BitmapData.fromFile(path);
				if (bitmap != null)
				{
					var spr = new FlxSprite(0, 0, bitmap);
					FlxG.state.add(spr);
					spr.x = FlxG.mouse.gameX - (spr.width / 2);
					spr.y = FlxG.mouse.gameY - (spr.height / 2);
					spr.scrollFactor.set();
					
					children.push(spr);
				}
			}
		});
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (hovered == null)
		{
			var garbage = [];
			
			var reversed = children.copy();
			reversed.reverse();
			
			for (i in reversed)
			{
				if (i == null)
				{
					garbage.push(i);
					continue;
				}
				if (FlxG.mouse.overlaps(i))
				{
					hovered = i;
					break;
				}
			}
			
			for (i in garbage)
				children.remove(i);
		}
		else if (hovered != null)
		{
			if (FlxG.mouse.pressed)
			{
				hovered.x += FlxG.mouse.deltaViewX;
				hovered.y += FlxG.mouse.deltaViewY;
			}
			
			if (FlxG.mouse.wheel != 0)
			{
				var oldScale = hovered.scale.x;
				
				var newScale = hovered.scale.x + (FlxG.mouse.wheel * 0.1);
				if (newScale < 0.05) newScale = 0.05;
				
				hovered.scale.set(newScale, newScale);
				
				hovered.x += (hovered.frameWidth * oldScale - hovered.frameWidth * hovered.scale.x) * 0.5;
				hovered.y += (hovered.frameHeight * oldScale - hovered.frameHeight * hovered.scale.x) * 0.5;
				
				hovered.updateHitbox();
			}
			
			if (FlxG.mouse.justReleasedRight)
			{
				hovered.kill();
				children.remove(hovered);
				if (hovered is FlxVideoSprite)
				{
					var vid:FlxVideoSprite = cast hovered;
					if (vid.bitmap.isPlaying) vid.stop();
				}
			}
			
			if (FlxG.mouse.justReleased || FlxG.mouse.justReleasedRight || !FlxG.mouse.overlaps(hovered)) hovered = null;
		}
	}
}
