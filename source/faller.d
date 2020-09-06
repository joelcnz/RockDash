module source.faller;

import foxid;

import source.app;

final class Faller : Instance {
    Image fallImg;

    this(Vec pos, string name) @safe {
        this.name = name;
        position = pos;
        ofsprite.image = (name == "rock" ? g_spriteList[SpriteGraph.rock] : g_spriteList[SpriteGraph.diamond]);
        shape = ShapeRectangle(Vec(0,0), Vec(g_stepSize, g_stepSize));
    }

    override void step() @safe {
        auto newPos = position + Vec(0,g_stepSize);
        if (newPos.inBounds) {
            auto obj = sceneManager.current.getInstanceByMask(newPos,
                        ShapeRectangle(Vec(1,1),Vec(g_stepSize-1,g_stepSize-1)));
            if (obj is null && inBounds(newPos)) {
                position = newPos;
            } else if (obj !is null && obj.name == "diamond_maker") {
                auto obj2 = sceneManager.current.getInstanceByMask(newPos + Vec(0,g_stepSize), // what's under the diamond maker
                    ShapeRectangle(Vec(1,1),Vec(g_stepSize-1,g_stepSize-1)));
                if (obj2 is null && (newPos + Vec(0,g_stepSize)).inBounds)
                    putObj(g_chars[name == "rock" ? SpriteGraph.diamond : SpriteGraph.rock],newPos + Vec(0,g_stepSize));
                this.destroy;
            }
        }
    }
}
