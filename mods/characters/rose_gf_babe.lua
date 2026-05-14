function onCreate()
	makeAnimatedLuaSprite('speaker', 'stages/weekparty/speaker', getProperty('gf.x') - 210, getProperty('gf.y') + 420)
	luaSpriteAddAnimationByPrefix('speaker', 'idle', 'speaker :3 instance 1', 24, false);
	addLuaSprite('speaker', false);
end
function onBeatHit()
	luaSpritePlayAnimation('speaker', 'idle', false);
end