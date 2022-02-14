package input2action;


abstract Json2ObjectConfig(Map<String, Json2ObjectItem>) from Map<String, Json2ObjectItem> to Map<String, Json2ObjectItem>
{

}

class Json2ObjectItem {
	var down:Bool = true;
	var up:Bool = false;
	var repeat:Bool = false;
	var repeatRate:Int = 10;
	
	var keyboard:String = null;
	var gamepad :String = null;
	var joystick:String = null;

/*	public function toJsonActionConfigItem(v:NestedArray<lime.ui.KeyCode>):ActionConfigItem {
		return null;
	}
*/
	
}

