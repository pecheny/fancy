package htext;
import Axis2D;
import gl.ValueWriter.IValueWriter;
import haxe.io.Bytes;
import htext.style.TextStyleContext;
class SmothnessWriter implements AttributeFiller {
    var writer:IValueWriter;
    var layouter:TextLayouter;
    var ctx:TextStyleContext;
    var tr:Location2D;
    var windowSize:ReadOnlyAVector2D<Int>;

    public function new(wr, l, ctx, tr, ws) {
        this.writer = wr;
        this.layouter = l;
        this.ctx = ctx;
        this.tr = tr;
        this.windowSize = ws;
    }

    public function write(target:Bytes, start) {
        var tiles = layouter.getTiles();
        var base = ctx.getFontScale(tr) * windowSize[vertical] / 2;
        var dfSize = ctx.getFont().getDFSize();
        for (i in 0...tiles.length) {
            var tile = tiles[i];
            var val = 2 * dfSize / ( base * tile.scale );
            for (j in 0...4) {
                writer.setValue(target, start + j + i * 4, val);
            }
        }
    }
}
