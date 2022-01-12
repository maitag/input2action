package input2actions;

import lime.ui.KeyCode;
import lime.ui.GamepadButton;

typedef ActionConfig = haxe.ds.StringMap<ActionConfigItem>;
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
	public var down:Bool = true;
	public var up:Bool = false;
	public var repeat:Bool = false;
	public var repeatRate:Int = 10;
	
	public var keyboard:NestedArray<KeyCode> = null;
	public var gamepad :NestedArray<GamepadButton> = null;
	public var joystick:NestedArray<Int> = null;	
}

