colourRefs = {'31A2FD', '31FD8C', 'F794F7', 'F96D63', 'FBA633', 'FFFFFF'}

function onEvent(name, value1)
    if name == 'Party Lights' then
		if value1 == '0' then
			doTweenColor('partyLightsTween0', 'partyLights', 'FFFFFF', 0.5, 'linear') -- white!!!! or sets it back to nothing cus its a white image with multiply for blending
		elseif value1 == '1' then
			if flashingLights then 
				doTweenColor('partyLightsTween1', 'partyLights', '31A2FD', 0.5, 'linear') -- blue
			else
				doTweenColor('partyLightsTween1', 'partyLights', '9CD2FC', 0.5, 'linear') -- light blue
			end
		elseif value1 == '2' then
			if flashingLights then 
				doTweenColor('partyLightsTween2', 'partyLights', '31FD8C', 0.5, 'linear') -- teal
			else
				doTweenColor('partyLightsTween2', 'partyLights', 'A1FCC8', 0.5, 'linear') -- light teal
			end
		elseif value1 == '3' then
			if flashingLights then 
				doTweenColor('partyLightsTween3', 'partyLights', 'F794F7', 0.5, 'linear') -- pink
			else
				doTweenColor('partyLightsTween3', 'partyLights', 'F4C3F4', 0.5, 'linear') -- light pink
			end
		elseif value1 == '4' then
			if flashingLights then 
				doTweenColor('partyLightsTween4', 'partyLights', 'F96D63', 0.5, 'linear') -- red
			else
				doTweenColor('partyLightsTween4', 'partyLights', 'F7BCB9', 0.5, 'linear') -- pinkish red
			end
		elseif value1 == '5' then
			if flashingLights then 
				doTweenColor('partyLightsTween5', 'partyLights', 'FBA633', 0.5, 'linear') -- orange
			else
				doTweenColor('partyLightsTween5', 'partyLights', 'F9D09A', 0.5, 'linear') -- light orange yeah
			end
		end
    end
end

-- thats it, thats the code
-- see like why cant code be as simple as this its so much easier like come onn am i right or what? thank you rose cord for coding this beautiful piece of work! why thank you me! i have schizophrenia and am very dangerous to be around