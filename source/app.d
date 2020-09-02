module source.app;

//@safe:
import foxid;
import source.dasher;
import source.screen;

import jmisc;

import std.datetime.stopwatch;

version(unittest)
    import unit_threaded;

import jmisc;

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

/+
	Create our first scene
+/
final class RockDashScene : Scene
{
	import foxid.sdl;

	private Font fontgame;

	StopWatch sw;
	
	this() @trusted {
		name = "RockDashScene";
		
		sw.start;

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
			g_sprites['g'] = g_spriteList[gap];
		}

        auto fileName = "assets/screen.txt";
        import std.file, std.string;
        auto data = readText(fileName).split('\n');
        auto p = Vec(0,0);
        foreach(lineNum, line; data) {
            foreach(s; line) {
				add(new Piece(p, s));
                p.x += g_stepSize;
            }
            p.x = 0;
            p.y += g_stepSize;
        }

		fontgame = loader.loadFont("assets/DejaVuSans.ttf",14);
		add(new Dasher());

		add(new class Instance {
			override void init() @safe {
				name = "banner";
				depth = 10;
			}
			override void draw(Display graph) @safe {
				graph.drawText("Hello Rock Dash fan!", fontgame, Color(255,180,0), Vec(0,12 * g_stepSize));
			}
		});
	}

	override void step() @safe {
		if (sw.peek.total!"msecs" > 500) {
			sw.reset;
			sw.start;
			foreach(y; 0 .. g_screenCharH)
				foreach(x; 0 .. g_screenCharW) {
					Vec pos = Vec(x * g_stepSize, y * g_stepSize);
					auto obj = sceneManager.current.
						getInstanceByMask(pos, ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));
					if (obj !is null) {
						if (obj.name == "rock" || obj.name == "diamond") {
							auto objBelow = sceneManager.current.
								getInstanceByMask(pos + Vec(0,g_stepSize), ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));
							if (objBelow !is null) {
								if (objBelow.name == "gap") {
									sceneManager.current.add(new Piece(obj.position, g_chars[SpriteGraph.gap]));
									sceneManager.current.add(new Piece(objBelow.position,
										obj.name == "rock" ? g_chars[SpriteGraph.rock] : g_chars[SpriteGraph.diamond]));
									objBelow.destroy();
									obj.destroy();
								}
							}
						}
					}
				}
		}
	}
} // final class RockDashScene : Scene

version(unittest) {
} else {
	int main(string[] args)
	{
		// game setup
		Game game = new Game(640, 480, "* Rock Dash *");
		window.background = Color(0,0,0);

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
