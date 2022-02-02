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
import input2actions.ActionFunction;
import input2actions.ActionMap;


import input2actions.ActionConfig;
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

		// defined in haxe
		var actionConfig:input2actions.ActionConfig = [
			{
				action: "action2",  // key for ActionMap				
				keyboard: [ 
					#if !input2actions_noKeyCombos
					[KeyCode.A, KeyCode.S], // key-combo ("a" have to press first)
					#end
					KeyCode.LEFT_SHIFT, KeyCode.Y    // additional multiple single keys for this action
			    ],				
				gamepad: [ GamepadButton.A ]
			},
			{
				action: "action3",
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
				action: "action1",
				
				// only trigger if pressed alone and not if there is also another key-combo action for this keys
				single:true, // (false by default)
				
				keyboard: [ KeyCode.S, KeyCode.C ],
				
				// for 2 player-setup this would gives keyboard-id 2 for "k"
				// keyboard : [ [KeyCode.S],  [KeyCode.K]  ],
				
				gamepad: [ GamepadButton.X, GamepadButton.Y ]
			},
			{
				action: "switchFullscreen",
				keyboard: [ KeyCode.F ],
			},
		];
		
		//var actionConfigJson:ActionConfigJson = actionConfig;
		//trace(actionConfigJson);
		
		var actionMap:ActionMap = [
			"action1" => {
				action:action1,
				up: true,  // enables key/button "up"-event
				
				// if multiple keys pressed/released together:
				// each: false, // (default) "down"-event fires only for the first key/button, "up"-event only after the last key/button is released
				each: true // fire events for each key/button			
			},
			"action2" => {action:action2},
			"action3" => {action:action3},
			"switchFullscreen" => {action:switchFullscreen},
		];
		
		
		var input2Actions = new Input2Actions(actionConfig, actionMap);
/*
		// TODO: set defaults and let force it also outside of config/json !

		var input2Actions = new Input2Actions(actionConfig, actionMap, {
			up:true, // default value for "up" if it is not defined
			forceUp:true, // force to "up"-default-value even if it is defined
			each:false,
			forceEach:false,
			single:true,
			forceSingle:true,
		});
*/
		
		//input2Actions.config(actionConfig, actionMap);
		
		input2Actions.enable(window);
		//input2Actions.disable(window);

	}
	
	
	// ------------------------------------------------------------	
	// -------------------- Actions -------------------------------	
	// ------------------------------------------------------------
	
	function action1(isUp:Bool, player:Int) 
	{
		trace('action 1 - ${(isUp) ? "UP" : "DOWN"}, player:$player');
	}
	
	function action2(isUp:Bool, player:Int) 
	{
		trace('action 2 - ${(isUp) ? "UP" : "DOWN"}, player:$player');
	}
	
	function action3(isUp:Bool, player:Int) 
	{
		trace('action 3 - ${(isUp) ? "UP" : "DOWN"}, player:$player');
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