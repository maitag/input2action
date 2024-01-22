# input2action
haxe library to easy handle configuration and bingings of keyboard/gamepad-buttons to haxe-calls


## Features

- define the input-device-bindings inside of haxe or load/save as json-format
- handle key/button down-events and optional up-events
- let define multiple keys for one action over cross devices
- key-combinations: press 2 keys in order to trigger an action
- let use default repeat-rate/delay for keyboard or use custom ones
- handle multiple params (e.g. let share 1 keyboard or gamepad for 2 player-params)


## Dependencies

- haxelime
- json2object


## Synopsis

```haxe
// bindings for keyboard and gamepad:
var actionConfig:ActionConfig = [
	{	action: "moveLeft",
		keyboard: [ KeyCode.A, KeyCode.LEFT],
		gamepad:  [ GamepadButton.DPAD_LEFT ]
	},
	{	action: "moveRight",
		keyboard: [ KeyCode.D, KeyCode.RIGHT],
		gamepad:  [ GamepadButton.DPAD_RIGHT ]
	},
	{	action: "fire",
		keyboard: [ KeyCode.LEFT_CTRL, KeyCode.RIGHT_CTRL ],
		gamepad:  [ GamepadButton.LEFT_SHOULDER ]
	}
];

// show how it would look into json-format
trace(actionConfig.toJson);


// contains the actions and mappings to functionpointers
var actionMap:ActionMap = [
	"moveLeft"  => { action:moveLeft , up:true },
	"moveRight" => { action:moveRight, up:true },
	"fire"  => { action:fire }		
];


// functions to call
function moveLeft(isDown:Bool, param:Int) {
	trace('moveLeft - ${(isDown) ? "DOWN" : "UP"}, param:$param');
}

function moveRight(isDown:Bool, param:Int) {
	trace('moveRight - ${(isDown) ? "DOWN" : "UP"}, param:$param');
}

function fire(isDown:Bool, param:Int) {
	trace('fire - ${(isDown) ? "DOWN" : "UP"}, param:$param');
}


// init with the lime window object to set up keyboard up/down handlers
var input2Action = new Input2Action(window);

// set keyboard bindings
var keyboardAction = new KeyboardAction(actionConfig, actionMap);

// add it to input2action
input2Action.addKeyboard(keyboardAction);

// start
input2Action.enable();
```

Please look into the samples-folder to see all more options for different usecases.


## TODO

- let change the param-Type by compiler-define (or by macro)
- more documentation
- let capture the input for an action to let easy change the configuration at runtime
- more optimization by defines (e.g. if only using one inputActions per device)
