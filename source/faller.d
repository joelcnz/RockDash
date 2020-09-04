//#diamond is made and pops up even if there's something in the way
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
        auto obj = sceneManager.current.getInstanceByMask(newPos,
                    ShapeRectangle(Vec(1,1),Vec(g_stepSize-1,g_stepSize-1)));
        if (obj is null && inBounds(newPos) || (obj !is null && obj.name == "diamond_maker")) {
            foreach(i; 0 .. (obj !is null && obj.name == "diamond_maker") ? 2 : 1)
                position.y += g_stepSize;
            if (obj !is null && obj.name == "diamond_maker") {
                auto obj2 = sceneManager.current.getInstanceByMask(newPos + Vec(0,g_stepSize), // what's under the diamond maker
                    ShapeRectangle(Vec(1,1),Vec(g_stepSize-1,g_stepSize-1)));
                //#diamond is made and pops up even if there's something in the way
                if (obj2 !is null)
                    obj2.destroy;
                putObj(g_chars[SpriteGraph.diamond],position);
                this.destroy;
            }
        }
    }
}
