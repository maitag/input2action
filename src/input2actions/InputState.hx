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
	public inline function addDownAction(action:ActionFunction, key:Int, modKey:Int = null) {
		var inputAction = this.get(key);
		if (inputAction == null) {
			inputAction = new InputAction();
			this.set(key, inputAction);
		}
		
		if (modKey == null) {
			if (inputAction.singleActionDown != null) throw('Error, the single action to key $key is already defined');
			inputAction.singleActionDown = action;
		}
		else {
			if (inputAction.modifierActionDown == null) inputAction.modifierActionDown = new Array<ModifierAction>();
			else for (ma in inputAction.modifierActionDown) if (ma.keyCode == modKey) throw('Error, the action to key $key and modkey $modKey is already defined');
			
			if (this.get(modKey) == null) this.set(modKey, new InputAction());// TODO
			
			inputAction.modifierActionDown.push(new ModifierAction(modKey, action));
		}
	}
	
	public inline function addUpAction(action:ActionFunction, key:Int, modKey:Int = null) {
		var inputAction = this.get(key);
		if (inputAction == null) {
			inputAction = new InputAction();
			this.set(key, inputAction);
		}
		
		if (modKey == null) {
			if (inputAction.singleActionUp != null) throw('Error, the single action to key $key is already defined');
			inputAction.singleActionUp = action;
		}
		else {
			if (inputAction.modifierActionUp == null) inputAction.modifierActionUp = new Array<ModifierAction>();
			else for (ma in inputAction.modifierActionUp) if (ma.keyCode == modKey) throw('Error, the action to key $key and modkey $modKey is already defined');
			
			if (this.get(modKey) == null) this.set(modKey, new InputAction());// TODO
			
			inputAction.modifierActionUp.push(new ModifierAction(modKey, action));			
		}
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
			
			//TODO: switch here between ONLY single-action and MULTI-KEY-ACTIONS (where the single is inside the list ordererd by priority)
			if (inputAction.singleActionDown != null) inputAction.singleActionDown(InputType.KEYBOARD, ActionState.DOWN);
			
			if (inputAction.modifierActionDown != null) {
				for (modifierAction in inputAction.modifierActionDown) {
					if (isDown(modifierAction.keyCode)) {
						modifierAction.action(InputType.KEYBOARD, ActionState.DOWN);
					}
				}
			}
			
		}
	}
		
	public function callUpActions(key:Int) {
		var inputAction = this.get(key);
		if (inputAction != null && inputAction.isDown) {
			inputAction.isDown = false;
			
			//TODO: switch here between ONLY single-action and MULTI-KEY-ACTIONS (where the single is inside the list ordererd by priority)
			if (inputAction.singleActionUp != null) inputAction.singleActionUp(InputType.KEYBOARD, ActionState.UP);
			
			if (inputAction.modifierActionUp != null) {
				for (modifierAction in inputAction.modifierActionUp) {
					if (isDown(modifierAction.keyCode)) modifierAction.action(InputType.KEYBOARD, ActionState.UP);
				}
			}
			
		}
	}
	
	@:to
	public function toString():String return toStringWithAction();

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

		
		for (i in 0...this.length) {
			var inputAction = this.get(i);
			if (inputAction != null) {
				out += '\n\n';
				out += Input2Actions.keyCodeName.get(Input2Actions.toKeyCode(i));
				out += (inputAction.isDown) ? " (isDown)" : " (isUp)";
				
				if (inputAction.singleActionDown != null) out += ', down -> ' + actionName(inputAction.singleActionDown);
				
				if (inputAction.singleActionUp != null) out += ', up -> ' + actionName(inputAction.singleActionUp);
				
				if (inputAction.modifierActionDown != null)
					for (modifierAction in inputAction.modifierActionDown)
						out += '\n   '
						+ Input2Actions.keyCodeName.get(Input2Actions.toKeyCode(modifierAction.keyCode))
						+ ' down -> ' + actionName(modifierAction.action);
						
				if (inputAction.modifierActionUp != null)
					for (modifierAction in inputAction.modifierActionUp)
						out += '\n   '
						+ Input2Actions.keyCodeName.get(Input2Actions.toKeyCode(modifierAction.keyCode))
						+ ' up -> ' + actionName(modifierAction.action);
			}
		}

		return out + "\n";
	}
	
	
}





private class InputAction {
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
	
	//TODO:
	//public var isDown:Bool = false;
	
	public var keyCode:Int;
	public var action:ActionFunction;
	public function new(keyCode:Int, action:ActionFunction) {
		this.keyCode = keyCode;
		this.action = action;	
	}
}
