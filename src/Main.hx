package;

import input2actions.util.EnumMacros;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.system.Locale;

//import lime.ui.Gamepad;
//import lime.ui.GamepadAxis;

import lime.ui.KeyCode;
import lime.ui.GamepadButton;


import input2actions.InputType;
import input2actions.ActionType;
import input2actions.ActionFunction;
import input2actions.ActionMap;


import input2actions.ActionConfig;
import input2actions.Input2Actions;
import input2actions.KeySetting;



class Main extends Application {
	
		
	public override function onWindowCreate ():Void 
	{
		//trace(Locale.currentLocale.language);
/*		
		// json2obj:
		var actionConfigJson:ActionConfigJson =
		'
		[
			{	"action"    : "action1",
				"down"      : "ones",
				"up"        : "none",
				"repeat"    : "0",
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
			#if !input2actions_singlekey
			{
				action: "action2",  // key for ActionMap
				
				// multiple keys for the same action, ANY:all the time, NONE:disabled
				// #if input2actions_noMultiKeySetting
				// down: KeySetting.ANY,  // if the ANY key is pressed down
				// up:   KeySetting.ANY,  // if the ANY key is released up
				// #else
				down: KeySetting.ONES,  // only if the first key is pressed down
				up:   KeySetting.ONES,  // only if the last key released up
				// #end
				
				//repeat:10,
				//repeatRate:1100,
				
				keyboard: [ 
					[KeyCode.A, KeyCode.S], // double-key-combo ("a" have to press first)
					KeyCode.LEFT_SHIFT, KeyCode.Y    // additional single key for this action
			    ],
				
				//gamepad   : [ GamepadButton.LEFT_STICK ]
			},
			{
				action: "action3",
				
				//reverseKeyCombos:true, // adds also [KeyCode.S, KeyCode.D] combination
				keyboard: [ 
					[KeyCode.D, KeyCode.S]  // double-key-combo ("d" have to press first)
				],
				
				//gamepad   : [ GamepadButton.LEFT_STICK ]
			},
			#end
			{
				action: "action1",
				
				single:true, // only trigger if pressed alone and not inside of a key-combo (default is true if there is no key-combos defined)
				// better naming: singleKeyAlone:true,
				
				keyboard: [ KeyCode.S, KeyCode.C ],
				
				// for 2 player-setup this would gives keyboard-id 2 for "k"
				// keyboard : [ [KeyCode.S],  [KeyCode.K]  ],
				
				//gamepad   : [ GamepadButton.LEFT_STICK ]
			},
			//"switchFullscreen" =>
			//{
				//keyboard  : [ KeyCode.F ],
			//},
		];
		
		//var actionConfigJson:ActionConfigJson = actionConfig;
		//trace(actionConfigJson);
		
		var actionMap:ActionMap = [
			"action1" => action1,
			"action2" => action2,
			"action3" => action3,
			"switchFullscreen" => switchFullscreen,
		];
		
		
		var input2Actions = new Input2Actions(actionConfig, actionMap);

		//input2Actions.config(actionConfig, actionMap);
		
		input2Actions.enable(window);
		//input2Actions.disable(window);

	}
	
	
	// ------------------------------------------------------------	
	// -------------------- Actions -------------------------------	
	// ------------------------------------------------------------
	
	function action1(inputType:InputType, actionState:ActionType) 
	{
		var type:String;
		switch (inputType) {
			case (InputType.KEYBOARD) : type = "Keyboard";
			case (InputType.GAMEPAD)  : type = "GamePad";
			case (InputType.JOYSTICK) : type = "JoyStick";
			default: type = "unknown";
		}
		
		switch (actionState) {
			case (ActionType.DOWN)    : trace("action 1 - DOWN");
			case (ActionType.UP)      : trace("action 1 - UP");
			case (ActionType.REPEAT)  : trace("action 1 - REPEAT");
			default: trace("error");
		}
	}
	
	function action2(inputType:InputType, actionState:ActionType) 
	{
		var type:String;
		switch (inputType) {
			case (InputType.KEYBOARD) : type = "Keyboard";
			case (InputType.GAMEPAD)  : type = "GamePad";
			case (InputType.JOYSTICK) : type = "JoyStick";
			default: type = "unknown";
		}
		
		switch (actionState) {
			case (ActionType.DOWN)    : trace("action 2 - DOWN");
			case (ActionType.UP)      : trace("action 2 - UP");
			case (ActionType.REPEAT)  : trace("action 2 - REPEAT");
			default: trace("error");
		}
	}
	
	function action3(inputType:InputType, actionState:ActionType) 
	{
		var type:String;
		switch (inputType) {
			case (InputType.KEYBOARD) : type = "Keyboard";
			case (InputType.GAMEPAD)  : type = "GamePad";
			case (InputType.JOYSTICK) : type = "JoyStick";
			default: type = "unknown";
		}
		
		switch (actionState) {
			case (ActionType.DOWN)    : trace("action 3 - DOWN");
			case (ActionType.UP)      : trace("action 3 - UP");
			case (ActionType.REPEAT)  : trace("action 3 - REPEAT");
			default: trace("error");
		}
	}
	
	function switchFullscreen(inputType:InputType, actionState:ActionType) {
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