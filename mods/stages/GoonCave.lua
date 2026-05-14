local lightningStrikes = true;
local lightningStrikeBeat = 0
local lightningOffset = 8

function onCreate()
	-- main bg image
	
	makeLuaSprite('bg', 'stages/weekparty/bg', -410, -340)
	setScrollFactor('bg', 0.95, 0.95);
	addLuaSprite('bg', false);
	
	if flashingLights and shadersEnabled then
		makeLuaSprite('shaderImage', 'stages/weekparty/bg', -410, -340) -- lets go baby (awesome fucking SHADER)
		setScrollFactor('shaderImage', 0.95, 0.95);
		setBlendMode('shaderImage', 'add');
		setProperty('shaderImage.visible', false);
		addLuaSprite('shaderImage', true);
	end
	
	if not lowQuality then
		initLuaShader('FOG')
		runTimer('startMistLoop', 0.001)
		
		makeLuaSprite('mistBack', 'stages/weekparty/mistBack', -400, -100)
		setScrollFactor('mistBack', 0.9, 0.9)
		setBlendMode('mistBack', 'add');
		scaleObject('mistBack', 2, 2);
		setProperty('mistBack.alpha', 0.25)
		addLuaSprite('mistBack', true);
		
		makeLuaSprite('mistMid', 'stages/weekparty/mistMid', -400, -100)
		setScrollFactor('mistMid', 1.1, 1.1)
		setBlendMode('mistMid', 'add');
		scaleObject('mistMid', 2, 2);
		setProperty('mistMid.alpha', 0.25)
		addLuaSprite('mistMid', true);
	end
	
	-- bg stuff
	
	makeAnimatedLuaSprite('recordPlayer', 'stages/weekparty/recordPlayer', 290, 545)
	luaSpriteAddAnimationByPrefix('recordPlayer', 'idle', 'recordplayer instance 1', 24, true);
	setScrollFactor('recordPlayer', 0.95, 0.95);
	addLuaSprite('recordPlayer', false);
	
	makeLuaSprite('plumpkin', 'stages/weekparty/plumpkin', 410, 840) --blumpkin
	setScrollFactor('plumpkin', 0.95, 0.95);
	addLuaSprite('plumpkin', false);
	
	makeLuaSprite('plant', 'stages/weekparty/plant', 50, 570)
	setScrollFactor('plant', 0.95, 0.95);
	addLuaSprite('plant', true);
	
	makeLuaSprite('poles', 'stages/weekparty/poles', -60, -150)
	setScrollFactor('poles', 1.2, 1);
	addLuaSprite('poles', true);
	
	makeLuaSprite('pole2', 'stages/weekparty/pole2', 2230, -150)
	setScrollFactor('pole2', 1.2, 1);
	addLuaSprite('pole2', true);
	
	-- overlay .
	
	if not lowQuality then
		makeAnimatedLuaSprite('television', 'stages/weekparty/television/tv_screen', 385, -5)
		luaSpriteAddAnimationByPrefix('television', 'idle', 'static instance 1', 24, true);
		luaSpriteAddAnimationByPrefix('television', 'monster', 'monstertv instance 1', 48, true);
		luaSpriteAddAnimationByPrefix('television', 'news', 'tv instance 1', 24, true);
		luaSpriteAddAnimationByPrefix('television', 'flash', 'shootstat instance 1', 24, false);
		luaSpriteAddAnimationByPrefix('television', 'fnaf', 'fnaf instance 1', 24, true);
		setScrollFactor('television', 1.05, 1.05);
		addLuaSprite('television', false);
		
		makeLuaSprite('TV', 'stages/weekparty/television/TV', 300, -565)
		setScrollFactor('TV', 1.05, 1.05);
		addLuaSprite('TV', false);
		
		makeLuaSprite('tvglow', 'stages/weekparty/tvglow', 200, -160)
		setScrollFactor('tvglow', 1, 1);
		setBlendMode('tvglow', 'add');
		addLuaSprite('tvglow', false);
		
		makeLuaSprite('overlay', 'stages/weekparty/overlay_add', -410, -250)
		setScrollFactor('overlay', 1, 1);
		setBlendMode('overlay', 'add');
		addLuaSprite('overlay', true);
		
		makeLuaSprite('mistFront', 'stages/weekparty/mistFront', -100, 50)
		setScrollFactor('mistFront', 1.7, 1.7)
		setBlendMode('mistFront', 'add');
		scaleObject('mistFront', 2, 2);
		setProperty('mistFront.alpha', 0.25)
		addLuaSprite('mistFront', true);
		
		makeLuaSprite('lightning_multiply', 'stages/weekparty/lightning_multiply', -450, -350)
		setScrollFactor('lightning_multiply', 1, 1);
		setBlendMode('lightning_multiply', 'multiply');
		setProperty('lightning_multiply.alpha', 0.001)
		addLuaSprite('lightning_multiply', true);
		
		if songName == 'Babe' then createInstance('roseCopy', 'objects.Character', {1137, 320, 'rose_gf_babe', false}) -- babe
		elseif songName == 'Dejala' then  createInstance('roseCopy', 'objects.Character', {1137, 320, 'rose_gf_dejala', false}) -- dejala
		elseif songName == 'Milk Duds' then createInstance('roseCopy', 'objects.Character', {1137, 320, 'rose_gf_milkduds', false}) -- milk duds
		else createInstance('roseCopy', 'objects.Character', {1137, 320, 'rose_gf_babe', false}) --just defaults to babe if it doesnt work lol
		end



		setProperty('roseCopy.alpha', 0.001)
		addInstance('roseCopy',true)
		
		createInstance('felineCopy', 'objects.Character', {1633, 541, 'feline', true})
		setProperty('felineCopy.alpha', 0.001)
		addInstance('felineCopy',true)
		
		createInstance('marilynCopy', 'objects.Character', {620, 330, 'marilyn', false})
		setProperty('marilynCopy.alpha', 0.001)
		addInstance('marilynCopy',true)

		setProperty('felineCopy.atlas.useRenderTexture', true)
		setProperty('roseCopy.atlas.useRenderTexture', true)
		setProperty('marilynCopy.atlas.useRenderTexture', true)


	end
	
	makeLuaSprite('partyLights', nil, -1500, -700)
	makeGraphic('partyLights', 1, 1, 'FFFFFF')
	-- scaleObject('partyLights',1000,1000)
	setScrollFactor('partyLights', 0, 0);
	scaleObject('partyLights', 4 * 1000, 4 * 1000);
	setBlendMode('partyLights', 'multiply'); -- perfect... they wont see it coming...
	addLuaSprite('partyLights', true);
	
	-- OVER EVERYTHING.
	
	-- makeLuaSprite('black', 'black', -570, -310)
	-- scaleObject('black', 4, 4);
	-- setProperty('black.alpha', 0)
	-- addLuaSprite('black', true);
	
	precacheSound('thunder_1')
	precacheSound('thunder_2')
end

function onUpdatePost(elapsed)
	-- setShaderFloat('fogShader', 'iTime', getSongPosition() / 1000)

	if inGameOver then return end
	
	-- feline lightning effect
	if getProperty('felineCopy.__previousAnim') ~= getProperty('boyfriend.__previousAnim') then 
	playAnim('felineCopy', getProperty('boyfriend.__previousAnim'),true) end

	if getProperty('felineCopy.animCurFrame') ~= getProperty('boyfriend.animCurFrame') then 
	setProperty('felineCopy.animCurFrame', getProperty('boyfriend.animCurFrame')) end
	
	-- rose lightning effect
	if getProperty('roseCopy.__previousAnim') ~= getProperty('gf.__previousAnim') then 
	playAnim('roseCopy', getProperty('gf.__previousAnim'),true) end
	if getProperty('roseCopy.animCurFrame') ~= getProperty('gf.animCurFrame') then 
	setProperty('roseCopy.animCurFrame', getProperty('gf.animCurFrame')) end
	
	-- marilyn lightning effect
	if getProperty('marilynCopy.__previousAnim') ~= getProperty('dad.__previousAnim') then 
	playAnim('marilynCopy', getProperty('dad.__previousAnim'),true) end
	if getProperty('marilynCopy.animCurFrame') ~= getProperty('dad.animCurFrame') then 
	setProperty('marilynCopy.animCurFrame', getProperty('dad.animCurFrame')) end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startMistLoop' then -- fog
		runTimer('mistLoop1', 0.001)
	end
	
	if tag == 'mistLoop1' then --loop .
		doTweenAlpha('mistFade0', 'mistFront', 0.2, 1, 'linear'); -- fade out fog
		doTweenAlpha('mistFade1', 'mistMid', 0.25, 1, 'linear');
		doTweenAlpha('mistFade2', 'mistBack', 0.25, 1, 'linear');
		runTimer('mistLoop2', 1.5)
	end
	if tag == 'mistLoop2' then
		doTweenAlpha('mistFade3', 'mistFront', 0.35, 1, 'linear'); -- fade out fog
		doTweenAlpha('mistFade4', 'mistMid', 0.3, 1, 'linear');
		doTweenAlpha('mistFade5', 'mistBack', 0.3, 1, 'linear');
		runTimer('mistLoop1', 1.5)
	end
end

function onCreatePost()
	runHaxeCode([[
		if (gf.atlas != null) gf.atlas.useRenderTexture = true;
		if (dad.atlas != null) dad.atlas.useRenderTexture = true;
		if (boyfriend.atlas != null) boyfriend.atlas.useRenderTexture = true;
	]])

end

function onGameOverStart()
	setProperty('camFollow.x', getMidpointX('boyfriend') + 40)
	setProperty('camFollow.y', getMidpointY('boyfriend') + 50)
end

  beatHitFuncs = {

}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	
	end

	-- lightning
	if getRandomBool(1) and curBeat > lightningStrikeBeat + lightningOffset and songName ~= 'freak' and lightningStrikes == true and flashingLights and not lowQuality then
		lightningStrikeShit()
	end
end

function lightningStrikeShit()
	lightningStrikeBeat = curBeat
	lightningOffset = getRandomInt(8, 24)
	
	-- lightning
	setProperty('white.alpha', 0.3)
	setBlendMode('white', 'add')
	doTweenAlpha('white go away', 'white', 0.001, 0.2, 'quadIn')
	
	setProperty('lightning_multiply.alpha', 1)
	doTweenAlpha('are you sure?', 'lightning_multiply', 0.001, 2, 'quadIn')
	runHaxeCode([[import flixel.effects.FlxFlicker;
		FlxFlicker.flicker(game.getLuaObject('lightning_multiply'), 0.1, 0.05, true, true);
	]])
	
	soundName = string.format('kittyBattle/thunder_%i', getRandomInt(1, 2));
	playSound(soundName, 0.3, 'thundah');
	
	-- chars
	setProperty('felineCopy.alpha', 0.8)
	setProperty('roseCopy.alpha', 0.8)
	setProperty('marilynCopy.alpha', 0.8)
	
	doTweenAlpha('felineFade', 'felineCopy', 0.001, 3, 'quadIn')
	doTweenAlpha('roseFade', 'roseCopy', 0.001, 3, 'quadIn')
	doTweenAlpha('marilynFade', 'marilynCopy', 0.001, 3, 'quadIn')
end