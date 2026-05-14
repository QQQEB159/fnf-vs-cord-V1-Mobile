function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Beatbox' then
			setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true)
			
		end
	end
end

animations = {'singbeatboxLEFT','singbeatboxDOWN','singbeatboxUP','singbeatboxRIGHT'}
function opponentNoteHit(id, noteData, noteType, isSustainNote)
    if noteType == 'Beatbox' then
		playAnim('dad', animations[noteData+1], true)
		setProperty('dad.holdTimer', 0)
    end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    if noteType == 'Beatbox' then
		playAnim('boyfriend', animations[noteData+1], true)
		setProperty('boyfriend.holdTimer', 0)
    end
end