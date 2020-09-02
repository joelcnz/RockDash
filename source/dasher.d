module source.dasher;

import jmisc;

import foxid;

import source.app, source.screen;

final class Dasher : Instance {

    Image dasherUp;
    Image dasherDown;
    Image dasherLeft;
    Image dasherRight;

    int score,
        diamonds;

    this() @trusted {
        name = "dasher";

        dasherUp = g_spriteList[SpriteGraph.up];
        dasherDown = g_spriteList[SpriteGraph.down];
        dasherLeft = g_spriteList[SpriteGraph.left];
        dasherRight = g_spriteList[SpriteGraph.right];

        ofsprite.image = dasherUp;

        position = Vec(6 * g_stepSize, 5 * g_stepSize);
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
            auto obj = sceneManager.current.getInstanceByMask(position + dirs[index].dir, ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));

            if (obj !is null) {
                import std.algorithm : canFind;
                import std.string : split;

                switch(obj.name) {
                    default: break;
                    case "gap", "mud", "diamond", "aswitch":
                        position += dirs[index].dir;
                        switch(obj.name) {
                            default: break;
                            case "gap":
                                // into a gap sound
                            break;
                            case "mud":
                                // clear mud sound
                            break;
                            case "diamond":
                                // sound for picking up
                                score += 10;
                                diamonds += 1;
                                mixin(trace("score diamonds".split));
                            break;
                            case "aswitch":
                                import std.stdio; writeln("Switch triggered");
                            break;
                        }
                    break;
                }
                if ("mud diamond aswitch".split.canFind(obj.name)) {
                    obj.destroy();
                    sceneManager.current.add(new Piece(obj.position, g_chars[SpriteGraph.gap]));
                }
            } // obj not is null
        }
    }
}
