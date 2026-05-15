import lime.system.BackgroundWorker;

import flixel.system.scaleModes.RatioScaleMode;
import flixel.ui.FlxBar;

import openfl.media.Sound;

import states.TitleState;

enum abstract PreloadType(Int)
{
	var SONG;
	var SOUND;
	var IMAGE;
}

class Preload extends MusicBeatState
{
	static final songsToPreload:Array<String> = [
		'curiosity',
		// 'bad-luck',
		'nine-lives',
		// 'babe',
		'dejala',
		'milk-duds',
		'carefree',
		// 'cat',
		// 'miau'
	];
	
	static final soundsToPreload:Array<String> = [
		"soundtray/beep",
		"soundtray/VolMAX"
	];
	
	static final imagesToPreload:Array<String> = [];
	
	var preloadList:Array<{type:PreloadType, file:String}>;
	
	var sticker:FlxSprite;
	var lastSticker:Int = -1;
	var stickerAngleBopTimer:Float = 0.5;
	var stickerAngleFlipped:Bool = false;
	
	var loadingTxt:FlxText;
	var curLoadingTxt:FlxText;
	var tipText:FlxText;
	
	var timerTillPreload:Float = 5;
	
	var loadingBar:FlxBar; // unfortunately has to be a flxbar
	
	var loadPercent(get, never):Float;
	var loaded:Int = 0;
	var toLoad:Int = 0;
	
	var canceled:Bool = false;
	var preloading:Bool = false;
	var exiting:Bool = false;
	
	var worker:BackgroundWorker;
	
	var splashText:Array<String> = CoolUtil.coolTextFile(Paths.getPath('data/introText.txt'));
	
	override function create()
	{
		super.create();
		
		preloadList = [];
		
		for (i in songsToPreload)
			preloadList.push({file: i, type: SONG});
			
		for (i in soundsToPreload)
			preloadList.push({file: i, type: SOUND});
			
		for (i in imagesToPreload)
			preloadList.push({file: i, type: IMAGE});
			
		toLoad = preloadList.length;
		loaded = 0;
		
		Mods.loadTopMod();
		
		#if desktop
		@:privateAccess
		{
			(cast FlxG.scaleMode : RatioScaleMode).fillScreen = true;
			FlxG.resizeWindow(TitleState.FAKE_WIDTH, backend.Native.windowHeight);
			FlxG.stage.window.resizable = false;
			CoolUtil.centerWindow();
		}
		#end
		
		sticker = new FlxSprite();
		sticker.frames = Paths.getAtlas('stickers/1');
		add(sticker);
		sticker.scale.set(0.7, 0.7);
		sticker.antialiasing = true;
		randomizeIcon();
		
		loadingBar = new FlxBar(0, 0, LEFT_TO_RIGHT, 400, 25, this, 'loadPercent', 0, 1);
		loadingBar.screenCenter();
		loadingBar.y = FlxG.height * 0.65;
		loadingBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
		
		add(new FlxSprite(loadingBar.x - 8, loadingBar.y - 8).makeScaledGraphic(loadingBar.width + 16, loadingBar.height + 16));
		add(new FlxSprite(loadingBar.x - 4, loadingBar.y - 4).makeScaledGraphic(loadingBar.width + 8, loadingBar.height + 8, FlxColor.BLACK));
		
		add(loadingBar);
		
		curLoadingTxt = new FlxText(0, 0, FlxG.width, 'Loading...', 12);
		curLoadingTxt.font = Paths.font('PixelOperator8.ttf');
		curLoadingTxt.alignment = CENTER;
		add(curLoadingTxt);
		curLoadingTxt.y = loadingBar.y - curLoadingTxt.height - 25;
		
		loadingTxt = new FlxText(0, 0, FlxG.width, 'Asset preloading will start in $timerTillPreload\n\nPress SPACE to cancel.', 12);
		loadingTxt.font = Paths.font('PixelOperator8.ttf');
		loadingTxt.alignment = CENTER;
		add(loadingTxt);
		loadingTxt.y = loadingBar.y + loadingBar.height + 25;
		
		tipText = new FlxText(0, 0, FlxG.width, FlxG.random.getObject(splashText), 16);
		tipText.font = Paths.font('PixelOperator8.ttf');
		tipText.alignment = CENTER;
		add(tipText);
		tipText.y = loadingBar.y - curLoadingTxt.height - 60;
		tipText.alpha = 0.5;
		
		addTouchPad("NONE", "A_B");
		addTouchPadCamera();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		FlxG.mouse.visible = true;
		
		if (timerTillPreload > 0)
		{
			if (!canceled)
			{
				timerTillPreload -= elapsed;
				
				final timeLeft = Math.ceil(timerTillPreload);
				
				loadingTxt.text = 'Asset preloading will start in $timeLeft\nPress B to cancel.\n\nOr Press A to start now.';
			}
			
			if (FlxG.keys.justPressed.SPACE || touchPad != null && touchPad.buttonB.justPressed)
			{
				canceled = true;
				curLoadingTxt.text = 'Loading Canceled';
				loadingTxt.visible = false;
				
				exit();
			}
			
			if (FlxG.keys.justPressed.ENTER || touchPad != null && touchPad.buttonA.justPressed)
			{
				timerTillPreload = 0;
			}
		}
		else if (loadPercent >= 1 && !exiting)
		{
			exiting = true;
			
			curLoadingTxt.text = 'Loading Complete';
			exit();
		}
		else if (loadPercent < 1)
		{
			if (!preloading) startPreloading();
			
			loadingTxt.visible = false;
			
			var text = 'Loading...';
			
			if (loaded != -1) text += preloadList[loaded]?.file ?? '';
			
			curLoadingTxt.text = text;
		}
		
		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(sticker))
		{
			randomizeIcon();
		}
		
		stickerAngleBopTimer -= elapsed;
		
		if (stickerAngleBopTimer <= 0)
		{
			stickerAngleBopTimer = 1;
			sticker.angle = stickerAngleFlipped ? 5 : 0;
			stickerAngleFlipped = !stickerAngleFlipped;
		}
	}
	
	function randomizeIcon()
	{
		sticker.animation.frameIndex = FlxG.random.int(0, sticker.animation.numFrames, [lastSticker]);
		lastSticker = sticker.animation.frameIndex;
		
		sticker.updateHitbox();
		sticker.screenCenter().y -= 100;
	}
	
	function exit()
	{
		MusicBeatState.currentTransition = FADE;
		FlxTimer.wait(1, () -> {
			FlxG.camera.fade(FlxColor.BLACK, 1, false, () -> {
				FlxG.switchState(() -> Type.createInstance(Main.game.initialState, []));
			});
		});
	}
	
	function startPreloading()
	{
		preloading = true;
		
		var preloads = preloadList.copy();
		if (preloads.length == 0) return;
		
		worker = new BackgroundWorker();
		
		worker.doWork.add(_ -> {
			for (preload in preloadList)
			{
				switch (preload.type)
				{
					case SONG:
						preloadSong(preload.file);
						
					case IMAGE:
					
					case SOUND:
						preloadSound(preload.file);
						
					default:
				}
				
				trace('preloaded ' + preload.file);
				loaded++;
				
				Sys.sleep(0.1);
			}
		}, true);
		
		worker.run();
	}
	
	function preloadSound(file:String)
	{
		var path = Paths.getPath('sounds/$file.ogg', SOUND, null, true);
		if (FileSystem.exists(path))
		{
			Paths.currentTrackedSounds.set(path, Sound.fromFile(path));
			Paths.excludeAsset(path);
		}
	}
	
	function preloadSong(song:String)
	{
		var path = Paths.getPath('$song/Inst.ogg', SOUND, 'songs', true);
		if (FileSystem.exists(path))
		{
			Paths.currentTrackedSounds.set(path, Sound.fromFile(path));
			Paths.excludeAsset(path);
		}
		
		var path = Paths.getPath('$song/Voices.ogg', SOUND, 'songs', true);
		if (FileSystem.exists(path))
		{
			Paths.currentTrackedSounds.set(path, Sound.fromFile(path));
			Paths.excludeAsset(path);
		}
	}
	
	function get_loadPercent():Float
	{
		if (toLoad == 0) return 1;
		return Math.max(0, loaded / toLoad);
	}
	
	override function destroy()
	{
		super.destroy();
	}
}
