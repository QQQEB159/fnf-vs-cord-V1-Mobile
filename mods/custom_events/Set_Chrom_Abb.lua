function onCreatePost()

    makeLuaSprite("chromAbbSpr")

    runHaxeCode([[
        var shaderName = "CHROMABB";

        game.initLuaShader(shaderName);

        var shader0 = game.createRuntimeShader(shaderName);
        game.camGame.filters = [new ShaderFilter(shader0)];
        game.getLuaObject("chromAbbSpr").shader = shader0; // setting it into temporary sprite so luas can set its shader uniforms/properties
    ]]);
    setShaderFloat('chromAbbSpr', 'intensity', 0.0);
end

function onEvent(n, v1, v2)
    if n == 'Set_Chrom_Abb' then
        setShaderFloat('chromAbbSpr', 'intensity', tonumber(v1))
    end
end
