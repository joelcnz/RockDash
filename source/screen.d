//#here
module source.screen;

import foxid;

import source.app;

final class Piece : Instance {

    this(Vec pos, char c) @safe {
/+
            BmSDlsMdrRg
+/
        switch(c) with(SpriteIndex) {
            default: import std.conv : text; assert(0, text("unhandled char: ", c));
            case 'B': name = SpriteNames[brick]; break;
            case 'm': name = SpriteNames[mud]; break; //#here
            case 'S': name = SpriteNames[start]; break;
            case 'D': name = SpriteNames[shut_door]; break;
            case 'l': name = SpriteNames[bady_maker_left]; break;
            case 's': name = SpriteNames[aswitch]; break;
            case 'M': name = SpriteNames[diamond_maker]; break;
            case 'd': name = SpriteNames[diamond]; break;
            case 'r': name = SpriteNames[rock]; break;
            case 'R': name = SpriteNames[bady_maker_right]; break;
            case 'o': name = SpriteNames[door_open]; break;
            case 'g': name = SpriteNames[gap]; break;
        }
        auto obj = sceneManager.current.getInstanceByMask(pos,g_shapeRect);
        if  (obj !is null)
            obj.destroy;
        if (name != "gap") {
            position = pos;
            ofsprite.image = g_sprites[c];
            //if (name != "start")
                shape = ShapeRectangle(Vec(0,0), Vec(g_stepSize, g_stepSize));
        }
    }
}
