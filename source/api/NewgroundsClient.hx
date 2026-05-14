package api;

import io.newgrounds.Call.CallError;
import io.newgrounds.objects.events.Outcome;

import flixel.FlxG;

import haxe.io.Bytes;

import openfl.display.BitmapData;

import flixel.FlxSprite;

import io.newgrounds.components.MedalComponent;
import io.newgrounds.utils.MedalList.ExternalMedalList;
import io.newgrounds.utils.MedalList.ExternalMedal;
import io.newgrounds.NGLite.LoginOutcome;
import io.newgrounds.NG;

using DateTools;

class NewgroundsClient
{
	public static var sessionData:Null<NewgroundsSessionData> = null;
	public static var active:Bool = false;
	
	public static function initCore()
	{
		if (NG.core != null) return;
		final sessionID:Null<String> = FlxG.save.data.__usersNGID ?? null;
		
		NG.create('test', sessionID, false, (rq:LoginOutcome) -> onLogReq(rq));
		
		makeSessionData();
	}
	
	static function makeSessionData()
	{
		if (NG.core == null) return;
		final userName = NG.core.user?.name;
		final isSupporter = NG.core.user?.supporter;
		
		sessionData = {sessionDate: Date.now(), sessionID: NG.core.sessionId, userData: {name: userName, isSupporter: isSupporter}};
	}
	
	public static function newgroundsLogin(?onComplete:(outcome:LoginOutcome) -> Void):Void
	{
		initCore();
		if (NG.core.attemptingLogin) return;
		
		NG.core.requestLogin((rq:LoginOutcome) -> {
			onLogReq(rq, onComplete);
		});
	}
	
	static function onLogReq(rq:LoginOutcome, ?onComplete:(outcome:LoginOutcome) -> Void)
	{
		active = rq == SUCCESS;
		
		switch (rq)
		{
			case SUCCESS:
				FlxG.save.data.__usersNGID = NG.core.sessionId;
				FlxG.save.flush();
				
				#if ACHIEVEMENTS_ALLOWED
				Achievements.unlock('NG');
				#end
				
				makeSessionData();
				
			default:
		}
		if (onComplete != null) onComplete(rq);
	}
	
	public static function logOut(?onComplete:(outcome:Outcome<CallError>) -> Void)
	{
		if (NG.core == null) return;
		
		NG.core.logOut(onComplete);
		active = false;
		sessionData = null;
		FlxG.save.data.__usersNGID = null;
		FlxG.save.flush();
	}
}

typedef NewgroundsSessionData =
{
	sessionDate:Date,
	sessionID:String,
	userData:
	{
		?name:String, ?isSupporter:Bool
	}
}
