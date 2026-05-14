package mods.data.miau;

import flixel.tweens.FlxTween;

import openfl.filters.ShaderFilter;

function onCreate()
{
	//
	shader = createRuntimeShader('miau');
	shader.setFloat('u_mosaic', 5);
	shader.setFloat('u_sinStrength', 0.8);
	
	FlxG.camera.filters = [new ShaderFilter(shader)];
}

function onSongStart()
{
	FlxTween.num(5, 0.2, 1, {ease: FlxEase.sineOut}, (f) -> {
		shader.setFloat('u_sinStrength', f);
	});
	
	FlxTween.num(20, 0.5, 1.3, {}, (f) -> {
		shader.setFloat('u_mosaic', f);
	});
}

function onBeatHit()
{
	if (curBeat == 10)
	{
		// shader.setFloat('u_sinStrength', 0);
		FlxG.camera.filters = null;
	}
}

var _e = 0;

function onUpdate(e)
{
	_e += e;
	shader.setFloat('iTime', _e);
}
