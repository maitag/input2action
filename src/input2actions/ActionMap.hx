package input2actions;
import input2actions.ActionFunction;
import input2actions.InputState.ActionState;

typedef ActionMap = haxe.ds.StringMap<ActionMapItem>;


typedef ActionMapItem = {
	action:ActionFunction,
	?up:Bool,
	?each:Bool
}