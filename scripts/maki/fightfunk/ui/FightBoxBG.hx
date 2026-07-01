package funkin.maki.fightfunk.ui;

import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;

class FightBoxBG extends FlxBackdrop
{
	override public function new(color:FlxColor)
	{
		super(Paths.image('ui/fight/box'));

		this.color = color;
		this.velocity.set(20, -20);
        
		this.scale.set(2, 2);
		this.updateHitbox();
        
		this.blend = 0;
	}
}
