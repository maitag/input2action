package input2actions;

import input2actions.ActionMap;
import lime.ui.Gamepad;
import lime.ui.GamepadAxis;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
//import lime.ui.KeyModifier;
import lime.ui.Window;

import json2object.JsonParser;
import json2object.JsonWriter;


import input2actions.util.EnumMacros;
import input2actions.InputState.ActionState;

/**
 * by Sylvio Sell - Rostock 2019
*/


class Input2Actions 
{
	public var actionMap(default, null):ActionMap;
	
	public function new(actionConfig:ActionConfig, actionMap:ActionMap ) 
	{
		this.actionMap = actionMap;
		
		// Todo: minimize keyboardState vector
		// var minKeyRangeL = 0x7fffffff;
		// var maxKeyRangeL = 0;
		
		keyboardState = new InputState(MAX_USABLE_KEYCODES);
		gamepadState = new InputState(GamepadButton.DPAD_RIGHT + 1);
		
		var actionMapItem:ActionMapItem;			
		var key:Int;
		var modkey:Int;
		
		for (actionConfigItem in actionConfig)
		{
			actionMapItem = actionMap.get(actionConfigItem.action);
			
			if (actionMapItem.action != null)
			{
				var actionState = new ActionState(actionMapItem.up, actionMapItem.each, actionConfigItem.single, actionMapItem.action #if input2actions_debug ,actionConfigItem.action #end);
				
				// ---- keyboard ----
				
				if (actionConfigItem.keyboard != null) {
					for (keys in actionConfigItem.keyboard) {
						switch (keys.length)
						{
							case 1:	key = fromKeyCode(keys[0]); modkey = 0; 
							case 2:	
								#if input2actions_singlekey
								throw('ERROR, multiple keys is disabled by compiler define: "input2actions_singlekey"');
								#else
								key = fromKeyCode(keys[1]); modkey = fromKeyCode(keys[0]);
								#end
							default: throw("ERROR, only one modifier key is allowed!");
						}						
						keyboardState.addAction(actionState, key, modkey);						
					}
				}
				
				// ---- gamepad ----
				
				if (actionConfigItem.gamepad != null) {
					for (keys in actionConfigItem.gamepad) {
						switch (keys.length)
						{
							case 1:	key = keys[0]; modkey = 0; 
							case 2:	
								#if input2actions_singlekey
								throw('ERROR, multiple keys is disabled by compiler define: "input2actions_singlekey"');
								#else
								key = keys[1]; modkey = keys[0];
								#end
							default: throw("ERROR, only one modifier key is allowed!");
						}						
						gamepadState.addAction(actionState, key, modkey);						
					}
				}
				
			}
		}
		
		// debug
		trace(keyboardState);
		
		
	}
	
	public function enable(window:Window) {
		window.onKeyDown.add(keyDown);
		window.onKeyUp.add(keyUp);
		
		for (gamepad in Gamepad.devices) gamepadConnect(gamepad);
		Gamepad.onConnect.add(gamepadConnect);
		//Gamepad.addMappings(["", ""]);
		//Joystick.onConnect.add(joystickConnectActive);
		
	}
	
	public function disable(window:Window) {
		window.onKeyDown.remove(keyDown);
		window.onKeyUp.remove(keyUp);
	}
	
	
	
	// ---------------- Keyboard -----------------------------
	
	public static var keyCodeName(default, never) = EnumMacros.nameByValue(KeyCode);
	public static var keyCodeValue(default, never) = EnumMacros.valueByName(KeyCode);
	
	
	var keyboardState:InputState;
	static inline var UNUSED_KEYCODE_START:Int = KeyCode.DELETE + 1; // 0x80;
	static inline var UNUSED_KEYCODE_END:Int = KeyCode.CAPS_LOCK; // 0x40000039;
	static inline var MAX_USABLE_KEYCODES:Int = fromKeyCode(KeyCode.SLEEP) + 1;
	
	// removes all unused keys between KeyCode.DELETE and KeyCode.CAPS_LOCK
	static public inline function fromKeyCode(k:KeyCode):Int {
		return (k < UNUSED_KEYCODE_END) ? k : k - UNUSED_KEYCODE_END + UNUSED_KEYCODE_START;
	}
	
	// extract back to full KeyCode range
	static public inline function toKeyCode(k:Int):KeyCode {
		return (k < UNUSED_KEYCODE_START) ? k : k + UNUSED_KEYCODE_END - UNUSED_KEYCODE_START;
	}
	
	inline function keyDown(key:KeyCode, _):Void
	{
		//trace("keyDown:",StringTools.hex(fromKeyCode(Std.int(key))));

		// case KeyCode.TAB: untyped __js__('event.preventDefault();');
		
		#if neko // TODO: check later into lime > 7.9.0
		keyboardState.callDownActions( fromKeyCode(Std.int(key)) );
		#else
		keyboardState.callDownActions( fromKeyCode(key) );
		#end
	}
	
	inline function keyUp(key:KeyCode, _):Void
	{
		#if neko // TODO: check later into lime > 7.9.0	
		keyboardState.callUpActions( fromKeyCode(Std.int(key)) );
		#else
		keyboardState.callUpActions( fromKeyCode(key) );
		#end
	}
	
	
	
	// ---------------- GamePad -----------------------------
	
	var gamepadState:InputState;

	public static var gamepadButtonName(default, never) = EnumMacros.nameByValue(GamepadButton);
	public static var gamepadButtonValue(default, never) = EnumMacros.valueByName(GamepadButton);
			
	inline function gamepadConnect (gamepad:Gamepad):Void
	{
		
		trace ("Gamepad connected: " + gamepad.id + ", " + gamepad.guid + ", " + gamepad.name);
		gamepad.onDisconnect.add(gamepadDisconnect.bind(gamepad));
		gamepad.onButtonDown.add(gamepadButtonDown);
		gamepad.onButtonUp.add(gamepadButtonUp);
		gamepad.onAxisMove.add(gamepadAxisMove.bind(gamepad, _));
		
	}
		
	inline function gamepadDisconnect (gamepad:Gamepad):Void 
	{		
		trace ("Gamepad disconnected: " + gamepad.id + ", " + gamepad.guid + ", "+ gamepad.name);	
		gamepad.onDisconnect.remove(gamepadDisconnect.bind(gamepad));
		gamepad.onButtonDown.remove(gamepadButtonDown);
		gamepad.onButtonUp.remove(gamepadButtonUp);
		gamepad.onAxisMove.remove(gamepadAxisMove.bind(gamepad, _));
		gamepad = null;
	}
	
	inline function gamepadButtonDown(button:GamepadButton):Void
	{
		//trace("gamepadButtonDown:",Std.int(button));
		#if neko // TODO: check later into lime > 7.9.0
		gamepadState.callDownActions( Std.int(button) );
		#else
		gamepadState.callDownActions( button );
		#end
	}
	
	inline function gamepadButtonUp(button:GamepadButton):Void
	{
		#if neko // TODO: check later into lime > 7.9.0	
		gamepadState.callUpActions( Std.int(button) );
		#else
		gamepadState.callUpActions( button );
		#end
	}

	inline function gamepadAxisMove(gamepad:Gamepad, axis:GamepadAxis, value:Float):Void
	{	
		if (value < -0.5) {
			//trace (axis, value);					
		} else if (value > 0.5) {
			//trace (axis, value);
		}
/*		switch (axis) {		
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
*/		
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