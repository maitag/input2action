package input2actions;

import input2actions.util.NestedArray;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;

typedef ActionConfig = Array<ActionConfigItem>;
//typedef ActionConfig = Map<String, ActionConfigItem>;


/*typedef ActionConfigItem = {
	?down:Bool,
	?up:Bool,
	?repeat:Bool,
	?repeatRate:Int,
	
	?keyboard:NestedArray<KeyCode>,
	?gamepad :NestedArray<GamepadButton>,
	?joystick:NestedArray<Int>,	
}
*/


@:structInit
class ActionConfigItem {
	public var action:String;
	
	public var up:Bool = false;
	public var each:Bool = false;	
	public var single:Bool = false;
	
	public var keyboard:NestedArray<KeyCode> = null;
	public var gamepad :NestedArray<GamepadButton> = null;
	public var joystick:NestedArray<Int> = null;	
}

