local height = 30
function onCreatePost()



	
	makeLuaSprite('outside2', 'stages/cafe/outside2', -50, -305.5 - height)
	setScrollFactor('outside2', 0.1, 0.1)
	addLuaSprite('outside2', false)
	
	makeLuaSprite('outside1', 'stages/cafe/outside1', 170, -200 - height)
	setScrollFactor('outside1', 0.2, 0.2)
	scaleObject('outside1', 0.8, 0.8)
	addLuaSprite('outside1', false)
	
	makeLuaSprite('backwindowDark', 'stages/cafe/backwindowDark', 170, -200 - height)
	setScrollFactor('backwindowDark', 0.2, 0.2)
	scaleObject('backwindowDark', 0.8, 0.8)
	addLuaSprite('backwindowDark', false)
	setProperty('backwindowDark.visible', false)
	
	makeLuaSprite('outside0', 'stages/cafe/outside0', 420, -220 - height)
	setScrollFactor('outside0', 0.4, 0.4)
	addLuaSprite('outside0', false)
	
	makeLuaSprite('outsideDark', 'stages/cafe/outsideDark', 420, -220 - height)
	setScrollFactor('outsideDark', 0.4, 0.4)
	addLuaSprite('outsideDark', false)
	setProperty('outsideDark.visible', false)
	
	makeLuaSprite('ground', 'stages/cafe/ground', -850, 725 - height)
	setScrollFactor('ground', 0.6, 0.5)
	addLuaSprite('ground', false)


	setProperty('usesShaders', true)

	initLuaShader('skew')
	setSpriteShader('ground','skew')

	setProperty('usesShaders', getPropertyFromClass('backend.Clientprefs','data.shaders'))


	
	makeLuaSprite('bg', 'stages/cafe/bg', -620, -300 - height)
	setScrollFactor('bg', 0.7, 0.8)
	addLuaSprite('bg', false)
	
	makeLuaSprite('counters', 'stages/cafe/counters', -575, 530 - height)
	setScrollFactor('counters', 0.75, 0.85)
	addLuaSprite('counters', false)

	
	makeAnimatedLuaSprite('sleepman', 'stages/cafe/bgCharacters/sleepman', 2150, 562 - height)
	addAnimationByPrefix('sleepman', 'idle', 'guySleeping instance 1', 24, true)
	setScrollFactor('sleepman', 0.75, 0.85)
	scaleObject('sleepman', 0.9, 0.9)
	addLuaSprite('sleepman', false)
	
	makeAnimatedLuaSprite('nolim', 'stages/cafe/bgCharacters/nolim', 2390, 420 - height)
	addAnimationByPrefix('nolim', 'idle', 'nolimOnthepute instance 1', 24, true)
	setScrollFactor('nolim', 0.75, 0.85)
	addLuaSprite('nolim', false)
	
	makeLuaSprite('lamps', 'stages/cafe/lamps', -100, -400 - height)
	setScrollFactor('lamps', 0.8, 0.8)
	addLuaSprite('lamps', false)
	
	makeLuaSprite('lampGlowAdd', 'stages/cafe/lampGlowAdd', -450, -240 - height)
	setScrollFactor('lampGlowAdd', 0.8, 0.8)
	setBlendMode('lampGlowAdd', 'add')
	addLuaSprite('lampGlowAdd', true)
	
	makeLuaSprite('darkness', nil, -800, -500)
	makeGraphic('darkness', 2900, 1800, 'ACD3FF')
	setScrollFactor('darkness', 0, 0)
	setProperty('darkness.alpha', 0.1)
	setBlendMode('darkness', 'add')
	addLuaSprite('darkness', false)
	
	makeLuaSprite('seats', 'stages/cafe/seats', -682, 607) -- make sure to put the big potted plant on the left infront of the seats
	setScrollFactor('seats', 0.98, 0.98)
	addLuaSprite('seats', false)
	
	makeLuaSprite('emptyTable', 'stages/cafe/emptyTable', 710, 815)
	setScrollFactor('emptyTable', 1, 1)
	addLuaSprite('emptyTable', false)
	setProperty('emptyTable.visible', false)
	
	makeAnimatedLuaSprite('boombox', 'stages/cafe/boombox', 1795, 685)
	addAnimationByPrefix('boombox', 'idle', 'boombox instance 1', 24, false)
	setScrollFactor('boombox', 0.98, 0.98)
	addLuaSprite('boombox', false)
	setProperty('boombox.color', getColorFromHex('F2DBB9'))
	
	makeLuaSprite('drink', 'stages/cafe/drink', 135, 665)
	setScrollFactor('drink', 0.98, 0.98)
	addLuaSprite('drink', false)
	
	-- characters in seats
	
	makeAnimatedLuaSprite('ruby', 'stages/cafe/bgCharacters/ruby', 173, 345)
	addAnimationByPrefix('ruby', 'idle0', 'rubyIdle0 instance 1', 24, false)
	addAnimationByPrefix('ruby', 'blink', 'rubyBlink instance 1', 24, false)
	addAnimationByPrefix('ruby', 'idle1', 'rubyIdle1 instance 1', 24, false)
	addOffset('ruby','idle0', 2, 0)
	addOffset('ruby','blink', 2, 0)
	addOffset('ruby','idle1', 0, 0)
	setScrollFactor('ruby', 0.98, 0.98)
	addLuaSprite('ruby', false)
	setProperty('ruby.color', getColorFromHex('B8CAD8'))
	
	makeAnimatedLuaSprite('starLatte', 'stages/cafe/bgCharacters/starLatte', 1493, 504)
	addAnimationByPrefix('starLatte', 'idle0', 'starLatte0 instance 1', 24, false)
	addAnimationByPrefix('starLatte', 'blink', 'starLatteBlink instance 1', 24, false)
	addAnimationByPrefix('starLatte', 'idle1', 'starLatte1 instance 1', 24, false)
	addOffset('starLatte','idle0', 2, 2)
	addOffset('starLatte','blink', 0, 0)
	addOffset('starLatte','idle1', 0, 0)
	setScrollFactor('starLatte', 0.98, 0.98)
	addLuaSprite('starLatte', false)
	setProperty('starLatte.color', getColorFromHex('B8CAD8'))
	
	makeAnimatedLuaSprite('leah', 'stages/cafe/bgCharacters/leah', -331, 438)
	addAnimationByPrefix('leah', 'idle', 'leah instance 1', 24, true)
	setScrollFactor('leah', 0.98, 0.98)
	addLuaSprite('leah', false)
	setProperty('leah.color', getColorFromHex('B8CAD8'))
	
	-- waiter
	
	makeAnimatedLuaSprite('waiter', 'stages/cafe/bgCharacters/waiter', 1500, 400)
	addAnimationByPrefix('waiter', 'idle', 'waiter instance 1', 24, true)
	addAnimationByPrefix('waiter', 'drinkIdle', 'waiterDrinks instance 1', 28, true)
	setScrollFactor('waiter', 0.98, 0.98)
	scaleObject('waiter', 1.2, 1.2)
	addLuaSprite('waiter', true)
	playAnim('waiter', 'idle')
	
	doTweenX('waiterWalking', 'waiter', -900, 7.3, 'linear')
	
	-- foreground fauck
	
	makeLuaSprite('foregroundTable', 'stages/cafe/foregroundTable', -770, 1275)
	setScrollFactor('foregroundTable', 1.6, 1.6)
	setProperty('foregroundTable.color', getColorFromHex('B8CAD8'))
	addLuaSprite('foregroundTable', true)
	
	makeLuaSprite('chairs', 'stages/cafe/chairs', 2200, 1300)
	setScrollFactor('chairs', 1.8, 1.8)
	setProperty('chairs.color', getColorFromHex('B8CAD8'))
	addLuaSprite('chairs', true)
	
	-- overlay
	
	makeLuaSprite('multiplyGlow', 'stages/cafe/glow', -909.6, -300)
	setScrollFactor('multiplyGlow', 0.7, 0.7)
	-- setProperty('multiplyGlow.alpha', 0.5)
	setBlendMode('multiplyGlow', 'multiply')
	addLuaSprite('multiplyGlow', true)
	
	-- night
	
	makeLuaSprite('eveningOverlay', 'stages/cafe/eveningOverlay', -909.6, -300)
	setScrollFactor('eveningOverlay', 0.7, 0.7)
	setBlendMode('eveningOverlay', 'multiply')
	setProperty('eveningOverlay.alpha', 0.8)
	addLuaSprite('eveningOverlay', true)
	
	makeLuaSprite('multiplyFilter25', 'stages/cafe/multiplyFilter25', -909.6, -300)
	setScrollFactor('multiplyFilter25', 0.7, 0.7)
	setBlendMode('multiplyFilter25', 'multiply')
	setProperty('multiplyFilter25.alpha', 0.25)
	addLuaSprite('multiplyFilter25', true)
	
	setProperty('eveningOverlay.visible', false)
	setProperty('multiplyFilter25.visible', false)
	
	runHaxeCode([[
		import shaders.ColorSwap;
		var colorSwap = new ColorSwap();
		game.getLuaObject("multiplyGlow").shader = colorSwap.shader;
		
		colorSwap.hue = -0.05;
	]])
	
	makeLuaSprite('glow', 'stages/cafe/glow', -800.6, -300)
	setScrollFactor('glow', 0.7, 0.7)
	setProperty('glow.alpha', 0.5)
	addLuaSprite('glow', true)
end

local stupid = false

  beatHitFuncs = {
	[32] = function()
		stupid = true
	end,
}

function bopBoppers(beat)
	if beat % 4 == 0 then
		playAnim('ruby', 'idle0', false)
	end
	if beat % 4 == 2 then 
		playAnim('ruby', 'idle1', false)
	end
	if beat % 32 == 0 then 
		playAnim('ruby', 'blink', false)
	end
	
	-- starlatte
	if beat % 2 == 0 then
		playAnim('starLatte', 'idle1', false)
	end
	if beat % 4 == 2 then
		playAnim('starLatte', 'idle0', false)
	end
	if beat % 16 == 0 then 
		playAnim('starLatte', 'blink', false)
	end
end

function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	end
	

	bopBoppers(curBeat)
	
	if stupid == true then
		playAnim('boombox', 'idle', true)
	end
end

local hasntStarted = true
local timeUp = 0
local lastBop = 2
function onUpdatePost(e)
	setShaderFloat('ground','u_skew',(getProperty('camGame.scroll.x')-280)/6000)
	scaleObject('ground',1.5,0.2-(getProperty('camGame.scroll.y')-720)/500)

	if hasntStarted then
		timeUp = timeUp + e
		if timeUp > 1 then
			timeUp = 0
			
			bopBoppers(lastBop)

			if lastBop == 2 then
				lastBop = 4
			else
				lastBop = 2
			end
		end
	end
end

function onSongStart()
	hasntStarted = false
end