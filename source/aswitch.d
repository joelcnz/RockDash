module source.aswitch;

import source.app,
    source.faller;

struct PopUp {
    Vec pos;
    char chr;
}

struct ASwitch {
    Vec pos;
    PopUp[] popUps;
    bool active;

    this(Vec pos)  {
        this.pos = pos;
        active = true;
    }

    void addPopUp(Vec pos, char chr) {
        popUps ~= PopUp(pos, chr);
    }

    void removePopUp(Vec pos) {
        /+
        foreach(i, e; popUps)
            if (e.pos == pos) {
                popUps = popUps[0 .. i] ~ popUps[i + 1 .. $];
                break;
            }
        +/
        import std.algorithm : del = remove;
        import std.array : array;
        popUps = popUps.del!(e => e.pos == pos).array;
    }

    void activate() {
        g_editMode = true;
        foreach(const pu; popUps) {
            auto obj = sceneManager.current.getInstanceByMask(pu.pos,g_shapeRect);
            if (obj !is null)
                obj.destroy;
            if (pu.chr == 'r' || pu.chr == 'd')
                sceneManager.current.add(new Faller(pu.pos, pu.chr == 'r' ? "rock" : "diamond"));
            else
                putObj(pu.chr, pu.pos);
            import std.string; mixin(trace("pu.chr pu.pos".split));
        }
        popUps.length = 0;
        g_editMode = false;
    }

    void draw(Display graph) {
        foreach(pu; popUps)
            graph.drawRect(pu.pos + Vec(1,1), pu.pos + Vec(g_stepSize - 1, g_stepSize - 1), Color(255,128,128), false);
        graph.drawRect(pos + Vec(1,1), pos + Vec(g_stepSize - 1, g_stepSize - 1), Color(255,128,128), false);
    }
}
