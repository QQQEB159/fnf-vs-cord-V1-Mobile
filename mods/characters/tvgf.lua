function onCreate()
	if not lowQuality then
		makeLuaSprite('glow', 'characters/GF_GLOW', getProperty('gf.x') + 100, getProperty('gf.y') - 60);
		addLuaSprite('glow', true);
		setBlendMode('glow', 'add');
		
		setScrollFactor('gfGroup', 0.97, 0.97)
	end
end