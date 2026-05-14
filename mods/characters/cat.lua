function onCreate()
	makeLuaSprite('mic', 'stages/weekcord/mic', getProperty('dad.x') + 440, getProperty('dad.y') + 255);
	setLuaSpriteScrollFactor('mic', 1, 1);
	scaleObject('mic', 0.8, 0.8);
	setObjectOrder('mic', 17)
	addLuaSprite('mic', true);
end