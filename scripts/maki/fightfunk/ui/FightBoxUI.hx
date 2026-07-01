package funkin.maki.fightfunk.ui;

import funkin.graphics.FunkinSprite;

class FightBoxUI extends FunkinSprite
{
	override public function new()
	{
		super(0, 0, 'ui/fight/box');

		this.antialiasing = false;
		this.scale.set(FlxG.width * 1.1 / this.width, 3);
		
        this.updateHitbox();
		this.screenCenter();
	}
}
