module source.editor;

import source.app;

final class Editor : Instance {
    Image payload;
    SpriteGraph sprGraph;
    Instance marked;

    this() @safe {
        name = "editor";

        payload = g_spriteList[sprGraph = SpriteGraph.rock];
        depth = 10;
    }

    override void event(Event event) @safe {
        position = event.getMousePosition();

        auto obj = sceneManager.current.getInstanceByMask(position.snapToGrid,
                    ShapeRectangle(Vec(1,1),Vec(g_stepSize-1,g_stepSize-1)));
        if (event.getKeyDown == 'b') {
            if (obj !is null) {
                foreach(i, n; SpriteNames)
                    if (n == obj.name) {
                        sprGraph = cast(SpriteGraph)i;
                        payload = g_spriteList[sprGraph];
                    }
            } else {
                payload = null;
                sprGraph = SpriteGraph.gap;
            }
        }

        if (event.isMouseLeftDown && inBounds(position)) {
            putObj(g_chars[sprGraph], position.snapToGrid);
            if (obj !is null)
                marked = obj;
        }
    }

    override void step() @trusted {
        if (marked && marked.name != "dasher") {
            marked.destroy;
            marked = null;
        }
    }

    override void draw(Display graph) @safe {
        auto pos = snapToGrid(position);

        graph.drawRect(pos, pos + Vec(g_stepSize, g_stepSize), Color(0,180,255), false);
        if (payload !is null)
            graph.draw(payload, Vec(0, g_stepSize * 13));
        graph.drawRect(Vec(0, g_stepSize * 13), Vec(g_stepSize, g_stepSize * 14 - 1), Color(180,255,0), false);
    }
}
