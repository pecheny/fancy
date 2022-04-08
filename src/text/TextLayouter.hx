package text;
import font.GLGlyphData.TileRecord;
import haxe.ds.ReadOnlyArray;

interface TextLayouter {
    function setText(val:String):Void;
    function getTiles():ReadOnlyArray<TileRecord>;
    function setWidthConstraint(val:Float):Void;
    function setTextAlign(align:Align):Void;
}

enum Align {
    Left;
    Right;
    Center;
}

interface CharsLayouterFactory {
    function create():TextLayouter;
}

