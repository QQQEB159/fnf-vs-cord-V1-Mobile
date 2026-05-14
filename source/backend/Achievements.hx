package backend;

#if ACHIEVEMENTS_ALLOWED
import objects.AchievementPopup;

import haxe.Exception;
import haxe.Json;

#if LUA_ALLOWED
import psychlua.FunkinLua;
#end

typedef Achievement =
{
	var name:String;
	var description:String;
	
	@:optional var textColour:Int;
	
	@:optional var hidden:Bool;
	@:optional var maxScore:Float;
	@:optional var maxDecimals:Int;
	
	// handled automatically, ignore these two
	@:optional var mod:String;
	@:optional var ID:Int;
	
	@:optional var gradColour1:Int;
	@:optional var gradColour2:Int;
}

class Achievements
{
	public static function init()
	{
		// perfecto
		createAchievement('weekCord_nomiss',
			{
				name: "Alright, now leave!",
				description: "Beat Cord's week on hard difficulty without missing.",
				textColour: 0xFF6DE4FE,
				gradColour1: 0xFF7DCDD1,
				gradColour2: 0xFF4787BD
			}); // done
		createAchievement('weekParty_nomiss',
			{
				name: "That Was Pretty Pawsome!",
				description: "Beat Kitty Battle on hard difficulty without missing.",
				textColour: 0xFFFE69EE,
				gradColour1: 0xFFB67AFA,
				gradColour2: 0xFF414EA0
			}); // done
		createAchievement('djSideQuest_nomiss',
			{
				name: "Rythmatic Maniac",
				description: "Beat Dj's week on hard difficulty without missing.",
				textColour: 0xFFB1FE44,
				gradColour1: 0xFFD0DE89,
				gradColour2: 0xFF448E56
			}); // done
		createAchievement('catSideQuest_nomiss',
			{
				name: "INTRUDER ALERT",
				description: "Beat Cat's week on hard difficulty without missing.",
				textColour: 0xFFFEA852,
				gradColour1: 0xFFE7A560,
				gradColour2: 0xFFBE7067
			}); // done
		createAchievement('pRank',
			{
				name: "Go for a Perfect!",
				description: "Complete a song without missing.",
				textColour: 0xFFFF5CF5,
				gradColour1: 0xFF8A4BF3,
				gradColour2: 0xFF791CA5
			}); // done
		createAchievement('goldenPRank',
			{
				name: "Lol now what",
				description: "Complete a Song with a rating of 100%.",
				textColour: 0xFFFF9C00,
				gradColour1: 0xFF782307,
				gradColour2: 0xFFFFC824
			}); // done
			
		// misc
		createAchievement('blueBalled10',
			{
				name: "That's 10 Times Too Many",
				description: "Blue ball 10 times.",
				textColour: 0xFF933742,
				gradColour1: 0xFF1E1D30,
				gradColour2: 0xFF563043
			}); // done
		createAchievement('miss100',
			{
				name: "Target Practice",
				description: "Miss 100+ notes.",
				textColour: 0xFF323849,
				gradColour1: 0xFF436565,
				gradColour2: 0xFF354357
			}); // done
		createAchievement('menuMusic',
			{
				name: "That's More Like It!",
				description: "Change the menu music.",
				textColour: 0xFF955DFC,
				gradColour1: 0xFF605974,
				gradColour2: 0xFF262741
			}); // done
		createAchievement('NG',
			{
				name: "Probably Associated With",
				description: "Log into your Newgrounds account.",
				textColour: 0xFFFE8125,
				gradColour1: 0xFF231E1F,
				gradColour2: 0xFF824322
			});
		createAchievement('1mScore',
			{
				name: "The Top 1%",
				description: "Reach 1,000,000 score.",
				textColour: 0xFFB66753,
				gradColour1: 0xFF9A44C8,
				gradColour2: 0xFFC9884F
			}); // done
		createAchievement('6hours',
			{
				name: "Way Too Much Free Time",
				description: "Spend 6+ hours on Vs Cord.",
				textColour: 0xFF472A1D,
				gradColour1: 0xFF52423C,
				gradColour2: 0xFF302123
			}); // done
		createAchievement('20percent',
			{
				name: "What a Disaster",
				description: "Complete a Song with a rating lower than 20%.",
				textColour: 0xFF474399,
				gradColour1: 0xFF454195,
				gradColour2: 0xFF19213E
			}); // done
		createAchievement('friday',
			{
				name: "Guys its like  its like th",
				description: "Play Vs Cord on a Friday... Night.",
				textColour: 0xFF0A72CA,
				gradColour1: 0xFF0977CD,
				gradColour2: 0xFF0C229B
			}); // done
			
		// minigame shit
		createAchievement('100rounds',
			{
				name: "One More Game!",
				description: "Reach 100 rounds in the \"Wanted\" minigame.",
				textColour: 0xFF3298CB,
				gradColour1: 0xFF50233F,
				gradColour2: 0xFF261322
			}); // done
		createAchievement('modifier',
			{
				name: "Overstimulating",
				description: "Have a round with every modifier in the \"Wanted\" minigame.",
				textColour: 0xFFFE00FE,
				gradColour1: 0xFF002F4E,
				gradColour2: 0xFFDA9093
			}); // done
		createAchievement('50kScore',
			{
				name: "On A Roll",
				description: "Reach 50,000 score in the \"Wanted\" minigame.",
				textColour: 0xFFCBAA25,
				gradColour1: 0xFF6B5918,
				gradColour2: 0xFFCCAB26
			}); // done
			
		createAchievement('50kClicks',
			{
				name: "I Can't Stop...",
				description: "Get 50,000 clicks in total in \"Rosie Clicker\".",
				textColour: 0xFFC1A5CB,
				gradColour1: 0xFFC2A6CC,
				gradColour2: 0xFFB694C1
			}); // done
		createAchievement('unlockCord',
			{
				name: "Uh Oh! Next Level!",
				description: "Unlock Cord in \"Rosie Clicker\".",
				textColour: 0xFFE9C5DC,
				gradColour1: 0xFFEAC6DD,
				gradColour2: 0xFFBF5FA1
			}); // done
		createAchievement('unlockAll',
			{
				name: "Reaching Nirvana",
				description: "Unlock every plushie in \"Rosie Clicker\".",
				textColour: 0xFF90BDBE,
				gradColour1: 0xFF96BDC7,
				gradColour2: 0xFF77809F
			}); // done
			
		// createAchievement('week1_nomiss', {name: "She Calls Me Daddy Too", description: "Beat Week 1 on Hard with no Misses."});
		// createAchievement('week2_nomiss', {name: "No More Tricks", description: "Beat Week 2 on Hard with no Misses."});
		// createAchievement('week3_nomiss', {name: "Call Me The Hitman", description: "Beat Week 3 on Hard with no Misses."});
		// createAchievement('week4_nomiss', {name: "Lady Killer", description: "Beat Week 4 on Hard with no Misses."});
		// createAchievement('week5_nomiss', {name: "Missless Christmas", description: "Beat Week 5 on Hard with no Misses."});
		// createAchievement('week6_nomiss', {name: "Highscore!!", description: "Beat Week 6 on Hard with no Misses."});
		// createAchievement('week7_nomiss', {name: "God Effing Damn It!", description: "Beat Week 7 on Hard with no Misses."});
		// createAchievement('ur_bad', {name: "What a Funkin' Disaster!", description: "Complete a Song with a rating lower than 20%."});
		// createAchievement('ur_good', {name: "Perfectionist", description: "Complete a Song with a rating of 100%."});
		// createAchievement('roadkill_enthusiast',
		// 	{
		// 		name: "Roadkill Enthusiast",
		// 		description: "Watch the Henchmen die 50 times.",
		// 		maxScore: 50,
		// 		maxDecimals: 0
		// 	});
		// createAchievement('oversinging', {name: "Oversinging Much...?", description: "Hold down a note for 10 seconds."});
		// createAchievement('hype', {name: "Hyperactive", description: "Finish a Song without going Idle."});
		// createAchievement('two_keys', {name: "Just the Two of Us", description: "Finish a Song pressing only two keys."});
		// createAchievement('toastie', {name: "Toaster Gamer", description: "Have you tried to run the game on a toaster?"});
		// createAchievement('debugger', {name: "Debugger", description: "Beat the \"Test\" Stage from the Chart Editor.", hidden: true});
		
		// dont delete this thing below
		_originalLength = _sortID + 1;
	}
	
	public static var achievements:Map<String, Achievement> = new Map<String, Achievement>();
	public static var variables:Map<String, Float> = [];
	public static var achievementsUnlocked:Array<String> = [];
	private static var _firstLoad:Bool = true;
	
	public static function get(name:String):Achievement return achievements.get(name);
	
	public static function exists(name:String):Bool return achievements.exists(name);
	
	public static function load():Void
	{
		if (!_firstLoad) return;
		
		if (_originalLength < 0) init();
		
		if (FlxG.save.data != null)
		{
			if (FlxG.save.data.achievementsUnlocked != null) achievementsUnlocked = FlxG.save.data.achievementsUnlocked;
			
			achievementsUnlocked ??= []; // ???
			
			trace(achievementsUnlocked);
			
			var savedMap:Map<String, Float> = cast FlxG.save.data.achievementsVariables;
			if (savedMap != null)
			{
				for (key => value in savedMap)
				{
					variables.set(key, value);
				}
			}
			_firstLoad = false;
		}
	}
	
	public static function save():Void
	{
		FlxG.save.data.achievementsUnlocked = achievementsUnlocked;
		FlxG.save.data.achievementsVariables = variables;
	}
	
	public static function getScore(name:String):Float return _scoreFunc(name, 0);
	
	public static function setScore(name:String, value:Float, saveIfNotUnlocked:Bool = true):Float return _scoreFunc(name, 1, value, saveIfNotUnlocked);
	
	public static function addScore(name:String, value:Float = 1, saveIfNotUnlocked:Bool = true):Float return _scoreFunc(name, 2, value, saveIfNotUnlocked);
	
	// mode 0 = get, 1 = set, 2 = add
	static function _scoreFunc(name:String, mode:Int = 0, addOrSet:Float = 1, saveIfNotUnlocked:Bool = true):Float
	{
		if (!variables.exists(name)) variables.set(name, 0);
		
		if (achievements.exists(name))
		{
			var achievement:Achievement = achievements.get(name);
			if (achievement.maxScore < 1) throw new Exception('Achievement has score disabled or is incorrectly configured: $name');
			
			if (achievementsUnlocked.contains(name)) return achievement.maxScore;
			
			var val = addOrSet;
			switch (mode)
			{
				case 0:
					return variables.get(name); // get
				case 2:
					val += variables.get(name); // add
			}
			
			if (val >= achievement.maxScore)
			{
				unlock(name);
				val = achievement.maxScore;
			}
			variables.set(name, val);
			
			Achievements.save();
			if (saveIfNotUnlocked || val >= achievement.maxScore) FlxG.save.flush();
			return val;
		}
		return -1;
	}
	
	static var _lastUnlock:Int = -999;
	
	public static function unlock(name:String, autoStartPopup:Bool = true):String
	{
		if (!achievements.exists(name))
		{
			FlxG.log.error('Achievement "$name" does not exists!');
			throw new Exception('Achievement "$name" does not exists!');
			return null;
		}
		
		// data todo uncomment this later.
		if (Achievements.isUnlocked(name)) return null;
		
		trace('Completed achievement "$name"');
		achievementsUnlocked.push(name);
		
		// earrape prevention
		var time:Int = openfl.Lib.getTimer();
		if (Math.abs(time - _lastUnlock) >= 100) // If last unlocked happened in less than 100 ms (0.1s) ago, then don't play sound
		{
			FlxG.sound.play(Paths.sound('achievementUnlocked'), 0.5);
			_lastUnlock = time;
		}
		
		Achievements.save();
		FlxG.save.flush();
		
		if (autoStartPopup) startPopup(name);
		return name;
	}
	
	inline public static function isUnlocked(name:String) return achievementsUnlocked.contains(name);
	
	@:allow(objects.AchievementPopup)
	private static var _popups:Array<AchievementPopup> = [];
	
	public static var showingPopups(get, never):Bool;
	
	public static function get_showingPopups() return _popups.length > 0;
	
	public static function startPopup(achieve:String, endFunc:Void->Void = null)
	{
		for (popup in _popups)
		{
			if (popup == null) continue;
			popup.intendedY -= AchievementPopup.HEIGHT;
		}
		
		var newPop:AchievementPopup = new AchievementPopup(achieve, endFunc);
		_popups.push(newPop);
		// trace('Giving achievement ' + achieve);
	}
	
	// Map sorting cuz haxe is physically incapable of doing that by itself
	static var _sortID = 0;
	static var _originalLength = -1;
	
	public static function createAchievement(name:String, data:Achievement, ?mod:String = null)
	{
		data.ID = _sortID;
		data.mod = mod;
		achievements.set(name, data);
		_sortID++;
	}
	
	#if MODS_ALLOWED
	public static function reloadList()
	{
		// remove modded achievements
		if ((_sortID + 1) > _originalLength) for (key => value in achievements)
			if (value.mod != null) achievements.remove(key);
			
		_sortID = _originalLength - 1;
		
		var modLoaded:String = Mods.currentModDirectory;
		Mods.currentModDirectory = null;
		loadAchievementJson(Paths.mods('data/achievements.json'));
		for (i => mod in Mods.parseList().enabled)
		{
			Mods.currentModDirectory = mod;
			loadAchievementJson(Paths.mods('$mod/data/achievements.json'));
		}
		Mods.currentModDirectory = modLoaded;
	}
	
	inline static function loadAchievementJson(path:String, addMods:Bool = true)
	{
		var retVal:Array<Dynamic> = null;
		if (FileSystem.exists(path))
		{
			try
			{
				var rawJson:String = File.getContent(path).trim();
				if (rawJson != null && rawJson.length > 0) retVal = tjson.TJSON.parse(rawJson); // Json.parse('{"achievements": $rawJson}').achievements;
				
				if (addMods && retVal != null)
				{
					for (i in 0...retVal.length)
					{
						var achieve:Dynamic = retVal[i];
						if (achieve == null)
						{
							var errorTitle = 'Mod name: ' + Mods.currentModDirectory != null ? Mods.currentModDirectory : "None";
							var errorMsg = 'Achievement #${i + 1} is invalid.';
							#if windows
							lime.app.Application.current.window.alert(errorMsg, errorTitle);
							#end
							trace('$errorTitle - $errorMsg');
							continue;
						}
						
						var key:String = achieve.save;
						if (key == null || key.trim().length < 1)
						{
							var errorTitle = 'Error on Achievement: ' + (achieve.name != null ? achieve.name : achieve.save);
							var errorMsg = 'Missing valid "save" value.';
							#if windows
							lime.app.Application.current.window.alert(errorMsg, errorTitle);
							#end
							trace('$errorTitle - $errorMsg');
							continue;
						}
						key = key.trim();
						if (achievements.exists(key)) continue;
						
						createAchievement(key, achieve, Mods.currentModDirectory);
					}
				}
			}
			catch (e:Dynamic)
			{
				var errorTitle = 'Mod name: ' + Mods.currentModDirectory != null ? Mods.currentModDirectory : "None";
				var errorMsg = 'Error loading achievements.json: $e';
				#if windows
				lime.app.Application.current.window.alert(errorMsg, errorTitle);
				#end
				trace('$errorTitle - $errorMsg');
			}
		}
		return retVal;
	}
	
	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State)
	{
		Lua_helper.add_callback(lua, "getAchievementScore", function(name:String):Float {
			if (!achievements.exists(name))
			{
				FunkinLua.luaTrace('getAchievementScore: Couldnt find achievement: $name', false, false, FlxColor.RED);
				return -1;
			}
			return getScore(name);
		});
		Lua_helper.add_callback(lua, "setAchievementScore", function(name:String, ?value:Float = 1, ?saveIfNotUnlocked:Bool = true):Float {
			if (!achievements.exists(name))
			{
				FunkinLua.luaTrace('setAchievementScore: Couldnt find achievement: $name', false, false, FlxColor.RED);
				return -1;
			}
			return setScore(name, value, saveIfNotUnlocked);
		});
		Lua_helper.add_callback(lua, "addAchievementScore", function(name:String, ?value:Float = 1, ?saveIfNotUnlocked:Bool = true):Float {
			if (!achievements.exists(name))
			{
				FunkinLua.luaTrace('addAchievementScore: Couldnt find achievement: $name', false, false, FlxColor.RED);
				return -1;
			}
			return addScore(name, value, saveIfNotUnlocked);
		});
		Lua_helper.add_callback(lua, "unlockAchievement", function(name:String):Dynamic {
			if (!achievements.exists(name))
			{
				FunkinLua.luaTrace('unlockAchievement: Couldnt find achievement: $name', false, false, FlxColor.RED);
				return null;
			}
			return unlock(name);
		});
		Lua_helper.add_callback(lua, "isAchievementUnlocked", function(name:String):Dynamic {
			if (!achievements.exists(name))
			{
				FunkinLua.luaTrace('isAchievementUnlocked: Couldnt find achievement: $name', false, false, FlxColor.RED);
				return null;
			}
			return isUnlocked(name);
		});
		Lua_helper.add_callback(lua, "achievementExists", function(name:String) return achievements.exists(name));
	}
	#end
	#end
}
#end
