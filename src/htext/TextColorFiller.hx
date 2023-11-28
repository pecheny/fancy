package htext;

import haxe.io.Bytes;
import gl.AttribSet;

class TextColorFiller<T:AttribSet> implements AttributeFiller {
    var attr:T;

    public var color:Int = 0xffffff;

    var layouter:TextLayouter;

    public function new(attrs:T, l) {
        this.attr = attrs;
        this.layouter = l;
    }

    public function write(target:Bytes, start) {
        attr.writeColor(target, color, start, 4 * layouter.getTiles().length);
    }
}
