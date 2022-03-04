package graphics.shapes;
import al.al2d.Axis2D;
import haxe.ds.ReadOnlyArray;
class RectWeights {
    public static var weights:Map<Axis2D, ReadOnlyArray<Float>> = [
        horizontal => [0, 0, 1, 1],
        vertical => [0, 1, 0, 1]
    ];
}
