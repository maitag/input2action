package input2action;

import lime.ui.Window;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
//import lime.ui.KeyModifier;
import lime.ui.Gamepad;
import lime.ui.GamepadAxis;

import input2action.ErrorMsg;
import input2action.KeyboardAction;
import input2action.GamepadAction;

/**
 * by Sylvio Sell - Rostock 2022
*/

class Input2Action 
{
	var window:Window;

	public function new(window:Window) 
	{
		this.window = window;		
	}

	public function enable() {
		enableKeyboard();
		enableGamepad();
	}
	
	public function disable() {
		disableKeyboard();
		disableGamepad();
	}
	

	// -----------------------------------------------------
	// ---------------- Keyboard ---------------------------
	// -----------------------------------------------------
	
	public var activeKeyboardActions = new Array<KeyboardAction>();

	public function addKeyboard(keyboardAction:KeyboardAction) {
		activeKeyboardActions.push(keyboardAction);
	}
	
	public function removeKeyboard(keyboardAction:KeyboardAction) {
		activeKeyboardActions.remove(keyboardAction);
	}

	public function enableKeyboard() {
		window.onKeyDown.add(keyDown);
		window.onKeyUp.add(keyUp);
	}

	public function disableKeyboard() {
		window.onKeyDown.remove(keyDown);
		window.onKeyUp.remove(keyUp);
	}
	
	inline function keyDown(key:KeyCode, _):Void {
		for (keyboardAction in activeKeyboardActions) keyboardAction.keyDown(key);
	}
	
	inline function keyUp(key:KeyCode, _):Void {
		for (keyboardAction in activeKeyboardActions) keyboardAction.keyUp(key);
	}
	
	
	// -----------------------------------------------------
	// ---------------- Gamepad ----------------------------
	// -----------------------------------------------------
	
	public var activeGamepads = new Map<Gamepad, Array<GamepadAction>>();

	public function addGamepad(gamepad:Gamepad, gamepadAction:GamepadAction) {
		var activeGamepadActions:Array<GamepadAction> = activeGamepads.get(gamepad);
		
		// if its the first gamepadAction for this gamepad
		if (activeGamepadActions == null) 
		{
			activeGamepadActions = new Array<GamepadAction>();
			activeGamepads.set( gamepad, activeGamepadActions );

			// add eventhandler for this gamepad
			gamepad.onButtonDown.add(gamepadButtonDown.bind(activeGamepadActions));
			gamepad.onButtonUp.add(gamepadButtonUp.bind(activeGamepadActions));			
			//gamepad.onAxisMove.add(gamepadAxisMove.bind(activeGamepadActions));
		}
		activeGamepadActions.push(gamepadAction);
	}
	
	public function removeGamepadAction(gamepad:Gamepad, gamepadAction:GamepadAction) {
		var activeGamepadActions:Array<GamepadAction> = activeGamepads.get(gamepad);
		if (activeGamepadActions == null) {
			trace("into removeGamepad: not added something yet for this gamepad");
		} 
		else {
			activeGamepadActions.remove(gamepadAction);
			// if removing last gamepadAction for this gamepad
			if (activeGamepadActions.length == 0) _removeGamepad(gamepad, activeGamepadActions);
		}
	}

	public function removeGamepad(gamepad:Gamepad) {
		var activeGamepadActions:Array<GamepadAction> = activeGamepads.get(gamepad);
		if (activeGamepadActions == null) {
			trace("into removeGamepad: not added something yet for this gamepad");
		} 
		else _removeGamepad(gamepad, activeGamepadActions);
	}

	inline function _removeGamepad(gamepad:Gamepad, activeGamepadActions:Array<GamepadAction>) {
		activeGamepads.remove(gamepad);

		// remove eventhandler for this gamepad
		gamepad.onButtonDown.remove(gamepadButtonDown.bind(activeGamepadActions));
		gamepad.onButtonUp.remove(gamepadButtonUp.bind(activeGamepadActions));
		//gamepad.onAxisMove.remove(gamepadAxisMove.bind(activeGamepadActions));
	}

	inline function gamepadButtonDown(activeGamepadActions:Array<GamepadAction>, button:GamepadButton):Void {
		for (gamepadAction in activeGamepadActions) gamepadAction.buttonDown(button);
	}
	
	inline function gamepadButtonUp(activeGamepadActions:Array<GamepadAction>, button:GamepadButton):Void {
		for (gamepadAction in activeGamepadActions) gamepadAction.buttonUp(button);
	}

	// TODO:
	public function enableGamepad() {
		
	}

	public function disableGamepad() {
		
	}



	// TODO
	
	inline function gamepadAxisMove(gamepadState:InputState, axis:GamepadAxis, value:Float):Void
	{	
		if (value < -0.5) {
			//trace (axis, value);					
		} else if (value > 0.5) {
			//trace (axis, value);
		}
/*		switch (axis) {		
			case GamepadAxis.LEFT_X:
				
				if (value < -0.5) {
					trace ("axis left");					
				} else if (value > 0.5) {
					trace ("axis right");
				}
			
			case GamepadAxis.LEFT_Y:
				
				if (value < -0.5) {
					trace ("axis up");
				} else if (value > 0.5) {
					trace ("axis down");
				}
			
			default:		
		}
*/		
	}
	
	
	

}