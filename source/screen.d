module source.screen;

import foxid;

import source.app;

final class Piece : Instance {

    this(Vec pos, char c) @safe {
        import std.string : format;

        name = format("piece%02s,%02s", pos.x / g_stepSize, pos.y / g_stepSize);
        position = pos;
        ofsprite.image = g_sprites[c];
    }
}
