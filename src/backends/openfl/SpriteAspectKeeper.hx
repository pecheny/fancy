package backends.openfl;

import al.openfl.display.FlashDisplayRoot;
import al.openfl.display.DrawcallDataProvider;
import ec.CtxWatcher;
import Axis2D;
import a2d.Boundbox;
import a2d.Stage;
import a2d.Placeholder2D;
import al.core.AxisApplier;
import ec.Entity;
import macros.AVConstructor;
import openfl.display.Sprite;
import a2d.Widget;

class SpriteAspectKeeper extends Widget {
    var spr:Sprite;
    var bounds:a2d.Boundbox;
    var size = AVConstructor.create(Axis2D, 1., 1.);
    var pos = AVConstructor.create(Axis2D, 0., 0.);
    var ownSizeAppliers:AVector2D<AxisApplier>;
    @:once var s:Stage;

    public function new(w:Placeholder2D, spr:Sprite, bounds = null) {
        var dp = DrawcallDataProvider.get(w.entity);
        new CtxWatcher(FlashDisplayRoot, w.entity);
        dp.views.push(spr);
        super(w);
        this.spr = spr;
        this.bounds = if (bounds == null) {
            var b = spr.getBounds(spr);
            new Boundbox(b.left, b.top, b.width, b.height);
        } else bounds;

        for (a in Axis2D) {
            w.axisStates[a].addSibling(new KeeperAxisApplier(pos, size, this, a));
        }
    }

    override function init() {
        super.init();
        refresh();
    }

    public function refresh() {
        if (!_inited)
            return;
        var scale = 9999.;
        for (a in Axis2D) {
            var _scale = size[a] / bounds.size[a];
            if (_scale < scale)
                scale = _scale;
        }

        for (a in Axis2D) {
            var free = size[a] - bounds.size[a] * scale;
            var pos = pos[a] + free / 2;
            apply(a, pos, scale);
        }
    }

    inline function apply(a:Axis2D, pos:Float, scale:Float) {
        switch a {
            case horizontal:
                spr.x = w2scr(a, pos);
                spr.scaleX = w2scr(a, scale);
            case vertical:
                spr.y = w2scr(a, pos);
                spr.scaleY = w2scr(a, scale);
        }
        // trace(this.pos[a]  + " " + size[a]);
        // trace(spr.x  +" " + spr.scaleX  + " " + spr.width);
    }

    inline function w2scr(a, val:Float) {
        return val * s.getWindowSize()[a] / s.getAspectRatio()[a] / 2;
    }

    public function getApplier(a:Axis2D) {
        return ownSizeAppliers[a];
    }
}

class KeeperAxisApplier implements AxisApplier {
    var key:Axis2D;
    var keeper:SpriteAspectKeeper;

    var size:AVector2D<Float>;
    var pos:AVector2D<Float>;

    public function new(p, s, k, a) {
        this.pos = p;
        this.size = s;
        this.keeper = k;
        this.key = a;
    }

    public function apply(pos:Float, size:Float):Void {
        this.pos[key] = pos;
        this.size[key] = size;
        keeper.refresh();
    }
}
