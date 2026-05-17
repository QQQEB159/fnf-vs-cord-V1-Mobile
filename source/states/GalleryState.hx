package states;

import backend.TurboControl;

import flixel.util.FlxStringUtil;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxRect;

import openfl.media.Sound;

import flixel.FlxBasic;

import haxe.Json;

import openfl.display.BlendMode;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

import objects.MusicPlayer;

using StringTools;

typedef GalleryCategory =
{
	var category:String;
	var entries:Array<FlatGalleryEntry>;
}

typedef FlatGalleryEntry =
{
	var ?category:String;
	var ?description:String;
	var ?image:String;
	var ?audio:String; // Optional field
}

@:access(backend.CoolUtil)
class GalleryState extends MusicBeatState
{
	var galleryShit:Array<FlatGalleryEntry>;
	
	var currentSound:FlxSound = null;
	
	static var currentIndex:Int = 0;
	
	var galleryCategories:Array<GalleryCategory>;
	
	var overlay:FlxSprite;
	
	var arrowLeft:FlxSprite;
	var arrowRight:FlxSprite;
	
	var descriptionText:FlxText;
	var galleryCategoryText:FlxText;
	var curImageText:FlxText;
	var timeTillNextSundayTxt:FlxText;
	
	var images:FlxTypedGroup<Entry>;
	
	var player:MusicPlayer;
	
	var musicPlayer:GalleryPlayer;
	var musicButton:FlxSprite;
	var musicButtonTwn:Null<FlxTween> = null;
	
	var turboLeft:TurboControl = TurboControl.fromControl('ui_left');
	var turboRight:TurboControl = TurboControl.fromControl('ui_right');
	
	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Gallery");
		#end
		
		if (!Paths.fileExists('data/galleryDescription.json', TEXT))
		{
			throw "Missing gallery data ?";
		}
		
		add(turboLeft);
		add(turboRight);
		
		Conductor.bpmChangeMap = [];
		Conductor.bpm = MenuMusic.KITTY_DAYS.toBPM();
		
		FlxG.sound.playMusic(Paths.music('kitty-days'), 0);
		FlxG.sound.music.fadeIn(1.0, 0.0, 1.0);
		
		galleryCategories = Json.parse(File.getContent(Paths.json('galleryDescription')));
		
		galleryShit = [for (i in galleryCategories)
			for (entry in i.entries)
				{
					category: i.category,
					description: entry.description,
					image: entry.image,
					audio: entry.audio}];
					
		// main BG Stuff
		final bg = new FlxSprite(Paths.image('menuassets/gallery/bgImage'));
		bg.screenCenter();
		add(bg);
		
		final checkerBg = new FlxBackdrop(Paths.image('menuassets/checkerLerp'));
		checkerBg.scale.set(0.8, 0.8);
		add(checkerBg);
		checkerBg.velocity.set(12, 2);
		
		overlay = new FlxSprite(Paths.image('menuassets/gallery/overlay'));
		overlay.screenCenter();
		overlay.blend = BlendMode.ADD;
		add(overlay);
		
		final polka = new FlxSprite(Paths.image('menuassets/gallery/polka'));
		polka.screenCenter();
		add(polka);
		
		final bars = new FlxSprite(Paths.image('menuassets/bars'));
		bars.scale.set(1, 2);
		bars.screenCenter();
		add(bars);
		FlxTween.tween(bars.scale, {x: 1, y: 1}, 3, {ease: FlxEase.expoOut});
		
		final glowAdd = new FlxSprite(Paths.image('menuassets/gallery/glowAdd'));
		glowAdd.screenCenter();
		glowAdd.blend = BlendMode.ADD;
		add(glowAdd);
		
		galleryCategoryText = new FlxText(0, -100, FlxG.width, "", 62);
		galleryCategoryText.setFormat(Paths.font("akira.otf"), 62, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		galleryCategoryText.alpha = 0.8;
		add(galleryCategoryText);
		FlxTween.tween(galleryCategoryText, {y: 20}, 3, {ease: FlxEase.expoOut});
		
		curImageText = new FlxText(0, -100, FlxG.width - 20, "", 32);
		curImageText.setFormat(Paths.font('Pix32.ttf'), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(curImageText);
		curImageText.alpha = 0.5;
		FlxTween.tween(curImageText, {y: 20 + (galleryCategoryText.height - curImageText.height) / 2}, 3, {ease: FlxEase.expoOut});
		
		descriptionText = new FlxText(25, FlxG.height + 200, FlxG.width - 50, "", 24);
		descriptionText.setFormat(Paths.font('Pix32.ttf'), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(descriptionText);
		FlxTween.tween(descriptionText, {y: FlxG.height - 110}, 3, {ease: FlxEase.expoOut});
		
		timeTillNextSundayTxt = new FlxText(0, 80, FlxG.width, "", 24);
		timeTillNextSundayTxt.setFormat(Paths.font('Pix32.ttf'), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(timeTillNextSundayTxt);
		timeTillNextSundayTxt.alpha = 0;
		
		arrowLeft = new FlxSprite(130, 0).loadGraphic(Paths.image('menuassets/arrow'));
		arrowLeft.frames = Paths.getSparrowAtlas('menuassets/arrow');
		arrowLeft.animation.addByPrefix('idle', 'arrow instance 1', 24, true);
		arrowLeft.animation.play('idle');
		arrowLeft.screenCenter(Y);
		add(arrowLeft);
		arrowLeft.antialiasing = true;
		
		arrowRight = new FlxSprite().loadSparrowFrames('menuassets/arrow');
		arrowRight.animation.addByPrefix('idle', 'arrow instance 1', 24, true);
		arrowRight.animation.play('idle');
		arrowRight.screenCenter(Y);
		arrowRight.flipX = true;
		add(arrowRight);
		arrowRight.antialiasing = true;
		arrowRight.x = FlxG.width - arrowRight.width - arrowLeft.x;
		
		images = new FlxTypedGroup();
		add(images);
		
		player = new MusicPlayer(this);
		add(player);
		
		musicPlayer = new GalleryPlayer(this);
		add(musicPlayer);
		
		musicButton = new FlxSprite().loadSparrowFrames('menuassets/gallery/soundButtons');
		musicButton.animation.addByPrefix('pause', 'pause instance 1');
		musicButton.animation.addByPrefix('play', 'play instance 1');
		add(musicButton);
		musicButton.animation.play('pause');
		musicButton.alpha = 0;
		musicButton.screenCenter();
		musicButton.x -= 200;
		musicButton.y += 150;
		musicButton.antialiasing = true; // there are some exceptions to the option because these just ugly without
		
		currentIndex = FlxMath.minInt(currentIndex, galleryShit.length - 1);
		
		changeSel();
		
		addTouchPad("LEFT_FULL", "A_B");
		//addTouchPadCamera();
		
		super.create();
	}
	
	override function beatHit()
	{
		super.beatHit();
		
		if (curBeat % 4 == 0)
		{
			overlay.alpha = 1;
		}
	}
	
	public var holdTime:Float = 0;
	
	function isValidSound(doCache:Bool = true)
	{
		final entry = galleryShit[currentIndex];
		if (entry == null) return false;
		
		final sound = entry.audio;
		
		return (sound != null
			&& sound.split('|')[0].trim() != ''
			&& (!doCache || Paths.sound('galleryAudio/${sound.split('|')[0].trim()}') != null));
	}
	
	var _second:Float = 0;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		overlay.alpha = FlxMath.lerp(overlay.alpha, 0.6, 1 - Math.exp(-elapsed * 4));
		
		Conductor.songPosition = musicPlayer.isPlaying ? musicPlayer.sound.time : FlxG.sound.music.time;
		
		if (FlxG.keys.justPressed.SPACE || controls.ACCEPT)
		{
			if (musicPlayer.isActive)
			{
				musicPlayer.flip();
			}
			else if (isValidSound())
			{
				final trimmedSound = galleryShit[currentIndex].audio.split('|')[0].trim();
				musicPlayer.revealAndPlay(Paths.sound('galleryAudio/$trimmedSound'));
				
				final bpm = Std.parseFloat(galleryShit[currentIndex].audio.split('|')[1]?.trim() ?? '');
				if (!Math.isNaN(bpm)) Conductor.bpm = bpm;
			}
		}
		else if (!musicPlayer.isActive)
		{
			if (turboLeft.PRESSED || turboRight.PRESSED)
			{
				changeSel(controls.UI_LEFT ? -1 : 1);
			}
			
			if (controls.UI_LEFT_P) arrowLeft.scale.set(0.8, 0.8);
			else if (controls.UI_LEFT_R) arrowLeft.scale.set(1, 1);
			
			if (controls.UI_RIGHT_P) arrowRight.scale.set(0.8, 0.8);
			else if (controls.UI_RIGHT_R) arrowRight.scale.set(1, 1);
		}
		
		if (controls.BACK)
		{
			if (musicPlayer.isActive)
			{
				musicPlayer.hideAndDisable();
				Conductor.bpm = MenuMusic.KITTY_DAYS.toBPM();
			}
			else
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				CoolUtil.playMenuMusic();
				FlxG.switchState(() -> new MainMenuState());
			}
		}
		
		_second += elapsed;
		if (_second > 1)
		{
			_second = 0;
			updateTimeTxt();
			if (CoolUtil.currentSunday != CoolUtil.getSundaysPassed())
			{
				CoolUtil.currentSunday = CoolUtil.getSundaysPassed();
				function update()
				{
					if (this != null) changeSel();
				}
				CoolUtil.loadFanartOfTheWeek(update);
			}
		}
	}
	
	inline function updateTimeTxt()
	{
		final timePlayed = CoolUtil.getTimeUntilNextSunday() / 1000;
		
		final timeMinutes = Std.int(timePlayed / 60) % 60;
		
		final timeHours = Std.int((timePlayed / 60) / 60) % 24;
		
		final timeDays = Std.int(((timePlayed / 60) / 60) / 24) % 24;
		
		final timeSeconds = Std.int(timePlayed) % 60;
		
		final resultedTime = '$timeDays Days | ${addZero(timeHours)}:${addZero(timeMinutes)}:${addZero(timeSeconds)}';
		
		timeTillNextSundayTxt.text = 'Next Reset in: $resultedTime';
	}
	
	inline function addZero(val:Int)
	{
		if (val < 10) return '0' + Std.string(val);
		
		return Std.string(val);
	}
	
	function changeSel(change:Int = 0):Void
	{
		if (change != 0)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		
		currentIndex = FlxMath.wrap(currentIndex + change, 0, galleryShit.length - 1);
		
		images.forEachAlive(img -> if (!img.isKilling) img.killSelf(change));
		
		FlxTween.cancelTweensOf(timeTillNextSundayTxt, ['y', 'alpha']);
		
		final entry = galleryShit[currentIndex];
		
		if (entry.description == CoolUtil.FAN_ART_KEY)
		{
			if (CoolUtil.artworkCredit != null)
			{
				descriptionText.text = 'Fanart of the Week by @${CoolUtil.artworkCredit}! (${CoolUtil.artworkYear}) \n \n Resets every Sunday at 12AM';
			}
			else
			{
				descriptionText.text = 'Failed to load Fanart of the Week. Are you connected to the internet?';
			}
			FlxTween.tween(timeTillNextSundayTxt, {alpha: 0.8, y: 80}, 0.2, {ease: FlxEase.cubeOut});
		}
		else
		{
			descriptionText.text = entry?.description ?? '';
			
			FlxTween.tween(timeTillNextSundayTxt, {alpha: 0, y: 70}, 0.2, {ease: FlxEase.cubeIn});
		}
		
		galleryCategoryText.text = galleryShit[currentIndex]?.category ?? 'UNKNOWN';
		
		curImageText.text = (currentIndex + 1) + '/' + galleryShit.length;
		
		final imagePath:String = entry?.image ?? '';
		
		final placeHolderGraphic = Paths.image('menuassets/gallery/galleryContent/placeholder');
		
		final graphic = imagePath == CoolUtil.FAN_ART_KEY ? Paths.currentTrackedAssets.get(CoolUtil.FAN_ART_KEY) ?? placeHolderGraphic : Paths.image('menuassets/gallery/galleryContent/$imagePath') ?? placeHolderGraphic;
		
		final scalero:Float = Math.min(FlxG.width / graphic.width, FlxG.height / graphic.height) * 0.625;
		
		final newImage = images.recycle(Entry, () -> {
			var entry = new Entry();
			entry.scrollFactor.set();
			entry.antialiasing = ClientPrefs.data.antialiasing;
			return entry;
		});
		
		images.remove(newImage, true); // needed for layering
		images.add(newImage);
		
		newImage.loadGraphic(graphic);
		newImage.scale.set(scalero, scalero);
		newImage.updateHitbox();
		
		newImage.revealSelf(change);
		
		musicButtonTwn?.cancel();
		
		if (isValidSound(false))
		{
			musicButtonTwn = FlxTween.tween(musicButton, {alpha: 0.4, 'scale.x': 1, 'scale.y': 1}, 0.2, {ease: FlxEase.backOut});
		}
		else
		{
			musicButtonTwn = FlxTween.tween(musicButton, {alpha: 0, 'scale.x': 0.8, 'scale.y': 0.8}, 0.2, {ease: FlxEase.sineInOut});
		}
	}
}

@:access(states.GalleryState)
private class GalleryPlayer extends FlxGroup
{
	public var isActive:Bool = false;
	
	public var sound:FlxSound = null;
	
	public final parent:GalleryState;
	
	public var isPlaying(get, never):Bool;
	
	public var pitch(default, set):Float = 1;
	
	public var bar:ProgressBar;
	
	var pitchText:FlxText;
	
	var timeText:FlxText;
	
	var musicTwn:Null<FlxTween> = null;
	var soundTwn:Null<FlxTween> = null;
	var pitchTextTwn:Null<FlxTween> = null;
	
	public function new(parent:GalleryState)
	{
		this.parent = parent;
		
		super();
		
		bar = new ProgressBar(0, 0, 350, 20, 8);
		add(bar);
		bar.screenCenter(X);
		bar.y = 90;
		
		bar.y = 80;
		bar.alpha = 0;
		
		pitchText = new FlxText(0, 80, 0, '1X', 16);
		pitchText.setFormat(Paths.font("akira.otf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		pitchText.x = bar.x - pitchText.width - 2;
		pitchText.alpha = 0;
		add(pitchText);
		
		timeText = new FlxText(0, 80, 0, '00:00', 16);
		timeText.setFormat(Paths.font("akira.otf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeText.x = bar.x - timeText.width - 2;
		timeText.alpha = 0;
		add(timeText);
	}
	
	public function play(?snd:Sound)
	{
		if (snd == null) return;
		
		FlxG.autoPause = false;
		
		//
		if (sound == null) sound = FlxG.sound.load(snd, 1, true);
		else sound.loadEmbedded(snd, true);
		
		musicTwn?.cancel();
		musicTwn = FlxTween.tween(FlxG.sound.music, {pitch: 0}, 0.2, {onComplete: Void -> FlxG.sound.music.pause()});
		
		sound.play();
		sound.pitch = 0;
		FlxTween.tween(sound, {pitch: pitch}, 0.2);
		
		// parent.musicButton.animation.play('play');
		// parent.musicButton.scale.set(0.8, 0.8);
		// parent.musicButtonTwn = FlxTween.tween(parent.musicButton, {alpha: 1, 'scale.x': 1, 'scale.y': 1}, 0.2, {ease: FlxEase.backOut});
		
		isActive = true;
	}
	
	public function flip()
	{
		final pausing = isPlaying;
		
		if (pausing)
		{
			FlxG.autoPause = ClientPrefs.data.autoPause;
			_pauseMusic();
		}
		else
		{
			FlxG.autoPause = false;
			_resumeMusic();
		}
		
		animateButton(!pausing);
	}
	
	function _pauseMusic(pitchDown:Bool = true)
	{
		if (!isPlaying) return;
		
		soundTwn?.cancel();
		if (pitchDown)
		{
			sound.pitch = pitch;
			soundTwn = FlxTween.tween(sound, {pitch: 0}, 0.2, {onComplete: Void -> sound.pause()});
		}
		else
		{
			sound.pause();
		}
	}
	
	function _resumeMusic(pitchUp:Bool = true)
	{
		if (isPlaying) return;
		
		soundTwn?.cancel();
		if (pitchUp)
		{
			sound.resume();
			sound.pitch = 0;
			soundTwn = FlxTween.tween(sound, {pitch: pitch}, 0.2);
		}
		else
		{
			sound.resume();
		}
	}
	
	function animateButton(play:Bool = true)
	{
		parent.musicButtonTwn?.cancel();
		
		parent.musicButton.animation.play(play ? 'play' : 'pause');
		parent.musicButton.scale.set(0.8, 0.8);
		parent.musicButtonTwn = FlxTween.tween(parent.musicButton, {alpha: 1, 'scale.x': 1, 'scale.y': 1}, 0.2, {ease: FlxEase.backOut});
	}
	
	public function hideAndDisable()
	{
		if (!isActive) return;
		
		@:bypassAccessor pitch = 1;
		
		FlxTween.tween(bar, {y: 80, alpha: 0}, 0.2, {ease: FlxEase.cubeOut});
		FlxTween.tween(pitchText, {y: 80, alpha: 0}, 0.2, {ease: FlxEase.cubeOut});
		FlxTween.tween(timeText, {y: 80, alpha: 0}, 0.2, {ease: FlxEase.cubeOut});
		
		parent.musicButton.animation.play('pause');
		parent.musicButtonTwn?.cancel();
		parent.musicButtonTwn = FlxTween.tween(parent.musicButton, {alpha: 0.4, 'scale.x': 0.8, 'scale.y': 0.8}, 0.2, {ease: FlxEase.backOut});
		
		FlxTween.tween(sound, {pitch: 0}, 0.2,
			{
				onComplete: Void -> {
					sound.stop();
					
					resumeGallery();
				}
			});
	}
	
	function resumeGallery()
	{
		FlxG.autoPause = ClientPrefs.data.autoPause;
		
		musicTwn?.cancel();
		
		FlxG.sound.music.resume();
		FlxG.sound.music.pitch = 0;
		musicTwn = FlxTween.tween(FlxG.sound.music, {pitch: 1}, 0.2);
		
		isActive = false;
	}
	
	public function revealAndPlay(snd:Sound)
	{
		play(snd);
		FlxTween.tween(bar, {y: 90, alpha: 1}, 0.4, {ease: FlxEase.cubeOut});
		FlxTween.tween(pitchText, {y: 90 + (pitchText.height - bar.height) / 2, alpha: 0.8}, 0.4, {ease: FlxEase.cubeOut});
		FlxTween.tween(timeText, {y: 90 + (timeText.height - bar.height) / 2, alpha: 0.8}, 0.4, {ease: FlxEase.cubeOut});
		animateButton(true);
	}
	
	var _trackedTime:Float = 0;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (isPlaying)
		{
			if (parent.controls.UI_UP_P || parent.controls.UI_DOWN_P)
			{
				pitch += 0.05 * (parent.controls.UI_DOWN ? -1 : 1);
			}
			else if (parent.controls.UI_LEFT_P || parent.controls.UI_RIGHT_P)
			{
				var time = _trackedTime;
				
				time += 1000 * (parent.controls.UI_LEFT ? -1 : 1);
				
				_trackedTime = FlxMath.bound(time, 0, sound.length);
				
				sound.time = _trackedTime;
			}
			else if (parent.controls.UI_LEFT || parent.controls.UI_RIGHT)
			{
				parent.holdTime += elapsed;
				
				if (parent.holdTime > 0.5)
				{
					if (parent.controls.UI_LEFT) _trackedTime -= 40000 * elapsed;
					else if (parent.controls.UI_RIGHT) _trackedTime += 40000 * elapsed;
				}
				
				_trackedTime = FlxMath.bound(_trackedTime, 0, sound.length);
			}
			else if (parent.controls.UI_LEFT_R || parent.controls.UI_RIGHT_R)
			{
				parent.holdTime = 0;
				
				sound.time = _trackedTime;
			}
			else
			{
				_trackedTime = sound.time;
			}
			
			bar.setValue(_trackedTime / sound.length);
		}
		// else
		// {
		// 	_trackedTime = 0;
		// }
		
		pitchText.text = pitch + 'X';
		pitchText.x = bar.x - pitchText.width - 2;
		
		timeText.x = bar.x + bar.width + 2;
		timeText.text = FlxStringUtil.formatTime(_trackedTime / 1000);
	}
	
	function get_isPlaying():Bool
	{
		return sound == null ? false : sound.playing;
	}
	
	function set_pitch(value:Float):Float
	{
		value = FlxMath.bound(FlxMath.roundDecimal(value, 2), 0.1, 3);
		if (sound != null) sound.pitch = value;
		
		bumpPitchText(FlxMath.signOf(value - pitch) == 1);
		
		return pitch = value;
	}
	
	function bumpPitchText(up:Bool)
	{
		pitchTextTwn?.cancel();
		pitchText.y += up ? -2 : 2;
		pitchTextTwn = FlxTween.tween(pitchText, {y: 90 + (pitchText.height - bar.height) / 2}, 0.1, {ease: FlxEase.cubeOut});
	}
}

private class ProgressBar extends FlxSprite
{
	public var fill:SmoothSprite;
	
	var layer:FlxSprite;
	
	public function new(x:Float = 0, y:Float = 0, width:Float = 100, height:Float = 25, thickness:Float = 4)
	{
		super(x, y);
		makeGraphic(Std.int(width), Std.int(height));
		layer = new FlxSprite().makeGraphic(Std.int(width - thickness), Std.int(height - thickness), FlxColor.BLACK);
		
		fill = new SmoothSprite();
		fill.makeGraphic(Std.int(width - (thickness * 2)), Std.int(height - (thickness * 2)), FlxColor.WHITE);
		
		setValue(0.5);
	}
	
	override function draw()
	{
		super.draw();
		
		layer.centerOnObject(this);
		layer.alpha = alpha;
		if (visible) layer.draw();
		
		fill.centerOnObject(this);
		fill.alpha = alpha;
		if (visible) fill.draw();
	}
	
	override function destroy()
	{
		super.destroy();
		fill = FlxDestroyUtil.destroy(fill);
		layer = FlxDestroyUtil.destroy(layer);
	}
	
	public function setValue(v:Float) // 0 - 1
	{
		if (fill.clipRect == null) fill.clipRect = new FlxRect(0, 0, fill.frameWidth, fill.frameHeight);
		
		final newWidth = fill.frameWidth * v;
		if (newWidth == fill.clipRect.width) return;
		
		fill.clipRect.width = newWidth;
		fill.clipRect = fill.clipRect;
	}
}

private class SmoothSprite extends FlxSprite
{
	override function set_clipRect(rect:FlxRect)
	{
		clipRect = rect;
		
		if (frames != null) frame = frames.frames[animation.frameIndex];
		
		return rect;
	}
}

private class Entry extends FlxSprite
{
	public var twn:Null<FlxTween> = null;
	
	public var isKilling:Bool = false;
	
	public function killSelf(direction:Int)
	{
		isKilling = true;
		
		twn?.cancel();
		
		twn = FlxTween.tween(this, {alpha: 0, x: this.x - (50 * direction)}, 0.1,
			{
				onComplete: Void -> {
					this.kill();
					isKilling = false;
				}
			});
	}
	
	public function revealSelf(direction:Int)
	{
		twn?.cancel();
		
		isKilling = false;
		this.alpha = 0;
		
		this.screenCenter();
		this.x += (50 * direction);
		
		twn = FlxTween.tween(this, {alpha: 1, x: this.x - (50 * direction)}, 0.5, {ease: FlxEase.expoOut});
	}
}
