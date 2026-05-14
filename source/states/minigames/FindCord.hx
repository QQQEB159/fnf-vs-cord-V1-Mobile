package states.minigames;

import flixel.FlxObject;
import flixel.graphics.FlxGraphic;

import shaders.ColorSwap;

import options.OptionsState;

import states.minigames.wanted.WantedGameMode;
import states.minigames.wanted.modifiers.*;
import states.minigames.wanted.FlickerIcon;
import states.minigames.wanted.Heart;
import states.minigames.wanted.ResultsScreen;

import haxe.ds.ArraySort;

import flixel.text.FlxBitmapText;
import flixel.text.FlxBitmapFont;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.atlas.FlxAtlas;
import flixel.group.FlxSpriteContainer;

import objects.Bopper;

import flixel.math.FlxRect;
import flixel.group.FlxContainer.FlxTypedContainer;

// add modifiers
// add gamemodes
// clean up
class FindCord extends MusicBeatState
{
	public static var instance:FindCord = null;
	
	// constants
	public static final MISS_CLICK_TOLERANCE:Int = 3;
	public static final BASE_ROUND_TIME:Float = 15;
	
	public static final ICON_MOVE_RATE:Float = 50;
	
	var gameMode:WantedGameMode = new WantedGameMode();
	
	// MODIFIERS STUFF
	var modifiers:Array<Modifier> = [];
	
	public function getModByCl<T:Modifier>(clInput:Class<T>):Null<T> // when using this always expect and account for null
	{
		for (mod in modifiers)
		{
			if (Std.isOfType(mod, clInput)) return cast mod;
		}
		
		return null;
	}
	
	// stats stuff
	var score:Int = 0;
	var health:Int = 3;
	var roundsPassed:Int = 0;
	
	public final ICON_WORLD_SPACE = FlxRect.get(340, 0, 600, 360);
	
	final MIN_ICONS:Int = 50;
	final MAX_ICONS:Int = 100;
	
	// ui stuff
	var ui:FlxSpriteContainer;
	var hearts:FlxTypedSpriteContainer<Heart>;
	var scoreNums:FlxBitmapText;
	var timerTxt:FlxBitmapText;
	var roundNums:FlxBitmapText;
	
	var scoreTxt:FlxSprite;
	var muteButton:FlxSprite;
	var redoButton:FlxSprite;
	var exitButton:FlxSprite;
	
	var findCordTxt:FlxSprite;
	
	var wantedCord:FlxSprite;
	
	var border:FlxSprite;
	
	// game stuff
	// icon thingyes
	var icons:FlxTypedContainer<FlickerIcon>;
	final iconUsers = ['conner', 'plant', 'rose'];
	
	var cordIcon:Null<FlickerIcon> = null; // reference to cord
	
	// using a atlas we can batch 100s of quads into just 1 or 2 dramatically improving performance oh yeah
	// make this apart of icon?
	var atlas:Null<FlxAtlas> = null;
	
	var timeLeftInRound:Float = 15;
	
	var isPlaying:Bool = false;
	
	var missClicks = 3;
	
	//
	var controllerCursor:FlxSprite;
	
	override function create()
	{
		instance = this;
		
		#if !debug
		FlxG.autoPause = false;
		#end
		
		#if DISCORD_ALLOWED
		DiscordClient.changePresence('Playing WANTED minigame', null, null, false, null, 'wanted');
		#end
		
		super.create();
		
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			FlxTween.cancelTweensOf(FlxG.sound.music, ['pitch']);
			FlxG.sound.music.pitch = 1;
		}
		Paths.music('minigames/findCordGameover');
		Paths.music('minigames/findCord');
		Paths.sound('minigames/findcord/drumroll');
		
		icons = new FlxTypedContainer();
		add(icons);
		icons.visible = false;
		
		generateIcons();
		
		border = new FlxSprite(Paths.image('minigames/findcord/border'));
		add(border);
		
		wantedCord = new FlxSprite().loadSparrowFrames('minigames/findcord/bottomScreen');
		wantedCord.animation.addByPrefix('idle', 'screen2Idle instance 1', 24, false);
		wantedCord.animation.addByPrefix('startUp', 'screen2Start48FPS instance 1', 48, false);
		wantedCord.animation.addByPrefix('restart', 'screen2Restart48FPS instance 1', 48, false);
		wantedCord.animation.addByPrefix('caught', 'screen2Caught48FPS instance 1', 48, false);
		add(wantedCord);
		wantedCord.y = FlxG.height - wantedCord.height + 10;
		wantedCord.screenCenter(X);
		wantedCord.visible = false;
		
		// ui stuff
		ui = new FlxSpriteContainer();
		add(ui);
		
		hearts = new FlxTypedSpriteContainer();
		ui.add(hearts);
		
		for (i in 0...health)
		{
			var heart = new Heart(0, ((health - 1) - i) * 35);
			hearts.add(heart);
		}
		
		hearts.x = wantedCord.x + wantedCord.width - 12;
		hearts.y = wantedCord.y + wantedCord.height - hearts.height - 100;
		
		findCordTxt = new FlxSprite(Paths.image('minigames/findcord/find_cord'));
		add(findCordTxt);
		findCordTxt.screenCenter();
		findCordTxt.scale.set(0.1, 0.1);
		findCordTxt.visible = false;
		
		var timeTxt = new FlxSprite(Paths.image('minigames/findcord/time'));
		ui.add(timeTxt);
		timeTxt.screenCenter();
		timeTxt.y += 5;
		
		// kinda has bad field width stuff so we are just gonna spam screencenter
		final fnt = FlxBitmapFont.fromAngelCode(Paths.font('findcordNums.png'), Paths.font('findcordNums.fnt'));
		timerTxt = new FlxBitmapText(0, 0, '', fnt);
		ui.add(timerTxt);
		timerTxt.screenCenter(Y);
		timerTxt.y += 50;
		
		scoreTxt = new FlxSprite(Paths.image('minigames/findcord/scoreText'));
		ui.add(scoreTxt);
		scoreTxt.scale.scale(0.8);
		scoreTxt.updateHitbox();
		scoreTxt.screenCenter(X);
		scoreTxt.x -= scoreTxt.width / 2;
		
		final fntBold = FlxBitmapFont.fromAngelCode(Paths.font('findcordNumsBold.png'), Paths.font('findcordNumsBold.fnt'));
		
		scoreNums = new FlxBitmapText(0, 0, '0', fntBold);
		ui.add(scoreNums);
		scoreNums.scale.scale(0.5);
		scoreNums.updateHitbox();
		scoreNums.y = FlxG.height - scoreNums.height - 5;
		
		roundNums = new FlxBitmapText(wantedCord.x + wantedCord.width, wantedCord.y, '0', fntBold);
		ui.add(roundNums);
		roundNums.scale.scale(0.5);
		roundNums.updateHitbox();
		final shader = new ColorSwap();
		shader.saturation = -1;
		
		roundNums.shader = shader.shader;
		
		muteButton = new FlxSprite().loadSparrowFrames('minigames/findcord/volumeButton');
		muteButton.animation.addByPrefix('unmuted', 'volumeOn instance 1');
		muteButton.animation.addByPrefix('muted', 'volumeOff instance 1');
		
		muteButton.animation.onFrameChange.add((anim, num, idx) -> {
			if (num == 0)
			{
				//
				muteButton.centerOffsets();
				
				if (anim == 'muted') muteButton.offset.y += -3;
			}
		});
		
		muteButton.animation.play('unmuted');
		
		muteButton.scale.scale(0.5);
		muteButton.updateHitbox();
		ui.add(muteButton);
		muteButton.setPosition(wantedCord.x - muteButton.width, wantedCord.y + wantedCord.height - muteButton.height - 20);
		
		redoButton = new FlxSprite(Paths.image('minigames/findcord/redo'));
		redoButton.scale.scale(0.5);
		redoButton.updateHitbox();
		redoButton.x = muteButton.x;
		redoButton.y = muteButton.y - redoButton.height - 10;
		ui.add(redoButton);
		
		exitButton = new FlxSprite(Paths.image('minigames/findcord/leave'));
		exitButton.scale.scale(0.5);
		exitButton.updateHitbox();
		
		exitButton.x = wantedCord.x + wantedCord.width;
		exitButton.y = wantedCord.y + wantedCord.height - exitButton.height - 20;
		ui.add(exitButton);
		
		ui.visible = false;
		
		controllerCursor = new FlxSprite(0, 0, FlxGraphic.fromClass(Init.RosieClickerCursor));
		add(controllerCursor).visible = false;
		controllerCursor.scale.set(0.25, 0.25);
		controllerCursor.updateHitbox();
		controllerCursor.screenCenter();
		
		initIntro();
	}
	
	function initIntro()
	{
		findCordTxt.visible = true;
		FlxTween.tween(findCordTxt,
			{
				'scale.x': 1,
				'scale.y': 1,
				alpha: 1,
				angle: 1440
			}, 3, {ease: FlxEase.quadOut});
			
		FlxTimer.wait(3 + 0.3, () -> {
			startRound();
		});
	}
	
	function startRound(isNext:Bool = false)
	{
		missClicks = MISS_CLICK_TOLERANCE;
		timerTxt.text = Std.string(Math.round(timeLeftInRound = getRoundTime()));
		
		icons.visible = false;
		
		ui.visible = true;
		
		wantedCord.visible = true;
		
		findCordTxt.visible = false;
		
		FlxG.sound.play(Paths.sound('minigames/findcord/' + (isNext ? 'fastDrum' : 'drumroll')));
		
		if (!isNext) FlxG.sound.playMusic(Paths.music('minigames/findCord'));
		
		if (isNext) generateIcons();
		
		wantedCord.animation.play(isNext ? 'restart' : 'startUp');
		
		wantedCord.animation.onFinish.addOnce(anim -> startGame());
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (FlxG.gamepads.anyInput() && !Controls.instance.controllerMode) Controls.instance.controllerMode = true;
		else if (Controls.instance.controllerMode && FlxG.mouse.justMoved) Controls.instance.controllerMode = false;
		
		controllerCursor.visible = isPlaying && Controls.instance.controllerMode;
		
		FlxG.mouse.visible = isPlaying && !controllerCursor.visible;
		
		if (FlxG.gamepads.firstActive != null) // playing it safe
		{
			var rate:Float = 200;
			
			rate *= FlxG.gamepads.firstActive.anyPressed([X]) ? 3 : 1;
			
			final addX = (FlxG.gamepads.firstActive.analog.value.LEFT_STICK_X * rate * elapsed);
			final addY = (FlxG.gamepads.firstActive.analog.value.LEFT_STICK_Y * rate * elapsed);
			
			controllerCursor.x = FlxMath.bound(controllerCursor.x + addX, 0, FlxG.width);
			controllerCursor.y = FlxMath.bound(controllerCursor.y + addY, 0, FlxG.height);
		}
		
		if (isPlaying)
		{
			icons.active = true; // hacky
			
			final lastSecond = Math.round(timeLeftInRound);
			timeLeftInRound -= elapsed;
			final nextSecond = Math.round(timeLeftInRound);
			
			if (lastSecond != nextSecond) FlxG.sound.play(Paths.sound('minigames/findcord/clockTick'));
			
			timerTxt.text = Std.string(Math.round(timeLeftInRound));
			
			gameMode.applyGravity(icons.members);
			
			final pressedMouse = FlxG.mouse.justPressed || FlxG.gamepads.anyJustPressed(A);
			
			if (timeLeftInRound <= 0)
			{
				lostRound();
			}
			else if (cordIcon != null && pressedMouse)
			{
				final inWorldSpace = FlxMath.mouseInFlxRect(true, ICON_WORLD_SPACE)
					|| (Controls.instance.controllerMode
						&& FlxMath.pointInFlxRect(controllerCursor.x, controllerCursor.y, ICON_WORLD_SPACE));
						
				if (inWorldSpace) // abit unfair to penalize when ur not even clicking the icons
				{
					if (overlaps(cordIcon))
					{
						FlxG.sound.play(Paths.sound('minigames/findcord/cordAlert'), 0.5);
						
						beatRound();
					}
					else
					{
						FlxG.sound.play(Paths.sound('minigames/findcord/mouseClick'), 0.5);
						FlxG.sound.play(Paths.sound('minigames/findcord/notCordAlert'));
						
						for (i in 0...icons.length)
						{
							var icon = icons.members[icons.length - i];
							if (icon != null && icon != cordIcon && overlaps(icon))
							{
								icon.flicker();
								break;
							}
						}
						
						missClicks--;
						
						if (missClicks == 0)
						{
							lostRound();
						}
					}
				}
			}
			
			if (clicked() && ui.visible && overlaps(redoButton))
			{
				softReload();
			}
		}
		
		// if (FlxG.gamepads.anyPressed(B) && ui.visible)
		// {
		// 	CoolUtil.playMenuMusic();
		// 	FlxG.sound.music.volume = 0;
		// 	FlxG.switchState(() -> new OptionsState());
		// }
		
		if (clicked() && ui.visible) // toggle mute
		{
			if (overlaps(muteButton))
			{
				FlxG.sound.play(Paths.sound('minigames/findcord/mouseClick'), 0.5);
				
				FlxG.sound.music.volume = FlxG.sound.music.volume == 0 ? 1 : 0;
				muteButton.animation.play(FlxG.sound.music.volume == 0 ? 'muted' : 'unmuted');
			}
			else if (overlaps(exitButton))
			{
				CoolUtil.playMenuMusic();
				FlxG.sound.music.volume = 0;
				FlxG.switchState(() -> new OptionsState());
				FlxG.mouse.visible = false;
				isPlaying = false;
			}
		}
		
		positionUI();
	}
	
	inline function overlaps(obj:FlxObject)
	{
		return Controls.instance.controllerMode ? controllerCursor.overlaps(obj) : FlxG.mouse.overlaps(obj);
	}
	
	inline function clicked()
	{
		return FlxG.mouse.justPressed || FlxG.gamepads.anyJustPressed(A);
	}
	
	function softReload()
	{
		roundsPassed = -1;
		health = 3;
		score = 0;
		scoreNums.text = Std.string(score);
		for (i in hearts)
			i.reviveHeart();
		updateRoundsPassed();
		isPlaying = false;
		
		startRound(true);
	}
	
	function positionUI()
	{
		timerTxt.screenCenter(X);
		
		scoreTxt.x = (FlxG.width - (scoreTxt.width + scoreNums.width)) / 2;
		scoreNums.x = scoreTxt.x + scoreTxt.width;
		
		scoreTxt.y = scoreNums.y + 3;
		
		roundNums.text = Std.string(roundsPassed + 1);
	}
	
	function updateScore()
	{
		final newScore = Math.round(FlxMath.remapToRange(timeLeftInRound, getRoundTime(), 0, 1000, 1));
		score += newScore;
		
		scoreNums.y = FlxG.height - scoreNums.height - 5 - 10;
		FlxTween.cancelTweensOf(scoreNums, ['y']);
		FlxTween.tween(scoreNums, {y: FlxG.height - scoreNums.height - 5}, 0.3, {ease: FlxEase.bounceOut});
		
		scoreNums.text = Std.string(score);
		
		#if ACHIEVEMENTS_ALLOWED
		if (score >= 50000) Achievements.unlock('50kScore');
		#end
	}
	
	function gameOver()
	{
		addNewScore(score);
		persistentDraw = false;
		
		FlxTween.tween(FlxG.sound.music, {pitch: 0}, 1,
			{
				onComplete: Void -> {
					var spr = new FlxSprite(Paths.image('minigames/findcord/explode'));
					add(spr);
					spr.screenCenter();
					spr.x += FlxG.random.int(-100, 100);
					spr.y += FlxG.random.int(-100, 100);
					FlxG.sound.play(Paths.sound('minigames/findcord/cutExplosion')).onComplete = () -> {
						openSubState(new ResultsScreen(this));
					}
				}
			});
	}
	
	inline function updateRoundsPassed()
	{
		roundsPassed++;
		
		#if ACHIEVEMENTS_ALLOWED
		if (roundsPassed >= 100)
		{
			Achievements.unlock('100rounds');
		}
		#end
		
		if (roundsPassed >= 10 && !iconUsers.contains('marilyn'))
		{
			iconUsers.push('marilyn');
			prepAtlas();
		}
		
		// update current game mode here
		
		// APPLY MODIFIERS
		for (mod in modifiers)
		{
			mod = FlxDestroyUtil.destroy(mod);
		}
		modifiers.resize(0);
		
		if (roundsPassed >= 100)
		{
			modifiers.push(new IconSpeedModifier());
			modifiers.push(new FlippedModifier());
			modifiers.push(new TimeModifier(-10));
			modifiers.push(new GreyScaleModifier());
		}
		else
		{
			if (roundsPassed >= 20 && FlxG.random.bool(30)) modifiers.push(new IconSpeedModifier());
			
			if (roundsPassed >= 30 && FlxG.random.bool(30)) modifiers.push(new FlippedModifier());
			
			if (roundsPassed >= 40 && FlxG.random.bool(30)) modifiers.push(new TimeModifier(FlxG.random.bool() ? -5 : -10));
			
			if (roundsPassed >= 75 && FlxG.random.bool(50)) modifiers.push(new GreyScaleModifier());
			else if (roundsPassed >= 50 && FlxG.random.bool(30)) modifiers.push(new GreyScaleModifier());
		}
		
		if (modifiers.length >= 4)
		{
			#if ACHIEVEMENTS_ALLOWED
			Achievements.unlock('modifier');
			#end
		}
		// gamemode picking
		if (roundsPassed > 5)
		{
			if (FlxG.random.bool(20)) gameMode.mode = WAVE;
			else if (FlxG.random.bool(20)) gameMode.mode = STATIC;
			else if (FlxG.random.bool(20)) gameMode.mode = BOUNCE;
			else gameMode.mode = WALLS;
		}
		gameMode.reset();
	}
	
	function beatRound()
	{
		updateRoundsPassed();
		isPlaying = false;
		
		updateScore();
		
		icons.forEach(spr -> {
			spr.velocity.set();
			spr.acceleration.set();
			spr.visible = false;
		});
		
		cordIcon.visible = true;
		
		cordIcon.playAnim('caught');
		wantedCord.animation.play('caught');
		
		FlxTimer.wait(1, () -> startRound(true));
	}
	
	function lostRound()
	{
		updateRoundsPassed();
		isPlaying = false;
		
		icons.active = false;
		
		icons.forEach(spr -> {
			spr.visible = false;
		});
		
		cordIcon.visible = true;
		
		for (i in 0...health - 1)
		{
			if (hearts.members[i].twn != null) hearts.members[i].twn.duration /= 2;
		}
		
		final heart = hearts.members[health - 1];
		
		if (heart != null)
		{
			heart.die();
		}
		
		health--;
		
		if (health <= 0)
		{
			FlxTimer.wait(0.5, gameOver);
		}
		else
		{
			FlxTimer.wait(0.5, () -> startRound(true));
		}
	}
	
	function startGame()
	{
		icons.active = true;
		
		icons.visible = true;
		isPlaying = true;
	}
	
	function prepAtlas()
	{
		if (atlas != null)
		{
			atlas.destroy();
		}
		atlas = new FlxAtlas('icons', false, 5, true);
		for (k => i in iconUsers)
		{
			atlas.addNode(Paths.image('minigames/findcord/icons/$i').bitmap, 'ICON_$i');
		}
		atlas.graphic.persist = false;
		atlas.graphic.destroyOnNoUse = false;
	}
	
	function generateIcons()
	{
		if (atlas == null) prepAtlas();
		
		for (i in 0...icons.length)
		{
			var icon = icons.members[0];
			icons.remove(icon, true);
			icon.destroy();
			
			icon = null;
		}
		
		icons.active = false;
		
		final trueMaxRange = MAX_ICONS + (getModByCl(AdditionalIconsModifer)?.getEffect() ?? 0);
		
		// if its static it has to be 40
		final range = gameMode.mode == STATIC ? 40 : FlxG.random.int(MIN_ICONS, trueMaxRange);
		
		for (i in 0...range - 1) // tbh with how basic this is i think its ok to not recycle .. we'll see
		{
			final icon = new FlickerIcon();
			icon.frames = atlas.getAtlasFrames();
			icon.animation.frameIndex = FlxG.random.int(0, iconUsers.length - 1);
			icons.add(icon);
		}
		
		// now add cord
		cordIcon = cast new FlickerIcon().loadSparrowFrames('minigames/findcord/icons/cord');
		cordIcon.animation.addByPrefix('idle', 'cordNormal instance 1');
		cordIcon.animation.addByPrefix('caught', 'cordCaught instance 1', 24, false);
		cordIcon.playAnim('idle');
		icons.add(cordIcon);
		
		// why is cord fucking massive dude?
		cordIcon.setGraphicSize(80);
		cordIcon.updateHitbox();
		
		FlxG.random.shuffle(icons.members);
		
		gameMode.positionIcons(icons.members); // for some reason this isnt getting applied very rarely.
		
		// apply mods to the icons
		final greyShader = getModByCl(GreyScaleModifier)?.getEffect();
		for (icon in icons)
		{
			icon.flipY = getModByCl(FlippedModifier)?.getEffect() ?? false;
			if (greyShader != null) icon.shader = greyShader;
		}
	}
	
	override function destroy()
	{
		FlxG.autoPause = ClientPrefs.data.autoPause;
		instance = null;
		ICON_WORLD_SPACE.put();
		super.destroy();
		
		atlas = FlxDestroyUtil.destroy(atlas);
	}
	
	// MODIFIER FUNCTIONS
	function getRoundTime()
	{
		return BASE_ROUND_TIME + getModByCl(TimeModifier)?.getEffect() ?? 0.0;
	}
	
	/**
	 * convenience
	 * 
	 * used for `getBestScores`
	 */
	public static function addNewScore(score:Int):Void
	{
		FlxG.save.data.__trackedFindCordScores ??= [];
		FlxG.save.data.__trackedFindCordScores.unshift(score);
		FlxG.save.flush();
	}
	
	public static function getBestScores():Array<Int>
	{
		var lastTrackedScores:Null<Array<Null<Int>>> = FlxG.save.data.__trackedFindCordScores;
		
		inline function sanitizeArray(a:Null<Array<Null<Int>>>):Array<Int>
		{
			var out:Array<Int> = [];
			if (a == null) return out;
			
			for (i in a)
				if (i != null) out.push(i);
				
			ArraySort.sort(out, (a, b) -> {
				if (a > b) return -1;
				else if (b > a) return 1;
				return 0;
			});
			
			while (out.length > 10)
			{
				out.pop();
			}
			
			return out;
		}
		
		if (lastTrackedScores != null)
		{
			final cleanedScores = sanitizeArray(lastTrackedScores);
			
			FlxG.save.data.__trackedFindCordScores = cleanedScores;
			FlxG.save.flush();
			
			return cleanedScores;
		}
		
		return [];
	}
}
