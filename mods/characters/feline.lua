function onCreate() --sigma
	setPropertyFromClass('GameOverSubstate', 'characterName', 'feline-death');
	setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'felineDeath');
	setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'gameOverFeline');
	setPropertyFromClass("GameOverSubstate", "endSoundName", "gameOverFelineEnd")
end

function onGameOverStart()
	triggerEvent('Screen Shake','0.35,0.007')
end