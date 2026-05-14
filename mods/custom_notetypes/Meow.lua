function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Meow' then
			setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true)

		end
	end
end

otherAlt = {'singLEFT', 'singDOWN-giggle', 'singUP-Meow', 'singRIGHT'} --only works for cord
function opponentNoteHit(id, noteData, noteType, isSustainNote)
    if noteType == 'Meow' then
		playAnim('dad', otherAlt[noteData+1], true)
		setProperty('dad.holdTimer', 0)
    end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    if noteType == 'Meow' then
		playAnim('boyfriend', otherAlt[noteData+1], true)
		setProperty('boyfriend.holdTimer', 0)
    end
end