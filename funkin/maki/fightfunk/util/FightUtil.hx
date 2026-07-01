package funkin.maki.fightfunk.util;

import haxe.Json;
import funkin.data.song.SongRegistry;
import funkin.util.assets.DataAssets;

using StringTools;

class FightUtil
{
	public static final defaultCameraZoom:Float = 0.5;

	public static final hpBarDefaultColor:FlxColor = 0xFFFFAA00;
	public static final hpBarKarmaColor:FlxColor = 0xFFFF00FF;

	public static var fightSongs:Array<String> = [];

	public static final nameShortcuts:Map<String, String> = [
		'boyfriend' => 'bf',
		'daddy dearest' => 'daddy',
		'pico' => 'pico',
		'girlfriend' => 'gf',
	];

	public static function init()
	{
		trace(DataAssets.listDataFilesInPath('battles/'));

		fightSongs = DataAssets.listDataFilesInPath('battles/');
		for (song in fightSongs)
			trace(song);
	}

	public static function isFightSong(songCode:String)
	{
		for (song in fightSongs)
			if (song == songCode) return true;

		return false;
	}

	public static function getBattleFile(songCode:String):String
	{
		return Paths.json('battles/$songCode');
	}

	public static function getSongBattle(songCode:String):Dynamic
	{
		var battle:Dynamic =
			{
				level: 0,
				events: [],
				camZoomStartOffset: 0.0,
				camPositionStartOffset: [0.0, 0.0],
			};

		var path = getBattleFile(songCode);
		var pathData:Dynamic = null;

		if (Assets.exists(path))
		{
			pathData = Json.parse(Assets.getText(path));
		}

		return pathData ?? battle;
	}
}
