# input2action
haxe library to configure and handle keyboard, gamepad and joystick input

This lib let you easy bind haxe functions to input-events from keyboard, gamepad or joystick devices.


## Dependencies

- haxelime
- json2object

## Features

- define the input-device-bindings inside of haxe or load/save as json-format
- handle key/button down-events and optional up-events
- key-combinations: press 2 keys in order to trigger an action
- multiple keys for one action over cross devices
- let use default repeat-rate/delay for keyboard or use custom ones
- handle multiple players (e.g. let share 1 keyboard or gamepad for 2 players)


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
function moveLeft(isDown:Bool, player:Int) {
	trace('moveLeft - ${(isDown) ? "DOWN" : "UP"}, player:$player');
}

function moveRight(isDown:Bool, player:Int) {
	trace('moveRight - ${(isDown) ? "DOWN" : "UP"}, player:$player');
}

function fire(isDown:Bool, player:Int) {
	trace('fire - ${(isDown) ? "DOWN" : "UP"}, player:$player');
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


## TODO

- more documentation
- handle axis-mode of gamepad or joysticks, let also define additional "keys" for axis-direction
- let capture input for an action to change config at runtime
- more optimization by defines (e.g. if only using one inputActions per device)
