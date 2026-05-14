function onCreatePost()
	--runs everything
	initLuaShader('skew')
	runTimer('waterAlphaLoop0', 0.001)
	runTimer('waterMoveLoop0', 0.001)
	runTimer('bobberLoop0', 0.001)
	runTimer('fishTween', 0.001)
	runTimer('fishUpTween', 0.001)
	
	--shader
	makeLuaSprite('downsample_shader')
	setSpriteShader('downsample_shader', 'downsample_shader')
	-- runHaxeCode([[
		-- var downsample_shader = game.getLuaObject('downsample_shader').shader;
		-- game.camGAME.filters = game.camGame.filters = [new ShaderFilter(downsample_shader)];
	-- ]])
	-- setShaderFloatArray("downsample_shader", "u_res", {1280, 720})

	makeLuaSprite('sky', 'stages/webfishing/sky', -2000, -2000);
	setLuaSpriteScrollFactor('sky', 0, 0);
	scaleObject('sky', 2, 2)
	addLuaSprite('sky', false);
	
	makeLuaSprite('water', 'stages/webfishing/water', -1000, 730);
	scaleObject('water', 1.5, 1.5)
	setLuaSpriteScrollFactor('water', 0.05, 0.05);
	addLuaSprite('water', false);
	
	if not lowQuality then
		makeAnimatedLuaSprite('fishy', 'stages/webfishing/fishy', -500, 1100)
		luaSpriteAddAnimationByPrefix('fishy', 'idle', 'fishy instance 1', 20, false);
		setLuaSpriteScrollFactor('fishy', 0.8, 0.8);
		setProperty('fishy.alpha', 0.001)
		addLuaSprite('fishy', true);
		
		makeAnimatedLuaSprite('fishy2', 'stages/webfishing/fishy2', 2100, 1200)
		luaSpriteAddAnimationByPrefix('fishy2', 'idle', 'fishy2 instance 1', 20, false);
		setLuaSpriteScrollFactor('fishy2', 1, 1);
		setProperty('fishy2.alpha', 0.001)
		addLuaSprite('fishy2', true);
	end
	
	makeLuaSprite('belowWater', 'stages/webfishing/belowWater', 469.25, 1120);
	setLuaSpriteScrollFactor('belowWater', 1, 1);
	setProperty('belowWater.alpha', 0.2)
	addLuaSprite('belowWater', false);
	
	--water overlay
	makeLuaSprite('water0', 'stages/webfishing/water0', -1000, 900);
	makeLuaSprite('water1', 'stages/webfishing/water1', -1000, 900);
	makeLuaSprite('water2', 'stages/webfishing/water2', -1000, 900);
	setLuaSpriteScrollFactor('water0', 0.8, 0.8);
	setLuaSpriteScrollFactor('water1', 0.8, 0.8);
	setLuaSpriteScrollFactor('water2', 0.8, 0.8);
	setProperty('water0.alpha', 0.001);
	setProperty('water1.alpha', 0.001);
	setProperty('water2.alpha', 0.001);
	setBlendMode('water0', 'add');
	setBlendMode('water1', 'add');
	setBlendMode('water2', 'add');
	addLuaSprite('water0', false);
	addLuaSprite('water1', false);
	addLuaSprite('water2', false);

	makeLuaSprite('otherForeground', 'stages/webfishing/otherForeground', 530.2, 963.05); --yup!
	setLuaSpriteScrollFactor('otherForeground', 1, 1);
	addLuaSprite('otherForeground', false);
	
	makeLuaSprite('veryBackground', 'stages/webfishing/veryBackground', 1700, 370);
	setLuaSpriteScrollFactor('veryBackground', 0.15, 0.15);
	addLuaSprite('veryBackground', false);
	
	makeLuaSprite('otherBackground', 'stages/webfishing/otherBackground', -20, 460);
	setLuaSpriteScrollFactor('otherBackground', 0.3, 0.3);
	addLuaSprite('otherBackground', false);
	
	makeLuaSprite('background', 'stages/webfishing/background', 400, 80);
	setLuaSpriteScrollFactor('background', 0.35, 0.35);
	addLuaSprite('background', false);
	
	makeAnimatedLuaSprite('alienCat', 'stages/webfishing/alienCat', 100, 10)
	luaSpriteAddAnimationByPrefix('alienCat', 'catch', 'catch instance 1', 24, false);
	luaSpriteAddAnimationByPrefix('alienCat', 'reel', 'reel instance 1', 24, true);
	luaSpriteAddAnimationByPrefix('alienCat', 'idle', 'idle instance 1', 24, true);
	setLuaSpriteScrollFactor('alienCat', 0.35, 0.35);
	playAnim('alienCat', 'idle', true);
	addLuaSprite('alienCat', false);
	
	makeLuaSprite('backgroundFog', 'stages/webfishing/backgroundFog', 400, 150);
	setLuaSpriteScrollFactor('backgroundFog', 0.4, 0.4);
	addLuaSprite('backgroundFog', false);
	
	makeLuaSprite('otherMidGround', 'stages/webfishing/otherMidGround', 1220, 160);
	setLuaSpriteScrollFactor('otherMidGround', 0.65, 0.65);
	addLuaSprite('otherMidGround', false);
	
	makeLuaSprite('midGround', 'stages/webfishing/midGround', 910, -30);
	setLuaSpriteScrollFactor('midGround', 0.75, 0.75);
	addLuaSprite('midGround', false);
	
	makeLuaSprite('boombox', 'stages/webfishing/boombox', 1120, 830);
	setLuaSpriteScrollFactor('boombox', 0.85, 0.85);
	addLuaSprite('boombox', false);
	
	--above characters
	makeLuaSprite('foreGround', 'stages/webfishing/foreGround', 1116.05, 833.3);
	setLuaSpriteScrollFactor('foreGround', 1, 1);
	addLuaSprite('foreGround', true);
	
	makeLuaSprite('fuckassfish', 'stages/webfishing/fuckassfish', 1670, 350); --for the fish buddy!!! : 3
	setLuaSpriteScrollFactor('fuckassfish', 0.9, 0.9);
	setProperty('fuckassfish.alpha', 0.001) -- making it this so it pre-loads instead of not loading
	addLuaSprite('fuckassfish', false);
	
	makeAnimatedLuaSprite('waterFlow', 'stages/webfishing/waterFlow', 529.85, 1143.65)
	luaSpriteAddAnimationByPrefix('waterFlow', 'idle', 'whiteWater instance 1', 24, true);
	setLuaSpriteScrollFactor('waterFlow', 1, 1);
	addLuaSprite('waterFlow', true);
	
	makeAnimatedLuaSprite('bobber', 'stages/webfishing/bobber', 730, 1280)
	luaSpriteAddAnimationByPrefix('bobber', 'idle', 'bobber instance 1', 24, true);
	setLuaSpriteScrollFactor('bobber', 1.5, 1.5);
	addLuaSprite('bobber', true);
	
	makeLuaSprite('catchPing', 'stages/webfishing/ui/catchPing', -400, 17.95); --bait
	setObjectCamera('catchPing', 'other')
	scaleObject('catchPing', 0.8, 0.8) -- original is too BIG! like your MOM
	addLuaSprite('catchPing', true);
	
	makeLuaSprite('filter', 'stages/webfishing/filter', -2000, -2000);
	setLuaSpriteScrollFactor('filter', 0, 0);
	setBlendMode('filter', 'multiply');
	setProperty('filter.alpha', 1)
	scaleObject('filter', 2, 2)
	addLuaSprite('filter', true);
	
	--THIS IS OVER EVERYTHING!!!
	if not lowQuality then
		makeLuaSprite('tint', 'stages/weekcord/tint', -400, -300);
		setLuaSpriteScrollFactor('tint', 0, 0);
		scaleObject('tint', 3, 3);
		setProperty('tint.alpha', 1)
		setBlendMode('tint', 'add');
		addLuaSprite('tint', true);
		
		makeLuaSprite('blov2', 'stages/weekcord/badluckfilter', -450, -200)
		setLuaSpriteScrollFactor('blov', 0, 0);
		setProperty('blov2.alpha', 0.2)
		setBlendMode('blov2', 'multiply');
		scaleObject('blov2', 3, 3);
		addLuaSprite('blov2', true);
	end
	
	setObjectOrder('otherForeground', getObjectOrder('dadGroup')-1) --put dad sprite behind otherForeground
	setObjectOrder('otherForeground', getObjectOrder('boyfriendGroup')-1) --put bf sprite over otherForeground
	
	setScrollFactor('gfGroup', 0.9, 0.9)
	setScrollFactor('dadGroup', 0.9, 0.9)
	
	--shader to sprite
	setSpriteShader('water0','skew')
	setSpriteShader('water1','skew')
	setSpriteShader('water2','skew')
end

function onUpdatePost()
	--thank you bbpanzu
	setShaderFloat('water0', 'u_skew',(getProperty('camGame.scroll.x') -280) / 4000)
	scaleObject('water0', 1.4, 0.5 - (getProperty('camGame.scroll.y') -720) / 2000)
	
	setShaderFloat('water1', 'u_skew',(getProperty('camGame.scroll.x') -280) / 4000)
	scaleObject('water1', 1.4, 0.5 - (getProperty('camGame.scroll.y') -720) / 2000)

	setShaderFloat('water2', 'u_skew',(getProperty('camGame.scroll.x') -280) / 4000)
	scaleObject('water2', 1.4, 0.5 - (getProperty('camGame.scroll.y') -720) / 2000)
end

function onTimerCompleted(tag, loops, loopsLeft)
	-- opacity
		if tag == 'waterAlphaLoop0' then
			doTweenAlpha('water0TweenIn', 'water0', 0.5, 3, 'linear');
			doTweenAlpha('water2TweenOut', 'water2', 0.001, 3, 'linear');
			runTimer('waterAlphaLoop1', 3.5) --loop 1
		end
		if tag == 'waterAlphaLoop1' then
			doTweenAlpha('water1TweenIn', 'water1', 0.5, 3, 'linear');
			doTweenAlpha('water0TweenOut', 'water0', 0.001, 3, 'linear');
			runTimer('waterAlphaLoop2', 3.5) --loop 2
		end
		if tag == 'waterAlphaLoop2' then
			doTweenAlpha('water2TweenIn', 'water2', 0.5, 3, 'linear');
			doTweenAlpha('water1TweenOut', 'water1', 0.001, 3, 'linear');
			runTimer('waterAlphaLoop0', 3.5) --loop 3
		end
	-- moving
	if tag == 'waterMoveLoop0' then
		doTweenX('water0moveIn', 'water0', -950, 4, 'quadInOut')
		doTweenX('water1moveOut', 'water1', -1050, 4, 'quadInOut')
		doTweenX('water2moveIn', 'water2', -1100, 4, 'quadInOut')
		runTimer('waterMoveLoop1', 4.1) --loop 1
	end
	if tag == 'waterMoveLoop1' then
		doTweenX('water0moveOut', 'water0', -1050, 4, 'quadInOut')
		doTweenX('water1moveIn', 'water1', -950, 4, 'quadInOut')
		doTweenX('water2moveOut', 'water2', -900, 4, 'quadInOut')
		runTimer('waterMoveLoop0', 4.1) --loop 2
	end
	-- for the bobber
		if tag == 'bobberLoop0' then
			doTweenY('bobberUp', 'bobber', 1265, 2.4, 'quadInOut')
			runTimer('bobberLoop1', 2.5) --loop 1
		end
		if tag == 'bobberLoop1' then
			doTweenY('bobberUp', 'bobber', 1280, 2.4, 'quadInOut')
			runTimer('bobberLoop0', 2.5) --loop 2
		end
	-- for the fish thing
	if tag == 'fishUpTween' then
		doTweenY('fishUp', 'fuckassfish', 300, 1.5, 'quadInOut')
		runTimer('fishDownTween', 1.55) --loop 1
	end
	if tag == 'fishDownTween' then
		doTweenY('fishDown', 'fuckassfish', 350, 1.5, 'quadInOut')
		runTimer('fishUpTween', 1.55) --loop 2
	end
	
	-- OH MY GODDD SO MANY TIMERS
	if tag == 'runPing' then
		doTweenX('pingSlideIn', 'catchPing', 13.65, 0.2, 'quadOut')
		runTimer('pingBye', 4)
	end
	if tag == 'pingBye' then
		doTweenX('pingSlideOut!', 'catchPing', -400, 0.2, 'quadIn')
	end
	
	--okay moving on...
	
	if tag == 'fishHide' then --for fishys
		doTweenAlpha('fishHide', 'fishy', 0.001, 0.5, 'linear');
		doTweenAlpha('fish2Hide', 'fishy2', 0.001, 0.5, 'linear');
	end
end

  beatHitFuncs = {
	
	[36] = function() -- buddy catch stuff
		setProperty('fuckassfish.alpha', 1)
		playAnim('gf', 'catch')
		playSound('webfishing/ping')
		runTimer('runPing', 0.001)
	end,
}

fishSpawned = false;
fishCooldown = 0;

function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	
	end
	
	if not fishSpawned then
		fishCooldown = fishCooldown + 1;
	end
	
	math.randomseed(os.time()); --yyup!
	if curBeat % 16 == 8 and math.random(0, 9) <= 3 and not fishSpawned and fishCooldown > 8 then
		math.randomseed(os.time() + curBeat * 4); --MATH MATH MATH
		fishCooldown = math.random(-4, 0);
		fishSpawn(); --ooh i know what this one does!
	end
end

function fishSpawn()
	runTimer('fishHide', 1.1)
	if getRandomInt(1, 2) == 1 then
		playAnim('fishy', 'idle')
		doTweenAlpha('fishShow', 'fishy', 0.3, 0.3, 'linear');
	else
		playAnim('fishy2', 'idle')
		doTweenAlpha('fish2Show', 'fishy2', 0.3, 0.3, 'linear');
	end
end