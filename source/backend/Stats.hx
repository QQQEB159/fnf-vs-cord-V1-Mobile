package backend;

import flixel.util.FlxStringUtil;

class Stats
{
	// maybe
	public static final instance:StatsData = new StatsData();
	
	static var statsFields:Null<Array<String>> = null;
	
	public static function loadStats()
	{
		statsFields ??= Type.getInstanceFields(StatsData);
		for (field in statsFields)
		{
			if (Reflect.hasField(FlxG.save.data, field))
			{
				Reflect.setField(instance, field, Reflect.field(FlxG.save.data, field));
			}
		}
	}
	
	public static function saveStats()
	{
		statsFields ??= Type.getInstanceFields(StatsData);
		for (field in statsFields)
		{
			var directField = Reflect.field(instance, field);
			if (!Reflect.isFunction(directField)) Reflect.setField(FlxG.save.data, field, directField);
		}
		
		#if ACHIEVEMENTS_ALLOWED
		if (instance.notesMissed >= 100) Achievements.unlock('miss100');
		if (instance.totalScore >= 1000000) Achievements.unlock('1mScore');
		#end
		// should it flush ?
		// probably
		
		FlxG.save.flush();
	}
	
	public static function addTime(v:Float)
	{
		instance.timePlayed += Math.floor(v);
		if (instance.timePlayed >= 21600) // 6 hours
		{
			Achievements.unlock('6hours');
		}
		
		// trace(instance.timePlayed);
		// saveStats();
	}
}

class StatsData
{
	public var timePlayed:Int = 0;
	
	public var totalDeaths:Int = 0;
	public var notesMissed:Int = 0;
	public var notesHit:Int = 0;
	public var bestCombo:Int = 0;
	public var songsPlayed:Int = 0;
	
	public var totalScore:Int = 0;
	public var totalSicks:Int = 0;
	public var totalGoods:Int = 0;
	public var totalBads:Int = 0;
	public var totalShits:Int = 0;
	
	public function new() {}
	
	public function toString()
	{
		inline function format(title:String, stat:String)
		{
			final totalLength = title.length + stat.length;
			
			var spacing = '';
			
			while ((spacing.length + totalLength) < 32)
			{
				spacing = spacing + ' ';
			}
			
			return title + spacing + stat;
		}
		
		var buff = new StringBuf();
		
		buff.add(format('Total Score:', '${FlxStringUtil.formatMoney(totalScore, false)}\n'));
		buff.add(format('Blueballed:', '$totalDeaths\n'));
		buff.add(format('Songs Played:', '$songsPlayed\n'));
		buff.add(format('Best Combo:', '$bestCombo\n'));
		buff.add(format('Notes Hit:', '$notesHit\n'));
		buff.add(format('Notes Missed:', '$notesMissed\n'));
		buff.add(format('Achievements Unlocked:', '${Achievements.achievementsUnlocked.length}/${Lambda.count(Achievements.achievements)}\n'));
		
		return buff.toString();
	}
}
