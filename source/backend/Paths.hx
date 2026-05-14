package backend;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;

import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
import openfl.geom.Rectangle;

import lime.utils.Assets;

import openfl.media.Sound;

import haxe.Json;

#if MODS_ALLOWED
import backend.Mods;
#end

class Paths
{
	#if ASSET_REDIRECT
	public static inline final trail = #if macos '../../../../../../../' #else '../../../../' #end;
	#end
	
	/**
	 * Primary asset directory
	 */
	public static inline final CORE_DIRECTORY = #if ASSET_REDIRECT trail + 'assets' #else 'assets' #end; // to do make this work
	
	/**
	 * Mod directory
	 */
	public static inline final MODS_DIRECTORY = #if ASSET_REDIRECT trail + 'mods' #else 'mods' #end;
	
	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	
	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];
	
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";
	
	public static function excludeAsset(key:String)
	{
		if (!dumpExclusions.contains(key)) dumpExclusions.push(key);
	}
	
	public static var dumpExclusions:Array<String> = [
		'assets/shared/music/freakyMenu.$SOUND_EXT',
		'assets/shared/music/breakfast.$SOUND_EXT',
		'assets/shared/music/tea-time.$SOUND_EXT',
	];
	
	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory()
	{
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys())
		{
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				disposeGraphic(currentTrackedAssets.get(key));
				currentTrackedAssets.remove(key);
			}
		}
		
		// run the garbage collector for good measure lmfao
		System.gc();
	}
	
	/**
	 * Disposes of a flxgraphic
	 * 
	 * frees its gpu texture as well.
	 * @param graphic 
	 */
	@:access(openfl.display.BitmapData)
	public static function disposeGraphic(graphic:Null<FlxGraphic>)
	{
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null) graphic.bitmap.__texture.dispose();
		@:nullSafety(Off) FlxG.bitmap.remove(graphic);
	}
	
	public static function disposeSound(key:String) // not really dispose... but for the fun of it lets call it that
	{
		Assets.cache.clear(key);
		if (currentTrackedSounds.exists(key)) currentTrackedSounds.remove(key);
	}
	
	public static function clearStoredMemory(?cleanUnused:Bool = false)
	{
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			if (!currentTrackedAssets.exists(key))
			{
				disposeGraphic(FlxG.bitmap.get(key));
			}
		}
		
		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
			{
				disposeSound(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		#if !html5 openfl.Assets.cache.clear("songs"); #end
	}
	
	static public var currentLevel:String;
	
	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}
	
	public static function getPath(file:String, ?type:AssetType = TEXT, ?library:Null<String> = null, ?modsAllowed:Bool = false):String
	{
		#if MODS_ALLOWED
		if (modsAllowed)
		{
			var customFile:String = file;
			if (library != null) customFile = '$library/$file';
			
			var modded:String = modFolders(customFile);
			
			if (FileSystem.exists(modded)) return modded;
		}
		#end
		
		if (library != null) return getLibraryPath(file, library);
		
		if (currentLevel != null)
		{
			var levelPath:String = '';
			if (currentLevel != 'shared')
			{
				levelPath = getLibraryPathForce(file, 'week_assets', currentLevel);
				if (OpenFlAssets.exists(levelPath, type)) return levelPath;
			}
		}
		
		return getSharedPath(file);
	}
	
	static public function getLibraryPath(file:String, library = "shared")
	{
		return if (library == "shared") getSharedPath(file); else getLibraryPathForce(file, library);
	}
	
	inline static function getLibraryPathForce(file:String, library:String, ?level:String)
	{
		if (level == null) level = library;
		return '$CORE_DIRECTORY/$level/$file';
	}
	
	inline public static function getSharedPath(file:String = '')
	{
		return '$CORE_DIRECTORY/shared/$file';
	}
	
	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}
	
	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}
	
	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}
	
	inline static public function shaderFragment(key:String, ?library:String)
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}
	
	inline static public function shaderVertex(key:String, ?library:String)
	{
		return getPath('shaders/$key.vert', TEXT, library);
	}
	
	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}
	
	static public function video(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsVideo(key);
		if (FileSystem.exists(file))
		{
			return file;
		}
		#end
		return 'assets/videos/$key.$VIDEO_EXT';
	}
	
	static public function sound(key:String):Sound
	{
		return returnSound('sounds/$key');
	}
	
	inline static public function soundRandom(key:String, min:Int, max:Int)
	{
		return sound(key + FlxG.random.int(min, max));
	}
	
	inline static public function music(key:String):Sound
	{
		return returnSound('music/$key');
	}
	
	inline static public function voices(song:String):Sound
	{
		return returnSound('${formatToSongPath(song)}/Voices', 'songs');
	}
	
	inline static public function inst(song:String):Sound
	{
		return returnSound('${formatToSongPath(song)}/Inst', 'songs');
	}
	
	static public function gif(key:String, ?library:String = null):FlxGraphic
	{
		var file:String = null;
		
		#if MODS_ALLOWED
		file = modFolders('images/' + key + '.gif');
		if (FileSystem.exists(file))
		{
			trace('Loading GIF from mods: ' + file);
			// If using flxgif for animated GIFs:
			// return FlxGIF.loadGraphicFromFile(file);
			
			// If only static (first frame):
			var bitmap = BitmapData.fromFile(file);
			return cacheBitmap(file, bitmap);
		}
		#end
		
		file = getPath('images/$key.gif', IMAGE, library);
		if (FileSystem.exists(file))
		{
			trace('Loading GIF from assets: ' + file);
			// If using flxgif:
			// return FlxGIF.loadGraphicFromFile(file);
			
			// Fallback: static GIF (first frame)
			var bitmap = BitmapData.fromFile(file);
			return cacheBitmap(file, bitmap);
		}
		
		trace('gif from "$key" returned null');
		return null;
	}
	
	static public function image(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxGraphic
	{
		var bitmap:BitmapData = null;
		var file:String = null;
		
		#if MODS_ALLOWED
		file = modsImages(key);
		if (currentTrackedAssets.exists(file))
		{
			localTrackedAssets.push(file);
			return currentTrackedAssets.get(file);
		}
		else if (FileSystem.exists(file)) bitmap = BitmapData.fromFile(file);
		else
		#end
		{
			file = getPath('images/$key.png', IMAGE, library);
			if (currentTrackedAssets.exists(file))
			{
				localTrackedAssets.push(file);
				return currentTrackedAssets.get(file);
			}
			else if (FileSystem.exists(file)) bitmap = BitmapData.fromFile(file);
			else if (OpenFlAssets.exists(file, IMAGE)) bitmap = OpenFlAssets.getBitmapData(file);
		}
		
		if (bitmap != null)
		{
			var retVal = cacheBitmap(file, bitmap, allowGPU);
			if (retVal != null) return retVal;
		}
		
		trace('image from "$key" returned null');
		return null;
	}
	
	static public function cacheBitmap(file:String, ?bitmap:BitmapData = null, ?allowGPU:Bool = true)
	{
		if (bitmap == null)
		{
			#if MODS_ALLOWED
			if (FileSystem.exists(file)) bitmap = BitmapData.fromFile(file);
			else
			#end
			{
				if (OpenFlAssets.exists(file, IMAGE)) bitmap = OpenFlAssets.getBitmapData(file);
			}
			
			if (bitmap == null) return null;
		}
		
		localTrackedAssets.push(file);
		if (allowGPU && ClientPrefs.data.cacheOnGPU)
		{
			bitmap.disposeImage();
		}
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
		currentTrackedAssets.set(file, newGraphic);
		return newGraphic;
	}
	
	/**
	 * Loads a graphic from url to a sprite.
	 * 
	 * png only tho..
	 * @param sprite 
	 * @param url 
	 * @param allowGPU 
	 * @return FlxSprite
	 */
	public static function loadFromUrl(sprite:FlxSprite, url:String, allowGPU:Bool = true):FlxSprite
	{
		if (sprite == null || !url.contains('png')) return sprite;
		
		if (Paths.currentTrackedAssets.exists(url))
		{
			return sprite.loadGraphic(Paths.currentTrackedAssets.get(url));
		}
		
		var http = new Http(url);
		http.onBytes = (bytes) -> {
			final bitmap = BitmapData.fromBytes(bytes);
			if (bitmap != null)
			{
				sprite.loadGraphic(Paths.cacheBitmap(url, bitmap, allowGPU));
			}
		}
		http.request(false);
		
		return sprite;
	}
	
	public static function cacheUrlBitmap(url:String, ?uniqueKey:String, allowGPU:Bool = true, permanent:Bool = true, ignoreCached:Bool = false, ?onComplete:Void->Void):Void
	{
		if (!ignoreCached || Paths.currentTrackedAssets.exists(url))
		{
			trace('$url is already cached');
			return;
		}
		
		var http = new Http(url);
		http.onBytes = (bytes) -> {
			final bitmap = BitmapData.fromBytes(bytes);
			if (bitmap != null)
			{
				var key = uniqueKey ?? url;
				
				if (permanent)
				{
					excludeAsset(key);
				}
				
				if (allowGPU && ClientPrefs.data.cacheOnGPU)
				{
					bitmap.disposeImage();
				}
				
				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
				newGraphic.persist = true;
				newGraphic.destroyOnNoUse = false;
				currentTrackedAssets.remove(key);
				currentTrackedAssets.set(key, newGraphic);
				
				if (onComplete != null) onComplete();
				trace('successfully cached $url');
			}
			else
			{
				trace('failed to cache $url');
			}
		}
		http.onError = (err) -> {
			trace('failed to cache Url Bitmap error: $err');
		}
		http.request(false);
	}
	
	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if sys
		#if MODS_ALLOWED
		if (!ignoreMods && FileSystem.exists(modFolders(key))) return File.getContent(modFolders(key));
		#end
		
		if (FileSystem.exists(getSharedPath(key))) return File.getContent(getSharedPath(key));
		
		if (currentLevel != null)
		{
			var levelPath:String = '';
			if (currentLevel != 'shared')
			{
				levelPath = getLibraryPathForce(key, 'week_assets', currentLevel);
				if (FileSystem.exists(levelPath)) return File.getContent(levelPath);
			}
		}
		#end
		var path:String = getPath(key, TEXT);
		if (OpenFlAssets.exists(path, TEXT)) return Assets.getText(path);
		return null;
	}
	
	inline static public function font(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsFont(key);
		if (FileSystem.exists(file))
		{
			return file;
		}
		#end
		return 'assets/fonts/$key';
	}
	
	public static function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String = null)
	{
		#if MODS_ALLOWED
		if (!ignoreMods)
		{
			for (mod in Mods.getGlobalMods())
				if (FileSystem.exists(mods('$mod/$key'))) return true;
				
			if (FileSystem.exists(mods(Mods.currentModDirectory + '/' + key)) || FileSystem.exists(mods(key))) return true;
			
			if (FileSystem.exists(mods('$key'))) return true;
		}
		#end
		
		if (OpenFlAssets.exists(getPath(key, type, library, false)) || FileSystem.exists(getPath(key, type, library, false)))
		{
			return true;
		}
		return false;
	}
	
	static public function getAtlas(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var useMod = false;
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		var myXml:Dynamic = getPath('images/$key.xml', TEXT, library, true);
		if (OpenFlAssets.exists(myXml) #if MODS_ALLOWED || (FileSystem.exists(myXml) && (useMod = true)) #end)
		{
			#if MODS_ALLOWED
			return FlxAtlasFrames.fromSparrow(imageLoaded, (useMod ? File.getContent(myXml) : myXml));
			#else
			return FlxAtlasFrames.fromSparrow(imageLoaded, myXml);
			#end
		}
		return getPackerAtlas(key, library);
	}
	
	inline static public function getSparrowAtlas(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		#if MODS_ALLOWED
		var xmlExists:Bool = false;
		
		var xml:String = modsXml(key);
		if (FileSystem.exists(xml)) xmlExists = true;
		
		if (!xmlExists)
		{
			xml = getPath('images/$key.xml', library);
			if (FileSystem.exists(xml)) xmlExists = true;
		}
		
		return FlxAtlasFrames.fromSparrow(imageLoaded, (xmlExists ? File.getContent(xml) : getPath('images/$key.xml', library)));
		#else
		return FlxAtlasFrames.fromSparrow(imageLoaded, getPath('images/$key.xml', library));
		#end
	}
	
	inline static public function getPackerAtlas(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		#if MODS_ALLOWED
		var txtExists:Bool = false;
		
		var txt:String = modsTxt(key);
		if (FileSystem.exists(txt)) txtExists = true;
		
		return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, (txtExists ? File.getContent(txt) : getPath('images/$key.txt', library)));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, getPath('images/$key.txt', library));
		#end
	}
	
	inline static public function formatToSongPath(path:String)
	{
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;
		
		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}
	
	public static function returnSound(key:String, ?path:String)
	{
		var file = getPath('$key.$SOUND_EXT', SOUND, path, true);
		if (!currentTrackedSounds.exists(file))
		{
			if (FileSystem.exists(file)) currentTrackedSounds.set(file, Sound.fromFile(file));
		}
		
		localTrackedAssets.push(file);
		return currentTrackedSounds.get(file);
	}
	
	#if MODS_ALLOWED
	inline static public function mods(key:String = '')
	{
		return '$MODS_DIRECTORY/' + key;
	}
	
	inline static public function modsFont(key:String)
	{
		return modFolders('fonts/' + key);
	}
	
	inline static public function modsJson(key:String)
	{
		return modFolders('data/' + key + '.json');
	}
	
	inline static public function modsVideo(key:String)
	{
		return modFolders('videos/' + key + '.' + VIDEO_EXT);
	}
	
	inline static public function modsSounds(path:String, key:String)
	{
		return modFolders(path + '/' + key + '.' + SOUND_EXT);
	}
	
	inline static public function modsImages(key:String)
	{
		return modFolders('images/' + key + '.png');
	}
	
	inline static public function modsGifs(key:String)
	{
		return modFolders('images/' + key + '.gif');
	}
	
	inline static public function modsXml(key:String)
	{
		return modFolders('images/' + key + '.xml');
	}
	
	inline static public function modsTxt(key:String)
	{
		return modFolders('images/' + key + '.txt');
	}
	
	static public function modFolders(key:String)
	{
		if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
		{
			var fileToCheck:String = mods(Mods.currentModDirectory + '/' + key);
			if (FileSystem.exists(fileToCheck))
			{
				return fileToCheck;
			}
		}
		
		for (mod in Mods.getGlobalMods())
		{
			var fileToCheck:String = mods(mod + '/' + key);
			if (FileSystem.exists(fileToCheck)) return fileToCheck;
		}
		return '$MODS_DIRECTORY/' + key;
	}
	#end
	
	public static function loadAnimateAtlas(spr:FlxAnimate, folderOrImg:String, spriteJson:Dynamic = null, animationJson:Dynamic = null)
	{
		spr.frames = animate.FlxAnimateFrames.fromAnimate(Paths.getPath('images/$folderOrImg', BINARY, null, true), null, null, null, false, {cacheOnLoad: true});
	}
}
