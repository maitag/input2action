package input2action;

import input2action.util.NestedArray;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;

//typedef ActionConfig = Array<ActionConfigItem>;
@:forward
abstract ActionConfig(Array<ActionConfigItem>) from Array<ActionConfigItem> to Array<ActionConfigItem>
{
// TODO: extra spice to set defaults or force config values

}


@:structInit
class ActionConfigItem {
	public var action:String;
	
	public var single:Bool = false;
	
	public var keyboard:NestedArray<KeyCode> = null;
	public var gamepad :NestedArray<GamepadButton> = null;
	public var joystick:NestedArray<Int> = null;	
}

