package input2action;

import haxe.ds.StringMap;

import lime.ui.KeyCode;
//import lime.ui.KeyModifier;

import input2action.ActionConfig;
import input2action.ActionMap;
import input2action.ErrorMsg;
import input2action.InputState;

import input2action.util.EnumMacros;
import input2action.InputState.ActionState;

/**
 * by Sylvio Sell - Rostock 2022
*/

@:access(input2action.InputState)
class KeyboardAction
{
	var inputState:InputState;

	public var param:Int = 0;

	public static var keyCodeName(default, never):Map<KeyCode, String> = EnumMacros.nameByValue(KeyCode);
	public static var keyCodeValue(default, never):Map<String, KeyCode> = EnumMacros.valueByName(KeyCode);	
	
	static inline var UNUSED_KEYCODE_START:Int = KeyCode.DELETE - 0 + 1; // don't know why need -0 to work with --no-inline
	//static inline var UNUSED_KEYCODE_START:Int = 0x80;
	static inline var UNUSED_KEYCODE_END:Int = KeyCode.CAPS_LOCK; // 0x40000039;
	//static inline var MAX_USABLE_KEYCODES:Int = fromKeyCode(KeyCode.SLEEP) + 1;
	static inline var MAX_USABLE_KEYCODES:Int = KeyCode.SLEEP - UNUSED_KEYCODE_END + UNUSED_KEYCODE_START + 1; //0x162

	// removes all unused keys between KeyCode.DELETE and KeyCode.CAPS_LOCK
	static public inline function fromKeyCode(k:KeyCode):Int {
		return (k < UNUSED_KEYCODE_END) ? k : k - UNUSED_KEYCODE_END + UNUSED_KEYCODE_START;
	}
	
	// extract back to full KeyCode range
	static public inline function toKeyCode(k:Int):KeyCode {
		return (k < UNUSED_KEYCODE_START) ? k : k + UNUSED_KEYCODE_END - UNUSED_KEYCODE_START;
	}
	

	// -----------------------------------------------------
		
	public function new(param:Int = 0, actionConfig:ActionConfig, actionMap:ActionMap ) 
	{
		this.param = param;

		inputState = new InputState(MAX_USABLE_KEYCODES);
		// Todo: minimize inputState vector
		// var minKeyRangeL = 0x7fffffff;
		// var maxKeyRangeL = 0;

		var actionStateMap = new StringMap<ActionState>();	
		var actionMapItem:ActionMapItem;			
		var key:Int=0;
		var modkey:Int=0;
		
		for (actionConfigItem in actionConfig)
		{	
			if (actionConfigItem.keyboard != null && actionConfigItem.keyboard.length != 0) 
			{	
				actionMapItem = actionMap.get(actionConfigItem.action);				
				if (actionMapItem != null)
				{
					// get or create new actionState
					var actionState = actionStateMap.get(actionConfigItem.action);
					if (actionState == null)
					{
						actionState = new ActionState(
							actionMapItem.up, actionMapItem.each,
							#if !input2action_noRepeat
							actionMapItem.repeatKeyboardDefault, actionMapItem.repeatDelay, actionMapItem.repeatRate,
							#end
							actionConfigItem.single, actionMapItem.action
							#if input2action_debug
							,actionConfigItem.action
							#end
						);
						actionStateMap.set(actionConfigItem.action, actionState);
					}
					
					// add actionState to inputState for the keys
					for (keys in actionConfigItem.keyboard)
					{
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
						
						inputState.addAction(actionState, key, modkey);						
					}
				}				
			}
		}
		
		// debug
		// trace(inputState);
	}
	
	
	// -----------------------------------------------------
		

	public inline function keyDown(key:KeyCode):Void
	{
		//trace("keyDown:",StringTools.hex(fromKeyCode(Std.int(key))));

		// case KeyCode.TAB: untyped __js__('event.preventDefault();');
		
		#if neko // TODO: check later into lime > 7.9.0
		inputState.callDownActions( fromKeyCode(Std.int(key)), param, true );
		#else
		inputState.callDownActions( fromKeyCode(key), param, true );
		#end
	}
	
	public inline function keyUp(key:KeyCode):Void
	{
		#if neko // TODO: check later into lime > 7.9.0	
		inputState.callUpActions( fromKeyCode(Std.int(key)), param, true );
		#else
		inputState.callUpActions( fromKeyCode(key), param, true );
		#end
	}
	
	

	
	

}