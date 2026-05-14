package states.minigames.rosiesim;

import states.minigames.rosiesim.StarBearModiferModule.StarBearModifierModule;

import flixel.util.FlxSignal.FlxTypedSignal;

import states.minigames.rosiesim.Outfit;

class Rosie extends FlxSprite
{
	public var outfit(default, set):Outfit = ROSE;
	
	var bopTwn:Null<FlxTween> = null;
	
	var spinTwn:Null<FlxTween> = null;
	
	var _doSpin:Bool = false;
	
	function set_outfit(v:Outfit)
	{
		loadGraphic(Paths.image('minigames/rosieclicker/$v'));
		
		if (_doSpin)
		{
			FlxG.sound.play(Paths.sound('minigames/rosieclicker/nop'));
			spinTwn?.cancel();
			if (angle > 350) angle = 0;
			spinTwn = FlxTween.tween(this, {angle: 360}, 1,
				{
					ease: FlxEase.expoOut,
					onComplete: Void -> {
						angle = 0;
					}
				});
		}
		onOutfitSwap(v, !_doSpin);
		
		if (FlxG.sound.music != null) FlxG.sound.music.pitch = 1;
		
		_doSpin = true;
		
		return this.outfit = v;
	}
	
	public function bop()
	{
		bopTwn?.cancel();
		
		final newScale = 0.925;
		scale.set(newScale, newScale);
		if ((spinTwn == null || !spinTwn.active) && outfit != STARBEAR)
		{
			angle = FlxG.random.float(-2, 2);
			bopTwn = FlxTween.tween(this, {'scale.x': 1, 'scale.y': 1, angle: 0}, 0.8, {ease: FlxEase.backOut});
		}
		else
		{
			bopTwn = FlxTween.tween(this, {'scale.x': 1, 'scale.y': 1}, 0.8, {ease: FlxEase.backOut});
		}
	}
	
	public dynamic function onOutfitSwap(outfit:Outfit, forced:Bool)
	{
		final state:RosieSimV2 = cast FlxG.state;
		
		FlxTween.cancelTweensOf(state.bgShader);
		FlxTween.tween(state.bgShader, {hue: outfit.isCord() ? -0.3 : 0}, 0.6);
		
		if (StarBearModifierModule.isStarPlush(outfit)
			&& state.starBearModifierModule.connectionStatus == DISCONNECTED) state.starBearModifierModule.connect();
		else if (state.starBearModifierModule.connectionStatus == CONNECTED) state.starBearModifierModule.disconnect();
		
		if (NolimeModifierModule.isNolime(outfit)
			&& state.nolimeModifierModule.connectionStatus == DISCONNECTED) state.nolimeModifierModule.connect();
		else if (state.nolimeModifierModule.connectionStatus == CONNECTED) state.nolimeModifierModule.disconnect();
		
		if (outfit.isCord() && !Achievements.isUnlocked('unlockCord')) Achievements.unlock('unlockCord');
		if (outfit.toString() == ONESIE_CORD && !Achievements.isUnlocked('unlockAll')) Achievements.unlock('unlockAll');
		
		@:privateAccess
		state.updateRpc(outfit.toRpc());
		
		if (this.outfit.isCord() == outfit.isCord() && !forced)
		{
			return;
		}
		
		if (outfit.isCord())
		{
			FlxG.sound.music.fadeOut();
			state.cordMusic.fadeIn();
		}
		else
		{
			FlxG.sound.music.fadeIn();
			state.cordMusic.fadeOut();
		}
		state.showSongTxt(!outfit.isCord());
	}
}
