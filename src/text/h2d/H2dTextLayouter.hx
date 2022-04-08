package text.h2d;
import font.FontStorage;
import font.GLGlyphData.Glyphs;
import font.GLGlyphData.TileRecord;
import font.GLGlyphData;
import font.IFont;
import text.h2d.Text;
import text.h2d.XmlText;
import haxe.ds.ReadOnlyArray;
import text.TextLayouter;
import text.h2d.Text.Align as H2dAlign;
class H2dTextLayouter implements TextLayouter {
    var text:Text<GLGlyphData>;
    var glyphs:Glyphs;

    public function new(f) {
        glyphs = new Glyphs();
        text = new Text(f, glyphs);
    }

    public function setText(val:String):Void {
        text.text = val;
        @:privateAccess text.updateSize();
    }

    public function getTiles():ReadOnlyArray<TileRecord> {
        return glyphs.tiles;
    }

    public function setWidthConstraint(val:Float):Void {
        text.constraintSize(val, -1);
    }

    public function setTextAlign(align:Align){
        text.textAlign =
        switch align {
            case Left : H2dAlign.Left;
            case Right : H2dAlign.Right;
            case Center : H2dAlign.Center;
        };
    }
}

class H2dCharsLayouterFactory implements CharsLayouterFactory {
    var font:IFont;

    public function new(f) {
        this.font = f;
    }

    public function create():TextLayouter {
        return new H2dTextLayouter(font);
    }
}

class H2dRichTextLayouter implements TextLayouter {
    var text:XmlText<GLGlyphData>;
    var glyphs:Glyphs;
    var fonts:FontStorage;

    public function new(f) {
        fonts = f;
        glyphs = new Glyphs();
        text = new XmlText(fonts.getFont("").font, glyphs);
        text.defaultLoadFont = loadFont;
    }

    function loadFont(name) {
        var finst = fonts.getFont(name);
        if (finst == null)
            return null;
        return finst.font;
    }

    public function setText(val:String):Void {
        text.text = val;
        @:privateAccess text.updateSize();
    }

    public function getTiles():ReadOnlyArray<TileRecord> {
        return glyphs.tiles;
    }

    public function setWidthConstraint(val:Float):Void {
        text.constraintSize(val, -1);
    }

    public function setTextAlign(align:Align){
        text.textAlign =
        switch align {
            case Left : H2dAlign.Left;
            case Right : H2dAlign.Right;
            case Center : H2dAlign.Center;
        };
    }
}

class H2dRichCharsLayouterFactory implements CharsLayouterFactory {
    var fonts:FontStorage;

    public function new(f) {
        this.fonts = f;
    }

    public function create():TextLayouter {
        return new H2dRichTextLayouter(fonts);
    }
}
