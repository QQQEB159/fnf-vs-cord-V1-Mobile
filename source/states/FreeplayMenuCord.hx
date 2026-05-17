package states;

import substates.GameplayChangersSubstate;

import flixel.graphics.tile.FlxGraphicsShader;

import haxe.io.Path;
import haxe.Json;

import flixel.util.FlxDestroyUtil;
import flixel.group.FlxContainer.FlxTypedContainer;
import flixel.util.FlxSignal;
import flixel.FlxBasic;
import flixel.system.FlxBGSprite;

import extensions.flxanimate.FlxAnimateEx;

import objects.HealthIcon;
import objects.FlxTextTyper;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import shaders.ColorSwap;

// lowkey i should reformat this
// the state should control everything primarily and the children just have the functions
class FreeplayMenuCord extends MusicBeatState
{
	static var doIntro:Bool = true;
	
	final TABLE_SCROLLFACTOR = FlxPoint.get(0.6, 0.7);
	
	var blackBg:FlxSprite;
	
	public var melanie:FlxAnimate;
	
	var melanieArm:FlxAnimate;
	var melanieTail:FlxSprite;
	
	public var melanieAnimTimer:FlxTimer = null;
	
	var dialogue:DialogueFreeplay;
	
	var tableVinyl:FlxSprite;
	var desk:FlxSprite;
	
	var freeplayInstance:FreeplayInteraction = null;
	
	public var muffledMusic:FlxSound;
	
	override function create()
	{
		_psychCameraInitialized = true;
		super.create();
		
		if (FlxG.sound.music.length != Paths.music('thriftShopping').length)
		{
			FlxG.sound.playMusic(Paths.music('thriftShopping'));
		}
		
		#if DISCORD_ALLOWED
		DiscordClient.changePresence('In Freeplay', null, null, false, null, 'vol1');
		#end
		
		muffledMusic = FlxG.sound.load(Paths.music('thriftShoppingMuffled'), 0, true);
		muffledMusic.play();
		
		persistentUpdate = true;
		
		FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;
		
		var bg = new FlxSprite(Paths.image('menuassets/freeplay/bg'));
		add(bg);
		bg.scrollFactor.set(0.2, 0.2);
		bg.screenCenter();
		bg.x -= 75;
		
		var stand = new FlxSprite(bg.x + 800, bg.y + 275, Paths.image('menuassets/freeplay/itemStand'));
		add(stand);
		stand.scrollFactor.set(0.25, 0.25);
		
		var rack = new FlxSprite(bg.x + 1240, bg.y + 390, Paths.image('menuassets/freeplay/clothingRack'));
		add(rack);
		rack.scrollFactor.set(0.3, 0.3);
		
		var lights = new FlxSprite(bg.x + 400, bg.y + -118, Paths.image('menuassets/freeplay/frontlights_ADD'));
		add(lights);
		lights.scrollFactor.set(0.5, 0.5);
		lights.blend = ADD;
		
		blackBg = new FlxBGSprite();
		blackBg.color = FlxColor.BLACK;
		add(blackBg);
		blackBg.alpha = 0;
		
		melanieTail = new FlxSprite().loadSparrowFrames('menuassets/freeplay/melanieTail');
		melanieTail.animation.addByPrefix('idle', 'tailIdle instance 1', 24);
		melanieTail.animation.addByPrefix('talk', 'tailTalking instance 1', 24);
		add(melanieTail);
		melanieTail.scrollFactor.copyFrom(TABLE_SCROLLFACTOR);
		
		final tableX = 40;
		
		melanie = new FlxAnimateEx(bg.x + 900 + tableX, bg.y + 130).loadAtlas('menuassets/freeplay/melanieAtlas');
		melanie.applyStageMatrix = true;
		melanie.anim.addBySymbol('idle', '.melanie/melanieIdle', 24);
		melanie.anim.addBySymbol('look', '.melanie/melanieLook', 24, false);
		melanie.anim.addBySymbol('talk-annoyed', '.melanie/melanieTalkAnnoyed', 24);
		melanie.anim.addBySymbol('talk-moody', '.melanie/melanieTalkMoody', 24);
		melanie.anim.addBySymbol('talk', '.melanie/melanieTalkNormal', 24);
		melanie.anim.addBySymbol('talk-serious', '.melanie/melanieTalkSerious', 24);
		melanie.anim.addBySymbol('talk-sideEye', '.melanie/melanieTalkSideEye', 24);
		melanie.animation.onFinish.add(anim -> {
			switch (anim)
			{
				case 'look':
					playMelAnim('idle');
			}
		});
		add(melanie);
		melanie.scrollFactor.copyFrom(TABLE_SCROLLFACTOR);
		
		melanieTail.x = melanie.x + 350;
		melanieTail.y = melanie.y + 400;
		
		desk = new FlxSprite(bg.x + 225 + tableX, bg.y + 370, Paths.image('menuassets/freeplay/table'));
		add(desk);
		desk.scrollFactor.copyFrom(TABLE_SCROLLFACTOR);
		
		melanieArm = new FlxAnimateEx(melanie.x + 217, melanie.y + 372).loadAtlas('menuassets/freeplay/armAtlas');
		melanieArm.applyStageMatrix = true;
		melanieArm.anim.addBySymbol('look', '.melanie/armStatic', 24);
		melanieArm.anim.addBySymbol('idle', '.melanie/armIdle', 24);
		melanieArm.anim.addBySymbol('talk', '.melanie/armTalk', 24);
		add(melanieArm);
		melanieArm.scrollFactor.copyFrom(TABLE_SCROLLFACTOR);
		
		tableVinyl = new FlxSprite(desk.x + 530, desk.y + 333, Paths.image('menuassets/freeplay/tableVinyl'));
		add(tableVinyl);
		tableVinyl.scrollFactor.copyFrom(TABLE_SCROLLFACTOR);
		tableVinyl.antialiasing = ClientPrefs.data.antialiasing;
		
		var overlay = new FlxSprite(bg.x - 200, bg.y - 200, Paths.image('menuassets/freeplay/overlay_ADD'));
		add(overlay);
		overlay.scrollFactor.copyFrom(TABLE_SCROLLFACTOR);
		overlay.blend = ADD;
		
		FlxSprite.defaultAntialiasing = false;
		
		playMelAnim('idle');
		
		final camera = new FlxCamera();
		camera.bgColor = 0x0;
		FlxG.cameras.add(camera, false);
		
		FlxG.camera.zoom = 0.9;
		
		addTouchPad("LEFT_FULL", "A_B_C_T");
		addTouchPadCamera();
		
		if (doIntro)
		{
			placeVinyl();
			doIntro = false;
		}
		else
		{
			blackBg.alpha = 0.7;
			freeplayInstance = new FreeplayInteraction();
			add(freeplayInstance);
			FlxG.camera.scroll.x = -150;
		}
		
		MusicBeatState.currentTransition = SWIPE;
	}
	
	/*override function closeSubState() {
		persistentUpdate = true;
		super.closeSubState();
		removeTouchPad();
		addTouchPad("LEFT_FULL", "A_B_C_T");
	    addTouchPadCamera();
	}*/
	
	function placeVinyl()
	{
		FlxG.camera.zoom = 1.1;
		
		FlxG.camera.scroll.y = 50;
		
		FlxG.camera.fade(FlxColor.BLACK, 1.4, true);
		
		FlxTween.tween(FlxG.camera, {zoom: 0.9, 'scroll.y': 0}, 2, {ease: FlxEase.cubeInOut});
		
		tableVinyl.scale.set(1.5, 1.5);
		tableVinyl.y += 300;
		FlxTween.tween(tableVinyl, {y: desk.y + 333, 'scale.x': 1, 'scale.y': 1}, 0.7, {ease: FlxEase.cubeOut, startDelay: 1.3});
		playMelAnim('look');
		
		melanie.animation.onFinish.addOnce(anim -> {
			FlxTween.tween(blackBg, {alpha: 0.7}, 0.6);
			FlxTween.tween(FlxG.camera.scroll, {x: -150}, 1, {ease: FlxEase.cubeInOut});
			
			var firstTime:Null<Bool> = FlxG.save.data._firstFreeplayInteraction;
			if (firstTime == null)
			{
				firstTime = true;
				FlxG.save.data._firstFreeplayInteraction = true;
				FlxG.save.flush();
			}
			else
			{
				firstTime = false;
			}
			add(freeplayInstance = new FreeplayInteraction(firstTime));
		});
	}
	
	var camFollowDivision:Float = 80;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	public function playMelAnim(anim:String)
	{
		melanie.anim.play(anim);
		if (anim == 'look' || anim == 'idle' || (anim = anim.split('-')[0]) == 'talk')
		{
			melanieArm.anim.play(anim);
			if (melanieTail.animation.exists(anim)) melanieTail.animation.play(anim);
		}
	}
}

@:structInit
class SongMetaSimple
{
	public var song:String;
	public var directory:String;
	public var week:Int;
	public var icon:String;
}

class FreeplayInteraction extends FlxTypedContainer<FlxBasic>
{
	public static final MAX_SONGS:Int = 7;
	
	static var curSel:Int = 0;
	static var curDiff:Int = 1;
	
	var canInteract:Bool = true;
	
	var songMetas:Array<SongMetaSimple> = [];
	var songs:FlxTypedContainer<FlxTextPageTracked>;
	
	var scoreTxtBg:FlxSprite;
	var scoreTxt:FlxText;
	var vinyl:FlxSprite;
	var vinylCopy:FlxSprite;
	var difficultySprite:FlxSprite;
	
	var arrowUp:FlxSprite;
	var arrowDown:FlxSprite;
	var icon:HealthIcon;
	
	var dialogue:DialogueFreeplay;
	
	//
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	
	public function new(firstTime:Bool = false)
	{
		super();
		
		vinylCopy = new FlxSprite();
		add(vinylCopy).kill();
		
		vinyl = new FlxSprite(50, 0, Paths.image('menuassets/freeplay/ui/ost1'));
		add(vinyl);
		vinyl.scale.scale(0.85);
		vinyl.updateHitbox();
		vinyl.y = FlxG.height;
		
		FlxTween.tween(vinyl, {y: (FlxG.height - vinyl.height) / 2 - 20}, 0.6, {ease: FlxEase.cubeOut});
		
		songs = new FlxTypedContainer();
		add(songs);
		
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);
		Difficulty.resetList();
		
		for (i in 0...WeekData.weeksList.length)
		{
			final leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			
			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				songMetas.push(
					{
						song: song[0],
						week: i,
						icon: song[1],
						directory: Mods.currentModDirectory
					});
			}
		}
		Mods.loadTopMod();
		
		arrowUp = new FlxSprite(0, vinyl.y + 100, Paths.image('menuassets/freeplay/ui/arrow'));
		add(arrowUp);
		arrowUp.centerOnObject(vinyl, X);
		
		arrowDown = new FlxSprite(0, 0, Paths.image('menuassets/freeplay/ui/arrow'));
		add(arrowDown);
		arrowDown.centerOnObject(vinyl, X);
		arrowDown.y = vinyl.y + vinyl.height - arrowDown.height - 35;
		arrowDown.flipY = true;
		
		final baseY = 190;
		for (k => i in songMetas)
		{
			var song = new FlxTextPageTracked(vinyl.x, vinyl.y + baseY + ((54 * 0.8) * (k % MAX_SONGS)), vinyl.width, i.song, 28);
			song.alpha = 0.5;
			song.setFormat(Paths.font('KidpixiesRegular-p0Z1.ttf'), 28, FlxColor.WHITE, CENTER);
			
			song.defY = song.y;
			song.page = Math.floor(k / MAX_SONGS);
			
			if (k >= MAX_SONGS)
			{
				song.visible = false;
			}
			
			songs.add(song);
		}
		
		icon = new HealthIcon();
		add(icon);
		icon.scale.scale(0.45);
		var colorSwap = new OutlineShader();
		icon.shader = colorSwap;
		
		difficultySprite = new FlxSprite(vinyl.x + 25, vinyl.y + 25, Paths.image('menuassets/freeplay/ui/normal'));
		add(difficultySprite);
		difficultySprite.scale.copyFrom(vinyl.scale);
		difficultySprite.updateHitbox();
		
		scoreTxtBg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		add(scoreTxtBg);
		scoreTxtBg.alpha = 0.6;
		
		scoreTxt = new FlxText(vinyl.x, vinyl.y + vinyl.height + 25, vinyl.width, 'HELP?', 24);
		add(scoreTxt);
		scoreTxt.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER);
		
		dialogue = new DialogueFreeplay(vinyl.x + vinyl.width + ((FlxG.width - (vinyl.x + vinyl.width))) / 2, FlxG.height - 100 - 85);
		add(dialogue);
		
		dialogue.onStart.add(() -> {
			final state:FreeplayMenuCord = cast FlxG.state;
			
			if (dialogue.lockControls)
			{
				state.muffledMusic.fadeIn(2, state.muffledMusic.volume, 0.2);
				FlxG.sound.music.fadeOut(2);
			}
			
			state.melanieAnimTimer?.cancel();
			
			state.melanie.animation.onLoop.removeAll();
		});
		
		dialogue.onWritingComplete.add(() -> {
			final state:FreeplayMenuCord = cast FlxG.state;
			state.melanieAnimTimer?.cancel();
			state.melanieAnimTimer = FlxTimer.wait(0.3, () -> {
				(cast FlxG.state : FreeplayMenuCord).melanie.animation.onLoop.addOnce((anim) -> {
					(cast FlxG.state : FreeplayMenuCord).playMelAnim('idle');
				});
			});
		});
		
		dialogue.onClose.add(() -> {
			(cast FlxG.state : FreeplayMenuCord).muffledMusic.fadeOut(1);
			FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume);
		});
		
		dialogue.onAdvance.add((dialogue) -> {
			(cast FlxG.state : FreeplayMenuCord).melanieAnimTimer?.cancel();
			(cast FlxG.state : FreeplayMenuCord).melanie.animation.onLoop.removeAll();
			
			(cast FlxG.state : FreeplayMenuCord).playMelAnim(dialogue.anim ?? 'talk');
		});
		
		if (firstTime)
		{
			dialogue.startDialogue('freeplay/intro', {controlLock: true});
		}
		else
		{
			dialogue.startDialogue(getRandomDialogue('entering_menu'), {skippable: false});
		}
		
		changeSel();
		changeDiff();
		
		updateIconPosition(9999, 0.3);
		
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 2]];
	}
	
	inline function getMaxPages():Int
	{
		if (songs == null) return 0;
		return songs.members[songs.length - 1].page;
	}
	
	var _lastPage:Int = 0;
	
	function updateVinylVisual()
	{
		var page = Math.floor(curSel / MAX_SONGS);
		
		if (Paths.fileExists('images/menuassets/freeplay/ui/ost' + Std.string(page + 1) + '.png', IMAGE))
		{
			final image = Paths.image('menuassets/freeplay/ui/ost' + Std.string(page + 1));
			if (vinyl.graphic != image)
			{
				vinylCopy.revive();
				
				FlxTween.cancelTweensOf(vinylCopy);
				FlxTween.cancelTweensOf(vinyl);
				
				vinylCopy.loadGraphic(vinyl.graphic);
				vinylCopy.scale.copyFrom(vinyl.scale);
				vinylCopy.updateHitbox();
				vinylCopy.alpha = 1;
				
				vinylCopy.screenCenter(Y).y -= 20;
				vinylCopy.x = 50;
				
				vinyl.loadGraphic(image);
				vinyl.updateHitbox();
				
				vinyl.screenCenter(Y);
				vinyl.alpha = 0;
				vinyl.y -= 20;
				
				var copyPush = -10;
				if (_lastPage < page)
				{
					vinyl.y -= 10;
					copyPush = 10;
				}
				else
				{
					vinyl.y += 10;
				}
				
				FlxTween.tween(vinyl, {y: ((FlxG.height - vinyl.height) / 2 - 20), alpha: 1}, 0.4, {ease: FlxEase.cubeOut});
				
				FlxTween.tween(vinylCopy, {y: ((FlxG.height - vinyl.height) / 2 - 20) + copyPush, alpha: 0}, 0.4, {ease: FlxEase.cubeOut});
			}
		}
		
		if (getMaxPages() == 0)
		{
			arrowDown.alpha = arrowUp.alpha = 0;
		}
		else
		{
			final ratio = 1 - Math.exp(-FlxG.elapsed * 12);
			
			arrowDown.alpha = FlxMath.lerp(arrowDown.alpha, page < getMaxPages() ? 1 : 0.4, ratio);
			arrowUp.alpha = FlxMath.lerp(arrowUp.alpha, (page == 0 || getMaxPages() == 0) ? 0.4 : 1, ratio);
		}
		
		arrowDown.y = vinyl.y + vinyl.height - arrowDown.height - 35;
		arrowUp.y = vinyl.y + 100;
		difficultySprite.y = vinyl.y + 25;
		
		if (songs != null && songs.length > 0) for (k => i in songs)
		{
			i.visible = i.page == page;
			i.y = vinyl.y + 190 + ((54 * 0.8) * (k % MAX_SONGS));
		}
		
		_lastPage = page;
	}
	
	var holdTime:Float = 0;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (canInteract && !dialogue.lockControls)
		{
			if (Controls.instance.UI_DOWN_P || Controls.instance.UI_UP_P)
			{
				changeSel(Controls.instance.UI_DOWN_P ? 1 : -1);
				holdTime = 0;
			}
			else if (FlxG.mouse.wheel != 0)
			{
				changeSel(-FlxG.mouse.wheel);
				holdTime = 0;
			}
			else if (Controls.instance.UI_LEFT_P || Controls.instance.UI_RIGHT_P)
			{
				changeDiff(Controls.instance.UI_LEFT_P ? -1 : 1);
			}
			else if (Controls.instance.UI_DOWN || Controls.instance.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
				
				if (holdTime > 0.5 && checkNewHold - checkLastHold > 0) changeSel((checkNewHold - checkLastHold) * (Controls.instance.UI_UP ? -1 : 1));
			}
			else if (FlxG.keys.justPressed.CONTROL || FlxG.gamepads.anyJustPressed(Y) || MusicBeatState.getState().touchPad != null && MusicBeatState.getState().touchPad.buttonC.justPressed)
			{
				FlxG.state.openSubState(new GameplayChangersSubstate());
				//MusicBeatState.getState().removeTouchPad();
				FlxG.state.persistentUpdate = false;
				return;
			}
			else if (Controls.instance.ACCEPT)
			{
				selectASong();
			}
			else if (Controls.instance.BACK)
			{
				canInteract = false;
				
				FlxTween.tween(FlxG.sound.music, {pitch: 0}, 0.4);
				FlxG.switchState(() -> new MainMenuState());
			}
			
			if ((FlxG.gamepads.anyJustPressed(X) || FlxG.keys.justPressed.T || MusicBeatState.getState().touchPad != null && MusicBeatState.getState().touchPad.buttonT.justPressed) && !dialogue.isActive)
			{
				if (FlxG.random.bool(30))
				{
					@:privateAccess
					dialogue.dialogue = Hints.grabHint();
					dialogue.startDialogue('', {controlLock: true});
				}
				else
				{
					dialogue.startDialogue(getRandomDialogue('random'), {controlLock: true});
				}
			}
		}
		
		updateVinylVisual();
		
		updateScoreTxt();
		
		updateIconPosition(20, elapsed);
	}
	
	inline function updateIconPosition(ratio:Float, elapsed:Float)
	{
		final x = songs.members[curSel].x + (songs.members[curSel].width - songs.members[curSel].textField.textWidth) / 2;
		
		icon.x = CoolUtil.decayLerp(icon.x, x - (icon.width * 1.7), ratio, elapsed);
		icon.y = CoolUtil.decayLerp(icon.y, songs.members[curSel].y - (75 * 0.8), ratio, elapsed);
	}
	
	function changeDiff(diff:Int = 0)
	{
		if (diff != 0)
		{
			FlxG.sound.play(Paths.sound('freeplay/scroll'));
		}
		
		curDiff = FlxMath.wrap(curDiff + diff, 0, Difficulty.list.length - 1);
		
		var stringified = Difficulty.getString(curDiff);
		if (stringified != null)
		{
			difficultySprite.loadGraphic(Paths.image('menuassets/freeplay/ui/' + stringified.toLowerCase()));
			difficultySprite.updateHitbox();
		}
		
		songs.members[curSel].color = getTextColourFromDiff();
	}
	
	function updateScoreTxt()
	{
		var score = Highscore.getScore(songMetas[curSel].song, curDiff);
		var rating = Highscore.getRating(songMetas[curSel].song, curDiff);
		
		rating = FlxMath.bound(rating * 100, 0, 100);
		
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, score, 1 - Math.exp(-FlxG.elapsed * 24)));
		lerpRating = FlxMath.lerp(lerpRating, rating, 1 - Math.exp(-FlxG.elapsed * 12));
		
		if (FlxMath.equal(lerpScore, score, 10)) lerpScore = score;
		if (FlxMath.equal(lerpRating, rating, 0.1)) lerpRating = rating;
		
		lerpRating = CoolUtil.floorDecimal(lerpRating, 2);
		
		scoreTxt.y = vinyl.y + vinyl.height + 25;
		scoreTxt.text = 'PERSONAL BEST: $lerpScore ($lerpRating%)';
		
		scoreTxtBg.scale.x = vinyl.width * 0.8 + 10;
		scoreTxtBg.scale.y = scoreTxt.textField.textHeight + 10;
		scoreTxtBg.updateHitbox();
		
		scoreTxtBg.x = vinyl.x + (vinyl.width - scoreTxtBg.width) / 2 - 5;
		scoreTxtBg.y = (scoreTxt.y + (scoreTxt.height - scoreTxt.textField.textHeight) / 2) - 5;
	}
	
	function getTextColourFromDiff():FlxColor
	{
		var stringified = Difficulty.getString(curDiff);
		if (stringified == null)
		{
			return FlxColor.WHITE;
		}
		
		stringified = stringified.toLowerCase();
		return stringified == 'easy' ? 0xFFBBFFCE : stringified == 'normal' ? 0xFF9DE0FF : 0xFFE7C3EE;
	}
	
	function changeSel(diff:Int = 0)
	{
		songs.members[curSel].text = '${songMetas[curSel].song}';
		songs.members[curSel].color = FlxColor.WHITE;
		
		FlxTween.cancelTweensOf(songs.members[curSel]);
		FlxTween.tween(songs.members[curSel], {alpha: 0.5}, 0.5);
		
		var lastSel = curSel;
		
		curSel = Std.int(FlxMath.bound(curSel + diff, 0, songs.length - 1));
		
		if (diff != 0 && curSel != lastSel)
		{
			FlxG.sound.play(Paths.sound('freeplay/scroll'));
		}
		
		songs.members[curSel].text = '- ${songMetas[curSel].song} -';
		songs.members[curSel].color = getTextColourFromDiff();
		
		FlxTween.cancelTweensOf(songs.members[curSel]);
		FlxTween.tween(songs.members[curSel], {alpha: 1}, 0.1);
		
		icon.changeIcon(songMetas[curSel].icon);
		
		icon.updateHitbox();
		
		#if DISCORD_ALLOWED
		final vol = songs.members[curSel].page + 1;
		DiscordClient.changePresence('In Freeplay', null, null, false, null, 'vol$vol');
		#end
	}
	
	function selectASong()
	{
		Difficulty.resetList();
		
		final song = Paths.formatToSongPath(songMetas[curSel].song);
		
		final diffFormatted:String = Highscore.formatSong(song, curDiff);
		
		try
		{
			PlayState.SONG = Song.loadFromJson(diffFormatted, song);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDiff;
			
			if (song == 'catch')
			{
				MusicBeatState.currentTransition = WEB_FISHING;
			}
			else
			{
				MusicBeatState.currentTransition = STICKERS;
			}
			
			FlxG.sound.play(Paths.sound('freeplay/confirm'));
			canInteract = false;
		}
		catch (e)
		{
			trace(e);
			
			return;
		}
		
		dialogue.startDialogue(getRandomDialogue('entering_song'), {skippable: false});
		
		FlxTween.tween(FlxG.sound.music, {pitch: 0}, 0.8,
			{
				onComplete: Void -> {
					FlxG.sound.music.pitch = 1;
					FlxG.sound.music.stop();
					FlxG.sound.music.volume = 0;
				}
			});
			
		dialogue.onClose.removeAll();
		
		dialogue.onClose.addOnce(() -> {
			LoadingState.loadAndSwitchState(() -> new PlayState());
		});
		
		// FlxG.sound.music.volume = 0;
		
		(cast FlxG.state : FreeplayMenuCord).muffledMusic.stop();
	}
	
	function getRandomDialogue(directory:String)
	{
		if (FileSystem.exists(Paths.getPath('data/freeplay/$directory'))
			&& FileSystem.isDirectory(Paths.getPath('data/freeplay/$directory')))
		{
			final dialogueToRead = Path.withoutExtension(FlxG.random.getObject(FileSystem.readDirectory(Paths.getPath('data/freeplay/$directory'))));
			return 'freeplay/$directory/$dialogueToRead';
		}
		
		return '';
	}
}

class DialogueFreeplay extends FlxSprite
{
	var typer:FlxTextTyper;
	
	var bg:FlxSprite;
	
	var infoBg:FlxSprite;
	
	var text:FlxText;
	
	var infoText:FlxText;
	
	var reminderBg:FlxSprite;
	
	var reminderText:FlxText;
	
	var skip:FlxSprite;
	
	var icon:FlxSprite;
	
	var closeTimer:FlxTimer = null;
	
	public var dialogue:Array<DialogueStruct> = [];
	
	public var isActive(default, null):Bool = false;
	
	public var lockControls(default, null):Bool = false;
	
	public var onStart:FlxSignal = new FlxSignal();
	public var onWritingComplete:FlxSignal = new FlxSignal();
	public var onAdvance = new FlxTypedSignal<DialogueStruct->Void>();
	public var onClose:FlxSignal = new FlxSignal();
	
	var skipAlpha:Float = 0;
	
	var reminderCheck:Float = 0;
	
	var reminderSin:Float = 0;
	
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		
		alpha = 0;
		
		bg = new FlxSprite();
		bg.makeGraphic(1, 1, FlxColor.BLACK);
		bg.alpha = 0.8;
		
		infoBg = new FlxSprite().makeScaledGraphic(1, 1, FlxColor.BLACK);
		infoBg.alpha = 0.8;
		infoBg.scale.zero();
		
		reminderBg = new FlxSprite().makeScaledGraphic(1, 1, FlxColor.BLACK);
		reminderBg.alpha = 0.8;
		reminderBg.scale.zero();
		
		text = new FlxText(0, 0, 500 - 60, '', 18);
		text.setFormat(Paths.font('VGA.ttf'), 18);
		
		infoText = new FlxText(0, 0, 0, 'Press T to skip', 18);
		infoText.setFormat(Paths.font('VGA.ttf'), 18);
		
		reminderText = new FlxText(0, 0, 0, 'Press T to skip', 18);
		reminderText.setFormat(Paths.font('VGA.ttf'), 18);
		
		skip = new FlxSprite(0, 0, Paths.image('menuassets/freeplay/ui/skip'));
		
		icon = new FlxSprite(0, 0, Paths.image('menuassets/freeplay/ui/icon-melanie'));
		
		icon.antialiasing = true;
		
		var b = false;
		new FlxTimer().start(0.7, (tmr) -> {
			b = !b;
			icon.angle = b ? 5 : -5;
		}, 0);
		
		closeTimer = new FlxTimer();
		
		typer = new FlxTextTyper();
		typer.delay = CONST(0.04);
		
		var typingRules = [new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFFC549), '*')];
		
		var rangeZero = [-1, -1];
		typer.onChange.add(() -> {
			text.text = typer.text;
			
			text.applyMarkup(typer.text, typingRules);
			
			@:privateAccess
			{
				if (text._formatRanges.length > 0) for (i in text._formatRanges)
				{
					if (i.range.end == -1)
					{
						i.range.end = text.text.length;
					}
				}
			}
			
			FlxG.sound.play(Paths.soundRandom('melanieDialogue', 1, 3));
		});
		
		typer.onTypingComplete.add(finishReading);
	}
	
	override function draw()
	{
		bg.cameras = cameras;
		text.cameras = cameras;
		skip.cameras = cameras;
		icon.cameras = cameras;
		infoBg.cameras = cameras;
		
		reminderBg.cameras = cameras;
		reminderText.cameras = cameras;
		
		bg.scrollFactor.copyFrom(scrollFactor);
		text.scrollFactor.copyFrom(scrollFactor);
		skip.scrollFactor.copyFrom(scrollFactor);
		infoBg.scrollFactor.copyFrom(scrollFactor);
		
		reminderBg.scrollFactor.copyFrom(scrollFactor);
		reminderText.scrollFactor.copyFrom(scrollFactor);
		
		bg.x = x;
		bg.y = y;
		
		infoBg.x = x;
		infoBg.y = y - 125;
		
		infoText.x = infoBg.x - (infoBg.scale.x / 2) + (infoBg.scale.x - infoText.width) / 2;
		infoText.y = infoBg.y - (infoBg.scale.y / 2) + (infoBg.scale.y - infoText.height) / 2;
		
		text.x = x - (bg.scale.x / 2) + 30;
		text.y = y - (bg.scale.y / 2) + 30;
		
		skip.x = bg.x + (bg.scale.x / 2) - skip.width - 5;
		skip.y = bg.y + (bg.scale.y / 2) - skip.height - 5;
		
		icon.x = x - (bg.scale.x / 2) - 30;
		icon.y = y - (bg.scale.y / 2) - (icon.height) + 10;
		
		bg.draw();
		infoBg.draw();
		
		reminderBg.scale.set(300, 36);
		
		reminderBg.x = x;
		reminderBg.y = y - 125;
		
		final sin = Math.sin((Math.PI * reminderSin) / 180);
		
		reminderBg.alpha = ((1 - alpha) * 0.6) * sin;
		reminderText.alpha = (1 - alpha) * sin;
		
		reminderText.x = infoBg.x - (reminderBg.scale.x / 2) + (reminderBg.scale.x - reminderText.width) / 2;
		reminderText.y = infoBg.y - (reminderBg.scale.y / 2) + (reminderBg.scale.y - reminderText.height) / 2;
		
		reminderBg.draw();
		reminderText.draw();
		
		text.alpha = alpha;
		skip.alpha = skipAlpha;
		icon.alpha = alpha;
		infoText.alpha = alpha * (infoBg.scale.x > 0 ? 1 : 0);
		
		text.draw();
		skip.draw();
		icon.draw();
		infoText.draw();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		typer.update(elapsed);
		
		if ((FlxG.gamepads.anyJustPressed(X) || FlxG.keys.justPressed.T || MusicBeatState.getState().touchPad != null && MusicBeatState.getState().touchPad.buttonT.justPressed) && isActive && infoBg.scale.x > 0)
		{
			if (typer.state == TYPING)
			{
				typer.skip();
			}
			else
			{
				if (!isEmpty()) advanceDialogue();
				else endDialogue();
			}
		}
		reminderText.update(elapsed);
		
		reminderText.text = 'Press ' + (Controls.instance.controllerMode ? (Controls.isPsController() ? 'SQUARE' : 'X') : 'T') + ' to interact';
		infoText.text = 'Press ' + (Controls.instance.controllerMode ? (Controls.isPsController() ? 'SQUARE' : 'X') : 'T') + ' to interact';
		
		final textScale = Controls.instance.controllerMode && Controls.isPsController() ? 0.7 : 1;
		reminderText.scale.set(textScale, 1);
		infoText.scale.set(textScale, 1);
		
		if (reminderCheck > 0)
		{
			reminderCheck -= elapsed;
		}
		else if (!isActive)
		{
			reminderSin += 180 * elapsed;
		}
	}
	
	override function destroy()
	{
		super.destroy();
		
		bg = FlxDestroyUtil.destroy(bg);
		text = FlxDestroyUtil.destroy(text);
		skip = FlxDestroyUtil.destroy(skip);
		typer = FlxDestroyUtil.destroy(typer);
		icon = FlxDestroyUtil.destroy(icon);
		infoBg = FlxDestroyUtil.destroy(infoBg);
		infoText = FlxDestroyUtil.destroy(infoText);
		
		reminderBg = FlxDestroyUtil.destroy(reminderBg);
		reminderText = FlxDestroyUtil.destroy(reminderText);
		
		// signals
		onStart.destroy();
		onWritingComplete.destroy();
		onAdvance.destroy();
		onClose.destroy();
	}
	
	public function startDialogue(filePath:String, ?options:DialogueOptions)
	{
		loadDialogue(filePath);
		if (isEmpty()) return;
		
		final validOptions:DialogueOptions =
			{
				skippable: options?.skippable ?? true,
				controlLock: options?.controlLock ?? false
			}
			
		lockControls = validOptions.controlLock;
		
		closeTimer?.cancel();
		
		advanceDialogue();
		isActive = true;
		
		if (validOptions.skippable) FlxTween.tween(infoBg, {'scale.x': 300, 'scale.y': 36}, 0.1);
		
		FlxTween.tween(bg, {'scale.x': 500, 'scale.y': 200}, 0.1);
		FlxTween.tween(this, {alpha: 1}, 0.1, {startDelay: 0.1});
		
		onStart.dispatch();
		
		reminderSin = 0;
	}
	
	public function finishReading()
	{
		closeTimer?.cancel();
		if (isEmpty())
		{
			closeTimer.start(1.5, tmr -> {
				endDialogue();
			});
		}
		else
		{
			skipAlpha = 1;
		}
		
		onWritingComplete.dispatch();
		
		reminderCheck = 10;
	}
	
	public function advanceDialogue()
	{
		skipAlpha = 0;
		
		var data = dialogue.shift();
		typer.startTyping(data.text);
		onAdvance.dispatch(data);
	}
	
	public function endDialogue()
	{
		stop();
		onClose.dispatch();
	}
	
	public function stop()
	{
		typer.skip();
		FlxTween.tween(this, {alpha: 0}, 0.1);
		FlxTween.tween(bg, {'scale.x': 0, 'scale.y': 0}, 0.1,
			{
				startDelay: 0.1,
				onComplete: Void -> {
					isActive = false;
					FlxTimer.wait(0.1, () -> lockControls = false);
				}
			});
		FlxTween.tween(infoBg, {'scale.x': 0, 'scale.y': 0}, 0.1,
			{
				startDelay: 0.1
			});
	}
	
	inline function loadDialogue(filePath:String)
	{
		//
		var formatted = Paths.json(filePath);
		
		if (FileSystem.exists(formatted))
		{
			var raw = File.getContent(formatted);
			dialogue = Json.parse(raw);
		}
	}
	
	public function isEmpty()
	{
		return dialogue == null || dialogue.length == 0;
	}
}

private class FlxTextPageTracked extends FlxText
{
	public var page:Int = 0;
	
	public var defY:Float = 0;
}

typedef DialogueStruct =
{
	var text:String;
	var ?anim:String;
}

typedef DialogueOptions =
{
	var ?skippable:Bool;
	var ?controlLock:Bool;
}

class OutlineShader extends FlxGraphicsShader
{
	@:glFragmentSource("
	#pragma header
	//main part
	//https://www.shadertoy.com/view/csc3W8

	vec2 complexRot(vec2 a,vec2 b)
	{
		return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);
	}

	void main()
	{
		vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);

		
		float thick = 3.0;
		float otl = 0.0;
		vec2 dir = vec2(1.0, 0.0);
		vec2 roter = vec2(0.866,0.5);

		for(int i = 0; i < 12; i++)//360/12 degree/times rotation
		{
			dir = complexRot(dir, roter);
			otl = min(otl + flixel_texture2D(bitmap, openfl_TextureCoordv + (dir * thick / openfl_TextureSize)).a / 3.0, 1.0);
		}

		gl_FragColor = mix(vec4(1.0) * otl, tex, tex.a);
	}
	")
	public function new()
	{
		super();
	}
}

private class Hints
{
	// seperated cuz its cleaner ig
	public static final wantedHint:Array<DialogueStruct> = [
		{
			text: "Okay look. We both know you're only talking to me for “secrets”.",
			anim: "talk-serious"
		},
		{
			text: "Unless you're just weird and want to know more about my life like you know me... ",
			anim: "talk-moody"
		},
		{
			text: "...Alright. Listen closely, I won't bother to repeat myself.",
			anim: "talk-serious"
		},
		{
			text: "*There's something in the options menu called “Debug Test”. It's for higher-ups only.*",
			anim: "talk-serious"
		},
		{
			text: "*You'll need codes if you want anything from there.*",
			anim: "talk-serious"
		},
		{
			text: "*Since I work here, I know all of them. But you can't tell anyone else.*",
			anim: "talk-serious"
		},
		{
			text: "Don't get yourself on a *WANTED* list.",
			anim: "talk-moody"
		}
	];
	
	public static final generalHints:Array<Array<DialogueStruct>> = [
		[
			{
				text: "Haven't I seen you here before with that one red haired kid?",
				anim: "talk-serious"
			},
			{
				text: "...*PICO*? Who's that?",
				anim: "talk"
			}
		],
		[
			{
				text: "I'm *CONFIDENT* you don't even understand half the things I'm saying.",
				anim: "talk-serious"
			}
		],
		[
			{
				text: "I had the highscore on *PACKMAN* at the arcade across from here...",
				anim: "talk-sideEye"
			},
			{
				text: "Until some little shit beat me.",
				anim: "talk-moody"
			},
			{
				text: "I'll get it back some day.",
				anim: "talk-sideEye"
			}
		],
		[
			{
				text: "There's something in the air conditioning vents that always makes a constant *CLICKING* sound.",
				anim: "talk-serious"
			},
			{
				text: "Like a pebble or something.",
				anim: "talk-serious"
			},
			{
				text: "It drives me insane.",
				anim: "talk-moody"
			}
		],
		[
			{
				text: "I always *WANTED* to work at a music shop.",
				anim: "talk-sideEye"
			},
			{
				text: "Sucks that the closest place I could find was this one.",
				anim: "talk-moody"
			}
		]
	];
	
	static var _lastIdx:Int = -1;
	
	public static function grabHint()
	{
		if (FlxG.save.data._wantedHintSeen == null)
		{
			FlxG.save.data._wantedHintSeen = true;
			FlxG.save.flush();
			return wantedHint.copy();
		}
		
		final copy = [for (i in generalHints) Reflect.copy(i)];
		
		final idx = FlxG.random.int(0, copy.length - 1, [_lastIdx]);
		
		_lastIdx = idx;
		
		return copy[idx];
	}
}
