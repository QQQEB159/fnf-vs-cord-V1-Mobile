package objects;

// highly based of base games bopper class
// i liked it alot
// nmv bopper gutted and simplified for this use case
class Bopper extends OffsetSprite
{
	/**
	 *	Animation offsets
	 * 
	 * applied through `playAnim`
	 */
	public var animOffsets:Map<String, Array<Float>> = [];
	
	/**
	 * However many beats between dances
	 */
	public var danceEveryNumBeats:Int = 2;
	
	/**
	 * Whether the bopper should dance left and right.
	 * - If true, alternate playing `danceLeft` and `danceRight`.
	 * - If false, play `idle` every time.
	 *
	 * You can manually set this value, or you can leave it as `null` to determine it automatically.
	 */
	public var alternatingDance:Null<Bool> = null;
	
	/**
	 * If `false`, playAnim will no longer function
	 * 
	 * used by `playAnimForDuration`'s `force` arguement.
	 */
	public var canPlayAnimations:Bool = true;
	
	/**
	 * internal tracker for alternating dance chars.
	 */
	var danced:Bool = false;
	
	/**
	 * Suffix added to the characters `dance` animation.
	 */
	public var idleSuffix:String = '';
	
	public var scalableOffsets:Bool = false;
	
	//-----
	
	public function new(x:Float = 0, y:Float = 0, danceEveryNumBeats:Int = 2)
	{
		super(x, y);
		this.danceEveryNumBeats = danceEveryNumBeats;
		this.antialiasing = ClientPrefs.data.antialiasing;
	}
	
	public function addOffset(anim:String, x:Float = 0, y:Float = 0):Void
	{
		animOffsets[anim] = [x, y];
	}
	
	/**
	 * Ensures a anim exists before playing
	 * 
	 * If there is no anim but there is a suffix, it will strip the suffix and try again
	 * 
	 * If still fails, `Null` is returned.
	 */
	public function correctAnimationName(animName:String):Null<String> // from base game !
	{
		if (hasAnim(animName)) return animName;
		
		// strip any post fix
		if (animName.lastIndexOf('-') != -1)
		{
			final correctedName = animName.substring(0, animName.lastIndexOf('-'));
			return correctAnimationName(correctedName);
		}
		else
		{
			// trace('missing anim ' + animName);
			return null;
		}
	}
	
	public function playAnim(animToPlay:String, isForced:Bool = false, isReversed:Bool = false, frame:Int = 0):Void
	{
		if (!canPlayAnimations) return;
		
		final correctedAnim = correctAnimationName(animToPlay);
		
		if (correctedAnim == null) return;
		animation.play(correctedAnim, isForced, isReversed, frame);
		
		final animationOffsets = animOffsets.get(correctedAnim);
		
		if (animationOffsets != null)
		{
			offset.set(animationOffsets[0], animationOffsets[1]);
			
			if (scalableOffsets)
			{
				offset.x *= scale.x;
				offset.y *= scale.y;
			}
		}
		
		__prevPlayedAnimation = animToPlay;
	}
	
	final forcedAnimationTimer:FlxTimer = new FlxTimer();
	
	/**
	 * Plays a animation for a given amount of time and will `dance` when it is done
	 * @param forced If true, the character will not play any other animation until the duration is complete
	 */
	public function playAnimForDuration(animToPlay:String, duration:Float = 0.6, forced:Bool = false)
	{
		if (forced) canPlayAnimations = true;
		playAnim(animToPlay, true);
		
		if (forced) canPlayAnimations = false;
		forcedAnimationTimer.start(duration, tmr -> {
			if (forced) canPlayAnimations = true;
			dance();
		});
	}
	
	public var canDance:Bool = true;
	
	/**
	 * Makes the sprite "dance".
	 */
	public function dance(forced:Bool = false):Void
	{
		if (alternatingDance == null)
		{
			recalculateDanceIdle();
		}
		
		if (!canDance) return;
		
		if (alternatingDance)
		{
			danced = !danced;
			if (danced) playAnim('danceRight$idleSuffix', forced);
			else playAnim('danceLeft$idleSuffix', forced);
		}
		else
		{
			playAnim('idle$idleSuffix', forced);
		}
	}
	
	/**
	 * Updates if the current character has a alternating `left/right` dance
	 */
	public function recalculateDanceIdle():Void
	{
		alternatingDance = hasAnim('danceLeft' + idleSuffix) && hasAnim('danceRight' + idleSuffix);
	}
	
	public function onBeatHit(beat:Int)
	{
		if (!isAnimNull() && beat % danceEveryNumBeats == 0) dance();
	}
	
	// general functions needed for stuff
	var __prevPlayedAnimation:String = '';
	
	public inline function getAnimName():String return __prevPlayedAnimation;
	
	public inline function hasAnim(anim:String):Bool
	{
		return animation.exists(anim);
	}
	
	public inline function isAnimNull():Bool
	{
		return animation.curAnim == null;
	}
	
	public inline function isAnimFinished():Bool
	{
		return isAnimNull() ? false : animation.curAnim.finished;
	}
	
	public inline function getAnimNumFrames():Int
	{
		if (isAnimNull()) return 0;
		
		return animation.curAnim.numFrames;
	}
	
	public var animCurFrame(get, set):Int;
	
	inline function get_animCurFrame():Int
	{
		return isAnimNull() ? 0 : animation.curAnim.curFrame;
	}
	
	inline function set_animCurFrame(value:Int):Int
	{
		if (isAnimNull()) return 0;
		
		return animation.curAnim.curFrame = value;
	}
}
