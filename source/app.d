//#here
module source.app;

public import foxid;
import source.dasher,
	source.screen,
	source.faller,
	source.editor,
	source.bady,
	source.explosion,
	source.exitdoor,
	source.aswitch;

public import foxid.sdl;

public import jmisc;

public import std.datetime.stopwatch;
public import std.stdio;

version(unittest)
    import unit_threaded;

immutable g_stepSize = 24;
immutable g_screenCharW = 14;
immutable g_screenCharH = 12;

enum SpriteGraph {brick, mud, start, shut_door, bady_maker_left, up, left, down, right, aswitch, diamond_maker,
	diamond, rock, bady_maker_right, blow0, blow1, blow2, blow3, bady_vert, bady_hor, door_open, blow4, blow5, blow6, gap}

immutable SpriteNames = ["brick", "mud", "start", "shut_door", "bady_maker_left", "up", "left", "down", "right", "aswitch", "diamond_maker",
	"diamond", "rock", "bady_maker_right", "blow0", "blow1", "blow2", "blow3", "bady_vert", "bady_hor", "door_open", "blow4", "blow5", "blow6", "gap"];

immutable OtherSpriteNames = ["editor", "dasher"];

Image[] g_spriteList;
Image[char] g_sprites;
string[char] g_names;
string g_chars;
bool g_levelComplete;
StopWatch g_sw;
Vec g_startPos, g_badyMakerPos, g_explodePoint = Vec(-1,-1);
Sound g_blowUp;
bool g_editMode;
int g_diamonds;
bool g_aswitchEditing;
bool g_doMoves,
	g_flashTime;
string[] g_args;
ASwitch g_aswitch;

/+
	Create our first scene
+/
final class RockDashScene : Scene
{
	private Font fontgame;

	this() @trusted {
		name = "RockDashScene";
		
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

			g_names['B'] = SpriteNames[brick];
			g_names['m'] = SpriteNames[mud];
			g_names['S'] = SpriteNames[start];
			g_names['D'] = SpriteNames[shut_door];
			g_names['l'] = SpriteNames[bady_maker_left];
			g_names['s'] = SpriteNames[aswitch];
			g_names['M'] = SpriteNames[diamond_maker];
			g_names['d'] = SpriteNames[diamond];
			g_names['r'] = SpriteNames[rock];
			g_names['R'] = SpriteNames[bady_maker_right];
			g_names['o'] = SpriteNames[door_open];
		}

		g_blowUp = new Sound();
        g_blowUp.load("assets/blowup.wav", "blowup");

		import std.stdio : write, writeln;
		write("Operating system: ");
		version(Windows) {
			writeln("Window OS");
		}
		version(OSX) {
			writeln("macOS");
		}
		version(linux) {
			writeln("Linux OS");
		}
		mixin(trace("g_sw.peek().total!`msecs`"));
	}

	override void event(Event event) {
		if (event.getKeyDown == 'e') {
			g_editMode = ! g_editMode;
		}
	}

	override void gameStart() @trusted {
		fontgame = loader.loadFont("assets/DejaVuSans.ttf",14);
		load(g_args.length > 1 ? g_args[1] ~ ".bin" : "test.bin");
	} // gameStart

	void save(string fileName) {
		import core.stdc.stdio;
		import std.path: buildPath;
		import std.string;

		fileName = buildPath("Saves", fileName);
		FILE* f;
		if ((f = fopen(fileName.toStringz, "wb")) == null) {
			import std.stdio; writeln("save: '", fileName, "' can't be opened");

			return;
		}
		scope(exit)
			fclose(f);
		writeln("Save: ", fileName);
		ubyte ver = 0;
		fwrite(&ver, 1, ubyte.sizeof, f); // 1 version
		import std.string : split;
		mixin(trace("ver"));
		import std.algorithm : canFind;
		int count;
		foreach(const e; sceneManager.current.getList().array)
			if (SpriteNames.canFind(e.name)) {
				count += 1;
			}
		fwrite(&count, 1, int.sizeof, f);
		mixin(trace("count"));
		foreach(const e; sceneManager.current.getList().array) {
			if ((SpriteNames ~ "Door").canFind(e.name)) {
				char c;
				foreach(i, n; SpriteNames)
					if (e.name == n) {
						c = g_chars[i];
						fwrite(&c, 1, char.sizeof, f);
						fwrite(&e.position.x, 1, float.sizeof, f);
						fwrite(&e.position.y, 1, float.sizeof, f);
						break;
					}
			}
		}
	} // save

	void load(string fileName)  {
		foreach(ref e; getList().array) {
			e.destroy();
		}
		g_levelComplete = false;
		g_diamonds = 0;

		import core.stdc.stdio;
		import std.path: buildPath;
		import std.string;

		fileName = buildPath("Saves", fileName);
		FILE* f;
		if ((f = fopen(fileName.toStringz, "rb")) == null) {
			import std.stdio; writeln("load: '", fileName, "' can't be opened");

			return;
		}
		scope(exit)
			fclose(f);
		writeln("Load: ", fileName);
		ubyte ver = 0;
		fread(&ver, 1, ubyte.sizeof, f); // 1 version
		import std.string : split;
		mixin(trace("ver"));
		int count;
		fread(&count, 1, int.sizeof, f);
		mixin(trace("count"));
		import std.algorithm : canFind;

		g_editMode = false;
		foreach(const e; 0 .. count) {
			char c;
			float x,y;
			fread(&c, 1, char.sizeof, f);
			fread(&x, 1, float.sizeof, f);
			fread(&y, 1, float.sizeof, f);
			putObj(c, Vec(x,y));
		}
		add(new Editor());
	} // load

	override void step() @trusted {
		if (! g_editMode) {
			g_doMoves = false;
			if (g_explodePoint != Vec(-1,-1)) {
				import std.range : iota;
				foreach(y; iota(g_explodePoint.y - g_stepSize, g_explodePoint.y + g_stepSize + 1, g_stepSize))
					foreach(x; iota(g_explodePoint.x - g_stepSize, g_explodePoint.x + g_stepSize + 1, g_stepSize)) {
						auto obj = sceneManager.current.getInstanceByMask(Vec(x,y),
							ShapeRectangle(Vec(1,1),Vec(g_stepSize-1,g_stepSize-1)));
						import std.algorithm : canFind;
						if (obj !is null && obj.position.inBounds && ["brick", "mud", "shut_door", "bady_maker_left",
							"aswitch", "diamond_maker","diamond", "rock",
							"bady_maker_right",
							"door_open"].canFind(obj.name))
							obj.destroy;
						if (Vec(x,y).inBounds) {
							sceneManager.current.add(new Explosion(Vec(x,y)));
						}
					}
				g_explodePoint = Vec(-1,-1);
			}
			if (g_sw.peek().total!"msecs" > 150) {
				g_sw.reset;
				g_sw.start;
				g_doMoves = true;
			}
		} // ! g_editMode

		if (g_editMode) {
			SDL_PumpEvents();

			if (g_keys[SDL_SCANCODE_S].keyTrigger) {
				save("test.bin");
			}

			if (g_keys[SDL_SCANCODE_L].keyTrigger) {
				load("test.bin");
			} // if L key pressed
		}
	}

	override void draw(Display graph) @trusted {
		super.draw(graph);
		if (g_aswitchEditing) {
			g_aswitch.draw(graph);
        }
	}
} // final class RockDashScene : Scene

version(unittest) {
} else {
	int main(string[] args) {
		g_sw.start;

		g_args = args;

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
		//sceneManager.add(new ASwitchScene());

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

void putObj(char c, Vec p) @trusted {
	import std.algorithm : canFind;
	if (g_aswitchEditing) {
		if (p.inBounds && "BmMdrg".canFind(c)) {
			g_aswitch.addPopUp(p, c);
			import std.string : split;
			mixin(trace("p c".split));
			//sceneManager.current.add(new Piece(p, c, /+ pop up +/  true));
		}
		return;
	}
	if ("SBmMobg".canFind(c)) {
		if (c == 'S' && p.inBounds && ! g_editMode) {
			sceneManager.current.add(new Dasher(p));
			g_startPos = p;
		} else {
			sceneManager.current.add(new Piece(p, c));
		}
	} else {
		bool inBounds = p.inBounds;
		switch(c) {
			default: break;
			case 'r': sceneManager.current.add(new Faller(p, "rock")); break;
			case 'd': sceneManager.current.add(new Faller(p, "diamond")); break;
			case 'l', 'R':
				sceneManager.current.add(new Piece(p, c));
				auto newPos = p + Vec(c == 'l' ? -g_stepSize : g_stepSize,0);
				if (! g_editMode && newPos.inBounds) {
					sceneManager.current.add(new Bady(newPos));
					g_badyMakerPos = p;
				}	
			break;
			case 'D':
				sceneManager.current.add(new ExitDoor(p));
			break;
			case 's':
				if (inBounds) {
					g_aswitch = ASwitch(p);
				}
				sceneManager.current.add(new Piece(p, c));
			break;
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
