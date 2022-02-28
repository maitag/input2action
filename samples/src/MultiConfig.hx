package;

import haxe.ds.Vector;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.Gamepad;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;
//import lime.ui.GamepadAxis;

import input2action.ActionConfig;
import input2action.Input2Action;


class MultiConfig extends Application {
	
	public var availableGamepad:Vector<Gamepad>;
	public var maxPlayer = 8;
		
	public override function onWindowCreate ():Void 
	{		
		// default
		var actionConfigDefaults:ActionConfig = [
			{	action: "inventory",
				keyboard: KeyCode.I,
				gamepad:  GamepadButton.A
			},
		];
		
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
		
		availableGamepad = new Vector<Gamepad>(maxPlayer);
		
		// contains the actions and mappings to the action-identifiers
		var application = new Action();
		
		var input2Action = new Input2Action(actionConfigDefaults, application.actionMap);
		// TODO:
		//var maxPlayer = 8;
		//var input2Action = new Input2Action( maxPlayer, actionMapKey, actionMapAxis , actionConfigDefault, dontConnectDevicesByDefault);
		
		// set keyboard bindings for player 0
		input2Action.setKeyboard(0, actionConfigPlayer0);
		
		// set keyboard bindings for player 1
		input2Action.setKeyboard(1, actionConfigPlayer1);
		
		// event handler for new plugged gamepads
		input2Action.onGamepadConnect = function(gamepad:Gamepad) 
		{
			// check for available players
		    var newPlayer:Null<Int> = null;
			for (i in 0...maxPlayer) {
				if (availableGamepad.get(i) == null) {
					availableGamepad.set(i, gamepad);
					newPlayer = i;
					break;
				}
			}
			
		    // set gamepad if there is a free player
			if (newPlayer != null) {
				trace('set ${gamepad.id} to player $newPlayer');
				input2Action.setGamepad(newPlayer, gamepad, actionConfigPlayer1);
			}
		}

		input2Action.onGamepadDisconnect = function(player:Int) {
			trace('players $player gamepad disconnected');
			availableGamepad.set(player, null);
			
			// this will be called automatically:
			//input2Action.removeGamepad(player);
		}
		
				
		// TODO
		//input2Action.setJoystick(2, joystick, actionConfig2);

		// set keyboard, gamepad and joystick bindings for player 0
		// input2Action.set(0, actionConfig0, gamepad, joystick);
		
		// swap input of player 0 and player 1
		// input2Action.swap(0, 1)
		
		// disable and enable input of player 1
		//input2Action.disable(1);
		//input2Action.enable(1);
		

		
		
		
		// TODO: save the modified config into json
		
		
		input2Action.enable(window);
		//input2Action.disable(window);

	}
	
	
	// ------------------------------------------------------------	
	// -------------------- Actions -------------------------------	
	// ------------------------------------------------------------
	
	function action1(isDown:Bool, player:Int) 
	{
		trace('action 1 - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function action2(isDown:Bool, player:Int) 
	{
		trace('action 2 - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function action3(isDown:Bool, player:Int) 
	{
		trace('action 3 - ${(isDown) ? "DOWN" : "UP"}, player:$player');
	}
	
	function switchFullscreen(isUp:Bool, player:Int) {
		window.fullscreen = !window.fullscreen;
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