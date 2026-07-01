package funkin.maki.fightfunk.ui;

import funkin.graphics.FunkinSprite;

class FightBoxUI extends FunkinSprite
{
	override public function new()
	{
		super(0, 0, Paths.image('ui/fight/box'));

		antialiasing = false;
		scale.set(FlxG.width * 1.1 / width, 3);
		
        updateHitbox();
		screenCenter();
	}
}
