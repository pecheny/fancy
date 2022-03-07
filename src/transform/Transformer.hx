package transform;
import haxe.ds.ReadOnlyArray;
import al.al2d.Boundbox;
import al.core.AxisApplier;
import al.al2d.Axis2D;
import al.al2d.Widget2D.AxisCollection2D;
class Transformer {
    var appliers:AxisCollection2D<TransformatorAxisApplier> = new AxisCollection2D();
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
            appliers[k] = new TransformatorAxisApplier(this, k);
    }

    public function setBounds(x, y, w, h) {
        bounds.set(x, y, w, h);
    }

    public function invalidate(){}
}

class TransformatorAxisApplier implements AxisApplier {
    var axisIntex:Axis2D;
    var target:Transformer;

    public function new(target:Transformer, c) {
        this.target = target;
        axisIntex = c;
    }

    public function apply(pos:Float, size:Float):Void {
        @:privateAccess target.pos[axisIntex] = pos;
        @:privateAccess target.size[axisIntex] = size ;
    }
}