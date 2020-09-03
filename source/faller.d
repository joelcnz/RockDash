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
        if (position.y + g_stepSize < g_stepSize * 12 &&
                sceneManager.current.getInstanceByMask(position + Vec(0,g_stepSize),
                    ShapeRectangle(Vec(1,1),Vec(g_stepSize-1,g_stepSize-1))) is null)
            position.y += g_stepSize;

//        if (objs.length == 1 && objs[0].name == "gap") // drop if only a gap object there
//            position.y += g_stepSize;
    }
}
