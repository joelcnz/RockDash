//#need a new sprite
/+
module source.exitdoor;

import source.app;

import source.dasher,
    source.screen;

final class ExitDoor : Instance {
    int frame;
    bool doorOpen;
    enum {closed,opening,open}
    Vec dasherPos;

    Image[] images;

    this(Vec pos) {
        name = "Door";
        position = pos;

        with(SpriteIndex)
            images = [g_spriteList[shut_door],
                g_spriteList[door_open], //#need a new sprite
                g_spriteList[door_open]];
        
        ofsprite.image = images[0];
    }

    void updateDasherPos(Dasher dasher) {
        dasherPos = dasher.position;
    }

    override void step() @safe {
        if (! g_doMoves || g_levelComplete || ! position.inBounds)
            return;
        if (doorOpen && position == dasherPos) {
            g_levelComplete = true;
            import std.stdio; writeln("Level complete!");
            ofsprite.image = images[closed];
        } else if (g_diamonds == 10 && ! doorOpen) {
            frame += 1;
            if (frame == 2 + 1) {
                doorOpen = true;
            } else
                ofsprite.image = images[frame];
        }
    }
}
+/
