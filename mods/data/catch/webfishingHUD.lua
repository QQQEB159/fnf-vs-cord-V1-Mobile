setProperty('introSoundsSuffix', '-webfishing') -- looks for "intro3/2/1/Go-suffix"
function onCountdownTick(c) -- THE!
    if c == 1 then
        loadGraphic('countdownReady', 'stages/webfishing/ui/ready') -- ready
    elseif c == 2 then
        loadGraphic('countdownSet', 'stages/webfishing/ui/set') -- set
    elseif c == 3 then
        loadGraphic('countdownGo', 'stages/webfishing/ui/go') -- go
    end
end

local chatTexts = getRandomInt(1, 1) -- random texts

function onCreatePost()
	setTextFont('scoreTxt', 'WEBFISH.ttf')
	
	setProperty('healthBar.x', 485);
	--setProperty('healthBar.y', getProperty('healthBar.y') - 10);
	setProperty('iconP1.y', getProperty('iconP1.y') - 10);
	setProperty('iconP2.y', getProperty('iconP2.y') - 10);
	setProperty('scoreTxt.x', 145);
	
	for i = 0, 3 do
		if not middlescroll then
			setPropertyFromGroup('playerStrums', i, 'x', 645 + (112 * (i % 4))) --x
			setPropertyFromGroup('playerStrums', i, 'y', 60) -- y
		end
		if downscroll then
			setPropertyFromGroup('playerStrums', i, 'y', screenHeight - 160)
		end
		setPropertyFromGroup('strumLineNotes',i,'x',-330) -- apparently this hides the notes
	end

	makeLuaSprite('items', 'stages/webfishing/ui/items', 1124, 17); -- top right thing
	setObjectCamera('items', 'other')
	addLuaSprite('items', true);

	callMethod('updateUnderlay')
	
	-- bait
	makeLuaSprite('baitUI', 'stages/webfishing/ui/baitUI', 1147.85, 650);
	setObjectCamera('baitUI', 'other')
	addLuaSprite('baitUI', true);
	
	-- textBOX... not the actual chat itself
	makeLuaSprite('textbox', 'stages/webfishing/ui/textbox', 25.1, 450);
	setObjectCamera('textbox', 'other')
	addLuaSprite('textbox', true);
	
	-- the chat itself
	makeAnimatedLuaSprite('chat', 'stages/webfishing/ui/chat', 35.4, 495)
	setLuaSpriteScrollFactor('chat', 0, 0);
	setObjectCamera('chat', 'other')
	addLuaSprite('chat', true);
	
	-- randomize the texts
	if chatTexts == 1 then
		luaSpriteAddAnimationByPrefix('chat', 'text0', 'text0 instance 1', 1, false);
	elseif chatTexts == 2 then
		luaSpriteAddAnimationByPrefix('chat', 'text1', 'text1 instance 1', 1, false);
	elseif chatTexts == 3 then
		luaSpriteAddAnimationByPrefix('chat', 'text2', 'text2 instance 1', 1, false);
	elseif chatTexts == 4 then
		luaSpriteAddAnimationByPrefix('chat', 'text3', 'text3 instance 1', 1, false);
	end

	-- alphas (those who know:)
	setProperty('textbox.alpha', 0)
	setProperty('chat.alpha', 0.5)
end

  beatHitFuncs = {
	[1] = function()
		
	end,
	
}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	
	end
end