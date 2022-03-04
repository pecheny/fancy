package transform;
import IGT.IGraphicsTransformApplier;
import IGT.IGraphicsTransform;
import al.al2d.Axis2D;
import al.al2d.Boundbox;
import al.al2d.Widget2D.AxisCollection2D;
import al.core.AxisApplier;
import Array;
import haxe.ds.ReadOnlyArray;
import transform.AspectRatio;
using transform.GAspectTransform.BoundboxConverters;


class GraphicTransformApplierBase {
    var appliers:AxisCollection2D<IGAxisApplier>;
    var children:Array<IGraphicsTransform> = [];
    public function addChild<T:IGraphicsTransform>(tr:T):T {
        children.push(tr);
        return tr;
    }

    public function getAxisApplier(a:Axis2D):AxisApplier {
        if (appliers == null)
            appliers = new AxisCollection2D();
        if (appliers.hasValueFor(a))
            return appliers[a];
        var ap = createApplier(a);
        appliers[a] = ap;
        return ap ;
    }

    function createApplier(a:Axis2D):IGAxisApplier {
        throw "n/a";
    }

    public function reapplyAll() {
        for (a in Axis2D.keys)
            applyContainers(a, appliers[a].targetTransform);
    }

    public function applyContainers(axisIndex:Axis2D, targetTransform) {
        for (c in children)
            c.applyTransform(axisIndex, targetTransform);
    }
}

class GraphicsTransformApplier extends GraphicTransformApplierBase implements IGraphicsTransformApplier {
    public var pos:Array<Float> = [0, 0];
    public var size:Array<Float> = [1, 1];
    var aspects:AspectRatio;
    var bounds:Boundbox = new Boundbox();

    public function new(aspects:ReadOnlyArray<Float>) {
        this.aspects = aspects;
    }

    public function setBounds(x, y, w, h) {
        bounds.set(x, y, w, h);
    }
}

//todo make own boundbox, exclude al dependency
class GAspectTransform extends GraphicsTransformApplier {
    var localScale = 1.;

    public inline function transformValue(c:Int, input:Float) {
        var a = Axis2D.fromInt(c);
        var sign = c == 0 ? 1 : -1;
        var free = size[c] - bounds.size[a] * localScale;
        var lp = (input - bounds.pos[a]) * localScale + free / 2;
        return
            ((pos[c] + lp) / aspects.getFactor(c) - 1) * sign;
    }


    public inline function invalidate() {
        localScale = 9999.;
        for (a in Axis2D.keys) {
            var _scale = size[a.toInt()] / bounds.size[a];
            if (_scale < localScale)
                localScale = _scale;
        }
    }

    override function createApplier(a:Axis2D){
        return new GTransformAxisApplier(this, a);
    }
}

class GFluidTransform extends GraphicsTransformApplier {

    public inline function transformValue(c:Int, input:Float) {
        var a = Axis2D.fromInt(c);
        var sign = c == 0 ? 1 : -1;
        return
            sign *
            ((pos[c] + bounds.localToGlobal(a, input) * size[c]) / aspects.getFactor(c) - 1) ;
    }

    override function createApplier(a:Axis2D){
        return new GTransformAxisApplier(this, a);
    }

    public inline function invalidate() {

    }
}

class BoundboxConverters {
    public static inline function localToGlobal(bb:Boundbox, a:Axis2D, value:Float):Float {
        return bb.pos[a] + value / bb.size[a];
    }

    public static inline function globalToLocal(bb:Boundbox, a:Axis2D, value:Float):Float {
        return value * bb.size[a] - bb.pos[a];
    }
}


interface IGAxisApplier extends AxisApplier {
    function targetTransform(v:Float):Float;
}
class GTransformAxisApplier implements IGAxisApplier {
    var axisIntex:Axis2D;
    var target:TransformTarget;
    var containers:Array<IGraphicsTransform> = [];

    public function new(target:TransformTarget, c) {
        this.target = target;
        axisIntex = c;
    }


    public function targetTransform(v:Float):Float {
        return target.transformValue(axisIntex, v);
    }

    public function applyPos(v:Float):Void {
    }

    public function apply(pos:Float, size:Float):Void {
        target.pos[axisIntex] = pos;
        target.size[axisIntex] = size ;
        target.invalidate();
        target.applyContainers(axisIntex, targetTransform);
    }
}

typedef TransformTarget = {
    var pos:Array<Float>;
    var size:Array<Float>;

    function invalidate():Void;

    function applyContainers(a:Axis2D, tr:Float -> Float):Void;

    function transformValue(c:Int, input:Float):Float;
}



