package;
import input2action.ActionMap;


class Action 
{	
	public var actionMap:ActionMap;

	// TODO:
	// public var axisActionMap:AxisActionMap;
	
	public function new() 
	{
		// ---------------------------------------------------------------------
		// ----------- map action-identifiers to function-references -----------
		// ---------------------------------------------------------------------
	
		// --- boolean options (all is false by default) ---
		
		//   up: true - enables key/button up-event (without that, the "isDown" param is allways TRUE),
		//              so the action is also called by key-up-event and its "isDown" then will be FALSE
		
		//   if multiple keys for this action is pressed/released together
		//   each: true  - call the function on each of them
		//         false - call only down-event if the first is pressed and up-event after the last is released
	
		//   repeatKeyboardDefault: true - repeat the keyboard down-events and using the os-defaults (keyboard only!)
		
		
		// --- integer options (all is 0 by default) ---
		
		//   repeatDelay:  time in ms how long it waits before start repeating the down-events while keypressing
		//                 value of 0 (default) is disable the initial delay time
		
		//   repeatRate:   time in ms how often it repeats the down-events while keypressing
		//                 value of 0 (default) is disable keyrepeat completely (also the delay)
		
		actionMap = [
				"menu"      => { action:menu },
				"inventory" => { action:inventory },
				"enter"     => { action:enter    , up:true },
				"modEnter"  => { action:modEnter , up:true },
				
				"fireLeft"  => { action:fireLeft , up:true, repeatRate:700 },
				"fireRight" => { action:fireRight, up:true, repeatRate:700, each:true },
				
				"modXfireLeft"  =>  { action:modXfireLeft , up:true },
				"modYfireLeft" =>   { action:modYfireLeft , up:true },
				"modXfireRight"  => { action:modXfireRight, up:true },
				"modYfireRight" =>  { action:modYfireRight, up:true },
				
				"moveUp"    => { action:moveUp   , up:true },
				"moveDown"  => { action:moveDown , up:true },
				"moveLeft"  => { action:moveLeft , up:true, repeatKeyboardDefault:true, repeatRate:500, repeatDelay:1000 },
				"moveRight" => { action:moveRight, up:true, repeatKeyboardDefault:true, repeatRate:500 },
			];

				
		// TODO: joysticks and gamepad-analogue-input
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
	
	function modEnter(isDown:Bool, player:Int) {
		trace('modEnter - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function fireLeft(isDown:Bool, player:Int) {
		trace('fireLeft - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function fireRight(isDown:Bool, player:Int) {
		trace('fireRight - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function modXfireLeft(isDown:Bool, player:Int) {
		trace('modXfireLeft - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function modYfireLeft(isDown:Bool, player:Int) {
		trace('modYfireLeft - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function modXfireRight(isDown:Bool, player:Int) {
		trace('modXfireRight - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function modYfireRight(isDown:Bool, player:Int) {
		trace('modYfireRight - ${(isDown) ? "DOWN" : "UP"}, player:$player');
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