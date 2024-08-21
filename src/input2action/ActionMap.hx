package input2action;

import haxe.ds.StringMap;
import haxe.ds.Map;
import input2action.ActionFunction;

// typedef ActionMap = haxe.ds.StringMap<ActionMapItem>;

@:forward
abstract ActionMap(StringMap<ActionMapItem>) from StringMap<ActionMapItem> to StringMap<ActionMapItem>
{
/*	public inline function new()
	{
		this = new StringMap<ActionMapItem>();
	}
*/
	@:from
	public static inline function fromStringMap(map:Map<String, ActionMapItem>):ActionMap {
		return cast map;
	}

	public function add(actionMap:ActionMap, replaceExisting:Bool = true) {
		for (key => value in actionMap) 
			if (replaceExisting || !this.exists(key)) this.set(key, value);
	}


}

typedef ActionMapItem = {
	action:ActionFunction,
	?description:String,
	?up:Null<Bool>,
	?each:Null<Bool>,
	#if !input2action_noRepeat
	?repeatKeyboardDefault:Null<Bool>,
	?repeatDelay:Null<Int>,
	?repeatRate:Null<Int>
	#end
}