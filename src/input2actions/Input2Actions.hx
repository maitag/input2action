package input2actions;

import haxe.ds.Vector;
import haxe.ds.IntMap;


import input2actions.KeyCodeOptimized;
import lime.ui.Gamepad;
import lime.ui.GamepadAxis;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;

import json2object.JsonParser;
import json2object.JsonWriter;


/**
 * by Sylvio Sell - Rostock 2019
*/

private class KeyboardAction {
	public var action:ActionFunction;
	public var state(default, null):ActionState;
	public var isDown:Bool = false;
	public function new(state:ActionState, action:ActionFunction) {
		this.action = action;
		this.state = state;
	}
}


class Input2Actions 
{	
	public function new(actionConfig:ActionConfig, actionMap:ActionMap ) 
	{
		
		// converting actionMap to actionVector
		var minKeyRangeL = 0x7fffffff;
		var maxKeyRangeL = 0;
		
		var minKeyRangeH = 0x7fffffff;
		var maxKeyRangeH = 0;

		var f:ActionFunction;
		var c:ActionConfig.ActionConfigItem;
		
		//var modKeys = new Array<Array<KeyCodeOptimized>>(); // Optimize: balanced FastIntMap
		//var singleKeys = new Array<KeyCodeOptimized>();
		
		for (k in actionConfig.keys())
		{
			trace(k);
			f = actionMap.get(k);
			if (f != null)
			{
				c = actionConfig.get(k);
				trace(c.up);
				trace(c.down);
				trace(c.repeat);
				
				if (c.keyboard != null) {
					for (keys in c.keyboard) {
						switch (keys.length)
						{
							case 1:
								//singleKeys.push(keys[0]);
							case 2: 
								//var k0:KeyCodeOptimized = keys[0];
								//var a:Array<KeyCodeOptimized>;
								//
								//if ( modKeys.exists(mk) ) {
									//a = modKeys.get(mk);
									//if () throw("ERROR, double");
									//a.push(keys[1]);
								//}
								//else a = [ keys[1] ];
								
							default: throw("ERROR, only one modifier key is allowed!");
						}
					}
				}
				
			}
		}
		
		//trace("firstKeys", firstKeys);
		
		// for ...keyboardActions.push();
		
	}
	
	public function enable(window:Window) {
		window.onKeyDown.add(keyDown);
		window.onKeyUp.add(keyUp);
	}
	
	public function disable(window:Window) {
		window.onKeyDown.remove(keyDown);
		window.onKeyUp.remove(keyUp);
	}
	
	inline function keyDown(key:KeyCode, modifier:KeyModifier):Void
	{
		// case KeyCode.TAB: untyped __js__('event.preventDefault();');
		callKeyboardAction(key, modifier, ActionState.DOWN);
	}
	
	inline function keyUp(key:KeyCode, modifier:KeyModifier):Void
	{
		callKeyboardAction(key, modifier, ActionState.UP);
	}
	
	// ---------------- Keyboard -----------------------------
	
	public var lastKey(default, null):KeyCodeOptimized = KeyCodeOptimized.UNKNOWN;
	
	var minKeyCode:KeyCodeOptimized;
	var maxKeyCode:KeyCodeOptimized;
		
	var keyboardActions:Vector<KeyboardAction>;
	var keyboardActionsSize:Int = 0;
	
	inline function callKeyboardAction(key:KeyCodeOptimized, modifier:KeyModifier, actionState:ActionState) {
		
		trace(key, modifier, actionState);
		
		//keyboardActions.get(key)(InputType.KEYBOARD, actionState);
		
		//lastKey = key;
	}
	
	
	// ---------------- GamePad -----------------------------
	
	
	function onGamepadConnect (gamepad:Gamepad):Void {
		
		trace ("Gamepad connected: " + gamepad.id + ", " + gamepad.name);
		
	}
	
	
	function onGamepadDisconnect (gamepad:Gamepad):Void {
		
		trace ("Gamepad disconnected: " + gamepad.id);
		
	}
	
	function onGamepadAxisMove (gamepad:Gamepad, axis:GamepadAxis, value:Float):Void {
		
		switch (axis) {
			
			case GamepadAxis.LEFT_X:
				
				if (value < -0.5) {
					trace ("axis left");					
				} else if (value > 0.5) {
					trace ("axis right");
				}
			
			case GamepadAxis.LEFT_Y:
				
				if (value < -0.5) {
					trace ("axis up");
				} else if (value > 0.5) {
					trace ("axis down");
				}
			
			default:
			
		}
		
	}
	
	
	public function callGamePadAction(gamepad:Gamepad, button:GamepadButton) {
		
		//keyboardActions.get(button)(ActionType.GAMEPAD, gamepad.id);
		
	}

	
	
	
	
/*		
		var writer = new JsonWriter<ActionConfig>(); // Creating a writer for Cls class
		var jsonString = writer.write(actionConfig);
		trace(jsonString);
		trace("-----------");
		
		actionConfig.set("action2",
			{
				down:false,
				up:true, repeat:false, repeatRate:1100,
				keyboard  : [ KeyCode.LEFT, KeyCode.A, [KeyCode.LEFT_SHIFT, KeyCode.A], [KeyCode.RIGHT_SHIFT, KeyCode.A]  ],
				gamepad   : [ GamepadButton.LEFT_STICK ]
			}
		);
		
		actionConfig.remove("action1");
		
		jsonString = writer.write(actionConfig);
		trace(jsonString);
		trace("-----------");
		
*/		
		
		
		//var parser = new json2object.JsonParser<Map<String, ActionConfigItem>>(); // Creating a parser for Cls class
		//parser.fromJson(jsonString, "test.json"); // Parsing a string. A filename is specified for errors management
		//var actionConfig1:ActionConfig = parser.value; // Access the parsed class
		//trace(actionConfig1);
		
/*		for (e in parser.errors) {
				var pos = switch (e) {case IncorrectType(_, _, pos) | IncorrectEnumValue(_, _, pos) | InvalidEnumConstructor(_, _, pos) | UninitializedVariable(_, pos) | UnknownVariable(_, pos) | ParserError(_, pos) | CustomFunctionException(_, pos): pos;}
				trace(pos.lines[0].number);
				if (pos != null) haxe.Log.trace(json2object.ErrorUtils.convertError(e), {fileName:pos.file, lineNumber:pos.lines[0].number,className:"",methodName:""});
			}
*/		
	
	
	
	
	

}