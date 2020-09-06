module source.app;

public import foxid;
import source.dasher;
import source.screen;
import source.faller;
import source.editor;

public import foxid.sdl;

public import jmisc;

import std.datetime.stopwatch;

version(unittest)
    import unit_threaded;

immutable g_stepSize = 24;
immutable g_screenCharW = 14;
immutable g_screenCharH = 12;

enum SpriteGraph {brick, mud, start, shut_door, bady_maker_left, up, left, down, right, aswitch, diamond_maker,
	diamond, rock, bady_maker_right, blow0, blow1, blow2, blow3, bady_vert, bady_hor, door_open, blow4, blow5, blow6, gap}

immutable SpriteNames = ["brick", "mud", "start", "shut_door", "bady_maker_left", "up", "left", "down", "right", "aswitch", "diamond_maker",
	"diamond", "rock", "bady_maker_right", "blow0", "blow1", "blow2", "blow3", "bady_vert", "bady_hor", "door_open", "blow4", "blow5", "blow6", "gap"];

Image[] g_spriteList;
Image[char] g_sprites;
string g_chars;

StopWatch g_sw;

/+
	Create our first scene
+/
final class RockDashScene : Scene
{
	private Font fontgame;
	
	this() @trusted {
		name = "RockDashScene";
		
		g_sw.start;

        g_spriteList = loader.load!ImageSurface("assets/rockdash5.png").image.strip(Vec(0,0), 24, 24).array;

        foreach(ref e; g_spriteList) {
            e.make();
        }

		g_chars = "BmSDl....sMdrR......o...g";

		with(SpriteGraph) {
			g_sprites['B'] = g_spriteList[brick];
			g_sprites['m'] = g_spriteList[mud];
			g_sprites['S'] = g_spriteList[start];
			g_sprites['D'] = g_spriteList[shut_door];
			g_sprites['l'] = g_spriteList[bady_maker_left];
			g_sprites['s'] = g_spriteList[aswitch];
			g_sprites['M'] = g_spriteList[diamond_maker];
			g_sprites['d'] = g_spriteList[diamond];
			g_sprites['r'] = g_spriteList[rock];
			g_sprites['R'] = g_spriteList[bady_maker_right];
			g_sprites['o'] = g_spriteList[door_open];
			//g_sprites['g'] = g_spriteList[gap];
		}
	}

	override void gameStart() @safe {
        auto fileName = "assets/screen.txt";
        import std.file, std.string;
        auto data = readText(fileName).split('\n');
        auto p = Vec(0,0);
        foreach(lineNum, line; data) {
            foreach(s; line) {
				putObj(s, p);
                p.x += g_stepSize;
            }
            p.x = 0;
            p.y += g_stepSize;
        }

		fontgame = loader.loadFont("assets/DejaVuSans.ttf",14);
		add(new Dasher());

/+
		add(new class Instance {
			override void init() @safe {
				name = "Hello, welcome to - Rock Dash!";
				depth = 10;
			}
			override void draw(Display graph) @safe {
				graph.drawText(name, fontgame, Color(255,180,0), Vec(0,12 * g_stepSize));
			}
		});
+/
		add(new Editor());
	}

	override void step() @trusted {
		SDL_Delay(100);
		/+
		if (g_sw.peek().total!"msecs" > 100) {
			g_sw.reset;
			g_sw.start;
		}
		+/
	}
} // final class RockDashScene : Scene

version(unittest) {
} else {
	int main(string[] args)
	{
		// game setup
		Game game = new Game(640, 480, "* Rock Dash *");
		window.background = Color(0,0,0);

		assert(initKeys, "keys setup failer..");

		import std.string;
 		mixin(trace("FOXID_VERSION FOXID_VERSION_STABLE".split));
		/+
			Add to the scene in the manager.
		+/
		sceneManager.add(new RockDashScene());

		/+
			We put the very first added scene active
		+/
		sceneManager.inbegin();

		game.handle();

		return 0;
	}
}

import foxid.core.collision;

Instance[] getInstanceArrayByMask(Vec pos,Shape shape) @safe {
	Instance temp = new Instance;
	temp.shape = shape;
	temp.position = pos;

	Instance[] finder = [];

	sceneManager.current.getList().each((ref e) {
		if (ShapeOnShape(temp,e)) {
			finder ~= e;
		}
	});

	return finder;
}

bool inBounds(T)(T obj) {
	static if (is(T == Instance)) {
		Vec tmp = obj.position;
	} else
		T tmp = obj;

	return tmp.x>=0 && tmp.x<g_stepSize*14 &&
		tmp.y>=0 && tmp.y<g_stepSize*12;
}

Vec snapToGrid(Vec pos) @safe {
    return Vec(cast(int)(pos.x / g_stepSize) * g_stepSize, 
                        cast(int)(pos.y / g_stepSize) * g_stepSize);
}

void putObj(char s, Vec p) @trusted {
	import std.algorithm : canFind;

	if ("BmDlsMRo".canFind(s))
		sceneManager.current.add(new Piece(p, s));
	else {
		switch(s) {
			default: break;
			case 'r': sceneManager.current.add(new Faller(p, "rock")); break;
			case 'd': sceneManager.current.add(new Faller(p, "diamond")); break;
		}
	}
}

Uint8* g_keystate;

/**
 * Handle keys, one hit buttons
 */
class TKey {
	/// Key state
	enum KeyState {up, down, startGap, smallGap}

	/// Key state variable
	KeyState _keyState;

	/// Start pause
	static _startPause = 200;
	
	/// Moving momments
	static _pauseTime = 40; // msecs
	
	/// Timer for start pause
	StopWatch _stopWatchStart;

	/// Timer for moving moments
	StopWatch _stopWatchPause;
	
	/// Key to use
	SDL_Scancode tKey;

	/// Is key set to down
	bool _keyDown;
	
	/**
	 * Constructor
	 */
	this(SDL_Scancode tkey0) {
		tKey = tkey0;
		_keyDown = false;
		_keyState = KeyState.up;
	}

	/// Is key pressed
	bool keyPressed() { // eg. g_keys[Keyboard.Key.A].keyPressed
		//return Keyboard.isKeyPressed(tKey) != 0;
		return g_keystate[tKey] != 0;
	}

	/// Goes once per key hit
	bool keyTrigger() { // eg. g_keys[Keyboard.Key.A].keyTrigger
		if (g_keystate[tKey] && _keyDown == false) {
			_keyDown = true;
			return true;
		} else if (! g_keystate[tKey]) {
			_keyDown = false;
		}
		
		return false;
	}
	
	// returns true doing trigger other wise false saying the key is already down
	/** One hit key */
	/+
		Press key down, print the character. Keep holding down the key and the cursor move at a staggered pace.
		+/
	bool keyInput() { // eg. g_keys[Keyboard.Key.A].keyInput
		if (! g_keystate[tKey])
			_keyState = KeyState.up;

		if (g_keystate[tKey] && _keyState == KeyState.up) {
			_keyState = KeyState.down;
			_stopWatchStart.reset;
			_stopWatchStart.start;

			return true;
		}
		
		if (_keyState == KeyState.down && _stopWatchStart.peek.total!"msecs" > _startPause)  {
			_keyState = KeyState.smallGap;
			_stopWatchPause.reset;
			_stopWatchPause.start;
		}
		
		if (_keyState == KeyState.smallGap && _stopWatchPause.peek.total!"msecs" > _pauseTime) {
			_keyState = KeyState.down;
			
			return true;
		}
		
		return false;
	}

	/** hold key */
//	bool keyPress() {
//		return Keyboard.isKeyPressed(tKey) > 0;
//	}
}

/// Keys array
TKey[] g_keys; // g_keys[SDL_SCANCODE_T].keyTrigger

bool initKeys() {
	version(Trace) { 5.gh; }
	g_keystate = SDL_GetKeyboardState(null);
	foreach(tkey; cast(SDL_Scancode)0 .. SDL_NUM_SCANCODES)
		g_keys ~= new TKey(cast(SDL_Scancode)tkey);
	version(Trace) { 4.gh; }

	return g_keys.length == SDL_NUM_SCANCODES;
}
