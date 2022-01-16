package input2actions;

import haxe.ds.Vector;
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
			
			if (inputAction.singleActionUp != null) inputAction.singleActionUp(InputType.KEYBOARD, ActionState.UP);
			
			if (inputAction.modifierActionUp != null) {
				for (modifierAction in inputAction.modifierActionUp) {
					if (isDown(modifierAction.keyCode)) modifierAction.action(InputType.KEYBOARD, ActionState.UP);
				}
			}
			
		}
	}
	
	@:to
	public function toString():String {
		var out = "";
		for (i in 0...this.length) {
			var inputAction = this.get(i);
			if (inputAction != null) {
				out += '\n\n$i : ${(inputAction.isDown) ? "isDown" : "isUp"}';
				
				if (inputAction.singleActionDown != null) out += ', down->' + inputAction.singleActionDown;
				if (inputAction.singleActionUp != null) out += ', up->' + inputAction.singleActionUp;
				
				if (inputAction.modifierActionDown != null)
					for (modifierAction in inputAction.modifierActionDown)
						out += '\n  ' + modifierAction.keyCode + '->' + modifierAction.action;
				if (inputAction.modifierActionUp != null)
					for (modifierAction in inputAction.modifierActionUp)
						out += '\n  ' + modifierAction.keyCode + '->' + modifierAction.action;
			}
		}

		return out;
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
	public var keyCode:Int;
	public var action:ActionFunction;
	public function new(keyCode:Int, action:ActionFunction) {
		this.keyCode = keyCode;
		this.action = action;	
	}
}
