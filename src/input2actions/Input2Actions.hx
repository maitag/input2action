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

//@:forward
abstract KeyboardState(Vector<KeyboardAction>) from Vector<KeyboardAction> to Vector<KeyboardAction>
{
	
	inline public function new(size:Int) {
		this = new Vector<KeyboardAction>(size);
		//for (i in 0...512) this.set(i, null);
	}


	public inline function addDownAction(action:ActionFunction, key:Int, modKey:Int = null) {
		var keyboardAction = this.get(key);
		if (keyboardAction == null) {
			keyboardAction = new KeyboardAction();
			this.set(key, keyboardAction);
		}
		
		if (modKey == null) {
			if (keyboardAction.singleActionDown != null) throw('Error, the single action to key $key is already defined');
			keyboardAction.singleActionDown = action;
		}
		else {
			if (keyboardAction.modifierActionDown == null) keyboardAction.modifierActionDown = new Array<ModifierAction>();
			else for (ma in keyboardAction.modifierActionDown) if (ma.keyCode == modKey) throw('Error, the action to key $key and modkey $modKey is already defined');
			keyboardAction.modifierActionDown.push(new ModifierAction(modKey, action));			
		}
	}
	
	public inline function addUpAction(action:ActionFunction, key:Int, modKey:Int = null) {
		var keyboardAction = this.get(key);
		if (keyboardAction == null) {
			keyboardAction = new KeyboardAction();
			this.set(key, keyboardAction);
		}
		
		if (modKey == null) {
			if (keyboardAction.singleActionUp != null) throw('Error, the single action to key $key is already defined');
			keyboardAction.singleActionUp = action;
		}
		else {
			if (keyboardAction.modifierActionUp == null) keyboardAction.modifierActionUp = new Array<ModifierAction>();
			else for (ma in keyboardAction.modifierActionUp) if (ma.keyCode == modKey) throw('Error, the action to key $key and modkey $modKey is already defined');
			keyboardAction.modifierActionUp.push(new ModifierAction(modKey, action));			
		}
	}
	
	public inline function isDown(key:Int):Bool {
		var keyboardAction = this.get(key);
		if (keyboardAction == null) return false;
		else return keyboardAction.isDown;
	}
	
	public inline function callDownActions(key:Int) {
		var keyboardAction = this.get(key);
		if (keyboardAction != null && !keyboardAction.isDown) {
			keyboardAction.isDown = true;
			
			if (keyboardAction.singleActionDown != null) keyboardAction.singleActionDown(InputType.KEYBOARD, ActionState.DOWN);
			
			if (keyboardAction.modifierActionDown != null) {
				for (modifierAction in keyboardAction.modifierActionDown) {
					if (isDown(modifierAction.keyCode)) {
						modifierAction.action(InputType.KEYBOARD, ActionState.DOWN);
					}
				}
			}
			
		}
	}

	public function callUpActions(key:Int) {
		var keyboardAction = this.get(key);
		if (keyboardAction != null && keyboardAction.isDown) {
			keyboardAction.isDown = false;
			
			if (keyboardAction.singleActionUp != null) keyboardAction.singleActionUp(InputType.KEYBOARD, ActionState.UP);
			
			if (keyboardAction.modifierActionUp != null) {
				for (modifierAction in keyboardAction.modifierActionUp) {
					if (isDown(modifierAction.keyCode)) modifierAction.action(InputType.KEYBOARD, ActionState.UP);
				}
			}
			
		}
	}
}


private class KeyboardAction {
	public var isDown:Bool = false;
	
	public var singleActionDown:ActionFunction = null;
	public var modifierActionDown:Array<ModifierAction> = null;
	
	public var singleActionUp:ActionFunction = null;
	public var modifierActionUp:Array<ModifierAction> = null;
	
	public var singleActionRepeat:ActionFunction = null;
	public var modifierActionRepeat:Array<ModifierAction> = null;
		
	public function new() {
	}
}

private class ModifierAction {
	public var keyCode:Int;
	public var action:ActionFunction;
	public function new(keyCode:Int, action:ActionFunction) {
		this.keyCode = keyCode;
		this.action = action;	
	}
}




class Input2Actions 
{
	var keyboardState:KeyboardState;
	
	public function new(actionConfig:ActionConfig, actionMap:ActionMap ) 
	{
		keyboardState = new KeyboardState(512);
		
		// converting actionMap to actionVector
		var minKeyRangeL = 0x7fffffff;
		var maxKeyRangeL = 0;
		
		var actionFunction:ActionFunction;
		var c:ActionConfig.ActionConfigItem;
		
		//var modKeys = new Array<Array<KeyCodeOptimized>>(); // Optimize: balanced FastIntMap
		//var singleKeys = new Array<KeyCodeOptimized>();
		
		var key:KeyCode;
		var modkey:KeyCode;
		
		for (action in actionConfig.keys())
		{
			trace("action:", action);
			actionFunction = actionMap.get(action);
			if (actionFunction != null)
			{
				c = actionConfig.get(action);
				trace(c.up);
				trace(c.down);
				trace(c.repeat);
				
				if (c.keyboard != null) {
					for (keys in c.keyboard) {
						switch (keys.length)
						{
							case 1:	key = keys[0]; modkey = null; 
							case 2:	key = keys[1]; modkey = keys[0]; 
							default: throw("ERROR, only one modifier key is allowed!");
						}
						
						if (c.down) keyboardState.addDownAction(actionFunction, key, modkey);
						if (c.down) keyboardState.addUpAction(actionFunction, key, modkey);
						
					}
				}
				
			}
		}
		
		//trace(keyboardState);
		
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
	
	inline function keyDown(key:KeyCode, modifier:KeyModifier):Void
	{
		// case KeyCode.TAB: untyped __js__('event.preventDefault();');
		#if neko // TODO: check later into lime > 7.9.0
		keyboardState.callDownActions(Std.int(key)); // thx to signmajesty
		#else
		keyboardState.callDownActions(key);
		#end
	}
	
	inline function keyUp(key:KeyCode, modifier:KeyModifier):Void
	{
		#if neko	
		keyboardState.callUpActions(Std.int(key));
		#else
		keyboardState.callUpActions(key);
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