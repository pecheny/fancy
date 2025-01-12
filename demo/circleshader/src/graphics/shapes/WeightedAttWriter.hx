package graphics.shapes;

import Axis2D;
import gl.ValueWriter;

class WeightedAttWriter {
    var writers:AttributeWriters;

    public var direction:Axis2D = horizontal;
    public var weights(default, null):AVector2D<Array<Float>>;

    public function new(wrs, wghs:AVector2D<Array<Float>>) {
        this.writers = wrs;
        this.weights = wghs;
    }

    public inline function writeAtts(target, vertOffset, tr) {
        var aw = weights[horizontal];
        var cw = weights[vertical];
        for (i in 0...cw.length)
            writeLine(target, direction, vertOffset + aw.length * i, 1, aw, tr);
        for (i in 0...aw.length) {
            writeLine(target, direction.other(), vertOffset + i, aw.length, cw, tr);
        }
    }

    public inline function writeLine(target, dir:Axis2D, start, offset, weights, tr) {
        for (i in 0...weights.length)
            writers[dir].setValue(target, start + i * offset, tr(dir, weights[i]));
    }
}
