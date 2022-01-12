package input2actions;

@:enum abstract InputType(Int) from Int to Int 
{
	public static inline var KEYBOARD :Int = 0;
	public static inline var GAMEPAD  :Int = 1;
	public static inline var JOYSTICK :Int = 2;
}
