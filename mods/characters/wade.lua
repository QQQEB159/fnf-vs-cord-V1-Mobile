local dogBark = "G" -- bark button

function onCreatePost()
	makeAnimatedLuaSprite('WADE_BARK', 'characters/WADE_BARK', 1060, 400);
	luaSpriteAddAnimationByPrefix('WADE_BARK', 'idle', 'bark instance 1', 24, false);
	setLuaSpriteScrollFactor('WADE_BARK', 1, 1);
	setProperty('WADE_BARK.alpha', 0);
	addLuaSprite('WADE_BARK', true);
end

function onUpdatePost(elapsed)

	if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.'.. dogBark) or callMethodFromClass('flixel.FlxG','gamepads.anyJustPressed',{9}) then -- if pressed G
		soundName = string.format('webfishing/dog/bark%i', math.random(0, 5)); -- random pitch
		playSound(soundName, 1, 'webfishing/dog/bark');	-- play bark
		playAnim('boyfriend', 'singUP', true);
		
		-- lil black bars 
		setProperty('WADE_BARK.alpha', 1);
		playAnim('WADE_BARK', 'idle', true);
	end
end

function onBeatHit()
	if curBeat % 16 == 8 and getProperty('boyfriend.animation.name') == 'idle' then -- blink
		playAnim('boyfriend', 'blink', true);
	end
end