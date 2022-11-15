package algl;
import Axis2D;
import transform.TransformerBase;
import al.core.AxisApplier;
class TransformatorAxisApplier implements AxisApplier {
    var axisIntex:Axis2D;
    var target:TransformerBase;

    public function new(target:TransformerBase, c) {
        this.target = target;
        axisIntex = c;
    }

    public function apply(_pos:Float, _size:Float):Void {
        var p:AVector2D<Float> = @:privateAccess target._pos;
        p[axisIntex] = _pos;
        var s:AVector2D<Float> = @:privateAccess target._size;
        s[axisIntex] = _size;
        target.changed.dispatch();
    }
}
