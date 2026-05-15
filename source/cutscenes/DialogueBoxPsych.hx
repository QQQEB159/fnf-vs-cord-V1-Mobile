package cutscenes;

import haxe.Json;

import openfl.utils.Assets;

import extensions.flixel.FlxUniformSprite;

import objects.FlxTextTyper;

import cutscenes.DialogueCharacter;

import flixel.system.FlxAssets.FlxSoundAsset;

typedef DialogueFile =
{
	var dialogue:Array<DialogueLine>;
}

typedef DialogueLine =
{
	var portrait:Null<String>;
	var expression:Null<String>;
	var text:Null<String>;
	
	var speed:Null<Float>;
	var sound:Null<String>;
	
	var ?boxState:Null<String>;
	
	var ?autoSkip:Bool;
}

// TO DO: Clean code? Maybe? idk //YES THIS IS BAD
class DialogueBoxPsych extends FlxSpriteGroup
{
	public static inline final DEFAULT_TEXT_X = 260;
	public static inline final DEFAULT_TEXT_Y = 470;
	
	public static inline final LEFT_CHAR_X:Float = -60;
	public static inline final RIGHT_CHAR_X:Float = -100;
	public static inline final DEFAULT_CHAR_Y:Float = 60;
	public static inline final TYPE_SOUND_DELAY:Float = 0.03;
	
	static final SCROLLSPEED = 4000;
	
	public var onComplete:Null<Void->Void> = null;
	public var nextDialogueThing:Null<Void->Void> = null;
	public var skipDialogueThing:Null<Void->Void> = null;
	
	var dialogueList:DialogueFile;
	var currentLine:Int = 0;
	
	var textTyper:FlxTextTyper;
	var sndToPlay:FlxSoundAsset;
	var textInstance:FlxText;
	
	var bgFade:FlxSprite;
	var box:FlxSprite;
	
	var characters:Array<DialogueCharacter> = [];
	var curCharacterIdx:Int = -1;
	
	public var closeSound:String = 'dialogueClose';
	public var closeVolume:Float = 1;
	
	var soundBuffer:Float = 0;
	
	public function new(dialogueList:DialogueFile, ?song:String)
	{
		super();
		
		if (song != null && song != '')
		{
			FlxG.sound.playMusic(Paths.music(song), 0);
			FlxG.sound.music.fadeIn(2, 0, 1);
		}
		
		this.dialogueList = dialogueList;
		
		textTyper = new FlxTextTyper();
		
		bgFade = new FlxUniformSprite().makeScaledGraphic(FlxG.width, FlxG.height);
		bgFade.visible = true;
		bgFade.alpha = 0;
		add(bgFade);
		
		spawnCharacters();
		
		box = new FlxSprite(70, 370).setFrames(Paths.getSparrowAtlas('speech_bubble'));
		box.antialiasing = ClientPrefs.data.antialiasing;
		box.scrollFactor.set();
		box.animation.addByPrefix('idle', 'speech bubble normal0', 24);
		box.animation.addByPrefix('open', 'Speech Bubble Normal Open', 24, false);
		box.animation.play('idle', true);
		box.updateHitbox();
		box.screenCenter(X);
		add(box);
		
		textInstance = new FlxText(DEFAULT_TEXT_X, DEFAULT_TEXT_Y, FlxG.width * 0.6 - 10, '', 24);
		add(textInstance);
		textInstance.font = Paths.font('PixelOperator8.ttf');
		
		textTyper.onChange.add(() -> {
			textInstance.text = textTyper.text;
			
			if (soundBuffer > TYPE_SOUND_DELAY)
			{
				FlxG.sound.play(sndToPlay);
				soundBuffer = 0;
			}
		});
		
		textTyper.onTypingComplete.add(() -> textInstance.text = textTyper.finalText);
		
		initiateDialog();
	}
	
	function initiateDialog()
	{
		box.y = FlxG.height;
		
		FlxTween.tween(box, {y: 370}, 1, {ease: FlxEase.sineOut});
		box.animation.play('open');
		
		for (char in characters)
		{
			final prevScale = char.scale.x;
			
			char.scale.set();
			char.origin.y = char.frameHeight;
			FlxTween.tween(char,
				{
					'alpha': 1,
					'scale.x': prevScale,
					'scale.y': prevScale,
				}, 0.35, {ease: FlxEase.sineOut, startDelay: 1});
				
			char.playAnim('talk', true);
		}
		
		FlxTimer.wait(1, () -> {
			startNextDialog();
		});
	}
	
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;
	
	function spawnCharacters()
	{
		var curAdded:Array<String> = [];
		for (i in 0...dialogueList.dialogue.length)
		{
			final portrait = dialogueList.dialogue[i]?.portrait;
			if (portrait == null || curAdded.contains(portrait)) continue;
			
			curAdded.push(portrait);
			
			var x:Float = LEFT_CHAR_X;
			var y:Float = DEFAULT_CHAR_Y;
			var char:DialogueCharacter = new DialogueCharacter(x, y, portrait);
			char.scale.scale(DialogueCharacter.DEFAULT_SCALE * char.jsonFile.scale);
			char.updateHitbox();
			char.scrollFactor.set();
			char.alpha = 0.00001;
			add(char);
			
			switch (char.jsonFile.dialogue_pos)
			{
				default:
				case RIGHT:
					x = FlxG.width - char.width + RIGHT_CHAR_X;
					char.x = x;
			}
			x += char.jsonFile.position[0];
			y += char.jsonFile.position[1];
			char.x += char.jsonFile.position[0];
			char.y += char.jsonFile.position[1];
			char.startingPos = x;
			characters.push(char);
		}
	}
	
	var ignoreThisFrame:Bool = true; // First frame is reserved for loading dialogue images
	
	override function update(elapsed:Float)
	{
		if (ignoreThisFrame)
		{
			ignoreThisFrame = false;
			super.update(elapsed);
			return;
		}
		
		soundBuffer += elapsed;
		
		textTyper?.update(elapsed);
		
		if (!dialogueEnded)
		{
			bgFade.alpha = FlxMath.bound(bgFade.alpha + (0.5 * elapsed), null, 0.5);
			
			if ((Controls.instance.ACCEPT || TouchUtil.justPressed) && dialogueStarted)
			{
				if (textTyper.state != FINISHED)
				{
					textTyper.typingCompleted();
					if (skipDialogueThing != null) skipDialogueThing();
				}
				else if (currentLine >= dialogueList.dialogue.length)
				{
					dialogueEnded = true;
					
					disposeEverything();
					
					FlxG.sound.music.fadeOut(1, 0);
				}
				else
				{
					startNextDialog();
				}
				FlxG.sound.play(Paths.sound(closeSound), closeVolume);
			}
			else if (textTyper.state == FINISHED)
			{
				var char:DialogueCharacter = characters[curCharacterIdx];
				if (char != null && char.animation.curAnim != null && char.animationIsLoop() && char.animation.finished)
				{
					char.playAnim(char.animation.curAnim.name, true);
				}
				
				if (dialogueList.dialogue[currentLine - 1] != null
					&& dialogueList.dialogue[currentLine - 1].autoSkip == true) startNextDialog();
			}
			else
			{
				var char:DialogueCharacter = characters[curCharacterIdx];
				if (char != null && char.animation.curAnim != null && char.animation.finished)
				{
					char.animation.curAnim.restart();
				}
			}
		}
		
		super.update(elapsed);
	}
	
	function startNextDialog():Void
	{
		var curDialogue:Null<DialogueLine> = dialogueList.dialogue[currentLine];
		if (curDialogue == null) return;
		
		verifyDialogue(curDialogue);
		
		for (i in 0...characters.length)
		{
			if (characters[i].curCharacter == curDialogue.portrait)
			{
				curCharacterIdx = i;
				
				break;
			}
		}
		
		textTyper.delay = CONST(curDialogue.speed);
		
		sndToPlay = Paths.sound(curDialogue.sound);
		
		textTyper.startTyping(curDialogue.text);
		
		var char:DialogueCharacter = characters[curCharacterIdx];
		if (char != null)
		{
			char.bounce();
			char.playAnim(curDialogue.expression, textTyper.state == FINISHED);
			if (char.animation.curAnim != null)
			{
				char.animation.curAnim.frameRate = FlxMath.bound(24 - (((curDialogue.speed - 0.05) / 5) * 480), 12, 48);
			}
		}
		
		currentLine++;
		
		if (nextDialogueThing != null) nextDialogueThing();
		
		dialogueStarted = true;
		
		box.animation.play('idle');
	}
	
	function disposeEverything()
	{
		textInstance.visible = false;
		for (char in characters)
		{
			FlxTween.tween(char,
				{
					'alpha': 0,
					'scale.x': 0,
					'scale.y': 0,
				}, 0.35, {ease: FlxEase.sineIn});
		}
		
		box.animation.play('open', true, true);
		
		FlxTween.tween(box, {y: FlxG.height}, 1, {ease: FlxEase.sineIn, startDelay: 0.35});
		
		FlxTween.tween(bgFade, {alpha: 0}, 1, {startDelay: 0.35});
		
		FlxTimer.wait(1.4, () -> {
			if (onComplete != null) onComplete();
		});
	}
	
	public static function parseDialogue(path:String):DialogueFile
	{
		#if MODS_ALLOWED
		if (FileSystem.exists(path))
		{
			return cast Json.parse(File.getContent(path));
		}
		#end
		return cast Json.parse(Assets.getText(path));
	}
	
	override function destroy()
	{
		textTyper.destroy();
		super.destroy();
	}
	
	function verifyDialogue(dialogue:DialogueLine)
	{
		if (dialogue.text == null || dialogue.text.length < 1) dialogue.text = ' ';
		if (dialogue.boxState == null) dialogue.boxState = 'normal';
		if (dialogue.speed == null || Math.isNaN(dialogue.speed)) dialogue.speed = 0.05;
		if (dialogue.sound == null || dialogue.sound.trim().length == 0) dialogue.sound = 'dialogue';
	}
}
