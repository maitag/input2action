package;
import input2action.ActionMap;


class Action 
{	
	public var actionMap:ActionMap;

	// TODO:
	// public var axisActionMap:AxisActionMap;
	
	public function new() 
	{
		// map action-identifiers to function-references
		// options (false by default):
		//   up:true - enables key/button up-event
		//   
		//   if multiple keys for this action is pressed/released together
		//   each: true  - call the function on each of them
		//         false - call only down-event if the first is pressed and up-event after the last is released
	
		actionMap = [
				"menu"      => { action:menu },
				"inventory" => { action:inventory },
				"enter"     => { action:enter    , up:true },
				
				"fire"      => { action:fire     , up:true, each:true },
				
				"moveUp"    => { action:moveUp   , up:true },
				"moveDown"  => { action:moveDown , up:true },
				"moveLeft"  => { action:moveLeft , up:true },
				"moveRight" => { action:moveRight, up:true },
			];

				
		// TODO: joysticks and gamepad-analogue-firebuttons
		/*	public var axisActionMap:AxisActionMap = [
					"moveByStick" => {
						action:moveByStick
						// TODO:
						//actionAxis:moveByStick,
					},
				];
		*/		
	}
	
	// ------------------------------------------------------------	
	// ------------ Keyboard and Button Actions -------------------	
	// ------------------------------------------------------------
	
	function menu(_, _) {
		trace('menu');
	}
	
	function inventory(_, player:Int) {
		trace('inventory - player:$player');
	}
	
	function enter(isDown:Bool, player:Int) {
		trace('enter - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function fire(isDown:Bool, player:Int) {
		trace('fire - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function moveUp(isDown:Bool, player:Int) {
		trace('moveUp - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function moveDown(isDown:Bool, player:Int) {
		trace('moveDown - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function moveLeft(isDown:Bool, player:Int) {
		trace('moveLeft - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function moveRight(isDown:Bool, player:Int) {
		trace('moveRight - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	
	// TODO
	// ------------------------------------------------------------	
	// ------------ Gamepad/Joystick Axis Actions -----------------
	// ------------------------------------------------------------
	
/*	function moveByStick(xAxis:Float, yAxis:Float, player:Int) 
	{
		trace('moveRight - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function fireRated(xAxis:Float, yAxis:Float, player:Int) 
	{
		trace('action 1 - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
*/	
	
}