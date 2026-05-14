import flixel.addons.transition.FlxTransitionableState;

import backend.CoolUtil;
import backend.Mods;

import flixel.tweens.FlxTween;

import backend.Controls;
import backend.Achievements;
import backend.Achievements.Achievement;
import backend.Stats;

import states.PlayState;

import flixel.FlxG;
import flixel.FlxSprite;

import psychlua.FunkinLua;

import backend.WebFishingTransition;
import backend.WebFishingTransition.CircleShader;

import psychlua.CustomSubstate;

import states.FreeplayMenuCord;
import states.StoryMenuState;

var canInteract:Bool = false;

function onGameOver()
{
	CustomSubstate.openCustomSubstate('webGameover', true);
	
	return FunkinLua.Function_Stop;
}

function onCustomSubstateCreate(name)
{
	if (name == 'webGameover')
	{
		FlxG.animationTimeScale = 1;
		PlayState.deathCounter += 1;
		Stats.instance.totalDeaths += 1;
		
		if (Stats.instance.totalDeaths >= 10)
		{
			Achievements.unlock('blueBalled10');
		}
		
		PlayState.instance.inst.stop();
		PlayState.instance.vocals.stop();
		PlayState.instance.isDead = true;
		
		blue = new FlxSprite().makeGraphic(FlxG.width, FlxG.width, 0xFF101C31);
		CustomSubstate.instance.add(blue);
		blue.shader = shader = new CircleShader();
		blue.screenCenter();
		
		blue.scrollFactor.set();
		
		blueAlpha = new FlxSprite().makeGraphic(FlxG.width, FlxG.width, 0x80101C31);
		CustomSubstate.instance.add(blueAlpha);
		blueAlpha.alpha = 0;
		blueAlpha.screenCenter();
		blueAlpha.scrollFactor.set();
		FlxTween.tween(blueAlpha, {alpha:1}, 0.01);
		
		popUp = new FlxSprite(0, 0, Paths.image('stages/webfishing/ui/kicked'));
		popUp.screenCenter();
		CustomSubstate.instance.add(popUp);
		
		shader.radius = 0.75;
		
		FlxG.sound.play(Paths.sound('webfishExit'));
		
		FlxTween.tween(shader, {radius: 0}, 0.7,
			{
				onComplete: Void -> {
					canInteract = true;
					
					retry = new FlxSprite(0, 0, Paths.image('stages/webfishing/ui/retry'));
					retry.screenCenter(FlxAxes.X);
					retry.y = FlxG.height - retry.height - 50;
					CustomSubstate.instance.add(retry);
				}
			});
	}
}

function onCustomSubstateUpdate(name, elapsed)
{
	if (name == 'webGameover')
	{
		if (canInteract)
		{
			if (Controls.instance.ACCEPT)
			{
				canInteract = false;
				// FlxG.sound.play(Paths.sound('webfishEnter'));
				
				camOther.fade(0xFF101C31, 0.01, false, FlxG.resetState);
				FlxTransitionableState.skipNextTransIn = true;
			}
			else if (Controls.instance.BACK)
			{
				canInteract = false;
				FlxG.sound.play(Paths.sound('webfishExit'));
				FlxTransitionableState.skipNextTransIn = true;
				
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				PlayState.chartingMode = false;
				
				Mods.loadTopMod();
				
				camOther.fade(0xFF101C31, 0.01, false, () -> {
					if (PlayState.isStoryMode) FlxG.switchState(() -> new StoryMenuState());
					else FlxG.switchState(() -> new FreeplayMenuCord());
					CoolUtil.playMenuMusic();
				});
			}
		}
	}
}
