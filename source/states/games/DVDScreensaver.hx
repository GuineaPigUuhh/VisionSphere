package states.games;

class DVDScreensaver extends FlxState
{
    var dvdLogo:FlxSprite;

    var curColor:Int = 0;
    var colors = [
        [255, 255, 255],
        [128, 128, 128],
        [0, 128, 0],
        [0, 255, 0],
        [255, 255, 0],
        [255, 165, 0],
        [255, 0, 0],
        [128, 0, 128],
        [0, 0, 255],
        [139, 69, 19],
        [255, 192, 203],
        [255, 0, 255],
        [0, 255, 255]
    ];

    override public function create()
    {
        dvdLogo = new FlxSprite(0, 0).loadGraphic(Paths.image('game/dvd/dvd'));
        dvdLogo.setGraphicSize(200, 5);
        dvdLogo.scale.y = dvdLogo.scale.x;
        dvdLogo.updateHitbox();
        dvdLogo.velocity.set(135, 95);
        dvdLogo.setColorTransform(0, 0, 0, 1, 255, 255, 255);
        add(dvdLogo);

        FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

        super.create();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE) 
        {
            FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
            {
                FlxG.switchState(new states.MenuState());
            });
            FlxG.sound.play(Paths.sound('cancel'));
        }
        
        if (dvdLogo.x > FlxG.width - dvdLogo.width || dvdLogo.x < 0)
        {
            dvdLogo.velocity.x = -dvdLogo.velocity.x;
            switchColor();
        }

        if (dvdLogo.y > FlxG.height - dvdLogo.height || dvdLogo.y < 0)
        {
            dvdLogo.velocity.y = -dvdLogo.velocity.y;
            switchColor();
        }
    }

    private function switchColor()
    {
        curColor = (curColor + 1) % colors.length;
        dvdLogo.setColorTransform(0, 0, 0, 1, colors[curColor][0], colors[curColor][1], colors[curColor][2]);
    }
}