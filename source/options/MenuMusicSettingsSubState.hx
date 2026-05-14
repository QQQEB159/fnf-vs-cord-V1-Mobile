package options;

import extensions.openfl.FileReferenceEx;

import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;

import options.Option.OptionType;

class MenuMusicSettingsSubState extends BaseOptionsMenu
{
	var fileRef:FileReferenceEx;
	
	var musicOption:Option;
	
	public function new()
	{
		fileRef = new FileReferenceEx();
		
		// make display names used later
		musicOption = new Option('Music', "Change what song generally plays within the menus\nFor Custom, you must use `Load Custom Track` first.", 'currentMenuMusic', 'string', MenuMusic.toArray());
		addOption(musicOption);
		musicOption.onChange = playNewMenuSong;
		
		var option:Option = new Option('Load Custom Track', "Press to load a specific track from disk to be used for the custom option.", '', OptionType.BUTTON);
		addOption(option);
		option.getValue = () -> return '';
		option.setValue = (v) -> {}
		option.onChange = () -> {
			fileRef.onFileSelect = (path) -> {
				try
				{
					if (!path.endsWith('.ogg')) throw 'was not provided a .OGG';
					
					if (!FileSystem.exists(Paths.MODS_DIRECTORY + '/music'))
					{
						FileSystem.createDirectory(Paths.MODS_DIRECTORY + '/music'); // just making sure
					}
					
					File.saveBytes(Paths.MODS_DIRECTORY + '/music/customMenuMusic.ogg', File.getBytes(path));
					trace('successfully saved $path');
					FlxG.sound.play(Paths.sound('settingsConfirm'));
					
					Paths.disposeSound(Paths.getPath('music/customMenuMusic.ogg', SOUND, null, true));
					
					musicOption.curOption = musicOption.options.length - 1;
					musicOption.setValue(MenuMusic.CUSTOM);
					
					musicOption.change();
				}
				catch (e)
				{
					FlxG.sound.play(Paths.sound('settingsBack'));
				}
			}
			fileRef.onFileCancel = () -> {
				FlxG.sound.play(Paths.sound('settingsBack'));
			}
			
			fileRef.browseForFile({openStyle: OPEN, typeFilter: [new FileFilter('ogg', 'ogg')]});
		}
		
		option.addsVisualSpace = true;
		
		var option:Option = new Option('Custom Track BPM', "Set the BPM of your custom track.", 'customBPM', INT);
		option.minValue = 0;
		option.maxValue = 500;
		option.changeValue = 1;
		option.displayFormat = '%v BPM';
		addOption(option);
		
		super();
		
		musicOption.change();
	}
	
	function playNewMenuSong()
	{
		#if ACHIEVEMENTS_ALLOWED
		Achievements.unlock('menuMusic');
		#end
		
		CoolUtil.playMenuMusic(0);
		
		FlxG.sound.music?.fadeTween?.cancel();
		FlxG.sound.music?.fadeIn(1);
		
		var val:MenuMusic = cast musicOption.getValue();
		musicOption.text = val.toDisplayName();
	}
	
	override function destroy()
	{
		fileRef?.destroy();
		super.destroy();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		updateSelectorSize();
	}
	
	override function close()
	{
		FlxG.sound.music?.fadeTween?.cancel();
		if (FlxG.sound.music != null) FlxG.sound.music.volume = 0;
		super.close();
	}
}
