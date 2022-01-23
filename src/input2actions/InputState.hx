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
		
		#if input2actions_singlekey
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
	
	public inline function isDownByKeyCombo(key:Int, keyState:KeyState):Bool {
		var keyComboState = this.get(key);
		if (keyComboState == null) return false;
		else {
			if (keyComboState.isDown) return true;
			else {
				return (keyComboState.upDownAt > keyState.upDownAt);
			}
		}
	}
	
		
	public inline function callDownActions(key:Int) {
		var keyState = this.get(key);
		if (keyState != null && !keyState.isDown) {
			keyState.isDown = true;
			keyState.upDownAt = step++;
			
			#if input2actions_singlekey
			if (keyState.singleKeyAction != null) keyState.singleKeyAction.action(InputType.KEYBOARD, ActionType.DOWN); //TODO
			#else
			if (keyState.keyCombo != null) 
			{
				var called = false;
				for (keyCombo in keyState.keyCombo) 
				{
					if (keyCombo.keyCode == 0 || isDown(keyCombo.keyCode))
					{
						var actionState:ActionState = keyCombo.actionState;
						
						//trace("DOWN", actionState.name, actionState.pressed);
						
						if (!actionState.single || !called)
						{					
							switch (actionState.down) {
								case ANY  :
									actionState.pressed++;
									called = true;
									actionState.action(InputType.KEYBOARD, ActionType.DOWN);
								case ONES :
									actionState.pressed++;
									called = true;
									if (actionState.pressed == 1) {
										actionState.action(InputType.KEYBOARD, ActionType.DOWN);
									}
								default: if (actionState.up != KeySetting.NONE) actionState.pressed++; // TODO
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
			
			#if input2actions_singlekey
			if (keyState.singleKeyAction != null) keyState.singleKeyAction.action(InputType.KEYBOARD, ActionType.UP); //TODO
			#else
			if (keyState.keyCombo != null)
			{
				var called = false;
				for (keyCombo in keyState.keyCombo)
				{
					if (keyCombo.keyCode == 0 || isDownByKeyCombo(keyCombo.keyCode, keyState))
					{
						var actionState:ActionState = keyCombo.actionState; //trace("UP", actionState.name, actionState.pressed);
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
											actionState.action(InputType.KEYBOARD, ActionType.UP); 
										}
										called = true;
									default: if (actionState.down != KeySetting.NONE) actionState.pressed--; // TODO
								}						
								if (actionState.single) break;
							}
						}
					}
				}
			}
			#end
			
			keyState.upDownAt = step++;

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
			var keyState = this.get(i);
			if (keyState != null) {
				out += '\n\n';
				out += Input2Actions.keyCodeName.get(Input2Actions.toKeyCode(i));
				out += (keyState.isDown) ? " (isDown)" : " (isUp)";
				
				#if input2actions_singlekey
				if (keyState.singleKeyAction != null) out += ' -> ' + actionName(keyState.singleKeyAction.action);
				#else
				if (keyState.keyCombo != null)
					for (keyCombo in keyState.keyCombo) {
						out += '\n   ';
						var actionState:ActionState = keyCombo.actionState;
						if (keyCombo.keyCode > 0) out += keyCodeName(keyCombo.keyCode) + ": ";
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


private class KeyState
{
	public var isDown:Bool = false;
	public var upDownAt:Int = 0; // step at what the key was pressed or released
	
	#if input2actions_singlekey
	
	public var deviceID:Int;
	public var singleKeyAction:ActionState = null;
	
	#else
	
	public var keyCombo:Array<KeyCombo> = null;
	
	#end
	
	public function new() {}
}


#if !input2actions_singlekey

private class KeyCombo 
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

