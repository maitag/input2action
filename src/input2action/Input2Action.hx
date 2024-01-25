package input2action;

import lime.ui.Window;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
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
	var window:Window = null;

	public function new() {};

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

	public function registerKeyboardEvents(window:Window) {
		if (this.window == null) this.window = window;
		else ErrorMsg.keyboardEventsAlreadyRegistered();
		window.onKeyDown.add(keyDown);
		window.onKeyUp.add(keyUp);
	}

	public function unRegisterKeyboardEvents() {
		if (this.window == null) {
			window.onKeyDown.remove(keyDown);
			window.onKeyUp.remove(keyUp);
			window = null;
		}
	}
	
	public inline function keyDown(key:KeyCode, _):Void {
		for (keyboardAction in activeKeyboardActions) keyboardAction.keyDown(key);
	}
	
	public inline function keyUp(key:KeyCode, _):Void {
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
			gamepad.onButtonDown.add(_gamepadButtonDown.bind(activeGamepadActions));
			gamepad.onButtonUp.add(_gamepadButtonUp.bind(activeGamepadActions));			
		}
		activeGamepadActions.push(gamepadAction);
	}
	
	public function removeGamepadAction(gamepad:Gamepad, gamepadAction:GamepadAction) {
		var activeGamepadActions:Array<GamepadAction> = activeGamepads.get(gamepad);
		if (activeGamepadActions != null)
		{
			activeGamepadActions.remove(gamepadAction);
			
			// if removing last gamepadAction for this gamepad
			if (activeGamepadActions.length == 0) _removeGamepad(gamepad, activeGamepadActions);
		}
	}

	public function removeGamepad(gamepad:Gamepad) {
		var activeGamepadActions:Array<GamepadAction> = activeGamepads.get(gamepad);
		if (activeGamepadActions != null) _removeGamepad(gamepad, activeGamepadActions);
	}

	inline function _removeGamepad(gamepad:Gamepad, activeGamepadActions:Array<GamepadAction>) {
		activeGamepads.remove(gamepad);
		// remove eventhandler for this gamepad
		gamepad.onButtonDown.remove(_gamepadButtonDown.bind(activeGamepadActions));
		gamepad.onButtonUp.remove(_gamepadButtonUp.bind(activeGamepadActions));
	}

	inline function _gamepadButtonDown(activeGamepadActions:Array<GamepadAction>, button:GamepadButton):Void {
		for (gamepadAction in activeGamepadActions) gamepadAction.buttonDown(button);
	}
	
	inline function _gamepadButtonUp(activeGamepadActions:Array<GamepadAction>, button:GamepadButton):Void {
		for (gamepadAction in activeGamepadActions) gamepadAction.buttonUp(button);
	}

	public inline function gamepadButtonDown(gamepad:Gamepad, button:GamepadButton):Void {
		_gamepadButtonDown(activeGamepads.get(gamepad), button);
	}
	
	public inline function gamepadButtonUp(gamepad:Gamepad, button:GamepadButton):Void {
		_gamepadButtonUp(activeGamepads.get(gamepad), button);
	}	

}