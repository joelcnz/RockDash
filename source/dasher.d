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

    int moveDir;
    bool doMove;

    struct Dirs {
            Vec dir;
        }

    auto dirs = [Dirs(Vec(0,-g_stepSize)), Dirs(Vec(g_stepSize,0)), Dirs(Vec(0,g_stepSize)), Dirs(Vec(-g_stepSize,0))];

    this() @trusted {
        name = "dasher";

        dasherUp = g_spriteList[SpriteGraph.up];
        dasherDown = g_spriteList[SpriteGraph.down];
        dasherLeft = g_spriteList[SpriteGraph.left];
        dasherRight = g_spriteList[SpriteGraph.right];

        ofsprite.image = dasherUp;

        position = Vec(6 * g_stepSize, 5 * g_stepSize);
    }

    override void step() @safe {
        if (doMove) {
            auto obj = sceneManager.current.getInstanceByMask(position + dirs[moveDir].dir, ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));

            if (obj !is null) {
                import std.algorithm : canFind;
                import std.string : split;

                switch(obj.name) {
                    default: break;
                    case "gap", "mud", "diamond", "aswitch":
                        position += dirs[moveDir].dir;
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
            doMove = false;
        }
    }

    override void event(Event event) @safe {
        switch(event.getKeyDown) {
            default: break;
            case Key.up:
                ofsprite.image = dasherUp;
                moveDir = 0;
                doMove = true;
            break;
            case Key.right:
                ofsprite.image = dasherRight;
                moveDir = 1;
                doMove = true;
            break;
            case Key.down:
                ofsprite.image = dasherDown;
                moveDir = 2;
                doMove = true;
            break;
            case Key.left:
                ofsprite.image = dasherLeft;
                moveDir = 3;
                doMove = true;
            break;
        }
    }
}