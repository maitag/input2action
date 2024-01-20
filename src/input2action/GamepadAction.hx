package input2action;

import haxe.ds.StringMap;

import lime.ui.GamepadButton;

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
class GamepadAction
{
	var inputState:InputState;

	public var param:Int = 0;
	
	public static var gamepadButtonName(default, never):Map<GamepadButton, String> = EnumMacros.nameByValue(GamepadButton);
	public static var gamepadButtonValue(default, never):Map<String, GamepadButton> = EnumMacros.valueByName(GamepadButton);
		
	// -----------------------------------------------------
		
	public function new(param:Int = 0, actionConfig:ActionConfig, actionMap:ActionMap ) 
	{
		this.param = param;

		inputState = new InputState(GamepadButton.DPAD_RIGHT + 1);

		var actionStateMap = new StringMap<ActionState>();	
		var actionMapItem:ActionMapItem;			
		var key:Int=0;
		var modkey:Int=0;
		
		for (actionConfigItem in actionConfig)
		{	
			if (actionConfigItem.gamepad != null && actionConfigItem.gamepad.length != 0) 
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
					for (keys in actionConfigItem.gamepad) 
					{
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
						
						inputState.addAction(actionState, key, modkey);						
					}
				}				
			}
		}
		
		// debug
		// trace(inputState);
	}
	
	
	// -----------------------------------------------------
		
	public inline function buttonDown(button:GamepadButton):Void
	{
		#if neko // TODO: check later into lime > 7.9.0
		inputState.callDownActions( Std.int(button), param, false );
		#else
		inputState.callDownActions( button, param, false );
		#end
	}
		
	public inline function buttonUp(button:GamepadButton):Void
	{
		#if neko // TODO: check later into lime > 7.9.0	
		inputState.callUpActions( Std.int(button), param, false );
		#else
		inputState.callUpActions( button, param, false );
		#end
	}

}