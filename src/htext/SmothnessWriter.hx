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
        var charSize = untyped ctx.getFont().font.initSize; // todo create font api
        for (i in 0...tiles.length) {
            var tile = tiles[i];
            var appliedDf = tile.dfSize / charSize;
            var sceenPixelsInTile = (base * tile.scale);
            var onePixelInUV = 1 / sceenPixelsInTile;
            var normalDistance = 1 / appliedDf;
            var val = onePixelInUV * normalDistance;
            // val is thickness of aa calculated for each glyph according to its size on screen.
            // that's not optimal way, todo see note at <2025-05-16 Fri 13:34>
            for (j in 0...4) {
                writer.setValue(target, start + j + i * 4, val);
            }
        }
    }
}
