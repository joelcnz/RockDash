module source.aswitch;

import source.app;

struct PopUp {
    Vec pos;
    char chr;
}

struct ASwitch {
    Vec pos;

    PopUp[] popUps;

    this(Vec pos)  {
        this.pos = pos;
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
            auto obj = sceneManager.current.getInstanceByMask(pu.pos,
                            ShapeRectangle(Vec(1,1),Vec(g_stepSize-1,g_stepSize-1)));
            if (obj !is null)
                obj.destroy;
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

/+
final class PopUp : Instance {
    Image popImage;

    this(Vec pos, char c) {
        name = g_names[c];
        position = pos;
        popImage = g_sprites[c];
        depth = 5;
    }

    override void draw(Display graph) {
        super.draw(graph);
        if (g_aswitchEditing) {
            graph.drawRect(position, position + Vec(g_stepSize, g_stepSize), Color(255,64,64), false);
        }
    }
}
+/
