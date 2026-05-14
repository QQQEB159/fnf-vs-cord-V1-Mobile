package mods.data.cat;

import flixel.math.FlxAngle;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.group.FlxSpriteContainer;
import flixel.FlxSprite;

import backend.Paths;

var frames = Paths.getSparrowAtlas('stages/weekcord/note');
var previousNote:Int = -1;
var container = new FlxSpriteContainer();
var micCanTurnOn = false;

function onCreate()
{
	//
	
	addBehindDad(container);
}

var noteTimer = 0;
var noteCap = 3;

function onUpdatePost(e)
{
	noteTimer += e;
	
	if (!mustHitSection && micCanTurnOn)
	{
		//
		if (noteTimer > noteCap)
		{
			noteCap = FlxG.random.float(0.7, 1.5);
			noteTimer = 0;
			
			spawnMusicNote();
		}
	}
}

function spawnMusicNote()
{
	var spr = modchartSprites.get('mic');
	
	var musicNote = container.recycle(FlxSprite, () -> new FlxSprite());
	
	musicNote.frames = frames;
	
	musicNote.scale.set(0.825, 0.825);
	musicNote.updateHitbox();
	musicNote.alpha = 1;
	
	musicNote.x = (spr.getMidpoint().x - musicNote.width / 2) + FlxG.random.int(-30, 30) + 50;
	musicNote.y = (spr.getMidpoint().y - musicNote.height / 2) - 100 + FlxG.random.int(-10, 30);
	
	musicNote.animation.frameIndex = FlxG.random.int(0, musicNote.animation.numFrames - 1, [previousNote]);
	previousNote = musicNote.animation.frameIndex;
	
	container.add(musicNote);
	
	var spinLeft = FlxG.random.bool();
	
	musicNote.scale.x = 0;
	musicNote.scale.y = 0;
	musicNote.angle = FlxG.random.int(5, 10);
	musicNote.angularVelocity = 30;
	musicNote.velocity.set(FlxG.random.bool() ? 50 : -50, -50);
	
	if (spinLeft)
	{
		musicNote.angle *= -1;
		musicNote.angularVelocity *= -1;
	}
	
	FlxTween.tween(musicNote, {x: musicNote.x + (FlxG.random.bool() ? -20 : 20)}, 2, {ease: FlxEase.sineInOut, type: 4});
	
	FlxTween.tween(musicNote, {'scale.x': 0.825, 'scale.y': 0.825}, 1.5 + 0.4, {ease: FlxEase.cubeInOut});
	
	FlxTween.tween(musicNote, {alpha: 0}, 1.5,
		{
			startDelay: 0.4,
			onComplete: Void -> {
				FlxTween.cancelTweensOf(musicNote, ['x', 'scale.x', 'scale.y']);
				musicNote.kill();
			}
		});
}

function onBeatHit() 
{
	if (curBeat == 188)
	{
		micCanTurnOn = true;
	}
	
	if (curBeat == 384)
	{
		micCanTurnOn = false;
	}
}
