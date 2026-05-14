function onCreatePost()

	makeLuaSprite('ground', 'stages/weekcord/old/oldstage', -310, -70)
	addLuaSprite('ground', false)
	
	setProperty('bar_upper.alpha', 0)
	setProperty('bar_lower.alpha', 0)
	setProperty('camDisplacement', 0)
	runHaxeCode([[game.iconP1.changeIcon("bf-old")]]) -- lol
	setHealthBarColors('F32A16', '16FF26');
end

-- god damnit
runHaxeCode([[

	game.endCallback = ()->{
		import options.OptionsState;

		saveProgression();

		FlxG.sound.music.volume = 0;
		FlxG.switchState(() -> new OptionsState());
	}
]])