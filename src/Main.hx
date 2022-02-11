package;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.system.Locale;


import lime.ui.KeyCode;
import lime.ui.GamepadButton;
//import lime.ui.Gamepad;
//import lime.ui.GamepadAxis;



import input2actions.ActionConfig;
import input2actions.ActionMap;
import input2actions.Input2Actions;



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
				"single"    : "false",
				"keyboard"  : "LEFT, A, LEFT_SHIFT A, RIGHT_SHIFT A",
				"gamepad"   : "LEFT_STICK"
			}
		]
		';
*/		
		//var actionConfig:ActionConfig = actionConfigJson;

		// defined in haxe:
		var actionConfig:ActionConfig = [
			{
				action: "action1",  // key for ActionMap				
				keyboard: [ 
					#if !input2actions_noKeyCombos
					[KeyCode.A, KeyCode.S], // key-combo ("a" have to press first)
					#end
					KeyCode.LEFT_SHIFT, KeyCode.Y    // additional multiple single keys for this action
			    ],				
				gamepad: [ GamepadButton.A ]
			},
			{
				action: "action2",
				// TODO: reverseCombo:true, // adds also [KeyCode.S, KeyCode.D] combination
				keyboard: [ 
					#if !input2actions_noKeyCombos
					[KeyCode.D, KeyCode.S],  // key-combo ("d" have to press first)
					#else
					KeyCode.D,    // additional multiple single keys for this action
					#end
				],				
				gamepad: [ GamepadButton.B ]
			},
			{
				action: "action3",
				
				// only trigger if pressed alone and not if there is also another key-combo action for this keys
				single:true, // (false by default)
				
				keyboard: [ KeyCode.S, KeyCode.C ],
				gamepad: [ GamepadButton.X, GamepadButton.Y ]
				
			},
			{
				action: "switchFullscreen",
				keyboard: [ KeyCode.F ],
			},
		];
		
		// Player 0 bindings
		var actionConfigPlayer0:ActionConfig = [
			{	action: "action1",
				keyboard: [ KeyCode.LEFT_SHIFT ],
			},
		];
		
		// Player 1 bindings
		var actionConfigPlayer1:ActionConfig = [
			{	action: "action1",
				keyboard: [ KeyCode.RIGHT_SHIFT ],
			},
			{	action: "action2",
				keyboard: [ KeyCode.L ],				
			},
			{	action: "action3",
				single:false,
				keyboard: [ KeyCode.M ],
				gamepad: [ GamepadButton.DPAD_LEFT ],			
			},
		];
		
		
		// ------ mapping to the action-function-references
		
		var actionMap:ActionMap = [
			"action1" => {
				action:action1,
				//actionAxis:actionAxis1,
				up: true,  // enables key/button "up"-event
				
				// if multiple keys pressed/released together:
				// each: false, // (default) "down"-event fires only for the first key/button, "up"-event only after the last key/button is released
				each: true // fire events for each key/button			
			},
			"action2" => {action:action2},
			"action3" => {action:action3},
			"switchFullscreen" => {action:switchFullscreen},
		];
		
		
/*
		// TODO: set defaults and let force it also outside of config/json !

		actionConfig.defaults({
			single:true,
			forceSingle:true,
		});
		
		actionConfig.force({
			single:true,
			forceSingle:true,
		});
		
		//trace(actionConfig.toJson);
*/
		
		var input2Actions = new Input2Actions(actionConfig, actionMap);
		// TODO:
		//var maxPlayer = 8;
		//var input2Actions = new Input2Actions( maxPlayer, actionMapKey, actionMapAxis , actionConfigDefault, dontConnectDevicesByDefault);
		
		// set keyboard bindings for player 0
		input2Actions.setKeyboard(0, actionConfig);
		
		// event handler for new plugged gamepads
		//input2Actions.onGamePadConnect() = function(gamepad:GamePad) {
		//    //if (game.addPlayer()) ... // check for available players
		//    // set gamepad for player 1
		//    input2Actions.setGamepad(1, gamepad, actionConfig1);
		//    // set another config for the same gamepad but another player 2
		//    input2Actions.setGamepad(2, gamepad, actionConfig2);
		//}

		//input2Actions.onGamePadDisconnect() = function(player:Int) {
		//    input2Actions.removeGamepad(1);
		//    //game.playerDisconnected(1);
		//}
		
		
		// update only the keyboard bindings for player 1
		//input2Actions.setKeyboard(1, actionConfig1);
		
		// TODO
		//input2Actions.setJoystick(2, joystick, actionConfig2);

		// set keyboard, gamepad and joystick bindings for player 0
		// input2Actions.set(0, actionConfig0, gamepad, joystick);
		
		// swap input of player 0 and player 1
		// input2Actions.swap(0, 1)
		
		// disable and enable input of player 1
		//input2Actions.disable(1);
		//input2Actions.enable(1);
		

		
		
		
		// TODO: save the modified config into json
		
		
		input2Actions.enable(window);
		//input2Actions.disable(window);

	}
	
	
	// ------------------------------------------------------------	
	// -------------------- Actions -------------------------------	
	// ------------------------------------------------------------
	
	function action1(isDown:Bool, player:Int) 
	{
		trace('action 1 - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function action2(isDown:Bool, player:Int) 
	{
		trace('action 2 - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function action3(isDown:Bool, player:Int) 
	{
		trace('action 3 - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function switchFullscreen(isUp:Bool, player:Int) {
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