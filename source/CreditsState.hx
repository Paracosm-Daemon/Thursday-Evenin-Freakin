package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		var pisspoop:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			["Freakin' Crew"],
			["Crash",				"crash",			"Director/Animator/Artist",								"https://twitter.com/SUSCRASH",			"D7023D"],
			["Pandemonium",			"pandemonium",		"Main Programmer/Composer/Charter\n[ rawposter ]",		"https://twitter.com/Paracosm_Daemon",	"323547"],
			["ImCuriousYT",			"curious",			"Main Charter\n[ Gaming ]",								"https://twitter.com/ImCuriousYT2",		"83AEDA"],
			["Aadsta",				"aadsta",			"Composer\n[ Gaming ]",									"https://twitter.com/FullNameDeTrain",	"FC83C9"],
			["Danyiyar Gaming",		"daniyar",			"Rawposter Assets",										"https://twitter.com/GamingDaniyar",	"77ADFF"],
			[""],
			["Psych Engine Team"],
			["Shadow Mario",		"shadowmario",		"Main Programmer of Psych Engine",						"https://twitter.com/Shadow_Mario_",	"444444"],
			["RiverOaken",			"riveroaken",		"Main Artist/Animator of Psych Engine",					"https://twitter.com/river_oaken",		"C30085"],
			["bb-panzu",			"bb-panzu",			"Additional Programmer of Psych Engine",				"https://twitter.com/bbsub3",			"389A58"],
			[""],
			["Engine Contributors"],
			["shubs",				"shubs",			"New Input System Programmer",							"https://twitter.com/yoshubs",			"4494E6"],
			["SqirraRNG",			"gedehari",			"Chart Editor\"s Sound Waveform base",					"https://twitter.com/gedehari",			"FF9300"],
			["iFlicky",				"iflicky",			"Delay/Combo Menu Song Composer\nand Dialogue Sounds",	"https://twitter.com/flicky_i",			"C549DB"],
			["PolybiusProxy",		"polybiusproxy",	".MP4 Video Loader Extension",							"https://twitter.com/polybiusproxy",	"FFEAA6"],
			["Keoiki",				"keoiki",			"Note Splash Animations",								"https://twitter.com/Keoiki_",			"FFFFFF"],
			[""],
			["Funkin' Crew"],
			["ninjamuffin99",		"ninjamuffin99",	"Programmer of Friday Night Funkin'",					"https://twitter.com/ninja_muffin99",	"F73838"],
			["PhantomArcade",		"phantomarcade",	"Animator of Friday Night Funkin'",						"https://twitter.com/PhantomArcade3K",	"FFBB1B"],
			["evilsk8r",			"evilsk8r",			"Artist of Friday Night Funkin'",						"https://twitter.com/evilsk8r",			"53E52C"],
			["kawaisprite",			"kawaisprite",		"Composer of Friday Night Funkin'",						"https://twitter.com/kawaisprite",		"6475F3"]
		];

		for (i in pisspoop) creditsStuff.push(i);
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			optionText.yAdd -= 70;
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				var icon:AttachedSprite = new AttachedSprite("credits/" + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;

				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = "";

				if(curSelected == -1) curSelected = i;
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + (.5 * elapsed), .7);
		var delta:Int = CoolUtil.getDelta(controls.UI_DOWN_P, controls.UI_UP_P);

		if (delta != 0) changeSelection(delta);
		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound("cancelMenu"));
			MusicBeatState.switchState(new MainMenuState());
		}
		if(controls.ACCEPT) CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);
		do {
			curSelected = CoolUtil.repeat(curSelected, change, creditsStuff.length);
		} while(unselectableCheck(curSelected));

		var newColor:Int =  getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = creditsStuff[curSelected][2];
	}

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];

		if(!bgColor.startsWith("0x")) bgColor = '0xFF$bgColor';
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}