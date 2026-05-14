package mods.data.curiosity;

import backend.Paths;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;

import states.PlayState;

var shakeCord:Bool = false;
var cordY:Float = 0;
var cordSound:FlxSound = FlxG.sound.load(Paths.sound('cordScaredDialogue'));

function onCreate()
{
	FlxG.sound.list.add(cordSound);
}

function onNextDialogue(idx)
{
	switch (idx)
	{
		case 1:
			cordSound.play();
			cordY = getCord().y;
			
			shakeCord = true;
			FlxTween.completeTweensOf(getBf());
			
			FlxTween.globalManager.update(0);
			
			getBf().playAnim('wtf');
			
			getBf().alpha = 0;
			
			getBf().x += 25;
			
		case 10:
			FlxTween.tween(getBf(), {alpha: 1, x: getBf().startingPos}, 3, {ease: FlxEase.sineInOut});
			
		case 24:
			shakeCord = false;
			getCord().y = cordY;
			getCord().x = getCord().startingPos;
	}
}

function onUpdatePost(e)
{
	if (PlayState.instance.psychDialogue != null && shakeCord)
	{
		getCord().x = getCord().startingPos + FlxG.random.float(-1, 1);
		getCord().angle = FlxG.random.float(-1, 1);
		getCord().y = cordY + FlxG.random.float(-1, 1);
	}
}

var _bf = null;

function getBf()
{
	if (_bf != null) return _bf;
	
	for (i in PlayState.instance.psychDialogue.characters)
	{
		if (i.curCharacter == 'bf')
		{
			_bf = i;
		}
	}
	return _bf;
}

var _cord = null;

function getCord()
{
	if (_cord != null) return _cord;
	
	for (i in PlayState.instance.psychDialogue.characters)
	{
		if (i.curCharacter == 'cord')
		{
			_cord = i;
		}
	}
	
	return _cord;
}
