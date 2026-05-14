import objects.HealthIcon;

import backend.CoolUtil;

var roseIcon:HealthIcon;
var iconXSpacer = 0;
var roseCanBop:Bool = true;
var roseYOffset:Float = 0;

function onCreatePost()
{
	roseIcon = new HealthIcon(gf.healthIcon, false);
	uiGroup.insert(uiGroup.members.indexOf(iconP1), roseIcon);
	roseIcon.visible = !ClientPrefs.data.hideHud;
	roseIcon.alpha = ClientPrefs.data.healthBarAlpha;
	roseIcon.y = iconP1.y - 75;
	roseIcon.updateHitbox();
	
	roseYOffset = ClientPrefs.data.downScroll ? -200 : 400;
	
	updateIconsPosition = (elapsed, snapped) -> {
		var iconOffset:Int = 26;
		
		var position = healthBar.barCenter - (150 / 2);
		
		var rate = HealthIcon.DEFAULT_LERP_RATE * playbackRate;
		
		if (!snapped)
		{
			roseIcon.x = CoolUtil.decayLerp(roseIcon.x, position, rate, elapsed);
			
			iconP1.x = CoolUtil.decayLerp(iconP1.x, healthBar.barCenter - iconOffset + iconXSpacer, rate, elapsed);
			iconP2.x = CoolUtil.decayLerp(iconP2.x, healthBar.barCenter - (190) / 2 - iconOffset - iconXSpacer, rate, elapsed);
		}
		else
		{
			roseIcon.x = position;
			
			iconP1.x = healthBar.barCenter - iconOffset + iconXSpacer;
			iconP2.x = healthBar.barCenter - (190) / 2 - iconOffset - iconXSpacer;
		}
		
		iconP1.y = healthBar.y - 75;
		iconP2.y = healthBar.y - 75;
		// roseIcon.y = iconP1.y + roseYOffset;
		roseIcon.y = CoolUtil.decayLerp(roseIcon.y, iconP1.y + roseYOffset, rate / 1.5, elapsed);
	}
	
	var oldScaleFunc = updateIconsScale;
	
	updateIconsScale = (elapsed) -> {
		oldScaleFunc(elapsed);
		
		final rate = HealthIcon.DEFAULT_LERP_RATE * playbackRate;
		
		var mult:Float = CoolUtil.decayLerp(roseIcon.scale.x, 0.9, rate, elapsed);
		roseIcon.scale.set(mult, mult);
		roseIcon.updateHitbox();
	}
}

function onBeatHit()
{
	roseIcon.scale.set(1, 1);
	
	roseIcon.updateHitbox();
	if (roseCanBop && curBeat % 2 == 0)
	{
		roseIcon.y += 10;
		roseIcon.flipX = !roseIcon.flipX;
	}
}

function onStepHit()
{
	if (curStep == 528)
	{
		showRoseIcon();
		//
	}
	else if (curStep == 780)
	{
		hideRoseIcon();
	}
}

function showRoseIcon()
{
	FlxTween.num(roseYOffset, -60, (Conductor.stepCrochet * 2) / 1000, {}, (f) -> roseYOffset = f);
	FlxTween.num(iconXSpacer, 30, (Conductor.stepCrochet * 2) / 1000, {}, (f) -> iconXSpacer = f);
}

function hideRoseIcon()
{
	FlxTween.num(roseYOffset, ClientPrefs.data.downScroll ? -200 : 400, (Conductor.stepCrochet * 4) / 1000, {}, (f) -> roseYOffset = f);
	FlxTween.num(iconXSpacer, 0, (Conductor.stepCrochet * 4) / 1000, {}, (f) -> iconXSpacer = f);
}
