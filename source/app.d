//#not sure about this
//#recusion
module source.app;

public import foxid;
import source.dasher,
	source.screen,
	source.faller,
	source.editor,
	source.bady,
	source.explosion,
	source.aswitch;

public import foxid.sdl;

public import jmisc;

public import std.datetime.stopwatch,
	std.stdio,
	std.string,
	std.algorithm,
	std.string,
	std.conv;

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

enum Door {to_open,opening,open,shutting,shut,done}
Door g_doorState = Door.to_open;

enum {up,right,down,left}

bool program_init = true;

string[] g_args;
//string g_level = "test";

Image[] g_spriteList;
Image[char] g_sprites;
string[char] g_names;
string g_chars;

string //g_fileName,
	g_fileNameBase;
bool g_levelComplete;
bool g_gameComplete;
bool g_gameOver;
bool g_gameInit = true;
int g_startLevel;
int g_diamonds;
int g_score,
	g_levelStartScore,
	g_levelDiamondsStart, // score when you start the level, gets reset to it when you put reload (A)
	g_extraLifeScore;
int g_lives;
StopWatch g_sw;
bool g_editMode;
Vec g_startPos, g_badyMakerPos, g_explodePoint = Vec(-1,-1);
bool g_aswitchEditing;
bool g_doMoves,
	g_flashTime;
ASwitch g_aswitch;
Vec g_exitDoorPos;
Shape g_shapeRect;
Sound g_rockFall, g_diamondStartFall, g_diamondStop, g_blowUp, g_diamondMaker;
bool g_hackForDiamondMakerBool;
Font g_fontgame;
string[] g_messages;

enum MessageType {stats,info,info2,info3}
int g_level;

/// update and scroll messages
void g_messageUpdate(in string txt) {
	if (txt == "")
		return;
	// avoiding repeated messages
	//#not sure about this
	if (txt == g_messages[MessageType.info3])
		return;
	for(int i = MessageType.info; i + 1 <= MessageType.info3; i += 1) {
		g_messages[i] = g_messages[i + 1];
	}
	g_messages[MessageType.info3] = txt;
}

void extraLifeScoreUpdate(in int points) {
	g_extraLifeScore += points;
	if (g_extraLifeScore >= 2_000) {
		g_extraLifeScore = 0;
		g_lives += 1;
	}
}

/+
	Create our first scene
+/
final class RockDashScene : Scene
{
	this() @trusted {
		name = "RockDashScene";
		
        //g_spriteList = loader.load!ImageSurface("assets/rockdash5.png").image.strip(Vec(0,0), 24, 24);
		g_spriteList = loader.load!ImageSurface("assets/RockDashColoured.png").image.strip(Vec(0,0), 24, 24);

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

		g_shapeRect = ShapeRectangle(Vec(1,1),Vec(g_stepSize-1,g_stepSize-1));

		g_blowUp = new Sound();
        g_blowUp.load("assets/blowup.wav", "blowup");

		g_rockFall = new Sound();
        g_rockFall.load("assets/boulder.wav", "fall");

		g_diamondStartFall = new Sound();
		g_diamondStartFall.load("assets/Diamondstartdrop.wav", "diamond_fall");

		g_diamondStop = new Sound();
		g_diamondStop.load("assets/Diamonddland.wav", "diamond_stop");

		g_diamondMaker = new Sound();
		g_diamondMaker.load("assets/diamond_maker.wav", "diamond_maker");

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

		g_fontgame = loader.loadFont("assets/DejaVuSans.ttf", g_stepSize / 2);
		g_messages.length = 5;

		mixin(trace("g_sw.peek().total!`msecs`"));
	}

	override void event(Event event) {
		if (event.getKeyDown == 'e' && ! g_gameComplete) {
			g_editMode = ! g_editMode;
			if (g_editMode) {
				foreach(ref e; getList()) {
					if (e.name == "dasher")
						e.visible = false;
				}
			} else {
				foreach(ref e; getList()) {
					if (e.name == "dasher")
						e.visible = true;
				}
			}
		}
	}

	override void gameStart() @trusted {
		"gameStart()".gh;
		g_score = g_extraLifeScore = 0;
		g_lives = 7;
		g_gameOver = g_levelComplete = g_gameComplete = false;
		g_messageUpdate("New Game");
		load(g_fileNameBase);
		if (program_init)
			g_editMode = program_init = false;
	} // gameStart

	void save(string fileNameBase) {
		g_fileNameBase = fileNameBase;
		import core.stdc.stdio;
		import std.path: buildPath;
		import std.string;

		auto fileName = buildPath("Saves", fileNameBase) ~ ".bin";
		jm_backUp(fileName);
		FILE* f;
		if ((f = fopen(fileName.toStringz, "wb")) == null) {
			import std.stdio; writeln("save: '", fileName, "' can't be opened");
			return;
		}
		scope(exit)
			fclose(f);
		writeln("Save: ", fileName);
		ubyte ver = 1;
		fwrite(&ver, 1, ubyte.sizeof, f); // 1 version
		import std.string : split;
		mixin(trace("ver"));
		import std.algorithm : canFind;
		int count;
		foreach(const e; sceneManager.current.getList())
			if (SpriteNames.canFind(e.name)) {
				count += 1;
			}
		fwrite(&count, 1, int.sizeof, f);
		mixin(trace("count"));
		foreach(const e; sceneManager.current.getList()) {
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
		// version 1
		auto pus = g_aswitch.popUps.length;
		fwrite(&pus, 1, ubyte.sizeof, f);
		foreach(pu; g_aswitch.popUps) {
			char c = pu.chr;
			fwrite(&c, 1, char.sizeof, f);
			fwrite(&pu.pos.x, 1, float.sizeof, f);
			fwrite(&pu.pos.y, 1, float.sizeof, f);
		}
		g_messageUpdate(text(fileNameBase, " saved"));
	} // save

	void load(string fileNameBase)  {
		g_fileNameBase = fileNameBase;
		foreach(ref e; getList()) {
			e.destroy();
		}
		g_levelComplete = false;
		g_levelStartScore = g_score;
		g_levelDiamondsStart = g_diamonds;
		g_editMode = false;

		import core.stdc.stdio;
		import std.path: buildPath;
		import std.string;
		import std.file : exists;

		auto fileName = buildPath("Saves", fileNameBase) ~ ".bin";
		jm_backUp(fileName);
		FILE* f;
		if ((f = fopen(fileName.toStringz, "rb")) == null) {
			import std.stdio; writeln("load: '", fileName, "' can't be opened");
			return;
		}
		scope(exit)
			fclose(f);
		writeln("Load: ", fileName);
		ubyte ver;
		fread(&ver, 1, ubyte.sizeof, f); // 1 version
		import std.string : split;
		mixin(trace("ver"));
		int count;
		fread(&count, 1, int.sizeof, f);
		mixin(trace("count"));
		foreach(const e; 0 .. count) {
			char c;
			float x,y;
			fread(&c, 1, char.sizeof, f);
			fread(&x, 1, float.sizeof, f);
			fread(&y, 1, float.sizeof, f);
			putObj(c, Vec(x,y));
		}
		add(new Editor());
		// version 1
		if (ver == 1) {
			ubyte pus;
			fread(&pus, 1, ubyte.sizeof, f);
			foreach(pu; 0 .. pus) {
				char chr;
				Vec pos;
				fread(&chr, 1, char.sizeof, f);
				fread(&pos.x, 1, float.sizeof, f);
				fread(&pos.y, 1, float.sizeof, f);
				if (g_aswitch.active)
					g_aswitch.addPopUp(pos, chr);
			}
		}
		g_editMode = true;
		g_messageUpdate(text(fileNameBase, " loaded"));
	} // load

	override void step() @trusted {
		if (! g_editMode) {
			import std.algorithm;
			import std.array;

			void ssort(T)(ref T[] data,bool delegate(T a,T b) @safe func) @trusted
			{
				for(size_t i = 0; i < data.length; i++)
				{
					for(size_t j = (data.length-1); j >= (i + 1); j--)
					{
						if(func(data[j],data[j-1])) {
							import std.algorithm : swap;
							swap(data[j], data[j-1]);
						}
					}
				}
			}

			Instance dasherIns = getInstanceByName("dasher");
			iDestroy_noGC(dasherIns);
			Instance badyIns = getInstanceByName("bady");
			iDestroy_noGC(badyIns);
			auto list = getList().dup;
			ssort!(Instance)(list, (a, b) => a.position.y < b.position.y);

			list.each!((ref e) {
				iDestroy_noGC(e);
			});

			add(list);
			add(dasherIns);
			add(badyIns);

			g_doMoves = false;
			if (g_explodePoint != Vec(-1,-1)) {
				import std.range : iota;
				foreach(y; iota(g_explodePoint.y - g_stepSize, g_explodePoint.y + g_stepSize + 1, g_stepSize))
					foreach(x; iota(g_explodePoint.x - g_stepSize, g_explodePoint.x + g_stepSize + 1, g_stepSize)) {
						auto obj = sceneManager.current.getInstanceByMask(Vec(x,y),g_shapeRect);
						import std.algorithm : canFind;
						if (obj !is null && obj.position.inBounds && ["brick", "mud", "shut_door", "bady_maker_left",
							"aswitch", "diamond_maker","diamond", "rock", "bady_maker_right", "door_open"].canFind(obj.name))
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

				if (g_doorState == Door.shut) {
					auto levelDiamonds = sceneManager.current.getInstanceByName("dasher").getObject!Dasher.diamonds;
					if (! g_levelComplete)
						g_diamonds += levelDiamonds;
					g_levelComplete = true;
					g_score += 500;
					extraLifeScoreUpdate(500);
					auto message = text(g_fileNameBase, " Complete! - Diamonds: ", levelDiamonds, ", Score: ",
						g_score - g_levelStartScore);
					import std.stdio; writeln(message);
					g_messageUpdate(message);
					getList().each!((ref e) => {
						if (e.name == "Dasher") {
							e.visible = false;
						} else {
							if (e.inBounds && e.name == "door_open") {
								putObj('D', e.position);
								e.destroy;
							}
						}
					});
				}
				if (g_doorState == Door.shut) {
					auto obj = getInstanceByMask(g_exitDoorPos,g_shapeRect);
					obj.destroy;
					putObj('D', g_exitDoorPos);
					g_doorState = Door.done;
				}
				if (g_doorState == Door.shutting)
					g_doorState = Door.shut;
			}
		} // ! g_editMode

		if (g_editMode) {
			SDL_PumpEvents();

			if (g_keys[SDL_SCANCODE_S].keyTrigger) {
				save(g_fileNameBase);
			}

			if (g_keys[SDL_SCANCODE_L].keyTrigger) {
				gameStart;
			} // if L key pressed
		}

		if (g_levelComplete) {
			if (g_keys[SDL_SCANCODE_RETURN].keyTrigger) {
				if (! g_gameComplete)
					g_levelComplete = false;
				setNextLevel;
			}
		}

		if (! g_editMode && ! g_gameComplete && ! g_gameOver) {
			if (g_keys[SDL_SCANCODE_A].keyTrigger) {
				g_score = g_levelStartScore;
				g_diamonds = g_levelDiamondsStart;
				g_level -= 1;
				setNextLevel("Reset level");
			}
		}
		if (! g_gameComplete && ! g_gameOver) {
			auto stats = text("Score: ", g_score, ", Diamonds: ",
							(getInstanceByName("dasher") !is null ?
								getInstanceByName("dasher").getObject!Dasher.diamonds : 0), ", Lives: ", g_lives);
			g_messages[MessageType.stats] = stats;
		}
	}

	void setNextLevel(in string messageUpdate = "") {
		if (g_gameComplete)
			return;
		g_level += 1;
		auto baseName = text("level", g_level);
		auto fileNameTest = getFillName(baseName);
		import std.file;
		if (! fileNameTest.exists) {
			if (g_level > 1) {
				g_level = 1;
				baseName = text("level", g_level);
			}
		}
		if (! g_gameInit && g_level == g_startLevel) {
			g_gameComplete = true;
			g_score += (g_lives - 1) * 800;
			if (g_lives > 1) {
				g_messageUpdate(text("Extra lives Bonus - ", (g_lives - 1) * 800," points"));
				writeln(text("Extra lives Bonus - ", (g_lives - 1) * 800," points"));
			}
			auto stats = text("Score: ", g_score, ", Total Diamonds Collected: ", g_diamonds, ", Lives: ", g_lives);
			g_messages[MessageType.stats] = stats;
			g_messageUpdate("Well done, you have completed the game!");
			writeln("Well done, you have completed the game!");
			return;
		}
		g_fileNameBase = baseName;
		load(g_fileNameBase);
		g_editMode = false;
		g_messageUpdate(messageUpdate);
	}

	override void draw(Display graph) @trusted {
		//super.draw(graph);
		if (g_aswitchEditing) {
			g_aswitch.draw(graph);
        }
		foreach(y, e; g_messages)
			graph.drawText(e,g_fontgame,Color(255,180,0),Vec(0, (g_screenCharH + 2) * g_stepSize + y * (g_stepSize / 2)));
	}
} // final class RockDashScene : Scene

version(unittest) {
} else {
	int main(string[] args) {
		g_sw.start;
		
		/+
		string 

		import std.getopt;
		auto helpInformation = getopt(
			args,
			"level",  &
		);
		+/

		g_args = args;
		import std.file : exists;
		g_fileNameBase = "test";
		if (args.length > 1) {
			g_fileNameBase = args[1];
			import std.ascii : isDigit;
			if (g_fileNameBase[0].isDigit) {
				try
					g_level = g_fileNameBase.to!int;
				catch(Exception e)
					writeln("Invalid number");
				g_fileNameBase = text("level", g_level);
				g_startLevel = g_level;
			}
			auto fileNameTest = getFillName(g_fileNameBase);
			if (! fileNameTest.exists)
				writeln(fileNameTest, " not found, using ", g_fileNameBase);
		}

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

string getFillName(in string baseName) {
	return "Saves/" ~ baseName ~ ".bin";
}

import foxid.core.collision;

Instance[] getInstanceArrayByMask(Vec pos,Shape shape) @safe {
	Instance temp = new Instance;
	temp.shape = shape;
	temp.position = pos;

	Instance[] finder = [];

	sceneManager.current.getList().each!((ref e) => {
		if (ShapeOnShape(temp,e)) {
			finder ~= e;
		}
	});

	return finder;
}

Instance instName(in string name) @trusted {
	Instance result;
	sceneManager.current.getList().each!((ref e) => {
		if (e.name == name)
			result = e;
	});
	return result;
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
				sceneManager.current.add(new Piece(p, c));
				if (inBounds)
					g_exitDoorPos = p;
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
