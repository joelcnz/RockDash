//#not sure about releasing memory
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

    Sound moveMud,
        moveGap;

    auto dirs = [Vec(0,-g_stepSize), Vec(g_stepSize,0), Vec(0,g_stepSize), Vec(-g_stepSize,0)];

    this() @trusted {
        name = "dasher";

        dasherUp = g_spriteList[SpriteGraph.up];
        dasherDown = g_spriteList[SpriteGraph.down];
        dasherLeft = g_spriteList[SpriteGraph.left];
        dasherRight = g_spriteList[SpriteGraph.right];

        ofsprite.image = dasherUp;

        position = Vec(6 * g_stepSize, 5 * g_stepSize);

        moveMud = new Sound();
        moveMud.load("assets/collect.wav", "moveMud");

        moveGap = new Sound();
        moveGap.load("assets/pop.wav", "moveGap");

        shape = ShapeRectangle(Vec(0,0), Vec(g_stepSize, g_stepSize));
    }

    override void gameExit() @safe {
        //#not sure about releasing memory
        //moveMud.free;
        //moveGap.free;
    }

    override void step() @safe {
        if (doMove) {
            auto obj = sceneManager.current.getInstanceByMask(position + dirs[moveDir],
                ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));

            if (obj !is null) {
                import std.algorithm : canFind;
                import std.string : split;

                switch(obj.name) {
                    default: break;
                    case "gap", "mud", "diamond", "aswitch", "rock":
                        position += dirs[moveDir];
                        switch(obj.name) {
                            default: break;
                            case "gap":
                                moveGap.play(false);
                            break;
                            case "mud":
                                moveMud.play(false);
                            break;
                            case "diamond":
                                score += 10;
                                diamonds += 1;
                                mixin(trace("score diamonds".split));
                            break;
                            case "aswitch":
                                import std.stdio; writeln("Switch triggered");
                            break;
                            case "rock":
                                auto beyond = sceneManager.current.getInstanceByMask(obj.position + dirs[moveDir],
                                                ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));
                                if (beyond is null) {
                                    obj.position += dirs[moveDir];
                                } else  {
                                    position = position - dirs[moveDir];
                                    //doMove = false;
                                }
                            break;
                        }
                    break;
                }
                if ("mud diamond aswitch".split.canFind(obj.name)) {
                    obj.destroy();
                }
            } else {
                moveGap.play(false);
                auto p = position + dirs[moveDir];
                if (p.x >= 0 && p.x < g_stepSize * 14 && p.y >= 0 && p.y < g_stepSize * 12)
                    position = p;
            }
            // obj not is null
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