package;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.Gamepad;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;

import input2action.ActionConfig;
import input2action.ActionMap;
import input2action.KeyboardAction;
import input2action.GamepadAction;
import input2action.Input2Action;


class SimpleConfig extends Application {	
		
	public override function onWindowCreate ():Void 
	{
		//trace(lime.system.Locale.currentLocale.language);

		// ---------------------------------------------------------------------
		// --------- key- and buttonbindings for keyboard and gamepad ----------
		// ---------------------------------------------------------------------

		var actionConfig:ActionConfig = [
			{	action: "menu",
				keyboard: KeyCode.ESCAPE,
				gamepad:  GamepadButton.BACK
			},
			{	action: "inventory",
				keyboard: KeyCode.I,
				gamepad:  GamepadButton.A
			},
			{	action: "enter",
				keyboard: [ KeyCode.RETURN, KeyCode.RETURN2 ],
				gamepad:  [ GamepadButton.LEFT_STICK ]
			},
			{	action: "modEnter",
				keyboard: KeyCode.NUMPAD_ENTER,
				gamepad:  GamepadButton.RIGHT_STICK
			},
			{	action: "fireLeft",
				keyboard: [ KeyCode.LEFT_CTRL, KeyCode.LEFT_ALT ],
				gamepad:  [ GamepadButton.LEFT_SHOULDER ]
			},
			{	action: "fireRight",
				keyboard: [ KeyCode.RIGHT_CTRL, KeyCode.SPACE, KeyCode.RIGHT_ALT ],
				gamepad:  [ GamepadButton.RIGHT_SHOULDER ]
			},
			{	action: "moveUp",
				keyboard: [ KeyCode.W, KeyCode.UP],
				gamepad:  [ GamepadButton.DPAD_UP ]
			},
			{	action: "moveDown",
				keyboard: [ KeyCode.S, KeyCode.DOWN],
				gamepad:  [ GamepadButton.DPAD_DOWN ]
			},
			{	action: "moveLeft",
				keyboard: [ KeyCode.A, KeyCode.LEFT],
				gamepad:  [ GamepadButton.DPAD_LEFT ]
			},
			{	action: "moveRight",
				keyboard: [ KeyCode.D, KeyCode.RIGHT],
				gamepad:  [ GamepadButton.DPAD_RIGHT ]
			},
		];
		
		// ---------------------------------------------------------------------
		// ----------- map action-identifiers to function-references -----------
		// ---------------------------------------------------------------------
	
		var actionMap:ActionMap = [
			"menu"      => { action:(_, _)->trace('menu') },
			"inventory" => { action:(_, player)->trace('inventory - player:$player') },

			// up: true - enables key/button up-event (without that, the "isDown" param is allways TRUE),
			//            so the action is also called by key-up-event and its "isDown" then will be FALSE
			"enter"     => { action:(isDown, player)->trace('enter - ${(isDown) ? "DOWN" : "UP"}, player:$player'), up:true },
			"modEnter"  => { action:(isDown, player)->trace('modenter - ${(isDown) ? "DOWN" : "UP"}, player:$player'), up:true },
			
			"modXfireLeft"  =>  { action:(isDown, player)->trace('modXfireLeft  - ${(isDown) ? "DOWN" : "UP"}, player:$player'), up:true },
			"modYfireLeft" =>   { action:(isDown, player)->trace('modYfireLeft  - ${(isDown) ? "DOWN" : "UP"}, player:$player'), up:true },
			"modXfireRight"  => { action:(isDown, player)->trace('modXfireRight - ${(isDown) ? "DOWN" : "UP"}, player:$player'), up:true },
			"modYfireRight" =>  { action:(isDown, player)->trace('modYfireRight - ${(isDown) ? "DOWN" : "UP"}, player:$player'), up:true },
			
			"moveUp"    => { action:(isDown, player)->trace('moveUp   - ${(isDown) ? "DOWN" : "UP"}, player:$player'), up:true },
			"moveDown"  => { action:(isDown, player)->trace('moveDown - ${(isDown) ? "DOWN" : "UP"}, player:$player'), up:true },

			// --- integer options to set custom repeat-time ---
			// (for keyboard this values only gets effect if repeatKeyboardDefault is not enabled)
			
			// repeatDelay:  time in ms how long it waits before start repeating the down-events while keypressing
			//               value of 0 (default) is disable the initial delay time
			
			// repeatRate:   time in ms how often it repeats the down-events while keypressing
			//               value of 0 (default) is disable keyrepeat completely (also the delay)			
			"moveLeft"  => { action:(isDown, player)->trace('moveLeft - ${(isDown) ? "DOWN" : "UP"}, player:$player'), up:true
				#if !input2action_noRepeat
				, repeatKeyboardDefault:true, repeatRate:500, repeatDelay:1000
				#end
			},
			
			"moveRight" => { action:(isDown, player)->trace('moveRight - ${(isDown) ? "DOWN" : "UP"}, player:$player'), up:true
				#if !input2action_noRepeat
				, repeatKeyboardDefault:true, repeatRate:500
				#end
			},

			"fireLeft"  => { action:(isDown, player)->trace('fireLeft - ${(isDown) ? "DOWN" : "UP"}, player:$player'), up:true
				#if !input2action_noRepeat
				, repeatRate:700
				#end
			},

			// if multiple keys for this action is pressed/released together
			// each: true  - call the function on each of them
			//       false - call only down-event if the first is pressed and up-event after the last is released			
			"fireRight" => { action:(isDown, player)->trace('fireRight - ${(isDown) ? "DOWN" : "UP"}, player:$player'), up:true,
				each:true
				#if !input2action_noRepeat
				, repeatRate:700
				#end
			}
			
		];



		// ---------------------------------------------------
		// -------------- init input2Action  -----------------
		// ---------------------------------------------------

		var input2Action = new Input2Action(window);
		

		// -------- KEYBOARD -----------

		// set keyboard bindings
		var keyboardAction = new KeyboardAction(actionConfig, actionMap);
		input2Action.addKeyboard(keyboardAction);
		

		// -------- GAMEPAD -----------

		// event handler if a gamepad disconnects
		var onGamepadDisconnect = function(gamepad:Gamepad) {
			trace('Gamepad ${gamepad.id} disconnected');
			// remove gamepad and all its gamepadAction bindings
			input2Action.removeGamepad(gamepad);
		};

		// event handler for new plugged gamepads
		var onGamepadConnect = function(gamepad:Gamepad) {
			trace('Gamepad ${gamepad.id} connected');
			// set gamepad bindings
			var gamepadAction = new GamepadAction(gamepad.id, actionConfig, actionMap);
			input2Action.addGamepad(gamepad, gamepadAction);

			// disconnect handler have to be added per gamepad here
			gamepad.onDisconnect.add(onGamepadDisconnect.bind(gamepad));
		};

		Gamepad.onConnect.add(onGamepadConnect);

		// also call the onConnect handler one times to set up already connected gamepads
		for (gamepad in Gamepad.devices) onGamepadConnect(gamepad);

		
		// ---------------------------------------------------
		// -------------- start input2Action  ----------------
		// ---------------------------------------------------
		input2Action.enable();

		//input2Action.disable();
	}
	
	



	// ------------------------------------------------------------	
	// ------------------------------------------------------------	
	// ------------------------------------------------------------
	
	public override function render (context:RenderContext):Void 
	{
		switch (context.type) {
			case CAIRO:	var cairo = context.cairo; cairo.setSourceRGB (0.75, 1, 0);	cairo.paint ();
			case CANVAS: var ctx = context.canvas2D; ctx.fillStyle = "#BFFF00";	ctx.fillRect (0, 0, window.width, window.height);
			case DOM: var element = context.dom; element.style.backgroundColor = "#BFFF00";
			case FLASH: var sprite = context.flash; sprite.graphics.beginFill (0xBFFF00); sprite.graphics.drawRect (0, 0, window.width, window.height);
			case OPENGL, OPENGLES, WEBGL: var gl = context.webgl; gl.clearColor (0.75, 1, 0, 1); gl.clear (gl.COLOR_BUFFER_BIT);
			default:
		}
	}
	
	
}