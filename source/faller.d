//#the following does nothing
module source.faller;

import foxid;

import source.app,
    source.bady;

final class Faller : Instance {
    Sound fall;
    bool falling;

    this(Vec pos, string name) @safe {
        this.name = name;
        position = pos;
        ofsprite.image = (name == "rock" ? g_spriteList[SpriteIndex.rock] : g_spriteList[SpriteIndex.diamond]);
        shape = ShapeRectangle(Vec(0,0), Vec(g_stepSize, g_stepSize));
    }

    override void step() @trusted {
        if (! g_doMoves)
            return;
        auto newPos = position + Vec(0,g_stepSize);
        if (newPos.inBounds) {
            auto obj = sceneManager.current.getInstanceByMask(newPos,g_shapeRect);
            if (obj is null && inBounds(newPos)) {
                position = newPos;
                if (! falling ) {
                    if (name == "rock")
                        g_rockFall.play(false);
                    else
                        g_diamondStartFall.play(false);
                    falling = true;
                }
            } else {
                if (falling) {                   
                    falling = false;
                    if (name == "rock")
                        g_rockFall.play(false);
                    else
                        g_diamondStop.play(false);
                }
                if (obj !is null) {
                    if (g_hackLevelJustLoaded) {
                        g_hackLevelJustLoaded = false;
                        return;
                    }
                    switch(obj.name) {
                        default:
                        break;
                        case "diamond_maker":
                            auto obj2 = sceneManager.current.getInstanceByMask(newPos + Vec(0,g_stepSize),g_shapeRect); // what's under the diamond maker
                            if (obj2 is null && (newPos + Vec(0,g_stepSize)).inBounds) {
                                sceneManager.current.add(new Faller(newPos + Vec(0,g_stepSize), name == "rock" ? "diamond" : "rock"));
                                g_diamondMaker.play(false);
                            }
                            this.destroy;
                            g_hackForDiamondMakerBool = true;
                            immutable points = 30;
                            g_score += points;
                            extraLifeScoreUpdate(points);
                            g_messageUpdate(text("Diamond maker used - ", points, " points"));
                        break;
                        case "bady":
                            immutable points = 100;
                            g_score += points;
                            extraLifeScoreUpdate(points);
                            g_messageUpdate(text("Bady blown - ", points, " points"));
                            this.destroy;
                            g_explodePoint = obj.position;
                            import std.range : iota;
                            bool isBadyMakerSafe = true;
                            foreach(y; iota(g_explodePoint.y - g_stepSize, g_explodePoint.y + g_stepSize + 1, g_stepSize))
                                foreach(x; iota(g_explodePoint.x - g_stepSize, g_explodePoint.x + g_stepSize + 1, g_stepSize)) {
                                    auto tst = sceneManager.current.getInstanceByMask(Vec(x,y),g_shapeRect);
                                    if (tst !is null && Vec(x,y).inBounds && (tst.name == "bady_maker_left" || tst.name == "bady_maker_right")) {
                                        isBadyMakerSafe = false;
                                        immutable blowBadyPoints = 400;
                                        g_score += blowBadyPoints;
                                        extraLifeScoreUpdate(blowBadyPoints);
                                        g_messageUpdate(text("Bady maker blown - ", blowBadyPoints, " points"));
                                        break;
                                    }
                                }
                            obj.destroy; // wipe out bady
                            if (isBadyMakerSafe) {
                                auto bdyMkr = sceneManager.current.getInstanceByMask(g_badyMakerPos,g_shapeRect);
                                
                                if (bdyMkr !is null && (bdyMkr.name == "bady_maker_left" || bdyMkr.name == "bady_maker_right")) {
                                    sceneManager.current.add(new Bady(g_badyMakerPos + Vec(bdyMkr.name == "bady_maker_left" ? -g_stepSize : g_stepSize,0)));
                                }
                            }
                        break;
                    }
                } // if obj !is null
            }
        } else {
            if (falling) {                   
                falling = false;
                if (name == "rock")
                    g_rockFall.play(false);
                else
                    g_diamondStop.play(false);
            }
        }
    }
}
