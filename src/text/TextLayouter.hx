package text;
import font.GLGlyphData.TileRecord;
import haxe.ds.ReadOnlyArray;
import text.Align;

interface TextLayouter {
    function setText(val:String):Void;
    function getTiles():ReadOnlyArray<TileRecord>;
    function setWidthConstraint(val:Float):Void;
    function setTextAlign(align:Align):Void;
}

interface CharsLayouterFactory {
    function create(fontName:String = ""):TextLayouter;
}

