package input2actions;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.ds.Vector;
import input2actions.ActionConfig;
import input2actions.ActionMap;
import input2actions.InputState;
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
	public var actionConfigDefault(default, null):ActionConfig;
	
	public function new(actionConfig:ActionConfig, actionMap:ActionMap ) 
	{
		this.actionMap = actionMap;
		this.actionConfigDefault = actionConfig;
		
		// Todo: minimize keyboardState vector
		// var minKeyRangeL = 0x7fffffff;
		// var maxKeyRangeL = 0;
			
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
	
	// -----------------------------------------------------
	
	var actionStatePlayers = new Vector<StringMap<ActionState>>(8);

	function getOrCreateActionState(actionMapItem:ActionMapItem, actionConfigItem:ActionConfigItem, player:Int):ActionState {
		var actionStatePlayer:StringMap<ActionState> = actionStatePlayers.get(player);
		if (actionStatePlayer == null) {
			actionStatePlayer = new StringMap<ActionState>();
			actionStatePlayers.set(player, actionStatePlayer);
		}
		var actionState = actionStatePlayer.get(actionConfigItem.action);
		if (actionState == null)
		{
			actionState = new ActionState(actionMapItem.up, actionMapItem.each, actionConfigItem.single, actionMapItem.action, player #if input2actions_debug ,actionConfigItem.action #end);
			actionStatePlayer.set(actionConfigItem.action, actionState);
		}
		return actionState;			
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
	
	public function setKeyboard(player:Int, actionConfig:ActionConfig) {
		
		var actionMapItem:ActionMapItem;			
		var key:Int;
		var modkey:Int;

		if (keyboardState==null) keyboardState = new InputState(MAX_USABLE_KEYCODES);

		for (actionConfigItem in actionConfig)
		{
			if (actionConfigItem.keyboard != null && actionConfigItem.keyboard.length != 0) 
			{
				actionMapItem = actionMap.get(actionConfigItem.action);				
				if (actionMapItem.action != null)
				{
					var actionState = getOrCreateActionState(actionMapItem, actionConfigItem, player);										
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
			}
		}
		
		// debug
		trace(keyboardState);

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
	
	public static var gamepadButtonName(default, never) = EnumMacros.nameByValue(GamepadButton);
	public static var gamepadButtonValue(default, never) = EnumMacros.valueByName(GamepadButton);
			
	// TODO:
	//var gamepadStates = new Map<Gamepad,InputState>
	//var gamepadPlayer = new IntMap<Gamepad>

	var gamepadStates:Vector<InputState> = new Vector<InputState>(8); // TODO maxPlayer
	public var gamepadPlayer:Vector<Int> = new Vector<Int>(8); // what player have what gamepad.id
	
	
	public function setGamePad(player:Int, gamepad:Gamepad, actionConfig:ActionConfig) {
		
		// TODO:
		gamepadPlayer.set(player, gamepad.id);

		// TODO: if no actionConfig do not create new inputstate if there is some for this gamepad already
		var gamepadState = gamepadStates.get(player);
		if (gamepadState == null) {
			gamepadState = new InputState(GamepadButton.DPAD_RIGHT + 1);
			gamepadStates.set(player, gamepadState);
		}
		
		var actionMapItem:ActionMapItem;			
		var key:Int;
		var modkey:Int;

		// TODO: this in separate function for keyboard, gamepad or joystick
		for (actionConfigItem in actionConfig)
		{
			if (actionConfigItem.gamepad != null && actionConfigItem.gamepad.length != 0) 
			{
				actionMapItem = actionMap.get(actionConfigItem.action);
				if (actionMapItem.action != null)
				{
					var actionState = getOrCreateActionState(actionMapItem, actionConfigItem, player);					
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
		

	}
	
	public function removeGamePad(player:Int) {
		
	}
	
	public function swapGamePad(player:Int) {
		
	}
	
	public function disableGamePad(player:Int) {
		
	}
	
	public function enableGamePad(player:Int) {
		
	}
	
	inline function gamepadConnect (gamepad:Gamepad):Void
	{		
		trace ("Gamepad connected: " + gamepad.id + ", " + gamepad.guid + ", " + gamepad.name);		
		gamepad.onDisconnect.add(gamepadDisconnect.bind(gamepad));
		
		// TODO: let easy bind the player and gamepadState[player] of new connected devices
		// TODO: check free SLOTS for player and lastUsedDevice(UUID) <-> player for old assignements
		var player = gamepadPlayer.get(gamepad.id);
		
		
		gamepad.onButtonDown.add(gamepadButtonDown.bind( gamepadStates.get(player) ));
		gamepad.onButtonUp.add(gamepadButtonUp.bind( gamepadStates.get(player) ));
		
		gamepad.onAxisMove.add(gamepadAxisMove.bind(gamepad));
		
		// TODO: call onGamepadConnect custom handler!
	}
		
	inline function gamepadDisconnect (gamepad:Gamepad):Void 
	{		
		trace ("Gamepad disconnected: " + gamepad.id + ", " + gamepad.guid + ", "+ gamepad.name);	
		gamepad.onDisconnect.remove(gamepadDisconnect.bind(gamepad));
		
		var player = gamepadPlayer.get(gamepad.id);
		
		gamepad.onButtonDown.remove(gamepadButtonDown.bind( gamepadStates.get(player) ));
		gamepad.onButtonUp.remove(gamepadButtonUp.bind( gamepadStates.get(player) ));
		
		gamepad.onAxisMove.remove(gamepadAxisMove.bind(gamepad));
		gamepad = null;
	}
	
	inline function gamepadButtonDown(gamepadState:InputState, button:GamepadButton):Void
	{
		#if neko // TODO: check later into lime > 7.9.0
		gamepadState.callDownActions( Std.int(button) );
		#else
		gamepadState.callDownActions( button );
		#end
	}
	
	inline function gamepadButtonUp(gamepadState:InputState, button:GamepadButton):Void
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