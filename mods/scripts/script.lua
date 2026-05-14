local enabled = true

if enabled then
		local thickness = 100

function onCreate()
	-- for the bars
		makeLuaSprite('bar_upper', nil, -100, -200)
		makeGraphic('bar_upper', 1480, 200, '000000')
		setObjectCamera('bar_upper', 'hud')
		addLuaSprite('bar_upper', false)

		makeLuaSprite('bar_lower', nil, -200, 720)
		makeGraphic('bar_lower', 1780, 200, '000000')
		setObjectCamera('bar_lower', 'hud')
		addLuaSprite('bar_lower', false)
		
	-- black screen
	makeLuaSprite('black', nil, -2000, -1000)
	makeGraphic('black', 1, 1, '000000')
	setLuaSpriteScrollFactor('black', 0, 0)
	scaleObject('black', 2000 * 4, 1000 * 4)
	addLuaSprite('black', true)
	
	-- white screen
	makeLuaSprite('white', nil, -2000, -1000)
	makeGraphic('white', 1, 1, 'FFFFFF')
	setLuaSpriteScrollFactor('white', 0, 0)
	scaleObject('white', 4 * 2000, 4 * 1000)
	addLuaSprite('white', true)
	
	setProperty('black.alpha', 0)
	setProperty('white.alpha', 0)
end

function onSongStart()
	if songName ~= 'Catch!' then
		doTweenY('bar_upper', 'bar_upper', -120, 2, 'quintout')
		doTweenY('bar_lower', 'bar_lower', 735 - thickness, 2, 'quintout')
	end
	
	setObjectOrder('black', 99)
	setObjectOrder('white', 99)
end
end


-- crash prevention
function onUpdate() end
function onUpdatePost() end
