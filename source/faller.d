module source.faller;

import foxid;

import source.app;

final class Faller : Instance {
    Image fallImg;

    Sound fall;
    bool falling;

    this(Vec pos, string name) @safe {
        this.name = name;
        position = pos;
        ofsprite.image = (name == "rock" ? g_spriteList[SpriteGraph.rock] : g_spriteList[SpriteGraph.diamond]);
        shape = ShapeRectangle(Vec(0,0), Vec(g_stepSize, g_stepSize));
        
        fall = new Sound();
        fall.load("assets/boulder.wav", "fall");
    }

    override void step() @safe {
        if (! g_doMoves)
            return;
        auto newPos = position + Vec(0,g_stepSize);
        if (newPos.inBounds) {
            auto obj = sceneManager.current.getInstanceByMask(newPos,g_shapeRect);
            if (obj is null && inBounds(newPos)) {
                position = newPos;
                if (! falling && (name == "rock" || name == "diamond")) {
                    if (name == "rock")
                        fall.play(false);
                    falling = true;
                    auto abovePos = position - Vec(0,g_stepSize * 2);
                    if (abovePos.inBounds) {
                        auto objAbove = sceneManager.current.getInstanceByMask(abovePos,g_shapeRect);
                        if (objAbove !is null && (objAbove.name == "rock" || objAbove.name == "diamond")) {
                            auto fname = objAbove.name;
                            objAbove.destroy;
                            sceneManager.current.add(new Faller(abovePos, fname));
                        }
                    }
                }
            } else {
                if (falling && name == "rock") {
                    falling = false;
                    fall.play(false);
                }
                if (obj !is null) {
                    switch(obj.name) {
                        default:
                            putObj(name == "rock" ? 'r' : 'd', position);
                            this.destroy;
                        break;
                        case "diamond_maker":
                            auto obj2 = sceneManager.current.getInstanceByMask(newPos + Vec(0,g_stepSize),g_shapeRect); // what's under the diamond maker
                            if (obj2 is null && (newPos + Vec(0,g_stepSize)).inBounds)
                                sceneManager.current.add(new Faller(newPos + Vec(0,g_stepSize), name == "rock" ? "diamond" : "rock"));
                                //putObj(g_chars[name == "rock" ? SpriteGraph.diamond : SpriteGraph.rock],newPos + Vec(0,g_stepSize));
                            this.destroy;
                        break;
                        case "bady":
                            g_explodePoint = obj.position;
                            obj.position = g_badyMakerPos;
                        break;
                    }
                }
            }
        }
    }
}
