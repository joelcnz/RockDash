module source.dasher;

import foxid;

import source.app;

final class Dasher : Instance {

    Image dasherUp;
    Image dasherDown;
    Image dasherLeft;
    Image dasherRight;

    this() @trusted {
        name = "Dasher";

        dasherUp = g_spriteList[SpriteGraph.up];
        dasherDown = g_spriteList[SpriteGraph.down];
        dasherLeft = g_spriteList[SpriteGraph.left];
        dasherRight = g_spriteList[SpriteGraph.right];

        ofsprite.image = dasherUp;

        position = Vec(5 * g_stepSize, 5 * g_stepSize);
/+
        shape = ShapeMulti([
			ShapeRectangle(Vec(7*24,0),Vec(7*24 + 24,24))
        ]);
+/
    }

    override void event(Event event) @safe {
        struct Dirs {
            Vec dir;
        }
        auto dirs = [Dirs(Vec(0,-g_stepSize)), Dirs(Vec(g_stepSize,0)), Dirs(Vec(0,g_stepSize)), Dirs(Vec(-g_stepSize,0))];
        int index = -1; // 0 - up, 1 - right, 2 - down, 3 - left

        switch(event.getKeyDown) {
            default: break;
            case Key.up:
                ofsprite.image = dasherUp;
                index = 0;
            break;
            case Key.right:
                ofsprite.image = dasherRight;
                index = 1;
            break;
            case Key.down:
                ofsprite.image = dasherDown;
                index = 2;
            break;
            case Key.left:
                ofsprite.image = dasherLeft;
                index = 3;
            break;
        }

        if (index != -1) {
            if (sceneManager.current.getInstanceByMask(position + dirs[index].dir, ShapeRectangle(Vec(0,0), Vec(g_stepSize,g_stepSize))).name == "mud") {
                position += dirs[index].dir;
            }
        }
    }
}
