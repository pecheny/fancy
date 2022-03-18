package text;
import font.GLGlyphData.TileRecord;
import haxe.ds.ReadOnlyArray;

interface TextLayouter {
    function setText(val:String):Void;
    function getTiles():ReadOnlyArray<TileRecord>;
}

interface CharsLayouterFactory {
    function create():TextLayouter;
}
