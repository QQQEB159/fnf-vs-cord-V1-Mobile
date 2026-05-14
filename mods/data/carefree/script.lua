luaDebugMode = true

local skipIntro = false -- TOGGLE FALSE FOR RELEASE
ui = 150

if downscroll then
ui = 0
end

if skipIntro then
	setProperty('boyfriend.cameraPosition', {0, -20})
	setProperty('dad.cameraPosition', {0, 40})
end

-- hide the countdown cus its fun
local m = {'Ready', 'Set', 'Go'}
function onCountdownTick(c)
    if c == 0 or c == 4 then return end
    callMethod('countdown'..m[c]..'.kill', {''})
end
setProperty('introSoundsSuffix', 'nothing')

function onCreatePost()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'mustPress') == false then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'noteSkins/DjNOTE_assets')
			setPropertyFromGroup('unspawnNotes', i, 'offsetX',  -8)

			if getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') then
				setPropertyFromGroup('unspawnNotes', i, 'offsetX',  -2)
				setPropertyFromGroup('unspawnNotes', i, 'scale.y', getPropertyFromGroup('unspawnNotes', i, 'scale.y') - 0.2)
				setPropertyFromGroup('unspawnNotes', i, 'offset.y', getPropertyFromGroup('unspawnNotes', i, 'offset.y') + 15)
			end
		end
    end

	if not skipIntro then
		setProperty('boyfriend.cameraPosition', {-900, -20})
		setProperty('black.alpha', 1)
		
		setProperty('bar_upper.alpha', 0)
		setProperty('bar_lower.alpha', 0)
		
		-- setProperty('healthBar.alpha', 0);
		-- setProperty('iconP1.alpha', 0);
		-- setProperty('iconP2.alpha', 0);
		-- setProperty('scoreTxt.alpha', 0);
		
		setProperty('healthBar.y', getProperty('healthBar.y')+ui);
		setProperty('iconP1.y', getProperty('iconP1.y')+ui);
		setProperty('iconP2.y', getProperty('iconP2.y')+ui);
		setProperty('scoreTxt.y', getProperty('scoreTxt.y')+ui);
	end
	
	setProperty('camHUD.alpha', 0)
	setProperty('camDisplacement', 10)
	setObjectCamera('black', 'camother')

	makeFlxAnimateSprite('thoughtBubble', 268, -354, 'stages/cafe/thoughtBubble')
	addAnimationBySymbol('thoughtBubble', 'idle', '.EXPORTABLE ASSETS/thoughtBubbleCutscene')
	addLuaSprite('thoughtBubble', true)
	setProperty('thoughtBubble.visible', false)
	
	runHaxeCode([[
		var filter = new BlurFilter();
		filter.blurX = 4;
		filter.blurY = 4;
		FlxG.game.setFilters([filter]);
		setVar('blur', filter);
	]])
end

function onDestroy()
	runHaxeCode([[
		FlxG.game.setFilters([]);
	]])
end

function onCountdownStarted()
	runHaxeCode([[
		for (i in 0...4) {
			FlxTween.cancelTweensOf(opponentStrums.members[i], ['alpha']);
			opponentStrums.members[i].alpha = 0;
		}
	]])

	for i = 0, 3 do
		setPropertyFromGroup('opponentStrums', i, 'texture', 'noteSkins/DjNOTE_assets')
		-- setPropertyFromGroup('opponentStrums', i, 'alpha', '1')
    end
end

local healthbarDecrease = true;
function onUpdatePost()
	if healthbarDecrease == true then
		health = getProperty('health')
		if getProperty('health') > 0.1 then
			setProperty('health', health- 0.005);
		end
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if not skipIntro then
		if tag == 'camTween' then 
			doTweenX('cameraTweenLeft','camFollowPos', 1025, 7, 'expoInOut')
		end
		if tag == 'startCountdown' then 
			startCountdown()
			setProperty('boyfriend.cameraPosition', {0, -20})
			setProperty('dad.cameraPosition', {0, 40})
		end
		if tag == 'zoom' then
			doTweenZoom('zoomTween', 'camGame', 0.65, 7, 'smootherStepInOut');	
		end
	end
	
	if tag == 'other' then
		if getPropertyFromClass('backend.ClientPrefs','data.streamerMode') then -- oh my god
			playSound('carefree/StreamerRadio'..getRandomInt(1, 3), 0.2,'streamAudio')
		else
			playSound('carefree/radio'..getRandomInt(0, 12), 0.3)
		end
		playSound('talkingBGaudio', 1,'bgAudio')	
		doTweenAlpha('black', 'black', 0, 5, 'linear');
		
		runHaxeCode([[
			if (getVar('blur') == null) {
				FlxG.game.setFilters([]);
				return;
			}
			FlxTween.tween(getVar('blur'),{blurX: 0,blurY: 0},2.75, {onComplete:Void->{
				FlxG.game.setFilters([]);
			}});
		]])
	end
end

  beatHitFuncs = {
	[1] = function()
		if not skipIntro then
			cancelTween('bar_upper')
			cancelTween('bar_lower')
			doTweenY('NOP', 'bar_upper', -200, 0.001, 'quintout')
			doTweenY('NUH UH', 'bar_lower', 720, 0.001, 'quintout')
		end
		
		healthbarDecrease = false;
	end,
	
	[9] = function()
		doTweenAlpha('hudAlpha', 'camHUD', 1, 3, 'linear')
	end,
	
	[16] = function()
		doTweenZoom('zoomOUT', 'camGame', 0.55, 10, 'smootherStepInOut');	
	end,
	
	[32] = function()
		if not skipIntro then
			setProperty('bar_upper.alpha', 1)
			setProperty('bar_lower.alpha', 1)
		
			doTweenY('bar_upper', 'bar_upper', -120, 2, 'quintout')
			doTweenY('bar_lower', 'bar_lower', 635, 2, 'quintout')
			
			doTweenY('healthTween', 'healthBar', getProperty('healthBar.y') - ui, 2, 'quintout')
			doTweenY('iconP1Tween', 'iconP1', getProperty('iconP1.y') - ui, 2, 'quintout')
			doTweenY('iconP2Tween', 'iconP2', getProperty('iconP2.y') - ui, 2, 'quintout')
			doTweenY('scoreTween', 'scoreTxt', getProperty('scoreTxt.y') - ui, 2, 'quintout')
		end
	end,
	
	[40] = function()
		runHaxeCode([[
			for (i in 0...4) {
				FlxTween.tween(opponentStrums.members[i], {alpha: 0.75}, 4);
			}
		]])
	end,
	
	[64] = function()
		setProperty('boyfriend.cameraPosition', {0, -10})
		setProperty('dad.cameraPosition', {0, 50})
	end,
	
	[82] = function()
		setProperty('waiter.flipX', true)
		playAnim('waiter', 'drinkIdle')
		setProperty('waiter.x', -900)
		doTweenX('waiterWalking', 'waiter', 2700, 7, 'linear')
	end,
	
	[96] = function()
		setProperty('camZooming', false)
		doTweenZoom('zoomOUT', 'camGame', 0.45, 7, 'smootherStepInOut');
		setProperty('dad.cameraPosition', {30, -140})
		setProperty('cameraSpeed', 0.15);
		
		doTweenY('cameraUp','camFollowPos', 550, 7, 'expoInOut')
		
		runHaxeCode([[
			for (i in 0...4) {
				FlxTween.tween(opponentStrums.members[i], {alpha: 0}, 4);
				FlxTween.tween(playerStrums.members[i], {alpha: 0}, 4);
			}
		]])
	end,

	[100] = function()
		setProperty('thoughtBubble.visible', true)
		playAnim('thoughtBubble', 'idle')
	end,
	
	[110] = function()
		setProperty('dad.cameraPosition', {70, -140})
		doTweenX('cameraTweenLeft','camFollowPos', 1070, 2.5, 'smootherStepInOut')
	end,
	
	[111] = function()
		setObjectOrder('waiter', getObjectOrder('seats')-1)
		setProperty('waiter.flipX', false)
		playAnim('waiter', 'drinkIdle')
		setProperty('waiter.x', 2400)
		doTweenX('waiterWalking', 'waiter', -1000, 6.5, 'linear')
		
		setProperty('waiter.y', 290)
		scaleObject('waiter', 1, 1)
	end,
	
	[124] = function()
		triggerEvent('Screen Shake','0.6, 0.002','0.015, 0.005')
		
		runHaxeCode([[
			for (i in 0...4) {
				FlxTween.tween(opponentStrums.members[i], {alpha: 0.75}, 2);
				FlxTween.tween(playerStrums.members[i], {alpha: 0.75}, 2);
			}
		]])
		
		doTweenY('cameraDown','camFollowPos', 750, 4, 'expoInOut')
		doTweenZoom('zoomOUT', 'camGame', 0.45, 1, 'smootherStepOut');
	end,
	
	[126] = function()
		cancelTween('zoomOUT')
		doTweenZoom('zoomIn', 'camGame', 0.65, 2, 'smootherStepIn');
		doTweenX('cameraTweenLeft','camFollowPos', 1150, 2, 'smootherStepIn')
	end,
	
	[128] = function()
		cancelTween('cameraDown')
		cancelTween('zoomIn')
		cancelTween('cameraTweenLeft')
		
		setProperty('camZooming', true)
		setProperty('cameraSpeed', 1);
		setProperty('defaultCamZoom', 0.65)
		setProperty('boyfriend.cameraPosition', {0, 0})
		setProperty('dad.cameraPosition', {0, 60})
		
		
		-- setObjectCamera('black', 'camGame')
		-- setObjectOrder('black', getObjectOrder('seats')-1)
		
		-- doTweenAlpha('blackAlpha', 'black', 0.4, 1, 'smootherStepOut');
		-- doTweenAlpha('multiplyGlowTween', 'multiplyGlow', 0.35, 1, 'smootherStepOut');
		-- doTweenAlpha('glowAlpha', 'glow', 0.2, 1, 'smootherStepOut');
	end,
	
	-- [144] = function()
		-- doTweenAlpha('blackAlpha', 'black', 0.3, 1, 'smootherStepOut');
		-- doTweenAlpha('multiplyGlowTween', 'multiplyGlow', 0.7, 1, 'smootherStepOut');
		-- doTweenAlpha('glowAlpha', 'glow', 0.35, 1, 'smootherStepOut');
	-- end,
	
	-- [160] = function()
		-- doTweenAlpha('blackAlpha', 'black', 0, 1, 'smootherStepOut');
		-- doTweenAlpha('multiplyGlowTween', 'multiplyGlow', 1, 1, 'smootherStepOut');
		-- doTweenAlpha('glowAlpha', 'glow', 0.5, 1, 'smootherStepOut');
	-- end,
	
	[192] = function()
		setProperty('camZooming', false)
		doTweenZoom('zoomOUT', 'camGame', 0.45, 13, 'smootherStepInOut');
		setProperty('dad.cameraPosition', {40, 20})
		setProperty('cameraSpeed', 0.1);
		
		doTweenY('cameraUp','camFollowPos', 710, 9, 'sineInOut')
		
		runHaxeCode([[
			for (i in 0...4) {
				FlxTween.tween(opponentStrums.members[i], {alpha: 0}, 4);
				FlxTween.tween(playerStrums.members[i], {alpha: 0}, 4);
			}
		]])
		
		doTweenAlpha('iconP1', 'iconP1', 0, 4, 'linear');
		doTweenAlpha('iconP2', 'iconP2', 0, 4, 'linear');
		doTweenAlpha('scoreTxt', 'scoreTxt', 0, 4, 'linear');
		doTweenAlpha('healthBar', 'healthBar', 0, 4, 'linear');
	end,
	
	[220] = function()
		stopSound('bgAudio')
		-- setObjectCamera('black', 'other')
		doTweenZoom('zoomOUT', 'camGame', 0.45, 3.5, 'smootherStepOut');
	
		setProperty('dadGroup.visible', false)
		setProperty('boyfriendGroup.visible', false)
		setProperty('emptyTable.visible', true)
		setProperty('drink.visible', false)
		
		setProperty('outside1.visible', false)
		setProperty('outside0.visible', false)
		setProperty('outsideDark.visible', true)
		setProperty('backwindowDark.visible', true)
		
		-- bg characters
		
		setProperty('sleepman.visible', false)
		setProperty('nolim.visible', false)
		setProperty('ruby.visible', false)
		setProperty('starLatte.visible', false)
		setProperty('leah.visible', false)
		
		setProperty('boombox.visible', false)
		
		-- overlay
		
		setProperty('multiplyGlow.visible', false)
		setProperty('eveningOverlay.visible', true)
		setProperty('multiplyFilter25.visible', true)
	end,
	
	[222] = function()
		doTweenAlpha('black', 'black', 1, 5, 'linear');
	end,
}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	
	end
end

-- gameplay stuff

local allowCountdown = false;
function onStartCountdown()
	if not allowCountdown and not skipIntro then
			runTimer('zoom', 6);
			runTimer('startCountdown', 4);
			runTimer('camTween', 1);
			runTimer('other', 1);
		allowCountdown = true
		return Function_Stop;
	end
	return Function_Continue;
end

function opponentNoteHit()
	health = getProperty('health')
	if getProperty('health') > 0.05 then
		setProperty('health', health- 0.0055);
	end
end
function goodNoteHit()
	health = getProperty('health')
	setProperty('health', health- 0.01); -- make the note gain a little less because hello i hate you fuck you -president frog
end
local noDeath = true;
function onGameOver() -- doing this because im too lazy to make a death screen LOL
    if noDeath then 
		playAnim('boyfriend', 'die'..getRandomInt(1,2), true)
		playSound('carefree/glassShatter', 0.25) -- dude this is so loud
		setProperty('health', 0.01); -- this makes it so the healthbar doesnt infinitely drain
		return Function_Stop 
	end
end

function noteMiss(index, noteData, noteType, isSustain)
	playAnim('boyfriend', 'die'..getRandomInt(1,2), true)
end

function onSongStart()
	if not skipIntro then
		setProperty("inst.volume", 0)
		callMethod('inst.fadeIn',{2})
	end
end

function onPause()
	runHaxeCode([[
		if (inst.fadeTween != null) inst.fadeTween.active = false;
	]])

	pauseSound('streamAudio')
	pauseSound('bgAudio')
end

function onResume()
	runHaxeCode([[
		if (inst.fadeTween != null) inst.fadeTween.active = true;
	]])

	resumeSound('streamAudio')
	resumeSound('bgAudio')
end

function onDestroy()
	runHaxeCode([[
		if (inst.fadeTween != null) inst.fadeTween.cancel();
	]])
end