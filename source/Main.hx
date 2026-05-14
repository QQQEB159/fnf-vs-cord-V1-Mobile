package;

import flixel.util.typeLimit.NextState;

import states.credits.CreditsPlatformer;
import states.minigames.RosieSimV2;
import states.StatsMenuState;
import states.GalleryState;

import options.OptionsState;

import states.minigames.FindCord;
import states.FreeplayMenuCord;

import objects.FunkinSoundTray;

import debug.FPSCounter;

import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;

import haxe.io.Path;

import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;

import lime.app.Application;
import lime.system.System as LimeSystem;

import states.TitleState;
#if COPYSTATE_ALLOWED
import states.CopyState;
#end

#if desktop
import ALConfig;
#end

#if linux
import lime.graphics.Image;
#end

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end
typedef GameStruct =
{
	width:Int,
	height:Int,
	initialState:Class<FlxState>,
	framerate:Int,
	skipSplash:Bool,
	startFullscreen:Bool
}

class Main extends Sprite
{
	public static final game:GameStruct =
		{
			width: 1280, // WINDOW width
			height: 720, // WINDOW height
			initialState: TitleState, // initial game state
			framerate: 60, // default framerate
			skipSplash: true, // if the default flixel splash screen should be skipped
			startFullscreen: false // if the game should start at fullscreen mode
		};
		
	public static var fpsVar:FPSCounter;
	
	// You can pretty much ignore everything from here on - your code should go in your states.
	
	public static function main():Void
	{
		Lib.current.addChild(new Main());
		#if cpp
        cpp.NativeGc.enable(true);
        cpp.NativeGc.run(true);
        #end
	}
	
	public function new()
	{
		#if mobile
		#if android
		StorageUtil.requestPermissions();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end
		backend.CrashHandler.init();
		
		super();
		
		#if (windows && cpp)
		backend.Native.fixScaling();
		#end
		
		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init();
		#end
		
		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		
		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		
		addChild(new FNFGame(game.width, game.height, #if COPYSTATE_ALLOWED !CopyState.checkExistingFiles() ? CopyState : #end Init, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
		
		// prevent accept button when alt+enter is pressed
		FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e) -> {
			if (e.keyCode == flixel.input.keyboard.FlxKey.ENTER && e.altKey) e.stopImmediatePropagation();
		}, false, 100);
		
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if (fpsVar != null)
		{
			fpsVar.visible = ClientPrefs.data.showFPS;
		}
		
		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end
		
		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		#if mobile
		LimeSystem.allowScreenTimeout = ClientPrefs.data.screensaver;
		#end
		
		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end
		
		FlxG.signals.gameResized.add(function (w, h) {
			if (fpsVar != null) fpsVar.positionFPS(10, 3, Math.min(Lib.current.stage.stageWidth / FlxG.width, Lib.current.stage.stageHeight / FlxG.height));
		});
	}
	
	public static function getFirstState():NextState
	{
		return ClientPrefs.data.shouldPreload ? () -> new Preload() : () -> Type.createInstance(Main.game.initialState, []);
	}
}

class FNFGame extends FlxGame
{
	//
	override function create(_:Event)
	{
		_customSoundTray = FunkinSoundTray;
		super.create(_);
	}
	
	override function onEnterFrame(_)
	{
		super.onEnterFrame(_);
		
		// this is called no matter what
	}
}
