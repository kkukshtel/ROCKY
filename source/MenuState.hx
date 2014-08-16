package;

import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.U;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import firetongue.FireTongue;
import openfl.Assets;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		add(new FlxText(0, 0, 100, "title state"));

		if (Main.tongue == null)
		{
	    Main.tongue = new FireTongueEx(); //create a new FireTongue instance on the FireTongue type variable tongue from Main
	    Main.tongue.init("en-US");
	    FlxUIState.static_tongue = Main.tongue;
		}

		_xml_id = "TitleMenu";
		
		super.create();
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}
}
