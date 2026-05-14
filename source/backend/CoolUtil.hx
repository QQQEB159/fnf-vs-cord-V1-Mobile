package backend;

import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.addons.transition.FlxTransitionableState;

import lime.app.Application;

import openfl.utils.Assets;

import lime.utils.Assets as LimeAssets;

class CoolUtil
{
	inline public static function quantize(f:Float, snap:Float)
	{
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}
	
	inline public static function capitalize(text:String) return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();
	
	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		var formatted:Array<String> = path.split(':'); // prevent "shared:", "preload:" and other library names on file path
		path = formatted[formatted.length - 1];
		if (FileSystem.exists(path)) daList = File.getContent(path);
		#else
		if (Assets.exists(path)) daList = Assets.getText(path);
		#end
		return daList != null ? listFromString(daList) : [];
	}
	
	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if (color.startsWith('0x')) color = color.substring(color.length - 6);
		
		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if (colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}
	
	inline public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		if (string != null) daList = string.trim().split('\n');
		
		for (i in 0...daList.length)
			daList[i] = daList[i].trim();
			
		return daList;
	}
	
	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if (decimals < 1) return Math.floor(value);
		
		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;
			
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}
	
	inline public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0)
				{
					if (countByColor.exists(colorOfThisPixel)) countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687)) countByColor[colorOfThisPixel] = 1;
				}
			}
		}
		
		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for (key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		countByColor = [];
		return maxKey;
	}
	
	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
			dumbArray.push(i);
			
		return dumbArray;
	}
	
	inline public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
	
	inline public static function openFolder(folder:String, absolute:Bool = false)
	{
		#if sys
		if (!absolute) folder = Sys.getCwd() + '$folder';
		
		folder = folder.replace('/', '\\');
		if (folder.endsWith('/')) folder.substr(0, folder.length - 1);
		
		#if linux
		var command:String = 'explorer.exe';
		#else
		var command:String = '/usr/bin/xdg-open';
		#end
		Sys.command(command, [folder]);
		trace('$command $folder');
		#else
		FlxG.error("Platform is not supported for CoolUtil.openFolder");
		#end
	}
	
	/**
		Helper Function to Fix Save Files for Flixel 5

		-- EDIT: [November 29, 2023] --

		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String
	{
		final company:String = FlxG.stage.application.meta.get('company');
		// #if (flixel < "5.0.0") return company; #else
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
		// #end
	}
	
	public static function setTextBorderFromString(text:FlxText, border:String)
	{
		switch (border.toLowerCase().trim())
		{
			case 'shadow':
				text.borderStyle = SHADOW;
			case 'outline':
				text.borderStyle = OUTLINE;
			case 'outline_fast', 'outlinefast':
				text.borderStyle = OUTLINE_FAST;
			default:
				text.borderStyle = NONE;
		}
	}
	
	/**
	 * referenced via https://youtu.be/LSNQuFEDOyQ
	 * 
	 * A frame independent lerp. Primary purpose is for the camera
	 * 
	 * your decay should be around 1 - 25
	 */
	public static function decayLerp(a:Float, b:Float, decay:Float, elapsed:Float) return b + (a - b) * Math.exp(-decay * elapsed);
	
	public static function centerWindow(?_)
	{
		Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
		Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);
	}
	
	public static function setTransitionSkip(into:Bool = false, outof:Bool = false)
	{
		FlxTransitionableState.skipNextTransIn = into;
		FlxTransitionableState.skipNextTransOut = outof;
	}
	
	public static function playPersistentSound(sound:FlxSoundAsset, volume:Float = 1):FlxSound
	{
		final sndPlayer = FlxG.sound.play(sound, volume);
		sndPlayer.persist = true;
		return sndPlayer;
	}
	
	public static function playMenuMusic(volume:Float = 1)
	{
		FlxG.sound.playMusic(getMenuMusic(), volume);
		Conductor.bpm = ClientPrefs.data.currentMenuMusic.toBPM();
	}
	
	public static function tryPlayingMenuMusic(vol:Float = 1)
	{
		final music = getMenuMusic();
		if (FlxG.sound.music == null || FlxG.sound.music.length != music.length)
		{
			playMenuMusic(vol);
		}
	}
	
	public static function getMenuMusic()
	{
		final customExists = Paths.fileExists('music/customMenuMusic.ogg', SOUND);
		
		return Paths.music(ClientPrefs.data.currentMenuMusic == CUSTOM ? customExists ? 'customMenuMusic' : MenuMusic.FREAKY_MENU : ClientPrefs.data.currentMenuMusic);
	}
	
	public static function pngFromFlxSprite(spr:FlxSprite, pathToSave:String)
	{
		if (spr == null) return;
		
		try
		{
			File.saveBytes(pathToSave + '.png', spr.pixels.encode(spr.pixels.rect, new openfl.display.PNGEncoderOptions()));
		}
	}
	
	// weekly updating fanart shit below
	public static final FAN_ART_KEY:String = 'VS_CORD_FAN_ARTWORK';
	static var artworkCredit:Null<String> = null;
	static var artworkYear:Null<String> = '20XX';
	public static var currentSunday = getSundaysPassed();
	
	public static function loadFanartOfTheWeek(?onComplete:Void->Void)
	{
		final url = 'https://raw.githubusercontent.com/RoseCord/VsCord-Weekly-Fanart/refs/heads/main/artwork.txt';
		final http = new haxe.Http(url);
		
		http.onData = (data) -> {
			if (data.length > 0)
			{
				final list = listFromString(data);
				
				final idx = Std.int(FlxMath.wrap(getSundaysPassed(), 0, list.length - 1));
				
				final week = list[idx];
				
				final image = week.split('|')[0].trim();
				
				artworkCredit = (week.split('|')[1] ?? 'unknown').trim();
				
				artworkYear = (week.split('|')[2] ?? '20XX').trim();
				
				Paths.cacheUrlBitmap('https://raw.githubusercontent.com/RoseCord/VsCord-Weekly-Fanart/refs/heads/main/art/$image.png', FAN_ART_KEY, true, true, true, onComplete);
			}
		}
		
		http.request(false);
	}
	
	public static function getTimeZoneMili(date:Date) // ?
	{
		var offset = date.getTimezoneOffset();
		offset *= 60;
		offset *= 1000;
		return offset;
	}
	
	public static function getTimeUntilNextSunday()
	{
		var now = Date.now();
		var curTime = now.getTime();
		
		var nextTime:Float = 0;
		
		final daysInAMonth = getDaysInMonth(now.getFullYear(), now.getMonth());
		
		final curDay = now.getDate();
		
		var sundaysLeft:Int = 0;
		
		for (i in curDay...daysInAMonth)
		{
			var day = new Date(now.getFullYear(), now.getMonth(), i + 1, 23, 59, 59);
			
			if (day.getDay() == 6)
			{
				sundaysLeft++;
			}
		}
		
		if (curDay == daysInAMonth || sundaysLeft == 0)
		{
			final nextMonthDay = new Date(now.getFullYear(), now.getMonth() + 1, 1, 0, 0, 0);
			
			for (i in nextMonthDay.getDate()...getDaysInMonth(nextMonthDay.getFullYear(), nextMonthDay.getMonth()))
			{
				var day = new Date(nextMonthDay.getFullYear(), nextMonthDay.getMonth(), i, 23, 59, 59);
				
				if (day.getDay() == 6)
				{
					return Math.max(0, (day.getTime() - curTime) /**+ (24 * 3600000)**/);
				}
			}
		}
		
		for (i in curDay...daysInAMonth)
		{
			var day = new Date(now.getFullYear(), now.getMonth(), i, 23, 59, 59);
			if (day.getDay() == 6)
			{
				nextTime = day.getTime();
				break;
			}
		}
		
		return Math.max(0, nextTime - curTime);
	}
	
	// i cannoty confirm if this is a good method to handle this but sure whatever
	
	static function getWeek()
	{
		return Math.floor(Date.now().getDate() / 7);
	}
	
	static function getDaysInMonth(year:Int, month:Int):Int
	{
		return new Date(year, FlxMath.wrap(month + 1, 0, 11), 0, 0, 0, 0).getDate();
	}
	
	// static function
	
	static function getSundaysPassed()
	{
		final now = Date.now();
		var sundays:Int = 0;
		for (i in 0...now.getDate())
		{
			var day = new Date(now.getFullYear(), now.getMonth(), i, 0, 0, 0);
			
			if (day.getDay() == 6)
			{
				sundays++;
			}
		}
		
		return sundays;
	}
	
	static function getTotalSundays()
	{
		final now = Date.now();
		var sundays:Int = 0;
		for (i in 0...getDaysInMonth(now.getFullYear(), now.getMonth()))
		{
			var day = new Date(now.getFullYear(), now.getMonth(), i + 1, 0, 0, 0);
			trace(day);
			
			if (day.getDay() == 0)
			{
				sundays++;
			}
		}
		
		return sundays;
	}
	
	public static function resizeWindow(w:Int, h:Int)
	{
		//
	}
}
