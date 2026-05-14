package states.minigames;

import flixel.util.FlxStringUtil;

import states.minigames.rosiesim.StarBearModiferModule.StarBearModifierModule;

import BigInt;

import flixel.util.FlxDestroyUtil;

import api.NewgroundsClient;

import flixel.group.FlxContainer.FlxTypedContainer;

import options.OptionsState;

import backend.InputFormatter;

import flixel.input.keyboard.FlxKey;

import Init.RosieClickerCursor;

import haxe.Int64;

import flixel.FlxObject;
import flixel.addons.display.FlxBackdrop;

import options.OptionsText;

import shaders.ColorSwapImproved;

import states.minigames.rosiesim.*;

// abit messy but thats ok
// todo cleanup
// add events on specific clicks
// make buying outfits work
// more polish

/**
 * Cookie clicker clone
 */
class RosieSimV2 extends MusicBeatState
{
	static final SAVE_INTERVAL:Float = 30;
	
	public var clicks(default, set):BigInt;
	
	public var rosie:Rosie;
	
	public var enabled:Bool = true;
	
	var clickTimer:Float = 0;
	
	var clickHits:Array<Float> = [];
	
	public var cordMusic = FlxG.sound.load(Paths.music('minigames/M3'), 1, true);
	
	var saveSpr:FlxSprite;
	var saveTimer:FlxTimer;
	
	var clickText:FlxText;
	var clicksPerSecText:FlxText;
	var songText:FlxText;
	
	public var bgShader:ColorSwapImproved;
	
	var outfitSpr:FlxSprite;
	var bgPlushes:FlxTypedGroup<FlxSprite>;
	
	var ngLogo:FlxSprite;
	
	var perClickTextGrp:FlxTypedContainer<PopUpText>;
	
	public static inline function viewCenter(obj:FlxObject)
	{
		obj.x = obj.getDefaultCamera().viewLeft + (obj.getDefaultCamera().viewWidth - obj.width) / 2;
		obj.y = obj.getDefaultCamera().viewTop + (obj.getDefaultCamera().viewHeight - obj.height) / 2;
		return obj;
	}
	
	var backgroundGradient:FlxSprite;
	var tiledPattern:FlxBackdrop;
	
	var controllerConfirmButton:FlxSprite;
	var controllerShopButton:FlxSprite;
	
	public var starBearModifierModule:StarBearModifierModule;
	public var nolimeModifierModule:NolimeModifierModule;
	
	override function create()
	{
		super.create();
		
		starBearModifierModule = new StarBearModifierModule();
		add(starBearModifierModule);
		
		nolimeModifierModule = new NolimeModifierModule();
		add(nolimeModifierModule);
		
		Conductor.bpm = 108;
		
		persistentUpdate = true;
		
		FlxG.mouse.load(new RosieClickerCursor(0, 0), 0.25);
		
		saveTimer = new FlxTimer().start(SAVE_INTERVAL, (tmr) -> flush(true), 0);
		
		if (FlxG.save.data._cachedClicksBinaryString != null)
		{
			clicks = BigInt.fromBinaryString(FlxG.save.data._cachedClicksBinaryString);
		}
		else clicks = BigInt.fromInt(0);
		
		FlxG.sound.playMusic(Paths.music('minigames/M2'), 0);
		
		FlxG.camera.zoom = FlxG.width / 1920;
		FlxG.camera.scroll.x = (1920 - FlxG.width) / 2;
		FlxG.camera.scroll.y = (1080 - FlxG.height) / 2;
		
		bgShader = new ColorSwapImproved();
		
		backgroundGradient = new FlxSprite(Paths.image('minigames/rosieclicker/bg'));
		add(backgroundGradient);
		viewCenter(backgroundGradient);
		backgroundGradient.antialiasing = ClientPrefs.data.antialiasing;
		backgroundGradient.shader = bgShader;
		
		tiledPattern = new FlxBackdrop(Paths.image('minigames/rosieclicker/patternAlpha25Multiply'));
		tiledPattern.blend = MULTIPLY;
		tiledPattern.velocity.set(25, 25);
		tiledPattern.alpha = 0.25;
		add(tiledPattern);
		tiledPattern.antialiasing = ClientPrefs.data.antialiasing;
		
		final bg = new FlxSprite(-3, -18, Paths.image('minigames/rosieclicker/border'));
		add(bg);
		viewCenter(bg);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		
		bgPlushes = new FlxTypedGroup();
		add(bgPlushes);
		
		outfitSpr = new FlxSprite(1731, 900).loadSparrowFrames('minigames/rosieclicker/outift');
		outfitSpr.animation.addByPrefix('default', 'outfitsDefault instance 1');
		outfitSpr.animation.addByPrefix('selected', 'outfitsSelected instance 1');
		outfitSpr.animation.play('default');
		add(outfitSpr);
		outfitSpr.antialiasing = ClientPrefs.data.antialiasing;
		
		ngLogo = new FlxSprite(0, outfitSpr.y, Paths.image('minigames/rosieclicker/ngLogo'));
		add(ngLogo);
		ngLogo.antialiasing = ClientPrefs.data.antialiasing;
		ngLogo.x = outfitSpr.x - ngLogo.width - 25;
		ngLogo.visible = NewgroundsClient.active;
		
		rosie = new Rosie(Paths.image('minigames/rosieclicker/rosie'));
		add(rosie);
		viewCenter(rosie);
		rosie.antialiasing = ClientPrefs.data.antialiasing;
		
		clickText = new OptionsText(184, 225, 0, clicks.toString(), 48);
		add(clickText);
		clickText.color = FlxColor.WHITE;
		
		clicksPerSecText = new OptionsText(184, 335, 0, Std.string(clicks), 48);
		add(clicksPerSecText);
		clicksPerSecText.color = FlxColor.WHITE;
		
		songText = new OptionsText(0, 1080 - 48 - 40, 1920, '', 24);
		add(songText);
		songText.color = FlxColor.WHITE;
		songText.alignment = CENTER;
		
		controllerConfirmButton = new FlxSprite(Paths.image('minigames/rosieclicker/controller_icons/' + (Controls.isPsController() ? 'ps_press' : 'xbox_press')));
		add(controllerConfirmButton);
		viewCenter(controllerConfirmButton);
		controllerConfirmButton.antialiasing = true;
		controllerConfirmButton.y = 850;
		
		controllerShopButton = new FlxSprite(Paths.image('minigames/rosieclicker/controller_icons/' + (Controls.isPsController() ? 'ps_shop' : 'xbox_shop')));
		add(controllerShopButton);
		controllerShopButton.antialiasing = true;
		controllerShopButton.centerOnObject(outfitSpr, X).y += 10;
		controllerShopButton.y = outfitSpr.y - (controllerShopButton.height * 1.25);
		
		//
		rosie.outfit = FlxG.save.data._rosieClickerOutfit ?? Outfit.ROSE;
		switch (rosie.outfit)
		{
			case CROC:
				applySecret('DATA3');
				
			case DATA_ROSE:
				applySecret('DATA5');
				
			case STARBEAR:
				applySecret('STAR');
				
			case INFRY_NOM:
				applySecret('67');
				
			case NOLIME:
				applySecret('NOLIME');
			default:
		}
		
		perClickTextGrp = new FlxTypedContainer();
		add(perClickTextGrp);
		
		usesXbox = !Controls.isPsController();
	}
	
	var _lastm2:Bool = false;
	
	public function showSongTxt(m2:Bool = false)
	{
		if (_lastm2 == m2)
		{
			return;
		}
		_lastm2 = m2;
		songText.text = 'Now Playing: pet in the tv OST - ' + (m2 ? 'M2' : 'M3');
		FlxTween.cancelTweensOf(songText, ['alpha']);
		FlxTween.tween(songText, {alpha: 1}, 1,
			{
				onComplete: Void -> {
					FlxTween.tween(songText, {alpha: 0}, 0.5, {startDelay: 1});
				}
			});
	}
	
	function updateOutfitSprAnim(over:Bool)
	{
		outfitSpr.animation.play(over ? 'selected' : 'default');
		outfitSpr.centerOffsets();
		if (over)
		{
			outfitSpr.offset.y += 2;
		}
	}
	
	var _typed:String = '';
	var _timeout:Float = 0;
	
	function handleSecrets(e:Float)
	{
		final key:FlxKey = FlxG.keys.firstJustPressed();
		if (key != -1)
		{
			_timeout = 1;
			
			switch (key)
			{
				case ONE | TWO | THREE | FOUR | FIVE | SIX | SEVEN | EIGHT | NINE | NUMPADONE | NUMPADTWO | NUMPADTHREE | NUMPADFOUR | NUMPADFIVE | NUMPADSIX | NUMPADSEVEN | NUMPADEIGHT | NUMPADNINE:
					_typed += InputFormatter.getKeyName(key);
					
				default:
					_typed += key.toString();
			}
			applySecret(_typed);
		}
		
		if (_timeout > 0)
		{
			_timeout -= e;
			if (_timeout <= 0)
			{
				_typed = '';
			}
		}
	}
	
	function applySecret(input:String)
	{
		switch (input)
		{
			case 'DATA5':
				if (rosie.outfit == DATA_ROSE) return;
				FlxG.sound.play(Paths.sound('minigames/rosieclicker/switch'));
				FlxG.camera.flash();
				
				rosie.outfit = DATA_ROSE;
			case '67':
				if (rosie.outfit != INFRY_NOM)
				{
					FlxG.sound.play(Paths.sound('minigames/rosieclicker/switch'));
					FlxG.camera.flash();
					
					rosie.outfit = INFRY_NOM;
				}
				
				FlxG.sound.music.pitch = 0.4;
			case 'STAR':
				if (rosie.outfit != STARBEAR)
				{
					FlxG.sound.play(Paths.sound('minigames/rosieclicker/switch'));
					FlxG.camera.flash();
					
					rosie.outfit = STARBEAR;
				}
				
				FlxG.sound.music.pitch = 1.4;
			case 'DATA3':
				if (rosie.outfit != CROC)
				{
					FlxG.sound.play(Paths.sound('minigames/rosieclicker/switch'));
					FlxG.camera.flash();
					
					rosie.outfit = CROC;
				}
				
				FlxG.sound.music.pitch = 3;
			case 'NOLIME':
				if (rosie.outfit != NOLIME)
				{
					FlxG.sound.play(Paths.sound('minigames/rosieclicker/switch'));
					FlxG.camera.flash();
					rosie.outfit = NOLIME;
				}
		}
	}
	
	inline function updateRpc(icon:String)
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence('Playing Rosie Clicker', null, icon, false, null, 'rosieclicker');
		#end
	}
	
	var tripleMult:Int = 1;
	var tripleTimer:Float = 0;
	
	var usesXbox = true;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		handleSecrets(elapsed);
		
		if (tripleTimer > 0)
		{
			tripleTimer -= elapsed;
			if (tripleTimer <= 0)
			{
				tripleMult = 1;
			}
		}
		
		bgPlushes.forEachAlive(spr -> {
			if (spr.angle > 360) spr.angle -= 360;
			if (spr.y > FlxG.height * 1.8) spr.kill();
		});
		
		clickTimer += elapsed;
		if (clickTimer >= 1)
		{
			clickTimer = 0;
			clicks += rosie.outfit.getOverTime();
			clickText.text = clicks.toString();
		}
		
		if (FlxG.gamepads.anyInput())
		{
			Controls.instance.controllerMode = true;
			FlxG.mouse.visible = false;
			
			if (usesXbox != Controls.isPsController())
			{
				usesXbox = !Controls.isPsController();
				
				var suffix = usesXbox ? 'xbox_' : 'ps_';
				
				controllerConfirmButton.loadGraphic(Paths.image('minigames/rosieclicker/controller_icons/' + suffix + 'press'));
				controllerShopButton.loadGraphic(Paths.image('minigames/rosieclicker/controller_icons/' + suffix + 'shop'));
			}
		}
		else if (FlxG.mouse.justMoved)
		{
			Controls.instance.controllerMode = false;
			FlxG.mouse.visible = true;
		}
		
		controllerConfirmButton.visible = Controls.instance.controllerMode;
		controllerShopButton.visible = Controls.instance.controllerMode;
		
		if (!enabled) return;
		
		if (Controls.instance.controllerMode)
		{
			handleControllerInputs();
		}
		else
		{
			handleMouseInputs();
		}
		
		if (clickHits.length != 0)
		{
			while (clickHits.length > 0 && (clickHits[0] + 2000) < Date.now().getTime())
				clickHits.shift();
		}
		
		clicksPerSecText.text = Std.string(Math.floor(clickHits.length / 2));
	}
	
	function handleControllerInputs()
	{
		if (FlxG.gamepads.anyJustPressed(A))
		{
			clicked();
			controllerConfirmButton.scale.set(0.9, 0.9);
		}
		else if (FlxG.gamepads.anyJustReleased(A))
		{
			controllerConfirmButton.scale.set(1, 1);
		}
		
		if (FlxG.gamepads.anyJustPressed(X))
		{
			enabled = false;
			openSubState(new OutfitPicker());
			updateOutfitSprAnim(false);
		}
		
		if (FlxG.gamepads.anyJustPressed(B))
		{
			enabled = false;
			CoolUtil.playMenuMusic();
			FlxG.sound.music.volume = 0;
			FlxG.switchState(() -> new OptionsState());
		}
	}
	
	function handleMouseInputs()
	{
		final isHoveringOutfit = FlxG.mouse.overlaps(outfitSpr);
		updateOutfitSprAnim(isHoveringOutfit);
		
		if (FlxG.mouse.justPressed && isHoveringOutfit)
		{
			enabled = false;
			openSubState(new OutfitPicker());
			updateOutfitSprAnim(false);
		}
		
		if (controls.BACK)
		{
			enabled = false;
			CoolUtil.playMenuMusic();
			FlxG.sound.music.volume = 0;
			FlxG.switchState(() -> new OptionsState());
			FlxG.mouse.visible = false;
		}
		
		#if ROSIECLICKER
		if (FlxG.keys.justPressed.M) clicks = clicks * 2;
		#end
		
		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(rosie))
		{
			clicked();
		}
	}
	
	function clicked()
	{
		clickHits.push(Date.now().getTime());
		
		final clickAddition = (1 + rosie.outfit.getAdditive()) * rosie.outfit.getMult() * tripleMult * (NewgroundsClient.active ? 2 : 1);
		
		clicks += clickAddition;
		
		if ((rosie.outfit == CORD || rosie.outfit == ONESIE_CORD) && FlxG.random.bool(5) && tripleMult == 1)
		{
			tripleMult = 3;
			tripleTimer = 5;
			//
		}
		
		if ((rosie.outfit == MIAU_CORD || rosie.outfit == ONESIE_CORD) && FlxG.random.bool(0.5))
		{
			clicks *= 2;
		}
		
		rosie.bop();
		
		final text = perClickTextGrp.recycle(PopUpText, () -> {
			var spr = new PopUpText(32);
			
			return spr;
		});
		
		text.alpha = 1;
		text.text = '+$clickAddition';
		
		text.x = FlxG.mouse.x - (text.width * 0.9);
		text.y = FlxG.mouse.y - (text.height * 0.9);
		
		text.moves = true;
		text.velocity.y = -50;
		text.acceleration.y = 200;
		
		FlxTween.tween(text, {alpha: 0}, 0.2,
			{
				startDelay: 0.3,
				onComplete: Void -> {
					text.kill();
				}
			});
		final plush = bgPlushes.recycle(FlxSprite, () -> {
			var spr = new FlxSprite();
			spr.velocity.y = 800;
			spr.angle = FlxG.random.int(0, 360);
			spr.angularVelocity = 120;
			spr.scale.set(0.2, 0.2);
			spr.blend = SCREEN;
			spr.alpha = 0.65;
			spr.antialiasing = ClientPrefs.data.antialiasing;
			return spr;
		});
		
		plush.loadGraphicFromSprite(rosie);
		plush.updateHitbox();
		plush.y = -plush.height - 100;
		plush.x = FlxG.camera.viewWidth * FlxG.random.float(0, 0.9);
		
		FlxG.sound.play(Paths.sound('minigames/rosieclicker/pop' + (FlxG.random.bool() ? '0' : '1')), 0.2);
		
		//
	}
	
	public function flush(visual:Bool = false)
	{
		FlxG.save.data._rosieClickerOutfit = rosie.outfit;
		FlxG.save.data._cachedClicksBinaryString = clicks.toBinaryString();
		
		// trace(FlxG.save.data._cachedClicksBinaryString);
		// FlxG.save.data._cachedClicksLow = (cast clicks.low : Int);
		// FlxG.save.data._cachedClicksHigh = (cast clicks.high : Int);
		FlxG.save.flush();
		
		if (!visual) return;
		
		if (saveSpr == null)
		{
			saveSpr = new FlxSprite(Paths.image('minigames/rosieclicker/saving'));
			saveSpr.screenCenter(X);
			saveSpr.scrollFactor.set();
			saveSpr.y = -75;
			insert(members.length, saveSpr);
		}
		
		FlxTween.cancelTweensOf(saveSpr, ['alpha']);
		saveSpr.alpha = 0;
		FlxTween.tween(saveSpr, {alpha: 1}, 1,
			{
				ease: FlxEase.sineInOut,
				type: 4,
				onComplete: (twn) -> {
					if (twn.executions >= 4)
					{
						twn.cancel();
					}
				}
			});
	}
	
	override function destroy()
	{
		flush();
		super.destroy();
	}
	
	function set_clicks(value:BigInt):BigInt
	{
		if (clicks >= 50000 && !Achievements.isUnlocked('50kClicks')) Achievements.unlock('50kClicks');
		if (clickText != null)
		{
			clickText.text = value.toString();
		}
		return clicks = value;
	}
}

class PopUpText extends OptionsText
{
	var ngLogo:FlxSprite;
	
	public function new(size:Int = 24)
	{
		super(0, 0, 0, '', size);
		color = FlxColor.WHITE;
		ngLogo = new FlxSprite(Paths.image('minigames/rosieclicker/ngLogo'));
		ngLogo.visible = NewgroundsClient.active;
	}
	
	override function draw()
	{
		super.draw();
		if (this.visible && ngLogo.visible)
		{
			ngLogo.setGraphicSize(0, this.height);
			ngLogo.updateHitbox();
			ngLogo.x = x + width;
			ngLogo.centerOnObject(this, Y);
			ngLogo.alpha = alpha;
			ngLogo.draw();
		}
	}
	
	override function destroy()
	{
		super.destroy();
		ngLogo = FlxDestroyUtil.destroy(ngLogo);
	}
}
