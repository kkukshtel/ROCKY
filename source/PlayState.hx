package;
//maybe
import openfl.Assets;
//import flixel.plugin.MouseEventManager;
//definitely
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxPoint;

import flixel.addons.nape.FlxNapeState;
import flixel.addons.nape.FlxNapeSprite;

import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.constraint.DistanceJoint;
import nape.constraint.PivotJoint;
import nape.constraint.WeldJoint;
import nape.constraint.AngleJoint;
import nape.dynamics.InteractionFilter;
import nape.dynamics.InteractionGroup;
import nape.geom.Vec2;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxNapeState
{
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	var rocky: Ragdoll;
	override public function create():Void
	{
		super.create();

		add(new FlxText(0, 0, 100, "play state"));

		createWalls(0, 0,FlxG.width, FlxG.height, 30);
		FlxNapeState.space.gravity.setxy(0, 800);
		napeDebugEnabled = false;

		rocky = new Ragdoll(100,250);
		rocky.init();
		rocky.createGraphics(
								"assets/images/GokuULeg.png",
								"assets/images/GokuLLeg.png",
								"assets/images/CameraPole.png"
								);
		add(rocky);
	}

	public function toggleSound():Void
	{
			Main.sound = !Main.sound;
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
		//DEBUG
		if (FlxG.keys.justPressed.G)
			napeDebugEnabled = !napeDebugEnabled;
		if (FlxG.keys.justPressed.Q)
			FlxG.resetState();
		//

		//CONTROL//
		if (FlxG.keys.pressed.R)
		{
			rocky.moveLeftUpper();
			FlxG.log.add("R");
		}
		if (FlxG.keys.pressed.O)
		{
			rocky.moveRightUpper();
			FlxG.log.add("O");
		}
		if (FlxG.keys.pressed.C)
		{
			rocky.moveLeftLower();
			FlxG.log.add("C");
		}
		if (FlxG.keys.pressed.K)
		{
			rocky.moveRightLower();
			FlxG.log.add("K");
		}

		/*/WIN CONDITIONS ONLY
		if (FlxG.keys.justPressed.Y)
			FlxG.resetState();
		/*/

		//NEED MOBILE CONTROL CONDITIONALS
	}
}

class Ragdoll extends FlxGroup
{
	public var sprites:Array<FlxNapeSprite>;

	public var rULeg:FlxNapeSprite; // right upper leg.
	public var rLLeg:FlxNapeSprite; // right lower leg.
	public var lULeg:FlxNapeSprite; // left upper leg.
	public var lLLeg:FlxNapeSprite; // left lower leg.
	public var cameraPole:FlxNapeSprite; //camera pole

	public var scale:Float;

	public var joints:Array<PivotJoint>;

	public var llegSize:FlxPoint;
	public var ulegSize:FlxPoint;
	public var cameraPoleSize:FlxPoint;

	public var limbOffset:Float;
	public var torsoOffset:Float;

	var startX:Float;
	var startY:Float;

	/**
	 * Creates the ragdoll
	 * @param	scale	The ragdol size scale factor.
	 */
	public function new(X:Float, Y:Float, Scale:Float = 1)
	{
		super();

		Scale > 0 ? scale = Scale : scale = 1;

		// defining width/lengths of body parts
		llegSize = FlxPoint.get(15 * scale, 45 * scale); //15x45 sprite
		ulegSize = FlxPoint.get(15 * scale, 50 * scale);
		cameraPoleSize = FlxPoint.get(30 * scale, 65 * scale);
		//neckHeight = 5 * scale;
		//headRadius = 15 * scale;

		limbOffset = 3 * scale;
		torsoOffset = 5 * scale;

		startX = X;
		startY = Y;

	}

	public function init()
	{
		sprites = new Array<FlxNapeSprite>();

		cameraPole = new FlxNapeSprite(startX, startY); sprites.push(cameraPole);
		rULeg = new FlxNapeSprite(startX, startY + 60); sprites.push(rULeg);
		rLLeg = new FlxNapeSprite(startX, startY + 110); sprites.push(rLLeg);
		lULeg = new FlxNapeSprite(startX, startY + 60); sprites.push(lULeg);
		lLLeg = new FlxNapeSprite(startX, startY + 110); sprites.push(lLLeg);

		add(rLLeg);
		add(lLLeg);
		add(rULeg);
		add(lULeg);
		add(cameraPole);

		createBodies();
		createContactListeners();
		createJoints();

		//setPos(startX, startY);
	}

	function setPos(x:Float, y:Float)
	{
		for (s in sprites)
		{
			s.body.position.x = x;
			s.body.position.y = y;
		}
	}

	function createBodies()
	{
		rULeg.createRectangularBody(ulegSize.x, ulegSize.y);
		rLLeg.createRectangularBody(llegSize.x, llegSize.y);

		lULeg.createRectangularBody(ulegSize.x, ulegSize.y);
		lLLeg.createRectangularBody(llegSize.x, llegSize.y);

		cameraPole.createRectangularBody(cameraPoleSize.x, cameraPoleSize.y);
	}

	function createContactListeners()
	{
		var leftUpperLeg:CbType = new CbType();
		var leftLowerLeg:CbType = new CbType();
		var rightUpperLeg:CbType = new CbType();
		var rightLowerLeg:CbType = new CbType();
		var theCameraPole:CbType = new CbType();

		lLLeg.body.cbTypes.add(leftUpperLeg);
		rLLeg.body.cbTypes.add(leftLowerLeg);
		lULeg.body.cbTypes.add(rightUpperLeg);
		rULeg.body.cbTypes.add(rightLowerLeg);
		cameraPole.body.cbTypes.add(theCameraPole);

		var listener;
		//x ignores y
		listener = new PreListener(InteractionType.COLLISION, leftLowerLeg, leftUpperLeg, ignoreCollision, 0, true);
		listener.space = FlxNapeState.space;
		listener = new PreListener(InteractionType.COLLISION, rightLowerLeg, rightUpperLeg, ignoreCollision, 0, true);
		listener.space = FlxNapeState.space;
		listener = new PreListener(InteractionType.COLLISION, rightUpperLeg, theCameraPole, ignoreCollision, 0, true);
		listener.space = FlxNapeState.space;
		listener = new PreListener(InteractionType.COLLISION, leftUpperLeg, theCameraPole, ignoreCollision, 0, true);
		listener.space = FlxNapeState.space;
		listener = new PreListener(InteractionType.COLLISION, leftUpperLeg, rightUpperLeg, ignoreCollision, 0, true);
		listener.space = FlxNapeState.space;
		listener = new PreListener(InteractionType.COLLISION, leftLowerLeg, rightLowerLeg, ignoreCollision, 0, true);
		listener.space = FlxNapeState.space;
	}

	function ignoreCollision(cb:PreCallback):PreFlag {
		return PreFlag.IGNORE;
	}

	public function createGraphics(UpperLeg:String, LowerLeg:String, CameraPole:String)
	{
		cameraPole.loadGraphic(CameraPole);
		rULeg.loadGraphic(UpperLeg);
		lULeg.loadGraphic(UpperLeg); lULeg.scale.x *= -1;
		rLLeg.loadGraphic(LowerLeg);
		lLLeg.loadGraphic(LowerLeg); lLLeg.scale.x *= -1;
	}


	function createJoints()
	{
		var constrain:PivotJoint;
		var angleJoint:AngleJoint;
		var weldJoint:WeldJoint;

		// lower legs with upper legs.
		// negative because +.y is the bottom of the leg in worldspace
		constrain = new PivotJoint(lLLeg.body, lULeg.body, new Vec2(0, -llegSize.y / 2 + 3), new Vec2(0, ulegSize.y / 2 - 3));
		constrain.space = FlxNapeState.space;
		constrain = new PivotJoint(rLLeg.body, rULeg.body, new Vec2(0, -llegSize.y / 2 + 3), new Vec2(0, ulegSize.y / 2 - 3));
		constrain.space = FlxNapeState.space;

		/*angleJoint = new AngleJoint(lLLeg.body, lULeg.body, 0, -Math.PI*.4);
		angleJoint.space = FlxNapeState.space;
		angleJoint = new AngleJoint(rLLeg.body, rULeg.body, 0, -Math.PI*.4);
		angleJoint.space = FlxNapeState.space;*/

		// Upper legs with each other
		constrain = new PivotJoint(lULeg.body, rULeg.body, new Vec2(0, -ulegSize.y / 2 + 3), new Vec2(0, -ulegSize.y / 2 + 3));
		constrain.space = FlxNapeState.space;

		/*/ Camera Pole with legs
		constrain = new PivotJoint(cameraPole.body, rULeg.body, new Vec2(0, cameraPoleSize.y / 2 + 3), new Vec2(0, -ulegSize.y / 2 + 3));
		constrain.space = FlxNapeState.space;*/

		weldJoint = new WeldJoint(cameraPole.body, rULeg.body, new Vec2(0, cameraPoleSize.y / 2 + 3), new Vec2(0, -ulegSize.y / 2 + 3), 0);
		weldJoint.space = FlxNapeState.space;

		//NEED TO MAKE PELVIC BONE THAT ACTS AS UNISON OF ALL PARTS SO CAMERA ISN'T JUST ATTACHED TO A LEG???

	}

	public function moveLeftUpper()
	{
		lULeg.body.rotate += Math.PI*3;
	}

	public function moveRightUpper()
	{
		rULeg.body.rotate += Math.PI*3;
	}

	public function moveLeftLower()
	{
		lLLeg.body.rotate += Math.PI*3;
	}

	public function moveRightLower()
	{
		rLLeg.body.rotate += Math.PI*3;
	}
}
