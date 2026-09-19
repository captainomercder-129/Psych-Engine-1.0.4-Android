package states;

import flixel.text.FlxInputText;
import haxe.Http;
import haxe.Json;
import backend.UserSession;

class LoginState extends MusicBeatState
{
static var SERVER_URL:String = "https://psych-nm.onrender.com";

var usernameInput:FlxInputText;
var passwordInput:FlxInputText;
var statusText:FlxText;
var isRegisterMode:Bool = false;
var isLoading:Bool = false;

var loginButton:FlxText;
var loginBtnBg:FlxSprite;
var switchModeText:FlxText;
var skipText:FlxText;

override function create()
{
super.create();
persistentUpdate = persistentDraw = true;

var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
add(bg);

var cardW:Int = 600;
var cardH:Int = 620;
var cardX:Float = (FlxG.width - cardW) / 2;
var cardY:Float = (FlxG.height - cardH) / 2;

var card:FlxSprite = new FlxSprite(cardX, cardY).makeGraphic(cardW, cardH, FlxColor.fromRGB(30, 20, 45));
add(card);

var titleText:FlxText = new FlxText(cardX, cardY + 30, cardW, "GIRIS YAPIN", 40);
titleText.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
add(titleText);

var subText:FlxText = new FlxText(cardX, cardY + 85, cardW, "Hesabina baglan", 20);
subText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.GRAY, CENTER);
add(subText);

var userLabel:FlxText = new FlxText(cardX + 50, cardY + 140, 500, "KULLANICI ADI", 16);
userLabel.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
add(userLabel);

usernameInput = new FlxInputText(Std.int(cardX + 50), Std.int(cardY + 165), 500, "", 20);
usernameInput.fieldBorderColor = FlxColor.WHITE;
usernameInput.backgroundColor = FlxColor.fromRGB(50, 40, 65);
add(usernameInput);

var passLabel:FlxText = new FlxText(cardX + 50, cardY + 220, 500, "SIFRE", 16);
passLabel.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
add(passLabel);

passwordInput = new FlxInputText(Std.int(cardX + 50), Std.int(cardY + 245), 500, "", 20);
passwordInput.fieldBorderColor = FlxColor.WHITE;
passwordInput.backgroundColor = FlxColor.fromRGB(50, 40, 65);
passwordInput.passwordMode = true;
add(passwordInput);

loginBtnBg = new FlxSprite(cardX + 50, cardY + 310).makeGraphic(500, 60, FlxColor.fromRGB(120, 80, 200));
add(loginBtnBg);

loginButton = new FlxText(cardX + 50, cardY + 328, 500, "GIRIS YAP", 28);
loginButton.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
add(loginButton);

statusText = new FlxText(cardX, cardY + 390, cardW, "", 18);
statusText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.RED, CENTER);
add(statusText);

switchModeText = new FlxText(cardX, cardY + 440, cardW, "Hesabin yok mu? Kayit ol", 20);
switchModeText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.fromRGB(180, 130, 255), CENTER);
add(switchModeText);

skipText = new FlxText(cardX, cardY + 490, cardW, "Atla", 20);
skipText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.GRAY, CENTER);
add(skipText);

addTouchPad("NONE", "NONE");
}

function isTouched(obj:FlxObject):Bool
{
if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(obj))
return true;
for (touch in FlxG.touches.list)
if(touch.justPressed && touch.overlaps(obj))
return true;
return false;
}

override function update(elapsed:Float)
{
super.update(elapsed);

if(isLoading) return;

if(isTouched(loginBtnBg) || isTouched(loginButton))
{
doSubmit();
}
else if(isTouched(switchModeText))
{
isRegisterMode = !isRegisterMode;
loginButton.text = isRegisterMode ? "KAYIT OL" : "GIRIS YAP";
switchModeText.text = isRegisterMode ? "Hesabin var mi? Giris yap" : "Hesabin yok mu? Kayit ol";
statusText.text = "";
FlxG.sound.play(Paths.sound("scrollMenu"));
}
else if(isTouched(skipText) || controls.BACK)
{
FlxG.sound.play(Paths.sound("cancelMenu"));
MusicBeatState.switchState(new MainMenuState());
}
}

function doSubmit()
{
var username:String = usernameInput.text.trim();
var password:String = passwordInput.text.trim();

if(username.length < 1 || password.length < 1)
{
statusText.text = "Kullanici adi ve sifre gerekli!";
return;
}

isLoading = true;
statusText.color = FlxColor.WHITE;
statusText.text = "Yukleniyor...";

var endpoint:String = isRegisterMode ? "/register" : "/login";
var http:Http = new Http(SERVER_URL + endpoint);
http.setHeader("Content-Type", "application/json");
http.setPostData(Json.stringify({username: username, password: password}));

http.onData = function(data:String)
{
isLoading = false;
try
{
var res:Dynamic = Json.parse(data);
if(res.success == true)
{
UserSession.isLoggedIn = true;
UserSession.username = res.username;
UserSession.userId = res.user_id;
FlxG.sound.play(Paths.sound("confirmMenu"));
MusicBeatState.switchState(new MainMenuState());
}
else
{
statusText.color = FlxColor.RED;
statusText.text = (res.error != null) ? Std.string(res.error) : "Bir hata olustu";
}
}
catch(e:Dynamic)
{
statusText.color = FlxColor.RED;
statusText.text = "Sunucu hatasi";
}
}

http.onError = function(error:String)
{
isLoading = false;
statusText.color = FlxColor.RED;
statusText.text = "Baglanti hatasi: " + error;
}

http.request(true);
}
}
