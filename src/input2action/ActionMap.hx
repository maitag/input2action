package input2action;
import input2action.ActionFunction;
import input2action.InputState.ActionState;

typedef ActionMap = haxe.ds.StringMap<ActionMapItem>;


typedef ActionMapItem = {
	action:ActionFunction,
	?up:Bool,
	?each:Bool
}