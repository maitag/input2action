package input2action;

import haxe.ds.StringMap;
import haxe.ds.Map;

// typedef ActionMap = haxe.ds.StringMap<ActionMapItem>;

@:forward
abstract ActionMap(StringMap<ActionMapItem>) from StringMap<ActionMapItem> to StringMap<ActionMapItem>
{
	// for haxe < 4.2 its more safe to use the construcor and map-literal as argument !
	public inline function new(map:StringMap<ActionMapItem>) {
		this = map;
	}
		
	// this did not work if ActionMapItem is a @:structInit
	@:from
	public static inline function fromStringMap(map:Map<String, ActionMapItem>):ActionMap {
		// trace("cast from Map<String, ActionMapItem>");
		return (map : StringMap<ActionMapItem>);
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

/*
// problems with hashlink
@:structInit
class ActionMapItem {
	public var action:ActionFunction;
	public var description:String = null;
	public var up:Null<Bool> = null;
	public var each:Null<Bool> = null;
	#if !input2action_noRepeat
	public var repeatKeyboardDefault:Null<Bool> = null;
	public var repeatDelay:Null<Int> = null;
	public var repeatRate:Null<Int> = null;
	#end
}
*/
