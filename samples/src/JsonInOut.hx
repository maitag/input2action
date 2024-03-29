package;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.Gamepad;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;
//import lime.ui.GamepadAxis;

import input2action.ActionConfig;
import input2action.JsonConfig;
import input2action.Input2Action;


class JsonInOut extends Application {
	
		
	public override function onWindowCreate():Void 
	{
		// bindings for keyboard and gamepad:
		var actionConfig:ActionConfig = [
			{	action: "menu",
				keyboard: KeyCode.ESCAPE,
				gamepad:  [ GamepadButton.BACK, GamepadButton.START ]
			},
			{	action: "inventory",
				keyboard: KeyCode.I,
				gamepad:  GamepadButton.A
			},
			{	action: "enter",
				single: true,
				keyboard: KeyCode.RETURN,
				gamepad:  [ GamepadButton.LEFT_STICK ]
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
		];
		
		trace("actionConfig:", actionConfig);

		// create an json formates string by actionConfig
		var jsonString = actionConfig.toJson();
		
		trace("actionConfig to json:", jsonString);
		
		// --------------------------------------------
		
		var jsonString = '[
			{	"action": "menu",
				"keyboard": "ESCAPE",
				"gamepad" : "BACK, START"
			},
			{	"action": "modEnter",
			
				// key-combinations need to define allways as array inside array!
				"keyboard": "[LEFT_SHIFT, RETURN], [RIGHT_SHIFT, RETURN], NUMPAD_ENTER, RETURN2",				
				"gamepad" : "[A, LEFT_STICK], RIGHT_STICK"
			},
		]';
		
		// create an actionConfig by json
		var actionConfig = ActionConfig.fromJson(jsonString, "test.json");

		trace("json to actionConfig:", actionConfig);

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