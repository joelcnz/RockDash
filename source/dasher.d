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

    int diamonds;

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
        //collectDiamond.load("assets/pop.wav", "collectDiamond");
        collectDiamond.load("assets/diamondcollect.wav", "collectDiamond");

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
        auto testList = sceneManager.current.getInstanceArrayByMask(position,g_shapeRect);
        foreach(t; testList)
            //if (id != t.id && position == t.position && t.name == "rock") {
            if (t.name == "rock") {
                t.destroy;
                "destroyed rock".gh;
            }

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

        auto obj = sceneManager.current.getInstanceByMask(position + dirs[moveDir],g_shapeRect);

        if (! inBounds(position + dirs[moveDir])) {
            return;
        }

        if (obj !is null) {
            switch1: switch(obj.name) {
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
                            g_score += 1;
                            g_messageUpdate(text("Mud cleared - ", 1, " point"));
                        break;
                        case "diamond":
                            diamonds += 1;
                            if (diamonds == 10) {
                                auto objOld = sceneManager.current.getInstanceByMask(g_exitDoorPos,g_shapeRect);
                                objOld.destroy;
                                putObj('o',g_exitDoorPos);
                                g_messageUpdate(text("Exit door opened - ", 700, " points"));
                            }
                            g_score += diamonds > 10 ? 10 * 4 : 10;
                            g_messageUpdate(diamonds > 10 ?
                                text("Bonus diamond collection ", 40, " points") :
                                text("Diamond collection ", 10, " points"));
                            collectDiamond.play(false);
                        break;
                        case "aswitch":
                            g_score += 200;
                            g_messageUpdate(text("Switch flicked - ", 200, " points"));
                            g_aswitch.activate;
                        break;
                        case "rock":
                            auto checkForDiamondMaker = sceneManager.current.getInstanceByMask(position + Vec(0,g_stepSize),g_shapeRect);
                            if (g_hackForDiamondMakerBool && checkForDiamondMaker !is null &&
                                    checkForDiamondMaker.position.inBounds && checkForDiamondMaker.name == "diamond_maker") {
                                g_hackForDiamondMakerBool = false;
                                break;
                            }
                            auto objPos = obj.position;
                            auto beyond = sceneManager.current.getInstanceByMask(objPos + dirs[moveDir],g_shapeRect);
                            auto newPos = objPos + dirs[moveDir];
                            if (beyond is null && newPos.inBounds) {
                                sceneManager.current.add(new Faller(newPos, "rock"));
                            } else  {
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
        g_messages[MessageType.stats] = text("Score: ", g_score, ", Diamonds: ", diamonds, ", Lives: ", g_lives);
    } // doMove

    override void draw(Display graph) {
        super.draw(graph);
    }
}
