package input2action;
import input2action.ActionFunction;

typedef ActionMap = haxe.ds.StringMap<ActionMapItem>;


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