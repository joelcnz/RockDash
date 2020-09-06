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

    Sound moveMud,
        moveGap;

    auto dirs = [Vec(0,-g_stepSize), Vec(g_stepSize,0), Vec(0,g_stepSize), Vec(-g_stepSize,0)];
    enum {up,right,down,left}

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

    override void step() @trusted {
        SDL_PumpEvents();

        if (g_keys[SDL_SCANCODE_UP].keyPressed) {
            ofsprite.image = dasherUp;
            doMove(up);
        }
        if (g_keys[SDL_SCANCODE_DOWN].keyPressed) {
            ofsprite.image = dasherDown;
            doMove(down);
        }
        if (g_keys[SDL_SCANCODE_RIGHT].keyPressed) {
            ofsprite.image = dasherRight;
            doMove(right);
        }
        if (g_keys[SDL_SCANCODE_LEFT].keyPressed) {
            ofsprite.image = dasherLeft;
            doMove(left);
        }
    }

    void doMove(in int moveDir) {
        auto obj = sceneManager.current.getInstanceByMask(position + dirs[moveDir],
            ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));

        if (! inBounds(position + dirs[moveDir]))
            return;

        if (obj !is null) {
            import std.algorithm : canFind;
            import std.string : split;

            switch(obj.name) {
                default: break;
                case "mud", "diamond", "aswitch", "rock":
                    position += dirs[moveDir];
                    switch(obj.name) {
                        default: break;
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
                            auto newPos = obj.position + dirs[moveDir];
                            if (beyond is null && inBounds(newPos)) {
                                obj.position = newPos;
                            } else  {
                                position = position - dirs[moveDir];
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
            position = p;
        }
    } // doMove
}
