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

abstract InputState(Vector<KeyState>) from Vector<KeyState> to Vector<KeyState>
{
	
	inline public function new(size:Int) {
		this = new Vector<KeyState>(size);
		//for (i in 0...size) this.set(i, null);
	}


	// TODO: up and down into one function
	public inline function addAction(actionState:ActionState, key:Int, modKey:Int = 0) {
		var keyState = this.get(key);
		if (keyState == null) {
			keyState = new KeyState();
			this.set(key, keyState);
		}
		
		#if input2actions_noKeyCombos
			if (keyState.singleKeyAction != null) throw('Error, the single action to key $key is already defined');
			keyState.singleKeyAction = actionState;
		#else
			if (keyState.keyCombo == null) keyState.keyCombo = new Array<KeyCombo>();
			else for (ma in keyState.keyCombo) if (ma.keyCode == modKey) throw('Error, the action to key $key and modkey $modKey is already defined');
			
			if (modKey > 0 && this.get(modKey) == null) this.set(modKey, new KeyState());// TODO
			
			keyState.keyCombo.push(new KeyCombo(modKey, actionState));
		#end
	}

	
	
	
	public static var step:Int = 0;
	
	public inline function isDown(key:Int):Bool {
		var keyState = this.get(key);
		if (keyState == null) return false;
		else return keyState.isDown;
	}
			
	public inline function callDownActions(key:Int) {
		var keyState = this.get(key);
		if (keyState != null && !keyState.isDown) {
			keyState.isDown = true;
			
			#if input2actions_noKeyCombos
			if (keyState.singleKeyAction != null) {
				var actionState:ActionState = keyState.singleKeyAction;
				if (actionState.each) actionState.callDownAction();
				else {
					actionState.pressed++;
					if (actionState.pressed == 1) actionState.callDownAction();
				}
			}
			#else
			if (keyState.keyCombo != null) 
			{
				var called = false;
				var actionState:ActionState;
				
				for (keyCombo in keyState.keyCombo) 
				{
					if (keyCombo.keyCode == 0 || isDown(keyCombo.keyCode))
					{
						actionState = keyCombo.actionState;
						
						if (!actionState.single || !called)
						{					
							called = true;
							keyCombo.downBy = true;
						
							if (actionState.each) actionState.callDownAction();
							else {
								actionState.pressed++;
								if (actionState.pressed == 1) actionState.callDownAction();
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
		var keyState = this.get(key);
		if (keyState != null && keyState.isDown) {
			keyState.isDown = false;
			
			#if input2actions_noKeyCombos
			if (keyState.singleKeyAction != null) {
				var actionState:ActionState = keyState.singleKeyAction;
				if (actionState.each) {
					if (actionState.up) actionState.callUpAction();
				}
				else {
					actionState.pressed--;
					if (actionState.up && actionState.pressed == 0) actionState.callUpAction();							
				}						
			}
			#else
			if (keyState.keyCombo != null)
			{
				var actionState:ActionState;
				for (keyCombo in keyState.keyCombo)
				{
					if (keyCombo.downBy)
					{
						keyCombo.downBy = false;
						
						actionState = keyCombo.actionState; //trace("UP", actionState.name, actionState.pressed);
						
						if (actionState.each) {
							if (actionState.up) actionState.callUpAction();
						}
						else {
							actionState.pressed--;
							if (actionState.up && actionState.pressed == 0) actionState.callUpAction();							
						}						
					}
				}
			}
			#end
		}
	}
	
	
	@:to public function toString():String 
	{
		var out = "";
		
		var actionName = function(actionState:ActionState):String {
			#if input2actions_debug
			return actionState.name;
			#else
			return Std.string(actionState.action);
			#end
		}

		var keyCodeName = function(key:Int):String {
			return Input2Actions.keyCodeName.get( Input2Actions.toKeyCode(key) );
		}
		
		for (i in 0...this.length) {
			var keyState = this.get(i);
			if (keyState != null) {
				out += '\n\n';
				out += Input2Actions.keyCodeName.get(Input2Actions.toKeyCode(i));
				out += (keyState.isDown) ? " (isDown)" : " (isUp)";
				
				#if input2actions_noKeyCombos
				if (keyState.singleKeyAction != null) out += ' -> ' + actionName(keyState.singleKeyAction);
				#else
				if (keyState.keyCombo != null)
					for (keyCombo in keyState.keyCombo) {
						out += '\n   ';
						var actionState:ActionState = keyCombo.actionState;
						if (keyCombo.keyCode > 0) out += keyCodeName(keyCombo.keyCode) + ": ";
						out += '' +  actionName(actionState);
						out += (actionState.single) ? " (single)" : "";
					}						
				#end
			}
		}

		return out + "\n";
	}
	
}


private class KeyState
{
	public var isDown:Bool = false;
	
	#if input2actions_noKeyCombos
	
	public var deviceID:Int;
	public var singleKeyAction:ActionState = null;
	
	#else
	
	public var keyCombo:Array<KeyCombo> = null;
	
	#end
	
	public function new() {}
}


#if !input2actions_noKeyCombos

private class KeyCombo 
{
	public var downBy:Bool = false;
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
	public var up:Bool;
	public var each:Bool;
	public var single:Bool;
	
	public var pressed:Int = 0;
	public var action:ActionFunction = null;
	
	public var player:Int; // two player can share one keyboard
	
	#if input2actions_debug
	public var name:String; //TODO: only for debug!
	#end
	
	public inline function callDownAction() action(true, player);
	public inline function callUpAction() action(false, player);
	
	public inline function new(up:Bool, each:Bool, single:Bool, action:ActionFunction, player:Int #if input2actions_debug , name:String #end) {
		this.up = up;
		this.each = each;
		this.single = single;
		this.action = action;
		this.player = player;
		#if input2actions_debug 
		this.name = name;
		#end
	}

}

