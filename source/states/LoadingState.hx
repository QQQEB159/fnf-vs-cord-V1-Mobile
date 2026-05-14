package states;

import flixel.util.typeLimit.NextState;
import flixel.FlxState;

import backend.StageData;

class LoadingState extends MusicBeatState
{
	inline static public function loadAndSwitchState(target:NextState, stopMusic = false)
	{
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;
		
		if (weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;
		
		Paths.setCurrentLevel(directory);
		
		if (stopMusic && FlxG.sound.music != null) FlxG.sound.music.stop();
		
		FlxG.switchState(target);
	}
}
