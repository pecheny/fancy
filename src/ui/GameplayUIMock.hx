package ui;

import al.al2d.Placeholder2D;
import al.al2d.Widget2DContainer;
import ec.Entity;
import widgets.Button;
import widgets.Widget;

using al.Builder;
using transform.LiquidTransformer;
using widgets.utils.Utils;

interface GameMock {
    function pause(v:Bool):Void;
}

class GameplayPauseScreen extends Widget {
    var pnl:Widget2DContainer;
    var game:GameMock;
    @:once var fb:FuiBuilder;

    public function new(w:Placeholder2D,  g) {
        super(w);
        this.game = g;
    }

    override function init() {
        super.init();
        pnl = Builder.createContainer(ph, vertical, Forward);
        fb.makeClickInput(ph);
        // var fb = root.getComponentUpward(FuiBuilder);
        var b = fb.placeholderBuilder;
        pnl.withChildren([
            b.h(pfr, 1).v(pfr, 1).b(),
            new Button(b.h(pfr, 1).v(pfr, 1).b().withLiquidTransform(fb.ar.getAspectRatio()), () -> game.pause(false), "||", fb.s("fit")).ph,
            b.h(pfr, 1).v(pfr, 1).b(),
        ]);
    }
}

class GameplayScreen extends Widget {
    var pnl:Widget2DContainer;
    var game:GameMock;
    @:once var fb:FuiBuilder;

    public function new(w:Placeholder2D, g) {
        super(w);
        this.game = g;
    }

    override function init() {
        pnl = Builder.createContainer(ph, vertical, Forward);
        // var fb = root.getComponentUpward(FuiBuilder);
        var b = fb.placeholderBuilder;
        pnl.withChildren([topBar(b.v(sfr, 0.05).b("top"), fb)]);
    }

    function topBar(w:Placeholder2D, fb:FuiBuilder) {
        var b = fb.placeholderBuilder;
        fb.makeClickInput(w);
        w.createContainer(horizontal, Backward).withChildren([
            new Button(b.h(sfr, .1).v(pfr, 1).b().withLiquidTransform(fb.ar.getAspectRatio()), () -> game.pause(true), "||", fb.s("fit")).ph,
        ]);
        return w;
    }
}
