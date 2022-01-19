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
	public inline function addDownAction(action:ActionFunction, key:Int, modKey:Int = 0) {
		var inputAction = this.get(key);
		if (inputAction == null) {
			inputAction = new InputAction();
			this.set(key, inputAction);
		}
		
		#if input2actions_singlekey
			if (inputAction.singleKeyDown != null) throw('Error, the single action to key $key is already defined');
			inputAction.singleKeyDown = action;
		#else
			if (inputAction.multiKeyDown == null) inputAction.multiKeyDown = new Array<MultiKeyAction>();
			else for (ma in inputAction.multiKeyDown) if (ma.keyCode == modKey) throw('Error, the action to key $key and modkey $modKey is already defined');
			
			if (modKey > 0 && this.get(modKey) == null) this.set(modKey, new InputAction());// TODO
			
			inputAction.multiKeyDown.push(new MultiKeyAction(modKey, action));
		#end
	}
	
	public inline function addUpAction(action:ActionFunction, key:Int, modKey:Int = 0) {
		var inputAction = this.get(key);
		if (inputAction == null) {
			inputAction = new InputAction();
			this.set(key, inputAction);
		}
		
		#if input2actions_singlekey
		if (inputAction.singleKeyUp != null) throw('Error, the single action to key $key is already defined');
		inputAction.singleKeyUp = action;
		#else
		if (inputAction.multiKeyUp == null) inputAction.multiKeyUp = new Array<MultiKeyAction>();
		else for (ma in inputAction.multiKeyUp) if (ma.keyCode == modKey) throw('Error, the action to key $key and modkey $modKey is already defined');
		
		if (modKey > 0 && this.get(modKey) == null) this.set(modKey, new InputAction());// TODO
		
		inputAction.multiKeyUp.push(new MultiKeyAction(modKey, action));			
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
			if (inputAction.singleKeyDown != null) inputAction.singleKeyDown(InputType.KEYBOARD, ActionState.DOWN);
			#else
			if (inputAction.multiKeyDown != null) {
				for (modifierAction in inputAction.multiKeyDown) {
					if (modifierAction.keyCode == 0 || isDown(modifierAction.keyCode)) {
						modifierAction.action(InputType.KEYBOARD, ActionState.DOWN);
						inputAction.downByModKey = modifierAction.keyCode; // TODO: in MultiKeyAction->isDown speichern
						break; // TODO: allow more then one
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
			if (inputAction.singleKeyUp != null) inputAction.singleKeyUp(InputType.KEYBOARD, ActionState.UP);
			#else
			if (inputAction.multiKeyUp != null) {
				for (modifierAction in inputAction.multiKeyUp) {
					//if (modifierAction.keyCode == 0 || isDown(modifierAction.keyCode)) {
					if (modifierAction.keyCode == inputAction.downByModKey) { // TODO: only if inside MultiKeyAction->isDown
						modifierAction.action(InputType.KEYBOARD, ActionState.UP);
						break; // TODO: allow more then one
					}
				}
			}
			#end
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
				if (inputAction.multiKeyDown != null)
					for (modifierAction in inputAction.multiKeyDown) {
						out += '\n   ';
						if (modifierAction.keyCode > 0) out += keyCodeName(modifierAction.keyCode) + ": ";
						out += 'down -> ' + actionName(modifierAction.action);
					}
						
				if (inputAction.multiKeyUp != null)
					for (modifierAction in inputAction.multiKeyUp) {
						out += '\n   ';
						if (modifierAction.keyCode > 0) out += keyCodeName(modifierAction.keyCode) + ": ";
						out += 'up -> ' + actionName(modifierAction.action);
					}
				#end
			}
		}

		return out + "\n";
	}
	
	
}





private class InputAction {
	public var isDown:Bool = false;
	
	#if input2actions_singlekey
	
	public var singleKeyDown:ActionFunction = null;
	public var singleKeyUp:ActionFunction = null;
	//public var singleKeyRepeat:ActionFunction = null;
	
	#else
	public var downByModKey:Int = 0;
	
	public var multiKeyDown:Array<MultiKeyAction> = null;
	public var multiKeyUp:Array<MultiKeyAction> = null;
	//public var multiKeyRepeat:Array<ModifierAction> = null;
	
	#end
	
	public function new() {
	}
}



#if !input2actions_singlekey
private class MultiKeyAction {
	
	//TODO:
	//public var isDown:Bool = false;
	
	public var keyCode:Int;
	public var action:ActionFunction;
	public function new(keyCode:Int, action:ActionFunction) {
		this.keyCode = keyCode;
		this.action = action;	
	}
}
#end