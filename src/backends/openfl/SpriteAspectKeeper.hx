package backends.openfl;

import Axis2D;
import a2d.Boundbox;
import a2d.Placeholder2D;
import a2d.Stage;
import a2d.Widget;
import al.core.AxisApplier;
import al.openfl.display.DrawcallDataProvider;
import al.openfl.display.FlashDisplayRoot;
import ec.CtxWatcher;
import macros.AVConstructor;
import openfl.display.Sprite;

enum abstract ScaleMode(Int) {
    var fit;
    var fit_vertical;
    var fit_horizontal;
    var overflow;
}

class SpriteAspectKeeper extends Widget {
    var spr:Sprite;
    var mask:Sprite;
    var bounds:a2d.Boundbox;
    var size = AVConstructor.create(Axis2D, 1., 1.);
    var pos = AVConstructor.create(Axis2D, 0., 0.);
    var ownSizeAppliers:AVector2D<AxisApplier>;
    var mode:ScaleMode;
    @:once var s:Stage;

    public function new(w:Placeholder2D, spr:Sprite, bounds = null, mode:ScaleMode = fit, hideOverflow = false) {
        this.mode = mode;
        var dp = DrawcallDataProvider.get(w.entity);
        new CtxWatcher(FlashDisplayRoot, w.entity);
        dp.views.push(spr);
        this.spr = spr;

        this.bounds = if (bounds == null) {
            var b = spr.getBounds(spr);
            new Boundbox(b.left, b.top, b.width, b.height);
        } else bounds;

        if (hideOverflow) {
            mask = new Sprite();
            mask.graphics.beginFill(0xffffff);
            mask.graphics.drawRect(0, 0, 2000, 2000);
            spr.mask = mask;
        }

        super(w);
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
        var scale:Float;
        switch mode {
            case overflow:
                scale = 0;
                for (a in Axis2D) {
                    var _scale = size[a] / bounds.size[a];
                    if (_scale > scale)
                        scale = _scale;
                }
            case fit:
                scale = 9999;
                for (a in Axis2D) {
                    var _scale = size[a] / bounds.size[a];
                    if (_scale < scale)
                        scale = _scale;
                }
            case fit_horizontal:
                var a = horizontal;
                scale = size[a] / bounds.size[a];
            case fit_vertical:
                var a = vertical;
                scale = size[a] / bounds.size[a];
        }
        for (a in Axis2D) {
            var free = size[a] - bounds.size[a] * scale;
            var pos = pos[a] + free / 2 - bounds.pos[a] * scale;
            apply(a, pos, scale);
            if (mask!=null) applyMask(a);
        }
    }

    function applyMask(axis:Axis2D) {
        var size = ph.axisStates[axis].getSize() * s.getWindowSize()[axis] / 2 / s.getAspectRatio()[axis];
        var pos = ph.axisStates[axis].getPos() * s.getWindowSize()[axis] / 2 / s.getAspectRatio()[axis];
        switch axis {
            case horizontal:
                mask.width = size;
                mask.x = pos;
            case vertical:
                mask.height = size;
                mask.y = pos;
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
