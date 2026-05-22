local allowCountdown = false
local roseSinging = false
local bothFade = true
local endCutscene = false

local noDeath = false

function onStartCountdown()
	if not allowCountdown then
		runTimer('start', 0.9)
		return Function_Stop
	end
	return Function_Continue
end

function onCreate()
	-- characters
	if not lowQuality then
		makeAnimatedLuaSprite('kris', 'stages/weekparty/bg_characters/kris_idle', -400, 400)
		luaSpriteAddAnimationByPrefix('kris', 'idle', 'krisidle instance 1', 24, false)
		setLuaSpriteScrollFactor('kris', 0.95, 0.95)
		addLuaSprite('kris', false)
		
		makeAnimatedLuaSprite('susie', 'stages/weekparty/bg_characters/susie', 20, 230)
		luaSpriteAddAnimationByPrefix('susie', 'idle', 'susie instance 1', 24, false)
		setLuaSpriteScrollFactor('susie', 0.95, 0.95)
		setObjectOrder('susie', getObjectOrder('television'))
		
		makeAnimatedLuaSprite('ravenpeek', 'stages/weekparty/bg_characters/ravenTeamFreaker', 2700, 500)
		luaSpriteAddAnimationByPrefix('ravenpeek', 'idle', 'AAKLALALAF instance 1', 24, true) -- my girlfriend!!
		setLuaSpriteScrollFactor('ravenpeek', 1.2, 1.2)
		addLuaSprite('ravenpeek', true)
		
		makeLuaSprite('rtlface', 'stages/weekparty/bg_characters/rtlface2', 2730, 601)
		setLuaSpriteScrollFactor('rtlface', 1.2, 1.2)
		setProperty('rtlface.alpha', 1)
		addLuaSprite('rtlface', true)
		
		
		makeAnimatedLuaSprite('lucia', 'stages/weekparty/bg_characters/lucia', 1525, 280) -- my real girlfriend!!!!
		luaSpriteAddAnimationByPrefix('lucia', 'leftIdle', 'luciaLeft instance 1', 24, false)
		luaSpriteAddAnimationByPrefix('lucia', 'rightIdle', 'luciaRight instance 1', 24, false)
		setLuaSpriteScrollFactor('lucia', 0.96, 0.96)
		setObjectOrder('lucia', getObjectOrder('speaker')-1)
		addLuaSprite('lucia', false)
		
		makeAnimatedLuaSprite('grav', 'stages/weekparty/bg_characters/grav', 1750, 320)
		luaSpriteAddAnimationByPrefix('grav', 'idle', 'graev instance 1', 24, false)
		setLuaSpriteScrollFactor('grav', 0.96, 0.96)
		addLuaSprite('grav', false)
		
		makeAnimatedLuaSprite('bratty', 'stages/weekparty/bg_characters/bratty_idle', 2000, 280)
		luaSpriteAddAnimationByPrefix('bratty', 'idle', 'bratty instance 1', 24, false)
		setLuaSpriteScrollFactor('bratty', 0.97, 0.97)
		addLuaSprite('bratty', false)
		
		makeAnimatedLuaSprite('catty', 'stages/weekparty/bg_characters/catty_idle', 2270, 470) -- my second girlfriend!!!!!
		luaSpriteAddAnimationByPrefix('catty', 'blinker', 'catty-blink instance 1', 24, false)
		luaSpriteAddAnimationByPrefix('catty', 'idle', 'catty-idle instance 1', 24, false)
		setLuaSpriteScrollFactor('catty', 1, 1)
		addLuaSprite('catty', false)
		
		makeAnimatedLuaSprite('monster', 'stages/weekparty/bg_characters/monster', 1400, -200) -- my third girlfriend!!!!!!!!!!
		luaSpriteAddAnimationByPrefix('monster', 'idle', 'monster instance 1', 24, true)
		setLuaSpriteScrollFactor('monster', 1.05, 1.05)
		setProperty('monster.visible', true)
		addLuaSprite('monster', false)
		setProperty('monster.alpha', 0)
		
		makeAnimatedLuaSprite('punkape', 'stages/weekparty/bg_characters/punkape', -60, 600)
		luaSpriteAddAnimationByPrefix('punkape', 'idle', 'punkidle instance 1', 24, false)
		setLuaSpriteScrollFactor('punkape', 1.2, 1.2)
		addLuaSprite('punkape', true)
		
		makeAnimatedLuaSprite('maxdesignpro', 'stages/weekparty/bg_characters/maxdesignpro', -280, 800) -- fuck you
		luaSpriteAddAnimationByPrefix('maxdesignpro', 'idle', 'max designer instance 1', 24, true)
		setLuaSpriteScrollFactor('maxdesignpro', 1.1, 1.1)
		addLuaSprite('maxdesignpro', true)
		if getRandomBool(1) then -- 1% chance of this loser appearing
			setProperty('maxdesignpro.visible', true)
		else	
			setProperty('maxdesignpro.visible', false)
		end
		
		makeAnimatedLuaSprite('liz', 'stages/weekparty/bg_characters/liz', 2400, 600)
		luaSpriteAddAnimationByPrefix('liz', 'idle', 'liz instance 1', 24, true)
		setLuaSpriteScrollFactor('liz', 1.35, 1.35)
		addLuaSprite('liz', true)
		
		makeAnimatedLuaSprite('loona', 'stages/weekparty/bg_characters/loona', -1400, 300)
		setLuaSpriteScrollFactor('loona', 1.35, 1.35)
		scaleObject('loona', 1.3, 1.3)
		addLuaSprite('loona', true)
		
		setObjectOrder('roseCopy', getObjectOrder('lightning_multiply')+1)
		setObjectOrder('felineCopy', getObjectOrder('lightning_multiply')+1)
		setObjectOrder('marilynCopy', getObjectOrder('lightning_multiply')+1)
		
	else
		makeAnimatedLuaSprite('monster', 'stages/weekparty/bg_characters/monster', 1400, -200) -- my third girlfriend!!!!!!!!!!
		luaSpriteAddAnimationByPrefix('monster', 'idle', 'monster instance 1', 24, true)
		setLuaSpriteScrollFactor('monster', 1.05, 1.05)
		setProperty('monster.visible', true)
		addLuaSprite('monster', false)
		setProperty('monster.alpha', 0)
	end

	initLuaShader('DISCO')
	if flashingLights and shadersEnabled then
		setSpriteShader('shaderImage', 'DISCO')
		setProperty('shaderImage.visible', false);
	end
	setProperty('skipCountdown', true)
	
	setProperty('black.alpha', 1)
	setObjectOrder('black', 99)
	setProperty('camDisplacement', 10)
	setObjectOrder('partyLights', 99)
	precacheSound('talkingBGaudio')
	
	setProperty('scoreTxt.alpha', 0)
	setProperty('healthBar.alpha', 0)
	setProperty('iconP1.alpha', 0)
	setProperty('iconP2.alpha', 0)
	
	runTimer('startloop', 0.001) -- lawl!!!
	runTimer('colourFade', 0.5) -- uhh yea
	runTimer('rtlLoop1', 0.001)

	doTweenColor('partyLightsTween2', 'partyLights', 'FFFBD1', 0.001, 'linear') -- orange 
	
	setObjectOrder('partyLights', 99)
	setObjectOrder('lightning_multiply', 20)
end

function onUpdate()
	if roseSinging then
		setProperty('gf.cameraPosition', {225, 320})
	end
	
	if bothFade == true and not lowQuality then
		if mustHitSection then --loona fade in, liz fades out
			doTweenAlpha('loonaAlpha1', 'loona', 1, 0.3, 'linear')
			doTweenAlpha('lizAlpha0.7', 'liz', 0.7, 0.3, 'linear')
		else --liz fade in, loona fades out
			doTweenAlpha('loonaAlpha0.7', 'loona', 0.7, 0.3, 'linear')
			doTweenAlpha('lizAlpha1', 'liz', 1, 0.3, 'linear')
		end
	end
	if flashingLights and shadersEnabled then
		setShaderFloat('shaderImage','iTime',os.clock())
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'start' then
		allowCountdown = true
		startCountdown()
		
		setProperty('camZooming', true)
		
		setStrumVisibilty(2,false)
		setStrumVisibilty(3,false)
		setStrumVisibilty(4,false)
		setStrumVisibilty(5,false)
		setStrumVisibilty(6,false)
		setStrumVisibilty(7,false)
	end
	
	if tag == 'dothefuckinthing' then
		doTweenAlpha('loonaSingTweenGO', 'loona', 0.7, 0.3, 'linear')
		doTweenAlpha('lizSingTweenGO', 'liz', 0.7, 0.3, 'linear')
	end
	
	if tag == 'startloop' then --triggers the monster movement
		runTimer('loop1', 0.001)
	end
	
	if tag == 'loop1' then --loop .
		doTweenY('monsterDOWN', 'monster', -180, 5, 'quadinout') --monster goes down
		runTimer('loop2', 5.1)
	end
	if tag == 'loop2' then
		doTweenY('monsterUP', 'monster', -220, 5, 'quadinout') --monster goes up
		runTimer('loop1', 5.1)
	end
	
	if tag == 'colourFade' then
		doTweenColor('FADEOUT', 'partyLights', 'FFFFFF', 20, 'linear')
	end
	
	if tag == 'blackout' then
		makeLuaText('TBC', "To Be Continued...?", 0, 0, 0)
		setTextFont('TBC', 'ADLER.ttf')
		setProperty('TBC.alpha', 0)
		setTextSize('TBC', 32)
		screenCenter('TBC')
		addLuaText('TBC')
		
		runTimer('shortTween', 2)
	end
	
	if tag == 'shortTween' and isStoryMode then
		doTweenAlpha('TweenTBC', 'TBC', 1, 2, 'linear')
	end
	
	if tag == 'rtlLoop1' then -- rtl.
		doTweenAlpha('fadeout', 'rtlface', 0.5, 2, 'linear') --fade out...
		runTimer('rtlLoop2', 2)
	end
	if tag == 'rtlLoop2' then
		doTweenAlpha('fadein', 'rtlface', 1, 2, 'linear') --fade in!
		runTimer('rtlLoop1', 2)
	end
end

  beatHitFuncs = {
	[1] = function()
		setStrumVisibilty(2,true)
		setStrumVisibilty(3,true)
		if flashingLights and shadersEnabled then
			setProperty('shaderImage.visible', false);
		end
	end,
	[2] = function()
		setStrumVisibilty(4,true)
		setStrumVisibilty(5,true)
	end,
	[3] = function()
		setStrumVisibilty(6,true)
		setStrumVisibilty(7,true)
	end,
	[4] = function()
		setProperty('black.alpha', 0) --go away
		
		setProperty('scoreTxt.alpha', 0.7)
		setProperty('healthBar.alpha', 1)
		setProperty('iconP1.alpha', 1)
		setProperty('iconP2.alpha', 1)
		
		playSound('talkingBGaudio', 1, 'talkingBGaudio')
	end,
	
	[53] = function()
		playAnim('television', 'news', true)
	end,
	
	[66] = function()
		playAnim('television', 'flash', true)
	end,
	
	[68] = function()
		if flashingLights and shadersEnabled then
			setProperty('shaderImage.visible', false)
		end
	end,
	
	[69] = function()
		playAnim('television', 'idle', true)
	end,
	
	[84] = function()
		doTweenX('loonaXTween','loona.scale', 1, 4,'quadout') --scale :3
		doTweenY('loonaYTween','loona.scale', 1, 4,'quadout')
		doTweenX('loonaWalkX','loona', -400, 4,'quadout') --X POSITION
		doTweenY('loonaWalkY','loona', 50, 4,'quadout') --Y POSITION
		luaSpriteAddAnimationByPrefix('loona', 'idle', 'loonawalk instance 1', 24, false)
	end,
	
	[100] = function()
		if flashingLights and shadersEnabled then
			setProperty('shaderImage.visible', false);
		end
	end,
	
	[132] = function()
		bothFade = false
		roseSinging = true
		runTimer('dothefuckinthing', 0.1)
		
		-- setProperty('boyfriend.cameraPosition', {400, 30})
		setProperty('boyfriend.cameraPosition', {260 + -70, 390 - 30})

	end,
	[140] = function()
		roseSinging = false
	end,
	[148] = function()
		roseSinging = true
	end,
	[156] = function()
		roseSinging = false
	end,
	[164] = function()
		roseSinging = true
	end,
	[180] = function()
		roseSinging = false
	end,
	
	[196] = function()
		setProperty('dad.cameraPosition', {20 + 240, 50 + 360})
		setProperty('boyfriend.cameraPosition', {-70, 390})
		bothFade = true
	end,
	
	[228] = function()
		if flashingLights and shadersEnabled then
			setProperty('shaderImage.visible', false)
		end
	end,
	
	[260] = function() --around 1:50
		setProperty('camZooming', false)
		lightningStrikes = false -- doesnt even fucking do anything useless ass code
		bothFade = false
		roseSinging = true
		runTimer('dothefuckinthing', 0.1)
		
		-- setProperty('boyfriend.cameraPosition', {400, 30})
		setProperty('boyfriend.cameraPosition', {260 + -70, 390 - 30})
		
		doTweenZoom('littleZoomInOut','camGame',0.39, 21,'linear')
		
		doTweenAlpha('scoreTxtTween', 'scoreTxt', 0, 5, 'linear')
		doTweenAlpha('healthBarTween', 'healthBar', 0, 5, 'linear')
		doTweenAlpha('iconP1Tween', 'iconP1', 0, 5, 'linear')
		doTweenAlpha('iconP2Tween', 'iconP2', 0, 5, 'linear')
		doTweenAlpha('timeTxtTweem', 'timeTxt', 0, 5, 'linear')
		
		noteTweenAlpha('notealpha0', 0, 0, 5, 'linear') --dinkleberg...
		noteTweenAlpha('notealpha1', 1, 0, 5, 'linear')
		noteTweenAlpha('notealpha2', 2, 0, 5, 'linear')
		noteTweenAlpha('notealpha3', 3, 0, 5, 'linear')
		noteTweenAlpha('notealpha4', 4, 0, 5, 'linear')
		noteTweenAlpha('notealpha5', 5, 0, 5, 'linear')
		noteTweenAlpha('notealpha6', 6, 0, 5, 'linear')
		noteTweenAlpha('notealpha7', 7, 0, 5, 'linear')
		
		doTweenY("bar_upper", "bar_upper", -200, 4, "quintout")
		doTweenY("bar_lower", "bar_lower", 720, 4, "quintout")
		
		if isStoryMode then
			setProperty('canPause', false)
			setProperty('inst.volume',0)
			playSound('kittyBattle/milkDudsCutscene', 1)
			endCutscene = true
		end
	end,
	
	[264] = function()
		if isStoryMode then
			doTweenAlpha('monster alpa', 'monster', 1, 10, 'linear')
		end
	end,
	
	[278] = function()
		if flashingLights and isStoryMode then
			doTweenAlpha('yup', 'black', 1, 6, 'linear')
			runHaxeCode([[import flixel.effects.FlxFlicker;
				FlxFlicker.flicker(game.getLuaObject('black'), 3.44, 0.075, true, true);
			]])
		end
	end,
	
	[280] = function()
		if isStoryMode then
			stopSound('talkingBGaudio')
			playAnim('gf', 'uhoh', true)
			setProperty('gf.specialAnim', true)
		end
	end,
	
	[282] = function()
		if isStoryMode then
			runTimer('blackout', 1.5) -- end
		else
			doTweenY("bar_upper", "bar_upper", -70, 11.5, "linear")
			doTweenY("bar_lower", "bar_lower", 595, 11.5, "linear")
		end
	end,
	
	[285] = function()
		if isStoryMode then
			cancelTween('yup')
			setProperty('black.alpha', 1)
			noDeath = true
		end
	end,
	
	[297] = function()
		if isStoryMode then
			endSong()
		end
	end,
	
	[308] = function()
		if not isStoryMode then
			setProperty('black.alpha', 1)
			setProperty('camHUD.alpha', 0)
			stopSound('talkingBGaudio')
		end
	end,
}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	
	end
	if curBeat % 2 == 0 then --loop
		playAnim('susie', 'idle', false)
		playAnim('bratty', 'idle', true)
		playAnim('catty', 'idle', true)
		playAnim('punkape', 'idle', true)
	end
	if curBeat % 4 == 0 then --slower loop
		playAnim('grav', 'idle', true)
	end
	
	if curBeat % 4 == 0 then --slower loop
		playAnim('lucia', 'leftIdle', false)
	end
	if curBeat % 4 == 2 then --slower loop
		playAnim('lucia', 'rightIdle', false)
	end
	
	if curBeat % 16 == 0 then 
		playAnim('catty', 'blinker', true)
	end
	
	if curBeat > 67 and curBeat < 96 then
		triggerEvent('Add Camera Zoom','0.01','0.02')
	end
	if curBeat > 227 and curBeat < 256 then 
		triggerEvent('Add Camera Zoom','0.01','0.02')
	end
end
function onStepHit() -- yea sure why not
	if curStep == 266 or curStep == 906 then
		setProperty('defaultCamZoom', 0.6)
		doTweenZoom('zoom1', 'camGame', 0.6, 0.01, 'linear')
		setProperty('cameraSpeed', 99)
    end
	
	if curStep == 268 or curStep == 908 then
		cancelTween('zoom1')
		doTweenZoom('zoom2', 'camGame', 0.7, 0.3, 'expoOut')
		
		setProperty('dad.cameraPosition', {550 + 240, 150 + 360})
    end
	
	if curStep == 269 or curStep == 909 then
		cancelTween('zoom2')
		doTweenZoom('gettinhornynow', 'camGame', 0.47, 0.35, 'expoIn') -- i swear on my life that tag is a reference to the song lyrics milk duds is originally covered from
		setProperty('cameraSpeed', 1)
    end
	
	if curStep == 272 or curStep == 912 then
		cancelTween('gettinhornynow')
		
		setProperty('dad.cameraPosition', {20 + 240, 50 + 360})
    end
end

function opponentNoteHit()
	if not roseSinging then
		health = getProperty('health')
		if getProperty('health') > 0.020 then
			setProperty('health', health- 0.020)
		end
	end
end

function setStrumVisibilty(v1,vis) --i stole this from vs whitty lmao
	strum = v1
	strumset = 'opponentStrums'

	if strum > 3 then
		strumset = 'playerStrums'
	end
		
	strum = v1 % 4
	setPropertyFromGroup(strumset,strum,'visible',vis)
end

function onTweenCompleted(name) --important
	if name == 'littleZoomInOut' then
		setProperty('defaultCamZoom',getProperty('camGame.zoom')) 
	end
end

function onGameOver() -- this is used after the story mode thingy blackout idk idc ts pmo
    if noDeath then 
		setProperty('health', 0.01)
		return Function_Stop 
	end
end