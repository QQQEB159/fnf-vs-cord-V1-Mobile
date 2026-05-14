package backend;

import flixel.util.FlxArrayUtil;

import haxe.ds.ArraySort;

import flixel.util.FlxSort;

class StickerTransition extends MusicBeatSubstate
{
	var stickers:FlxTypedGroup<FlxSprite>;
	
	public static var fileName:Null<String> = '1';
	public static var previousData:Null<Array<PrevParams>> = null;
	
	var onEnd:Null<Void->Void> = null;
	
	final unifiedScale:Float = 0.8;
	final sound:String = 'menu/options_click';
	
	public function new(?onEnd:Void->Void)
	{
		super();
		this.onEnd = onEnd;
	}
	
	override function create()
	{
		super.create();
		
		stickers = new FlxTypedGroup();
		add(stickers);
		
		if (fileName == null) throw '?????';
		
		if (previousData != null && previousData.length != 0)
		{
			despawn();
		}
		else
		{
			StickerTransition.fileName = FlxG.random.bool(4) ? '2' : '1';
			
			spawn();
		}
		
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
	
	function spawn()
	{
		var xPos:Float = -100;
		var yPos:Float = -100;
		
		final frames = Paths.getSparrowAtlas('stickers/$fileName');
		// trace(frames.parent.key);
		// Paths.excludeAsset(frames.parent.key);
		while (xPos <= FlxG.width)
		{
			final sticky:FlxSprite = new FlxSprite();
			sticky.frames = frames;
			sticky.animation.frameIndex = FlxG.random.int(0, sticky.numFrames - 1);
			sticky.scale.scale(unifiedScale);
			sticky.updateHitbox();
			sticky.visible = false;
			sticky.scrollFactor.set();
			sticky.antialiasing = ClientPrefs.data.antialiasing;
			
			sticky.x = xPos;
			sticky.y = yPos;
			xPos += ((sticky.frameWidth * sticky.scale.x) * 0.5);
			
			if (xPos >= FlxG.width)
			{
				if (yPos <= FlxG.height)
				{
					xPos = -100;
					yPos += FlxG.random.float(70, 120);
				}
			}
			
			sticky.angle = FlxG.random.int(-60, 70);
			stickers.add(sticky);
		}
		
		FlxG.random.shuffle(stickers.members);
		
		final sticky:FlxSprite = new FlxSprite();
		sticky.frames = frames;
		sticky.animation.frameIndex = FlxG.random.int(0, sticky.numFrames - 1);
		sticky.scale.scale(unifiedScale);
		sticky.updateHitbox();
		sticky.scrollFactor.set();
		sticky.antialiasing = ClientPrefs.data.antialiasing;
		
		sticky.visible = false;
		sticky.screenCenter();
		stickers.add(sticky);
		
		previousData = [];
		
		for (i => k in stickers)
		{
			final time = FlxMath.remapToRange(i, 0, stickers.length, 0, 0.8);
			
			previousData.push(
				{
					idx: k.animation.frameIndex,
					scale: k.scale.x,
					x: k.x,
					y: k.y,
					time: time,
					angle: k.angle
				});
				
			var t = FlxTimer.wait(time, () -> {
				if (this == null)
				{
					close();
					return;
				}
				k.visible = true;
				FlxG.sound.play(Paths.soundRandom('stickers/stickerSound', 1, 6), 0.5);
				
				var t = FlxTimer.wait((1 / 24) * FlxG.random.int(0, 2), () -> {
					if (this == null)
					{
						close();
						return;
					}
					k.scale.scale(1.025);
					
					if (i == stickers.length - 1)
					{
						FlxTimer.wait(0.25, () -> {
							if (onEnd != null) onEnd();
							FlxTimer.wait(0, close);
						});
					}
				});
				timers.push(t);
			});
			timers.push(t);
		}
	}
	
	function despawn()
	{
		final frames = Paths.getSparrowAtlas('stickers/$fileName');
		
		var times:Array<Float> = [];
		
		for (k => i in previousData)
		{
			final sticky:FlxSprite = new FlxSprite(i.x, i.y);
			sticky.frames = frames;
			sticky.animation.frameIndex = i.idx;
			sticky.scale.set(i.scale, i.scale);
			sticky.updateHitbox();
			sticky.scale.scale(1.025);
			sticky.angle = i.angle;
			stickers.add(sticky);
			sticky.scrollFactor.set();
			sticky.antialiasing = ClientPrefs.data.antialiasing;
			
			times.push(i.time);
			
			// FlxTimer.wait(i.time, () -> { // fix deletion order killing myself
			// 	sticky.visible = false;
			// 	FlxG.sound.play(Paths.soundRandom('stickers/stickerSound', 1, 6), 0.5);
			
			// 	if (k == stickers.length - 1)
			// 	{
			// 		close();
			// 	}
			// });
		}
		
		// var reversed =
		for (k => i in stickers.members)
		{
			var t = FlxTimer.wait((times[k] ?? 0.05), () -> { // maybe ?
				stickers.members[stickers.length - 1 - k].visible = false;
				FlxG.sound.play(Paths.soundRandom('stickers/stickerSound', 1, 6), 0.5);
				
				if (k == stickers.length - 1)
				{
					close();
				}
			});
			
			timers.push(t);
		}
		
		previousData = null;
		// fileName = null;
	}
	
	var timers:Array<FlxTimer> = [];
	
	override function destroy()
	{
		for (i in timers)
		{
			i?.cancel();
		}
		super.destroy();
	}
}

typedef PrevParams =
{
	idx:Int,
	scale:Float,
	x:Float,
	y:Float,
	time:Float,
	angle:Float
}
