local comboHelper = 0

function noteMiss(index, noteData, noteType, isSustain)


    if comboHelper >= 10 then
      playAnim('dad', 'laugh', true)
      setProperty('dad.specialAnim', true)

    end
    comboHelper = 0
end

function onRecalculateRating()
  if combo ~= 0 then
    comboHelper = combo
  end
end
