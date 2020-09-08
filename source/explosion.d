module source.explosion;

import source.app;

final class Explosion : Instance {
    int frame;

    Image[] images;

    this(Vec pos) {
        position = pos;

        with(SpriteGraph)
            images = [g_spriteList[blow0],
                g_spriteList[blow1],
                g_spriteList[blow2],
                g_spriteList[blow3],
                g_spriteList[blow4],
                g_spriteList[blow5],
                g_spriteList[blow6]];
        
        ofsprite.image = images[0];
        g_blowUp.play(false);
    }

    override void step() @safe {
        if (! g_doMoves)
            return;
        frame += 1;
        if (frame == 6 + 1) {
            this.destroy;
        } else
            ofsprite.image = images[frame];
    }
}
