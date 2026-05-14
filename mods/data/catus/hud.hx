import backend.ClientPrefs;

import psychlua.FunkinLua;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import backend.Conductor;

import objects.HealthIcon;

import backend.CoolUtil;

var cordIcon:HealthIcon;
var catIcon:HealthIcon;
var cordIconCanFunction:Bool = true;
var catX = -FlxG.width;
var catCanFunction:Bool = true;

function onCreatePost()
{
	Paths.image('icons/cordscared');
	
	iconP2.visible = false;
	
	catIcon = new HealthIcon('icon-cat', false);
	catIcon.visible = !ClientPrefs.data.hideHud;
	catIcon.alpha = ClientPrefs.data.healthBarAlpha;
	
	uiGroup.insert(uiGroup.members.indexOf(iconP2), catIcon);
	
	cordIcon = new HealthIcon(dad.healthIcon, false);
	uiGroup.insert(uiGroup.members.indexOf(catIcon) + 1, cordIcon);
	cordIcon.visible = !ClientPrefs.data.hideHud;
	cordIcon.alpha = ClientPrefs.data.healthBarAlpha;
	cordIcon.y = iconP1.y - 75;
	cordIcon.updateHitbox();
	
	updateIconsPosition = (elapsed, snapped) -> {
		var iconOffset:Int = 26;
		
		var rate = HealthIcon.DEFAULT_LERP_RATE * playbackRate;
		
		var nextCordX = snapped ? healthBar.barCenter - (190) / 2 - iconOffset : CoolUtil.decayLerp(iconP2.x, healthBar.barCenter - (190) / 2 - iconOffset, rate, elapsed);
		
		if (!snapped)
		{
			iconP1.x = CoolUtil.decayLerp(iconP1.x, healthBar.barCenter - iconOffset, rate, elapsed);
			iconP2.x = nextCordX;
		}
		else
		{
			iconP1.x = healthBar.barCenter - iconOffset;
			iconP2.x = nextCordX;
		}
		
		iconP1.y = healthBar.y - 75;
		
		if (cordIconCanFunction)
		{
			cordIcon.y = iconP1.y;
			cordIcon.x = nextCordX;
		}
		
		catIcon.x = nextCordX + catX;
		
		catIcon.y = iconP1.y;
	}
	
	updateIconsPosition(0, true);
	
	var oldScaleFunc = updateIconsScale;
	
	updateIconsScale = (elapsed) -> {
		oldScaleFunc(elapsed);
		
		final rate = HealthIcon.DEFAULT_LERP_RATE * playbackRate;
		
		var mult:Float = CoolUtil.decayLerp(cordIcon.scale.x, 0.9, rate, elapsed);
		cordIcon.scale.set(mult, mult);
		cordIcon.updateHitbox();
		
		var mult:Float = CoolUtil.decayLerp(catIcon.scale.x, 0.9, rate, elapsed);
		catIcon.scale.set(mult, mult);
		catIcon.updateHitbox();
	}
	
	// game.health = 2;
	// game.currentHealth = 2;
}

function onUpdatePost(e)
{
	if (cordIconCanFunction) cordIcon.animation.curAnim.curFrame = (healthBar.percent > 70) ? 1 : 0; // If health is over 80%, change opponent icon to frame 1 (losing icon), otherwise, frame 0 (normal)
	
	if (catCanFunction) catIcon.animation.curAnim.curFrame = (healthBar.percent > 70) ? 1 : 0; // If health is over 80%, change opponent icon to frame 1 (losing icon), otherwise, frame 0 (normal)
	
	return FunkinLua.Function_Continue;
}

function onBeatHit()
{
	if (cordIconCanFunction)
	{
		cordIcon.scale.set(1, 1);
		cordIcon.updateHitbox();
	}
	
	if (catCanFunction)
	{
		catIcon.scale.set(1, 1);
		catIcon.updateHitbox();
	}
}

function onStepHit()
{
	if (curStep == 638)
	{
		killCordIcon();
		// showRoseIcon();
		//
	}
	else if (curStep == 780)
	{
		// hideRoseIcon();
	}
}

function killCordIcon()
{
	//
	
	cordIconCanFunction = false;
	catCanFunction = false;
	
	catIcon.animation.curAnim.curFrame = 0;
	
	if (health > 1)
	{
		FlxTween.num(health, 1, Conductor.stepCrochet * 4 / 1000, {ease: FlxEase.cubeOut, startDelay: Conductor.stepCrochet * 2.5 / 1000}, (f) -> health = currentHealth = f);
	}
	
	FlxTween.num(catX, 0, Conductor.stepCrochet * 6 / 1000, {ease: FlxEase.cubeOut}, (f) -> catX = f);
	
	FlxTimer.wait(Conductor.stepCrochet * 4 / 1000, () -> {
		catCanFunction = true;
		cordIcon.loadGraphic(Paths.image('icons/cordscared'));
		
		cordIcon.velocity.y = -300;
		cordIcon.acceleration.y = 750;
		cordIcon.angularVelocity = -40;
	});
}

function hideRoseIcon() {}
