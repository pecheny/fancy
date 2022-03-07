package transform;
import al.al2d.Axis2D;
import al.al2d.Boundbox;
import al.core.AxisApplier;
using transform.GAspectTransform.BoundboxConverters;




class GAspectTransform extends Transformator {
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

class GFluidTransform extends Transformator {
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


