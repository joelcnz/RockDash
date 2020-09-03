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
        auto objs = getInstanceArrayByMask(position + Vec(0,g_stepSize),shape);

        if (objs.length == 1 && objs[0].name == "gap") // drop if only a gap object there
            position.y += g_stepSize;
    }
}
