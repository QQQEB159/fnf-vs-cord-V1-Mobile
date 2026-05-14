function onCreatePost()
	-- setScrollFactor('gfGroup', 0.95, 0.95)

	makeLuaSprite('sky', 'stages/village/sky', -1000, -800)
	setLuaSpriteScrollFactor('sky', 0, 0);
	addLuaSprite('sky', false)
	
	makeLuaSprite('verybg', 'stages/village/verybg', -1020, -50);
	setLuaSpriteScrollFactor('verybg', 0.15, 0.15);
	addLuaSprite('verybg', false);
	
	makeLuaSprite('houses', 'stages/village/houses', -1200, -600);
	setLuaSpriteScrollFactor('houses', 0.5, 0.5);
	addLuaSprite('houses', false);
	
	makeLuaSprite('ground', 'stages/village/ground', -1400, 460);
	setLuaSpriteScrollFactor('ground', 1, 1);
	addLuaSprite('ground', false);
	
	makeAnimatedLuaSprite('speaker', 'stages/village/speaker', 140, 62)
	addAnimationByPrefix('speaker', 'idle', 'speaker instance 1', 16, false)
	setScrollFactor('speaker', 1, 1);
	addLuaSprite('speaker', false)
	
	makeLuaSprite('truck', 'stages/village/truck', 140, 103);
	setLuaSpriteScrollFactor('truck', 1, 1);
	addLuaSprite('truck', false);
	
	makeLuaSprite('foreground', 'stages/village/foreground', -1550, -1300);
	setLuaSpriteScrollFactor('foreground', 1.3, 1.3);
	addLuaSprite('foreground', true);
	
	makeLuaSprite('lensflar', 'stages/village/lensflar', 1100, -350);
	setLuaSpriteScrollFactor('lensflar', 0, 0);
	setBlendMode('lensflar', 'add')
	-- addLuaSprite('lensflar', true);
	
	-- overlay
	
	makeLuaSprite('blackBg', nil, -1100, -600)
	makeGraphic('blackBg', 3450, 1950, '000000')
	setScrollFactor('blackBg', 0, 0);
	setProperty('blackBg.alpha', 0)
	addLuaSprite('blackBg', false)
	
	if not lowQuality then
		makeLuaSprite('multiply40', nil, -1100, -600)
		makeGraphic('multiply40', 3450, 1950, 'FFCD65')
		setLuaSpriteScrollFactor('multiply40', 0, 0);
		setBlendMode('multiply40', 'multiply')
		setProperty('multiply40.alpha', 0.4)
		addLuaSprite('multiply40', true)
		
		makeLuaSprite('difference17', nil, -1100, -600)
		makeGraphic('difference17', 3450, 1950, '65659A')
		setLuaSpriteScrollFactor('difference17', 0, 0);
		setBlendMode('difference17', 'difference')
		setProperty('difference17.alpha', 0.19)
		addLuaSprite('difference17', true)
	end
end

function onUpdatePost()
	
end

  beatHitFuncs = {

}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	
	end
	
	if curBeat % 2 == 0 then
		playAnim('speaker', 'idle', false)
	end
end