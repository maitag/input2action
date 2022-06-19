package input2action;

import haxe.ds.Vector;
import input2action.ActionFunction;
import input2action.Input2Action;

/**
 * by Sylvio Sell - Rostock 2022
*/

@:access(input2action.Input2Action)
abstract InputState(Vector<KeyState>) from Vector<KeyState> to Vector<KeyState>
{
	
	inline public function new(size:Int) {
		this = new Vector<KeyState>(size);
		//for (i in 0...size) this.set(i, null);
	}


	public inline function addAction(actionState:ActionState, key:Int, modKey:Int = -1) {
		var keyState = this.get(key);
		if (keyState == null) {
			keyState = new KeyState();
			this.set(key, keyState);
		}
		
		#if input2action_noKeyCombos
			if (keyState.singleKeyAction != null) ErrorMsg.alreadyDefinedKey(keyCodeName(key), actionState, keyState.singleKeyAction);
			keyState.singleKeyAction = actionState;
		#else
			if (keyState.keyCombo == null)
				keyState.keyCombo = new Array<KeyCombo>();
			else {
				for (ma in keyState.keyCombo)
					if (ma.keyCode == modKey)
						ErrorMsg.alreadyDefinedKey( (modKey > -1) ? '${keyCodeName(modKey)} + ${keyCodeName(key)}' : keyCodeName(key), actionState, ma.actionState);
			}
			
			// create empty keystate for the modkey
			if (modKey > -1 && this.get(modKey) == null) this.set(modKey, new KeyState());
			
			// checks if there is a "single" non-mod-key before into list
			if (modKey > -1) {
				var insertPos:Int = 0;
				for (ma in keyState.keyCombo) {
					if ( (!actionState.single && ma.actionState.single) ||
					     ( ma.keyCode == -1 && (ma.actionState.single || actionState.single) )
					   ) break;
					insertPos++;
				}
				keyState.keyCombo.insert(insertPos, new KeyCombo(modKey, actionState));
			}
			else keyState.keyCombo.push(new KeyCombo(modKey, actionState));			
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
			
			#if input2action_noKeyCombos
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
					if (keyCombo.keyCode == -1 || isDown(keyCombo.keyCode))
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
			
			#if input2action_noKeyCombos
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
						
						actionState = keyCombo.actionState;
						
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
	
	// TODO: also for joysticks !
	public function keyCodeName(key:Int):String {
		if (Input2Action.MAX_USABLE_KEYCODES == this.length)
			return Input2Action.keyCodeName.get( Input2Action.toKeyCode(key) );
		else return Input2Action.gamepadButtonName.get(key);
	}
		
	
	@:to public function toString():String 
	{
		var out = "";
		
		var actionName = function(actionState:ActionState):String {
			#if input2action_debug
			return actionState.name;
			#else
			return Std.string(actionState.action);
			#end
		}

		for (i in 0...this.length) {
			var keyState = this.get(i);
			if (keyState != null) {
				out += '\n\n';
				out += keyCodeName(i);
				out += (keyState.isDown) ? " (isDown)" : " (isUp)";
				
				#if input2action_noKeyCombos
				if (keyState.singleKeyAction != null) out += ' -> ' + actionName(keyState.singleKeyAction);
				#else
				if (keyState.keyCombo != null)
					for (keyCombo in keyState.keyCombo) {
						out += '\n   ';
						var actionState:ActionState = keyCombo.actionState;
						if (keyCombo.keyCode > -1) out += keyCodeName(keyCombo.keyCode) + ": ";
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
	
	#if input2action_noKeyCombos
	
	public var deviceID:Int;
	public var singleKeyAction:ActionState = null;
	
	#else
	
	public var keyCombo:Array<KeyCombo> = null;
	
	#end
	
	public function new() {}
}


#if !input2action_noKeyCombos

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
	
	public var player:Int;
	
	#if input2action_debug
	public var name:String;
	#end
	
	public inline function callDownAction() action(true, player);
	public inline function callUpAction() action(false, player);
	
	public inline function new(up:Bool, each:Bool, single:Bool, action:ActionFunction, player:Int #if input2action_debug , name:String #end) {
		this.up = up;
		this.each = each;
		this.single = single;
		this.action = action;
		this.player = player;
		#if input2action_debug 
		this.name = name;
		#end
	}

}

