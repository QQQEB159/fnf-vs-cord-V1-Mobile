import options.OptionsState;

import backend.WeekData;
import backend.Song;

import states.CopyrightState;

import backend.StickerTransition;

import openfl.display.BitmapData;

import api.NewgroundsClient;

import backend.Stats;

import plugins.HotReloadPlugin;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;

@:bitmap('art/rosieClickerCursor.png') class RosieClickerCursor extends BitmapData {}

class Init extends FlxState
{
	override function create()
	{
		super.create();
		
		DragAndDrop.init();
		
		CoolUtil.playMenuMusic(0);
		
		StickerTransition.fileName = '1';
		
		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];
		
		ClientPrefs.loadPrefs();
		
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
		
		Stats.loadStats();
		
		NewgroundsClient.initCore();
		
		backend.Highscore.load();
		
		if (FlxG.save.data != null && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		}
		
		if (FlxG.save.data.weekCompleted != null)
		{
			states.StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}
		
		HotReloadPlugin.init();
		
		CoolUtil.loadFanartOfTheWeek();
		
		FlxG.mouse.visible = false;
		
		MobileData.init();
		
		if (FlxG.save.data.streamerMode == null)
		{
			Main.game.initialState = CopyrightState;
		}
		
		FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
		if (FlxG.random.bool(10)) FlxG.switchState(() -> new WiiPopup());
		else FlxG.switchState(Main.getFirstState());
	}
}
