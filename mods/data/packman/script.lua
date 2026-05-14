uiX = 85
uiY = 250

if downscroll then
	uiY = 0
end

runHaxeCode([[

	game.endCallback = ()->{
		import options.OptionsState;

		saveProgression();

		FlxG.sound.music.volume = 0;
		FlxG.switchState(() -> new OptionsState());
	}
]])


setProperty('skipCountdown', true)

function onSpawnNote(index, noteData, noteType, isSustain, strumTime)
	runHaxeCode([[
		notes.members[0].cameras = [getVar('camHUD2')];
	]])

end

-- function onSpawnNote()

--     setObjectCamera('notes.members[0]', 'game')
--     callMethod('notes.members[0].scrollFactor.set', {1, 1})
-- 	scaleObject('notes.members[0]', 1, 1)
-- end

-- TO DO: fixing the scale of the notes and putting them behind bf and packman
-- also it would be nice if this song had a vcr shader

-- reminder when i wake up to hide the bar that goes behind the notes in this stage as its useless
-- hi rose

-- hi

local e = 0
function onUpdatePost(elapsed)
	setProperty('camHUD2.zoom', getProperty('camHUD.zoom'))
	callMethod('vhsShader.setFloat', {'iTime', e})
	e = e + elapsed
end

function onDestroy()
	runHaxeCode([[
		FlxG.game.setFilters([]);
	]])
end

function onCreatePost()

	setProperty('noteUnderlay.visible', false)
	runHaxeCode([[
		import flixel.FlxCamera;
		import openfl.filters.ShaderFilter;

		var cam = new FlxCamera();
		FlxG.cameras.insert(cam, 0, false);

		for (i in 0...playerStrums.length)
		{	
			var spr = playerStrums.members[i];
			spr.cameras = [cam];

			var x = -278;
			spr.x = x;
			spr.postAddedToGroup();
		}

		FlxG.camera.bgColor = 0x0;

		setVar('camHUD2', cam);

		//shdaer stuff
		// var shader = createRuntimeShader('vhs');
		// if (ClientPrefs.data.shaders)
		// {
		// 	FlxG.game.setFilters([new ShaderFilter(shader)]);
		// }
		// setVar('vhsShader', shader);
	]])

	for i = 0, 3 do
		setPropertyFromGroup('strumLineNotes',i,'x', -500) -- hide opponent notes
	
		-- setObjectCamera('playerStrums.members['.. i ..']', 'game') -- camGame
        -- callMethod('playerStrums.members['.. i ..'].scrollFactor.set', {1, 1}) -- scroll factor
		-- scaleObject('playerStrums.members['..i..']', 1, 1) -- size
		
		-- setPropertyFromGroup('playerStrums', i, 'x', 420 + (160 * (i % 4))) -- x
		
		if downscroll then
			setPropertyFromGroup('playerStrums', i, 'y', screenHeight - 160)
		end
	end

	setProperty('camDisplacement', 0)
	setProperty('bar_upper.alpha', 0)
	setProperty('bar_lower.alpha', 0)
	
	setProperty('defaultCamZoom', 0.6)
	doTweenZoom('zoom', 'camGame', 0.6, 0.001, 'linear')
	
	setProperty('dad.cameraPosition', {170, 95})
	setProperty('gfGroup.visible', false)
	
	setProperty('dad.x', 300)
	
	setProperty('boyfriend.x', 810)
	setProperty('boyfriend.y', 300)
	
	makeLuaSprite('bg', 'stages/atari/packman', -200, -300)
	addLuaSprite('bg', false)
	
	makeLuaSprite('screen', 'stages/atari/screen', 200, -300)
	setBlendMode('screen', 'screen')
	addLuaSprite('screen', true)
	
	-- ui
	
	setProperty('iconP1.cameras', 'camGame')
	setProperty('iconP2.cameras', 'camGame')
	setProperty('healthBar.cameras', 'camGame')
	setProperty('scoreTxt.cameras', 'camGame')
	
	setProperty('scoreTxt.cameras', 'camGame')
	
	setTextFont('scoreTxt', 'VGA.ttf')
	
	setProperty('healthBar.y', getProperty('healthBar.y') + uiY);
	setProperty('iconP1.y', getProperty('iconP1.y') + uiY);
	setProperty('iconP2.y', getProperty('iconP2.y') + uiY);
	setProperty('scoreTxt.y', getProperty('scoreTxt.y') + uiY + 30);
	
	setProperty('healthBar.x', getProperty('healthBar.x') + uiX);
	setProperty('iconP1.x', getProperty('iconP1.x') + uiX);
	setProperty('iconP2.x', getProperty('iconP2.x') + uiX);
	setProperty('scoreTxt.x', getProperty('scoreTxt.x') + uiX);

	setProperty('camZoomingMult', 0)
end

  beatHitFuncs = {
	[32] = function() setProperty('camZoomingMult', 1) end,
	
	[65] = function() setProperty('camZoomingMult', 0) end,
	
	[80] = function() setProperty('camZoomingMult', 1) end,
	
	[144] = function() setProperty('camZoomingMult', 0) end,
}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	end
end