module source.screen;

import foxid;

import source.app;

final class Piece : Instance {

    this(Vec pos, char c) @safe {
/+
enum SpriteGraph {brick, mud, start, shut_door, bady_maker_left, up, left, down, right, aswitch, diamond_maker,
	diamond, rock, bady_maker_right, blow0, blow1, blow2, blow3, bady_vert, bady_hor, door_open, blow4, blow5, blow6, gap}
			g_sprites['B'] = g_spriteList[brick];
			g_sprites['m'] = g_spriteList[mud];
			g_sprites['S'] = g_spriteList[start];
			g_sprites['D'] = g_spriteList[shut_door];
			g_sprites['l'] = g_spriteList[bady_maker_left];
			g_sprites['s'] = g_spriteList[aswitch];
			g_sprites['M'] = g_spriteList[diamond_maker];
			g_sprites['d'] = g_spriteList[diamond];
			g_sprites['r'] = g_spriteList[rock];
			g_sprites['g'] = g_spriteList[gap];

            BmSDlsMdrg
+/
        switch(c) with(SpriteGraph) {
            default: import std.stdio; writeln("unhandled char: ", c); break;
            case 'B': name = SpriteNames[brick]; break;
            case 'm': name = SpriteNames[mud]; break;
            case 'S': name = SpriteNames[start]; break;
            case 'D': name = SpriteNames[shut_door]; break;
            case 'l': name = SpriteNames[bady_maker_left]; break;
            case 's': name = SpriteNames[aswitch]; break;
            case 'M': name = SpriteNames[diamond_maker]; break;
            case 'd': name = SpriteNames[diamond]; break;
            case 'r': name = SpriteNames[rock]; break;
            case 'R': name = SpriteNames[bady_maker_right]; break;
            case 'g': name = SpriteNames[gap]; break;
        }
        position = pos;
        ofsprite.image = g_sprites[c];
    }
}
