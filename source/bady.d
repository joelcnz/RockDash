module source.bady;

import source.app,
    source.explosion,
    source.dasher,
    source.scores;

final class Bady : Instance {
    auto dirs = [Vec(0,-g_stepSize), Vec(g_stepSize,0), Vec(0,g_stepSize), Vec(-g_stepSize,0)];
    int moveDir;

    Image vert, horr;

    this(Vec pos) @safe {
        name = "bady";

        position = pos;

        vert = g_spriteList[SpriteIndex.bady_vert];
        horr = g_spriteList[SpriteIndex.bady_hor];

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
                        auto totalDiamonds = g_diamonds + sceneManager.current.getInstanceByName("dasher").getObject!Dasher.diamonds;
                        auto stats = text("Score: ", g_score,
                            ", Total Diamonds Collected: ", totalDiamonds,
                            ", Lives: ", g_lives);
            			g_messages[MessageType.stats] = stats;
                        //name,",",score,",",diamonds,",",lives,",",date,",",time,",",comment
                        import std.datetime : DateTime, Clock;
                        auto dt = cast(DateTime)Clock.currTime();
                        import std.ascii;
                        g_scoresDetails = ScoresDetails(g_scoresDetails.name,g_score,totalDiamonds,g_lives,
                            text(dt.day, ".", dt.month.to!string.capitalize, ".", dt.year),timeString,g_scoresDetails.comment);
                        g_scoreCards.add(g_scoresDetails);
                        upDate(g_scoresDetails);
                        upDate("Game Over");
                        g_scoreCards.save;
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

            auto lft = sceneManager.current.getInstanceByMask(vlft,g_shapeRect);
            auto rgt = sceneManager.current.getInstanceByMask(vrgt,g_shapeRect);
            auto u = sceneManager.current.getInstanceByMask(vu,g_shapeRect);
            auto dwn = sceneManager.current.getInstanceByMask(vdwn,g_shapeRect);

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
