package input2actions;

import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.ds.Vector;
import haxe.ds.WeakMap;
import input2actions.ActionFunction;
import input2actions.ActionMap;
import input2actions.Input2Actions;

/**
 * by Sylvio Sell - Rostock 2019
*/

abstract InputState(Vector<InputAction>) from Vector<InputAction> to Vector<InputAction>
{
	
	inline public function new(size:Int) {
		this = new Vector<InputAction>(size);
		//for (i in 0...size) this.set(i, null);
	}


	// TODO: up and down into one function
	public inline function addAction(actionState:ActionState, key:Int, modKey:Int = 0) {
		var inputAction = this.get(key);
		if (inputAction == null) {
			inputAction = new InputAction();
			this.set(key, inputAction);
		}
		
		#if input2actions_singlekey
			if (inputAction.singleKeyDown != null) throw('Error, the single action to key $key is already defined');
			inputAction.singleKeyDown = action;
		#else
			if (inputAction.multiKeyAction == null) inputAction.multiKeyAction = new Array<MultiKeyAction>();
			else for (ma in inputAction.multiKeyAction) if (ma.keyCode == modKey) throw('Error, the action to key $key and modkey $modKey is already defined');
			
			if (modKey > 0 && this.get(modKey) == null) this.set(modKey, new InputAction());// TODO
			
			inputAction.multiKeyAction.push(new MultiKeyAction(modKey, actionState));
		#end
	}

	
	
	
	public inline function isDown(key:Int):Bool {
		var inputAction = this.get(key);
		if (inputAction == null) return false;
		else return inputAction.isDown;
	}
	
		
	public inline function callDownActions(key:Int) {
		var inputAction = this.get(key);
		if (inputAction != null && !inputAction.isDown) {
			inputAction.isDown = true;
			
			#if input2actions_singlekey
			if (inputAction.singleKeyDown != null) inputAction.singleKeyDown(InputType.KEYBOARD, ActionType.DOWN); //TODO
			#else
			if (inputAction.multiKeyAction != null) 
			{
				var called = false;
				for (multiKeyAction in inputAction.multiKeyAction) 
				{
					if (multiKeyAction.keyCode == 0 || isDown(multiKeyAction.keyCode))
					{
						var actionState:ActionState = multiKeyAction.actionState;
						
						if (!actionState.single || !called) 
						{					
							switch (actionState.down) {
								case ANY  :
									actionState.action(InputType.KEYBOARD, ActionType.DOWN);
									called = true;
									actionState.pressed++;
								case ONES :
									if (actionState.pressed == 0) {
										actionState.action(InputType.KEYBOARD, ActionType.DOWN);
										called = true;
									}
									actionState.pressed++;
								default:
							}							
							if (actionState.single) break;
						}
					}
				}
			} 
			#end
		}
	}
		
	public function callUpActions(key:Int) {
		var inputAction = this.get(key);
		if (inputAction != null && inputAction.isDown) {
			inputAction.isDown = false;
			
			#if input2actions_singlekey
			if (inputAction.singleKeyUp != null) inputAction.singleKeyUp(InputType.KEYBOARD, ActionType.UP); //TODO
			#else
			if (inputAction.multiKeyAction != null)
			{
				var called = false;
				for (multiKeyAction in inputAction.multiKeyAction)
				{
					var actionState:ActionState = multiKeyAction.actionState;
					if (actionState.pressed > 0 )
					{					
						if (!actionState.single || !called) 
						{					
							switch (actionState.up) {
								case ANY  :
									actionState.pressed--;
									actionState.action(InputType.KEYBOARD, ActionType.UP);
									called = true;
								case ONES :
									actionState.pressed--;
									if (actionState.pressed == 0) {
										actionState.action(InputType.KEYBOARD, ActionType.UP); called = true;
									}
								default:
							}						
							if (actionState.single) break;
						}
					}

				}
			}
			#end
		}
	}
	
	
	@:to public function toString():String return toStringWithAction();
	
	public function debug(actionMap:ActionMap) trace(toStringWithAction(actionMap));	
	
	function toStringWithAction(actionMap:ActionMap = null):String 
	{
		var actionNames:Array<String> = null;
		var actionValues:Array<ActionFunction> = null;
		if (actionMap != null) {
			actionNames = [];
			actionValues = [];
			for (name => action in actionMap) {
				actionNames.push(name);
				actionValues.push(action);
			}
		}
		
		var out = "";
		
		var actionName = function(action:ActionFunction):Dynamic {
			if (actionMap != null)
				return actionNames[actionValues.indexOf(action)];
			else return action;
		}

		var keyCodeName = function(key:Int):String {
			return Input2Actions.keyCodeName.get( Input2Actions.toKeyCode(key) );
		}

		
		for (i in 0...this.length) {
			var inputAction = this.get(i);
			if (inputAction != null) {
				out += '\n\n';
				out += Input2Actions.keyCodeName.get(Input2Actions.toKeyCode(i));
				out += (inputAction.isDown) ? " (isDown)" : " (isUp)";
				
				#if input2actions_singlekey
				if (inputAction.singleKeyDown != null) out += ', down -> ' + actionName(inputAction.singleKeyDown);
				if (inputAction.singleKeyUp != null) out += ', up -> ' + actionName(inputAction.singleKeyUp);
				#else
				if (inputAction.multiKeyAction != null)
					for (multiKeyAction in inputAction.multiKeyAction) {
						out += '\n   ';
						var actionState:ActionState = multiKeyAction.actionState;
						if (multiKeyAction.keyCode > 0) out += keyCodeName(multiKeyAction.keyCode) + ": ";
						out += '' + actionName(actionState.action);
						//out += 'down -> ' + actionState.name;
						out += (actionState.single) ? " (single)" : "";
					}
						
				#end
			}
		}

		return out + "\n";
	}
	
	
}


private class InputAction
{
	public var isDown:Bool = false;
	
	#if input2actions_singlekey
	
	public var deviceID:Int;
	public var singleKeyAction:ActionState = null;
	
	#else
	
	public var multiKeyAction:Array<MultiKeyAction> = null;
	
	#end
	
	public function new() {}
}


#if !input2actions_singlekey

private class MultiKeyAction 
{
	public var keyCode:Int;
	public var deviceID:Int;
	public var actionState:ActionState;
	
	public function new(keyCode:Int, actionState:ActionState, deviceID:Int=0) {
		this.keyCode = keyCode;
		this.actionState = actionState;	
		this.deviceID = deviceID;	
	}
}

#end


class ActionState {
	public var single:Bool;
	public var down:KeySetting;
	public var up:KeySetting;
	public var pressed:Int = 0;	
	public var action:ActionFunction = null;
	
	public var name:String; //TODO: only for debug!
	
	public function new(single:Bool, down:KeySetting, up:KeySetting, action:ActionFunction, name:String) {
		this.single = single;
		this.down = down;
		this.up = up;
		this.action = action;
		this.name = name;
	}

}

