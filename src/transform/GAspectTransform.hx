package transform;
import al.al2d.Axis2D;
import al.al2d.Boundbox;
import al.al2d.Widget2D.AxisCollection2D;
import al.core.AxisApplier;
import Array;
import haxe.ds.ReadOnlyArray;
import transform.AspectRatio;
using transform.GAspectTransform.BoundboxConverters;


class GraphicTransformApplier {
    var appliers:AxisCollection2D<GTransformAxisApplier> = new AxisCollection2D();
    public var pos:Array<Float> = [0, 0];
    public var size:Array<Float> = [1, 1];
    var aspects:AspectRatio;

    public function getAxisApplier(a:Axis2D):AxisApplier {
        return appliers[a];
    }

//todo make own boundbox, exclude al dependency
    var bounds:Boundbox = new Boundbox();

    public function new(aspects:ReadOnlyArray<Float>) {
        this.aspects = aspects;
        for (k in Axis2D.keys)
            appliers[k] = new GTransformAxisApplier(this, k);
    }

    public function setBounds(x, y, w, h) {
        bounds.set(x, y, w, h);
    }

    public function invalidate(){}
}

class GAspectTransform extends GraphicTransformApplier {
    var localScale = 1.;

    public function transformValue(c:Int, input:Float) {
        var a = Axis2D.fromInt(c);
        var sign = c == 0 ? 1 : -1;
        var free = size[c] - bounds.size[a] * localScale;
        var lp = (input - bounds.pos[a]) * localScale + free / 2;
        return
            ((pos[c] + lp) / aspects.getFactor(c) - 1) * sign;
    }


    override public function invalidate() {
        localScale = 9999.;
        for (a in Axis2D.keys) {
            var _scale = size[a.toInt()] / bounds.size[a];
            if (_scale < localScale)
                localScale = _scale;
        }
    }
}

class GFluidTransform extends GraphicTransformApplier {
    public function transformValue(c:Int, input:Float) {
        var a = Axis2D.fromInt(c);
        var sign = c == 0 ? 1 : -1;
        return
            sign *
            ((pos[c] + bounds.localToGlobal(a, input) * size[c]) / aspects.getFactor(c) - 1) ;
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

class GTransformAxisApplier implements AxisApplier {
    var axisIntex:Axis2D;
    var target:GraphicTransformApplier;

    public function new(target:GraphicTransformApplier, c) {
        this.target = target;
        axisIntex = c;
    }

    public function apply(pos:Float, size:Float):Void {
        @:privateAccess target.pos[axisIntex] = pos;
        @:privateAccess target.size[axisIntex] = size ;
    }
}
