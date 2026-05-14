class WiiPopup extends MusicBeatState
{
	//
	override function create()
	{
		super.create();
		
		FlxG.camera.bgColor = FlxColor.WHITE;
		
		var spr = new FlxSprite(0, 0, Paths.image('menuassets/secret/wiiSafetyPopup'));
		add(spr);
		spr.alpha = 0;
		
		FlxTimer.wait(1.75, () -> {
			FlxG.sound.play(Paths.sound('secret/wiiSafetyBloop'));
		});
		
		FlxTween.tween(spr, {alpha: 1}, 1,
			{
				startDelay: 0.4,
				onComplete: Void -> {
					FlxG.camera.bgColor = FlxColor.BLACK;
					FlxTween.tween(spr, {alpha: 0}, 1,
						{
							startDelay: 3,
							onComplete: Void -> {
								FlxG.switchState(Main.getFirstState());
							}
						});
				}
			});
	}
}
