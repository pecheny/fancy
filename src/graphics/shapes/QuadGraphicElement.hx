package graphics.shapes;
import al.al2d.Axis2D;
import data.IndexCollection;
import gl.AttribSet;
import gl.ValueWriter.AttributeWriters;
import haxe.io.Bytes;
class QuadGraphicElement<T:AttribSet> {
    public var weights:Array<Array<Float>>;
    var transformators:(Axis2D, Float) -> Float;

    public function new(attrs:T, transformators) {
        this.transformators = transformators;
        weights = [];
        weights[0] = RectWeights.weights[horizontal].copy();
        weights[1] = RectWeights.weights[vertical].copy();
    }

    public inline function getIndices():IndexCollection {
        return IndexCollections.QUAD_ODD;
    }

    public function writePostions(target:Bytes, writer:AttributeWriters, vertOffset = 0) {
        inline function writeAxis(axis:Axis2D, i) {
            var wg = weights[axis][i];
            writer[axis].setValue(target, vertOffset + i, transformators(axis, wg));
        }
        for (i in 0...4) {
            writeAxis(horizontal, i);
            writeAxis(vertical, i);
        }
    }
}
