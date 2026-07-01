package funkin.maki.fightfunk;

import funkin.maki.fightfunk.util.FightUtil;
import funkin.modding.module.Module;

class FightMain extends Module
{
	override public function new()
	{
		super('FightMain');
	}

	override function onCreate(event)
	{
		super.onCreate(event);

        FightUtil.init();
	}
}
