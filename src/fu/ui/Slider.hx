package fu.ui;

import fu.Signal;
import a2d.AspectRatioProvider;
import a2d.Widget;
import a2d.Placeholder2D;
import al2d.WidgetHitTester2D;
import ec.CtxWatcher;
import ecbind.InputBinder;
import fu.graphics.ShapeWidget;
import gl.sets.ColorSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.ProgressBar;
import shimp.InputSystem;
import shimp.Point;
import utils.Mathu;

class FlatSlider {
    public static function withFlat(s:SliderInput) {
        var sw = new ShapeWidget(ColorSet.instance, s.ph, true);
        var q = new ProgressBar(ColorSet.instance);
        q.setVal(s.mainAxis, s.value);
        s.onChange.listen(v -> q.setVal(s.mainAxis, v));
        sw.addChild(q);
        sw.manInit();
        new ShapesColorAssigner(ColorSet.instance, 0xffffff, sw.getBuffer());
        return s;
    }
}

class SliderInput implements InputSystemTarget<Point> extends Widget {
    public var onChange(default, null):Signal<Float->Void> = new Signal();
    public var onRelease(default, null):Signal<Void->Void> = new Signal();
    public var value(default, null):Float;
    public var mainAxis(default, null):Axis2D;

    var hitTester:HitTester<Point>;
    var pos:Point;
    var pressed = false;
    var toLocal:ToWidgetSpace;

    public function new(ph, a) {
        super(ph);
        this.hitTester = new WidgetHitTester2D(ph);
        this.toLocal = new ToWidgetSpace(ph);
        this.mainAxis = a;
        ph.entity.addComponentByType(InputSystemTarget, this);
        new CtxWatcher(InputBinder, ph.entity);
    }

    public function withProgress(v) {
        value = v;
        onChange.dispatch(v);
        return this;
    }

    public function setPos(pos:Point):Void {
        this.pos = pos;
        if (pressed) {
            var v = toLocal.transformValue(mainAxis, posVal(pos, mainAxis));
            withProgress(Mathu.clamp(v, 0, 1));
        }
    }

    inline function posVal(p:Point, a:Axis2D) {
        return switch a {
            case horizontal: p.x;
            case vertical: p.y;
        }
    }

    public function isUnder(pos:Point):Bool {
        return hitTester.isUnder(pos);
    }

    public function setActive(val:Bool):Void {
        if (!val)
            pressed = false;
    }

    public function press():Void {
        pressed = true;
        setPos(pos);
    }

    public function release():Void {
        pressed = false;
        onRelease.dispatch();
    }
}

class ToWidgetSpace {
    var w:Placeholder2D;

    public function new(w) {
        this.w = w;
    }

    public inline function transformValue(c:Axis2D, input:Float):Float {
        return (input - w.axisStates[c].getPos()) / w.axisStates[c].getSize();
    }
}
