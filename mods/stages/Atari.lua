local hide = {'healthBar', 'timeTxt', 'iconP1', 'iconP2', 'bar_upper', 'bar_lower',...}
--setProperty('skipCountdown', true)
setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)
function onCreatePost()
	for _, obj in ipairs(hide) do
    setProperty(obj.. '.visible', false)
	end
	setProperty('showComboNum', false)
	setProperty('showRating', false)
	setProperty('showCombo', false)
	setProperty('introSoundsSuffix', 'nothing')
	
	makeLuaSprite('bg', 'stages/atari/bg', -180, -170)
	setLuaSpriteScrollFactor('bg', 1, 1)
	setProperty('bg.antialiasing', false)
	scaleObject('bg', 2, 2)
	addLuaSprite('bg', false)
	
	makeLuaSprite('bgRed', 'stages/atari/bgRed', -180, -170)
	setLuaSpriteScrollFactor('bgRed', 1, 1)
	setProperty('bgRed.antialiasing', false)
	scaleObject('bgRed', 2, 2)
	addLuaSprite('bgRed', false)
	setProperty('bgRed.alpha', 0.001)
	if flashingLights then 
		runHaxeCode([[import flixel.effects.FlxFlicker;
			FlxFlicker.flicker(game.getLuaObject('bgRed'), 9999, 0.1, false, true);
		]])
	end


	-- if downscroll then
		makeLuaSprite('lineCover',nil,0,16)
		makeGraphic('lineCover',192,2)
		addLuaSprite('lineCover',false)
		scaleObject('lineCover',2,2)
		setProperty('lineCover.x', getProperty('bg.x'))
		setProperty('lineCover.y', getProperty('bg.y') + (16 * 2))
		setProperty('lineCover.visible',downscroll)
		setProperty('lineCover.color', FlxColor('#FF000000'))
	-- end

	if downscroll then
		makeLuaSprite('fakeLine',nil,0,16)
		makeGraphic('fakeLine',192,2)
		addLuaSprite('fakeLine',false)
		scaleObject('fakeLine',2,2)
		setProperty('fakeLine.x', getProperty('bg.x'))
		setProperty('fakeLine.y', getProperty('bg.y') + (16 * 2))
		setProperty('fakeLine.y', getProperty('bg.y') + getProperty('bg.height') - (4 + (16 * 2)))
		setProperty('fakeLine.color', FlxColor('#78005C'))
	end
	
	makeLuaSprite('bottom_border', nil, -200, 507)
	makeGraphic('bottom_border', 1780, 300, '000000')
	setObjectCamera('bottom_border', 'other')
	addLuaSprite('bottom_border', true)
	makeLuaSprite('top_border', nil, -200, -113)
	makeGraphic('top_border', 1780, 300, '000000')
	setObjectCamera('top_border', 'other')
	addLuaSprite('top_border', true)
	
	setProperty('scoreTxt.y', 167)
	setProperty('scoreTxt.x', 445)
	setObjectOrder('scoreTxt', getObjectOrder('top_border')+1)
	setProperty('scoreTxt.antialiasing', false)
	setTextAlignment('scoreTxt', 'left')
	setObjectCamera('scoreTxt', 'other')
	setTextFont('scoreTxt', 'VGA.ttf')
	
	makeLuaText('HP', '', 0, 779, 167)
	setProperty('HP.antialiasing', false)
    setTextAlignment('HP', 'right')
	setProperty('HP.alpha', 0.75)
	scaleObject('HP', 1.2, 1)
    setTextSize('HP', 18) setTextFont('HP', 'VGA.ttf')
	setObjectCamera('HP', 'other')
    addLuaText('HP')
	
	makeLuaSprite('black', nil, -200, -113)
	makeGraphic('black', 1780, 1000, '000000')
	setObjectCamera('black', 'other')
	setProperty('black.alpha', 1)
	addLuaSprite('black', true)
	
	runTimer('fadeIn', 0.5, 4)
	setProperty('camHUD.visible', false)
end
function onUpdateScore()
setTextString('scoreTxt', 'Score: '..score)
setProperty('scoreTxt.alpha', 0.75)
if scoreZoom then
	callMethod('scoreTxtTween.cancel', {})
	scaleObject('scoreTxt', 1.2, 1)
end
end

cancelTimer = false
function noteMiss(index, noteD, noteType, isSustainNote)
	runTimer('missedFlicker', 0.001)
end
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'missedFlicker' and cancelTimer == false then
		setProperty('bgRed.alpha', 1)
		runTimer('hideRedBG', 1.5)
		cancelTimer = true
	end
	if tag == 'hideRedBG' and cancelTimer == true then
		setProperty('bgRed.alpha', 0.001)
		cancelTimer = false
	end
	
	if tag == 'fadeOut' then
	setProperty('black.alpha', getProperty('black.alpha') + 0.25)
	end
	if tag == 'fadeIn' then 
	setProperty('black.alpha', getProperty('black.alpha') - 0.25) 
	end
	if tag == 'restart' then 
	restartSong()
	end
end

function onUpdatePost(e)
    setTextString('HP',math.floor(getProperty("healthBar.percent"))..'%')

	local colour = '#FF000000'

	if getProperty('bgRed.alpha') >= 1 and getProperty('bgRed.visible') then
		colour = '#FF880000';
	end

	setProperty('lineCover.color', FlxColor(colour))
end

local noDeath = true;
function onGameOver()
	--setPropertyFromClass('Conductor', 'songPosition', getPropertyFromClass('Conductor', 'songPosition')-16)
	setPropertyFromClass('flixel.FlxG', 'sound.music.time', getPropertyFromClass('Conductor', 'songPosition'))
	setProperty('vocals.time', getPropertyFromClass('Conductor', 'songPosition'))
	setPropertyFromClass('flixel.FlxG', 'sound.music.volume', 0)
	runTimer('fadeOut', 0.25, 4)
	runTimer('restart', 1)
	if noDeath then 
		setProperty('health', 0.01);
		return Function_Stop 
	end
end
function onPause()
    --endSong()
    --return Function_Stop
end
function onSongStart()
setProperty('camHUD.visible', true)
end