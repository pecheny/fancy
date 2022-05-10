package widgets;
import al.al2d.Axis2D;
import al.al2d.Widget2D;
import data.aliases.AttribAliases;
import ec.CtxWatcher;
import gl.sets.ColorSet;
import graphics.shapes.ProgressBar;
import graphics.ShapeWidget;
import haxe.io.Bytes;
import input.al.WidgetHitTester;
import input.core.HitTester;
import input.core.SwitchableInputTarget;
import input.ec.binders.SwitchableInputBinder;
import input.Point;
import mesh.MeshUtilss;
import mesh.providers.AttrProviders.SolidColorProvider;
import utils.Mathu;
class Slider extends ShapeWidget<ColorSet> {
    public var q:ProgressBar<ColorSet>;
    var color:Int;
    var cp:SolidColorProvider;
    var mainAxis:Axis2D;
    var progress:Float;
    var handler:Float->Void;

    public function new(w:Widget2D, direction:Axis2D, h) {
        this.handler = h;
        this.color = 0xffffff;
        this.mainAxis = direction;
        buffer = Bytes.alloc(4 * ColorSet.instance.stride);
        posWriter = ColorSet.instance.getWriter(AttribAliases.NAME_POSITION);
        cp = SolidColorProvider.fromInt(color, 128);
        super(ColorSet.instance, w);
    }

    public function withProgress(v) {
        progress = v;
        if (q != null)
            q.setVal(mainAxis, v);
        if(handler!=null)
            handler(v);
        return this;
    }

    override function createShapes() {
        var aspectRatio = ratioProvider.getFactorsRef();
        q = new ProgressBar(ColorSet.instance, transformer.transformValue);
        q.setVal(mainAxis, progress);
        children.push(q);
        var inp = new SliderInput(w, cast ratioProvider, mainAxis, (v) -> withProgress(v));
        w.entity.addComponentByType(SwitchableInputTarget, inp);
        new CtxWatcher(SwitchableInputBinder, w.entity);
    }

    override function onShapesDone() {
        setColor(color);
    }


    public function setColor(c:Int) {
        cp.setColor(c);
        MeshUtilss.writeInt8Attribute(attrs, buffer, AttribAliases.NAME_COLOR_IN, 0, vertsCount, cp.getValue);
    }
}

class SliderInput implements SwitchableInputTarget<Point> {
    var hitTester:HitTester<Point>;
    var pos:Point;
    var pressed = false;
    var toLocal:ToWidgetSpace;
    var a:Axis2D;
    var handler:Float -> Void;

    public function new(w, stage, a, h) {
        this.hitTester = new WidgetHitTester(w);
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
            case horizontal : p.x;
            case vertical : p.y;
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
    var w:Widget2D;

    public function new(w, s) {
        this.w = w;
    }

    public inline function transformValue(c:Axis2D, input:Float):Float {
        return (input - w.axisStates[c].getPos()) /
        w.axisStates[c].getSize();
    }
}