package states.credits.objects;

import flixel.addons.display.FlxRuntimeShader;

@:publicFields
class CreditPopper extends FlxTypedSpriteGroup<FlxSprite>
{
	var info:CreditInformation;
	var name:FlxText;
	var description:FlxText;
	var icons:Array<FlxSprite> = [];
	
	public var line:FlxSprite;
	public var icon:FlxSprite;
	
	override public function new(info:CreditInformation)
	{
		super();
		this.info = info;
		
		icon = new FlxSprite(0, 0).loadGraphic(Paths.image('menuassets/credits/icons/${info.icon}'));
		add(icon);
		icon.antialiasing = true;
		icon.scale.set(0.75, 0.75);
		icon.updateHitbox();
		
		name = new FlxText(icon.x, (icon.y + icon.height), 0, info.name, 72);
		name.setFormat(Paths.font("AKIRA.otf"), 72, FlxColor.WHITE);
		name.scale.scale(0.5);
		name.updateHitbox();
		add(name);
		name.antialiasing = true;
		
		line = new FlxSprite(name.x, (name.y + name.height)).makeGraphic(1, 6, FlxColor.WHITE);
		add(line);
		line.antialiasing = true;
		
		for (i in 0...info.contributions.length)
		{
			var ico = new FlxSprite(0, 0).loadGraphic(Paths.image('menuassets/credits/symbols/${info.contributions[i]}'));
			add(ico);
			ico.antialiasing = true;
			ico.scale.set(0.75, 0.75);
			ico.updateHitbox();
			ico.x = icons[i - 1] != null ? (icons[i - 1].x + icons[i - 1].width) + 10 : ((icon.x + icon.width) + 10);
			ico.y = (name.y - ico.height) - 5;
			icons.push(ico);
		}
		
		final topWidth:Float = (icons[icons.length - 1].x + icons[icons.length - 1].width) - icon.x;
		
		// if (name.width < topWidth) line.makeScaledGraphic(Std.int(topWidth), 6, FlxColor.WHITE);
		
		line.scale.x = Math.max(Math.max(topWidth, name.width), 225);
		line.updateHitbox();
		
		description = new FlxText(line.x, (line.y + line.height) + 3, line.width * 2, info.description, 32);
		description.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE);
		description.scale.scale(0.5);
		description.updateHitbox();
		add(description);
		description.antialiasing = true;
		
		if (info.name == "Rose Cord")
		{
			var crown = new FlxSprite(0, 0).loadGraphic(Paths.image('menuassets/credits/symbols/director'));
			add(crown);
			crown.antialiasing = true;
			crown.scale.set(0.75, 0.75);
			crown.updateHitbox();
			crown.x = (name.x - crown.width) - 10;
			crown.y = name.y + ((name.height - crown.height) / 2);
		}
		else if (info.name == 'Data5')
		{
			//
			name.shader = new FlxRuntimeShader("
				#pragma header

				uniform float iTime;

				void main() 
				{
					vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);

					// tex.rgb *= vec3(0.89,0.73,0.29);
					tex.rgb *= vec3(0.78,0.64,0.43);

					vec4 whiteBlend = mix(tex, vec4(1.0), step(0.99, (sin(openfl_TextureCoordv.x + openfl_TextureCoordv.y - iTime * 3.0))));
					
					gl_FragColor = mix(tex, whiteBlend, tex.a);
				}
			");
		}
	}
	
	function bop()
	{
		FlxTween.tween(this,
			{
				baseY: baseY - 20
			}, 0.5 * FlxG.sound.music.pitch,
			{
				ease: FlxEase.sineOut,
				onComplete: Void -> {
					FlxTween.tween(this, {
						baseY: baseY + 20
					}, 0.5 * FlxG.sound.music.pitch, {ease: FlxEase.sineIn, onComplete: Void -> bop()});
				}
			});
	}
	
	@:allow(states.credits.CreditsPlatformer)
	var _e:Float = 0;
	
	@:allow(states.credits.CreditsPlatformer)
	var baseY:Float = 0;
	
	var rate:Float = 0.05;
	var amp:Float = 2;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		_e += elapsed;
		
		this.y = baseY + FlxMath.fastSin((180 / Math.PI) * _e * rate) * amp;
		
		if (name.shader != null)
		{
			var shader:FlxRuntimeShader = cast name.shader;
			shader.setFloat('iTime', _e);
		}
	}
}

typedef CreditInformation =
{
	name:String,
	icon:String,
	contributions:Array<CreditOccupations>,
	description:String
}

enum abstract CreditOccupations(String) to String
{
	var ARTIST = 'artist';
	var CAMEO = 'cameo';
	var CHARTER = 'charter';
	var CODING = 'coding';
	var COMPOSER = 'composer';
	var PLAYTESTER = 'playtester';
	var SCRIPTER = 'scripter';
	var VILTRUM = 'viltrum';
}
