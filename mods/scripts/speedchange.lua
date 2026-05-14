increaseratebutton = "F1" --The button to increase the rate speed
decreaseratebutton = "F2" --Same but decrease
changerateammount = 0.05 --Ammount to increase/decrease

function onUpdatePost(elapsed)
	if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.'.. increaseratebutton) then
		setProperty('playbackRate',getProperty('playbackRate') + changerateammount)
		debugPrint(getProperty('playbackRate'))
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.' .. decreaseratebutton) then
		setProperty('playbackRate',getProperty('playbackRate') - changerateammount)
		debugPrint(getProperty('playbackRate'))
	end
end