//#hack not work!
module io.load;

import source.app,
    source.screen,
    source.editor;

void load(string fileNameBase) {
    g_exitDoorPos = Vec(-1,-1);
    g_fileNameBase = fileNameBase;
    foreach(ref e; sceneManager.current.getList()) {
        e.destroy();
    }
    g_levelComplete = false;
    g_levelStartScore = g_score;
    g_levelDiamondsStart = g_diamonds;
    g_editMode = false;

    import core.stdc.stdio;
    import std.path: buildPath;
    import std.string;
    import std.file : exists;

    auto fileName = getFillName(fileNameBase);
    jm_backUp(fileName);
    FILE* f;
    if ((f = fopen(fileName.toStringz, "rb")) == null) {
        import std.stdio; writeln("load: '", fileName, "' can't be opened");
        return;
    }
    scope(exit)
        fclose(f);
    writeln("Load: ", fileName);
    ubyte ver;
    fread(&ver, 1, ubyte.sizeof, f); // 1 version
    import std.string : split;
    mixin(tce("ver"));
    int count;
    fread(&count, 1, int.sizeof, f);
    mixin(tce("count"));
    foreach(const e; 0 .. count) {
        char c;
        float x,y;
        fread(&c, 1, char.sizeof, f);
        fread(&x, 1, float.sizeof, f);
        fread(&y, 1, float.sizeof, f);
        putObj(c, Vec(x,y));
    }
    sceneManager.current.add(new Editor());
    // version 1
    if (ver == 1) {
        ubyte pus;
        fread(&pus, 1, ubyte.sizeof, f);
        foreach(pu; 0 .. pus) {
            char chr;
            Vec pos;
            fread(&chr, 1, char.sizeof, f);
            fread(&pos.x, 1, float.sizeof, f);
            fread(&pos.y, 1, float.sizeof, f);
            if (g_aswitch.active)
                g_aswitch.addPopUp(pos, chr);
        }
    }
    g_editMode = true;
    immutable levelLoadedMessage = text(fileNameBase, " loaded");
    g_messageUpdate(levelLoadedMessage);
    upDate(levelLoadedMessage);
    if (g_startPos.inBounds)
        putObj('S', g_startPos);
    g_hackLevelJustLoaded = true; //#hack not work!
} // load
