local seenDialogue = false
local seenCameraMove = false


function onStartCountdown()
	-- Block the first countdown and start a timer of 0.8 seconds to play the dialogue

	if isStoryMode and not seenCutscene then

		if not seenDialogue then
			setProperty('inCutscene', true)
			runTimer('startDialogue', 0.8)

			seenDialogue = true

			return Function_Stop
		elseif not seenCameraMove then
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

function onCreatePost()
	if isStoryMode then
		setProperty('camGame.zoom', 0.65)
	end

	--drop shadow
	runHaxeCode([[
		import shaders.DropShadowShader;

		var shader = new DropShadowShader();

		shader.angle = 180;

		shader.color = 0xFFA07946;

    	shader.distance = 15;

		dad.shader = shader;

		var char = dad.isAnimateAtlas ? dad.atlas : dad;

		shader.attachedSprite = char;

		function onChange(anim,idx,num) 
		{
			shader.updateFrameInfo(char.frame);
		}

		char.animation.onFrameChange.add(onChange);



	]])

	-- makes the video sprite
	runHaxeCode([[
		import objects.FunkinVideoSprite;

		var video = new FunkinVideoSprite();
		video.load(Paths.video('badLuckCutscene'),[FunkinVideoSprite.muted]);

		video.cameras = [camHUD];
		insert(0,video);

		video.visible = false;

		video.tiedToGame = false;
		
		
		video.onFormat(()->{
			video.scale.set(0.68,0.68);
			video.setPosition(-330,-180);
			video.visible = false;
			video.pause();
		},true);

		video.delayAndStart();

		video.onEnd(()->video.kill());

		video.antialiasing = ClientPrefs.data.antialiasing;

		setVar('vid',video);
	]])
end

function onCreate()
	setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)

	setProperty('building2.visible', true)
	setProperty('closebuildings2.visible', true)
	
	if not lowQuality then
		makeLuaSprite('blov', 'stages/weekcord/badluckfilter', -700, -310)
		setProperty('blov.alpha', 0.1)
		setBlendMode('blov', 'add')
		scaleObject('blov', 2.5, 2)
		addLuaSprite('blov', true)
		
		makeLuaSprite('blov2', 'stages/weekcord/badluckfilter', -700, -310)
		setProperty('blov2.alpha', 0.25)
		setBlendMode('blov2', 'multiply')
		scaleObject('blov2', 2.5, 2)
		addLuaSprite('blov2', true)
		
		makeLuaSprite('shading', 'stages/weekcord/eveningShading', -760, 546)
		setLuaSpriteScrollFactor('shading', 0.95, 0.95)
		setProperty('shading.alpha', 0.25)
		addLuaSprite('shading', false)
		setProperty('shading.visible', true)
	end
end

function onUpdate()
end
function onUpdatePost()	

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
	end
end

  beatHitFuncs = {
	
	[1] = function()
		doTweenAlpha('hudAlpha', 'camHUD', 0, 0.4, 'linear')
	end,
	
	[4] = function()
		doTweenAlpha('hudAlpha', 'camHUD', 1, 0.4, 'linear')
		setProperty('bar_upper.visible', true)
		setProperty('bar_lower.visible', true)
	end,
	
	[34] = function()
		doTweenX('penis','camFollowPos', 390, 1.1, 'quadout')
		doTweenZoom('zoomTween', 'camGame', 0.9, 1.1, 'quadinout')	
		doTweenY('lala land','camFollowPos', 330, 1.1, 'quadout')
	end,
	
	[66] = function()
		doTweenX('coolLeftTween','camFollowPos', 390, 1, 'expoIn')
	end,
	
	[68] = function()
		cancelTween('coolLeftTween')
	end,
	
	[130] = function()
		doTweenZoom('zoomTween', 'camGame', 1, 1.1, 'quadin')	
	end,
	
	[132] = function()
		cameraFlash('camHUD', 'FFFFFF', 1)
		setProperty('camZoomingMult', 0)
		
		runHaxeCode([[
			getVar('vid').resume();
			getVar('vid').bitmap.time = 0;
			getVar('vid').visible = true;
			getVar('vid').tiedToGame = true;
		]])

		-- setProperty('bar_upper.alpha',0.001)
		-- setProperty('bar_lower.alpha',0.001)
		setProperty('noteUnderlay.alpha',0.001)

		
		-- get rid of HUD
		doTweenAlpha('13', 'timeTxt', 0, 0.4, 'linear')
		doTweenAlpha('14', 'scoreTxt', 0, 0.4, 'linear')
		doTweenAlpha('15', 'healthBar', 0, 0.4, 'linear')
		doTweenAlpha('16', 'iconP1', 0, 0.4, 'linear')
		doTweenAlpha('17', 'iconP2', 0, 0.4, 'linear')
		for i = 0, getProperty('strumLineNotes.length') - 1 do
			noteTweenAlpha('18'..i, i, 0, 0.4, 'linear')
		end
		
		setProperty('camZooming', false)
		
	end,
	
	[146] = function()
		setObjectCamera('black', 'camHUD')
		doTweenAlpha('fadeIn', 'black', 1, 1, 'linear');
	end,
	
	[148] = function()
		setProperty('camZoomingMult', 1)
		doTweenAlpha('hudAlpha', 'camHUD', 1, 0.4, 'expoIn')
		-- setProperty('bar_upper.alpha',1)
		-- setProperty('bar_lower.alpha',1)
		callMethod('updateUnderlay')

		
		doTweenAlpha('13', 'timeTxt', 0.7, 0.4, 'linear')
		doTweenAlpha('14', 'scoreTxt', 0.7, 0.4, 'linear')
		doTweenAlpha('15', 'healthBar', 1, 0.4, 'linear')
		doTweenAlpha('16', 'iconP1', 1, 0.4, 'linear')
		doTweenAlpha('17', 'iconP2', 1, 0.4, 'linear')
		for i = 0, getProperty('strumLineNotes.length') - 1 do
			local intendedAlpha = 0.75

			if i <= 3 then
				if getPropertyFromClass('backend.ClientPrefs.data','opponentStrums') then
					intendedAlpha = 0
				elseif middlescroll then
					intendedAlpha = 0.35

				end
			end

			noteTweenAlpha('18'..i, i, intendedAlpha, 0.4, 'linear')
		end

		
		setProperty('defaultCamZoom', 0.575)
		
		setProperty('camZooming', true)
		
		setProperty('black.alpha', 0)
		cameraFlash('camHUD', 'FFFFFF', 1)
	end,
	
	[157] = function()
		setProperty('peekaboo.visible', true)
		luaSpritePlayAnimation('peekaboo', 'crackindawallpeekaboo', false)
	end,
	
	[162] = function()
		doTweenZoom('zoomTween', 'camGame', 1, 1.5, 'quadinout')	
	end,
	
	[164] = function()
		cancelTween('zoomTween')
	end,
	
	[192] = function()
		setProperty('dad.cameraPosition', {205, 350})
	end,
	
	[194] = function()
		doTweenZoom('zoomTween', 'camGame', 0.9, 1, 'quadinout')	
		doTweenAngle('rotateCam', 'camGame', 3, 1, 'quadin')
	end,
	
	[195] = function()
		setObjectCamera('black', 'camGame')
		setObjectOrder('black', getObjectOrder('gfGroup')-1)
		setProperty('black.alpha', 0.4)
		doTweenAlpha('blackFade', 'black', 0, 1, 'quadout')
		
		setProperty('blov2.alpha', 0.5)
		setProperty('blov.alpha', 0.05)
		doTweenAlpha('blov2Alpha', 'blov2', 0.25, 2, 'quadout')
		doTweenAlpha('blovAlpha', 'blov', 0.1, 2, 'quadout')
		
		cancelTween('rotateCam')
		cancelTween('zoomTween')
		
		doTweenZoom('zoomTween', 'camGame', 0.6, 0.03, 'quadinout')
		setProperty('defaultCamZoom', 0.65)
		setProperty('camGame.angle', -1)
		doTweenAngle('BOOM', 'camGame', 0, 0.05, 'bounceInOut')
	end,
	
	[196] = function()
		setObjectCamera('black', 'camHUD')
		setProperty('dad.cameraPosition', {240, 350})
	end,
	
	[260] = function()
		setProperty('boyfriend.cameraPosition', {310, -135})
		setProperty('cameraSpeed', 0.5)
		if isStoryMode then
			doTweenAlpha('hudAlpha', 'camHUD', 0, 2, 'linear')
		end
	end,
}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	
	end
end
