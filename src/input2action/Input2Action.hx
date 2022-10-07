package input2action;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.ds.Vector;
import input2action.ActionConfig;
import input2action.ActionMap;
import input2action.ErrorMsg;
import input2action.InputState;
import lime.ui.Gamepad;
import lime.ui.GamepadAxis;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
//import lime.ui.KeyModifier;
import lime.ui.Window;

//import json2object.JsonParser;
//import json2object.JsonWriter;


import input2action.util.EnumMacros;
import input2action.InputState.ActionState;

/**
 * by Sylvio Sell - Rostock 2022
*/


class Input2Action 
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
			actionState = new ActionState(actionMapItem.up, actionMapItem.each, actionConfigItem.single, actionMapItem.action, player #if input2action_debug ,actionConfigItem.action #end);
			actionStatePlayer.set(actionConfigItem.action, actionState);
		}
		return actionState;			
	}
	
	
	// -----------------------------------------------------
	// ---------------- Keyboard -----------------------------
	// -----------------------------------------------------
	
	public static var keyCodeName(default, never):Map<KeyCode, String> = EnumMacros.nameByValue(KeyCode);
	public static var keyCodeValue(default, never):Map<String, KeyCode> = EnumMacros.valueByName(KeyCode);	
	
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
	
	// TODO: keyboardPlayer:Int
	
	public function setKeyboard(player:Int = 0, actionConfig:ActionConfig = null) {
		
		if (actionConfig == null) actionConfig = actionConfigDefault;
		
		// TODO: check maxPlayer
		// TODO: set keyboardPlayer bit
		
		var actionMapItem:ActionMapItem;			
		var key:Int;
		var modkey:Int;
		
		if (keyboardState==null) keyboardState = new InputState(MAX_USABLE_KEYCODES);

		for (actionConfigItem in actionConfig)
		{	
			if (actionConfigItem.keyboard != null && actionConfigItem.keyboard.length != 0) 
			{	
				actionMapItem = actionMap.get(actionConfigItem.action);				
				if (actionMapItem != null && actionMapItem.action != null)
				{	
					var actionState = getOrCreateActionState(actionMapItem, actionConfigItem, player);										
					
					for (keys in actionConfigItem.keyboard) {
						switch (keys.length)
						{
							case 1:	key = fromKeyCode(keys[0]); modkey = -1;
							case 2:	
								#if input2action_noKeyCombos
								ErrorMsg.keyCombosNeedToEnable(actionState);
								#else
								key = fromKeyCode(keys[1]); modkey = fromKeyCode(keys[0]);
								#end
							default: ErrorMsg.onlyOneModKeyAllowed(actionState);
						}
						
						keyboardState.addAction(actionState, key, modkey);						
					}
				}				
			}
		}
		
		// debug
		// trace(keyboardState);

	}
	
	// TODO:
	public function removeKeyboard(player:Int) {
		
	}
	public function enableKeyboard(player:Int) {
		
	}
	public function disableKeyboard(player:Int) {
		
	}
	
	inline function keyDown(key:KeyCode, _):Void
	{
		//trace("keyDown:",StringTools.hex(fromKeyCode(Std.int(key))));

		// case KeyCode.TAB: untyped __js__('event.preventDefault();');
		
		#if neko // TODO: check later into lime > 7.9.0
		keyboardState.callDownActions( fromKeyCode(Std.int(key)), true );
		#else
		keyboardState.callDownActions( fromKeyCode(key), true );
		#end
	}
	
	inline function keyUp(key:KeyCode, _):Void
	{
		#if neko // TODO: check later into lime > 7.9.0	
		keyboardState.callUpActions( fromKeyCode(Std.int(key)), true );
		#else
		keyboardState.callUpActions( fromKeyCode(key), true );
		#end
	}
	
	
	
	// -----------------------------------------------------
	// ---------------- Gamepad -----------------------------
	// -----------------------------------------------------
	
	public static var gamepadButtonName(default, never):Map<GamepadButton, String> = EnumMacros.nameByValue(GamepadButton);
	public static var gamepadButtonValue(default, never):Map<String, GamepadButton> = EnumMacros.valueByName(GamepadButton);
	
	// TODO:
	var gamepadPlayer = new IntMap<Gamepad>(); // TODO: Vector<Gamepad> and init with maxPlayer value
	var gamepadStates = new Map<Gamepad,InputState>();
	
	public function setGamepad(player:Int = 0, gamepad:Gamepad, actionConfig:ActionConfig = null)
	{		
		if (actionConfig == null) actionConfig = actionConfigDefault;
		
		// TODO:
		gamepadPlayer.set(player, gamepad);

		// TODO: if no actionConfig do not create new inputstate if there is some for this gamepad already
		var gamepadState = gamepadStates.get(gamepad);
		if (gamepadState == null) {
			gamepadState = new InputState(GamepadButton.DPAD_RIGHT + 1);
			gamepadStates.set(gamepad, gamepadState);
		}
		
		var actionMapItem:ActionMapItem;			
		var key:Int;
		var modkey:Int;

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
							case 1:	key = keys[0]; modkey = -1;
							case 2:	
								#if input2action_noKeyCombos
								ErrorMsg.keyCombosNeedToEnable(actionState);
								#else
								key = keys[1]; modkey = keys[0];
								#end
							default: ErrorMsg.onlyOneModKeyAllowed(actionState);
						}
						gamepadState.addAction(actionState, key, modkey);						
					}
				}				
			}
		}
		// debug
		// trace(gamepadState);

		enableGamepad(player);
	}
	
	public function removeGamepad(player:Int, gamepad:Gamepad = null) {
		
		// TODO: one player -> many gamepads
		// TODO: if 2 players sharing 1 gamepad, only remove that specific player from inputstate!
		//var gamepad = gamepadPlayer.get(player);
		
		if (gamepad == null) {
			gamepad = gamepadPlayer.get(player);
			if (gamepad != null) gamepadPlayer.remove(player);
		}
		
		if (gamepad != null) {
			var gamepadState = gamepadStates.get(gamepad);
			if (gamepadState != null) {
				gamepadStates.remove(gamepad);
				gamepad.onDisconnect.remove(gamepadDisconnect.bind(gamepad, player));
				gamepad.onButtonDown.remove(gamepadButtonDown.bind(gamepadState));
				gamepad.onButtonUp.remove(gamepadButtonUp.bind(gamepadState));
				gamepad.onAxisMove.remove(gamepadAxisMove.bind(gamepadState));
			}
		}
	}
	
	public function swapGamepad(player:Int) {
		
	}
	
	public function enableGamepad(player:Int) {
		var gamepad = gamepadPlayer.get(player);
		var gamepadState = gamepadStates.get(gamepad);
		if (gamepad != null) {
			gamepad.onDisconnect.add(gamepadDisconnect.bind(gamepad, player));
			gamepad.onButtonDown.add(gamepadButtonDown.bind(gamepadState));
			gamepad.onButtonUp.add(gamepadButtonUp.bind(gamepadState));			
			gamepad.onAxisMove.add(gamepadAxisMove.bind(gamepadState));
			
		
		}
	}
	
	public function disableGamepad(player:Int) {
		var gamepad = gamepadPlayer.get(player);
		var gamepadState = gamepadStates.get(gamepad);
		if (gamepad != null) {
			gamepad.onDisconnect.remove(gamepadDisconnect.bind(gamepad, player));
			gamepad.onButtonDown.remove(gamepadButtonDown.bind(gamepadState));
			gamepad.onButtonUp.remove(gamepadButtonUp.bind(gamepadState));
			gamepad.onAxisMove.remove(gamepadAxisMove.bind(gamepadState));
		}
	}
	
	
	public var onGamepadConnect:Gamepad->Void = null;
	inline function gamepadConnect (gamepad:Gamepad):Void
	{		
		trace ("Gamepad connected: " + gamepad.id + ", " + gamepad.guid + ", " + gamepad.name);		
		if (onGamepadConnect != null) onGamepadConnect(gamepad);
	}
	
	public var onGamepadDisconnect:Int->Void = null;
	inline function gamepadDisconnect (gamepad:Gamepad, player:Int):Void 
	{		
		trace ("Gamepad disconnected: " + gamepad.id + ", " + gamepad.guid + ", " + gamepad.name);			
		removeGamepad(player, gamepad);
		if (onGamepadDisconnect != null) onGamepadDisconnect(player);
	}
	
	inline function gamepadButtonDown(gamepadState:InputState, button:GamepadButton):Void
	{
		#if neko // TODO: check later into lime > 7.9.0
		gamepadState.callDownActions( Std.int(button), false );
		#else
		gamepadState.callDownActions( button, false );
		#end
	}
	
	inline function gamepadButtonUp(gamepadState:InputState, button:GamepadButton):Void
	{
		#if neko // TODO: check later into lime > 7.9.0	
		gamepadState.callUpActions( Std.int(button), false );
		#else
		gamepadState.callUpActions( button, false );
		#end
	}

	inline function gamepadAxisMove(gamepadState:InputState, axis:GamepadAxis, value:Float):Void
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
	
	
	// TODO: remove all keyboard and gamepad events for this player only
	public function removePlayer(player:Int=0) {
		
	}
	
	

	
	
	
	

	
	

}