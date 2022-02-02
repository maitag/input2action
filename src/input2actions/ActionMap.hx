package input2actions;
import input2actions.ActionFunction;

typedef ActionMap = haxe.ds.StringMap<ActionMapItem>;


typedef ActionMapItem = {
	action:ActionFunction,
	?up:Bool,
	?each:Bool
}