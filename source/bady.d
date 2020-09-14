module source.bady;

import source.app;
import source.explosion;

final class Bady : Instance {
    enum {up,right,down,left}
    auto dirs = [Vec(0,-g_stepSize), Vec(g_stepSize,0), Vec(0,g_stepSize), Vec(-g_stepSize,0)];
    int moveDir;

    Image vert, horr;

    this(Vec pos) @safe {
        name = "bady";

        position = pos;
        moveDir = up;

//enum SpriteGraph {brick, mud, start, shut_door, bady_maker_left, up, left, down, right, aswitch, diamond_maker,
//	diamond, rock, bady_maker_right, blow0, blow1, blow2, blow3, bady_vert, bady_hor, door_open, blow4, blow5, blow6, gap}
        vert = g_spriteList[SpriteGraph.bady_vert];
        horr = g_spriteList[SpriteGraph.bady_hor];

        ofsprite.image = vert;

        shape = ShapeRectangle(Vec(0,0), Vec(g_stepSize, g_stepSize));
    }

    void setGraph() {
        if (moveDir == up || moveDir == down)
            ofsprite.image = vert;
        else
            ofsprite.image = horr;
    }

    override void step() @trusted {
        if (! g_doMoves || g_editMode)
            return;

        setGraph;

        auto newPos = position + dirs[moveDir];
        auto obj = sceneManager.current.getInstanceByMask(newPos,
            ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));

        if (newPos.inBounds) {
            if (obj !is null) {
                if (obj.name == "dasher") {
                    //g_explodePoint = obj.position;
                    sceneManager.current.add(new Explosion(obj.position));
                    obj.position = g_startPos; // put player back at start point
                    obj = sceneManager.current.getInstanceByMask(g_badyMakerPos,
                            ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));
                    if (obj !is null) {
                        auto newPos2 = obj.position + Vec(obj.name == "bady_maker_left" ? -g_stepSize : g_stepSize,0);
                        if (newPos2.inBounds)
                            position = newPos2;
                    }
                }
            }
        } // if newPos in bounds
                
        if (! newPos.inBounds || obj !is null) {
            auto vlft = position + Vec(-g_stepSize, 0);
            auto vrgt = position + Vec(g_stepSize, 0);
            auto vu = position + Vec(0,-g_stepSize);
            auto vdwn = position + Vec(0,g_stepSize);

            auto lft = sceneManager.current.getInstanceByMask(vlft,
                ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));
            auto rgt = sceneManager.current.getInstanceByMask(vrgt,
                ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));
            auto u = sceneManager.current.getInstanceByMask(vu,
                ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));
            auto dwn = sceneManager.current.getInstanceByMask(vdwn,
                ShapeRectangle(Vec(1,1), Vec(g_stepSize - 1,g_stepSize - 1)));

            auto tlft = ! vlft.inBounds || lft;
            auto trgt = ! vrgt.inBounds || rgt;
            auto tu = ! vu.inBounds || u;
            auto tdwn = ! vdwn.inBounds || dwn;

            auto stDir = moveDir;
            switch(moveDir) {
                default: break;
                case up, down:
                    if (tlft && trgt)
                        moveDir = (stDir == up ? down : up);
                    else
                        if (! tlft)
                            moveDir = left;
                        else
                            moveDir = right;
                break;
                case left,right:
                    if (tu && tdwn)
                        moveDir = (stDir == left ? right : left);
                    else
                        if (! tu)
                            moveDir = up;
                        else
                            moveDir = down;
                break;
            } // switch
            setGraph;
        } else {
            if (obj is null)
                position = newPos;
        }
    }
}
