package graphics;

import a2d.WidgetInPixels;
import gl.AttribSet;
import gl.sets.CircleSet;
import haxe.io.Bytes;



/**
    Input should be UV density ie number of pixels in the UV unit.
**/
@:access(SquareShape)
class PhAntialiasing<T:AttribSet> {
    var att:T;
    var smoothness = 6.;
    var count:Int;
    var pixelSize:PixelSizeInUVSpace;

    public function new(att, count, piuw) {
        this.att = att;
        this.count = count;
        this.pixelSize = piuw;
    }

    public function writePostions(target:Bytes, vertOffset = 0, transformer) {
        var aasize = smoothness * pixelSize.pixelSizeInUVSpace;
        att.fillFloat(target, CircleSet.AASIZE_IN, aasize, vertOffset, count);
    }
}
