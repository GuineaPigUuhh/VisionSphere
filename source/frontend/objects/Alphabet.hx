package frontend.objects;

import flixel.graphics.frames.FlxAtlasFrames;

enum Alignment
{
	LEFT;
	CENTERED;
	RIGHT;
}

class Alphabet extends FlxSpriteGroup
{
	public var text(default, set):String;
	public var menuType(default, set):String;
	
	public var bold:Bool = false;
	public var letters:Array<AlphaCharacter> = [];
	public var itemType:String = "";
	public var isMenuItem:Bool = false;
	public var isMenuItemCentered:Bool = false;
	public var targetY:Int = 0;
	public var targetX:Float = 0;
	public var changeX:Bool = true;
	public var changeY:Bool = true;
	public var disableX:Bool = false;
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var yMult:Float = 120;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var alignment(default, set):Alignment = LEFT;
	public var scaleX(default, set):Float = 1;
	public var scaleY(default, set):Float = 1;
	public var rows:Int = 0;
	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0);
	public var xTo:Int = 100;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = true)
	{
		super(x, y);

		this.startPosition.x = x;
		this.startPosition.y = y;
		this.bold = bold;
		this.text = text;
	}

	public function setAlignmentFromString(align:String)
	{
		switch (align.toLowerCase().trim())
		{
			case 'right':
				alignment = RIGHT;
			case 'center' | 'centered':
				alignment = CENTERED;
			default:
				alignment = LEFT;
		}
	}

	private function set_alignment(align:Alignment)
	{
		alignment = align;
		updateAlignment();
		return align;
	}

	private function updateAlignment()
	{
		for (letter in letters)
		{
			var newOffset:Float = 0;
			switch (alignment)
			{
				case CENTERED:
					newOffset = letter.rowWidth / 2;
				case RIGHT:
					newOffset = letter.rowWidth;
				default:
					newOffset = 0;
			}
	
			letter.offset.x -= letter.alignOffset;
			letter.offset.x += newOffset;
			letter.alignOffset = newOffset;
		}
	}

	private function set_text(newText:String)
	{
		newText = newText.replace('\\n', '\n');
		clearLetters();
		createLetters(newText);
		updateAlignment();
		this.text = newText;
		return newText;
	}

	public function clearLetters()
	{
		var i:Int = letters.length;
		while (i > 0)
		{
			--i;
			var letter:AlphaCharacter = letters[i];
			if (letter != null)
			{
				letter.kill();
				letters.remove(letter);
				letter.destroy();
			}
		}
		letters = [];
		rows = 0;
	}

	private function set_scaleX(value:Float)
	{
		if (value == scaleX) return value;

		scale.x = value;
		for (letter in letters)
		{
			if (letter != null)
			{
				letter.updateHitbox();
				var ratio:Float = (value / letter.spawnScale.x);
				letter.x = letter.spawnPos.x * ratio;
			}
		}
		scaleX = value;
		return value;
	}

	private function set_scaleY(value:Float)
	{
		if (value == scaleY) return value;

		scale.y = value;
		for (letter in letters)
		{
			if (letter != null)
			{
				letter.updateHitbox();
				letter.updateLetterOffset();
				var ratio:Float = (value / letter.spawnScale.y);
				letter.y = letter.spawnPos.y * ratio;
			}
		}
		scaleY = value;
		return value;
	}

	override function update(elapsed:Float)
	{
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		if (isMenuItem)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
			if (changeX)
				x = FlxMath.lerp(x, (targetY * distancePerItem.x) + startPosition.x, lerpVal);
			if (changeY)
				y = FlxMath.lerp(y, (targetY * 1.3 * distancePerItem.y) + startPosition.y, lerpVal);

			x = (!disableX) ? FlxMath.lerp(x, (targetY * 20) + 90, elapsed * 6) : FlxMath.lerp(x, xTo, elapsed * 6);

			if (isMenuItemCentered)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
				y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);
				if (forceX != Math.NEGATIVE_INFINITY) screenCenter(X); else screenCenter(X); // what??
			}

			switch (itemType)
			{
				case "Classic":
					y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.16);
					x = FlxMath.lerp(x, (targetY * 20) + 90, 0.16);
				case "Vertical":
					y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.5), 0.16);
					x = FlxMath.lerp(x, (targetY * 0) + 308, 0.16);
					x += targetX;
				case "C-Shape":
					y = FlxMath.lerp(y, (scaledY * 65) + (FlxG.height * 0.39), 0.16);
					x = FlxMath.lerp(x, Math.exp(scaledY * 0.8) * 70 + (FlxG.width * 0.1), 0.16);
					if (scaledY < 0)
						x = FlxMath.lerp(x, Math.exp(scaledY * -0.8) * 70 + (FlxG.width * 0.1), 0.16);
					if (x > FlxG.width + 30)
						x = FlxG.width + 30;
				case "D-Shape":
					y = FlxMath.lerp(y, (scaledY * 90) + (FlxG.height * 0.45), 0.16);
					x = FlxMath.lerp(x, Math.exp(scaledY * 0.8) * -70 + (FlxG.width * 0.35), 0.16);
					if (scaledY < 0)
						x = FlxMath.lerp(x, Math.exp(scaledY * -0.8) * -70 + (FlxG.width * 0.35), 0.16);
					if (x < -900)
						x = -900;
			}
		}
		super.update(elapsed);
	}

	public function snapToPosition()
	{
		if (isMenuItem)
		{
			if (changeX)
				x = (targetY * distancePerItem.x) + startPosition.x;
			if (changeY)
				y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
		}
	}

	private static var Y_PER_ROW:Float = 85;

	private function createLetters(newText:String)
	{
		var consecutiveSpaces:Int = 0;

		var xPos:Float = 0;
		var rowData:Array<Float> = [];
		rows = 0;
		for (character in newText.split(''))
		{
			if (character != '\n')
			{
				var spaceChar:Bool = (character == " " || (bold && character == "_"));
				if (spaceChar) consecutiveSpaces++;

				var isAlphabet:Bool = AlphaCharacter.isTypeAlphabet(character.toLowerCase());
				if (AlphaCharacter.allLetters.exists(character.toLowerCase()) && (!bold || !spaceChar))
				{
					if (consecutiveSpaces > 0)
					{
						xPos += 28 * consecutiveSpaces * scaleX;
						if (!bold && xPos >= FlxG.width * 0.65)
						{
							xPos = 0;
							rows++;
						}
					}
					consecutiveSpaces = 0;

					var letter:AlphaCharacter = new AlphaCharacter(xPos, rows * Y_PER_ROW * scaleY, character, bold, this);
					letter.x += letter.letterOffset[0] * scaleX;
					letter.y -= letter.letterOffset[1] * scaleY;
					letter.row = rows;

					var off:Float = 0;
					if (!bold) off = 2;
					xPos += letter.width + (letter.letterOffset[0] + off) * scaleX;
					rowData[rows] = xPos;

					add(letter);
					letters.push(letter);
				}
			}
			else
			{
				xPos = 0;
				rows++;
			}
		}

		for (letter in letters)
		{
			letter.spawnPos.set(letter.x, letter.y);
			letter.spawnScale.set(scaleX, scaleY);
			letter.rowWidth = rowData[letter.row];
		}

		if (letters.length > 0) rows++;
	}

	inline function set_menuType(value:String)
	{
		if (value == 'Centered')
			screenCenter(X);

		menuType = value;
		return value;
	}
}

typedef Letter = {
	?anim:Null<String>,
	?offsets:Array<Float>,
	?offsetsBold:Array<Float>
}

class AlphaCharacter extends FlxSprite
{
	public var image(default, set):String;

	public static var allLetters:Map<String, Null<Letter>> = [
		'a'  => null, 'b'  => null, 'c'  => null, 'd'  => null, 'e'  => null, 'f'  => null,
		'g'  => null, 'h'  => null, 'i'  => null, 'j'  => null, 'k'  => null, 'l'  => null,
		'm'  => null, 'n'  => null, 'o'  => null, 'p'  => null, 'q'  => null, 'r'  => null,
		's'  => null, 't'  => null, 'u'  => null, 'v'  => null, 'w'  => null, 'x'  => null,
		'y'  => null, 'z'  => null,

		'á'  => null, 'é'  => null, 'í'  => null, 'ó'  => null, 'ú'  => null,
		'à'  => null, 'è'  => null, 'ì'  => null, 'ò'  => null, 'ù'  => null,
		'â'  => null, 'ê'  => null, 'î'  => null, 'ô'  => null, 'û'  => null,
		'ã'  => null, 'ë'  => null, 'ï'  => null, 'õ'  => null, 'ü'  => null,
		'ä'  => null, 'ö'  => null, 'å'  => null, 'ø'  => null, 'æ'  => null,
		'ñ'  => null, 'ç'  => {offsetsBold: [0, -11]}, 'š'  => null, 'ž'  => null, 'ý'  => null, 'ÿ'  => null,
		'ß'  => null,
		
		'0'  => null, '1'  => null, '2'  => null, '3'  => null, '4'  => null,
		'5'  => null, '6'  => null, '7'  => null, '8'  => null, '9'  => null,

		'&'  => {offsetsBold: [0, 2]},
		'('  => {offsetsBold: [0, 5]},
		')'  => {offsetsBold: [0, 5]},
		'*'  => {offsets: [0, 28], offsetsBold: [0, 40]},
		'+'  => {offsets: [0, 7], offsetsBold: [0, 12]},
		'-'  => {offsets: [0, 16], offsetsBold: [0, 30]},
		'<'  => {offsetsBold: [0, -2]},
		'>'  => {offsetsBold: [0, -2]},
		'\'' => {anim: 'apostrophe', offsets: [0, 32], offsetsBold: [0, 40]},
		'"'  => {anim: 'quote', offsets: [0, 32], offsetsBold: [0, 40]},
		'!'  => {anim: 'exclamation'},
		'?'  => {anim: 'question'},
		'.'  => {anim: 'period'},
		'❝'  => {anim: 'start quote', offsets: [0, 24], offsetsBold: [0, 40]},
		'❞'  => {anim: 'end quote', offsets: [0, 24], offsetsBold: [0, 40]},
		'_'  => null,
		'#'  => null,
		'$'  => null,
		'%'  => null,
		':'  => {offsets: [0, 2], offsetsBold: [0, 8]},
		';'  => {offsets: [0, -2], offsetsBold: [0, 4]},
		'@'  => null,
		'['  => null,
		']'  => {offsets: [0, -1]},
		'^'  => {offsets: [0, 28], offsetsBold: [0, 38]},
		','  => {anim: 'comma', offsets: [0, -6], offsetsBold: [0, -4]},
		'\\' => {anim: 'back slash', offsets: [0, 0]},
		'/'  => {anim: 'forward slash', offsets: [0, 0]},
		'|'  => null,
		'~'  => {offsets: [0, 16], offsetsBold: [0, 20]},
		'¡'  => {anim: 'inverted exclamation', offsets: [0, -20], offsetsBold: [0, -20]},
		'¿'  => {anim: 'inverted question', offsets: [0, -20], offsetsBold: [0, -20]},
		'{'  => null,
		'}'  => null,
		'•'  => {anim: 'bullet', offsets: [0, 18], offsetsBold: [0, 20]}
	];

	var parent:Alphabet;
	
	public var alignOffset:Float = 0;
	public var letterOffset:Array<Float> = [0, 0];
	public var spawnPos:FlxPoint = new FlxPoint();
	public var spawnScale:FlxPoint = new FlxPoint();

	public var row:Int = 0;
	public var rowWidth:Float = 0;
	public function new(x:Float, y:Float, character:String, bold:Bool, parent:Alphabet)
	{
		super(x, y);
		this.parent = parent;
		image = 'objects/alphabet';
		antialiasing = true;

		var curLetter:Letter = allLetters.get('?');
		var lowercase = character.toLowerCase();
		if (allLetters.exists(lowercase)) curLetter = allLetters.get(lowercase);

		var suffix:String = '';
		if (!bold)
		{
			if (isTypeAlphabet(lowercase))
				suffix = (lowercase != character) ? ' uppercase' : ' lowercase';
			else
			{
				suffix = ' normal';
				if (curLetter != null && curLetter.offsets != null)
				{
					letterOffset[0] = curLetter.offsets[0];
					letterOffset[1] = curLetter.offsets[1];
				}
			}
		}
		else
		{
			suffix = ' bold';
			if (curLetter != null && curLetter.offsetsBold != null)
			{
				letterOffset[0] = curLetter.offsetsBold[0];
				letterOffset[1] = curLetter.offsetsBold[1];
			}
		}

		var alphaAnim:String = lowercase;
		if (curLetter != null && curLetter.anim != null) alphaAnim = curLetter.anim;

		var anim:String = alphaAnim + suffix;
		animation.addByPrefix(anim, anim, 24);
		animation.play(anim, true);
		if (animation.curAnim == null)
		{
			if (suffix != ' bold') suffix = ' normal';
			anim = 'question' + suffix;
			animation.addByPrefix(anim, anim, 24);
			animation.play(anim, true);
		}
		updateHitbox();
		updateLetterOffset();
	}

	public static function isTypeAlphabet(c:String)
	{
		var ascii = StringTools.fastCodeAt(c, 0);
		return (ascii >= 65 && ascii <= 90)
			|| (ascii >= 97 && ascii <= 122)
			|| (ascii >= 192 && ascii <= 214)
			|| (ascii >= 216 && ascii <= 246)
			|| (ascii >= 248 && ascii <= 255);
	}

	private function set_image(name:String)
	{
		var lastAnim:String = null;
		if (animation != null)
			lastAnim = animation.name;

		image = name;
		frames = Paths.getSparrowAtlas(name);
		this.scale.x = parent.scaleX;
		this.scale.y = parent.scaleY;
		alignOffset = 0;
		
		if (lastAnim != null)
		{
			animation.addByPrefix(lastAnim, lastAnim, 24);
			animation.play(lastAnim, true);
			
			updateHitbox();
			updateLetterOffset();
		}
		return name;
	}

	public function updateLetterOffset()
	{
		if (animation.curAnim == null) return;
		offset.y += (!animation.curAnim.name.endsWith('bold')) ? -(110 - height) : -(70 - height);
	}
}