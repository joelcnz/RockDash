module source.dasher;

import foxid;

import source.app;

final class Dasher : Instance {
    this() @trusted {
        name = "Dasher";

        Image[] cadrs = loader.load!ImageSurface("assets/rockdash5.png").image.strip(Vec(0,0), 24, 24).array;

        ofsprite.image = cadrs[5];
        visible = true;

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
                position.x += 24;
            break;
            case Key.left:
                position.x -= 24;
            break;
            case Key.up:
                position.y -= 24;
            break;
            case Key.down:
                position.y += 24;
            break;
        }
    }
}
