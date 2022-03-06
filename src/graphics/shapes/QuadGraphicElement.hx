package graphics.shapes;
import IGT.IGraphicsTransform;
import al.al2d.Axis2D;
import al.al2d.Widget2D.AxisCollection2D;
import data.AttribAliases;
import gl.AttribSet;
import data.IndexCollection;
import gl.Renderable;
import gl.RenderTargets;
class QuadGraphicElement<T:AttribSet>  implements Renderable<T> implements IGraphicsTransform {
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

    public function render(targets:RenderTargets<T>):Void {
        targets.blitIndices(IndexCollections.QUAD_ODD, 6);
        inline function writeAxis(axis:Axis2D, i) {
            var tr = transformators[axis];
            var wg = weights[axis][i];
            targets.writeValue(AttribAliases.NAME_POSITION, axis, tr(wg));
        }
        for (i in 0...4) {
            writeAxis(horizontal, i);
            writeAxis(vertical, i);
            targets.vertexDone();
        }
    }
}
