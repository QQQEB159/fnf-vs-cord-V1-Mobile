import flixel.tweens.FlxTween;

import openfl.filters.ShaderFilter;

function onCreatePost()
{
	//
	shader = createRuntimeShader('miau');
	shader.setFloat('u_mosaic', 0.001);
	shader.setFloat('u_sinStrength', 0);
	
	if (FlxG.camera.filters != null)
	{
		FlxG.camera.filters.push(new ShaderFilter(shader));
	}
	else
	{
		FlxG.camera.filters = [new ShaderFilter(shader)];
	}
}

function onSongStart()
{
	// FlxTween.num(5, 0.2, 1, {ease: FlxEase.sineOut}, (f) -> {
	// 	shader.setFloat('u_sinStrength', f);
	// });
	
	// FlxTween.num(20, 0.5, 1.3, {}, (f) -> {
	// 	shader.setFloat('u_mosaic', f);
	// });
}

function onBeatHit()
{
	if (curBeat == 87) // camera starts to pixelate alot
	{
		FlxTween.num(0.001, 15, 0.45, {}, (f) -> {
			shader.setFloat('u_mosaic', f);
		});
	}
	if (curBeat == 88) // camera is only a tiny bit pixely and a tiny bit wavy
	{
		shader.setFloat('u_mosaic', 3);
		shader.setFloat('u_sinStrength', 0.05);
	}
	if (curBeat == 120) // the pixel effect goes away
	{
		FlxTween.num(3, 0.001, 2, {}, (f) -> {
			shader.setFloat('u_mosaic', f);
		});
	}
	if (curBeat == 152) // the wavy effect goes away
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

var shakeCord:Bool = false;
var cordY:Float = 0;

function onNextDialogue(idx)
{
	switch (idx)
	{
		case 1:
			cordY = getCord().y;
		case 10:
			shakeCord = true;
		case 13:
			shakeCord = false;
			getCord().y = cordY;
			getCord().x = getCord().startingPos;
	}
}

function onUpdatePost(e)
{
	if (PlayState.instance.psychDialogue != null && shakeCord)
	{
		getCord().x = getCord().startingPos + FlxG.random.float(-1, 1);
		getCord().angle = FlxG.random.float(-1, 1);
		getCord().y = cordY + FlxG.random.float(-1, 1);
	}
}

var _cord = null;

function getCord()
{
	if (_cord != null) return _cord;
	
	for (i in PlayState.instance.psychDialogue.characters)
	{
		if (i.curCharacter == 'cord')
		{
			_cord = i;
		}
	}
	
	return _cord;
}
