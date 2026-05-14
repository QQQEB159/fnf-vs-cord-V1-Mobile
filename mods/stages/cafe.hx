package mods.stages;

import flixel.tweens.FlxTween;

import haxe.ds.StringMap;

import backend.ClientPrefs;

import flixel.FlxG;
import flixel.FlxSprite;

import haxe.io.Path;

import sys.FileSystem;

import backend.Paths;

import states.PlayState;

// var frameCache = [];
var frameCache:StringMap = new StringMap();
var walkerGroup;
var walkerGroupFG;
var lastIdx = -1;
var canSpawn:Bool = true;
var spawnRate = 15;

function onCreatePost()
{
	var path = Paths.getPath('images/stages/cafe/bgCharacters/walkers', 'binary', null, true);
	
	if (FileSystem.exists(path) && FileSystem.isDirectory(path))
	{
		for (i in FileSystem.readDirectory(path))
		{
			i = Path.withoutExtension(i);
			var atlas = Paths.getAtlas('stages/cafe/bgCharacters/walkers/' + i);
			// frameCache.push(atlas);
			frameCache.set(i, atlas);
		}
	}
	
	walkerGroup = new FlxSpriteContainer();
	insert(members.indexOf(PlayState.instance.getLuaObject('counters')) + 1, walkerGroup);
	
	walkerGroupFG = new FlxSpriteContainer();
	insert(members.indexOf(PlayState.instance.getLuaObject('foregroundTable')), walkerGroupFG);
	
	spawnWalker();
}

function walkerFactory()
{
	var temp = new FlxSprite();
	temp.antialiasing = ClientPrefs.data.antialiasing;
	temp.scrollFactor.set(PlayState.instance.getLuaObject('counters').scrollFactor.x, PlayState.instance.getLuaObject('counters').scrollFactor.y);
	return temp;
}

function spawnWalker()
{
	//
	var array = [];
	
	for (i in frameCache.keys())
	{
		array.push(i);
	}
	var idx = FlxG.random.int(0, array.length - 1, [lastIdx]);
	var name = array[idx];
	lastIdx = idx;
	
	// uncomment this rose if u wanna manually set the chars
	// name = 'WHOEVER U WANT IF U WANNA TEST SPECIFIC CHAR ACTERS';
	
	var isFG = FlxG.random.bool(50);
	
	var walker = isFG ? walkerGroupFG.recycle(FlxSprite, walkerFactory) : walkerGroup.recycle(FlxSprite, walkerFactory);
	FlxTween.cancelTweensOf(walker, ['y']);
	
	walker.frames = frameCache.get(name);
	walker.animation.addByPrefix('i', 'idle', 24);
	walker.animation.play('i');
	walker.updateHitbox();
	walker.velocity.x = -200 * getSpeedMult(name);
	
	walker.x = PlayState.instance.getLuaObject('counters').x + PlayState.instance.getLuaObject('counters').width;
	walker.flipX = false;
	
	if (FlxG.random.bool(50))
	{
		walker.velocity.x *= -1;
		walker.x = PlayState.instance.getLuaObject('counters').x - walker.width;
		walker.flipX = true;
	}
	
	if (isFG)
	{
		walker.y = PlayState.instance.getLuaObject('emptyTable')
			.y + PlayState.instance.getLuaObject('emptyTable').height - walker.height + 50 + getYOffset(name);
			
		walker.scale.set(1.1, 1.1);
		
		walkerGroupFG.add(walker);
	}
	else
	{
		walker.y = PlayState.instance.getLuaObject('counters').y
			+ PlayState.instance.getLuaObject('counters').height
			- walker.height
			+ 100
			+ getYOffset(name);
		walker.scale.set(1.0, 1.0);
		
		walkerGroup.add(walker);
	}
	
	if (name == 'booQueen' || name == 'wannaSeeMyLittleDigitalCircus')
	{
		FlxTween.tween(walker, {y: walker.y - 20}, 1, {ease: FlxEase.sineInOut, type: 4});
	}
}

function getSpeedMult(char:String)
{
	if (char == 'wannaSeeMyLittleDigitalCircus') return 3; // add more offsets here
	if (char == 'superFuckingMario') return 10;
	if (char == 'roblox') return 1.5;
	if (char == 'data5') return 2.25;
	if (char == 'evie') return 3.5;
	if (char == 'duchee') return 1.75;
	if (char == 'booQueen') return 1.75;
	if (char == 'stanKyle') return 1.5;
	if (char == 'cartmanKenny') return 1.5;
	if (char == 'oldWaiter') return 2.5;
	return 1;
}

function getYOffset(char:String)
{
	if (char == 'wannaSeeMyLittleDigitalCircus') return -400; // add more offsets here
	if (char == 'superFuckingMario') return -20;
	if (char == 'roblox') return 0;
	if (char == 'data5') return 0;
	if (char == 'evie') return 0;
	if (char == 'duchee') return 15;
	if (char == 'booQueen') return -100;
	if (char == 'stanKyle') return 10;
	if (char == 'cartmanKenny') return 25;
	if (char == 'oldWaiter') return -15;
	return 0;
}

function onSectionHit()
{
	if (canSpawn && FlxG.random.bool(spawnRate)) spawnWalker();
}

function killWalkers(walker)
{
	var counter = PlayState.instance.getLuaObject('counters');
	
	if (walker.x < counter.x - 500) walker.kill();
	else if (walker.x > counter.x + counter.width + 500) walker.kill();
}

function onUpdatePost(e)
{
	if (walkerGroup.length != 0 || walkerGroupFG.length != 0)
	{
		walkerGroup.forEachAlive(killWalkers);
		walkerGroupFG.forEachAlive(killWalkers);
	}
}

function onEvent(ev, v1, v2, time)
{
	if (ev == '' && v1 == 'ending')
	{
		canSpawn = false;
		
		function fadeOut(spr)
		{
			spr.alpha = 0;
		}
		
		walkerGroup.forEachAlive(fadeOut);
		walkerGroupFG.forEachAlive(fadeOut);
	}
	if (ev == '' && v1 == 'spawnRate')
	{
		spawnRate = Std.parseInt(v2);
	}
}
