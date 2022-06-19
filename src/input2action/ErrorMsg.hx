package input2action;

import input2action.InputState.ActionState;

/**
 * collect all error messages
 * 
 * by Sylvio Sell, Rostock 2022
 */

class ErrorMsg
{
	static inline function error(msg:String) {
		#if (haxe_ver >= "4.1.0")
			throw new haxe.Exception(msg);
		#else
			throw(msg);
		#end
	}
		
	
	// --------------- Input2Action ----------------
	
	public static inline function keyCombosNeedToEnable(actionState:ActionState) {
		#if input2action_debug
		error('To use key-combinations for "${actionState.name}"-action it need to disable the compiler define "input2action_noKeyCombos".');
		#else
		error('To use key-combinations it need to disable the compiler define "input2action_noKeyCombos".');
		#end
	}
	
	public static inline function onlyOneModKeyAllowed(actionState:ActionState) {
		#if input2action_debug
		error('Only one modifier per key-combination is allowed for "${actionState.name}"-action.');
		#else
		error('Only one modifier per key-combination is allowed for.');
		#end
	}
	

	
		
	// --------------- InputState ---------------
	
	public static inline function alreadyDefinedKey(modKeyCodeName:String, actionState:ActionState, actionStateAlready:ActionState) {
		#if input2action_debug
		error('$modKeyCodeName of "${actionState.name}"-action is already defined for "${actionStateAlready.name}"-action');
		#else
		error('$modKeyCodeName is already defined for an action');
		#end
	}

	
	
}