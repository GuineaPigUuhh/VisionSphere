package states;

import flixel.ui.FlxButton;

class ModsState extends FlxState
{
	static var changedAThing:Bool = false;
	
	var mods:Array<ModMetadata> = [];
	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;
	
	var noModsTxt:FlxText;
	var selector:AttachedSprite;
	var descriptionTxt:FlxText;
	var needaReset:Bool = false;
	var curSelected:Int = 0;

	public static var defaultColor:FlxColor = 0xFFea71fd;

	var buttonDown:FlxButton;
	var buttonTop:FlxButton;
	var buttonDisableAll:FlxButton;
	var buttonEnableAll:FlxButton;
	var buttonUp:FlxButton;
	var buttonToggle:FlxButton;
	var buttonsArray:Array<FlxButton> = [];

	var modsList:Array<Dynamic> = [];

	var visibleWhenNoMods:Array<FlxBasic> = [];
	var visibleWhenHasMods:Array<FlxBasic> = [];

	override function create()
	{
		bg = new FlxSprite().loadGraphic(Paths.image('menu/desatBG'));
		add(bg);

		noModsTxt = new FlxText(0, 0, FlxG.width, "NO MODS INSTALLED\nPRESS BACK TO EXIT AND INSTALL A MOD\n...OR PRESS 7 TO ACCESS THE MOD SETUP MENU", 48);
		noModsTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noModsTxt.scrollFactor.set();
		noModsTxt.borderSize = 2;
		add(noModsTxt);
		noModsTxt.screenCenter();
		visibleWhenNoMods.push(noModsTxt);

		if (FlxG.random.bool(35)) // this is fake okay
			noModsTxt.text += "\n\nBY THE WAY, " 
				+ FlxG.random.int(0, 255) + "." + FlxG.random.int(0, 255) + "." + FlxG.random.int(0, 255) + "." + FlxG.random.int(0, 255);

		var path:String = 'modsList.txt';
		if (FileSystem.exists(path))
		{
			var leMods:Array<String> = CoolUtil.getText(path);
			for (i in 0...leMods.length)
			{
				if (leMods.length > 1 && leMods[0].length > 0) {
					var modSplit:Array<String> = leMods[i].split('|');
					if (!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()))
						addToModsList([modSplit[0], (modSplit[1] == '1')]);
				}
			}
		}

		if (FileSystem.exists("modsList.txt")) 
		{
			for (folder in Paths.getModDirectories())
				if (!Paths.ignoreModFolders.contains(folder))
					addToModsList([folder, true]);
		}
		saveTxt();

		selector = new AttachedSprite();
		selector.xAdd = -205;
		selector.yAdd = -68;
		selector.alphaMult = 0.5;
		makeSelectorGraphic();
		add(selector);
		visibleWhenHasMods.push(selector);

		var startX:Int = 1120;

		buttonToggle = new FlxButton(startX, 0, "ON", () ->
		{
			if (mods[curSelected].restart)
				needaReset = true;
			
			modsList[curSelected][1] = !modsList[curSelected][1];
			updateButtonToggle();
			FlxG.sound.play(Paths.sound('scroll'), 0.6);
		});
		buttonToggle.setGraphicSize(50, 50);
		buttonToggle.updateHitbox();
		add(buttonToggle);
		buttonsArray.push(buttonToggle);
		visibleWhenHasMods.push(buttonToggle);
		
		buttonToggle.label.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);
		setAllLabelsOffset(buttonToggle, -15, 10);
		startX -= 70;

		buttonUp = new FlxButton(startX, 0, "/\\", () ->
		{
			moveMod(-1);
			FlxG.sound.play(Paths.sound('scroll'), 0.6);
		});
		buttonUp.setGraphicSize(50, 50);
		buttonUp.updateHitbox();
		add(buttonUp);
		buttonsArray.push(buttonUp);
		visibleWhenHasMods.push(buttonUp);
		buttonUp.label.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK, CENTER);
		setAllLabelsOffset(buttonUp, -15, 10);
		startX -= 70;

		buttonDown = new FlxButton(startX, 0, "\\/", () -> {
			moveMod(1);
			FlxG.sound.play(Paths.sound('scroll'), 0.6);
		});
		buttonDown.setGraphicSize(50, 50);
		buttonDown.updateHitbox();
		add(buttonDown);
		buttonsArray.push(buttonDown);
		visibleWhenHasMods.push(buttonDown);
		buttonDown.label.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK, CENTER);
		setAllLabelsOffset(buttonDown, -15, 10);

		startX -= 100;
		buttonTop = new FlxButton(startX, 0, "TOP", () -> {
			var doRestart:Bool = (mods[0].restart || mods[curSelected].restart);
			for (i in 0...curSelected) 
				moveMod(-1, true);

			if (doRestart)
				needaReset = true;
			
			FlxG.sound.play(Paths.sound('scroll'), 0.6);
		});
		buttonTop.setGraphicSize(80, 50);
		buttonTop.updateHitbox();
		buttonTop.label.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK, CENTER);
		setAllLabelsOffset(buttonTop, 0, 10);
		add(buttonTop);
		buttonsArray.push(buttonTop);
		visibleWhenHasMods.push(buttonTop);
		
		startX -= 190;
		buttonDisableAll = new FlxButton(startX, 0, "DISABLE ALL", () -> {
			for (i in modsList)
				i[1] = false;
			
			for (mod in mods)
			{
				if (mod.restart)
				{
					needaReset = true;
					break;
				}
			}
			updateButtonToggle();
			FlxG.sound.play(Paths.sound('scroll'), 0.6);
		});
		buttonDisableAll.setGraphicSize(170, 50);
		buttonDisableAll.updateHitbox();
		buttonDisableAll.label.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK, CENTER);
		buttonDisableAll.label.fieldWidth = 170;
		setAllLabelsOffset(buttonDisableAll, 0, 10);
		add(buttonDisableAll);
		buttonsArray.push(buttonDisableAll);
		visibleWhenHasMods.push(buttonDisableAll);

		startX -= 190;
		buttonEnableAll = new FlxButton(startX, 0, "ENABLE ALL", () -> {
			for (i in modsList)
				i[1] = true;

			for (mod in mods)
			{
				if (mod.restart)
				{
					needaReset = true;
					break;
				}
			}
			updateButtonToggle();
			FlxG.sound.play(Paths.sound('scroll'), 0.6);
		});
		buttonEnableAll.setGraphicSize(170, 50);
		buttonEnableAll.updateHitbox();
		buttonEnableAll.label.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK, CENTER);
		buttonEnableAll.label.fieldWidth = 170;
		setAllLabelsOffset(buttonEnableAll, 0, 10);
		add(buttonEnableAll);
		buttonsArray.push(buttonEnableAll);
		visibleWhenHasMods.push(buttonEnableAll);

		var startX:Int = 1100;
		
		descriptionTxt = new FlxText(148, 0, FlxG.width - 216, "", 32);
		descriptionTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
		descriptionTxt.scrollFactor.set();
		add(descriptionTxt);
		visibleWhenHasMods.push(descriptionTxt);
		
		var i:Int = 0;
		var len:Int = modsList.length;
		while (i < modsList.length)
		{
			var values:Array<Dynamic> = modsList[i];
			if (!FileSystem.exists(Paths.mods(values[0])))
			{
				modsList.remove(modsList[i]);
				continue;
			}

			var newMod:ModMetadata = new ModMetadata(values[0]);
			mods.push(newMod);

			newMod.alphabet = new Alphabet(0, 0, mods[i].name, true);
			var scale:Float = Math.min(840 / newMod.alphabet.width, 1);
			newMod.alphabet.scaleX = scale;
			newMod.alphabet.scaleY = scale;
			newMod.alphabet.y = i * 150;
			newMod.alphabet.x = 310;
			add(newMod.alphabet);
			var loadedIcon:BitmapData = null;
			var iconToUse:String = Paths.mods(values[0] + '/pack.png');
			if (FileSystem.exists(iconToUse))
				loadedIcon = BitmapData.fromFile(iconToUse);

			newMod.icon = new AttachedSprite();
			if (loadedIcon != null)
			{
				newMod.icon.loadGraphic(loadedIcon, true, 150, 150);
				var totalFrames = Math.floor(loadedIcon.width / 150) * Math.floor(loadedIcon.height / 150);
				newMod.icon.animation.add("icon", [for (i in 0...totalFrames) i], 10);
				newMod.icon.animation.play("icon");
			}
			else
				newMod.icon.loadGraphic(Paths.image('unknownMod'));
			
			newMod.icon.sprTracker = newMod.alphabet;
			newMod.icon.xAdd = -newMod.icon.width - 30;
			newMod.icon.yAdd = -45;
			add(newMod.icon);
			i++;
		}
		
		if (curSelected >= mods.length) 
			curSelected = 0;

		bg.color = (mods.length < 1) ? defaultColor : mods[curSelected].color;
		intendedColor = bg.color;
		
		changeSelection();
		updatePosition();

		FlxG.sound.play(Paths.sound('scroll'));

		super.create();
	}

	function addToModsList(values:Array<Dynamic>)
	{
		for (i in 0...modsList.length)
			if (modsList[i][0] == values[0])
				return;
		
		modsList.push(values);
	}

	function updateButtonToggle()
	{
		buttonToggle.label.text = (modsList[curSelected][1]) ? 'ON' : 'OFF';
		buttonToggle.color = (modsList[curSelected][1]) ? FlxColor.GREEN : FlxColor.RED;
	}

	function moveMod(change:Int, skipResetCheck:Bool = false)
	{
		if (mods.length > 1)
		{
			var doRestart:Bool = (mods[0].restart);

			var newPos:Int = curSelected + change;
			if (newPos < 0)
			{
				modsList.push(modsList.shift());
				mods.push(mods.shift());
			}
			else if (newPos >= mods.length)
			{
				modsList.insert(0, modsList.pop());
				mods.insert(0, mods.pop());
			}
			else
			{
				var lastArray:Array<Dynamic> = modsList[curSelected];
				modsList[curSelected] = modsList[newPos];
				modsList[newPos] = lastArray;

				var lastMod:ModMetadata = mods[curSelected];
				mods[curSelected] = mods[newPos];
				mods[newPos] = lastMod;
			}
			changeSelection(change);

			if (!doRestart) doRestart = mods[curSelected].restart;
			if (!skipResetCheck && doRestart) needaReset = true;
		}
	}

	function saveTxt()
	{
		var fileStr:String = '';
		for (values in modsList)
		{
			if (fileStr.length > 0) fileStr += '\n';
			fileStr += values[0] + '|' + (values[1] ? '1' : '0');
		}

		var path:String = 'modsList.txt';
		File.saveContent(path, fileStr);

		Paths.pushGlobalMods();
	}

	var noModsSine:Float = 0;
	var canExit:Bool = true;
	override function update(elapsed:Float)
	{
		if (noModsTxt.visible)
		{
			noModsSine += 180 * elapsed;
			noModsTxt.alpha = 1 - Math.sin((Math.PI * noModsSine) / 180);
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

        var up = Input.is('up') || (gamepad != null ? Input.gamepadIs('gamepad_up') : false);
        var down = Input.is('down') || (gamepad != null ? Input.gamepadIs('gamepad_down') : false);
        var exit = Input.is('exit') || (gamepad != null ? Input.gamepadIs('gamepad_exit') : false);
		var setup = Input.is('seven') || (gamepad != null ? Input.gamepadIs('x') : false);

		if (canExit && exit)
		{
			if (colorTween != null)
				colorTween.cancel();
			
			saveTxt();
			FlxG.sound.play(Paths.sound('cancel'));

			if (needaReset)
				FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
			else
				FlxG.switchState(MenuState.new);
		}

		if (up || down)
			changeSelection(up ? -1 : 1);

		if (setup)
			FlxG.switchState(ModsSetupState.new);
		
		updatePosition(elapsed);
		super.update(elapsed);
	}

	function setAllLabelsOffset(button:FlxButton, x:Float, y:Float)
	{
		for (point in button.labelOffsets)
			point.set(x, y);
	}

	function changeSelection(change:Int = 0)
	{
		var noMods:Bool = (mods.length < 1);
		
		for (obj in visibleWhenHasMods)
			obj.visible = !noMods;
		
		for (obj in visibleWhenNoMods)
			obj.visible = noMods;
		
		if (noMods) return;

		curSelected = FlxMath.wrap(curSelected + change, 0, mods.length - 1);

		var newColor:Int = mods[curSelected].color;
		if (newColor != intendedColor) {
			if (colorTween != null)
				colorTween.cancel();
			
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: (twn:FlxTween) -> {
					colorTween = null;
				}
			});
		}
		
		var i:Int = 0;
		for (mod in mods)
		{
			mod.alphabet.alpha = 0.6;
			if (i == curSelected)
			{
				mod.alphabet.alpha = 1;
				selector.sprTracker = mod.alphabet;
				descriptionTxt.text = mod.description;
				if (mod.restart)
					descriptionTxt.text += " (This Mod will restart the game!)";

				var stuffArray:Array<FlxSprite> = [selector, descriptionTxt, mod.alphabet, mod.icon];
				for (obj in stuffArray)
				{
					remove(obj);
					insert(members.length, obj);
				}
				for (obj in buttonsArray)
				{
					remove(obj);
					insert(members.length, obj);
				}
			}
			i++;
		}
		updateButtonToggle();
	}

	function updatePosition(elapsed:Float = -1)
	{
		var i:Int = 0;
		for (mod in mods)
		{
			var intendedPos:Float = (i - curSelected) * 225 + 200;
			if (i > curSelected) intendedPos += 225;

			mod.alphabet.y = (elapsed == -1) ? intendedPos : FlxMath.lerp(mod.alphabet.y, intendedPos, CoolUtil.boundTo(elapsed * 12, 0, 1));

			if (i == curSelected)
			{
				descriptionTxt.y = mod.alphabet.y + 160;
				for (button in buttonsArray)
					button.y = mod.alphabet.y + 320;
			}
			i++;
		}
	}

	var cornerSize:Int = 11;
	function makeSelectorGraphic()
	{
		selector.makeGraphic(1100, 450, FlxColor.BLACK);
		selector.pixels.fillRect(new Rectangle(0, 190, selector.width, 5), 0x0);
		selector.pixels.fillRect(new Rectangle(0, 0, cornerSize, cornerSize), 0x0);
		drawCircleCornerOnSelector(false, false);
		selector.pixels.fillRect(new Rectangle(selector.width - cornerSize, 0, cornerSize, cornerSize), 0x0);
		drawCircleCornerOnSelector(true, false);
		selector.pixels.fillRect(new Rectangle(0, selector.height - cornerSize, cornerSize, cornerSize), 0x0);
		drawCircleCornerOnSelector(false, true);
		selector.pixels.fillRect(new Rectangle(selector.width - cornerSize, selector.height - cornerSize, cornerSize, cornerSize), 0x0);
		drawCircleCornerOnSelector(true, true);
	}

	function drawCircleCornerOnSelector(flipX:Bool, flipY:Bool)
	{
		var antiX:Float = (selector.width - cornerSize);
		var antiY:Float = flipY ? (selector.height - 1) : 0;
		if (flipY) antiY -= 2;
		selector.pixels.fillRect(new Rectangle((flipX ? antiX : 1), Std.int(Math.abs(antiY - 8)), 10, 3), FlxColor.BLACK);
		if (flipY) antiY++;
		selector.pixels.fillRect(new Rectangle((flipX ? antiX : 2), Std.int(Math.abs(antiY - 6)),  9, 2), FlxColor.BLACK);
		if (flipY) antiY++;
		selector.pixels.fillRect(new Rectangle((flipX ? antiX : 3), Std.int(Math.abs(antiY - 5)),  8, 1), FlxColor.BLACK);
		selector.pixels.fillRect(new Rectangle((flipX ? antiX : 4), Std.int(Math.abs(antiY - 4)),  7, 1), FlxColor.BLACK);
		selector.pixels.fillRect(new Rectangle((flipX ? antiX : 5), Std.int(Math.abs(antiY - 3)),  6, 1), FlxColor.BLACK);
		selector.pixels.fillRect(new Rectangle((flipX ? antiX : 6), Std.int(Math.abs(antiY - 2)),  5, 1), FlxColor.BLACK);
		selector.pixels.fillRect(new Rectangle((flipX ? antiX : 8), Std.int(Math.abs(antiY - 1)),  3, 1), FlxColor.BLACK);
	}
}

class ModMetadata
{
	public var folder:String;
	public var name:String;
	public var description:String;
	public var color:FlxColor;
	public var restart:Bool;
	public var alphabet:Alphabet;
	public var icon:AttachedSprite;

	public function new(folder:String)
	{
		this.folder = folder;
		this.name = folder;
		this.description = "No description provided.";
		this.color = ModsState.defaultColor;
		this.restart = false;
		
		var path = Paths.mods('$folder/pack.json');
		if (FileSystem.exists(path)) {
			var rawJson:String = File.getContent(path);
			if (rawJson != null && rawJson.length > 0) {
				var stuff:Dynamic = Json.parse(rawJson);
				var colors:Array<Int> = Reflect.getProperty(stuff, "color");
				var description:String = Reflect.getProperty(stuff, "description");
				var name:String = Reflect.getProperty(stuff, "name");
				var restart:Bool = Reflect.getProperty(stuff, "restart");
					
				if (name != null && name.length > 0)
					this.name = name;
				
				if (description != null && description.length > 0)
					this.description = description;
				
				if (name == 'Name')
					this.name = folder;
				
				if (description == 'Description')
					this.description = "No description provided.";
				
				if (colors != null && colors.length > 2)
					this.color = FlxColor.fromRGB(colors[0], colors[1], colors[2]);
				
				this.restart = restart;
			}
		}
	}
}