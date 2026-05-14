-- fuck this script like actually this sucks

local seenVideo = false
local seenDialogue = false
local seenCouchAnim = false

function onStartCountdown()

	if isStoryMode and not seenCutscene then

		if not seenVideo then
			startVideo('weekcord')

			seenVideo = true

			return Function_Stop

		elseif not seenDialogue then
			setProperty('inCutscene', true)

			runTimer('startDialogue', 1.5)
			playAnim('boyfriend','intro',true)

			seenDialogue = true

			return Function_Stop
			
		elseif not seenCouchAnim then
			runTimer('start', 0.9)
			runTimer('cordanimplay', 0.1)

			seenCouchAnim = true

			return Function_Stop

		end

		return Function_Continue

	end

	return Function_Continue
end

function onCreate()
	if isStoryMode and not seenCutscene then

		setProperty('dad.cameraPosition', {420, 320})
		makeAnimatedLuaSprite('cord_couchjump', 'stages/weekcord/cord_couchjump', -208, -99)
		setLuaSpriteScrollFactor('cord_couchjump', 1, 1)
		scaleObject('cord_couchjump', 1.05, 1.05)
		setObjectOrder('cord_couchjump', 18)
		addLuaSprite('cord_couchjump', true)
		
		setProperty('dad.visible', false) 
	else 
		setProperty('dad.cameraPosition', {270, 350})
	end
	
	if not lowQuality then
		makeLuaSprite('tint', 'stages/weekcord/tint', -650, -350)
		setLuaSpriteScrollFactor('tint', 0.9, 0.9)
		setProperty('tint.alpha', 0.2)
		setBlendMode('tint', 'add')
		addLuaSprite('tint', true)
		
		makeLuaSprite('blov2', 'stages/weekcord/nightoverlay', -700, -310)
		setLuaSpriteScrollFactor('blov', 0.97, 0.97)
		setProperty('blov2.alpha', 0.2)
		setBlendMode('blov2', 'add')
		scaleObject('blov2', 2.5, 2)
		addLuaSprite('blov2', true)
		
		setProperty('glow.visible', true)
		setProperty('windowShine.visible', true)
		setProperty('boyfriend.color', getColorFromHex('DEECEA'))
		
		makeLuaSprite('shading', 'stages/weekcord/morningShading', -760, 546)
		setLuaSpriteScrollFactor('shading', 0.95, 0.95)
		setProperty('shading.alpha', 0.25)
		addLuaSprite('shading', false)
		setProperty('shading.visible', true)
	end
	
	setProperty('building1.visible', true)
	setProperty('closebuildings1.visible', true)
end

function onSongStart()
	cancelTween('zoomTween')
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'kitty-days')
	end
	
	if tag == 'start' then
		startCountdown()
		setProperty('dad.cameraPosition', {270, 350})
		doTweenZoom('zoomTween', 'camGame', 0.8, 3, 'smootherStepInOut')
	end
	
	if tag == 'cordanimplay' then
		luaSpriteAddAnimationByPrefix('cord_couchjump', 'idle', 'cordjumpanim instance 1', 24, false)
	end
end

  beatHitFuncs = {
  
	[1] = function()
		doTweenAlpha('hudAlpha', 'camHUD', 0, 0.4, 'linear')
	end,
	
	[4] = function()
		if isStoryMode then
			setProperty('cord_couchjump.visible', false)
			setProperty('dad.visible', true)
		end
	
		doTweenAlpha('hudAlpha', 'camHUD', 1, 0.4, 'linear')
		setProperty('bar_upper.visible', true)
		setProperty('bar_lower.visible', true)
	end,
	
	[32] = function()
		doTweenZoom('lalalas', 'camGame', 0.8, 3.2, 'smootherStepInOut')
	end,
	
	[36] = function()
		cancelTween('lalalas')
	end,
	
	[100] = function()
		setProperty('cameraSpeed', 9)
		setProperty('camDisplacement', 0)
	end,
	
	[116] = function()
		setProperty('cameraSpeed', 1)
		setProperty('camDisplacement', 20)
	end,
	
	[200] = function()
		setProperty('boyfriend.cameraPosition', {310, -135})
		setProperty('cameraSpeed', 0.5)
		
		if isStoryMode then
			doTweenAlpha('hudAlpha', 'camHUD', 0, 3, 'linear')
		end
	end,
	
	[203] = function()
		if isStoryMode then
			doTweenZoom('zoomIn', 'camGame', 0.65, 4.7, 'smootherStepInOut')
			setProperty('camZooming', false)
		end
	end,
}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	
	end
end