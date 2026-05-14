local startFade = false

function onCreate()
	-- characters
	if not lowQuality then
		makeLuaSprite('rtlface', 'stages/weekparty/bg_characters/rtlface', 1900, 490) -- my girlfriend!!!
		setLuaSpriteScrollFactor('rtlface', 0.7, 0.7)
		scaleObject('rtlface', 0.85, 0.85)
		setProperty('rtlface.alpha', 0.5)
		addLuaSprite('rtlface', false)
		
		makeAnimatedLuaSprite('kris', 'stages/weekparty/bg_characters/kris_idle', -400, 400)
		luaSpriteAddAnimationByPrefix('kris', 'idle', 'krisidle instance 1', 24, false)
		setLuaSpriteScrollFactor('kris', 0.95, 0.95)
		addLuaSprite('kris', false)
		
		makeAnimatedLuaSprite('susie', 'stages/weekparty/bg_characters/susie', 20, 230)
		luaSpriteAddAnimationByPrefix('susie', 'idle', 'susie instance 1', 24, false)
		setLuaSpriteScrollFactor('susie', 0.95, 0.95)
		-- addLuaSprite('susie', false)
		setObjectOrder('susie', getObjectOrder('television'))
		
		makeAnimatedLuaSprite('punkape', 'stages/weekparty/bg_characters/punkape', -60, 600)
		luaSpriteAddAnimationByPrefix('punkape', 'idle', 'punkidle instance 1', 24, false)
		setLuaSpriteScrollFactor('punkape', 1.2, 1.2)
		addLuaSprite('punkape', true)
		
		makeAnimatedLuaSprite('liz', 'stages/weekparty/bg_characters/liz', 3300, 600)
		luaSpriteAddAnimationByPrefix('liz', 'idle', 'liz instance 1', 24, true)
		setLuaSpriteScrollFactor('liz', 1.35, 1.35)
		addLuaSprite('liz', true)
		
		-- other
		
		doTweenAlpha('DIE', 'rtlface', 0, 0.001, 'linear') --hi
		doTweenAlpha('lizAlpha0.7', 'liz', 0.7, 0.3, 'linear') --lol
		
		setObjectOrder('lightning_multiply', 40)
		-- setObjectOrder('rtlface', 41)
		setObjectOrder('roseCopy', getObjectOrder('lightning_multiply')+1)
		setObjectOrder('felineCopy', getObjectOrder('lightning_multiply')+1)
		setObjectOrder('marilynCopy', getObjectOrder('lightning_multiply')+1)
	end
	
	if isStoryMode then
		setProperty('boyfriend.cameraPosition', {175, 60 + 280})
	end
	
	setObjectOrder('partyLights', 99)
	precacheSound('talkingBGaudio')
	playSound('talkingBGaudio', 0.5)
	setProperty('camDisplacement', 0)
	doTweenColor('dejalaColour', 'partyLights', 'FFEBD6', 50, 'linear') -- orange
end

function onUpdate()
	if startFade == true and not lowQuality then
		if mustHitSection then --liz fades out
			doTweenAlpha('lizAlpha0.7', 'liz', 0.7, 0.3, 'linear')
		else --liz fade in
			doTweenAlpha('lizAlpha1', 'liz', 1, 0.3, 'linear')
		end
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	
	if tag == 'startloop' then --triggers the whole thing for rtl
		runTimer('loop1', 0.001)
	end
	
	if tag == 'loop1' then --loop .
		doTweenAlpha('fadeout', 'rtlface', 0.5, 3, 'linear') --fade out...
		runTimer('loop2', 3)
	end
	if tag == 'loop2' then
		doTweenAlpha('fadein', 'rtlface', 0.8, 3, 'linear') --fade in!
		runTimer('loop1', 3)
	end
end

function onSongStart()
	doTweenZoom('zoomOut', 'camGame', 0.48, 3.5, 'expoOut')
end

  beatHitFuncs = {
	
	[4] = function()
		startFade = true
		--doTweenY('tv go down','television', -410, 3.5, 'smootherStepOut')
		cancelTween('zoomOut')
		doTweenZoom('zoomIn', 'camGame', 0.58, 1.8, 'expoIn')
		
		if isStoryMode then
			setProperty('boyfriend.cameraPosition', {-70, 390})
		end
	end,
	
	[8] = function()
		setProperty('camZooming', true)
		cancelTween('zoomIn')
		setProperty('defaultCamZoom', 0.55)
		setProperty('camDisplacement', 15)
	end,
	
	[32] = function()
		runTimer('loop1', 0.01)
	end,
	
	[40] = function()
		setProperty('defaultCamZoom', 0.5)
	end,
	
	[68] = function()
		if not lowQuality then
			doTweenX('plugwalk','liz', 2400, 4,'quadout') --X POSITION
		end
	end,
	
	[120] = function()
		doTweenAngle('camGameRotate', 'camGame', 1, 4, 'smootherStepOut')
	end,
	
	[128] = function()
		doTweenZoom('zoomIn', 'camGame', 0.625, 1.75, 'expoOut')
	end,
	
	[136] = function()
		doTweenY('bar_upper', 'bar_upper', -100, 3, 'expoOut')
		doTweenY('bar_lower', 'bar_lower', 615, 3, 'expoOut')
	end,
	
	[137] = function()
		playAnim('television', 'fnaf', true)
		doTweenAngle('ROTATA', 'camGame', 0, 4, 'smootherStepOut')
	end,
	
	[158] = function()
		playAnim('television', 'flash', true)
	end,
	
	[160] = function()
		playAnim('television', 'idle', true)
	end,
	
	[168] = function()
		doTweenY('bar_upper', 'bar_upper', -120, 3, 'expoOut')
		doTweenY('bar_lower', 'bar_lower', 635, 3, 'expoOut')
	end,	
	
	[232] = function()
		doTweenZoom('zoomTween', 'camGame', 0.7, 9.3, 'smootherStepInOut') --oy
		setProperty('camZooming', false)
	end,
	
	[260] = function()
		setProperty('camZooming', true)
	end,
	
	[264] = function()
		setProperty('dad.cameraPosition', {300 + 240, 50 + 360})
		
		setProperty('camDisplacement', 0)
		
		if isStoryMode then
			doTweenAlpha('hudAlpha', 'camHUD', 0, 1, 'linear')
			doTweenAlpha('hey.', 'black', 1, 1, 'linear') --whatsup bro
		end
	end,
}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	
	end
	if curBeat % 2 == 0 then --loop
		playAnim('susie', 'idle', false)
		playAnim('punkape', 'idle', true)
	end
end

function opponentNoteHit()
    health = getProperty('health')
    if getProperty('health') > 0.020 then
        setProperty('health', health- 0.015)
    end
end