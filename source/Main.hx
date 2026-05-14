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

#if android
import android.content.Context;
#end

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

import states.TitleState;

#if desktop
import ALConfig;
#end

#if linux
import lime.graphics.Image;
#end

// crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;

import haxe.CallStack;
import haxe.io.Path;
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
	}
	
	public function new()
	{
		super();
		
		#if (windows && cpp)
		backend.Native.fixScaling();
		#end
		
		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init();
		#end
		
		// Credits to MAJigsaw77 (he's the og author for this code)
		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end
		
		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		
		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		
		addChild(new FNFGame(game.width, game.height, Init, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
		
		// prevent accept button when alt+enter is pressed
		FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e) -> {
			if (e.keyCode == flixel.input.keyboard.FlxKey.ENTER && e.altKey) e.stopImmediatePropagation();
		}, false, 100);
		
		#if !mobile
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if (fpsVar != null)
		{
			fpsVar.visible = ClientPrefs.data.showFPS;
		}
		#end
		
		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end
		
		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
		
		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end
	}
	
	public static function getFirstState():NextState
	{
		return ClientPrefs.data.shouldPreload ? () -> new Preload() : () -> Type.createInstance(Main.game.initialState, []);
	}
	
	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();
		
		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");
		
		path = "./crash/" + "PsychEngine_" + dateNow + ".txt";
		
		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}
		
		errMsg += "\nUncaught Error: "
			+ e.error
			+ "\nPlease report this error to the GitHub page: https://github.com/ShadowMario/FNF-PsychEngine\n\n> Crash Handler written by: sqirra-rng";
			
		if (!FileSystem.exists("./crash/")) FileSystem.createDirectory("./crash/");
		
		File.saveContent(path, errMsg + "\n");
		
		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));
		
		Application.current.window.alert(errMsg, "Error!");
		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
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
