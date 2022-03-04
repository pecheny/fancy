package graphics.shapes;
import graphics.GraphicsLayer.GraphicsElement;
import al.al2d.Axis2D;
import data.AttribAliases;
import data.AttribSet;
import data.IndexCollection;
class QuadGraphicElement<T:AttribSet> extends GraphicsElement<T> {
    public var weights:Array<Array<Float>>;

    public function new(attrs:T) {
        super(attrs);
        weights = [];
        weights[0] = RectWeights.weights[horizontal].copy();
        weights[1] = RectWeights.weights[vertical].copy();
    }

    override public function applyTransform(axis:Axis2D, tr:Float -> Float) {

        for (i in 0...weights[axis].length) {
            var wg = weights[axis][i];
            writers[AttribAliases.NAME_POSITION][axis].setValue(i, tr(wg));
        }
    }

    override public function vertCount():Int {
        return 4;
    }

    override public function indexCollection():IndexCollection {
        return IndexCollections.QUAD_ODD;
    }
}
