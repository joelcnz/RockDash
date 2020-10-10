module source.editor;

import source.app,
    source.dasher;

/++
Construction editor for making levels
+/
final class Editor : Instance {
    Image payload; /// 
    SpriteIndex sprIndex;
    Instance marked;
    Vec currentItemPos;

    this() @safe {
        name = "editor";

        payload = g_spriteList[sprIndex = SpriteIndex.brick];
        depth = 99;

        currentItemPos = Vec(0, g_stepSize * 13);
    }

    
    override void event(Event event) @safe {
        position = event.getMousePosition();
        if (! g_editMode)
            return;
        auto obj = sceneManager.current.getInstanceByMask(position.snapToGrid,g_shapeRect);
        if (event.getKeyDown == 'b') {
            if (obj !is null) {
                foreach(i, n; SpriteNames)
                    if (n == obj.name) {
                        sprIndex = cast(SpriteIndex)i;
                        payload = g_spriteList[sprIndex];
                    }
            } else {
                payload = null;
                sprIndex = SpriteIndex.gap;
            }
        }
        if (event.getKeyDown == 'q') {
            g_aswitchEditing = ! g_aswitchEditing;
            mixin(tce("g_aswitchEditing"));
        }
    }

    /// Handle placing items on map and items for switch
    override void step() @trusted {
        if (! g_editMode)
            return;
        // clear space
        if (marked !is null && marked.name != "dasher") {
            import std.algorithm : canFind;
            if (SpriteNames.canFind(marked.name))
                marked.destroy;
            marked = null;
        }
        //SDL_Event ev = event._sdl_handle();
        //if (ev.type == SDL_MOUSEBUTTONDOWN
        if ((g_aswitchEditing && g_keys[SDL_SCANCODE_V].keyTrigger) || (! g_aswitchEditing && g_keys[SDL_SCANCODE_V].keyPressed))
            if (inBounds(position)) {
                auto obj = sceneManager.current.getInstanceByMask(position.snapToGrid,g_shapeRect);
                //g_editMode = true;
                putObj(g_chars[sprIndex], position.snapToGrid);
                if (! g_aswitchEditing && obj !is null)
                    marked = obj;
            }
        if (g_aswitchEditing && g_keys[SDL_SCANCODE_W].keyPressed) {
            g_aswitch.removePopUp(position.snapToGrid);
        }
    }

    /++
    Draw current mouse space, and current item; also switch popup locations
    +/
    override void draw(Display graph) @safe {
        if (payload !is null)
            graph.draw(payload, currentItemPos);
        graph.drawRect(Vec(0, g_stepSize * 13), Vec(g_stepSize, g_stepSize * 14), Color(180,255,0), false);
        if (! g_editMode)
            return;
        auto pos = snapToGrid(position);
        graph.drawRect(pos, pos + Vec(g_stepSize, g_stepSize), Color(0,180,255), false);
        graph.draw(g_spriteList[SpriteIndex.start],g_startPos);
    }
}
