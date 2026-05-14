local arrText = 'noteSkins/NOTE_assets-atari' 

runHaxeCode([[
	game.endCallback = ()->{
		import options.OptionsState;

		saveProgression();

		FlxG.sound.music.volume = 0;
		FlxG.switchState(() -> new OptionsState());
	}
]])

function onCreatePost()
	setProperty('camDisplacement', 0)
	setProperty('strumLineNotes.visible', false)
	setProperty('gf.visible', false)

	if arrText ~= nil then
		for i = 0, getProperty('strumLineNotes.length') - 1 do
			setPropertyFromGroup('strumLineNotes', i, 'texture', arrText)
		end

		for i = 0, getProperty('unspawnNotes.length') - 1 do
			if getPropertyFromGroup('unspawnNotes', i, 'noteType') == '' then
				setPropertyFromGroup('unspawnNotes', i, 'texture', arrText)
				setPropertyFromGroup('unspawnNotes', i, 'noteSplashData.texture', 'noteSplashes/noteSplashes-atari')
			end
		end
	end

	local strumY = 170

	if downscroll then
		strumY = 422
	end

	for i = 0, 7 do
		setPropertyFromGroup('playerStrums', i, 'x', 640 + (40 * (i % 4)))
		setPropertyFromGroup('playerStrums', i, 'y', strumY)
		setPropertyFromGroup('opponentStrums', i, 'x', 415 + (40 * (i % 4)))
		setPropertyFromGroup('opponentStrums', i, 'y', strumY + 10)
	end

	if flashingLights then
		runHaxeCode([[import flixel.effects.FlxFlicker;
			FlxFlicker.flicker(game.dad, 9999, 0.01, false, true);
			FlxFlicker.flicker(game.gf, 9999, 0.01, false, true);
		]])
	end
end

scales = {'strumLineNotes', 'unspawnNotes', 'grpNoteSplashes',...}

function onUpdate(e)
	for i = 0,7 do
		for _, obj in ipairs(scales) do
			setPropertyFromGroup(obj, i, 'scale.x', 0.25)
			setPropertyFromGroup(obj, i, 'scale.y', 0.25)
		end
	end
end

function onBeatHit()
	setProperty('camZooming', false)
end