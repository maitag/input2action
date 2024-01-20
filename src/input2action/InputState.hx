package input2action;

import haxe.ds.Vector;
import input2action.ActionFunction;
import input2action.Input2Action;

/**
 * by Sylvio Sell - Rostock 2022
*/

@:access(input2action.KeyboardAction)
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
	
	// --------------- DOWN -------------------------
	
	inline function callDownActions(key:Int, param:Int, isKeyboard:Bool) { // TODO: isKeyboard
		var keyState = this.get(key);
		if (keyState != null
			#if input2action_noRepeat
			&& (!isKeyboard || !keyState.isDown)
			#end
		)
		{
			var repeated = false;
			#if input2action_noRepeat
			keyState.isDown = true;
			#else
			if (!keyState.isDown) keyState.isDown = true;	
			else if (isKeyboard) repeated = true;
			#end
			
			#if input2action_noKeyCombos
			if (keyState.singleKeyAction != null) {
				var actionState:ActionState = keyState.singleKeyAction;				
				if (!repeated) actionState.pressed++;
				_callDownAction(actionState, param, isKeyboard, repeated);
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
							
							if (!repeated) actionState.pressed++;
							_callDownAction(actionState, param, isKeyboard, repeated);
							
							if (actionState.single) break;
						}
					}
				}
			} 
			#end
		}
	}
		
	inline function _callDownAction(actionState:ActionState, param:Int, isKeyboard:Bool, repeated:Bool) 
	{	
		#if input2action_noRepeat
		if ( actionState.each || (actionState.pressed == 1) ) actionState.callDownAction(param);
		#else
		if (isKeyboard && actionState.repeatKeyboardDefault) { // keyboard is using system-settings
			actionState.callDownAction(param);
		}
		else if (!repeated) 
		{
			if ( actionState.each || (actionState.pressed == 1) ) actionState.callDownAction(param);
			
			if (actionState.repeatRate != 0 && actionState.timer == null) 
			{
				//trace("actionState.timer.START()");
				//if (actionState.timer != null) actionState.timer.stop();
				if (actionState.repeatDelay == 0) {	
					actionState.timer = new haxe.Timer(actionState.repeatRate);
					actionState.timer.run = actionState.callDownAction.bind(param);
				}
				else { // https://try.haxe.org/#8248a0f7
					actionState.timer = new haxe.Timer(actionState.repeatDelay);
					actionState.timer.run = function() {
						actionState.callDownAction(param);
						actionState.timer.stop();
						actionState.timer = new haxe.Timer(actionState.repeatRate);
						//actionState.timer.run = (param) -> actionState.callDownAction(param);
						actionState.timer.run = actionState.callDownAction.bind(param);
					};
				}
			}
		}
		#end
	}
	
	// ----------------- UP -----------------------
	
	inline function callUpActions(key:Int, param:Int, isKeyboard:Bool) {
		var keyState = this.get(key);
		if (keyState != null && keyState.isDown) {
			keyState.isDown = false;
			#if input2action_noKeyCombos
			if (keyState.singleKeyAction != null) {
				var actionState:ActionState = keyState.singleKeyAction;
				actionState.pressed--;
				_callUpAction(actionState, param, isKeyboard);
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
						actionState.pressed--;						
						_callUpAction(actionState, param, isKeyboard);											
					}
				}
			}
			#end
		}
	}
	
	inline function _callUpAction(actionState:ActionState, param:Int, isKeyboard:Bool) {
		#if !input2action_noRepeat
		if (actionState.pressed == 0 && actionState.repeatRate != 0 && actionState.timer != null) 
		{	//trace("actionState.timer.stop()");
			actionState.timer.stop();
			actionState.timer = null;
		}
		#end
		if (actionState.up && (actionState.each || (actionState.pressed == 0) ) ) actionState.callUpAction(param);
	}
	
	// ----------------------------------------
	
	// TODO: also for joysticks !
	public function keyCodeName(key:Int):String {
		if (KeyboardAction.MAX_USABLE_KEYCODES == this.length)
			return KeyboardAction.keyCodeName.get( KeyboardAction.toKeyCode(key) );
		else return GamepadAction.gamepadButtonName.get(key);
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
	public var up:Bool = false;
	public var each:Bool = false;
	
	#if !input2action_noRepeat
	public var repeatKeyboardDefault:Bool = false;
	public var repeatDelay:Int = 0;
	public var repeatRate:Int = 0;
	
	public var timer:haxe.Timer = null;
	#end
	
	public var single:Bool;
	
	public var pressed:Int = 0;
	public var action:ActionFunction = null;
		
	#if input2action_debug
	public var name:String;
	#end
	
	public inline function callDownAction(param:Int) action(true, param);
	public inline function callUpAction(param:Int) action(false, param);
	
	public inline function new(
		up:Null<Bool>, each:Null<Bool>,
		#if !input2action_noRepeat
		repeatKeyboardDefault:Null<Bool>, repeatDelay:Null<Int>, repeatRate:Null<Int>,
		#end
		single:Bool, action:ActionFunction #if input2action_debug , name:String #end
	) {
		if (up   != null) this.up = up;
		if (each != null) this.each = each;
		
		#if !input2action_noRepeat
		if (repeatKeyboardDefault != null) this.repeatKeyboardDefault = repeatKeyboardDefault;
		if (repeatDelay != null) this.repeatDelay = repeatDelay;
		if (repeatRate  != null) this.repeatRate = repeatRate;
		#end
		
		this.single = single;
		this.action = action;

		#if input2action_debug 
		this.name = name;
		#end
	}

}

