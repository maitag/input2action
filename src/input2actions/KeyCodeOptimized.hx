package input2actions;

import lime.ui.KeyCode;

@:forward
@:forwardStatics
@:enum abstract KeyCodeOptimized(KeyCode) to Int
{
	inline function new(i:Int) {
		this = i;
	}
	
	@:from
	static public function fromLimeKeyCode(k:KeyCode) {
		return new KeyCodeOptimized( (k < 0x40000039) ? k : k - 0x40000039 + 0x80 ); // shrink from CAPS_LOCK down
	}

	@:to
	public inline function toLimeKeyCode():KeyCode {
		return ((this < 0x80) ? this : this + 0x40000039 - 0x80); // extract again
	}
	
	
	
}