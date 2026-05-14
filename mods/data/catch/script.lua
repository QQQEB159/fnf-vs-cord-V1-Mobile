function onCreatePost()
	setProperty('camDisplacement', 10)
end
function onUpdatePost()
end

  beatHitFuncs = {
	[2] = function()
		doTweenZoom('zoomTween', 'camGame', 0.6, 1.7, 'quadin');	
	end,
	
	[4] = function()
		cancelTween('zoomTween')	
	end,
	
	[60] = function()
		doTweenZoom('zoomTween', 'camGame', 0.4, 10, 'quadinout');	
	end,
	
	[69] = function()
		cancelTween('zoomTween')
	end,
  
	[90] = function()
		playAnim('alienCat', 'reel', true);
	end,
	
	[96] = function()
		doTweenZoom('zoomTween', 'camGame', 0.4, 10, 'quadinout');
	end,
	
	[100] = function()
		setProperty('alienCat.x', getProperty('alienCat.x') - 805)
		setProperty('alienCat.y', getProperty('alienCat.y') - 190)
		playAnim('alienCat', 'catch');
	end,
}
function onBeatHit()
	if beatHitFuncs[curBeat] then 
		beatHitFuncs[curBeat]()
	
	end
end