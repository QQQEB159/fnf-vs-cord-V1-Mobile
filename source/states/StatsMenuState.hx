package states;

import openfl.display.BitmapData;

import shaders.ColorSwapImproved;
import shaders.ColorSwap;

import haxe.Http;

import openfl.display.BlendMode;

import io.newgrounds.NG;

import flixel.group.FlxSpriteContainer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

import extensions.flixel.FlxBackdropEx;

import api.NewgroundsClient;

import backend.Stats;

import options.OptionsText;

class StatsMenuState extends MusicBeatState
{
	public static final NG_ACTIVE_HUE:Float = 0.20;
	
	public static final BACKDROP_BLUE:FlxColor = 0x307CCED4;
	
	public var canInteract:Bool = true;
	
	public var bgShader = new ColorSwapImproved();
	
	public var patternBackdrop:FlxBackdropEx;
	
	var cord:FlxAnimate;
	
	var totalTimePlayed:FlxText;
	var clock:FlxSprite;
	
	var loginPrompt:FlxText;
	final loginTextHighlight:FlxColor = 0xFFFFBA13;
	
	var uiElements:FlxSpriteContainer;
	
	var ngIcon:FlxSprite;
	
	var userIcon:FlxSprite;
	
	var achievements:FlxBackdrop;
	
	var tvGlow:FlxSprite = null;
	
	override function create()
	{
		super.create();
		
		persistentUpdate = true;
		
		final bgImage = new FlxSprite(0, 0, Paths.image('menuassets/stats/bg'));
		bgImage.antialiasing = ClientPrefs.data.antialiasing;
		bgImage.scale.scale(1.2);
		add(bgImage);
		
		bgImage.shader = bgShader;
		bgShader.hue = NG_ACTIVE_HUE;
		bgShader.brightness = 0.5;
		bgShader.saturation = -0.1;
		
		var backdrop = new FlxBackdrop(FlxGridOverlay.create(100, 100, 200, 200, true, FlxColor.BLACK, 0x0).graphic);
		backdrop.velocity.set(50, 50);
		add(backdrop);
		backdrop.alpha = 0.15;
		
		patternBackdrop = new FlxBackdropEx(Paths.image('menuassets/stats/pattern'));
		patternBackdrop.velocity.set(-15, -15);
		add(patternBackdrop);
		patternBackdrop.rotation = -15;
		patternBackdrop.antialiasing = ClientPrefs.data.antialiasing;
		patternBackdrop.alpha = 0.2;
		patternBackdrop.color = 0x30FFFFFF;
		patternBackdrop.scale.scale(1.2);
		patternBackdrop.blend = BlendMode.ADD;
		
		if (!NewgroundsClient.active)
		{
			bgShader.mix = 0;
			patternBackdrop.color = BACKDROP_BLUE;
		}
		
		uiElements = new FlxSpriteContainer();
		uiElements.scrollFactor.set();
		add(uiElements);
		
		final bg2 = new FlxSprite(0, 0, Paths.image('menuassets/stats/statsBG'));
		bg2.antialiasing = ClientPrefs.data.antialiasing;
		uiElements.add(bg2);
		
		final statsTxt = new FlxSprite(300, 15).loadSparrowFrames('menuassets/stats/text');
		statsTxt.animation.addByPrefix('i', 'stats instance 1', 24);
		statsTxt.animation.play('i');
		uiElements.add(statsTxt);
		
		loginPrompt = new FlxText(FlxG.width, 25, 0, "Login?...", 50);
		loginPrompt.setFormat(Paths.font("NG.otf"), 50, loginTextHighlight, CENTER);
		uiElements.add(loginPrompt);
		
		ngIcon = new FlxSprite(1189, 12, Paths.image('menuassets/stats/ngLogo'));
		ngIcon.antialiasing = ClientPrefs.data.antialiasing;
		uiElements.add(ngIcon);
		
		userIcon = new FlxSprite();
		userIcon.antialiasing = ClientPrefs.data.antialiasing;
		uiElements.add(userIcon);
		userIcon.visible = false;
		
		clock = new FlxSprite(1217, 109, Paths.image('menuassets/stats/clock'));
		clock.antialiasing = ClientPrefs.data.antialiasing;
		uiElements.add(clock);
		
		totalTimePlayed = new OptionsText(0, 0, 0, '', 22);
		totalTimePlayed.color = FlxColor.WHITE;
		totalTimePlayed.borderColor = FlxColor.BLACK;
		totalTimePlayed.borderStyle = OUTLINE;
		totalTimePlayed.borderSize = 2;
		uiElements.add(totalTimePlayed);
		
		var fields = Std.string(Stats.instance).split('\n');
		
		for (k => field in fields)
		{
			if (field.length < 1) continue;
			final text = new OptionsText(145, 112 + (k * 49), 0, field, 22);
			if (k % 2 == 0) text.color = 0xFFC6C6C6;
			uiElements.add(text);
		}
		
		var previousImage:FlxSprite = null;
		for (k => i in ['sick', 'good', 'bad', 'shit'])
		{
			final spr = new FlxSprite(145, 444, Paths.image(i));
			uiElements.add(spr);
			
			spr.scale.scale(0.5);
			spr.updateHitbox();
			
			if (previousImage != null)
			{
				spr.y = previousImage.y + previousImage.height + 20;
			}
			
			// this is duct tape but i also dont thjink it really matters
			var value = new OptionsText(145, (112 + ((fields.length - 1) * 49) + (k * 72) + 10), 570, '', 22); // LOWKEY dont do this rewrite this latger !
			value.alignment = RIGHT;
			if (k % 2 != 0) value.color = 0xFFC6C6C6;
			uiElements.add(value);
			
			switch (i)
			{
				case 'sick':
					value.text = Std.string(Stats.instance.totalSicks);
				case 'good':
					value.text = Std.string(Stats.instance.totalGoods);
				case 'bad':
					value.text = Std.string(Stats.instance.totalBads);
				case 'shit':
					value.text = Std.string(Stats.instance.totalShits);
					
					spr.y -= 15;
					spr.scale.scale(0.9);
					spr.updateHitbox();
			}
			
			previousImage = spr;
		}
		
		cord = new extensions.flxanimate.FlxAnimateEx(520, 110).loadAtlas('menuassets/stats/cord');
		cord.anim.addBySymbol('sleep', 'cordAnims/cordSleep', 24);
		cord.anim.addBySymbol('tv', 'cordAnims/cordTV', 24);
		cord.anim.addBySymbol('tap', 'cordAnims/cordTap', 24);
		cord.anim.addBySymbol('fall', 'cordAnims/cordFall', 24, false);
		cord.anim.play(FlxG.random.bool(50) ? 'tv' : 'sleep');
		
		cord.animation.onFrameChange.add((anim, num, idx) -> {
			if (anim == 'fall' && idx == 32)
			{
				FlxG.camera.shake(0.01, 1);
			}
		});
		
		cord.animation.onFinish.add((anim) -> {
			if (anim == 'fall')
			{
				cord.active = false;
				return;
			}
			cord.anim.play('sleep');
		});
		
		uiElements.insert(0, cord);
		
		if (cord.animation.curAnim.name == 'tv')
		{
			tvGlow = new FlxSprite(675, 100, Paths.image('menuassets/stats/tvGlow_ADD'));
			tvGlow.blend = ADD;
			
			new FlxTimer().start(0.05, (t) -> {
				tvGlow.alpha = FlxG.random.float(0.9, 1);
			}, 0);
			uiElements.insert(uiElements.members.indexOf(cord) + 1, tvGlow);
		}
		
		snoreZs = new FlxSpriteGroup(150, 80);
		add(snoreZs);
		
		if (cord.animation.curAnim.name == 'sleep') makeZs();
		
		requestProfilePicture();
		
		createAchievementsWall();
	}
	
	function createAchievementsWall()
	{
		final list = ['weekCord_nomiss', 'weekParty_nomiss', 'djSideQuest_nomiss', 'catSideQuest_nomiss', 'menuMusic', 'blueBalled10', 'NG', '6hours', '1mScore', 'friday', 'miss100', '20percent', 'pRank', 'goldenPRank', '50kScore', 'modifier', '100rounds'];
		var bmp = new FlxSprite().makeGraphic(151, Math.round(150 * list.length), FlxColor.TRANSPARENT);
		
		bmp.antialiasing = true;
		for (i in 0...list.length)
		{
			var isUnlocked = Achievements.isUnlocked(list[i]);
			
			var achievement = new FlxSprite(0, 0, Paths.image('achievements/' + (isUnlocked ? list[i] : 'locked')));
			add(achievement);
			achievement.scale.scale(0.85);
			achievement.updateHitbox();
			
			achievement.kill();
			
			bmp.stamp(achievement, 0, 150 * i);
			
			achievement.antialiasing = true;
		}
		
		// CoolUtil.pngFromFlxSprite(bmp, 'for_rose');
		bmp.kill();
		
		achievements = new FlxBackdrop(bmp.graphic, Y);
		achievements.velocity.y = -40;
		achievements.setGraphicSize(129);
		achievements.updateHitbox();
		achievements.antialiasing = true;
		add(achievements);
	}
	
	var camFollowDivision:Float = 40;
	
	var snoreZs:FlxSpriteGroup;
	
	var snoreTimer:Float = 0;
	
	var canSnore:Bool = true;
	
	function makeZs()
	{
		//
		
		canSnore = false;
		
		for (i in 0...3)
		{
			var revI = 3 - i;
			
			var z = snoreZs.recycle(FlxSprite);
			
			FlxTween.cancelTweensOf(z, ['alpha']);
			
			if (z.frames == null)
			{
				z.frames = Paths.getSparrowAtlas('menuassets/stats/zzz');
				z.animation.addByPrefix('i', 'z', 24, false);
			}
			z.setPosition(cord.x + 350 + (-30 * i), cord.y + 100 + (-30 * i));
			z.alpha = 0;
			z.angle = 0;
			z.antialiasing = true;
			FlxTween.tween(z, {alpha: 1, angle: 10}, 0.7, {startDelay: i * 0.2, ease: FlxEase.sineOut});
			
			z.velocity.x = -5;
			z.velocity.y = -5 * i % 2;
			
			FlxTween.tween(z, {alpha: 0}, 0.5,
				{
					startDelay: 2 + (i * 0.2),
					onComplete: Void -> {
						z.kill();
						if (i == 2)
						{
							canSnore = true;
						}
					}
				});
				
			z.animation.play('i');
			snoreZs.add(z);
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (!controls.UI_DOWN || !controls.UI_UP)
		{
			achievements.velocity.y = FlxG.keys.pressed.SHIFT ? -80 : -40;
		}
		
		loginPrompt.x = CoolUtil.decayLerp(loginPrompt.x, FlxG.width - loginPrompt.width - 100, 40, elapsed);
		
		final isOverLogin = FlxG.mouse.overlaps(loginPrompt);
		
		loginPrompt.text = isOverLogin ? NewgroundsClient.active ? 'LogOut?...' : 'Login?...' : NewgroundsClient.sessionData?.userData.name ?? 'Login?...';
		
		// trace(cord.anim?.curInstance?.symbol.name);
		
		if (cord.active && canSnore && ((snoreTimer += elapsed) > 5) && cord.anim.curAnim?.name == 'sleep')
		{
			snoreTimer %= 5;
			makeZs();
		}
		
		if (canInteract)
		{
			handleMouse(elapsed);
			
			if (controls.BACK)
			{
				canInteract = false;
				FlxG.switchState(() -> new MainMenuState());
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.mouse.visible = false;
			}
			
			loginPrompt.color = isOverLogin ? FlxColor.WHITE : loginTextHighlight;
			
			if (isOverLogin)
			{
				if (FlxG.mouse.justPressed)
				{
					openSubState(new NGLoginSubstate(NewgroundsClient.active ? LOGGING_OUT : LOGGING_IN, this));
				}
			}
			
			if (cord.active && FlxG.mouse.justPressed && FlxG.mouse.x > 1117 && FlxG.mouse.x < 1260 && FlxG.mouse.y > 275 && FlxG.mouse.y < 400 && cord.anim.curAnim?.name != 'fall' && cord.animation.curAnim?.name != 'tv')
			{
				if (FlxG.random.bool(15))
				{
					cord.anim.play('fall');
					FlxG.sound.play(Paths.sound('stats/cordChairFall'));
				}
				else
				{
					cord.anim.play('tap', true);
					FlxG.sound.play(Paths.sound('stats/boop'));
				}
			}
		}
		
		updateTimeTxt(elapsed);
	}
	
	public function requestProfilePicture()
	{
		if (!NewgroundsClient.active || NG.core.user == null || NG.core.user.icons == null) return;
		
		final url = NG.core.user.icons.large;
		
		var http = new Http(url);
		http.onBytes = (bytes) -> {
			if (url.contains('webp') || url.contains('.png'))
			{
				if (Paths.currentTrackedAssets.exists(url))
				{
					var graphic = Paths.currentTrackedAssets.get(url);
					
					if (graphic == null) return;
					
					userIcon.loadGraphic(graphic);
					userIcon.setGraphicSize(0, ngIcon.height);
					userIcon.updateHitbox();
				}
				else
				{
					var bitmap:BitmapData = null;
					if (url.contains('.png'))
					{
						try
						{
							bitmap = BitmapData.fromBytes(bytes);
						}
						catch (e) {}
					}
					#if hxWebP
					else if (url.contains('webp'))
					{
						try
						{
							bitmap = webp.WebP.getBitmapDataFromBytes(bytes);
						}
						catch (e) {}
					}
					#end
					if (bitmap == null) return;
					
					var img = Paths.cacheBitmap(url, bitmap, false);
					if (img == null) return;
					
					userIcon.loadGraphic(img);
					userIcon.setGraphicSize(0, ngIcon.height);
					userIcon.updateHitbox();
				}
			}
			else
			{
				userIcon.loadGraphic(Paths.image('menuassets/stats/icon-user'));
				userIcon.setGraphicSize(0, ngIcon.height);
				userIcon.updateHitbox();
			}
			
			userIcon.centerOnObject(ngIcon);
			userIcon.visible = true;
			ngIcon.visible = false;
		}
		http.request();
	}
	
	@:noCompletion var _prevX:Float = 0;
	@:noCompletion var _prevY:Float = 0;
	
	var timeout:Float = 0;
	
	@:access(openfl.display.Stage)
	function handleMouse(elapsed:Float)
	{
		// flixels fuck ass system doesnt actually work bitch ass system die
		inline function hasMoved() return (FlxG.stage.stage.__mouseX != _prevX || FlxG.stage.__mouseY != _prevY);
		
		if (hasMoved() || FlxG.mouse.justPressed)
		{
			timeout = 1;
			FlxG.mouse.visible = true;
		}
		else if (timeout > 0)
		{
			timeout -= elapsed;
		}
		else if (FlxG.mouse.visible)
		{
			FlxG.mouse.visible = false;
		}
		
		_prevX = FlxG.stage.stage.__mouseX;
		_prevY = FlxG.stage.stage.__mouseY;
	}
	
	function cameraMovement(elapsed:Float)
	{
		FlxG.mouse.visible = true;
		
		final x = (FlxG.mouse.viewX - (FlxG.width / 2)) / camFollowDivision;
		final y = (FlxG.mouse.viewY - (FlxG.height / 2)) / camFollowDivision;
		
		FlxG.camera.scroll.x = CoolUtil.decayLerp(FlxG.camera.scroll.x, x, 3, elapsed);
		FlxG.camera.scroll.y = CoolUtil.decayLerp(FlxG.camera.scroll.y, y, 3, elapsed);
	}
	
	var timeAddition:Float = 0;
	
	function updateTimeTxt(elapsed:Float)
	{
		timeAddition += elapsed;
		
		final timePlayed = Stats.instance.timePlayed + Math.floor(timeAddition);
		
		final timeMinutes = Std.int(timePlayed / 60) % 60;
		
		final timeHours = Std.int((timePlayed / 60) / 60);
		
		final timeSeconds = Std.int(timePlayed) % 60;
		
		final resultedTime = '${addZero(timeHours)}:${addZero(timeMinutes)}:${addZero(timeSeconds)}';
		
		totalTimePlayed.text = resultedTime;
		
		totalTimePlayed.x = clock.x - totalTimePlayed.width;
		totalTimePlayed.y = clock.y + (clock.height - totalTimePlayed.height) / 2;
	}
	
	inline function addZero(val:Int)
	{
		if (val < 10) return '0' + Std.string(val);
		
		return Std.string(val);
	}
}

enum abstract LoginState(Int)
{
	var LOGGING_IN;
	var LOGGING_OUT;
}

private class NGLoginSubstate extends MusicBeatSubstate
{
	final parent:StatsMenuState;
	final state:LoginState;
	
	var canInteract:Bool = false;
	
	var header:FlxText;
	
	public function new(state:LoginState, parent:StatsMenuState)
	{
		this.parent = parent;
		this.state = state;
		
		parent.canInteract = false;
		super();
	}
	
	override function create()
	{
		if (state == LOGGING_IN)
		{
			NewgroundsClient.newgroundsLogin((rq) -> {
				exit();
				FlxG.sound.play(Paths.sound('main/select'));
				FlxTween.tween(parent.bgShader, {mix: 1}, 0.4);
				FlxTween.color(parent.patternBackdrop, 0.4, parent.patternBackdrop.color, 0x30FFFFFF);
			});
		}
		
		final headerTxt = state == LOGGING_IN ? 'Connecting...' : 'Logout?';
		
		final subTxt = state == LOGGING_IN ? "You will now be redirected to the \"Newgrounds Passport\" website. This lets users log in (or sign up) to Newgrounds.com and Apps using Newgrounds.io without risk of data being stolen.\nPress anything to ignore and exit." : 'Press Enter to logout of newgrounds. Press ESC to exit this prompt.';
		
		super.create();
		
		var bg:FlxSprite = new FlxSprite().makeScaledGraphic(FlxG.width * 0.7, FlxG.height * 0.7, 0xDF000000);
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);
		
		header = new FlxText(bg.x + 25, FlxG.height * 0.4, bg.width - 50, headerTxt, 55);
		header.setFormat(Paths.font("NG.otf"), 55, 0xFFFFBA13, CENTER);
		header.scrollFactor.set();
		add(header);
		
		var subtext:FlxText = new FlxText(bg.x + 25, header.y + 100, bg.width - 50, subTxt, 24);
		subtext.setFormat(Paths.font("NG.otf"), 24, 0xFFFFFFFF, CENTER);
		subtext.scrollFactor.set();
		add(subtext);
		
		FlxTimer.wait(0, () -> canInteract = true);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (canInteract)
		{
			if (state == LOGGING_IN)
			{
				if (FlxG.keys.firstJustPressed() != -1)
				{
					NG.core.cancelLoginRequest();
					canInteract = false;
				}
			}
			else
			{
				if (controls.BACK)
				{
					exit();
				}
				else if (controls.ACCEPT)
				{
					header.text = 'Logging out...';
					NewgroundsClient.logOut((rq) -> {
						exit();
						FlxG.sound.play(Paths.sound('settingsBack'));
						@:privateAccess
						{
							parent.userIcon.visible = false;
							parent.ngIcon.visible = true;
						}
						
						FlxTween.tween(parent.bgShader, {mix: 0}, 0.4);
						FlxTween.color(parent.patternBackdrop, 0.4, parent.patternBackdrop.color, StatsMenuState.BACKDROP_BLUE);
					});
					canInteract = false;
				}
			}
		}
	}
	
	function exit()
	{
		forEachAlive(spr -> {
			FlxTween.tween(spr, {alpha: 0}, 0.6);
		});
		
		FlxTimer.wait(0.6, () -> {
			close();
			parent.canInteract = true;
			
			parent.requestProfilePicture();
		});
	}
}
