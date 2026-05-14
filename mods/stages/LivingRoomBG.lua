function onCreate()
	initLuaShader('OVERLAY')
	
	-- window bg
	makeLuaSprite('building1', 'stages/weekcord/outside0001', -450, -75) --stage 1
	setLuaSpriteScrollFactor('building1', 0, 0)
	scaleObject('building1', 0.8, 0.8)
	makeLuaSprite('building2', 'stages/weekcord/outside0002', -450, -75) --stage 2
	setLuaSpriteScrollFactor('building2', 0, 0)
	scaleObject('building2', 0.8, 0.8)
	makeLuaSprite('building3', 'stages/weekcord/outside0003', -450, -75) --stage 3
	setLuaSpriteScrollFactor('building3', 0, 0)
	scaleObject('building3', 0.8, 0.8)
	addLuaSprite('building1', false)
	addLuaSprite('building2', false)
	addLuaSprite('building3', false)
	setProperty('building1.visible', false)
	setProperty('building2.visible', false)
	setProperty('building3.visible', false)
	
	--buildings up close
	makeLuaSprite('closebuildings1', 'stages/weekcord/buildings0001', -840, -240) --stage 1
	setLuaSpriteScrollFactor('closebuildings1', 0.2, 0.2)
	makeLuaSprite('closebuildings2', 'stages/weekcord/buildings0002', -840, -240) --stage 2
	setLuaSpriteScrollFactor('closebuildings2', 0.2, 0.2)
	makeLuaSprite('closebuildings3', 'stages/weekcord/buildings0003', -840, -240) --stage 3
	setLuaSpriteScrollFactor('closebuildings3', 0.2, 0.2)
	addLuaSprite('closebuildings1', false)
	addLuaSprite('closebuildings2', false)
	addLuaSprite('closebuildings3', false)
	setProperty('closebuildings1.visible', false)
	setProperty('closebuildings2.visible', false)
	setProperty('closebuildings3.visible', false)
	scaleObject('closebuildings1', 0.8, 0.8)
	scaleObject('closebuildings2', 0.8, 0.8)
	scaleObject('closebuildings3', 0.8, 0.8)
	
	makeLuaSprite('tree', 'stages/weekcord/tree', -600, -100)
	setLuaSpriteScrollFactor('tree', 0.5, 0.5)
	scaleObject('tree', 1.2, 1.2)
	addLuaSprite('tree', false)
	setProperty('tree.angle', 20)
	
	makeLuaSprite('bg', 'stages/weekcord/cordbg', -760, -310)
	setLuaSpriteScrollFactor('bg', 0.95, 0.95)
	addLuaSprite('bg', false)
	
	if songName == 'Cat' or songName == 'Catus' then
		makeLuaSprite('openDoor', 'stages/weekcord/openDoor', 35, 70)
		setLuaSpriteScrollFactor('openDoor', 0.95, 0.95)
		addLuaSprite('openDoor', false)
	end
	
	makeAnimatedLuaSprite('boombox', 'stages/weekcord/boombox', 770, 150)
	luaSpriteAddAnimationByPrefix('boombox', 'idle', 'boombox instance 1', 24, false)
	setLuaSpriteScrollFactor('boombox', 0.95, 0.95)
	addLuaSprite('boombox', false)
	
	makeLuaSprite('lights', 'stages/weekcord/lights', -900, -530)
	setLuaSpriteScrollFactor('lights', 0.97, 0.97)
	addLuaSprite('lights', false)
	
	makeLuaSprite('chair', 'stages/weekcord/chair', -400, 735)
	setLuaSpriteScrollFactor('chair', 1.3, 1.3)
	addLuaSprite('chair', true)
	
	if not lowQuality then
		makeAnimatedLuaSprite('peekaboo', 'stages/weekcord/peekaboo', 1419, 260)
		luaSpriteAddAnimationByPrefix('peekaboo', 'crackindawallpeekaboo', 'crackindawallpeekaboo instance 1', 24, false)
		setLuaSpriteScrollFactor('peekaboo', 0.98, 0.98)
		addLuaSprite('peekaboo', true)
		setProperty('peekaboo.visible', false)
	
		makeLuaSprite('glow', 'stages/weekcord/glow', -900, -900)
		setLuaSpriteScrollFactor('glow', 0.9, 0.9)
		setProperty('glow.alpha', 0.8)
		addLuaSprite('glow', true)
		setProperty('glow.visible', false)
		
		makeLuaSprite('nightTint', 'stages/weekcord/nighttime', -630, -280)
		setLuaSpriteScrollFactor('nightTint', 0.97, 0.97)
		setProperty('nightTint.alpha', 0.1)
		setBlendMode('nightTint', 'difference')
		-- setSpriteShader('nightTint','OVERLAY')
		addLuaSprite('nightTint', true)
		setProperty('nightTint.visible', false)
		
		makeLuaSprite('windowShine', 'stages/weekcord/windowShine', -445, -250)
		setLuaSpriteScrollFactor('windowShine', 0.97, 0.97)
		scaleObject('windowShine', 1.3, 1)
		setBlendMode('windowShine', 'add')
		-- setProperty('windowShine.alpha', 0.5)
		setObjectOrder('windowShine', getObjectOrder('gfGroup') + 1)
		addLuaSprite('windowShine', false)
		setProperty('windowShine.visible', false)
	end
end

  beatHitFuncs = {

}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	
	end
	
	if curBeat % 4 == 0 then -- loop
		luaSpritePlayAnimation('boombox', 'idle', true)
	end
end