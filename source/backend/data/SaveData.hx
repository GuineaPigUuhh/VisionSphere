package backend.data;

// i could have used enumerators, but i wanna keep it simple!
@:structInit class SaveSettings {
	public var timeFormat:String = '%r';
	public var theme:String = 'daylight';
	public var lang:String = 'en';
	public var username:String = 'user';
	public var profile:String = 'blue';
	public var framerate:Int = 60;
	public var colorBlindFilter:Int = -1;
	public var fpsCounter:Bool = true;
	#if desktop
	public var fullscreen:Bool = false;
	#end
	public var keyboardBinds:Array<FlxKey> = [LEFT, DOWN, UP, RIGHT, ENTER, ESCAPE];
	public var gamepadBinds:Array<FlxGamepadInputID> = [DPAD_LEFT, DPAD_DOWN, DPAD_UP, DPAD_RIGHT, A, B];
}

class SaveData {
	public static var settings:SaveSettings = {};

	public static function init() {
		for (key in Reflect.fields(settings))
			if (Reflect.field(FlxG.save.data, key) != null)
				Reflect.setField(settings, key, Reflect.field(FlxG.save.data, key));
		
		if (Main.fpsDisplay != null)
			Main.fpsDisplay.visible = settings.fpsCounter;
		
		Main.updateFramerate(settings.framerate);
	}

	public static function saveSettings() {
		for (key in Reflect.fields(settings))
			Reflect.setField(FlxG.save.data, key, Reflect.field(settings, key));

		FlxG.save.flush();

		trace('settings saved!');
	}
}