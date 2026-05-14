package states.minigames.rosiesim;

import options.OptionsText;

class OutfitPicker extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var plushes:Array<FlxSprite> = [];
	var locks:Array<FlxSprite> = [];
	var oneTick:Bool;
	
	override function create()
	{
		super.create();
		
		FlxG.sound.play(Paths.sound('minigames/rosieclicker/open'));
		
		bg = new FlxSprite().makeScaledGraphic(1920 * 0.8, 1080 * 0.8, FlxColor.BLACK);
		add(bg);
		bg.scale.set();
		bg.screenCenter();
		bg.alpha = 0.7;
		bg.scrollFactor.set();
		
		for (i in 0...Outfit.toList().length)
		{
			var plush = new FlxSprite(0, bg.y + 10, Paths.image('minigames/rosieclicker/${Outfit.toList()[i]}'));
			plush.scale.scale(0.5);
			plush.updateHitbox();
			
			var x = FlxMath.remapToRange(i, 0, 3, bg.x + 50, bg.x + bg.width - 50 - plush.width);
			if (i > 3)
			{
				x = FlxMath.remapToRange(i, 4, Outfit.toList().length - 1, bg.x + 200, bg.x + bg.width - 200 - plush.width);
			}
			plush.x = x;
			plush.y = bg.y + 80 + ((plush.height + 50) * Math.ffloor(i / 4));
			add(plush);
			
			plushes.push(plush);
			
			plush.antialiasing = ClientPrefs.data.antialiasing;
			plush.scrollFactor.set();
			
			final isLocked = Outfit.toList()[i].isLocked();
			
			var lock = new FlxSprite(Paths.image('minigames/rosieclicker/locked'));
			add(lock);
			lock.centerOnObject(plush);
			lock.scrollFactor.set();
			lock.antialiasing = ClientPrefs.data.antialiasing;
			lock.alpha = 0;
			locks.push(lock);
			
			if (isLocked)
			{
				plush.alpha = 0.4;
				lock.alpha = 1;
			}
			
			var desc = new OptionsText(0, 0, plush.width * 1.4, Outfit.getDesc(Outfit.toList()[i]), 18);
			add(desc);
			desc.centerOnObject(plush, X);
			desc.alignment = CENTER;
			desc.y = plush.y + plush.height + 8;
			desc.scrollFactor.set();
			desc.color = FlxColor.WHITE;
			
			// animate it
			
			plush.alpha = 0;
			plush.y += 10;
			desc.alpha = 0;
			desc.y += 10;
			lock.scale.set();
			
			FlxTween.tween(plush, {alpha: isLocked ? 0.4 : 1, y: plush.y - 10}, 0.2, {ease: FlxEase.cubeOut, startDelay: 0.1});
			FlxTween.tween(desc, {alpha: 1, y: desc.y - 10}, 0.2, {ease: FlxEase.cubeOut, startDelay: 0.1});
			FlxTween.tween(lock, {'scale.x': 1, 'scale.y': 1}, 0.2, {ease: FlxEase.backOut, startDelay: 0.2 + (i * 0.025)});
		}
		
		FlxTween.tween(bg, {'scale.x': 1920 * 0.8, 'scale.y': 1080 * 0.8}, 0.2, {ease: FlxEase.sineOut});
	}
	
	var controlerIndex:Int = 0;
	
	var exiting:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (oneTick == false)
		{
			oneTick = true;
			return;
		}
		
		if (exiting)
		{
			return;
		}
		
		final usingController = Controls.instance.controllerMode;
		
		if (usingController)
		{
			//
			
			if (Controls.instance.UI_LEFT_P)
			{
				controlerIndex -= 1;
				controlerIndex = FlxMath.wrap(controlerIndex, 0, plushes.length - 1);
			}
			else if (Controls.instance.UI_RIGHT_P)
			{
				controlerIndex += 1;
				controlerIndex = FlxMath.wrap(controlerIndex, 0, plushes.length - 1);
			}
			else if (Controls.instance.UI_DOWN_P)
			{
				controlerIndex += 4;
				controlerIndex = FlxMath.wrap(controlerIndex, 0, plushes.length - 1);
			}
			else if (Controls.instance.UI_UP_P)
			{
				controlerIndex -= 4;
				controlerIndex = FlxMath.wrap(controlerIndex, 0, plushes.length - 1);
			}
			
			if (FlxG.gamepads.anyJustPressed(B))
			{
				exit();
				return;
			}
		}
		else
		{
			if (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(bg))
			{
				exit();
				return;
			}
		}
		
		for (i in 0...plushes.length)
		{
			final plush = plushes[i];
			
			final isOver = usingController ? controlerIndex == i : FlxG.mouse.overlaps(plush);
			
			if (isOver && (FlxG.gamepads.anyJustPressed(A) || (!usingController && FlxG.mouse.justPressed)))
			{
				attemptPurchase(i);
			}
			
			final sc = FlxMath.lerp(plush.scale.x, isOver ? 0.525 : 0.5, FlxMath.getElapsedLerp(0.4, elapsed));
			
			plush.scale.set(sc, sc);
			
			final transfomOffset = FlxMath.lerp(plush.colorTransform.redOffset, isOver ? 25 : 0, FlxMath.getElapsedLerp(0.4, elapsed));
			
			plush.colorTransform.redOffset = transfomOffset;
			plush.colorTransform.blueOffset = transfomOffset;
			plush.colorTransform.greenOffset = transfomOffset;
		}
	}
	
	function attemptPurchase(idx:Int)
	{
		final plush = plushes[idx];
		if (plush.alpha > 0.4)
		{
			(cast FlxG.state : RosieSimV2).rosie.outfit = Outfit.toList()[idx];
			
			exit();
		}
		else
		{
			if (Outfit.toList()[idx].isCord())
			{
				switch (Outfit.toList()[idx])
				{
					case CORD:
						var fit:Outfit = ONESIE_ROSE;
						if (fit.isLocked())
						{
							denyPurchase();
							return;
						}
					case MIAU_CORD:
						var fit:Outfit = CORD;
						if (fit.isLocked())
						{
							denyPurchase();
							return;
						}
						
					case ONESIE_CORD:
						var fit:Outfit = MIAU_CORD;
						if (fit.isLocked())
						{
							denyPurchase();
							return;
						}
					default:
				}
			}
			
			if (Outfit.toList()[idx].getCost() <= (cast FlxG.state : RosieSimV2).clicks)
			{
				(cast FlxG.state : RosieSimV2).clicks -= Outfit.toList()[idx].getCost();
				Outfit.toList()[idx].unlock();
				
				// make this cooler...
				FlxTween.tween(plush, {y: plush.y - 45}, 0.15,
					{
						ease: FlxEase.sineOut,
						onComplete: Void -> {
							FlxTween.tween(plush, {y: plush.y + 45}, 0.15, {ease: FlxEase.sineIn});
						}
					});
					
				plush.alpha = 1;
				
				locks[idx].scale.set(0.9, 0.9);
				
				FlxTimer.wait(0.1, () -> {
					locks[idx].scale.set(1, 1);
					FlxTimer.wait(0.1, () -> {
						locks[idx].visible = false;
					});
				});
			}
			else
			{
				denyPurchase();
			}
		}
	}
	
	inline function denyPurchase()
	{
		FlxG.sound.play(Paths.sound('minigames/rosieclicker/nop'));
		FlxG.camera.shake(0.005, 0.1);
	}
	
	function exit()
	{
		exiting = true;
		
		(cast FlxG.state : RosieSimV2).enabled = true;
		
		forEach(spr -> {
			if (spr != bg) FlxTween.tween(spr, {alpha: 0}, 0.1);
		});
		
		FlxTween.tween(bg, {'scale.x': 0, 'scale.y': 0}, 0.2, {ease: FlxEase.sineIn, onComplete: Void -> close()});
	}
	
	override function destroy()
	{
		forEach(spr -> {
			FlxTween.cancelTweensOf(spr);
		}, true);
		
		(cast FlxG.state : RosieSimV2).flush(false);
		
		super.destroy();
	}
}
