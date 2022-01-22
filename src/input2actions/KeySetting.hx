package input2actions;

@:enum abstract KeySetting(Int) from Int to Int 
{
	public static inline var NONE :Int = 0;
	public static inline var ANY  :Int = 1;
	public static inline var ONES :Int = 2;
}
