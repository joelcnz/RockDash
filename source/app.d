module source.app;

//@safe:
import foxid;
import source.dasher;
import source.screen;

import jmisc;

version(unittest)
    import unit_threaded;

import jmisc;

immutable g_stepSize = 24;

enum SpriteGraph {brick, mud, start, shut_door, bady_maker_left, up, left, down, right, aswitch, diamond_maker,
	diamond, rock, bady_maker_right, blow0, blow1, blow2, blow3, bady_vert, bady_hor, door_open, blow4, blow5, blow6, gap}

Image[] g_spriteList;

Image[char] g_sprites;

/+
	Create our first scene
+/
final class RockDashScene : Scene
{
	import foxid.sdl;

	private Font fontgame;
	
	this() @trusted {
		name = "RockDashScene";

        g_spriteList = loader.load!ImageSurface("assets/rockdash5.png").image.strip(Vec(0,0), 24, 24).array;

        foreach(ref e; g_spriteList) {
            e.make();
        }

		//foreach(c; "BmSDl....sMdr")
//enum SpriteGraph {brick, mud, start, shut_door, bady_maker_left, up, left, down, right, aswitch, diamond_maker,
//	diamond, rock, bady_maker_right, blow0, blow1, blow2, blow3, bady_vert, bady_hor, blow4, blow5, blow6, gap}

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

		fontgame = loader.loadFont("assets/arcade_classic.ttf",14);
		add(new Dasher());

		add(new class Instance {
			override void init() @safe {
				depth = 10;
			}
			override void draw(Display graph) @safe {
				graph.drawText("Hello Rock Dash fan!", fontgame, Color(255,180,0), Vec(0,0));
			}
		});
	}
}

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
