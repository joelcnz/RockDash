module source.dasher;

import foxid;

import source.app;

final class Dasher : Instance {

    Image dasherUp;
    Image dasherDown;
    Image dasherLeft;
    Image dasherRight;

    this() @trusted {
        name = "Dasher";

        dasherUp = g_spriteList[SpriteGraph.up];
        dasherDown = g_spriteList[SpriteGraph.down];
        dasherLeft = g_spriteList[SpriteGraph.left];
        dasherRight = g_spriteList[SpriteGraph.right];

        ofsprite.image = dasherUp;

        position = Vec(5 * g_stepSize, 5 * g_stepSize);

/+
        shape = ShapeMulti([
			ShapeRectangle(Vec(7*24,0),Vec(7*24 + 24,24))
        ]);
+/
    }

    override void event(Event event) @safe {
        switch(event.getKeyDown) {
            default: break;
            case Key.right:
                ofsprite.image = dasherRight;
                position.x += 24;
            break;
            case Key.left:
                ofsprite.image = dasherLeft;
                position.x -= 24;
            break;
            case Key.up:
                ofsprite.image = dasherUp;
                position.y -= 24;
            break;
            case Key.down:
                ofsprite.image = dasherDown;
                position.y += 24;
            break;
        }
    }
}
