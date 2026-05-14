package backend;

import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;

import backend.StickerTransition;
import backend.PsychCamera;

enum abstract TransitionType(Int)
{
	var WEB_FISHING = 0;
	var STICKERS = 1;
	var SWIPE = 2;
	var FADE = 3;
}

class MusicBeatState extends FlxUIState
{
	public static var currentTransition:TransitionType = SWIPE;
	
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;
	
	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	
	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	
	public var controls(get, never):Controls;
	
	private function get_controls()
	{
		return Controls.instance;
	}
	
	public function new() super();
	
	var _psychCameraInitialized:Bool = false;
	
	override function create()
	{
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		#if MODS_ALLOWED Mods.updatedOnState = false; #end
		
		if (!_psychCameraInitialized) initPsychCamera();
		
		super.create();
		
		if (!skip)
		{
			switch (currentTransition)
			{
				case FADE:
					openSubState(new FadeTransition(0.7, true));
				case STICKERS:
					openSubState(StickerTransition.previousData != null ? new StickerTransition() : new CustomFadeTransition(0.7, true));
				case WEB_FISHING:
					openSubState(new WebFishingTransition(0.7, true));
				default:
					openSubState(new CustomFadeTransition(0.7, true));
			}
		}
		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;
	}
	
	public function initPsychCamera():PsychCamera
	{
		var camera = new PsychCamera();
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		_psychCameraInitialized = true;
		return camera;
	}
	
	public static var timePassedOnState:Float = 0;
	
	override function update(elapsed:Float)
	{
		timePassedOnState += elapsed;
		
		final oldStep:Int = curStep;
		
		updateCurStep();
		updateBeat();
		
		if (curStep > oldStep)
		{
			if (curStep > 0) for (step in oldStep...curStep)
			{
				curStep = step + 1;
				updateBeat();
				stepHit();
			}
			
			if (PlayState.SONG != null) updateSection();
		}
		else if (PlayState.SONG != null)
		{
			rollbackSection();
		}
		
		if (FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;
		
		stagesFunc(function(stage:BaseStage) {
			stage.update(elapsed);
		});
		
		super.update(elapsed);
	}
	
	private function updateSection():Void
	{
		if (stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}
	
	private function rollbackSection():Void
	{
		if (curStep < 0) return;
		
		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if (stepsToDo > curStep) break;
				
				curSection++;
			}
		}
		
		if (curSection > lastSection) sectionHit();
	}
	
	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}
	
	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);
		
		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}
	
	override function startOutro(onOutroComplete:() -> Void)
	{
		if (!FlxTransitionableState.skipNextTransIn)
		{
			switch (currentTransition)
			{
				case FADE:
					openSubState(new FadeTransition(0.6, false, onOutroComplete));
				case STICKERS:
					if (StickerTransition.fileName != null) openSubState(new StickerTransition(onOutroComplete));
					else openSubState(new CustomFadeTransition(0.6, false, onOutroComplete));
					
				case WEB_FISHING:
					openSubState(new WebFishingTransition(0.6, false, onOutroComplete));
					
				default:
					openSubState(new CustomFadeTransition(0.6, false, onOutroComplete));
			}
			
			return;
		}
		
		FlxTransitionableState.skipNextTransIn = false;
		
		super.startOutro(onOutroComplete);
	}
	
	public function getTopState():FlxState
	{
		var state:FlxState = FlxG.state;
		while (state.subState != null)
			state = state.subState;
		return state;
	}
	
	override function destroy()
	{
		Stats.addTime(timePassedOnState);
		Stats.saveStats(); // not the biggest fan of flushing every time the state swaps feels gross...
		super.destroy();
	}
	
	public static function getState():MusicBeatState
	{
		return cast(FlxG.state, MusicBeatState);
	}
	
	public function stepHit():Void
	{
		stagesFunc(function(stage:BaseStage) {
			stage.curStep = curStep;
			stage.curDecStep = curDecStep;
			stage.stepHit();
		});
		
		if (curStep % 4 == 0) beatHit();
	}
	
	public var stages:Array<BaseStage> = [];
	
	public function beatHit():Void
	{
		// trace('Beat: ' + curBeat);
		stagesFunc(function(stage:BaseStage) {
			stage.curBeat = curBeat;
			stage.curDecBeat = curDecBeat;
			stage.beatHit();
		});
	}
	
	public function sectionHit():Void
	{
		// trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
		stagesFunc(function(stage:BaseStage) {
			stage.curSection = curSection;
			stage.sectionHit();
		});
	}
	
	function stagesFunc(func:BaseStage->Void)
	{
		for (stage in stages)
			if (stage != null && stage.exists && stage.active) func(stage);
	}
	
	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
