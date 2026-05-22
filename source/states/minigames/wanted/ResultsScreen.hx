package states.minigames.wanted;

import options.OptionsText;
import options.OptionsState;

class ResultsScreen extends MusicBeatSubstate
{
	final parentState:FindCord;
	
	public function new(parentState:FindCord)
	{
		super();
		
		this.parentState = parentState;
		
		FlxG.sound.playMusic(Paths.music('minigames/findCordGameover'), 0);
		FlxTween.tween(FlxG.sound.music, {volume: 1}, 3, {startDelay: 1});
		
		var highscoreTxt = new OptionsText(0, 15, FlxG.width, 'HIGH SCORES', 48);
		highscoreTxt.alignment = CENTER;
		add(highscoreTxt);
		
		inline function formatString(rank:String, score:String)
		{
			rank = switch (rank)
			{
				case '1': '1st';
				case '2': '2nd';
				case '3': '3rd';
				default: rank + 'th';
			}
			final totalLength = rank.length + score.length;
			
			var spacing = '';
			
			while ((spacing.length + totalLength) < 15)
			{
				spacing = spacing + ' ';
			}
			
			return rank + spacing + score;
		}
		
		var highestCaught = false;
		
		for (k => i in FindCord.getBestScores())
		{
			final txt = new OptionsText(250, 100 + (k * 26), FlxG.width - (250 * 2), formatString(Std.string(k + 1), Std.string(i)), 24);
			add(txt);
			txt.alignment = CENTER;
			@:privateAccess
			if (parentState.score == i && !highestCaught)
			{
				highestCaught = true;
				
				var youTxt = new OptionsText(800, txt.y, ' < YOU', 24);
				add(youTxt);
			}
		}
		
		var press = new OptionsText(0, 15, FlxG.width, 'PRESS ENTER TO RETRY / PRESS ESCAPE TO LEAVE', 24);
		press.alignment = CENTER;
		add(press);
		press.y = FlxG.height - press.height - 15;
		
		addTouchPad("NONE", "A_B");
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (controls.ACCEPT) FlxG.resetState();
		else if (controls.BACK)
		{
			CoolUtil.playMenuMusic();
			FlxG.sound.music.volume = 0;
			FlxG.switchState(() -> new OptionsState());
		}
	}
	
	override function destroy()
	{
		FlxTween.cancelTweensOf(FlxG.sound.music, ['volume']);
		super.destroy();
	}
}
