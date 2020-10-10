module io.save;

import source.app,
    source.screen;

void save(string fileNameBase) {
    g_fileNameBase = fileNameBase;
    import core.stdc.stdio;
    import std.path: buildPath;
    import std.string;

    foreach(ref e; sceneManager.current.getList())
        if (e.name == "dasher")
            e.destroy;
    //editMode = ;
    putObj('S', g_startPos);
    
    auto fileName = getFillName(fileNameBase);
    jm_backUp(fileName);
    FILE* f;
    if ((f = fopen(fileName.toStringz, "wb")) == null) {
        import std.stdio; writeln("save: '", fileName, "' can't be opened");
        return;
    }
    scope(exit)
        fclose(f);
    writeln("Save: ", fileName);
    ubyte ver = 1;
    fwrite(&ver, 1, ubyte.sizeof, f); // 1 version
    import std.string : split;
    mixin(tce("ver"));
    import std.algorithm : canFind;
    int count;
    foreach(const e; sceneManager.current.getList())
        if (SpriteNames.canFind(e.name)) {
            count += 1;
        }
    fwrite(&count, 1, int.sizeof, f);
    mixin(tce("count"));
    foreach(const e; sceneManager.current.getList()) {
        if ((SpriteNames ~ "Door").canFind(e.name)) {
            char c;
            foreach(i, n; SpriteNames)
                if (e.name == n) {
                    c = g_chars[i];
                    fwrite(&c, 1, char.sizeof, f);
                    fwrite(&e.position.x, 1, float.sizeof, f);
                    fwrite(&e.position.y, 1, float.sizeof, f);
                    break;
                }
        }
    }
    // version 1
    auto pus = g_aswitch.popUps.length;
    fwrite(&pus, 1, ubyte.sizeof, f);
    foreach(pu; g_aswitch.popUps) {
        char c = pu.chr;
        fwrite(&c, 1, char.sizeof, f);
        fwrite(&pu.pos.x, 1, float.sizeof, f);
        fwrite(&pu.pos.y, 1, float.sizeof, f);
    }
    g_messageUpdate(text(fileNameBase, " saved"));
} // save
