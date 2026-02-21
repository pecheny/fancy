package htext;

import gl.ValueWriter;
import font.GLGlyphData;
import haxe.io.Bytes;

class TextDepthFiller implements AttributeFiller {
    var writer:IValueWriter;
    var glyphs:Glyphs<Dynamic>;

    public var value:Float = 0;

    public function new(wr, glyphs) {
        this.writer = wr;
        this.glyphs = glyphs;
    }

    public function write(target:Bytes, start) {
        var tiles = glyphs.tiles;
        for (i in 0...tiles.length * 4) {
            writer.setValue(target, start + i, value);
        }
    }
}
