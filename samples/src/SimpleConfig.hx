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


class SimpleConfig extends Application {
	
		
	public override function onWindowCreate ():Void 
	{
		//trace(lime.system.Locale.currentLocale.language);

		// bindings for keyboard and gamepad:
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