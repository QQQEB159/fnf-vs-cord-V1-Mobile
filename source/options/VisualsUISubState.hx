package options;

import objects.Note;
import objects.StrumNote;
import objects.Alphabet;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and UI:';
		rpcTitle = 'Visuals & UI Settings Menu'; // for Discord Rich Presence
		
		var noteSplashes:Array<String> = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt');
		if (noteSplashes.length > 0)
		{
			if (!noteSplashes.contains(ClientPrefs.data.splashSkin)) ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; // Reset to default if saved splashskin couldnt be found
			
			noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin); // Default skin always comes first
			var option:Option = new Option('Note Splashes:', "Select your prefered Note Splash variation or turn it off.", 'splashSkin', 'string', noteSplashes);
			addOption(option);
		}
		
		var option:Option = new Option('Note Splash Opacity', 'How much transparent should the Note Splashes be.', 'splashAlpha', 'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		var option:Option = new Option('Hide HUD', 'If checked, hides most HUD elements.', 'hideHud', 'bool');
		addOption(option);
		
		var option:Option = new Option('Simplified Score', 'Makes the score less complicated if checked.', 'simplifiedScore', 'bool');
		addOption(option);
		
		var option:Option = new Option('Flashing Lights', "Uncheck this if you're sensitive to flashing lights!", 'flashing', 'bool');
		addOption(option);
		
		option.addsVisualSpace = true;
		
		var option:Option = new Option('Camera Zooms', "If unchecked, the camera won't zoom in on a beat hit.", 'camZooms', 'bool');
		addOption(option);
		
		var option:Option = new Option('Score Text Zoom on Hit', "If unchecked, disables the Score text zooming\neverytime you hit a note.", 'scoreZoom', 'bool');
		addOption(option);
		
		var option:Option = new Option('Health Bar Opacity', 'How much transparent should the health bar and icons be.', 'healthBarAlpha', 'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		var option:Option = new Option('Background Brightness', 'Displays a bar behind your notes so you can see them better', 'noteUnderlayAlpha', 'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.05;
		option.decimals = 2;
		addOption(option);
		
		option.addsVisualSpace = true;
		
		#if !mobile
		var option:Option = new Option('FPS Counter', 'If unchecked, hides FPS Counter.', 'showFPS', 'bool');
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end
		
		option.addsVisualSpace = true;
		
		var option:Option = new Option('Pause Screen Song:', "What song do you prefer for the Pause Screen?", 'pauseMusic', 'string', ['None', 'Press Paws']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if DISCORD_ALLOWED
		var option:Option = new Option('Discord Rich Presence', "Uncheck this to prevent accidental leaks, it will hide the Application from your \"Playing\" box on Discord", 'discordRPC', 'bool');
		addOption(option);
		#end
		
		var option:Option = new Option('Combo Stacking', "If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read", 'comboStacking', 'bool');
		addOption(option);
		
		var option:Option = new Option('Streamer Mode', "If unchecked, Any instance of copyrighted material will be disabled", 'streamerMode', 'bool');
		addOption(option);
		
		super();
	}
	
	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
	}
	
	var changedMusic:Bool = false;
	
	function onChangePauseMusic()
	{
		if (ClientPrefs.data.pauseMusic == 'None') FlxG.sound.music.volume = 0;
		else FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));
		
		changedMusic = true;
	}
	
	override function destroy()
	{
		if (changedMusic && !OptionsState.onPlayState) CoolUtil.playMenuMusic();
		super.destroy();
	}
	
	#if !mobile
	function onChangeFPSCounter()
	{
		if (Main.fpsVar != null) Main.fpsVar.visible = ClientPrefs.data.showFPS;
	}
	#end
}
