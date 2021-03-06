module source.aswitch;

import source.app,
    source.faller,
    source.explosion;

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
        import std.algorithm : del = remove;
        import std.array : array;
        popUps = popUps.del!(e => e.pos == pos).array;
    }

    void activate() {
        g_editMode = true;
        foreach(const pu; popUps) {
            auto obj = sceneManager.current.getInstanceByMask(pu.pos,g_shapeRect);
            if (obj !is null) {
                if (obj.name == "bady" && pu.chr != 'g') {
                    sceneManager.current.add(new Explosion(obj.position));
                    immutable switchPopUpPoints = 700;
                    g_messageUpdate("Switch destroyed bady - "~switchPopUpPoints.to!string~" points");
                    g_score += switchPopUpPoints;
                    extraLifeScoreUpdate(switchPopUpPoints);
                    auto objMkr = sceneManager.current.getInstanceByMask(g_badyMakerPos,g_shapeRect);
                    if (objMkr.name == "bady_maker_left" || objMkr.name == "bady_maker_right") {
                        auto badyMaker = (objMkr.name == "bady_maker_left" ? "bmleft" : "bmright");
                        obj.position = objMkr.position + Vec(badyMaker == "bmleft" ? -g_stepSize : g_stepSize,0);
                    } else
                        obj.destroy;
                } else
                    obj.destroy;
            }
            if (pu.chr == 'r' || pu.chr == 'd')
                sceneManager.current.add(new Faller(pu.pos, pu.chr == 'r' ? "rock" : "diamond"));
            else
                putObj(pu.chr, pu.pos);
            import std.string; mixin(tce("pu.chr pu.pos".split));
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
