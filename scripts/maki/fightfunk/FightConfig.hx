package funkin.maki.fightfunk;

import haxe.Json;
import flixel.math.FlxPoint;

class FightConfig
{
	public static var nameShortcuts:Map<String, String> = [
		'boyfriend' => 'bf',
		'daddy dearest' => 'dad',
		'pico' => 'pico',
		'girlfriend' => 'gf',
	];

	public static function getSongBattle(songCode:String):Dynamic
	{
		var battle:Dynamic =
			{
				level: 0,
				events: [],
				camZoomStartOffset: 0.0,
				camPositionStartOffset: [0.0, 0.0],
			};

		var path = Paths.json('battles/${songCode.toLowerCase()}');
		var pathData:Dynamic = null;

		if (Assets.exists(path))
		{
			pathData = Json.parse(Assets.getText(path));
		}

		return pathData ?? battle;
	}
}
