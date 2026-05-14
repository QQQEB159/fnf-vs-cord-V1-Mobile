package states;

import objects.AttachedSprite;

class CreditsState extends MusicBeatState
{
	var bg:FlxSprite;
	var facingLeft:Bool = false;
	var facingRight:Bool = true;
	
	var pixelCord:FlxSprite;
	
	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Credits", null);
		#end
		
		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();
		
		pixelCord = new FlxSprite(300, 300).loadGraphic(Paths.image('menuassets/credits/cordPixel'));
		pixelCord.frames = Paths.getSparrowAtlas('menuassets/credits/cordPixel');
		pixelCord.animation.addByPrefix('idle', 'Idle', 24, true);
		pixelCord.animation.addByPrefix('blink', 'Blink', 24, true); // plays randomly
		pixelCord.animation.addByPrefix('run', 'Run', 24, true);
		pixelCord.animation.addByPrefix('jump', 'Jump', 1, true);
		pixelCord.animation.addByPrefix('intro', 'Start Anim', 24, false); // only plays when you finish nine lives and enter the credits stage
		pixelCord.scale.set(5, 5);
		
		pixelCord.antialiasing = false;
		
		pixelCord.animation.play('idle');
		add(pixelCord);
		
		super.create();
	}
	
	var quitting:Bool = false;
	
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		if (!quitting)
		{
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new MainMenuState());
				quitting = true;
			}
			
			if (controls.UI_RIGHT_P)
			{
				pixelCord.animation.play('run');
				if (!facingRight)
				{
					pixelCord.flipX = true;
					facingRight = true;
					facingLeft = false;
				}
			}
			else if (controls.UI_LEFT_P)
			{
				pixelCord.animation.play('run');
				if (!facingLeft)
				{
					pixelCord.flipX = false;
					facingRight = false;
					facingLeft = true;
				}
			}
		}
		super.update(elapsed);
	}
}
