package funkin.maki.fightfunk.ui.menus;

import funkin.maki.fightfunk.shaders.WireframeShader;
import funkin.maki.fightfunk.util.FightUtil;
import funkin.modding.module.Module;
import funkin.ui.freeplay.FreeplayState;
import funkin.util.ReflectUtil;

using StringTools;

class FightFreeplayIcons extends Module
{
	public function new()
	{
		super('FightFreeplayIcons', 1000,
			{
				state: FreeplayState,
			});

		freeplayIconShader = new WireframeShader(0xFFFF0000);
		freeplayRatingShader = new WireframeShader(0xFFFFFFFF);
		freeplayRatingShader.setThreshold(0.25);
	}

	var freeplay:FreeplayState;

	var freeplayIconShader:WireframeShader;
	var freeplayRatingShader:WireframeShader;

	var songCodees:Array<String> = [];

	function onFreeplayClose(event)
	{
		super.onFreeplayClose(event);
		freeplay = null;
		songCodees = [];
	}

	function onDifficultySwitch(event)
	{
		super.onDifficultySwitch(event);
		songCodees = [];
	}

	function onSubStateOpenEnd(event)
	{
		super.onSubStateOpenEnd(event);

		freeplay = FlxG.state.subState;
		songCodees = [];
	}

	function onUpdate(event)
	{
		super.onUpdate(event);

		if (freeplay != null)
		{
			for (capsules in freeplay.grpCapsules)
			{
				var songData = capsules.freeplayData;

				var songCode:String = '${songData?.idAndVariation?.replace(':', '-')}'?.toLowerCase()?.trim();
				if (songCodees.contains(songCode)) return;
				songCodees.push(songCode);

				capsules.pixelIcon.shader = FightUtil.isFightSong(songCode) ? freeplayIconShader : null;
			}
		}
	}
}
