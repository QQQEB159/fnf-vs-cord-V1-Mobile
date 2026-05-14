package states.minigames.rosiesim;

import haxe.Int64;

enum abstract Outfit(String) to String
{
	var ROSE = 'rosie';
	var SWIMSUIT_ROSE = 'swimsuitRosie';
	var ROSE_THE_BAT = 'roseTheBat';
	var ONESIE_ROSE = 'onesieRosie';
	var CORD = 'cord';
	var MIAU_CORD = 'miauCord';
	var ONESIE_CORD = 'onesieCord';
	
	var DATA_ROSE = 'data5Rosie';
	var INFRY_NOM = 'infrynom';
	var STARBEAR = 'star';
	var CROC = 'croc';
	var NOLIME = 'nolime';
	
	public inline function toString():String return cast this;
	
	public inline function getMult()
	{
		return switch (this)
		{
			case ROSE_THE_BAT | ONESIE_CORD: 2;
			default: 1;
		}
	}
	
	public inline function getAdditive()
	{
		return switch (this)
		{
			// case ROSE_THE_BAT: 1;
			// case ONESIE_ROSE: 5;
			case ONESIE_CORD: 6;
			default: 0;
		}
	}
	
	public inline function getOverTime()
	{
		return switch (this)
		{
			case SWIMSUIT_ROSE: 1;
			case ONESIE_ROSE: 5;
			case ONESIE_CORD: 6;
			default: 0;
		}
	}
	
	public static function toList():Array<Outfit> return [ROSE, SWIMSUIT_ROSE, ROSE_THE_BAT, ONESIE_ROSE, CORD, MIAU_CORD, ONESIE_CORD];
	
	public static function getDesc(outfit:Outfit):String
	{
		return switch (outfit)
		{
			case SWIMSUIT_ROSE: '500 Clicks\n+1 Clicks per Second';
			case ROSE_THE_BAT: '2,500 Clicks\n2X Click Rate';
			case ONESIE_ROSE: '5,000 Clicks\n+5 Clicks per Second';
			case CORD: '(Requires Onesie Rose)\n10,000 Clicks\n5% Chance to triple your Click Rate (5 Seconds)';
			case MIAU_CORD: '(Requires Cord)\n25,000\n0.5% Chance to Double your Click Amount';
			case ONESIE_CORD: '(Requires Miau Cord)\n100,000 Clicks\nAll Previous Modifiers Enabled';
			default: '';
		}
	}
	
	public function getCost():Int
	{
		return switch (this)
		{
			case SWIMSUIT_ROSE: 500;
			case ROSE_THE_BAT: 2500;
			case ONESIE_ROSE: 5000;
			case CORD: 10000;
			case MIAU_CORD: 25000;
			case ONESIE_CORD: 100000;
			default: 0;
		}
	}
	
	public function unlock():Void
	{
		Reflect.setField(FlxG.save.data, '_rClickerOutfit_${this.toString()}', true);
		FlxG.save.flush();
	}
	
	public function isLocked():Bool
	{
		if (this == ROSE) return false; // ur the default dum dum
		
		var save = Reflect.field(FlxG.save.data, '_rClickerOutfit_${this.toString()}');
		return save == null || save == false;
	}
	
	public function isCord():Bool return this.toLowerCase().contains('cord');
	
	public function toRpc()
	{
		return switch (this)
		{
			case ROSE: 'roseplush';
			case SWIMSUIT_ROSE: 'roseswimsuitplush';
			case ROSE_THE_BAT: 'rosethebatplush';
			case ONESIE_ROSE: 'roseonesieplush';
			case CROC: 'croc';
			case INFRY_NOM: 'infrynom';
			case CORD: 'cordplush';
			case MIAU_CORD: 'cordshirt';
			case ONESIE_CORD: 'cordonesie';
			case STARBEAR: 'starplush';
			case NOLIME: 'nolimeplush';
			default: 'roseplush';
		}
	}
}
