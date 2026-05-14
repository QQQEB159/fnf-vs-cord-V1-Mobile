package states.credits;

import haxe.Json;

import flixel.graphics.FlxGraphic;

import states.credits.objects.Coin;

import flixel.addons.transition.FlxTransitionableState;

import openfl.filters.ShaderFilter;

import flixel.graphics.tile.FlxGraphicsShader;
import flixel.effects.particles.FlxEmitter;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxRect;
import flixel.FlxG;
import flixel.util.FlxDirectionFlags;

import backend.MusicBeatState;

import states.credits.objects.Tree;
import states.credits.objects.Door;
import states.credits.objects.CreditPopper;

using flixel.util.FlxArrayUtil;

typedef CoinPosition =
{
	x:Float,
	y:Float,
}

class CreditsPlatformer extends MusicBeatState
{
	final CREDITS:Array<CreditInformation> = [
		{
			name: "Rose Cord",
			icon: "rosecord",
			contributions: [ARTIST, CODING, CHARTER, CAMEO],
			description: "Director, Main Artist and Animator, Coder, and Charter."
		},
		{
			name: "Nyamukoneko",
			icon: "nyamukoneko",
			contributions: [COMPOSER, SCRIPTER, ARTIST, CAMEO],
			description: "Composer for all Songs, Script Writer, and Pixel Artist."
		},
		{
			name: "Nolime",
			icon: "nolime",
			contributions: [ARTIST, CAMEO, PLAYTESTER],
			description: "Second Main Sprite Artist and Animator. Helped a ton with playtesting."
		},
		{
			name: "Data5",
			icon: "data5",
			contributions: [CODING, CAMEO],
			description: "Main Coder, Helped with Shaders, and saved the mod from being canned. <3"
		},
		{
			name: "Jigglypuffgd",
			icon: "jigglypuffgd",
			contributions: [ARTIST, SCRIPTER],
			description: "Concept Artist, and Script Writer."
		},
		{
			name: "Vidz",
			icon: "vidz",
			contributions: [CODING],
			description: "Helped with Coding the Gallery, and Gameplay Visuals."
		},
		{
			name: "isophoro",
			icon: "isophoro",
			contributions: [CODING],
			description: "Helped with Coding extra Gameplay Visuals, and the Credits Menu."
		},
		{
			name: "Kangeldevii",
			icon: "kangeldevii",
			contributions: [ARTIST],
			description: "Helped create Marilyn's Semi-Final Design."
		},
		{
			name: "MashProTato",
			icon: "mashprotato",
			contributions: [ARTIST, CAMEO],
			description: "Helped with Art and Animations, and Marilyn's Concept Designs."
		},
		{
			name: "Stxrbears",
			icon: "stxrbears",
			contributions: [ARTIST, CAMEO, PLAYTESTER],
			description: "Helped with Pixel Art for the Main Menu, and the Credits."
		},
		{
			name: "Graev",
			icon: "graev",
			contributions: [ARTIST, CAMEO],
			description: "Helped with Backgrounds, and BG Characters. Certified Bum."
		},
		{
			name: "DJ",
			icon: "dj",
			contributions: [CHARTER, CAMEO],
			description: "Main Opponent in Care-Free, and Helped with Charting."
		},
		{
			name: "Grand Regent Thragg",
			icon: "thragg",
			contributions: [VILTRUM],
			description: "Grand Regent of the Viltrum Empire."
		}
	];
	
	final SPECIAL_THANKS:Array<String> = [
		"SoRubyCore",
		"Michu",
		"Baglzx",
		"Rowan",
		"TR4UMA",
		"numbdropbc",
		"SadBulldog",
		"Penkaru"
	];
	
	static var enteringFromCordWeek:Bool = false;
	
	var startX:Float = 0;
	var endX:Float = 0;
	
	var HUD:FlxCamera;
	
	var progress_bar:FlxSprite;
	var cord_progress:FlxSprite;
	
	var player:CordPlayer;
	var floor:FlxSprite;
	
	var entrance_door:Door;
	var exit_door:Door;
	
	var trees:Array<Tree> = [];
	
	var coins:Array<Coin> = [];
	
	var credit_group:FlxTypedSpriteGroup<CreditPopper>;
	
	var specialThanksHeader:FlxText;
	var specialThanksTxt:FlxText;
	
	var mosaicShader:MosaicShader;
	
	var portalAmbience:FlxSound = FlxG.sound.load(Paths.sound('credits/ambiancePortal'), 0, true, null, true, true);
	
	var starAmbience:FlxSound = FlxG.sound.load(Paths.music('minigames/M2'), 0, true, null, true, true);
	
	var windAmbience:FlxSound = FlxG.sound.load(Paths.sound('credits/quietWind'), 0.85, true, null, true, true);
	
	override function destroy()
	{
		portalAmbience?.destroy();
		starAmbience?.destroy();
		windAmbience?.destroy();
		super.destroy();
	}
	
	override function create()
	{
		starAmbience.pitch = 1.4;
		
		FlxG.sound.list.add(starAmbience);
		FlxG.sound.list.add(portalAmbience);
		FlxG.sound.list.add(windAmbience);
		
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Credits");
		#end
		
		persistentUpdate = true;
		
		initPsychCamera();
		mosaicShader = new MosaicShader();
		FlxG.camera.filters = [new ShaderFilter(mosaicShader)];
		
		HUD = new FlxCamera();
		FlxG.cameras.add(HUD, false);
		HUD.bgColor.alpha = 0;
		
		FlxG.cameras.add(new FlxCamera(), false).bgColor = 0x0;
		
		super.create();
		
		windAmbience.play();
		
		FlxG.camera.bgColor = 0xff131419;
		
		FlxG.camera.minScrollX = 0;
		FlxG.camera.minScrollY = -102;
		
		FlxG.camera.zoom = 1;
		
		credit_group = new FlxTypedSpriteGroup<CreditPopper>();
		
		generateCredits();
		
		floor = new FlxSprite(-1000, 0).makeScaledGraphic((specialThanksTxt.x + specialThanksTxt.width + FlxG.width) + 1000, 300, FlxColor.TRANSPARENT);
		add(floor);
		floor.solid = true;
		floor.immovable = true;
		floor.updateHitbox();
		floor.y = 393;
		
		var farBackground = new FlxTiledSprite(Paths.image("menuassets/credits/farBackgroundScaled"), FlxG.width, Paths.image("menuassets/credits/farBackgroundScaled")
			.height, true, false);
		add(farBackground);
		farBackground.y = -102;
		// farBackground.scale.set(3, 3);
		// farBackground.updateHitbox();
		farBackground.antialiasing = false;
		farBackground.scrollFactor.x = 0.9;
		
		var idx = 0;
		while (idx == 0 || credit_group.members[(idx * 2) - 1] != null)
		{
			var tree:Tree = new Tree(0, idx % 2 == 0 ? 2 : 1);
			add(tree);
			trees.push(tree);
			tree.x = (idx == 0 ? 500 : (credit_group.members[(idx * 2) - 1].x + credit_group.members[(idx * 2) - 1].width) + (idx % 2 == 0 ? -180 : 80));
			idx++;
		}
		
		var sign = new FlxSprite(0, 0).loadGraphic(Paths.image("menuassets/credits/sign"));
		add(sign);
		sign.antialiasing = false;
		sign.scale.set(3, 3);
		sign.updateHitbox();
		sign.y = floor.y - sign.height;
		
		add(credit_group);
		add(specialThanksHeader);
		add(specialThanksTxt);
		
		entrance_door = new Door(0, floor.y - 264, true);
		entrance_door.flipX = true;
		add(entrance_door);
		
		exit_door = new Door((specialThanksTxt.x + specialThanksTxt.width) + 200, floor.y - 264, false);
		add(exit_door);
		
		player = new CordPlayer();
		add(player);
		player.screenCenter();
		
		FlxG.camera.follow(player, PLATFORMER, 0.06);
		FlxG.camera.followLead.set(5, 0);
		FlxG.camera.targetOffset.y = -100;
		FlxG.camera.deadzone.top = 999;
		FlxG.camera.deadzone.bottom = 400;
		FlxG.camera.maxScrollX = exit_door.x + exit_door.front.width + 200;
		
		sign.x = player.x + 150;
		
		startX = credit_group.members[0].x;
		endX = specialThanksTxt.getMidpoint().x;
		
		add(entrance_door.front);
		entrance_door.front.y = floor.y - 264;
		add(exit_door.front);
		exit_door.front.y = floor.y - 264;
		
		farBackground.x = entrance_door.x + entrance_door.width;
		farBackground.width = exit_door.x - farBackground.x - 1000;
		
		var coinPositions:Array<CoinPosition> = [];
		
		if (Paths.fileExists('data/coins.json', TEXT))
		{
			coinPositions = Json.parse(File.getContent(Paths.getPath('data/coins.json')));
		}
		
		for (idx in 0...coinPositions.length)
		{
			var coin = new Coin(coinPositions[idx].x, coinPositions[idx].y);
			
			add(coin);
			coins.push(coin);
		}
		
		var real_floor:FlxBackdrop = new FlxBackdrop(Paths.image("menuassets/credits/ground"), X);
		add(real_floor);
		real_floor.scale.set(3, 3);
		real_floor.updateHitbox();
		real_floor.antialiasing = false;
		real_floor.y = 390;
		// real_floor.visible = false;
		
		var bar = new FlxSprite(0, 40).loadGraphic(Paths.image("menuassets/credits/bar"));
		add(bar);
		bar.camera = HUD;
		bar.updateHitbox();
		bar.screenCenter(X);
		
		bar.antialiasing = ClientPrefs.data.antialiasing;
		
		progress_bar = new ProgBar(bar.x + 52, bar.y + 12).loadGraphic(Paths.image("menuassets/credits/progressBar"));
		progress_bar.clipRect = new FlxRect(0, 0, Std.int(progress_bar.width), Std.int(progress_bar.height));
		add(progress_bar);
		progress_bar.camera = HUD;
		progress_bar.updateHitbox();
		progress_bar.antialiasing = ClientPrefs.data.antialiasing;
		
		cord_progress = new FlxSprite(progress_bar.x, bar.y - 1).loadGraphic(Paths.image("menuassets/credits/icon"));
		add(cord_progress);
		cord_progress.camera = HUD;
		cord_progress.antialiasing = ClientPrefs.data.antialiasing;
		
		MusicBeatState.currentTransition = SWIPE;
		
		if (enteringFromCordWeek)
		{
			FlxG.camera.minScrollY = null;
			player.x = startX - 425;
			
			final prevOffset = FlxG.camera.targetOffset.y;
			player.canMove = false;
			
			FlxG.camera.zoom = 2;
			FlxG.camera.targetOffset.y = -800;
			FlxG.camera.snapToTarget();
			
			FlxTween.tween(FlxG.camera, {'targetOffset.y': prevOffset}, 2.5, {ease: FlxEase.cubeOut});
			
			FlxTween.tween(FlxG.camera, {zoom: 1}, 2.5, {ease: FlxEase.cubeInOut, startDelay: 4});
			
			player.animation.play("intro", true);
			player.animation.onFinish.addOnce(anim -> {
				player.canMove = true;
				FlxG.camera.minScrollY = -102;
				
				FlxG.sound.playMusic(Paths.music('weird-cat'), 0);
				FlxG.sound.music.fadeIn(2);
			});
			
			MainMenuState.curSelected = MainMenuState.options.indexOf('credits');
		}
		else
		{
			FlxG.sound.playMusic(Paths.music('weird-cat'), 0);
			FlxG.sound.music.fadeIn(2);
			
			player.x = startX - 800;
			player.canMove = false;
			
			player.animation.play('walk');
			
			FlxTween.tween(player, {x: startX - 425}, 1.8,
				{
					onComplete: Void -> {
						player.canMove = true;
					}
				});
				
			FlxG.camera.fade(FlxColor.BLACK, 1, true);
			
			mosaicShader.value = 20;
			
			FlxTween.tween(mosaicShader, {value: 0.001}, 2);
		}
	}
	
	function generateCredits()
	{
		for (i in 0...CREDITS.length)
		{
			var credit = new CreditPopper(CREDITS[i]);
			credit_group.add(credit);
			
			var icony = credit.icon.y;
			var liney = credit.line.y;
			var heightTarget = liney - icony;
			
			credit.y = 265 - heightTarget;
			credit.x = (i == 0 ? 1000 : (credit_group.members[i - 1].x + credit_group.members[i - 1].width) + 350);
			credit.baseY = credit.y;
			credit._e += i * 0.5;
			if (CREDITS[i].name == 'Stxrbears') credit.bop();
		}
		
		specialThanksHeader = new FlxText(0, 0, 0, 'Special Thanks', 32);
		specialThanksHeader.setFormat(Paths.font("AKIRA.otf"), 32, FlxColor.WHITE, CENTER);
		
		final specialThanks = '\n' + SPECIAL_THANKS.join('\n') + '\n\n\nThank you for playing!';
		
		specialThanksTxt = new FlxText(credit_group.members.last().x + credit_group.members.last().width + 250, 0, 300, specialThanks, 16);
		specialThanksTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		specialThanksTxt.y = credit_group.members.last().name.y + credit_group.members.last().name.height - specialThanksTxt.height;
		
		specialThanksHeader.centerOnObject(specialThanksTxt, X).y = specialThanksTxt.y - specialThanksHeader.height;
	}
	
	var progress:Float = 0;
	
	override function update(elapsed:Float)
	{
		progress = FlxMath.remapToRange(Math.min(Math.max(player.x, startX), endX), startX, endX, 0, 1);
		
		if (progress_bar?.clipRect != null)
		{
			progress_bar.clipRect.width = FlxMath.lerp(progress_bar.clipRect.width, progress * 306, 1 - Math.exp(-elapsed * 4));
			progress_bar.clipRect = progress_bar.clipRect;
		}
		
		cord_progress.x = (progress_bar.x + progress_bar.clipRect.width) - ((cord_progress.width / 2) - 2);
		
		if (player.canMove)
		{
			for (door in [exit_door, entrance_door])
			{
				if (FlxG.overlap(door.collider, player))
				{
					player.canMove = false;
					player.velocity.x = 0;
					
					FlxG.sound.music.fadeOut(0.8);
					FlxTween.tween(mosaicShader, {value: 10}, 1);
					FlxG.camera.fade();
					
					FlxG.sound.play(Paths.sound('credits/portal'), 1.0);
					
					FlxTween.tween(door.white, {alpha: 1}, 1,
						{
							onComplete: _ -> {
								FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = false;
								if (enteringFromCordWeek)
								{
									enteringFromCordWeek = false;
									MainMenuState.curSelected = MainMenuState.options.indexOf('story_mode');
									FlxG.switchState(() -> new StoryMenuState());
								}
								else
								{
									FlxG.switchState(() -> new MainMenuState());
								}
							}
						});
				}
			}
		}
		
		#if debug
		if (controls.BACK && !controls.controllerMode) FlxG.switchState(() -> new MainMenuState());
		#end
		
		FlxG.worldBounds.x = FlxG.camera.viewX;
		FlxG.worldBounds.width = FlxG.camera.viewWidth + 600;
		
		HUD.alpha = FlxMath.remapToRange(player.x, (player.x >= endX ? endX + 90 : startX), (player.x >= endX ? endX - 90 : startX) + 90, 0, 1);
		
		final leftDoor = entrance_door.front;
		final rightDoor = exit_door.front;
		
		final closestDoor = (Math.abs(player.x - (leftDoor.x + leftDoor.width)) < Math.abs(player.x - (rightDoor.x))) ? leftDoor : rightDoor;
		
		final maxDistance = 600;
		final distanceToDoor = Math.abs(closestDoor.getMidpoint().x - player.x);
		
		portalAmbience.volume = FlxMath.remapToRange(Math.min(maxDistance, distanceToDoor), maxDistance, 0, 0, 1);
		
		final maxDistance = 200;
		
		inline function getPanda()
		{
			if (_starCredit != null) return _starCredit;
			
			for (i in credit_group.members)
			{
				if (i.info.name == 'Stxrbears') _starCredit = i;
			}
			
			return _starCredit;
		}
		
		final distancefromStar = Math.abs(getPanda().getMidpoint().x - player.x);
		
		starAmbience.volume = FlxMath.remapToRange(Math.min(maxDistance, distancefromStar), maxDistance, 0, 0, 1);
		
		// visual garbage
		updateCreditsVisuals(elapsed);
		
		for (coin in coins)
		{
			if (!coin.collected && coin.objectOverlaps(player)) coin.grab();
		}
		
		FlxG.collide(player, floor);
		if (player.isTouching(FlxDirectionFlags.FLOOR)) player.grounded = true;
		
		super.update(elapsed);
	}
	
	var _starCredit:Null<CreditPopper> = null;
	
	inline function updateCreditsVisuals(elapsed:Float)
	{
		for (i in trees)
		{
			for (fly in i.flies)
			{
				final maxDistance = 300;
				final distance = Math.abs(fly.x - player.x);
				
				fly.distanceAlpha = FlxMath.remapToRange(Math.min(maxDistance, distance), maxDistance, 0, 0, 1);
			}
		}
		
		final lastCredit = credit_group.members.last();
		if (lastCredit != null) // i hate assuming array values like this without null checks so
		{
			specialThanksTxt.y = lastCredit.name.y + lastCredit.name.height - specialThanksTxt.height;
			
			specialThanksTxt.y += FlxMath.fastSin((180 / Math.PI) * (lastCredit._e + 0.5) * lastCredit.rate) * lastCredit.amp;
			
			specialThanksHeader.centerOnObject(specialThanksTxt, X).y = specialThanksTxt.y - specialThanksHeader.height;
		}
	}
	
	override function draw()
	{
		// this is insanity
		var culled = [for (tree in trees) for (fly in tree.flies) fly].filter(fly -> fly != null && fly.isForeground);
		
		super.draw();
		
		for (i in culled)
			i.draw();
	}
}

class CordPlayer extends FlxSprite
{
	public var canMove:Bool = false;
	public var grounded:Bool = false;
	
	public var controls(get, never):Controls;
	
	static final MAX_SPEED = 225;
	static final MAX_RUN_SPEED = 350;
	static final ACCEL = 0.15;
	static final DEACCEL = 0.25;
	
	static final GRAVITY = 4000;
	
	static final JUMP_HEIGHT = -300 * 3;
	
	var running:Bool = false;
	
	var walkSound:FlxSound;
	var runSound:FlxSound;
	var jumpSound:FlxSound;
	
	var stepTimer:Float = 0;
	
	var dustEmitter:FlxEmitter;
	
	inline function get_controls()
	{
		return Controls.instance;
	}
	
	public function new()
	{
		super(0, 0);
		
		#if debug
		FlxG.console.registerClass(CordPlayer);
		#end
		
		walkSound = FlxG.sound.load(Paths.sound('credits/walking'));
		runSound = FlxG.sound.load(Paths.sound('credits/running'), 0.8);
		jumpSound = FlxG.sound.load(Paths.sound('credits/jumping'));
		
		frames = Paths.getSparrowAtlas("menuassets/credits/cordPixel");
		animation.addByPrefix('idle', 'Idle', 24, true);
		animation.addByPrefix('blink', 'Blink', 24, false); // plays randomly
		animation.addByPrefix('walk', 'Run', 26, true);
		// animation.addByPrefix('run', 'Run', 38, true);
		animation.addByPrefix('jump', 'Jump', 1, true);
		// animation.addByPrefix('intro', 'Start Anim', 24, false);
		
		var indices = [for (i in 0...20) 0];
		for (i in 0...111)
			indices.push(i);
			
		animation.addByIndices('intro', 'Start Anim', indices, '', 22, false);
		animation.play('idle');
		
		antialiasing = false;
		scale.set(3, 3);
		updateHitbox();
		
		dustEmitter = new FlxEmitter();
		dustEmitter.makeParticles(6, 6, 0xFF808D99);
		dustEmitter.launchMode = SQUARE;
		
		dustEmitter.velocity.set(200, 0, 200, 0);
		dustEmitter.start(false, 0);
		dustEmitter.lifespan.set(0.6, 1.2);
		dustEmitter.alpha.set(0.7, 1, 0, 0);
		dustEmitter.scale.set(0.8, 0.8, 1.2, 1.2, 0, 0, 0.5, 0.5);
		dustEmitter.angle.set(0, 20, 30, 40);
		dustEmitter.emitting = false;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		cordMovement(elapsed);
		
		if (canMove) // lets treat this like a active type of thing.
		{
			blinkCheck(elapsed);
			handleSfx(elapsed);
			handleEmitter();
		}
		
		dustEmitter.update(elapsed);
	}
	
	override function draw()
	{
		super.draw();
		dustEmitter.x = x + (width / 2);
		dustEmitter.y = y + height;
		dustEmitter.draw();
	}
	
	function handleEmitter()
	{
		if (grounded && !FlxMath.equal(velocity.x, 0))
		{
			var vel = controls.UI_LEFT ? 50 : -50;
			
			dustEmitter.velocity.set(vel * 0.5, -25, vel, -50);
			
			dustEmitter.frequency = 0.4 / (Math.abs(velocity.x) * 0.005);
			
			dustEmitter.emitting = true;
		}
		else
		{
			dustEmitter.emitting = false;
		}
	}
	
	function handleSfx(e:Float)
	{
		if (velocity.x != 0 && grounded)
		{
			if (Controls.instance.UI_LEFT_P || Controls.instance.UI_RIGHT_P)
			{
				stepTimer = 0;
				// writing weridr code for the fun
				(running ? runSound : walkSound).play();
			}
			else if (Controls.instance.UI_LEFT || Controls.instance.UI_RIGHT)
			{
				stepTimer += e;
				// did you know this is valid haxe code ?
				final snd = running == true ? runSound : walkSound, rate = running == true ? (1 / 6) : (1 / 4);
				
				if (stepTimer > rate)
				{
					snd.play();
					stepTimer = 0;
				}
			}
			else if (Controls.instance.UI_LEFT_R || Controls.instance.UI_RIGHT_R)
			{
				stepTimer = 0;
			}
		}
		
		if (velocity.y == JUMP_HEIGHT && !grounded) // hacky check but lol
		{
			jumpSound.play(true);
			stepTimer = 999;
		}
	}
	
	public function blinkCheck(elapsed:Float)
	{
		if (animation.curAnim.name != "idle" && animation.curAnim.name == 'blink') return;
		if (FlxG.random.bool(5 * elapsed))
		{
			animation.play('blink', true);
			animation.onFinish.addOnce(anim -> {
				if (anim == 'blink') animation.play('idle');
			});
		}
	}
	
	// My very simple movement...ok?
	public function cordMovement(elapsed:Float)
	{
		running = controls.controllerMode ? FlxG.gamepads.anyPressed(X) == true : FlxG.keys.pressed.SHIFT;
		
		if (!grounded)
		{
			velocity.y += (GRAVITY * elapsed);
			if (velocity.y >= 500 * 3) velocity.y = 500 * 3;
		}
		else
		{
			velocity.y = 0;
		}
		
		if (!canMove) return;
		
		final speed = running ? MAX_RUN_SPEED : MAX_SPEED;
		final accelRate = 1.0 - Math.pow(1.0 - ACCEL, elapsed * 60);
		
		if (controls.UI_LEFT)
		{
			velocity.x = FlxMath.lerp(velocity.x, speed * -1, accelRate);
			if ((animation.curAnim.name != "walk") && grounded) animation.play("walk", true);
			
			animation.curAnim.frameRate = running ? 38 : 26;
			flipX = true;
		}
		else if (controls.UI_RIGHT)
		{
			velocity.x = FlxMath.lerp(velocity.x, speed, accelRate);
			if ((animation.curAnim.name != "walk") && grounded) animation.play("walk", true);
			
			animation.curAnim.frameRate = running ? 38 : 26;
			flipX = false;
		}
		else if (!controls.UI_RIGHT && !controls.UI_LEFT)
		{
			velocity.x = FlxMath.lerp(velocity.x, 0, 1.0 - Math.pow(1.0 - DEACCEL, elapsed * 60));
			if ((animation.curAnim.name != "idle" && animation.curAnim.name != 'blink') && grounded) animation.play("idle", true);
		}
		
		if ((controls.controllerMode ? controls.pressed('accept') : controls.UI_UP) && grounded)
		{
			velocity.y = JUMP_HEIGHT;
			animation.play('jump', true);
			grounded = false;
		}
		else if ((controls.controllerMode ? controls.justReleased('accept') : controls.UI_UP_R))
		{
			velocity.y /= 2;
		}
	}
	
	override function destroy()
	{
		super.destroy();
		dustEmitter?.destroy();
	}
}

private class ProgBar extends FlxSprite
{
	override function set_clipRect(rect:FlxRect)
	{
		clipRect = rect;
		
		if (frames != null) frame = frames.frames[animation.frameIndex];
		
		return rect;
	}
}

class MosaicShader extends FlxGraphicsShader
{
	public var value(default, set):Float = 0.0001;
	
	function set_value(v:Float)
	{
		return this.pixel.value[0] = value = v;
	}
	
	@:glFragmentSource("
		#pragma header

		uniform float pixel;
		void main()
		{
			vec2 size = openfl_TextureSize.xy / pixel;
			gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv.xy * size) / size);
		}
	")
	public function new()
	{
		super();
		
		this.pixel.value = [0.0001];
	}
}
