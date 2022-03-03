package input2action;
import json2object.*;
import input2action.ActionConfig;
import input2action.Input2Action;
import input2action.util.NestedArray;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;

@:forward
abstract JsonConfig(Array<JsonConfigItem>) from Array<JsonConfigItem> to Array<JsonConfigItem>
{
	// from json string
	public inline function new() {
		this = new Array<JsonConfigItem>();
	}
	
	static var rComments    = new EReg("//.*?$", "gm");
	static var rItemEnd     = new EReg(",\\s*\\}", "gm");
	static var rListItemEnd = new EReg(",\\s*\\]", "gm");

	static public inline function fromString(jsonString:String, filename:String = ""):JsonConfig {
		jsonString = rComments.replace(jsonString, "");
		jsonString = rItemEnd.replace(jsonString, "}");
		jsonString = rListItemEnd.replace(jsonString, "]");
		
		var parser = new json2object.JsonParser<JsonConfig>();
		parser.fromJson(jsonString, filename); // filename is specified for errors management
		
		for (e in parser.errors) {
			var pos = switch (e) {case IncorrectType(_, _, pos) | IncorrectEnumValue(_, _, pos) | InvalidEnumConstructor(_, _, pos) | UninitializedVariable(_, pos) | UnknownVariable(_, pos) | ParserError(_, pos) | CustomFunctionException(_, pos): pos;}
			trace(pos.lines[0].number);
			if (pos != null) haxe.Log.trace(json2object.ErrorUtils.convertError(e), {fileName:pos.file, lineNumber:pos.lines[0].number,className:"",methodName:""});
		}
		
		return parser.value;
	}

	@:from
	static inline function _fromString(jsonString:String):JsonConfig {
		return fromString(jsonString);
	}

	static var rDefaultSingle = new EReg('"single"\\s*:\\s*false\\s*,?\\s*', "gm");
	static var rDefaultKeyboard = new EReg('"keyboard"\\s*:\\s*null\\s*,?\\s*', "gm");
	static var rDefaultGamepad = new EReg('"gamepad"\\s*:\\s*null\\s*,?\\s*', "gm");
	static var rDefaultJoystick = new EReg('"joystick"\\s*:\\s*null\\s*,?\\s*', "gm");
	
	// to json string
	@:to
	public inline function toString():String {
		var writer = new JsonWriter<JsonConfig>();
		var jsonString = writer.write(this, "  ");
		jsonString = rDefaultSingle.replace(jsonString, "");
		jsonString = rDefaultKeyboard.replace(jsonString, "");
		jsonString = rDefaultGamepad.replace(jsonString, "");
		jsonString = rDefaultJoystick.replace(jsonString, "");
		jsonString = rItemEnd.replace(jsonString, "\n  }");
		jsonString = rListItemEnd.replace(jsonString, "\n]");
		return jsonString;
	}
	
	// from ActionConfig
	static public inline function fromActionConfig(actionConfig:ActionConfig):JsonConfig {
		var jsonConfig = new JsonConfig();
		
		for (a in actionConfig) {
			jsonConfig.push({
					action : a.action,
					single : a.single,
					keyboard: (a.keyboard == null) ? null :
						[for (keys in a.keyboard) (keys.length == 1) ? Input2Action.keyCodeName.get(keys[0]) :// TODO: check valid key!
							"[" +Input2Action.keyCodeName.get(keys[0]) + ", " + Input2Action.keyCodeName.get(keys[1]) + "]" // TODO: check valid key!
						].join(", "),
					gamepad: (a.gamepad == null) ? null :
						[for (keys in a.gamepad) (keys.length == 1) ? Input2Action.gamepadButtonName.get(keys[0]) :// TODO: check valid key!
							"[" +Input2Action.gamepadButtonName.get(keys[0]) + ", " + Input2Action.gamepadButtonName.get(keys[1]) + "]" // TODO: check valid key!
						].join(", "),
					joystick : null, // TODO
			});
		}
		
		return jsonConfig;
	}

	static var rSpaces   = new EReg('\\s*', "g");
	static var rKeyCombo = new EReg('^\\[(.*?)\\],?', "m");
	static var rKeyEntry = new EReg('^(\\w+),?', "m");
	
	// to ActionConfig
	public function toActionConfig():ActionConfig {
		var actionConfig:ActionConfig = [];// new ActionConfig();
		for (j in this) {
			
			var keyboard:NestedArray<KeyCode> = [];
			if (j.keyboard != null) {
				var s = rSpaces.replace(j.keyboard,"");
				while (s.length > 0) {
					if (rKeyCombo.match(s)) {
						keyboard.push( [for (i in rKeyCombo.matched(1).split(",")) Input2Action.keyCodeValue.get(i) ] );// TODO: check valid key!
						s = rKeyCombo.replace(s, "");
					}
					else if (rKeyEntry.match(s)) {
						keyboard.push( [Input2Action.keyCodeValue.get(rKeyEntry.matched(1))] ); // TODO: check valid key!
						s = rKeyEntry.replace(s, "");
					}
					else break; // TODO: throw error
				}	
			}	
			
			var gamepad:NestedArray<GamepadButton> = [];
			if (j.gamepad != null) {
				var s = rSpaces.replace(j.gamepad,"");
				while (s.length > 0) {
					if (rKeyCombo.match(s)) {
						gamepad.push( [for (i in rKeyCombo.matched(1).split(",")) Input2Action.gamepadButtonValue.get(i) ] );// TODO: check valid key!
						s = rKeyCombo.replace(s, "");
					}
					else if (rKeyEntry.match(s)) {
						gamepad.push( [Input2Action.gamepadButtonValue.get(rKeyEntry.matched(1))] ); // TODO: check valid key!
						s = rKeyEntry.replace(s, "");
					}
					else break; // TODO: throw error
				}	
			}	
			
			actionConfig.push({
					action : j.action,
					single : j.single,
					keyboard : (keyboard.length > 0) ? keyboard : null,
					gamepad  : (gamepad.length > 0) ? gamepad : null,
					joystick : null, // TODO
			});
		}
		return actionConfig;
	}

	
}

@:structInit
class JsonConfigItem {
	public var action:String;
	
	@:optional @:default(false) public var single:Null<Bool> = false;
	
	@:optional @:default(null) public var keyboard:String = null;
	@:optional @:default(null) public var gamepad :String = null;
	@:optional @:default(null) public var joystick:String = null;		
}

		
		
	
	
	