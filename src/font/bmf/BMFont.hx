package font.bmf;
import font.bmf.hxd.fmt.bfnt.FontParser;
import font.bmf.h2d.Font;
import utils.LazyMap;
import haxe.io.Path;
class BMFont implements IFont {
    var map(default, null):LazyMap<String, GLGlyphData>;
    var yOffset:Float = 0.;
    var dfSize:Int = 1;
    public var font(default, null):Font;

    public function new(font:Font, ?dfSize:Int) {
        this.font = font;
        if (dfSize != null)
            this.dfSize = dfSize;
        this.yOffset = (font.lineHeight - font.baseLine) / font.baseLine;
        map = new LazyMap(createGlyph);
    }

    public function getKerningOffset(ch1:String, ch2:String):Float {
        return 0;
    }

    public function getDFSize():Int {
        return dfSize;
    }


@:access(font.bmf.h2d.Tile)
    function createGlyph(char:String) {
        var fontChar = font.getChar(char.charCodeAt(0));
        var t = fontChar.t;
        var px = t.dx ;
        var w = t.width;
        var asc = font.lineHeight;

        var h = t.height;
        var py = t.dy - asc + yOffset;

        var pos = {x:px, y:py, w:w, h:h};
        var uvs = {x:t.u, y:t.v, w:t.u2 - t.u, h:t.v2 - t.v};
        var glyph = new GLGlyphData(pos, uvs, fontChar.width);
        return glyph;
    }

    public function getChar(key:String) {
        return map.get(key);
    }

    public function getLineHeight():Float {
        return font.lineHeight;
    }
}
class BMFontFactory implements FontFactory<IFont> {
    public function new() {}

    public function create(fontPath:String, ?dfsize:Int) {
        var folder = Path.directory(fontPath);
        var bytes = lime.utils.Assets.getBytes(fontPath);
        var font = FontParser.parse(bytes, ".");
        font.resizeTo(1);
        return new FontInstance<IFont>(new BMFont(font, dfsize), font.tilePath);
    }
}