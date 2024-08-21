package input2action;

import input2action.util.NestedArray;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;

@:forward
abstract ActionConfig(Array<ActionConfigItem>) from Array<ActionConfigItem> to Array<ActionConfigItem>
{
/*	public inline function new()
	{
		this = new Array<ActionConfigItem>();
	}
*/	
	public static function fromJson(jsonString:String, debugFilename:String = ""):ActionConfig {
		return JsonConfig.fromString(jsonString, debugFilename).toActionConfig();
	}
	
	public function toJson():String {
		return JsonConfig.fromActionConfig(this);
	}

	public function add(actionConfig:ActionConfig, replaceExisting:Bool = true) {
		if (replaceExisting) for (item in actionConfig) this.push(item);
		else {
			var existingActions:Array<String> = [for (item in this) item.action];
			for (item in actionConfig)
				if (existingActions.indexOf(item.action) < 0) this.push(item);
		}
	}

}


@:structInit
class ActionConfigItem {
	public var action:String;
	
	public var single:Bool = false;
	
	public var keyboard:NestedArray<KeyCode> = null;
	public var gamepad :NestedArray<GamepadButton> = null;
	public var joystick:NestedArray<Int> = null;	
}

