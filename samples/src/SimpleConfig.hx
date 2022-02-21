package;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.Gamepad;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;
//import lime.ui.GamepadAxis;

import input2action.ActionConfig;
import input2action.Input2Action;


class SimpleConfig extends Application {
	
		
	public override function onWindowCreate ():Void 
	{
		//trace(lime.system.Locale.currentLocale.language);

		// bindings for keyboard and gamepad:
		var actionConfig:ActionConfig = [
			{	action: "menu",
				keyboard: [ KeyCode.ESCAPE ],
				gamepad: [ GamepadButton.BACK ]
			},
			{	action: "inventory",
				keyboard: [ KeyCode.I ],
				gamepad: [ GamepadButton.X ]
			},
			{	action: "enter",
				keyboard: [ KeyCode.RETURN, KeyCode.RETURN2, KeyCode.NUMPAD_ENTER],
				gamepad: [ GamepadButton.A ]
			},
			{	action: "fire",
				keyboard: [ KeyCode.SPACE, KeyCode.LEFT_CTRL, KeyCode.RIGHT_CTRL],
				gamepad: [ GamepadButton.LEFT_SHOULDER, GamepadButton.RIGHT_SHOULDER ]
			},
			{	action: "moveUp",
				keyboard: [ KeyCode.W, KeyCode.UP],
				gamepad: [ GamepadButton.DPAD_UP ]
			},
			{	action: "moveDown",
				keyboard: [ KeyCode.S, KeyCode.DOWN],
				gamepad: [ GamepadButton.DPAD_DOWN ]
			},
			{	action: "moveLeft",
				keyboard: [ KeyCode.A, KeyCode.LEFT],
				gamepad: [ GamepadButton.DPAD_LEFT ]
			},
			{	action: "moveRight",
				keyboard: [ KeyCode.D, KeyCode.RIGHT],
				gamepad: [ GamepadButton.DPAD_RIGHT ]
			},
		];
		
		// contains the actions and mappings to the action-identifiers
		var application = new Action();
		
		var input2Action = new Input2Action(actionConfig, application.actionMap);
		
		// set keyboard bindings
		input2Action.setKeyboard();
		
		// event handler for new plugged gamepads
		input2Action.onGamepadConnect = function(gamepad:Gamepad) {
		    input2Action.setGamepad(gamepad);
		}

		input2Action.onGamepadDisconnect = function(gamepad:Gamepad, player:Int) {
		    input2Action.removeGamepad(gamepad);
		}
		
		
		//trace(actionConfig.toJson);
		
		
		input2Action.enable(window);
		//input2Action.disable(window);

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