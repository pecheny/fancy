package transform;
import al.al2d.Boundbox;
import al.al2d.Axis2D;
using transform.LiquidTransformer.BoundboxConverters;
class LiquidTransformer extends Transformer {
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


