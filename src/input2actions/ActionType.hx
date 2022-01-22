package input2actions;

@:enum abstract ActionType(Int) from Int to Int 
{
	public static inline var UP    :Int = 1;
	public static inline var DOWN  :Int = 2;
	public static inline var REPEAT:Int = 4;
}
