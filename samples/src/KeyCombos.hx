package;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.Gamepad;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;
//import lime.ui.GamepadAxis;

import input2action.ActionConfig;
import input2action.KeyboardAction;
import input2action.GamepadAction;
import input2action.Input2Action;


class KeyCombos extends Application {
			
	public override function onWindowCreate ():Void 
	{
		// bindings for keyboard and gamepad:
		var actionConfig:ActionConfig = 
		[
			{	action: "enter",
				
				// only trigger if pressed alone and not if there is also another key-combo action for this keys
				single:true,
				
				keyboard: KeyCode.RETURN,
				gamepad:  GamepadButton.LEFT_STICK
			},
			{	action: "modEnter",
			
				// key-combinations need to define allways as array inside array!
				keyboard: [
					[KeyCode.LEFT_SHIFT, KeyCode.RETURN],   // key-combo ("left shift" have to press first)
					[KeyCode.RIGHT_SHIFT, KeyCode.RETURN],  // key-combo ("right shift" have to press first)
					KeyCode.NUMPAD_ENTER, KeyCode.RETURN2   // additional single keys
			    ],				
				gamepad: [ 
					[GamepadButton.A, GamepadButton.LEFT_STICK],  // key-combo ("A" have to press first)
				    GamepadButton.RIGHT_STICK  // additional single key
				]
			},
			
			// -----------------------
			{	action: "fireLeft",
				single:true,
				keyboard: [ KeyCode.LEFT_CTRL, KeyCode.LEFT_ALT ],
				gamepad:  GamepadButton.LEFT_SHOULDER
			},
			{	action: "modXfireLeft", // TODO: reverseCombo:true, to add automatically reverse combination
				// key-combos
				keyboard: [ [KeyCode.X, KeyCode.LEFT_CTRL], [KeyCode.X, KeyCode.LEFT_ALT] ],
				gamepad:  [ [GamepadButton.X, GamepadButton.LEFT_SHOULDER ] ]
			},
			{	action: "modYfireLeft",
				// key-combos
				keyboard: [ [KeyCode.Y, KeyCode.LEFT_CTRL], [KeyCode.Y, KeyCode.LEFT_ALT] ],
				gamepad:  [ [GamepadButton.Y, GamepadButton.LEFT_SHOULDER ] ]
			},
			
			// -----------------------
			{	action: "fireRight",
				//single:true,
				keyboard: [ KeyCode.RIGHT_CTRL, KeyCode.SPACE ],
				gamepad:  GamepadButton.RIGHT_SHOULDER
			},
			{	action: "modXfireRight",
				// key-combos
				// single:true,
				keyboard: [ [KeyCode.X, KeyCode.RIGHT_CTRL], [KeyCode.X, KeyCode.SPACE] ],
				gamepad:  [ [GamepadButton.X, GamepadButton.RIGHT_SHOULDER ] ]
			},
			{	action: "modYfireRight",
				// key-combos
				single:true,
				keyboard: [ [KeyCode.Y, KeyCode.RIGHT_CTRL], [KeyCode.Y, KeyCode.SPACE] ],
				gamepad:  [ [GamepadButton.Y, GamepadButton.RIGHT_SHOULDER ] ]
			},
		];
				

		// init input2Action
		var input2Action = new Input2Action(window);
		
		// -------- KEYBOARD -----------

		// set keyboard bindings
		var keyboardAction = new KeyboardAction(actionConfig, new Action().actionMap);
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
			var gamepadAction = new GamepadAction(gamepad.id, actionConfig, new Action().actionMap);
			input2Action.addGamepad(gamepad, gamepadAction);

			// disconnect handler have to be added per gamepad here
			gamepad.onDisconnect.add(onGamepadDisconnect.bind(gamepad));
		};

		Gamepad.onConnect.add(onGamepadConnect);

		// also call the onConnect handler one times to set up already connected gamepads
		for (gamepad in Gamepad.devices) onGamepadConnect(gamepad);

		
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