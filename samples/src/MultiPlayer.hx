package;

import haxe.ds.Vector;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.Gamepad;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;

import input2action.ActionConfig;
import input2action.ActionMap;
import input2action.Input2Action;
import input2action.KeyboardAction;
import input2action.GamepadAction;


class MultiPlayer extends Application {
	
	public override function onWindowCreate ():Void 
	{		
		
		// Player 0 bindings
		var actionConfigPlayer0:ActionConfig = [
			{	action: "inventory",
				keyboard: KeyCode.I,
				gamepad:  GamepadButton.A
			},
		];
		
		// Player 1 bindings
		var actionConfigPlayer1:ActionConfig = [
			{	action: "inventory",
				keyboard: KeyCode.TAB,
				gamepad:  GamepadButton.B
			},
		];

		// map to functions
		var actionMap:ActionMap = [
			"inventory" => { action:(_, player)->trace('inventory - player:$player') },
		];

		// init input2action
		var input2Action = new Input2Action(window);

		// -------- KEYBOARD -----------

		// set keyboard bindings for player 0
		var keyboardAction0 = new KeyboardAction(0, actionConfigPlayer0, actionMap);
		input2Action.addKeyboard(keyboardAction0);

		// set keyboard bindings for player 1
		var keyboardAction1 = new KeyboardAction(1, actionConfigPlayer1, actionMap);
		input2Action.addKeyboard(keyboardAction1);

		
		// -------- GAMEPAD -----------

		var gamepadAction0 = new GamepadAction(0, actionConfigPlayer0, actionMap);
		var gamepadAction1 = new GamepadAction(1, actionConfigPlayer1, actionMap);
		
		// for the first two connected gamepads
		for (gamepad in Gamepad.devices)
		{
			trace('found Gamepad ${gamepad.id}');
			
			if (gamepad.id==0) input2Action.addGamepad(gamepad, gamepadAction0);
			else if (gamepad.id==1) input2Action.addGamepad(gamepad, gamepadAction1);
		};

		
		input2Action.enable();
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