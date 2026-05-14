local seenDialogue = false
local seenCameraMove = false

if isStoryMode then
	cordFallingCutscene = true
else
	cordFallingCutscene = false
end

local healthDecrease = false -- doing this because theres an invisible note at the start of the level

function onStartCountdown()
	-- Block the first countdown and start a timer of 0.8 seconds to play the dialogue

	if isStoryMode and not seenCutscene then

		if not seenDialogue then
			setProperty('inCutscene', true)
			runTimer('startDialogue', 0.8)

			seenDialogue = true

			return Function_Stop
		elseif not seenCameraMove then
			setProperty('camFollow.x', getProperty('camFollow.x') - 700, 50)
			setProperty('camFollow.y', getProperty('camFollow.y') - 500, 50)
			setProperty('inCutscene', true)
			runTimer('startLevel', 0.8)		
			runTimer('zoomTweenIntro', 0.7)

			seenCameraMove = true

			return Function_Stop
		end

		return Function_Continue
	end

	return Function_Continue
end

local arcadeBG = false
function onCreate()
	if isStoryMode then
		setProperty('dad.cameraPosition', {420, 320})
	else 
		setProperty('dad.cameraPosition', {270, 350})
	end

	precacheSound('cordFall')
	setProperty('building3.visible', true)
	setProperty('closebuildings3.visible', true)
	
	if not lowQuality then
		setProperty('nightTint.visible', true)
		
		makeLuaSprite('tint', 'stages/weekcord/tint', -650, -300)
		setLuaSpriteScrollFactor('tint', 0.9, 0.9)
		scaleObject('tint', 2, 1)
		setProperty('tint.alpha', 1)
		setBlendMode('tint', 'add')
		addLuaSprite('tint', true)
	end
	
	-- arcade bg
	makeLuaSprite('abg', 'stages/weekcord/arcade/bg', -680, -650)
	setLuaSpriteScrollFactor('abg', 0.95, 0.95)
	scaleObject('abg', 0.9, 0.9)
	addLuaSprite('abg', false)
	
	makeAnimatedLuaSprite('machines', 'stages/weekcord/arcade/machines', 100, -100)
	luaSpriteAddAnimationByPrefix('machines', 'idle', 'silly arcade stuff instance 1', 2, true)
	setLuaSpriteScrollFactor('machines', 0.95, 0.95)
	addLuaSprite('machines', false)
	
	if not lowQuality then
		makeAnimatedLuaSprite('booQueen', 'stages/weekcord/arcade/booQueen', 1070, 30)
		luaSpriteAddAnimationByPrefix('booQueen', 'idle', 'booque instance 1', 24, true)
		setLuaSpriteScrollFactor('booQueen', 0.95, 0.95)
		scaleObject('booQueen', 0.9, 0.9)
		setProperty('booQueen.alpha', 0.9)
		addLuaSprite('booQueen', false)
		
		makeAnimatedLuaSprite('mash', 'stages/weekcord/arcade/mash', -150, 50)
		luaSpriteAddAnimationByPrefix('mash', 'idle', 'mashidle instance 1', 24, true)
		setLuaSpriteScrollFactor('mash', 0.9, 0.9)
		addLuaSprite('mash', false)
		
		makeAnimatedLuaSprite('whatTheLoggo', 'stages/weekcord/arcade/whatTheLoggo', -300, 400)
		luaSpriteAddAnimationByPrefix('whatTheLoggo', 'idle', 'loggoandsign instance 1', 24, true)
		setLuaSpriteScrollFactor('whatTheLoggo', 0.9, 0.9)
		addLuaSprite('whatTheLoggo', false)
	end
	
	makeAnimatedLuaSprite('foreground', 'stages/weekcord/arcade/foreground', -900, -50)
	luaSpriteAddAnimationByPrefix('foreground', 'idle', 'fg arcades instance 1', 3, true)
	setLuaSpriteScrollFactor('foreground', 1.2, 1.2)
	addLuaSprite('foreground', true)
	
	if not lowQuality then
		makeLuaSprite('arcadeOverlay', 'stages/weekcord/nightoverlay', -700, -310)
		setLuaSpriteScrollFactor('arcadeOverlay', 0.97, 0.97)
		setProperty('arcadeOverlay.alpha', 0.3)
		setBlendMode('arcadeOverlay', 'difference')
		scaleObject('arcadeOverlay', 2.5, 2)
		addLuaSprite('arcadeOverlay', true)
	end
end

function onCreatePost()
	setProperty('tree.color',FlxColor('#6E6EAD'))
end

function onUpdate()
	if arcadeBG == true then
		setProperty('building3.visible', false)
		setProperty('closebuildings3.visible', false)
		setProperty('bg.visible', false)

		setProperty('tree.visible', false)
		setProperty('chair.visible', false)
		setProperty('boombox.visible', false)
		
		setProperty('abg.visible', true)
		setProperty('machines.visible', true)
		setProperty('foreground.visible', true)
		
		if not lowQuality then
			setProperty('booQueen.visible', true)
			setProperty('mash.visible', true)
			setProperty('whatTheLoggo.visible', true)
			setProperty('arcadeOverlay.visible', true)
			setProperty('nightTint.visible', false)
		end
	else
		setProperty('building3.visible', true)
		setProperty('closebuildings3.visible', true)
		setProperty('bg.visible', true)
		setProperty('tree.visible', true)
		setProperty('chair.visible', true)
		setProperty('boombox.visible', true)
		
		setProperty('abg.visible', false)
		setProperty('machines.visible', false)
		setProperty('foreground.visible', false)
		
		if not lowQuality then
			setProperty('nightTint.visible', true)
			setProperty('booQueen.visible', false)
			setProperty('mash.visible', false)
			setProperty('whatTheLoggo.visible', false)
			setProperty('arcadeOverlay.visible', false)
		end
	end
end

function onSongStart()
	cancelTween('zoomTween')
end
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'kitty-days')
	end
		
	if tag == 'zoomTweenIntro' then
		doTweenZoom('zoomTween', 'camGame', 0.7, 3, 'smootherStepInOut')	
	end
	
	if tag == 'startLevel' then
		startCountdown()
		setProperty('dad.cameraPosition', {270, 350})
	end
	
	if tag == 'stayZoomEnd' then
		setProperty('defaultCamZoom', 0.55)
	end
	
	if tag == 'endSong' then
		-- cordFallingCutscene = false

		realExit()
		

	end
end

function opponentNoteHit()
	health = getProperty('health')
	
	if healthDecrease == true then
		if getProperty('health') > 0.5 then
			setProperty('health', health- 0.010)
		end
	end
end

  beatHitFuncs = {
	[1] = function()
		doTweenAlpha('hudAlpha', 'camHUD', 0, 0.4, 'linear')
	end,
	
	[4] = function()
		doTweenAlpha('hudAlpha', 'camHUD', 1, 2, 'linear')
		triggerEvent('Alt Idle Animation', 'dad', '-alt')
		setProperty('dad.cameraPosition', {270, 350})
	end,
	
	[17] = function()
		doTweenZoom('startZoom', 'camGame', 1, 2, 'smootherStepIn')
		healthDecrease = true
	end,
	
	[20] = function()
		cancelTween('startZoom')
		setProperty('defaultCamZoom', 0.6)
	end,
	
	[22] = function()
		setProperty('peekaboo.visible', true)
		luaSpritePlayAnimation('peekaboo', 'crackindawallpeekaboo', false)
	end,
	
	[80] = function() -- 41 seconds
		doTweenZoom('zoomTween1', 'camGame', 0.5, 3.7, 'smootherStepInOut')
		
		setProperty('boyfriend.cameraPosition', {280, -70})
		setProperty('camDisplacement', 0)
		
		setProperty('camGame.angle', -0.2)
		doTweenAngle('rotate', 'camGame', 0, 0.75, 'smootherStepOut')
	end,
	
	[81] = function()
		cancelTween('rotate')
	
		setProperty('camGame.angle', 0.4)
		doTweenAngle('rotate', 'camGame', 0, 0.75, 'smootherStepOut')
	end,
	[82] = function()
		cancelTween('rotate')
		
		setProperty('camGame.angle', -0.6)
		doTweenAngle('rotate', 'camGame', 0, 0.75, 'smootherStepOut')
	end,
	[83] = function()
		cancelTween('rotate')
	
		setProperty('camGame.angle', 0.8)
		doTweenAngle('rotate', 'camGame', 0, 0.75, 'smootherStepOut')
	end,
	
	[84] = function() 
		cancelTween('rotate')
	
		setProperty('camGame.angle', -0.5)
		doTweenAngle('rotate', 'camGame', 0.25, 2, 'smootherStepOut')
	
		cancelTween('zoomTween1')
		doTweenZoom('zoomTween2', 'camGame', 3, 2, 'smootherStepIn')
		doTweenAlpha('hudAlpha', 'camHUD', 0, 0.4, 'linear')
		doTweenAngle('4', 'camGame', 0, 1, 'smootherStepInOut')
		setProperty('boyfriend.cameraPosition', {280, -240})
	end,
	
	[87] = function() 
		cancelTween('zoomTween2')
		setProperty('defaultCamZoom', 1.3)
		triggerEvent('Screen Shake','0.7,0.001')
		
		doTweenAngle('rotate', 'camGame', 0, 0.5, 'smootherStepOut')
	end,
  
	[88] = function() -- CHANGE
		arcadeBG = true
	
		setProperty('defaultCamZoom', 0.7)
		cameraFlash('camGame', 'FFFFFF', 0.5)
		doTweenAlpha('hudAlpha', 'camHUD', 1, 0.4, 'linear')
		
		setProperty('boyfriend.cameraPosition', {0, -40})
		setProperty('camDisplacement', 20)
	end,
	
	[148] = function() -- around 1:16
		setProperty('boyfriend.cameraPosition', {290, -230})
		setProperty('camDisplacement', 0)
		setProperty('cameraSpeed', 0.5)
		doTweenZoom('zoomTween2', 'camGame', 2, 2, 'smootherStepIn')
	end,
	
	[152] = function() -- go back pls
		arcadeBG = false

		cameraFlash('camGame', 'FFFFFF', 0.3)
		setProperty('cameraSpeed', 1)
		setProperty('defaultCamZoom', 0.7)
		cancelTween('zoomTween2')
		
		setProperty('boyfriend.cameraPosition', {0, 0})
		setProperty('camDisplacement', 20)
	end,
	
	[212] = function()
		doTweenZoom('zoomTween1', 'camGame', 0.55, 3, 'smootherStepInOut')
		-- setProperty('cameraSpeed', 0.3)
		
		setProperty('dad.cameraPosition', {420, 330})
		setProperty('camDisplacement', 0)
		runTimer('stayZoomEnd', 1.5)
		
		setProperty('camGame.angle', -0.25)
		doTweenAngle('rotate', 'camGame', 0, 0.75, 'smootherStepOut')
	end,
	
	[213] = function()
		cancelTween('rotate')
	
		setProperty('camGame.angle', 0.5)
		doTweenAngle('rotate', 'camGame', 0, 0.75, 'smootherStepOut')
	end,
	[214] = function()
		cancelTween('rotate')
		
		setProperty('camGame.angle', -0.75)
		doTweenAngle('rotate', 'camGame', 0, 1, 'smootherStepOut')
	end,
	[215] = function()
		cancelTween('rotate')
	
		setProperty('camGame.angle', 1)
		doTweenAngle('rotate', 'camGame', 0, 1, 'smootherStepOut')
	end,
	
	[219] = function()
		setProperty('camZooming', false)
		setProperty('black.alpha', 1)
		setProperty('camHUD.visible', false)
		
		if isStoryMode then
			runTimer('endSong', 10.5)
			playSound('cordFall')
			triggerEvent('Play Animation', 'fall', 'Dad')
			setObjectOrder('dadGroup', getObjectOrder('black')+1)
		end
	end
}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	end
	playAnim('mash', 'idle', false)
end

function onEndSong()
	if cordFallingCutscene == false then
		return Function_Continue
	end
	return Function_Stop
end


function realExit()
	runHaxeCode([[
		import backend.MusicBeatState;
		import states.credits.CreditsPlatformer;
		import states.PlayState;
		
		MusicBeatState.currentTransition = 2;
		CreditsPlatformer.enteringFromCordWeek = true;

		PlayState.storyPlaylist = [];

		PlayState.instance.saveProgression();

		FlxG.switchState(()->new CreditsPlatformer());
	]])


end