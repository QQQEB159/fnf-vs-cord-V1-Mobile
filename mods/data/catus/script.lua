local allowCountdown = false
constantCamBeat = false
somewhatCamBeat = false
Xmoved = 60
Ymoved = -10

function onStartCountdown()
	if not allowCountdown and isStoryMode then
			runTimer('startCountdown', 1)
			setProperty('black.alpha', 1)
			doTweenAlpha('blackTween', 'black', 0, 2, 'quadOut') 
			allowCountdown = true
		return Function_Stop
	end
	return Function_Continue
end

function onTimerCompleted(tag, loops, loopsLeft)
	
	if tag == 'startCountdown' then
		doTweenZoom('countdownZoom', 'camGame', 0.7, 4, 'quadInOut');	
		allowCountdown = true
		startCountdown()
	end
end

function onCreate()
	setProperty('camDisplacement', 25)
	
	createInstance('cordCopy', 'objects.Character', {-25, 80, 'cord', false}) -- 80, 45
	setProperty('cordCopy.alpha', 0.001)
	setObjectOrder('cordCopy', getObjectOrder('dadGroup')-1)
	addInstance('cordCopy',true)
	
	setProperty('building3.visible', true)
	setProperty('closebuildings3.visible', true)
	setProperty('bg.visible', true)
	setProperty('lightsoff.visible', true)
	setProperty('window shine.visible', false)
	setProperty('nighttint.visible', true)
	
	makeLuaSprite('tint', 'stages/weekcord/tint', -650, -300);
	setLuaSpriteScrollFactor('tint', 0.9, 0.9);
	scaleObject('tint', 2, 1);
	setProperty('tint.alpha', 1)
	setBlendMode('tint', 'add');
	addLuaSprite('tint', true);
	
	setObjectCamera('black', 'other');
	
	setProperty('mic.alpha', 0.001)
end

function onCreatePost()
	setProperty('tree.color',FlxColor('#6E6EAD'))
end

function onUpdatePost(elapsed)
end

  beatHitFuncs = {
	[1] = function()
		if isStoryMode then
			setProperty('defaultCamZoom', 0.7)
		end
	end,
	
	[32] = function()
		somewhatCamBeat = true
	end,
	
	[128] = function() -- 39 seconds or something
		setProperty('cameraSpeed', 0.5);
		setProperty('boyfriend.cameraPosition', {-80, 50})
	end,
	
	[132] = function()
		doTweenZoom('zoomIn', 'camGame', 1, 10, 'smootherStepInOut');
	end,
	
	[136] = function()
		doTweenAngle('rotateCam', 'camGame', -4, 10, 'smootherStepInOut')		
	end,
	
	[160] = function() -- CAT EVENT
		somewhatCamBeat = false
		doTweenZoom('camGameZoomTween', 'camGame', 1.5, 0.01, 'linear')
		setProperty('camZoomingMult', 0)
		cancelTween('rotateCam')
		cancelTween('zoomIn')
		doTweenAngle('rotateCam', 'camGame', 0, 2, 'bounceOut')
		
		setProperty('dad.cameraPosition', {210, 20})
		setProperty('camDisplacement', 0)
		triggerEvent('Screen Shake','0.9, 0.005')
		
		doTweenX('cordMovingX', 'cordCopy', 80, 1, 'expoOut')
		doTweenY('cordMovingY', 'cordCopy', 45, 1, 'expoOut')
		
		setProperty('dadGroup.x', getProperty('dadGroup.x') - 60)
		setProperty('dadGroup.y', getProperty('dadGroup.y') + 10)
		setScrollFactor('cordCopy', 0.98, 0.98);
		
		setProperty('mic.x', getProperty('dadGroup.x') + 340)
		setProperty('mic.y', getProperty('dadGroup.y') + 585*2)
		
		setScrollFactor('mic', 1, 1);
		
		playAnim('cordCopy', 'catusAnim')
		
		setProperty('cordCopy.alpha', 1)
		setProperty('mic.alpha', 1)
	end,
	
	[163] = function()
		doTweenZoom('zoomIn', 'camGame', 0.6, 2, 'quadIn');
		doTweenX('camTweenX', 'camFollowPos', 490, 3, 'smootherStepInOut')
		doTweenY('micY', 'mic', getProperty('mic.y') - 585, 6, 'quadOut')
	end,
	
	[184] = function() -- 54 secs
		setObjectCamera('black', 'camHUD');
		doTweenAlpha('alphaTween', 'camHUD', 0.6, 2, 'smootherStepInOut');
		doTweenAngle('rotateCam', 'camGame', 1, 0.2, 'quadOut')
		
		doTweenY('camTweenY', 'camFollowPos', 600, 2, 'smootherStepInOut')
		doTweenX('camTweenX', 'camFollowPos', 100, 2, 'smootherStepInOut')
		
		setObjectCamera('black', 'camGame')
		setObjectOrder('black', getObjectOrder('dadGroup')-1)
		doTweenAlpha('blackFade', 'black', 1, 4, 'quadout')
	end,
	
	[185] = function()
		doTweenAngle('rotateCam', 'camGame', 2, 0.2, 'quadOut')
	end,
	
	[186] = function()
		doTweenAngle('rotateCam', 'camGame', 3, 0.2, 'quadOut')
	end,
	
	[187] = function()
		doTweenAngle('rotateCam', 'camGame', 5, 0.2, 'quadOut')
	end,
	
	[188] = function()
		constantCamBeat = true
		setProperty('camZoomingMult', 1)
		
		cancelTween('blackFade')
		cancelTween('alphaTween')
		cancelTween('camTweenX')
		cancelTween('camTweenY')
		
		doTweenAlpha('blackFade', 'black', 0, 1, 'quadout')
		doTweenAlpha('alphaTween', 'camHUD', 1, 0.25, 'smootherStepInOut');
		doTweenAngle('rotateCam', 'camGame', 0, 1, 'quadOut')

		setProperty('camDisplacement', 20)
		setProperty('boyfriend.cameraPosition', {-20, 20})
		setProperty('dad.cameraPosition', {140 + Xmoved, 70 + Ymoved})
		setProperty('cameraSpeed', 1);
	end,
	
	[284] = function() -- 1:24
		setProperty('cameraSpeed', 0.5);
		setProperty('dad.cameraPosition', {330 + Xmoved, -30 + Ymoved}) -- +60, +40
		setProperty('camDisplacement', 0)
	end,
	
	[344] = function()
		constantCamBeat = false
	end,
	
	[348] = function()
		setProperty('dad.cameraPosition', {750 + Xmoved, 90 + Ymoved})
		doTweenZoom('zoomIn', 'camGame', 1, 13, 'smootherStepInOut');
		setProperty('cameraSpeed', 0.1);
	end,
	
	[376] = function()
		setProperty('camZoomingMult', 0)
	end,
	
	[380] = function()
		setProperty('cameraSpeed', 1.1);
		setProperty('dad.cameraPosition', {700 + Xmoved, 60 + Ymoved})
		cancelTween('zoomIn')
	end,
	
	[384] = function()
		setProperty('camZooming', false)
		doTweenX('camTweenX', 'camFollowPos', 430, 2.25, 'smootherStepInOut')
	end,
	
	[385] = function()
		setProperty('dad.cameraPosition', {90 + Xmoved, 60 + Ymoved})
	end,
}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	end
	
	if constantCamBeat == true then
		triggerEvent('Add Camera Zoom', '', '')
	end
	
	if somewhatCamBeat == true then
		if curBeat % 4 == 2 then
			triggerEvent('Add Camera Zoom', '0.005', '0.015')
		end
	end
end