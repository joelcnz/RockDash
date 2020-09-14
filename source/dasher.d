//#boppo! gets rid of the rocks that shouldn't be there
//#not sure about releasing memory
module source.dasher;

import jmisc;

import foxid;

import source.app, source.screen, source.faller; //, source.exitdoor;

final class Dasher : Instance {
    Image dasherUp;
    Image dasherDown;
    Image dasherLeft;
    Image dasherRight;

    Font fontgame;

    int score,
        diamonds;

    Sound moveMud,
        moveGap,
        collectDiamond;        
    
    bool timerGap;

    StopWatch flashTimeTimer;
    
    auto dirs = [Vec(0,-g_stepSize), Vec(g_stepSize,0), Vec(0,g_stepSize), Vec(-g_stepSize,0)];

    this(Vec pos) @trusted {
        name = "dasher";

        dasherUp = g_spriteList[SpriteGraph.up];
        dasherDown = g_spriteList[SpriteGraph.down];
        dasherLeft = g_spriteList[SpriteGraph.left];
        dasherRight = g_spriteList[SpriteGraph.right];

        ofsprite.image = dasherUp;

        position = pos;
        depth = 10;

        moveMud = new Sound();
        moveMud.load("assets/collect.wav", "moveMud");

        collectDiamond = new Sound();
        collectDiamond.load("assets/pop.wav", "collectDiamond");

        moveGap = new Sound();
        moveGap.load("assets/gap.wav", "moveGap");

        shape = ShapeRectangle(Vec(0,0), Vec(g_stepSize, g_stepSize));

        fontgame = loader.loadFont("assets/DejaVuSans.ttf",14);
    }

    override void gameExit() @safe {
        //#not sure about releasing memory
        //moveMud.free;
        //moveGap.free;
    }

    override void step() @trusted {
        //#boppo! gets rid of the rocks that shouldn't be there
        auto testList = sceneManager.current.getInstanceArrayByMask(position,
                            ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));
        foreach(t; testList)
            if (id != t.id && position == t.position && t.name == "rock")
                t.destroy;

        if (g_editMode) {
            visible = false;
            return;
        }
        visible = true;

        if (g_levelComplete)
            visible = false;
        if (! g_doMoves || g_levelComplete)
            return;

        SDL_PumpEvents();

        if (g_keys[SDL_SCANCODE_UP].keyPressed) {
            ofsprite.image = dasherUp;
            doMove(up);
        }
        if (g_keys[SDL_SCANCODE_DOWN].keyPressed) {
            ofsprite.image = dasherDown;
            doMove(down);
        }
        if (g_keys[SDL_SCANCODE_LEFT].keyPressed) {
            ofsprite.image = dasherLeft;
            doMove(left);
        }
        if (g_keys[SDL_SCANCODE_RIGHT].keyPressed) {
            ofsprite.image = dasherRight;
            doMove(right);
        }
    }

    void doMove(in int moveDir) {
        dasherMoveDir = moveDir;
        /+
        if (g_editMode) {
            visible = false;
            return;
        }
        visible = true;
        +/

        auto obj = sceneManager.current.getInstanceByMask(position + dirs[moveDir],
            ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));

        if (! inBounds(position + dirs[moveDir])) {
            return;
        }

        if (moveDir == left || moveDir == right && position.y >= 0) {
            auto above = sceneManager.current.getInstanceByMask(position + dirs[up],
                ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));
            if (above !is null) {
                if (["rock","diamond"].canFind(above.name)) {
                    sceneManager.current.add(new Faller(above.position, above.name));
                    above.destroy;
                }
            }
        }
        if  (dasherMoveDir == down) {
            auto above = sceneManager.current.getInstanceByMask(position + dirs[up],
                ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));
            if (above !is null) {
                if (["rock","diamond"].canFind(above.name)) {
                    sceneManager.current.add(new Faller(above.position, above.name));
                    above.destroy;
                }
            }
        }

        if (obj !is null) {
            switch(obj.name) {
                default: break;
                case "mud", "diamond", "aswitch", "rock", "door_open":
                    position += dirs[moveDir];
                    switch(obj.name) {
                        default: break;
                        case "door_open":
                            g_doorState = Door.shutting;
                        break;
                        case "mud":
                            moveMud.play(false);
                        break;
                        case "diamond":
                            diamonds += 1;
                            g_diamonds = diamonds;
                            if (diamonds == 10) {
                                auto objOld = sceneManager.current.getInstanceByMask(g_exitDoorPos,
                                            ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));
                                objOld.destroy;
                                putObj('o',g_exitDoorPos);
                            }
                            score += diamonds > 10 ? 10 * 4 : 10;
                            collectDiamond.play(false);
                        break;
                        case "aswitch":
                            g_aswitch.activate;
                        break;
                        case "rock":
                            auto objPos = obj.position;
                            auto beyond = sceneManager.current.getInstanceByMask(objPos + dirs[moveDir],
                                            ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));
                            auto newPos = objPos + dirs[moveDir];
                            if (beyond is null && newPos.inBounds) {
                                //obj.destroy;
                                sceneManager.current.add(new Faller(newPos, "rock"));
                            } else  {
                                //obj.destroy;
                                sceneManager.current.add(new Faller(position, "rock"));
                                position -= dirs[moveDir];
                            }
                        break;
                    }
                break;
            }
            if ("mud diamond aswitch rock".split.canFind(obj.name)) {
                obj.destroy();
            }
        } else {
            auto p = position + dirs[moveDir];
            position = p;
            moveGap.play(false);
        }
    } // doMove

    override void draw(Display graph) {
        super.draw(graph);
        import std.conv : text;
        graph.drawText(text("Score: ", score, ", Diamonds: ", diamonds),fontgame,Color(255,180,0),Vec(0,g_stepSize * (12 + 3)));
    }
}
