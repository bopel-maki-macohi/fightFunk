package funkin.maki.fightfunk.shaders;

import flixel.addons.display.FlxRuntimeShader;
import flixel.util.FlxColor;

/**
 * THANK YOU VIRTU I LOVE YOU (no homo)
**/
class WireframeShader extends FlxRuntimeShader
{
	public function new(?outlineColor:Int)
	{
		var fragText:String = Assets.getText(Paths.frag('wireframe'));
		super(fragText);

		setOutlineColor(outlineColor ?? 0xFFFFFFFF);
		setFillingColor(0xFF000000);
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

	public function setFillingColor(color:Int):Int
	{
		var red:Float = ((color >> 16) & 0xff) / 255;
		var green:Float = ((color >> 8) & 0xff) / 255;
		var blue:Float = (color & 0xff) / 255;
		var targetColorArray:Float = [red, green, blue];
		this.setFloatArray('filling', targetColorArray);
	}

	public function getOutlineColor():Int
	{
		var outline = this.getFloatArray('outline');
		return FlxColor.fromRGBFloat(outline[0], outline[1], outline[2]);
	}

	public function getFillingColor():Int
	{
		var filling = this.getFloatArray('filling');
		return FlxColor.fromRGBFloat(filling[0], filling[1], filling[2]);
	}

	public function setThreshold(threshold:Float):Float
	{
		this.setFloatArray('threshold', [threshold]);
	}
}
