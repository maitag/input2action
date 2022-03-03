package input2action;
import input2action.ActionFunction;

typedef ActionMap = haxe.ds.StringMap<ActionMapItem>;


typedef ActionMapItem = {
	action:ActionFunction,
	?description:String,
	?up:Bool,
	?each:Bool
}