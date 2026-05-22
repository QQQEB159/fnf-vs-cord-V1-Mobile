package states;

import flixel.math.FlxRect;
import flixel.graphics.tile.FlxGraphicsShader;

import options.OptionsText;

import flixel.FlxObject;
import flixel.util.FlxSort;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

import objects.Bar;

#if ACHIEVEMENTS_ALLOWED
class AchievementsMenuState extends MusicBeatState
{
	var MAX_PER_ROW:Int = 4;
	
	public var curSelected:Int = 0;
	
	public var options:Array<Dynamic> = [];
	
	var colours:Array<Array<FlxColor>> = [];
	
	public var grpOptions:FlxSpriteGroup;
	
	var descBox:FlxSprite;
	
	public var nameText:FlxText;
	public var descText:FlxText;
	public var progressTxt:FlxText;
	public var progressBar:Bar;
	
	public var hoverIcon:FlxSprite;
	
	public var menuBG:FlxSprite;
	
	var camFollow:FlxObject;
	
	var bgShader:GradientShader;
	
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Achievements Menu", null);
		#end
		
		// prepare achievement list
		for (achievement => data in Achievements.achievements)
		{
			var unlocked:Bool = Achievements.isUnlocked(achievement);
			if (data.hidden != true || unlocked) options.push(makeAchievement(achievement, data, unlocked, data.mod));
		}
		
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		
		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.antialiasing = ClientPrefs.data.antialiasing;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.2));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.scrollFactor.set();
		add(menuBG);
		// menuBG.color = FlxColor.WHITE;
		
		var backdrop = new FlxBackdrop(FlxGridOverlay.create(75, 75, 150, 150, true, FlxColor.BLACK, 0x0).graphic);
		backdrop.velocity.set(20, -20);
		add(backdrop);
		backdrop.alpha = 0.15;
		backdrop.scrollFactor.x = 0;
		
		bgShader = new GradientShader();
		bgShader.topColour = 0xFF545563;
		bgShader.bottomColour = 0xFF2E2E39;
		menuBG.shader = bgShader;
		
		grpOptions = new FlxSpriteGroup();
		grpOptions.scrollFactor.x = 0;
		
		options.sort(sortByID);
		for (option in options)
		{
			var hasAntialias:Bool = ClientPrefs.data.antialiasing;
			var graphic = null;
			if (option.unlocked)
			{
				#if MODS_ALLOWED Mods.currentModDirectory = option.mod; #end
				var image:String = 'achievements/' + option.name;
				if (Paths.fileExists('images/$image-pixel.png', IMAGE))
				{
					graphic = Paths.image('$image-pixel');
					hasAntialias = false;
				}
				else graphic = Paths.image(image);
				
				if (graphic == null) graphic = Paths.image('unknownMod');
			}
			else graphic = Paths.image('achievements/locked');
			
			var spr:FlxSprite = new FlxSprite(0, Math.floor(grpOptions.members.length / MAX_PER_ROW) * 180).loadGraphic(graphic);
			spr.scrollFactor.x = 0;
			spr.screenCenter(X);
			spr.x += 180 * ((grpOptions.members.length % MAX_PER_ROW) - MAX_PER_ROW / 2) + spr.width / 2 + 15;
			spr.ID = grpOptions.members.length;
			spr.antialiasing = hasAntialias;
			grpOptions.add(spr);
			
			colours.push(option.colour);
		}
		#if MODS_ALLOWED Mods.loadTopMod(); #end
		
		var box:FlxSprite = new FlxSprite(0, -30).makeGraphic(1, 1, FlxColor.BLACK);
		box.scale.set(grpOptions.width + 60, grpOptions.height + 60);
		box.updateHitbox();
		box.alpha = 0.8;
		box.scrollFactor.x = 0;
		box.screenCenter(X);
		add(box);
		
		add(grpOptions);
		
		descBox = new ClipSprite(0, 570).makeGraphic(1, 1, FlxColor.BLACK);
		descBox.scale.set(150 * 2, 150);
		descBox.updateHitbox();
		descBox.alpha = 0.8;
		descBox.scrollFactor.set(0, 1);
		add(descBox);
		
		hoverIcon = new FlxSprite(Paths.image('menuassets/achievements/selectBox'));
		hoverIcon.scrollFactor.x = 0;
		add(hoverIcon);
		
		hoverIcon.x = grpOptions.members[0].x + (grpOptions.members[0].width - hoverIcon.width) / 2;
		hoverIcon.y = grpOptions.members[0].y + (grpOptions.members[0].height - hoverIcon.height) / 2;
		
		nameText = new ClipText(50, descBox.y + 10, descBox.width, "", 14);
		nameText.setFormat(Paths.font("VGA.ttf"), 14, FlxColor.WHITE, CENTER);
		nameText.scrollFactor.set(0, 1);
		nameText.antialiasing = true;
		
		descText = new ClipText(50, nameText.y + 38, descBox.width - 10, "", 14);
		descText.setFormat(Paths.font("VGA.ttf"), 14, FlxColor.WHITE, CENTER);
		descText.scrollFactor.set(0, 1);
		descText.antialiasing = true;
		
		progressBar = new Bar(0, descText.y + 52);
		progressBar.screenCenter(X);
		progressBar.scrollFactor.set();
		progressBar.enabled = false;
		
		progressTxt = new OptionsText(50, progressBar.y - 6, FlxG.width - 100, "", 32);
		progressTxt.setFormat(Paths.font("VGA.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		progressTxt.scrollFactor.set();
		progressTxt.borderSize = 2;
		
		add(progressBar);
		add(progressTxt);
		add(descText);
		add(nameText);
		
		_changeSelection();
		super.create();
		
		FlxG.camera.zoom = 0.9;
		
		FlxG.camera.follow(camFollow, null, 0.03);
		FlxG.camera.scroll.y = -FlxG.height;
		
		addTouchPad("LEFT_FULL", "B_C");
		addTouchPadCamera();
	}
	
	override function closeSubState()
	{
		MusicBeatState.getState().touchPad.visible = persistentUpdate = true;
		
		super.closeSubState();
	}
	
	function makeAchievement(achievement:String, data:Achievement, unlocked:Bool, mod:String = null)
	{
		var unlocked:Bool = Achievements.isUnlocked(achievement);
		return {
			name: achievement,
			displayName: unlocked ? data.name : '???',
			description: data.description,
			curProgress: data.maxScore > 0 ? Achievements.getScore(achievement) : 0,
			maxProgress: data.maxScore > 0 ? data.maxScore : 0,
			decProgress: data.maxScore > 0 ? data.maxDecimals : 0,
			unlocked: unlocked,
			ID: data.ID,
			mod: mod,
			colour: [!unlocked ? 0xFF545563 : data.gradColour1 ?? 0xFF545563, !unlocked ? 0xFF2E2E39 : data.gradColour2 ?? 0xFF2E2E39]
		};
	}
	
	public static function sortByID(Obj1:Dynamic, Obj2:Dynamic):Int return FlxSort.byValues(FlxSort.ASCENDING, Obj1.ID, Obj2.ID);
	
	var goingBack:Bool = false;
	
	override function update(elapsed:Float)
	{
		if (!goingBack && options.length > 1)
		{
			var add:Int = 0;
			if (controls.UI_LEFT_P) add = -1;
			else if (controls.UI_RIGHT_P) add = 1;
			
			if (add != 0)
			{
				var oldRow:Int = Math.floor(curSelected / MAX_PER_ROW);
				var rowSize:Int = Std.int(Math.min(MAX_PER_ROW, options.length - oldRow * MAX_PER_ROW));
				
				curSelected += add;
				var curRow:Int = Math.floor(curSelected / MAX_PER_ROW);
				if (curSelected >= options.length) curRow++;
				
				if (curRow != oldRow)
				{
					if (curRow < oldRow) curSelected += rowSize;
					else curSelected = curSelected -= rowSize;
				}
				_changeSelection();
			}
			
			if (options.length > MAX_PER_ROW)
			{
				var add:Int = 0;
				if (controls.UI_UP_P) add = -1;
				else if (controls.UI_DOWN_P) add = 1;
				
				if (add != 0)
				{
					var diff:Int = curSelected - (Math.floor(curSelected / MAX_PER_ROW) * MAX_PER_ROW);
					curSelected += add * MAX_PER_ROW;
					// trace('Before correction: $curSelected');
					if (curSelected < 0)
					{
						curSelected += Math.ceil(options.length / MAX_PER_ROW) * MAX_PER_ROW;
						if (curSelected >= options.length) curSelected -= MAX_PER_ROW;
						// trace('Pass 1: $curSelected');
					}
					if (curSelected >= options.length)
					{
						curSelected = diff;
						// trace('Pass 2: $curSelected');
					}
					
					_changeSelection();
				}
			}
			
			if ((controls.RESET || touchPad != null && touchPad.buttonC.justPressed) && (options[curSelected].unlocked || options[curSelected].curProgress > 0))
			{
				openSubState(new ResetAchievementSubstate());
				MusicBeatState.getState().touchPad.visible = persistentUpdate = false;
			}
		}
		
		var x = 0.0;
		var y = 0.0;
		
		grpOptions.forEach(spr -> {
			if (x == 0 && y == 0 && spr.ID == curSelected)
			{
				final point = spr.getGraphicMidpoint();
				x = point.x;
				y = point.y;
			}
		});
		
		final lerpRate = FlxMath.getElapsedLerp(0.2, elapsed);
		
		hoverIcon.x = FlxMath.lerp(hoverIcon.x, x - (hoverIcon.width / 2), lerpRate);
		hoverIcon.y = FlxMath.lerp(hoverIcon.y, y - (hoverIcon.height / 2), lerpRate);
		
		bgShader.topColour = FlxColor.interpolate(bgShader.topColour, colours[curSelected][0], lerpRate / 2);
		bgShader.bottomColour = FlxColor.interpolate(bgShader.bottomColour, colours[curSelected][1], lerpRate / 2);
		
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(() -> new MainMenuState());
			goingBack = true;
		}
		super.update(elapsed);
		updateBoxState();
	}
	
	var lastBoxIdx:Int = -1;
	
	var boxTwn:Null<FlxTween> = null;
	
	function updateBoxState()
	{
		//
		
		nameText.updateHitbox();
		descText.updateHitbox();
		
		if (boxTwn == null)
		{
			if (lastBoxIdx != curSelected)
			{
				lastBoxIdx = curSelected;
				descBox.clipRect ??= new FlxRect(0, 0, descBox.frameWidth, descBox.frameHeight);
				nameText.clipRect ??= new FlxRect(0, 0, nameText.frameWidth, nameText.frameHeight - 2);
				descText.clipRect ??= new FlxRect(0, 0, descText.frameWidth, descText.frameHeight - 1);
				
				inline function updateClipSetter()
				{
					descBox.clipRect = descBox.clipRect;
					
					nameText.clipRect.width = nameText.frameWidth * descBox.clipRect.width;
					descText.clipRect.width = descText.frameWidth * descBox.clipRect.width;
					nameText.clipRect.height = nameText.frameHeight - 2;
					descText.clipRect.height = descText.frameHeight - 1;
					
					nameText.clipRect = nameText.clipRect;
					descText.clipRect = descText.clipRect;
				}
				
				boxTwn = FlxTween.tween(descBox, {'clipRect.width': 0}, 0.1,
					{
						onUpdate: Void -> updateClipSetter(),
						onComplete: Void -> {
							FlxTimer.wait(0, () -> {
								descBox.x = grpOptions.members[curSelected].x + grpOptions.members[curSelected].width;
								descBox.y = grpOptions.members[curSelected].y;
								
								nameText.text = options[curSelected].displayName;
								descText.text = options[curSelected].description;
								
								nameText.x = descBox.x;
								nameText.y = descBox.y + 20;
								
								descText.x = descBox.x + 5;
								descText.y = nameText.y + nameText.height + 10;
								
								var colourToUse = colours[curSelected][0];
								if (colours[curSelected][1].brightness > colourToUse.brightness) colourToUse = colours[curSelected][1];
								
								colourToUse.brightness *= 1.1;
								
								nameText.color = colourToUse;
								
								updateClipSetter();
								
								boxTwn = FlxTween.tween(descBox, {'clipRect.width': descBox.frameWidth}, 0.1,
									{
										onUpdate: Void -> updateClipSetter(),
										onComplete: Void -> {
											updateClipSetter();
											boxTwn = null;
										}
									});
							});
						}
					});
			}
		}
	}
	
	public var barTween:FlxTween = null;
	
	function _changeSelection()
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		var hasProgress = options[curSelected].maxProgress > 0;
		// nameText.text = options[curSelected].displayName;
		// descText.text = options[curSelected].description;
		progressTxt.visible = progressBar.visible = hasProgress;
		
		// descText.x = grpOptions.members[curSelected].x + grpOptions.members[curSelected].width;
		// descText.y = grpOptions.members[curSelected].y;
		
		if (barTween != null) barTween.cancel();
		
		if (hasProgress)
		{
			var val1:Float = options[curSelected].curProgress;
			var val2:Float = options[curSelected].maxProgress;
			progressTxt.text = CoolUtil.floorDecimal(val1, options[curSelected].decProgress)
				+ ' / '
				+ CoolUtil.floorDecimal(val2, options[curSelected].decProgress);
				
			barTween = FlxTween.tween(progressBar, {percent: (val1 / val2) * 100}, 0.5,
				{
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween) progressBar.updateBar(),
					onUpdate: function(twn:FlxTween) progressBar.updateBar()
				});
		}
		else progressBar.percent = 0;
		
		var maxRows = Math.floor(grpOptions.members.length / MAX_PER_ROW);
		if (maxRows > 0)
		{
			var camY:Float = FlxG.height / 2 + (Math.floor(curSelected / MAX_PER_ROW) / maxRows) * Math.max(0, grpOptions.height - FlxG.height / 2 - 50) - 100;
			camFollow.setPosition(0, camY);
		}
		else camFollow.setPosition(0, grpOptions.members[curSelected].getGraphicMidpoint().y - 100);
		
		// camFollow.setPosition(grpOptions.members[curSelected].getGraphicMidpoint().x, grpOptions.members[curSelected].getGraphicMidpoint().y);
		
		grpOptions.forEach(function(spr:FlxSprite) {
			// spr.alpha = 0.6;
			if (spr.ID == curSelected)
			{
				// spr.alpha = 1;
				// hoverIcon.x = spr.getGraphicMidpoint().x - (hoverIcon.width / 2);
				// hoverIcon.y = spr.y + (spr.height - hoverIcon.height) / 2;
			}
		});
	}
}

class ResetAchievementSubstate extends MusicBeatSubstate
{
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;
	
	public function new()
	{
		super();
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		
		var text:Alphabet = new Alphabet(0, 180, "Reset Achievement:", true);
		text.screenCenter(X);
		text.scrollFactor.set();
		add(text);
		
		var state:AchievementsMenuState = cast FlxG.state;
		var text:FlxText = new FlxText(50, text.y + 90, FlxG.width - 100, state.options[state.curSelected].displayName, 40);
		text.setFormat(Paths.font("VGA.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.scrollFactor.set();
		text.borderSize = 2;
		add(text);
		
		yesText = new Alphabet(0, text.y + 120, 'Yes', true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		yesText.scrollFactor.set();
		for (letter in yesText.letters)
			letter.color = FlxColor.RED;
		add(yesText);
		noText = new Alphabet(0, text.y + 120, 'No', true);
		noText.screenCenter(X);
		noText.x += 200;
		noText.scrollFactor.set();
		add(noText);
		updateOptions();
		
		addTouchPad("LEFT_RIGHT", "A");
		addTouchPadCamera();
	}
	
	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			FlxTimer.wait(0.1, ()->{
			    close();
			});
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}
		
		super.update(elapsed);
		
		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
			onYes = !onYes;
			updateOptions();
		}
		
		if (controls.ACCEPT)
		{
			if (onYes)
			{
				var state:AchievementsMenuState = cast FlxG.state;
				var option:Dynamic = state.options[state.curSelected];
				
				Achievements.variables.remove(option.name);
				Achievements.achievementsUnlocked.remove(option.name);
				option.unlocked = false;
				option.curProgress = 0;
				option.name = state.nameText.text = '???';
				if (option.maxProgress > 0) state.progressTxt.text = '0 / ' + option.maxProgress;
				state.grpOptions.members[state.curSelected].loadGraphic(Paths.image('achievements/locked'));
				state.grpOptions.members[state.curSelected].antialiasing = ClientPrefs.data.antialiasing;
				
				if (state.progressBar.visible)
				{
					if (state.barTween != null) state.barTween.cancel();
					state.barTween = FlxTween.tween(state.progressBar, {percent: 0}, 0.5,
						{
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween) state.progressBar.updateBar(),
							onUpdate: function(twn:FlxTween) state.progressBar.updateBar()
						});
				}
				Achievements.save();
				FlxG.save.flush();
				
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
			FlxTimer.wait(0.1, ()->{
			    close();
			});
			return;
		}
	}
	
	function updateOptions()
	{
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;
		
		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}

private class GradientShader extends FlxGraphicsShader
{
	public var topColour(default, set):FlxColor = FlxColor.WHITE;
	
	function set_topColour(v:FlxColor):FlxColor
	{
		u_top.value = [v.redFloat, v.greenFloat, v.blueFloat];
		
		return topColour = v;
	}
	
	public var bottomColour(default, set):FlxColor = FlxColor.BLACK;
	
	function set_bottomColour(v:FlxColor):FlxColor
	{
		u_bottom.value = [v.redFloat, v.greenFloat, v.blueFloat];
		
		return bottomColour = v;
	}
	
	@:glFragmentSource('
		#pragma header

		uniform vec3 u_top;
		uniform vec3 u_bottom;

		void main()
		{

			vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);

    		vec3 color = mix(u_top,u_bottom, openfl_TextureCoordv.y);

			tex.rgb *= color;

			gl_FragColor = tex;

		}
		
		')
	public function new()
	{
		super();
		
		topColour = FlxColor.WHITE;
		
		bottomColour = FlxColor.BLACK;
	}
}

private class ClipSprite extends FlxSprite
{
	override function set_clipRect(rect:FlxRect):FlxRect
	{
		clipRect = rect;
		
		if (frames != null) frame = frames.frames[animation.frameIndex];
		
		return rect;
	}
}

private class ClipText extends OptionsText
{
	override function set_clipRect(rect:FlxRect):FlxRect
	{
		clipRect = rect;
		
		if (frames != null) frame = frames.frames[animation.frameIndex];
		
		return rect;
	}
}
#end
