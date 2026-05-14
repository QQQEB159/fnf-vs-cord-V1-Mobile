package objects;

import flixel.group.FlxGroup;
import flixel.ui.FlxBar;
import flixel.util.FlxStringUtil;
import flixel.FlxObject;
import flixel.FlxState;

import states.FreeplayState;
import states.GalleryState;

/**
 * Music player used for Freeplay
 */
@:access(states.FreeplayState)
@:access(states.GalleryState)
class MusicPlayer extends FlxGroup
{
	public var instance:FreeplayState;
	public var freeplay:FreeplayState;
	public var gallery:GalleryState;
	
	public var playing(get, never):Bool;
	public var paused(get, never):Bool;
	
	public var playingMusic:Bool = false;
	public var curTime:Float;
	
	var songBG:FlxSprite;
	var songTxt:FlxText;
	var timeTxt:FlxText;
	var progressBar:FlxBar;
	var playbackBG:FlxSprite;
	var playbackSymbols:Array<FlxText> = [];
	var playbackTxt:FlxText;
	
	var wasPlaying:Bool;
	
	var holdPitchTime:Float = 0;
	var playbackRate(default, set):Float = 1;
	
	public function new(parent:FlxState)
	{
		super();
		
		if (Std.isOfType(parent, FreeplayState)) freeplay = cast parent;
		else if (Std.isOfType(parent, GalleryState)) gallery = cast parent;
		
		var xPos:Float = FlxG.width * 0.7;
		
		if (gallery != null)
		{
			songBG = new FlxSprite(xPos - 6, 125).makeGraphic(1, 100, 0xFF000000);
			songBG.alpha = 0.6;
			add(songBG);
			
			playbackBG = new FlxSprite(xPos - 6, 125).makeGraphic(1, 100, 0xFF000000);
			playbackBG.alpha = 0.6;
			add(playbackBG);
			
			songTxt = new FlxText(FlxG.width * 0.7, 130, 0, "", 32);
			songTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
			add(songTxt);
			
			timeTxt = new FlxText(xPos, songTxt.y + 60, 0, "", 32);
			timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
			add(timeTxt);
		}
		else
		{
			songBG = new FlxSprite(xPos - 6, 0).makeGraphic(1, 100, 0xFF000000);
			songBG.alpha = 0.6;
			add(songBG);
			
			playbackBG = new FlxSprite(xPos - 6, 0).makeGraphic(1, 100, 0xFF000000);
			playbackBG.alpha = 0.6;
			add(playbackBG);
			
			songTxt = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
			songTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
			add(songTxt);
			
			timeTxt = new FlxText(xPos, songTxt.y + 60, 0, "", 32);
			timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
			add(timeTxt);
		}
		
		for (i in 0...2)
		{
			var text:FlxText = new FlxText();
			text.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, CENTER);
			text.text = '^';
			if (i == 1) text.flipY = true;
			text.visible = false;
			playbackSymbols.push(text);
			add(text);
		}
		
		progressBar = new FlxBar(timeTxt.x, timeTxt.y + timeTxt.height, LEFT_TO_RIGHT, Std.int(timeTxt.width), 8, null, "", 0, Math.POSITIVE_INFINITY);
		progressBar.createFilledBar(FlxColor.WHITE, FlxColor.BLACK);
		add(progressBar);
		
		playbackTxt = new FlxText(FlxG.width * 0.6, 120, 0, "", 32);
		playbackTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE);
		add(playbackTxt);
		
		switchPlayMusic();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (!playingMusic)
		{
			return;
		}
		
		if (freeplay != null)
		{
			if (paused && !wasPlaying) songTxt.text = 'PLAYING: ' + freeplay.songs[FreeplayState.curSelected].songName + ' (PAUSED)';
			else songTxt.text = 'PLAYING: ' + freeplay.songs[FreeplayState.curSelected].songName;
		}
		else
		{
			var currentIndex = GalleryState.currentIndex;
			var entry = gallery.galleryShit[currentIndex];
			var soundName = entry.audio.toUpperCase();
			var soundNameSpace = StringTools.replace(soundName, "-", " ");
			if (paused && !wasPlaying) songTxt.text = 'PLAYING: ' + soundNameSpace + ' (PAUSED)';
			else songTxt.text = 'PLAYING: ' + soundNameSpace;
		}
		
		positionSong();
		
		if (freeplay != null && (freeplay.controls.UI_LEFT_P) || (gallery != null && (gallery.controls.UI_LEFT_P)))
		{
			if (playing) wasPlaying = true;
			
			pauseOrResume();
			
			if (freeplay != null)
			{
				FlxG.sound.music.time = curTime;
				curTime = FlxG.sound.music.time - 1000;
				freeplay.holdTime = 0;
				
				if (curTime < 0) curTime = 0;
				
				if (FreeplayState.vocals != null) FreeplayState.vocals.time = curTime;
			}
			else
			{
				gallery.currentSound.time = curTime;
				curTime = gallery.currentSound.time - 1000;
				gallery.holdTime = 0;
				
				if (curTime < 0) curTime = 0;
				
				if (gallery.currentSound != null) gallery.currentSound.time = curTime;
			}
		}
		if (freeplay != null && (freeplay.controls.UI_RIGHT_P) || (gallery != null && (gallery.controls.UI_RIGHT_P)))
		{
			if (playing) wasPlaying = true;
			
			pauseOrResume();
			
			if (freeplay != null)
			{
				FlxG.sound.music.time = curTime;
				curTime = FlxG.sound.music.time + 1000;
				freeplay.holdTime = 0;
				
				if (curTime > FlxG.sound.music.length) curTime = FlxG.sound.music.length;
				
				if (FreeplayState.vocals != null) FreeplayState.vocals.time = curTime;
			}
			else
			{
				gallery.currentSound.time = curTime;
				curTime = gallery.currentSound.time + 1000;
				gallery.holdTime = 0;
				
				if (curTime > gallery.currentSound.length) curTime = gallery.currentSound.length;
				
				if (gallery.currentSound != null) gallery.currentSound.time = curTime;
			}
			
			/*curTime = FlxG.sound.music.time + 1000;
				instance.holdTime = 0;

				if (curTime > FlxG.sound.music.length)
					curTime = FlxG.sound.music.length;

				FlxG.sound.music.time = curTime;
				if (FreeplayState.vocals != null)
					FreeplayState.vocals.time = curTime;

				if (freeplay !=  null)
				{
					if (FreeplayState.vocals != null)
						FreeplayState.vocals.time = curTime;
				}
				else
				{
				if (GalleryState.currentSound != null)
					GalleryState.currentSound.time = curTime;
			}*/
		}
		
		updateTimeTxt();
		
		// Handle LEFT/RIGHT hold for seeking in Freeplay or Gallery
		if ((freeplay != null && (freeplay.controls.UI_LEFT || freeplay.controls.UI_RIGHT))
			|| (gallery != null && (gallery.controls.UI_LEFT || gallery.controls.UI_RIGHT)))
		{
			if (freeplay != null)
			{
				freeplay.holdTime += elapsed;
				
				if (freeplay.holdTime > 0.5)
				{
					var direction = freeplay.controls.UI_LEFT ? -1 : 1;
					curTime += 40000 * elapsed * direction;
				}
				
				// Bound curTime within music bounds
				var difference = Math.abs(curTime - FlxG.sound.music.time);
				curTime = FlxMath.bound(curTime, difference, FlxG.sound.music.length);
				
				FlxG.sound.music.time = curTime;
				if (FreeplayState.vocals != null) FreeplayState.vocals.time = curTime;
			}
			else if (gallery != null)
			{
				gallery.holdTime += elapsed;
				
				if (gallery.holdTime > 0.5)
				{
					if (gallery.controls.UI_LEFT) curTime -= 40000 * elapsed;
					else if (gallery.controls.UI_RIGHT) curTime += 40000 * elapsed;
				}
				
				// Bound curTime within sound bounds
				var difference = Math.abs(curTime - gallery.currentSound.time);
				curTime = FlxMath.bound(curTime, difference, gallery.currentSound.length);
				
				gallery.currentSound.time = curTime;
			}
			
			updateTimeTxt();
		}
		
		if ((freeplay != null && (freeplay.controls.UI_LEFT_R || freeplay.controls.UI_RIGHT_R))
			|| (gallery != null && (gallery.controls.UI_LEFT_R || gallery.controls.UI_RIGHT_R)))
		{
			if (freeplay != null)
			{
				FlxG.sound.music.time = curTime;
				if (FreeplayState.vocals != null) FreeplayState.vocals.time = curTime;
			}
			else
			{
				if (gallery.currentSound != null) gallery.currentSound.time = curTime;
			}
			
			if (wasPlaying)
			{
				pauseOrResume(true);
				wasPlaying = false;
			}
			
			updateTimeTxt();
		}
		if (freeplay != null && (freeplay.controls.UI_UP_P) || (gallery != null && (gallery.controls.UI_UP_P)))
		{
			holdPitchTime = 0;
			playbackRate += 0.05;
			setPlaybackRate();
		}
		else if (freeplay != null && (freeplay.controls.UI_DOWN_P) || (gallery != null && (gallery.controls.UI_DOWN_P)))
		{
			holdPitchTime = 0;
			playbackRate -= 0.05;
			setPlaybackRate();
		}
		if ((freeplay != null && (freeplay.controls.UI_DOWN || freeplay.controls.UI_UP))
			|| (gallery != null && (gallery.controls.UI_DOWN || gallery.controls.UI_UP)))
		{
			holdPitchTime += elapsed;
			if (holdPitchTime > 0.6)
			{
				playbackRate += 0.05 * (freeplay != null ? (freeplay.controls.UI_UP ? 1 : -1) : (gallery.controls.UI_UP ? 1 : -1));
				setPlaybackRate();
			}
		}
		if (freeplay != null)
		{
			if (FreeplayState.vocals != null && FlxG.sound.music.time > 5)
			{
				var difference:Float = Math.abs(FlxG.sound.music.time - FreeplayState.vocals.time);
				if (difference >= 5 && !paused)
				{
					pauseOrResume();
					FreeplayState.vocals.time = FlxG.sound.music.time;
					pauseOrResume(true);
				}
			}
		}
		
		updatePlaybackTxt();
		
		if (freeplay != null && (freeplay.controls.RESET) || (gallery != null && (gallery.controls.RESET)))
		{
			playbackRate = 1;
			setPlaybackRate();
			
			if (freeplay != null)
			{
				FlxG.sound.music.time = 0;
				if (FreeplayState.vocals != null) FreeplayState.vocals.time = 0;
			}
			else
			{
				if (gallery.currentSound != null) gallery.currentSound.time = 0;
			}
			
			updateTimeTxt();
		}
	}
	
	public function pauseOrResume(resume:Bool = false)
	{
		if (resume)
		{
			if (freeplay != null)
			{
				FlxG.sound.music.resume();
				
				if (FreeplayState.vocals != null) FreeplayState.vocals.resume();
			}
			else
			{
				gallery.currentSound.resume();
			}
		}
		else if (freeplay != null)
		{
			FlxG.sound.music.pause();
			if (FreeplayState.vocals != null) FreeplayState.vocals.pause();
		}
		else
		{
			gallery.currentSound.pause();
		}
		
		positionSong();
	}
	
	public function switchPlayMusic()
	{
		FlxG.autoPause = (!playingMusic && ClientPrefs.data.autoPause);
		active = visible = playingMusic;
		
		if (freeplay != null)
		{
			freeplay.scoreBG.visible = freeplay.diffText.visible = freeplay.scoreText.visible = !playingMusic;
		}
		// Hide Freeplay texts and boxes if playingMusic is true
		songTxt.visible = timeTxt.visible = songBG.visible = playbackTxt.visible = playbackBG.visible = progressBar.visible = playingMusic; // Show Music Player texts and boxes if playingMusic is true
		
		for (i in playbackSymbols)
			i.visible = playingMusic;
			
		holdPitchTime = 0;
		if (freeplay != null)
		{
			freeplay.holdTime = 0;
		}
		else
		{
			gallery.holdTime = 0;
		}
		
		playbackRate = 1;
		updatePlaybackTxt();
		
		if (playingMusic)
		{
			if (freeplay != null)
			{
				freeplay.bottomText.text = "Press SPACE to Pause / Press ESCAPE to Exit / Press R to Reset the Song";
				positionSong();
				
				progressBar.setRange(0, FlxG.sound.music.length);
				progressBar.setParent(FlxG.sound.music, "time");
				progressBar.numDivisions = 1600;
			}
			else
			{
				progressBar.setRange(0, gallery.currentSound.length);
				progressBar.setParent(gallery.currentSound, "time");
				progressBar.numDivisions = 1600;
			}
			
			updateTimeTxt();
		}
		else
		{
			if (freeplay != null)
			{
				freeplay.bottomText.text = freeplay.bottomString;
				freeplay.positionHighscore();
			}
			progressBar.setRange(0, Math.POSITIVE_INFINITY);
			progressBar.setParent(null, "");
			progressBar.numDivisions = 0;
		}
		progressBar.updateBar();
	}
	
	function updatePlaybackTxt()
	{
		var text = "";
		if (playbackRate is Int) text = playbackRate + '.00';
		else
		{
			var playbackRate = Std.string(playbackRate);
			if (playbackRate.split('.')[1].length < 2) // Playback rates for like 1.1, 1.2 etc
				playbackRate += '0';
				
			text = playbackRate;
		}
		playbackTxt.text = text + 'x';
	}
	
	function positionSong()
	{
		if (freeplay != null)
		{
			var length:Int = freeplay.songs[FreeplayState.curSelected].songName.length;
		}
		else
		{
			var length:Int = gallery.currentSound.name.length;
		}
		
		var shortName:Bool = length < 5; // Fix for song names like Ugh, Guns
		songTxt.x = FlxG.width - songTxt.width - 6;
		if (shortName) songTxt.x -= 10 * length - length;
		songBG.scale.x = FlxG.width - songTxt.x + 12;
		if (shortName) songBG.scale.x += 6 * length;
		songBG.x = FlxG.width - (songBG.scale.x / 2);
		timeTxt.x = Std.int(songBG.x + (songBG.width / 2));
		timeTxt.x -= timeTxt.width / 2;
		if (shortName) timeTxt.x -= length - 5;
		
		playbackBG.scale.x = playbackTxt.width + 30;
		playbackBG.x = songBG.x - (songBG.scale.x / 2);
		playbackBG.x -= playbackBG.scale.x;
		
		playbackTxt.x = playbackBG.x - playbackTxt.width / 2;
		if (freeplay != null)
		{
			playbackTxt.y = playbackTxt.height;
		}
		else
		{
			playbackTxt.y = playbackTxt.height + 115;
		}
		
		progressBar.setGraphicSize(Std.int(songTxt.width), 5);
		progressBar.y = songTxt.y + songTxt.height + 10;
		progressBar.x = songTxt.x + songTxt.width / 2 - 15;
		if (shortName)
		{
			progressBar.scale.x += length / 2;
			progressBar.x -= length - 10;
		}
		
		for (i in 0...2)
		{
			var text = playbackSymbols[i];
			text.x = playbackTxt.x + playbackTxt.width / 2 - 10;
			text.y = playbackTxt.y;
			
			if (i == 0) text.y -= playbackTxt.height;
			else text.y += playbackTxt.height;
		}
	}
	
	function updateTimeTxt()
	{
		var text:String = '';
		if (freeplay != null)
		{
			text = FlxStringUtil.formatTime(FlxG.sound.music.time / 1000, false) + ' / ' + FlxStringUtil.formatTime(FlxG.sound.music.length / 1000, false);
		}
		else
		{
			text = FlxStringUtil.formatTime(gallery.currentSound.time / 1000, false)
				+ ' /'
				+ FlxStringUtil.formatTime(gallery.currentSound.length / 1000, false);
		}
		timeTxt.text = '< ' + text + ' >';
	}
	
	function setPlaybackRate()
	{
		if (freeplay != null)
		{
			FlxG.sound.music.pitch = playbackRate;
			if (FreeplayState.vocals != null) FreeplayState.vocals.pitch = playbackRate;
		}
		else
		{
			gallery.currentSound.pitch = playbackRate;
		}
	}
	
	function get_playing():Bool
	{
		if (freeplay != null)
		{
			return FlxG.sound.music.playing;
		}
		else
		{
			return gallery.currentSound.playing;
		}
	}
	
	function get_paused():Bool
	{
		if (freeplay != null)
		{
			@:privateAccess return FlxG.sound.music._paused;
		}
		else
		{
			@:privateAccess return gallery.currentSound._paused;
		}
	}
	
	function set_playbackRate(value:Float):Float
	{
		var value = FlxMath.roundDecimal(value, 2);
		if (value > 3) value = 3;
		else if (value <= 0.25) value = 0.25;
		return playbackRate = value;
	}
}
