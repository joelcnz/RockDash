module source.bady;

import source.app,
    source.explosion,
    source.dasher;

final class Bady : Instance {
    auto dirs = [Vec(0,-g_stepSize), Vec(g_stepSize,0), Vec(0,g_stepSize), Vec(-g_stepSize,0)];
    int moveDir;

    Image vert, horr;

    this(Vec pos) @safe {
        name = "bady";

        position = pos;

        vert = g_spriteList[SpriteGraph.bady_vert];
        horr = g_spriteList[SpriteGraph.bady_hor];

        ofsprite.image = horr;

        shape = ShapeRectangle(Vec(0,0), Vec(g_stepSize, g_stepSize));

        if (g_badyMakerPos.x < position.x)
            moveDir = right;
        else
            moveDir = left;
    }

    void setGraph() {
        if (moveDir == up || moveDir == down)
            ofsprite.image = vert;
        else
            ofsprite.image = horr;
    }

    override void step() @trusted {
        foreach(space; sceneManager.current.getInstanceArrayByMask(position,g_shapeRect))
            if (space.name != "bady") {
                visible = false;
                return;
            }
        visible = true;
        if (! g_doMoves || g_editMode)
            return;
        setGraph;

        auto newPos = position + dirs[moveDir];
        auto obj = sceneManager.current.getInstanceByMask(newPos,g_shapeRect);

        if (! g_gameOver && newPos.inBounds) {
            if (obj !is null && g_explodePoint == Vec(-1,-1)) {
                if (obj.name == "dasher" && g_exitDoorPos != obj.position) {
                    sceneManager.current.add(new Explosion(obj.position));
                    g_lives -= 1;
                    if (g_lives == 0) {
                        g_messageUpdate("Game Over");
                        g_gameOver = true;
                        obj.position = Vec(-g_stepSize,-g_stepSize);
                    } else
                        g_messageUpdate("Life lost");
                    if (! g_gameOver)
                        obj.position = g_startPos; // put player back at start point
                    obj = sceneManager.current.getInstanceByMask(g_badyMakerPos,g_shapeRect);
                    if (obj !is null) {
                        if (obj.name == "bady_maker_left" || obj.name == "bady_maker_right") {
                            auto badyMaker = obj.name == "bady_maker_left" ? "bmleft" : "bmright";
                            position = obj.position + Vec(badyMaker == "bmleft" ? -g_stepSize : g_stepSize,0);
                        } else
                            this.destroy;
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
