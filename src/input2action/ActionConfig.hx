package input2action;

import input2action.util.NestedArray;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;

typedef ActionConfig = Array<ActionConfigItem>;
// TODO: own abstract Array and extra spice to set defaults or force config values

/*typedef ActionConfigItem = {
	action:String,
	?single:Bool,
	
	?keyboard:NestedArray<KeyCode>,
	?gamepad :NestedArray<GamepadButton>,
	?joystick:NestedArray<Int>,	
}
*/


@:structInit
class ActionConfigItem {
	public var action:String;
	
	public var single:Bool = false;
	
	public var keyboard:NestedArray<KeyCode> = null;
	public var gamepad :NestedArray<GamepadButton> = null;
	public var joystick:NestedArray<Int> = null;	
}

