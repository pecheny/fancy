package htext;

import font.GLGlyphData;
import data.aliases.AttribAliases;
import gl.ValueWriter.AttributeWriters;
import haxe.io.Bytes;
import gl.AttribSet;

class TextColorFiller<T:AttribSet> implements AttributeFiller {
    var attr:T;
    var writers:AttributeWriters;

    public var color:Int = 0xffffff;

    var glyphs:ColorXmlGlyphs;

    public function new(attrs:T, l) {
        this.attr = attrs;
        writers = attrs.getWriter(AttribAliases.NAME_COLOR_IN);
        this.glyphs = l;
    }

    public function write(target:Bytes, start) {
        var tiles = glyphs.tiles;
        for (i in 0...tiles.length) {
            var tile = tiles[i];
            attr.writeColor(target, tile.color, start + i * 4, 4);
        }
    }
}

class ColorTile extends TileRecord {
    public var color(default, null):Int;

    public function new(t, x, y, s, df, color) {
        super(t, x, y, s, df);
        this.color = color;
    }
}

class ColorXmlGlyphs extends XmlGlyphs<ColorTile> {
    public var color:Int = 0xffffff;

    public function new() {
        super();
        nodeHandlers["color"] = (e:Xml) -> {
            var cur = color;
            color = Std.parseInt(e.get("value"));
            return () -> color = cur;
        };
    }

    override function add(v:GLGlyphData, x:Float, y:Float, scale:Float = 1., dfSize:Int = 2) {
        tiles.push(new ColorTile(v, x, y, scale, dfSize, color));
    }
}
