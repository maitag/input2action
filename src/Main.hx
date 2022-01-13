package;

import lime.app.Application;
import lime.graphics.RenderContext;

//import lime.ui.Gamepad;
//import lime.ui.GamepadAxis;

import lime.ui.KeyCode;
import lime.ui.GamepadButton;


import input2actions.InputType;
import input2actions.ActionState;
import input2actions.ActionFunction;
import input2actions.ActionMap;


import input2actions.ActionConfig;
import input2actions.Input2Actions;



class Main extends Application {
	
		
	public override function onWindowCreate ():Void 
	{
/*		
		// json2obj:
		var actionConfigJson:ActionConfigJson =
		'
		[
			{	"action"    : "action1",
				"down"      : "true",
				"up"        : "false",
				"repeat"    : "false",
				"repeatRate": "1100",
				"keyboard"  : "LEFT, A, LEFT_SHIFT A, RIGHT_SHIFT A",
				"gamepad"   : "LEFT_STICK"
			}
		]
		';
*/		
		//var actionConfig:ActionConfig = actionConfigJson;

		// defined in haxe
		var actionConfig:input2actions.ActionConfig = [
			"action1" =>
			{
				//down:false,
				up:true, repeat:false, repeatRate:1100,
				keyboard  : [ KeyCode.LEFT, KeyCode.A, [KeyCode.LEFT_SHIFT, KeyCode.A], [KeyCode.RIGHT_SHIFT, KeyCode.A]  ],
				gamepad   : [ GamepadButton.LEFT_STICK ]
			}
		];
		
		//var actionConfigJson:ActionConfigJson = actionConfig;
		//trace(actionConfigJson);
		
		var actionMap:ActionMap = [
			"action1" => action1,
			//"action2" => action2,
		];
		
		
		var input2Actions = new Input2Actions(actionConfig, actionMap);

		//input2Actions.config(actionConfig, actionMap);
		
		
		
		
		input2Actions.enable(window);
		//input2Actions.disable(window);

	}
	
	
	// ------------------------------------------------------------	
	// -------------------- Actions -------------------------------	
	// ------------------------------------------------------------
	
	function action1(inputType:InputType, actionState:ActionState) 
	{
		var type:String;
		switch (inputType) {
			case (InputType.KEYBOARD) : type = "Keyboard";
			case (InputType.GAMEPAD)  : type = "GamePad";
			case (InputType.JOYSTICK) : type = "JoyStick";
			default: type = "unknown";
		}
		
		switch (actionState) {
			case (ActionState.DOWN)    : trace("action 1 - DOWN");
			case (ActionState.UP)      : trace("action 1 - UP");
			case (ActionState.REPEAT)  : trace("action 1 - REPEAT");
			default: trace("error");
		}
	}
	
	function switchFullscreen(_) {
		window.fullscreen = !window.fullscreen;
	}
	
	// ------------------------------------------------------------	
	// ------------------------------------------------------------	
	// ------------------------------------------------------------
	
	public override function render (context:RenderContext):Void 
	{
		switch (context.type) {
			case CAIRO:	var cairo = context.cairo; cairo.setSourceRGB (0.75, 1, 0);	cairo.paint ();
			case CANVAS: var ctx = context.canvas2D; ctx.fillStyle = "#BFFF00";	ctx.fillRect (0, 0, window.width, window.height);
			case DOM: var element = context.dom; element.style.backgroundColor = "#BFFF00";
			case FLASH: var sprite = context.flash; sprite.graphics.beginFill (0xBFFF00); sprite.graphics.drawRect (0, 0, window.width, window.height);
			case OPENGL, OPENGLES, WEBGL: var gl = context.webgl; gl.clearColor (0.75, 1, 0, 1); gl.clear (gl.COLOR_BUFFER_BIT);
			default:
		}
	}
	
	
}