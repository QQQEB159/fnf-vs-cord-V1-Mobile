package states;

import backend.TurboControl;

import objects.OffsetSprite;

import flixel.FlxObject;

import openfl.display.PNGEncoderOptions;

import flixel.addons.display.FlxTiledSprite;
import flixel.graphics.tile.FlxGraphicsShader;

import openfl.filters.ShaderFilter;

import flixel.graphics.atlas.FlxAtlas;
import flixel.util.FlxDestroyUtil;
import flixel.tweens.misc.NumTween;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxSpriteContainer;

import objects.Bopper;

import flixel.util.typeLimit.NextState;
import flixel.effects.FlxFlicker;

import options.OptionsState;

using backend.Paths;

// need to adda  fill in the trans out cuz the sheet dont got it
// also i might reexport the sheet seperately so its more optimized

class MainMenuState extends MusicBeatState
{
	public static var options:Array<String> = ['story_mode', 'freeplay', 'stats', 'awards', 'gallery', 'credits', 'options'];
	
	public static var psychEngineVersion:String = '0.7.2'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	
	static var seenIntro:Bool = false;
	
	var bg:OffsetSprite;
	var overlay:OffsetSprite;
	var arcade:Bopper;
	var introArcade:Bopper = null;
	
	var canSelect:Bool = true;
	
	var optionGrp:FlxTypedSpriteContainer<TextSprite>;
	var flashSprites:Array<OffsetSprite> = [];
	var flashArcade:OffsetSprite;
	
	var turboDown = TurboControl.fromControl('ui_down');
	var turboUp = TurboControl.fromControl('ui_up');
	
	override function create()
	{
		add(turboDown);
		add(turboUp);
		
		turboDown.rate = 0.2;
		turboUp.rate = 0.2;
		
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();
		
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		
		super.create();
		
		persistentUpdate = persistentDraw = true;
		
		bg = new OffsetSprite(615, -10, Paths.image('menuassets/main/bgDark'));
		bg.loadGraphic(Paths.image("menuassets/main/bgNormal"));
		add(bg);
		bg.offset.set(-100, 10);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		
		final addOverlay = new OffsetSprite(0, -100, Paths.image('menuassets/main/bgIntroEffect_ADD'));
		add(addOverlay);
		flashSprites.push(addOverlay);
		
		add(new OffsetSprite(0, -56, Paths.image('menuassets/main/behindMachineBG')));
		
		optionGrp = new FlxTypedSpriteContainer();
		add(optionGrp);
		// optionGrp.visible = false;
		
		for (i in 0...options.length)
		{
			var option = new TextSprite(158, 175 + (500 * i), Paths.image('menuassets/main/menu_buttons/' + options[i]));
			option.ID = i;
			optionGrp.add(option);
		}
		
		arcade = cast new Bopper().loadSparrowFrames('menuassets/main/mainmachine');
		arcade.animation.addByPrefix('idle', 'machine_idle', 24, true);
		arcade.animation.addByPrefix('up', 'machine_up', 24, false);
		arcade.animation.addByPrefix('down', 'machine_down', 24, false);
		arcade.animation.addByPrefix('transIn', 'machine_transitionIn', 24, false);
		// arcade.animation.addByPrefix('transOut', 'machine_transitionOut0', 24, false);
		arcade.animation.addByPrefix('accept', 'machine_accept', 24, false);
		arcade.addOffset('idle', 42, 55);
		arcade.addOffset('up', 42, 55);
		arcade.addOffset('down', 42, 55);
		arcade.addOffset('accept', 42, 55);
		arcade.addOffset('transIn', 42 + 98, 55 + 93);
		// arcade.addOffset('transOut', 42 + 98, 55 + 93);
		arcade.playAnim('idle');
		add(arcade);
		arcade.scrollFactor.set();
		
		// used for the seamless effect
		if (!seenIntro)
		{
			introArcade = cast new Bopper().loadSparrowFrames('menuassets/main/intro');
			introArcade.animation.addByPrefix('i', 'machine_IntroFrame0');
			introArcade.animation.addByPrefix('out', 'machine_transitionOutIntro', 24, false);
			introArcade.addOffset('i', 78, 110);
			introArcade.addOffset('out', 141, 148);
			introArcade.playAnim('out');
			add(introArcade);
			introArcade.active = introArcade.visible = false;
			
			introArcade.scrollFactor.set();
		}
		
		flashArcade = new OffsetSprite(Paths.image('menuassets/main/machineIntroEffect_ADD'));
		add(flashArcade);
		flashArcade.offset.set(180, 216);
		flashSprites.push(flashArcade);
		
		overlay = new OffsetSprite(Paths.image('menuassets/main/overlay_ADD'));
		overlay.blend = ADD;
		overlay.offset.set(200, 200);
		add(overlay);
		overlay.alpha = 0;
		
		for (i in flashSprites)
		{
			i.blend = ADD;
			i.alpha = 0;
		}
		
		if (!seenIntro)
		{
			MusicBeatState.currentTransition = SWIPE;
			
			CoolUtil.getMenuMusic();
			seenIntro = true;
			intro();
			
			FlxTween.tween(FlxG.stage.window, {width: backend.Native.windowWidth}, 0.7,
				{
					startDelay: 0.3,
					ease: FlxEase.cubeInOut,
					onUpdate: CoolUtil.centerWindow,
					onComplete: Void -> {
						FlxG.stage.window.resizable = true;
						
						@:privateAccess
						(cast FlxG.scaleMode : flixel.system.scaleModes.RatioScaleMode).fillScreen = false;
						
						CoolUtil.centerWindow();
					}
				});
				
			updateTextPos(true);
		}
		else
		{
			var snd = CoolUtil.getMenuMusic();
			if (FlxG.sound.music == null || FlxG.sound.music.length != snd.length)
			{
				CoolUtil.playMenuMusic();
			}
			FlxG.sound.music.pitch = 1;
			
			updateTextPos(true);
			canSelect = false;
			arcade.playAnim('transIn', true, true);
			
			FlxTimer.wait(0.2, () -> FlxG.sound.play(Paths.sound('main/woosh')));
			if (FlxG.sound.music.volume < 0.6) FlxG.sound.music.fadeIn();
			
			overlay.alpha = 0;
			FlxTween.tween(overlay, {alpha: 1}, 0.5, {startDelay: 1});
			
			slideCamera(false);
			
			arcade.animation.onFinish.addOnce(anim -> {
				canSelect = true;
				arcade.playAnim('idle');
				
				for (i in optionGrp)
				{
					// i hate flxflicker
					FlxFlicker.flicker(i, 0.25, 0.025, true);
				}
			});
		}
		
		FlxTransitionableState.skipNextTransIn = true;
		
		#if ACHIEVEMENTS_ALLOWED
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) Achievements.unlock('friday');
		#end
	}
	
	function slideCamera(into:Bool)
	{
		FlxG.camera.scroll.x = into ? 0 : -50;
		FlxTween.tween(FlxG.camera.scroll, {x: into ? -50 : 0}, 0.7, {startDelay: into ? 0.1 : 1, ease: into ? FlxEase.cubeIn : FlxEase.cubeOut});
	}
	
	override function update(elapsed:Float)
	{
		if (canSelect)
		{
			if (turboUp.PRESSED || turboDown.PRESSED) changeSelection(controls.UI_DOWN ? 1 : -1);
			if (controls.ACCEPT) loadMenu(options[curSelected]);
		}
		
		if (controls.justPressed('debug_1'))
		{
			FlxG.switchState(() -> new states.editors.MasterEditorMenu());
		}
		
		super.update(elapsed);
	}
	
	function intro()
	{
		canSelect = false;
		
		var startupSnd = FlxG.sound.play(Paths.sound('main/startup'));
		
		for (i in optionGrp)
			i.visible = false;
			
		arcade.visible = false;
		overlay.visible = false;
		bg.loadGraphic(Paths.image('menuassets/main/bgDark'));
		
		slideCamera(false);
		
		var tmr:Null<FlxTimer> = null;
		introArcade.animation.onFrameChange.add((anim, num, idx) -> {
			if (num == 40) // THIS IS THE STATIC PART
			{
				if (ClientPrefs.data.currentMenuMusic == TRACK_01) FlxG.sound.play(Paths.sound('main/riser'));
				
				FlxTween.tween(flashArcade, {alpha: 1, 'scale.x': 1.05, 'scale.y': 1.05}, 1.2, {ease: FlxEase.quintIn});
				var rate:Float = 0;
				
				FlxTween.cancelTweensOf(FlxG.camera);
				FlxTween.tween(FlxG.camera, {zoom: 1.025}, 1.3, {ease: FlxEase.quintIn});
				
				tmr = new FlxTimer().start(0.05, (tmr) -> {
					var x = FlxG.random.float(-rate, rate);
					var y = FlxG.random.float(-rate, rate);
					forEachOfType(OffsetSprite, spr -> {
						spr.offset2.x = x;
						spr.offset2.y = y;
					});
					
					rate += 0.2;
				}, 0);
			}
		});
		
		introArcade.playAnim('out');
		introArcade.animation.finishCallback = (animName:String) -> {
			bg.loadGraphic(Paths.image("menuassets/main/bgNormal"));
			introArcade.active = introArcade.visible = false;
			tmr?.cancel();
			forEachOfType(OffsetSprite, spr -> {
				spr.offset2.x = 0;
				spr.offset2.y = 0;
				// FlxTween.tween(spr, {'offset2.x': 0, 'offset2.y': 0}, 0.2);
			});
			
			FlxTween.cancelTweensOf(FlxG.camera);
			FlxTween.tween(FlxG.camera, {zoom: 1}, 0.75, {ease: FlxEase.quartOut});
			// FlxG.camera.zoom = 1;
			
			startupSnd?.stop();
			CoolUtil.playMenuMusic();
			
			FlxG.sound.play(Paths.sound('main/thisSoundPlaysWhenTheMachineTurnsOn'), 0.5);
			
			arcade.visible = true;
			overlay.visible = true;
			
			for (i in optionGrp)
				i.visible = true;
				
			overlay.alpha = 1;
			FlxTween.tween(overlay, {alpha: 0}, 0.6);
			
			FlxTween.cancelTweensOf(flashArcade);
			FlxTween.tween(flashArcade, {alpha: 0, 'scale.x': 1, 'scale.y': 1}, 1, {ease: FlxEase.cubeOut});
			for (i in flashSprites)
			{
				if (i == flashArcade) continue;
				i.alpha = 1;
				FlxTween.tween(i, {alpha: 0}, 0.6);
			}
			
			FlxTimer.wait(0.3, () -> canSelect = true);
		}
		introArcade.visible = introArcade.active = true;
	}
	
	function loadMenu(option:String)
	{
		canSelect = false;
		
		arcade.playAnim('accept');
		
		FlxTween.tween(overlay, {alpha: 0}, 0.5, {startDelay: 1});
		
		flashSprites[flashSprites.length - 1].alpha = 1;
		FlxTween.tween(flashSprites[flashSprites.length - 1], {alpha: 0}, 0.25);
		
		FlxFlicker.flicker(optionGrp.members[curSelected], 1, 0.05, false);
		FlxTimer.wait(1, () -> {
			FlxTimer.wait(0.2, () -> FlxG.sound.play(Paths.sound('main/woosh')));
			
			arcade.playAnim('transIn');
			slideCamera(true);
		});
		
		if (option == 'options' || option == 'gallery' || option == 'freeplay' || option == 'credits')
		{
			//
			FlxG.sound.music.fadeOut(2, 0);
		}
		
		FlxG.sound.play(Paths.sound('main/button press'));
		
		arcade.animation.onFinish.add((anim) -> if (anim == 'transIn') selectedOption(option));
	}
	
	function selectedOption(val:String)
	{
		final state:NextState = switch (val)
		{
			case 'story_mode':
				() -> new StoryMenuState();
			case 'freeplay':
				() -> new states.FreeplayMenuCord();
			case 'stats':
				() -> new StatsMenuState();
			case 'awards':
				() -> new AchievementsMenuState();
			case 'gallery':
				() -> new GalleryState();
			case 'credits':
				() -> new states.credits.CreditsPlatformer();
			case 'options':
				OptionsState.onPlayState = false;
				if (PlayState.SONG != null)
				{
					PlayState.SONG.arrowSkin = null;
					PlayState.SONG.splashSkin = null;
				}
				FlxTransitionableState.skipNextTransOut = true;
				() -> new OptionsState();
			default:
				() -> new MainMenuState();
		}
		
		FlxG.switchState(state);
	}
	
	var unWrappedCurSelected:Int = 0;
	
	function changeSelection(diff:Int = 0)
	{
		unWrappedCurSelected += diff;
		
		curSelected = FlxMath.wrap(curSelected + diff, 0, options.length - 1);
		
		updateTextPos();
		
		arcade.playAnim(diff == -1 ? 'up' : 'down', true);
		
		if (diff != 0)
		{
			FlxG.sound.play(Paths.sound('main/c_stick lower'));
		}
	}
	
	function updateTextPos(snap:Bool = false)
	{
		for (k => i in optionGrp.members)
		{
			i.move(k - curSelected, snap);
		}
	}
}

private class TextSprite extends FlxSprite
{
	public var visualPosition:FlxPoint = FlxPoint.get();
	
	var tween:NumTween = null;
	
	public function move(idx:Int, snap:Bool = false)
	{
		final newY = 175 + (500 * idx);
		
		if (snap)
		{
			y = newY;
			visualPosition.y = y;
		}
		else
		{
			final ease = tween != null ? FlxEase.backOut : FlxEase.backInOut;
			
			tween?.cancel();
			
			tween = FlxTween.num(visualPosition.y, newY, 0.425, {ease: ease, onComplete: Void -> tween = null}, (val) -> visualPosition.y = val);
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		y = CoolUtil.decayLerp(y, visualPosition.y, 40, elapsed);
	}
	
	override function destroy()
	{
		visualPosition = FlxDestroyUtil.put(visualPosition);
		super.destroy();
	}
}
