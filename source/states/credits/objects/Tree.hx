package states.credits.objects;

import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;
import flixel.group.FlxContainer.FlxTypedContainer;
import flixel.util.FlxDestroyUtil;
import flixel.FlxBasic;

import shaders.WiggleEffect;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;

enum abstract FlyPattern(Int) from Int
{
	var CIRCLE;
	var INFINITY;
}

private class FireFly extends FlxSprite
{
	public var basePosition:FlxPoint = FlxPoint.get();
	
	var lifeTime:Float = 0;
	var twn:FlxTween = null;
	
	var flyPattern:FlyPattern = CIRCLE;
	
	public var isForeground:Bool = FlxG.random.bool();
	
	public function new()
	{
		super();
		loadSparrowFrames('menuassets/credits/firefly');
		scale.scale(3);
		updateHitbox();
		
		animation.addByPrefix('i', 'light', 2);
		animation.play('i');
		
		blend = ADD;
		
		revive();
	}
	
	override function revive()
	{
		super.revive();
		isForeground = FlxG.random.bool();
		flyPattern = FlxG.random.int(0, 1);
		
		lifeTime = FlxG.random.int(5, 15);
		amp = FlxG.random.int(2, 10);
		rate = FlxG.random.float(0.025, 0.075);
		
		alpha = 0;
		
		twn = FlxTween.tween(this, {alpha: 1}, 2 + FlxG.random.float(0, 3), {onComplete: Void -> twn = null});
	}
	
	var _e:Float = 0;
	
	var rate:Float = 0.05;
	var amp:Float = 2;
	
	public var distanceAlpha:Float = 0;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		_e += elapsed;
		
		switch (flyPattern)
		{
			case CIRCLE:
				x = basePosition.x + FlxMath.fastCos((180 / Math.PI) * _e * rate) * amp;
				y = basePosition.y + FlxMath.fastSin((180 / Math.PI) * _e * rate) * amp;
			case INFINITY:
				x = basePosition.x + FlxMath.fastCos((180 / Math.PI) * _e * rate * 0.5) * amp;
				y = basePosition.y + FlxMath.fastSin((180 / Math.PI) * _e * rate) * amp;
		}
		
		lifeTime -= elapsed;
		
		if (lifeTime < 0 && (twn == null || !twn.active))
		{
			lifeTime = 999;
			
			twn = FlxTween.tween(this, {alpha: 0}, 2 + FlxG.random.float(0, 3),
				{
					onComplete: Void -> {
						kill();
						twn = null;
					}
				});
		}
	}
	
	override function destroy()
	{
		super.destroy();
		
		basePosition = FlxDestroyUtil.put(basePosition);
	}
	
	override function draw()
	{
		colorTransform.alphaMultiplier = Math.min(alpha * distanceAlpha * 0.7, 1);
		super.draw();
	}
}

class Tree extends FlxSpriteGroup
{
	public var emitter:FlxEmitter;
	public var tree:Int = 0;
	
	var wiggleShader:WiggleEffect;
	
	var backLeaves:FlxSprite;
	var frontLeaves:FlxSprite;
	
	public var flies:FlxTypedSpriteContainer<FireFly>;
	
	override public function new(x:Float, tree:Int)
	{
		super(x, 0);
		this.tree = tree;
		
		backLeaves = new FlxSprite(0, 0).loadGraphic(Paths.image('menuassets/credits/backLeavesTree$tree'));
		add(backLeaves);
		backLeaves.scale.set(3, 3);
		backLeaves.antialiasing = false;
		backLeaves.updateHitbox();
		backLeaves.x -= 50;
		backLeaves.y -= backLeaves.height / 2;
		
		var back = new FlxSprite(0, 0).loadGraphic(Paths.image('menuassets/credits/tree$tree'));
		add(back);
		back.scale.set(3, 3);
		back.antialiasing = false;
		back.updateHitbox();
		
		emitter = new FlxEmitter();
		emitter.particleClass = Leaf;
		emitter.launchAngle.set(100, 160);
		emitter.angularVelocity.set(-80, 100);
		emitter.lifespan.set(5); // fuck it
		
		emitter.speed.set(60, 100);
		
		emitter.alpha.set(1, null, 1, 1);
		emitter.width = backLeaves.width / 2;
		emitter.height = backLeaves.height / 4;
		emitter.start(false, 1.25);
		
		frontLeaves = new FlxSprite(0, 0).loadGraphic(Paths.image('menuassets/credits/frontLeavesTree$tree'));
		add(frontLeaves);
		frontLeaves.scale.set(3, 3);
		frontLeaves.antialiasing = false;
		frontLeaves.updateHitbox();
		frontLeaves.x -= 50;
		frontLeaves.y -= frontLeaves.height / 2;
		
		wiggleShader = new WiggleEffect();
		wiggleShader.waveSpeed = 1.5;
		wiggleShader.waveFrequency = 3;
		wiggleShader.waveAmplitude = 0.014;
		// shader.
		wiggleShader.effectType = DREAMY;
		
		backLeaves.shader = wiggleShader.shader; // i hate these parent class shit
		frontLeaves.shader = wiggleShader.shader; // i hate these parent class shit
		
		flies = new FlxTypedSpriteContainer();
		add(flies);
		
		new FlxTimer().start(FlxG.random.int(1, 10), (f) -> {
			f.reset(FlxG.random.int(10, 20));
			makeFly();
		});
		
		if (tree == 2)
		{
			backLeaves.x = ((back.x + back.width) - backLeaves.width) + 50;
			frontLeaves.x = backLeaves.x + 15;
			frontLeaves.y -= 10;
		}
		
		flies.x = backLeaves.x;
		y = 393 - back.height;
	}
	
	function makeFly()
	{
		var fly = flies.recycle(FireFly);
		flies.add(fly);
		
		fly.x = backLeaves.x + FlxMath.remapToRange(Math.random(), 0, 1, -50, backLeaves.width + 50);
		fly.y = flies.y + backLeaves.height * 0.5 + FlxG.random.int(0, 25);
		
		fly.basePosition.x = fly.x;
		fly.basePosition.y = fly.y;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		emitter.update(elapsed);
		
		wiggleShader.update(elapsed);
	}
	
	@:access(flixel.FlxCamera)
	override function draw()
	{
		emitter.x = backLeaves.x + (backLeaves.width - emitter.width) / 2;
		emitter.y = y + emitter.height / 2;
		
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (_cameras != null)
		{
			FlxCamera._defaultCameras = _cameras;
		}
		
		var temp:Array<FlxBasic> = cast members.copy();
		
		temp.insert(temp.indexOf(frontLeaves), emitter);
		
		for (basic in temp)
		{
			if (basic != null && basic.exists && basic.visible)
			{
				if (basic == flies)
				{
					for (i in flies)
					{
						if (i.isForeground) continue;
						
						i.draw();
					}
					
					continue;
				}
				basic.draw();
			}
		}
		
		FlxCamera._defaultCameras = oldDefaultCameras;
	}
	
	override function destroy()
	{
		super.destroy();
		emitter = FlxDestroyUtil.destroy(emitter);
		@:privateAccess
		wiggleShader.shader = null;
		wiggleShader = null;
	}
}

private class Leaf extends FlxParticle
{
	public function new()
	{
		super();
		makeGraphic(6, 6, 0xFF1B363A);
	}
}
