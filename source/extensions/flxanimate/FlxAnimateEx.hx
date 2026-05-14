package extensions.flxanimate;

import flixel.system.FlxAssets.FlxGraphicAsset;

import animate.FlxAnimateFrames;

import flixel.graphics.frames.FlxFramesCollection;

// one func ok but its for convenience
class FlxAnimateEx extends FlxAnimate
{
	public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset, ?settings:FlxAnimateSettings)
	{
		super(x, y, simpleGraphic, settings);
		antialiasing = ClientPrefs.data.antialiasing;
	}
	
	public function loadAtlas(path:String, cacheAnims:Bool = true, ?useRenderTexture:Bool)
	{
		path = Paths.getPath('images/$path');
		if (FileSystem.exists(path) && FileSystem.isDirectory(path))
		{
			this.frames = FlxAnimateFrames.fromAnimate(path, null, null, null, false, {cacheOnLoad: cacheAnims});
		}
		
		if (useRenderTexture != null)
		{
			this.useRenderTexture = useRenderTexture;
		}
		
		return this;
	}
}
