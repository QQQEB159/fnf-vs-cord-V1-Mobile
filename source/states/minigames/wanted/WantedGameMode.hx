package states.minigames.wanted;

import states.minigames.wanted.modifiers.*;

import flixel.math.FlxRect;

enum abstract GameModeDirect(Int)
{
	/**
	 * The icons are lined up in rows and do not move
	 */
	var STATIC;
	
	/**
	 * The icons will scroll across the screen looping
	 */
	var WAVE;
	
	/**
	 * The icons will bounce around hitting the edges of the screen
	 */
	var WALLS;
	
	/**
	 * The icons bounce vertically off the bottom of the screen
	 */
	var BOUNCE;
}

class WantedGameMode
{
	public function new() {}
	
	public var mode:GameModeDirect = WALLS;
	
	public function applyGravity(icons:Array<Null<FlickerIcon>>)
	{
		switch (mode)
		{
			case WALLS:
				for (icon in icons)
				{
					if (icon == null) continue;
					// this is a bit more crude way to handle this but flxg.collide was dramatically slower
					if (icon.x < FindCord.instance.ICON_WORLD_SPACE.left)
					{
						icon.x = FindCord.instance.ICON_WORLD_SPACE.left;
						icon.velocity.x *= -1;
					}
					
					if ((icon.x + icon.width) > FindCord.instance.ICON_WORLD_SPACE.right)
					{
						icon.x = FindCord.instance.ICON_WORLD_SPACE.right - icon.width;
						icon.velocity.x *= -1;
					}
					
					if (icon.y < FindCord.instance.ICON_WORLD_SPACE.top)
					{
						icon.y = FindCord.instance.ICON_WORLD_SPACE.top;
						icon.velocity.y *= -1;
					}
					
					if ((icon.y + icon.height) > FindCord.instance.ICON_WORLD_SPACE.bottom)
					{
						icon.y = FindCord.instance.ICON_WORLD_SPACE.bottom - icon.height;
						icon.velocity.y *= -1;
					}
				}
			case STATIC:
			
			case BOUNCE:
				for (icon in icons)
				{
					if (icon == null) continue;
					icon.velocity.x = 0;
					
					if ((icon.y + icon.height) > FindCord.instance.ICON_WORLD_SPACE.bottom)
					{
						icon.y = FindCord.instance.ICON_WORLD_SPACE.bottom - icon.height;
						icon.velocity.y *= -1;
					}
				}
				
			case WAVE:
				for (icon in icons)
				{
					if (icon == null) continue;
					
					icon.wrapAroundRect(FindCord.instance.ICON_WORLD_SPACE);
				}
		}
	}
	
	public function reset() {} // might be delteed
	
	public function positionIcons(icons:Array<Null<FlickerIcon>>)
	{
		switch (mode)
		{
			case STATIC:
				final startX = FindCord.instance.ICON_WORLD_SPACE.left + 25;
				final startY = FindCord.instance.ICON_WORLD_SPACE.top;
				final row = 8;
				final spacing = 75;
				
				// 40
				for (k => icon in icons)
				{
					if (icon == null) continue;
					
					var x = (startX + ((k * spacing) % (row * spacing)));
					var y = startY + (spacing * Math.ffloor(k / row));
					
					icon.setPosition(x, y);
					icon.startingPos.set(x, y);
					icon.scale.scale(0.75);
					icon.updateHitbox();
					
					icon.x -= (icon.width) / 2;
				}
			case WALLS | BOUNCE:
				for (icon in icons)
				{
					if (icon == null) continue;
					
					icon.x = FlxMath.lerp(FindCord.instance.ICON_WORLD_SPACE.left, FindCord.instance.ICON_WORLD_SPACE.right - icon.width, Math.random());
					icon.y = FlxMath.lerp(FindCord.instance.ICON_WORLD_SPACE.top, FindCord.instance.ICON_WORLD_SPACE.bottom - icon.height, Math.random());
					
					icon.startingPos.set(icon.x, icon.y);
					
					icon.velocity.x = (Math.random() - 0.5) * ((Math.random() + 0.5) * getMoveSpeed());
					icon.velocity.y = (Math.random() - 0.5) * ((Math.random() + 0.5) * getMoveSpeed());
					
					if (mode == BOUNCE)
					{
						icon.acceleration.y = FlxG.random.int(200, 500);
					}
				}
				
			case WAVE:
				final goLeft = FlxG.random.bool();
				final goUp = FlxG.random.bool();
				
				final movesY = FlxG.random.bool(80);
				final movesX = FlxG.random.bool(80);
				
				for (icon in icons)
				{
					if (icon == null)
					{
						trace('null icon???');
						continue;
					}
					
					icon.x = FlxMath.lerp(FindCord.instance.ICON_WORLD_SPACE.left, FindCord.instance.ICON_WORLD_SPACE.right - icon.width, Math.random());
					icon.y = FlxMath.lerp(FindCord.instance.ICON_WORLD_SPACE.top, FindCord.instance.ICON_WORLD_SPACE.bottom - icon.height, Math.random());
					
					icon.startingPos.set(icon.x, icon.y);
					
					if (movesX) icon.velocity.x = (Math.random() + 0.5) * getMoveSpeed() * 2;
					if (movesY) icon.velocity.y = (Math.random() + 0.5) * getMoveSpeed() * 2;
					
					if (goLeft) icon.velocity.x *= -1;
					if (goUp) icon.velocity.y *= -1;
				}
		}
	}
	
	public function getScoreMod():Float
	{
		return 0.0;
	}
	
	inline function getMoveSpeed():Float return (FindCord.instance.getModByCl(IconSpeedModifier)?.getEffect() ?? 1.0) * FindCord.ICON_MOVE_RATE;
}
