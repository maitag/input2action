package input2actions;

import lime.ui.Gamepad;
import lime.ui.GamepadAxis;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
//import lime.ui.KeyModifier;
import lime.ui.Window;

import json2object.JsonParser;
import json2object.JsonWriter;


/**
 * by Sylvio Sell - Rostock 2019
*/


class Input2Actions 
{
	var keyboardState:InputState;
	static inline var UNUSED_KEYCODE_START:Int = KeyCode.DELETE + 1; // 0x80;
	static inline var UNUSED_KEYCODE_END:Int = KeyCode.CAPS_LOCK; // 0x40000039;
	static inline var MAX_USABLE_KEYCODES:Int = fromKeyCode(KeyCode.SLEEP) + 1;
	
	// removes all unused keys between KeyCode.DELETE and KeyCode.CAPS_LOCK
	static public inline function fromKeyCode(k:KeyCode):Int {
		return (k < UNUSED_KEYCODE_END) ? k : k - UNUSED_KEYCODE_END + UNUSED_KEYCODE_START;
	}
	
	// extract back to full KeyCode range
	static public inline function toKeyCode(k:KeyCode):KeyCode {
		return (k < UNUSED_KEYCODE_START) ? k : k + UNUSED_KEYCODE_END - UNUSED_KEYCODE_START;
	}
	
	
	
	public function new(actionConfig:ActionConfig, actionMap:ActionMap ) 
	{
		//trace(StringTools.hex(fromKeyCode(KeyCode.BACKSPACE)));
		//trace(StringTools.hex(fromKeyCode(KeyCode.DELETE)));
		//trace(StringTools.hex(fromKeyCode(KeyCode.CAPS_LOCK)));
		//trace(StringTools.hex(fromKeyCode(KeyCode.SLEEP)));
		
		keyboardState = new InputState(MAX_USABLE_KEYCODES);
		
		// converting actionMap to actionVector
		var minKeyRangeL = 0x7fffffff;
		var maxKeyRangeL = 0;
		
		var actionFunction:ActionFunction;
		var c:ActionConfig.ActionConfigItem;
		
		
		var key:KeyCode;
		var modkey:KeyCode;
		
		for (action in actionConfig.keys())
		{
			trace("action:", action);
			actionFunction = actionMap.get(action);
			if (actionFunction != null)
			{
				c = actionConfig.get(action);
				//trace(c.up);
				//trace(c.down);
				//trace(c.repeat);
				
				if (c.keyboard != null) {
					for (keys in c.keyboard) {
						switch (keys.length)
						{
							case 1:	key = fromKeyCode(keys[0]); modkey = null; 
							case 2:	key = fromKeyCode(keys[1]); modkey = fromKeyCode(keys[0]);
							default: throw("ERROR, only one modifier key is allowed!");
						}
						if (c.down) keyboardState.addDownAction(actionFunction, key, modkey);
						if (c.up) keyboardState.addUpAction(actionFunction, key, modkey);
						
					}
				}
				
			}
		}
		
		trace(keyboardState);
	}
	
	public function enable(window:Window) {
		window.onKeyDown.add(keyDown);
		window.onKeyUp.add(keyUp);
	}
	
	public function disable(window:Window) {
		window.onKeyDown.remove(keyDown);
		window.onKeyUp.remove(keyUp);
	}
	
	
	
	// ---------------- Keyboard -----------------------------
	
	inline function keyDown(key:KeyCode, _):Void
	{
		//trace("keydown:",StringTools.hex(fromKeyCode(Std.int(key))));

		// case KeyCode.TAB: untyped __js__('event.preventDefault();');
		
		#if neko // TODO: check later into lime > 7.9.0
		keyboardState.callDownActions( fromKeyCode(Std.int(key)) );
		#else
		keyboardState.callDownActions( fromKeyCode(key) );
		#end
	}
	
	inline function keyUp(key:KeyCode, _):Void
	{
		//trace("keyup:",StringTools.hex(fromKeyCode(Std.int(key))));

		#if neko // TODO: check later into lime > 7.9.0	
		keyboardState.callUpActions( fromKeyCode(Std.int(key)) );
		#else
		keyboardState.callUpActions( fromKeyCode(key) );
		#end
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