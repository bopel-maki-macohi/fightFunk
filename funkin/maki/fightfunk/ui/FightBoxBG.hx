package funkin.maki.fightfunk.ui;

import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;

class FightBoxBG
{
    public static function create(newColor:FlxColor):FlxBackdrop
    {
        var bg = new FlxBackdrop(Paths.image('ui/fight/box'));
        bg.color = newColor ?? 0xFFFFFFFF;

		bg.scale.set(2, 2);
		bg.updateHitbox();

		bg.blend = 0;

        bg.alpha = 0;

        return bg;
    }
}
