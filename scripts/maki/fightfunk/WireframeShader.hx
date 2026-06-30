package funkin.maki.fightfunk;

import flixel.addons.display.FlxRuntimeShader;

/**
 * THANK YOU VIRTU I LOVE YOU (no homo)
**/
class WireframeShader extends FlxRuntimeShader
{
	public function new()
	{
		var fragText:String = Assets.getText(Paths.frag('wireframe'));
		super(fragText);

		setOutlineColor(0xFFFFFFFF);
		setThreshold(0.1);
	}

	public function setOutlineColor(color:Int):Int
	{
		var red:Float = ((color >> 16) & 0xff) / 255;
		var green:Float = ((color >> 8) & 0xff) / 255;
		var blue:Float = (color & 0xff) / 255;
		var targetColorArray:Float = [red, green, blue];
		this.setFloatArray('outline', targetColorArray);
	}

	public function setThreshold(threshold:Float):Float
	{
		this.setFloatArray('threshold', [threshold]);
	}
}
