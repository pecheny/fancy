package graphics.shapes;
import gl.sets.ColorSet;
import al.al2d.Axis2D;
import al.al2d.Widget2D.AxisCollection2D;
import data.IndexCollection;
import gl.AttribSet;
import gl.ValueWriter.AttributeWriters;
import haxe.io.Bytes;
import IGT.IGraphicsTransform;
class QuadGraphicElement<T:AttribSet>  implements IGraphicsTransform {
    public var weights:Array<Array<Float>>;
    var transformators:AxisCollection2D<Float->Float> = new AxisCollection2D();

    public function new(attrs:T) {
        weights = [];
        weights[0] = RectWeights.weights[horizontal].copy();
        weights[1] = RectWeights.weights[vertical].copy();
        for (k in Axis2D.keys)
            transformators[k] = identity;
    }

    function identity(v) return v;


    public function applyTransform(axis:Axis2D, tr:Float -> Float) {
        transformators[axis] = tr;
    }

    public inline function getIndices():IndexCollection {
        return IndexCollections.QUAD_ODD;
    }

    public function writePostions(target:Bytes, writer:AttributeWriters, vertOffset = 0) {
        inline function writeAxis(axis:Axis2D, i) {
            var tr = transformators[axis];
            var wg = weights[axis][i];
            writer[axis].setValue(target, vertOffset+i, tr(wg));
        }
        for (i in 0...4) {
            writeAxis(horizontal, i);
            writeAxis(vertical, i);
        }
    }
}
