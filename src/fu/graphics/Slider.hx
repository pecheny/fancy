package fu.graphics;
import al2d.WidgetHitTester2D;
import data.aliases.AttribAliases;
import ec.CtxWatcher;
import ecbind.InputBinder;
import format.png.Data.Color;
import gl.sets.ColorSet;
import graphics.ShapesColorAssigner;
import mesh.providers.AttrProviders.SolidColorProvider;
import shimp.InputSystem;
import shimp.Point;
import utils.Mathu;

class Slider extends ShapeWidget<ColorSet> {
    public var q:ProgressBar<ColorSet>;

    var mainAxis:Axis2D;
    var progress:Float;
    var handler:Float->Void;

    public function new(w:Placeholder2D, direction:Axis2D, h) {
        this.handler = h;
        this.mainAxis = direction;
        super(ColorSet.instance, w);
        new ShapesColorAssigner(ColorSet.instance, 0xffffff, getBuffer());
    }

    public function withProgress(v) {
        progress = v;
        if (q != null)
            q.setVal(mainAxis, v);
        if (handler != null)
            handler(v);
        return this;
    }

    override function createShapes() {
        var aspectRatio = ratioProvider.getAspectRatio();
        q = new ProgressBar(ColorSet.instance);
        q.setVal(mainAxis, progress);
        addChild(q);
        var inp = new SliderInput(ph, cast ratioProvider, mainAxis, (v) -> withProgress(v));
        ph.entity.addComponentByType(InputSystemTarget, inp);
        new CtxWatcher(InputBinder, ph.entity);
    }
}

class SliderInput implements InputSystemTarget<Point> {
    var hitTester:HitTester<Point>;
    var pos:Point;
    var pressed = false;
    var toLocal:ToWidgetSpace;
    var a:Axis2D;
    var handler:Float->Void;

    public function new(w, stage, a, h) {
        this.hitTester = new WidgetHitTester2D(w);
        this.toLocal = new ToWidgetSpace(w, stage);
        this.handler = h;
        this.a = a;
    }

    public function setPos(pos:Point):Void {
        this.pos = pos;
        if (pressed) {
            var v = toLocal.transformValue(a, posVal(pos, a));
            handler(Mathu.clamp(v, 0, 1));
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
    }
}

class ToWidgetSpace {
    var w:Placeholder2D;

    public function new(w, s) {
        this.w = w;
    }

    public inline function transformValue(c:Axis2D, input:Float):Float {
        return (input - w.axisStates[c].getPos()) / w.axisStates[c].getSize();
    }
}
