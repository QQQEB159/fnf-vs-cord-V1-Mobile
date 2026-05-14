local allowCountdown = false
tweenCompleted = false

function onStartCountdown()
	if not allowCountdown and isStoryMode then
			runTimer('spawn', 1)
			runTimer('startCountdown', 2)
			setProperty('dadGroup.alpha', 0)
			
			doTweenZoom('yeah', 'camGame', 0.55, 0.001, 'linear');	
		allowCountdown = true
		return Function_Stop
	end
	return Function_Continue
end

function onCreate()
	if not lowQuality then
		makeLuaSprite('tint', 'stages/weekcord/tint', -650, -350)
		setLuaSpriteScrollFactor('tint', 0.9, 0.9)
		setProperty('tint.alpha', 0.3)
		setBlendMode('tint', 'add')
		addLuaSprite('tint', true)
		
		makeLuaSprite('blov2', 'stages/weekcord/nightoverlay', -700, -310)
		setLuaSpriteScrollFactor('blov', 0.97, 0.97)
		setProperty('blov2.alpha', 0.3)
		setBlendMode('blov2', 'add')
		scaleObject('blov2', 2.5, 2)
		addLuaSprite('blov2', true)
		
		setProperty('glow.visible', true)
		setProperty('windowShine.visible', true)
		setProperty('boyfriend.color', getColorFromHex('DEECEA'))
		
		runHaxeCode([[
			import shaders.ColorSwap;
			var colorSwap = new ColorSwap();
			game.getLuaObject("building1").shader = colorSwap.shader;
			
			colorSwap.hue = -0.15;
			colorSwap.saturation = -0.1;
		]])
	end
	
	setProperty('building1.visible', true)
	setProperty('closebuildings1.visible', true)
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'spawn' then
		doTweenAlpha('funny', 'dadGroup', 1, 1, 'linear')
		playSound('catSpawn')
	end
	
	if tag == 'startCountdown' then
		doTweenZoom('yeah', 'camGame', 0.6, 4, 'quadInOut');	
		allowCountdown = true
		startCountdown()
	end
end
function onTweenCompleted(tag)
	if tag == 'blackTween' then
		tweenCompleted = true
		endSong()
	end
end

  beatHitFuncs = {
	[20] = function()
		setProperty('camZooming', true)
	end,
	
	[95] = function()
		followchars = false
		doTweenZoom('ZoomIn', 'camGame', 0.85, 5, 'quadinout')
		doTweenY('camTweenY', 'camFollowPos', 500, 4.3, 'quadinout')
		doTweenX('camTweenX', 'camFollowPos', 1050, 5.3, 'quadinout')
		setProperty('camZooming', false)
	end,
	
	[96] = function()
		doTweenAngle('rotateCam', 'camGame', -4, 10, 'quadOut')
	end,
	
	[104] = function()
		followchars = true
		
		cancelTween('rotateCam')
		doTweenAngle('rotateCam', 'camGame', 0, 2, 'quadOut')
		
		setProperty('camZooming', true)
		cancelTween('ZoomIn')
		cancelTween('camTweenY')
		cancelTween('camTweenX')
	end,
	
	[138] = function()
		doTweenAngle('rotateCam', 'camGame', 1, 0.5, 'quadOut')
		setProperty('dad.cameraPosition', {140, 65})
	end,
	
	[139] = function()
		doTweenAngle('rotateCam', 'camGame', 2, 0.5, 'quadOut')
		setProperty('dad.cameraPosition', {120, 80})
	end,
	
	[140] = function()
		doTweenAngle('rotateCam', 'camGame', 0, 1, 'quadOut')
		setProperty('dad.cameraPosition', {160, 45})
	end,
	
	[183] = function()
		followchars = false
		doTweenZoom('ZoomIn', 'camGame', 0.85, 5, 'quadinout')
		doTweenY('camTweenY', 'camFollowPos', 500, 4.3, 'quadinout')
		doTweenX('camTweenX', 'camFollowPos', 1050, 5.3, 'quadinout')
		setProperty('camZooming', false)
	end,
	
	[184] = function()
		doTweenAngle('rotateCam', 'camGame', -4, 10, 'quadOut')
	end,
	
	[192] = function()
		followchars = true
		
		cancelTween('rotateCam')
		doTweenAngle('rotateCam', 'camGame', 0, 2, 'quadOut')
		
		setProperty('camZooming', true)
		cancelTween('ZoomIn')
		cancelTween('camTweenY')
		cancelTween('camTweenX')
	end,
	
	[226] = function()
		doTweenAngle('rotateCam', 'camGame', 1, 0.5, 'quadOut')
		setProperty('dad.cameraPosition', {140, 65})
	end,
	
	[227] = function()
		doTweenAngle('rotateCam', 'camGame', 2, 0.5, 'quadOut')
		setProperty('dad.cameraPosition', {120, 80})
	end,
	
	[228] = function()
		doTweenAngle('rotateCam', 'camGame', 0, 1, 'quadOut')
		setProperty('dad.cameraPosition', {320, -10})
		setObjectCamera('black', 'other')
	end,
	
	[229] = function()
		if isStoryMode then
			doTweenAlpha('blackTween', 'black', 1, 2, 'quadOut') 
		end
	end,
}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	
	end
end

function onEndSong()
    if not tweenCompleted and isStoryMode then
		return Function_Stop
	end
end