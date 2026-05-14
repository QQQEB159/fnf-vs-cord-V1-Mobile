luaDebugMode = true
local theNewRickRoll = false
local smokeBeat = 0
local smokeOffset = 16

function onCreate()
	setProperty('skipCountdown', true)
	setProperty('camDisplacement', 0)
	setProperty('cameraSpeed', 0.2)
	doTweenZoom('startZoom', 'camGame', 0.375, 0.001, 'linear')
	setProperty('boyfriend.cameraPosition', {290, -100})
end

function onUpdatePost()
	if theNewRickRoll then
		setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true)
	end
end

function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	end
	
	if getRandomBool(1) and curBeat > smokeBeat + smokeOffset then
		smokeAnimPlay()
	end
end

beatHitFuncs = {
	[1] = function()
		doTweenZoom('zoomIn', 'camGame', 0.475, 5, 'smootherStepInOut')
		doTweenAngle('camGameRotate', 'camGame', 5, 8, 'smootherStepOut')
		doTweenAlpha('alphaBlackBg', 'blackBg', 0.65, 8, 'smootherStepOut')
	end,
	
	[10] = function()
		cancelTween('zoomIn')
		cancelTween('camGameRotate')
		cancelTween('alphaBlackBg')
		setProperty('blackBg.alpha', 0)
		
		setProperty('isCameraOnForcedPos',true)
		callMethod('snapCamFollowToPos', { 50, 520})
		callMethod('camGame.snapToTarget', {})
		
		doTweenZoom('camGameZoomTween', 'camGame', 0.8, (crochet / 1000), 'elasticOut')
		setProperty('camGame.angle', -2)
	end,

	[12] = function()
		setProperty('camDisplacement', 20)
		setProperty('cameraSpeed', 1)
		setProperty('boyfriend.cameraPosition', {0, 0})
		
		setProperty('isCameraOnForcedPos',false)
		
		doTweenAngle('camGameRotate', 'camGame', 0, 2, 'smootherStepOut')
	end,
	
	[140] = function()
		setProperty('camZooming', false)
	end,
	
	[172] = function()
		setProperty('boyfriend.cameraPosition', {0, 0})
		setProperty('dad.cameraPosition', {40, 50})
		setProperty('camZooming', true)
	end,
	
	[198] = function()
		setProperty('camDisplacement', 0)
		theNewRickRoll = true
	end,
}

function onStepHit() -- yea sure why not
	if stepHitFuncs[curStep] then 
		stepHitFuncs[curStep]()
	end
end

stepHitFuncs = {
	[564] = function()
		doTweenAngle('miauRotate', 'camGame', 0.25, 1, 'smootherStepOut')
		
		setProperty('boyfriend.cameraPosition', {0, 40})
		setProperty('dad.cameraPosition', {20, 50})
	end,
	
	[572] = function()
		doTweenAngle('miauRotate', 'camGame', -0.25, 1, 'smootherStepOut')
	end,
	
	[578] = function()
		cancelTween('miauRotate')
		doTweenAngle('miauRotate', 'camGame', 0, 1, 'smootherStepOut')
	end,
	
	-- seperated to read better
	
	[596] = function()
		doTweenAngle('miauRotate', 'camGame', 0.25, 1, 'smootherStepOut')
	end,
	
	[604] = function()
		doTweenAngle('miauRotate', 'camGame', -0.25, 1, 'smootherStepOut')
	end,
	
	[610] = function()
		cancelTween('miauRotate')
		doTweenAngle('miauRotate', 'camGame', 0, 1, 'smootherStepOut')
	end,
}

function onStartCountdown()
	if not allowCountdown then
		runTimer('start', 0.005)
		return Function_Stop
	end
	return Function_Continue
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'start' then
		allowCountdown = true
		startCountdown()
	end
end

function smokeAnimPlay()
	smokeBeat = curBeat
	smokeOffset = getRandomInt(8, 24)
	
	playAnim('gf', 'smoke')
	setProperty('gf.specialAnim', true)
end
