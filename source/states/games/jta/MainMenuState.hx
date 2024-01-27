package states.games.jta;

class MainMenuState extends FlxState
{
    var logo:FlxSprite;

    // not making a FlxTypedGroup because it wont work!!!
    var playBtn:FlxSprite;
    var exitBtn:FlxSprite;

    override public function create()
    {
        super.create();

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('game/jta/bgMain'));
        bg.screenCenter();
        add(bg);

        logo = new FlxSprite(0, 190).loadGraphic(Paths.image('game/jta/logo'));
        logo.screenCenter(X);
        logo.scale.set(1.6, 1.6);
        add(logo);

        playBtn = new FlxSprite().loadGraphic(Paths.image('game/jta/buttons'), true, 16, 16);
        playBtn.animation.add('playU', [0]); // unselected
        playBtn.animation.add('playS', [1]); // selected
        playBtn.animation.add('playP', [2]); // pressed
        playBtn.animation.play('playU');
        playBtn.scale.set(12, 12);
        playBtn.screenCenter();
        add(playBtn);

        logoTween();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.mouse.overlaps(playBtn))
        {
            if (FlxG.mouse.pressed)
            {
                playBtn.animation.play('playP');
                FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
                {
                    FlxG.switchState(new states.games.jta.PlayState());
                });
            }
            else
                playBtn.animation.play('playS');
        }

        if (Input.is('exit'))
        {
            FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
            {
                FlxG.switchState(new states.MenuState());
            });
        }
    }

    private function logoTween()
    {
        logo.angle = -4;

        new FlxTimer().start(0.01, function(tmr:FlxTimer) 
        {
            if (logo.angle == -4)
                FlxTween.angle(logo, logo.angle, 4, 4, {ease: FlxEase.quartInOut});
            if (logo.angle == 4)
                FlxTween.angle(logo, logo.angle, -4, 4, {ease: FlxEase.quartInOut});
        }, 0);
    }
}