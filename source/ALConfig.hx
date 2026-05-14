package;

import haxe.io.Path;

@:keepInit class ALConfig
{
	public static function __init__():Void
	{
		#if (desktop && !hl)
		var configPath:String = Path.directory(Path.withoutExtension(Sys.programPath()));
		
		#if windows
		configPath += "/plugins/alsoft.ini";
		#elseif mac
		configPath = Path.directory(configPath) + "/Resources/plugins/alsoft.conf";
		#else
		configPath += "/plugins/alsoft.conf";
		#end
		
		Sys.putEnv("ALSOFT_CONF", configPath);
		#end
	}
}
