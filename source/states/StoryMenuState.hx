package states;

import flixel.util.FlxStringUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.graphics.FlxGraphic;

import objects.MenuItem;

import backend.WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	private static var lastDifficultyName:String = '';
	private static var curWeek:Int = 0;
	
	var loadedWeeks:Array<WeekData> = [];
	
	var scoreText:FlxText;
	
	var curDifficulty:Int = 1;
	
	var txtWeekTitle:FlxText;
	var songNameWeek:FlxText;
	
	var grpWeekText:FlxTypedGroup<MenuItem>;
	
	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	
	var bgSpr:FlxBackdrop;
	var bgGradient:FlxSprite;
	var icons:FlxSprite;
	var charLeft:FlxSprite;
	var charRight:FlxSprite;
	
	var checkerbg:FlxBackdrop;
	var border:FlxSprite;
	
	var _started:Bool = false;
	
	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		
		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		
		if (curWeek >= WeekData.weeksList.length) curWeek = 0;
		
		CoolUtil.tryPlayingMenuMusic();
		
		super.create();
		
		MusicBeatState.currentTransition = SWIPE;
		
		bgSpr = new FlxBackdrop();
		add(bgSpr);
		bgSpr.velocity.x = -5;
		
		bgGradient = new FlxSprite(0, -100);
		add(bgGradient);
		
		checkerbg = new FlxBackdrop(Paths.image('menuassets/CheckerLerpPurple'), XY, 1, 5);
		checkerbg.scale.set(0.5, 0.5);
		checkerbg.antialiasing = ClientPrefs.data.antialiasing;
		checkerbg.alpha = 0.2;
		add(checkerbg);
		checkerbg.velocity.x = 15;
		
		final ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		
		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);
		
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if (!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, 325, WeekData.weeksList[i]); // y needs to be set a bit down
				weekThing.y += (weekThing.height - 105);
				weekThing.scale.set(0.65, 0.65);
				grpWeekText.add(weekThing);
				
				weekThing.screenCenter(X);
				weekThing.antialiasing = ClientPrefs.data.antialiasing;
				// weekThing.updateHitbox();
				
				// Needs an offset thingie
				// if (isLocked)
				// {
				// 	var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				// 	lock.frames = ui_tex;
				// 	lock.animation.addByPrefix('lock', 'lock');
				// 	lock.animation.play('lock');
				// 	lock.ID = i;
				// 	lock.antialiasing = ClientPrefs.data.antialiasing;
				// 	grpLocks.add(lock);
				// }
			}
		}
		
		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		
		border = new FlxSprite(-55, -36.2).loadGraphic(Paths.image('menuassets/story_mode/border'));
		border.frames = Paths.getSparrowAtlas('menuassets/story_mode/border');
		border.animation.addByPrefix('idle', 'Symbol 1 instance 1', 24, true);
		border.antialiasing = ClientPrefs.data.antialiasing;
		border.animation.play('idle');
		border.updateHitbox();
		add(border);
		
		icons = new FlxSprite();
		add(icons);
		
		charLeft = new FlxSprite();
		add(charLeft);
		
		charRight = new FlxSprite();
		add(charRight);
		
		for (i in [bgSpr, bgGradient, icons, charLeft, charRight])
		{
			i.antialiasing = ClientPrefs.data.antialiasing;
		}
		
		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);
		scoreText.alpha = 0.7;
		
		txtWeekTitle = new FlxText(0, 5, FlxG.width - 10, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;
		
		songNameWeek = new FlxText(0, 30, FlxG.width - 10, "i suck penis!!", 32);
		songNameWeek.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, RIGHT);
		songNameWeek.alpha = 0.5;
		
		difficultySelectors = new FlxGroup();
		add(difficultySelectors);
		
		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width - 380, grpWeekText.members[0].y + 0);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.data.antialiasing;
		leftArrow.y = (FlxG.height - leftArrow.height) - 15;
		difficultySelectors.add(leftArrow);
		
		Difficulty.resetList();
		if (lastDifficultyName == '')
		{
			lastDifficultyName = Difficulty.getDefault();
		}
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		
		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = ClientPrefs.data.antialiasing;
		sprDifficulty.screenCenter(X);
		difficultySelectors.add(sprDifficulty);
		leftArrow.x = (sprDifficulty.x - leftArrow.width) - 15;
		
		rightArrow = new FlxSprite((sprDifficulty.x + sprDifficulty.width) + 15, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.data.antialiasing;
		difficultySelectors.add(rightArrow);
		
		var snd = CoolUtil.getMenuMusic();
		if (FlxG.sound.music == null || FlxG.sound.music.length != snd.length)
		{
			CoolUtil.playMenuMusic();
		}
		FlxG.sound.music.pitch = 1;
		
		add(scoreText);
		add(txtWeekTitle);
		add(songNameWeek);
		
		changeWeek();
		changeDifficulty();
		
		_cacheChars();
		
		addTouchPad("LEFT_FULL", "A_B_X_Y");
		//addTouchPadCamera();
	}
	
	function _cacheChars()
	{
		//
		for (i in loadedWeeks)
		{
			if (i.directFile.leftCharacter != null && i.directFile.leftCharacter.img != null)
			{
				Paths.getSparrowAtlas('menuassets/story_mode/char/' + i.directFile.leftCharacter.img);
			}
			
			if (i.directFile.rightCharacter != null && i.directFile.rightCharacter.img != null)
			{
				Paths.getSparrowAtlas('menuassets/story_mode/char/' + i.directFile.rightCharacter.img);
			}
		}
	}
	
	override function closeSubState()
	{
		persistentUpdate = true;
		changeWeek();
		removeTouchPad();
		addTouchPad("LEFT_FULL", "A_B_X_Y");
		//addTouchPadCamera();
		super.closeSubState();
	}
	
	override function update(elapsed:Float)
	{
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 30, 0, 1)));
		if (Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;
		
		scoreText.text = "WEEK SCORE:" + lerpScore;
		
		if (!movedBack && !selectedWeek)
		{
			if (controls.UI_UP_P)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			
			if (controls.UI_DOWN_P)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			
			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(-FlxG.mouse.wheel);
				changeDifficulty();
			}
			
			if (controls.UI_RIGHT) rightArrow.animation.play('press')
			else rightArrow.animation.play('idle');
			
			if (controls.UI_LEFT) leftArrow.animation.play('press');
			else leftArrow.animation.play('idle');
			
			if (controls.UI_RIGHT_P) changeDifficulty(1);
			else if (controls.UI_LEFT_P) changeDifficulty(-1);
			else if (controls.UI_UP_P || controls.UI_DOWN_P) changeDifficulty();
			
			if (FlxG.keys.justPressed.CONTROL || touchPad != null && touchPad.buttonX.justPressed)
			{
				persistentUpdate = false;
				openSubState(new substates.GameplayChangersSubstate());
				removeTouchPad();
			}
			else if (controls.RESET || touchPad != null && touchPad.buttonY.justPressed)
			{
				if (curWeek != 5)
				{
					persistentUpdate = false;
					openSubState(new substates.ResetScoreSubState('', curDifficulty, '', curWeek));
					removeTouchPad();
				}
			}
			else if (controls.ACCEPT)
			{
				selectWeek();
			}
		}
		
		if (controls.BACK && !movedBack && !selectedWeek)
		{
			MusicBeatState.currentTransition = SWIPE;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(() -> new MainMenuState());
		}
		
		super.update(elapsed);
	}
	
	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;
	
	function selectWeek()
	{
		if (loadedWeeks[curWeek].fileName == 'comingSoon') // cheep method but it works
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.camera.shake(0.001, 0.3);
			
			return;
		}
		
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				
				grpWeekText.members[curWeek].isFlashing = true;
				
				stopspamming = true;
			}
			
			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length)
			{
				songArray.push(leWeek[i][0]);
			}
			
			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;
			
			var diffic = Difficulty.getFilePath(curDifficulty);
			
			if (diffic == null) diffic = '';
			
			PlayState.storyDifficulty = curDifficulty;
			
			try
			{
				PlayState.SONG = backend.Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
				
				MusicBeatState.currentTransition = STICKERS;
				new FlxTimer().start(1, function(tmr:FlxTimer) {
					LoadingState.loadAndSwitchState(() -> new PlayState(), true);
					FreeplayState.destroyFreeplayVocals();
				});
			}
			catch (e)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.camera.shake(0.01, 0.2);
				selectedWeek = false;
			}
		}
		else
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}
	
	var tweenDifficulty:FlxTween;
	
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;
		
		if (curDifficulty < 0) curDifficulty = Difficulty.list.length - 1;
		if (curDifficulty >= Difficulty.list.length) curDifficulty = 0;
		
		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);
		
		var diff:String = Difficulty.getString(curDifficulty);
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		// trace(Paths.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));
		
		if (sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.updateHitbox();
			sprDifficulty.screenCenter(X);
			sprDifficulty.y = FlxG.height - sprDifficulty.height;
			sprDifficulty.alpha = 0;
			
			leftArrow.x = (sprDifficulty.x - leftArrow.width) - 15;
			rightArrow.x = (sprDifficulty.x + sprDifficulty.width) + 15;
			if (tweenDifficulty != null) tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 10, alpha: 1}, 0.07,
				{
					onComplete: function(twn:FlxTween) {
						tweenDifficulty = null;
					}
				});
		}
		lastDifficultyName = diff;
		
		intendedScore = backend.Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
	}
	
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	
	function changeWeek(change:Int = 0):Void
	{
		var lastWeek = loadedWeeks[curWeek];
		
		curWeek = FlxMath.wrap(curWeek + change, 0, loadedWeeks.length - 1);
		
		final currentWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(currentWeek);
		
		txtWeekTitle.text = currentWeek.storyName.toUpperCase();
		
		final iconTag = currentWeek?.icons ?? 'icon0';
		icons.loadGraphic(Paths.image('menuassets/story_mode/$iconTag'));
		icons.updateHitbox();
		icons.screenCenter(X);
		
		final gradientTag = currentWeek.gradient ?? 'gradient0';
		bgGradient.loadGraphic(Paths.image('menuassets/story_mode/$gradientTag'));
		
		final bgTag = currentWeek.storyBG ?? '';
		
		var bgGraphic = Paths.image('menuassets/story_mode/$bgTag');
		bgSpr.loadGraphic(bgGraphic);
		bgSpr.setGraphicSize(0, FlxG.height);
		bgSpr.updateHitbox();
		
		bgSpr.x = 100;
		
		final rightOffsets = currentWeek.directFile?.rightCharacter?.offsets ?? [0., 0.];
		final leftOffsets = currentWeek.directFile?.leftCharacter?.offsets ?? [0., 0.];
		
		if ((change == 0 && !_started)
			|| (currentWeek.directFile.leftCharacter != null
				&& lastWeek.directFile.leftCharacter != null
				&& lastWeek.directFile.leftCharacter.img != currentWeek.directFile.leftCharacter.img))
		{
			final img = currentWeek.directFile?.leftCharacter?.img ?? '';
			charLeft.frames = Paths.getSparrowAtlas('menuassets/story_mode/char/$img');
			charLeft.x = 0 + leftOffsets[0];
			
			charLeft.animation.addByPrefix('idle', 'idle instance 1', 24);
			charLeft.animation.play('idle');
			
			FlxTween.cancelTweensOf(charLeft, ['x']);
			FlxTween.tween(charLeft, {x: 50 + leftOffsets[0]}, 3, {ease: FlxEase.expoOut});
		}
		
		if ((change == 0 && !_started)
			|| (currentWeek.directFile.rightCharacter != null
				&& lastWeek.directFile.rightCharacter != null
				&& lastWeek.directFile.rightCharacter.img != currentWeek.directFile.rightCharacter.img))
		{
			final img = currentWeek.directFile?.rightCharacter?.img ?? '';
			
			charRight.frames = Paths.getSparrowAtlas('menuassets/story_mode/char/$img');
			charRight.x = FlxG.width - charRight.frameWidth + rightOffsets[0];
			
			charRight.animation.addByPrefix('idle', 'idle instance 1', 24);
			charRight.animation.play('idle');
			
			FlxTween.cancelTweensOf(charRight, ['x']);
			FlxTween.tween(charRight, {x: FlxG.width - charRight.frameWidth - 50 + rightOffsets[0]}, 3, {ease: FlxEase.expoOut});
		}
		
		charRight.y = (FlxG.height - charRight.frameHeight) - 75;
		charRight.y += rightOffsets[1];
		
		charLeft.y = (FlxG.height - charLeft.frameHeight) - 75;
		charLeft.y += leftOffsets[1];
		
		var unlocked:Bool = !weekIsLocked(currentWeek.fileName);
		for (k => item in grpWeekText.members)
		{
			item.targetY = k - curWeek;
			if (item.targetY == Std.int(0) && unlocked) item.alpha = 1;
			else item.alpha = 0.4;
		}
		
		PlayState.storyWeek = curWeek;
		
		Difficulty.resetList();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if (diffStr != null) diffStr = diffStr.trim(); // Fuck you HTML5
		difficultySelectors.visible = unlocked;
		
		if (diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if (diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if (diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}
			
			if (diffs.length > 0 && diffs[0].length > 0)
			{
				Difficulty.list = diffs;
			}
		}
		
		if (Difficulty.list.contains(Difficulty.getDefault()))
		{
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		}
		else
		{
			curDifficulty = 0;
		}
		
		var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
		if (newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
		
		_started = true;
	}
	
	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}
	
	function updateText()
	{
		intendedScore = backend.Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		
		if (loadedWeeks[curWeek].songs != null) songNameWeek.text = [for (i in loadedWeeks[curWeek].songs) FlxStringUtil.toTitleCase(i[0])].join(' • ');
		else songNameWeek.text = '';
	}
}
