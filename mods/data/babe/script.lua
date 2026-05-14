local allowCountdown = false
function onStartCountdown()
	if not allowCountdown and isStoryMode then -- for some reason theres a small delay when you start the week in story mode
		runTimer('start', 0.025)
		return Function_Stop
	end
	return Function_Continue
end

function onCreate()
	setProperty('camDisplacement', 15)
	setProperty('boyfriend.cameraPosition', {260 + -70, 330})
	
	setProperty('skipCountdown', true)
	doTweenZoom('TweenZoom', 'camGame', 2, 0.001, 'linear')
	cameraFlash('camHUD', '000000', 2)
	
	if not lowQuality then
		makeAnimatedLuaSprite('kris', 'stages/weekparty/bg_characters/kris_idle', -400, 400)
		luaSpriteAddAnimationByPrefix('kris', 'idle', 'krisidle instance 1', 24, false)
		setLuaSpriteScrollFactor('kris', 0.95, 0.95)
		addLuaSprite('kris', false)
		
		makeAnimatedLuaSprite('susie', 'stages/weekparty/bg_characters/susie', 20, 230)
		luaSpriteAddAnimationByPrefix('susie', 'idle', 'susie instance 1', 24, false)
		setLuaSpriteScrollFactor('susie', 0.95, 0.95)
		setObjectOrder('susie', getObjectOrder('television'))
	
	--other
	setObjectOrder('lightning_multiply', 99)
	setObjectOrder('roseCopy', getObjectOrder('lightning_multiply')+1)
	setObjectOrder('felineCopy', getObjectOrder('lightning_multiply')+1)
	setObjectOrder('marilynCopy', getObjectOrder('lightning_multiply')+1)
	
	--doTweenY('UpTween', 'camFollow', 800, 3, 'quintIn')
	--setProperty('television.visible', false)

	runHaxeCode([[
		var filter = new BlurFilter();
		filter.blurX = 4;
		filter.blurY = 4;
		FlxG.game.setFilters([filter]);
		setVar('blur', filter);
	]])
	end
end

function onDestroy()

	runHaxeCode([[
		FlxG.game.setFilters([]);
	]])

end

function onEvent(event, value1, value2, strumTime)
	if event == '' and value1 == 'init' then
		if not lowQuality then
			runHaxeCode([[
				FlxTween.tween(getVar('blur'), {blurX: 0,blurY: 0}, 2.2, {onComplete:Void->{
					FlxG.game.setFilters([]);
				}});
			]])
		end
		doTweenY('UpTween', 'camFollow', 700, 2.2, 'quintInOut')
	end
end

beatHitFuncs = {
  
	[4] = function()
		setProperty('dad.cameraPosition', {50 + 260, 50 + 370})
		setProperty('boyfriend.cameraPosition', {140 -150, 60 + 330})
	end,
}

function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	
	end

	if curBeat % 2 == 0 then --loop
		playAnim('susie', 'idle', false)
	end
end
function onStepHit() -- yea sure why not
	if curStep == 1 then
		doTweenZoom('ZoomOut', 'camGame', 0.7, 2, 'easeOut')
	end

    if curStep == 144 then
        doTweenZoom('zoom', 'camGame', 0.52, 0.5, 'quadOut')
    end
	if curStep == 208 then
        doTweenZoom('zoom', 'camGame', 0.52, 0.5, 'quadOut')
    end
	if curStep == 252 then
        -- doTweenZoom('realZoomCam', 'camGame', 0.6, 5, 'expoInOut') -- no :/
    end
	if curStep == 400 then
        doTweenZoom('realZoomCam', 'camGame', 0.5, 1.5, 'quadOut')
    end
	if curStep == 464 then
        doTweenZoom('zoom', 'camGame', 0.52, 0.5, 'quadOut')
    end
	if curStep == 656 then
        doTweenZoom('realZoomCam', 'camGame', 0.55, 3, 'sineInOut')
    end
	if curStep == 756 then
        doTweenZoom('realZoomCam', 'camGame', 0.5, 4, 'sineInOut')
    end
	if curStep == 778 then
		doTweenY("bar_upper", "bar_upper", -200, 4, "sineInOut")
		doTweenY("bar_lower", "bar_lower", 720, 4, "sineInOut")
		
		setProperty('cameraSpeed', 0.3)
		setProperty('defaultCamZoom', 0.5)
		setProperty('boyfriend.cameraPosition', {175, 60 + 280})
    end
end
function onTweenCompleted(name)
	if name == 'realZoomCam' then
		setProperty('defaultCamZoom',getProperty('camGame.zoom')) 
	end
end
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'start' then
		allowCountdown = true
		startCountdown()
	end
end

function opponentNoteHit()
    health = getProperty('health')
    if getProperty('health') > 0.020 then
        setProperty('health', health- 0.010)
    end
end