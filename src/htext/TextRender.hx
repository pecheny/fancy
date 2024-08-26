package htext;
import Axis2D;
import data.aliases.AttribAliases;
import data.IndexCollection;
import font.GLGlyphData.TileRecord;
import font.GLGlyphData;
import gl.AttribSet;
import gl.RenderTarget;
import gl.ValueWriter.AttributeWriters;
import gl.ValueWriter;
import htext.TextLayouter;
import a2d.transform.TransformerBase;
import utils.DynamicBytes;

/**
* TextRender combines all required from htext and flgl libs to fill haxe.io.Bytes buffer with vertex data of quads according to provided string.
**/
class TextRender<T:AttribSet> implements ITextRender<T> {
    static var indices:IndexCollection;
    var value = "";
    var efficientLen = 0;
    var transformer:TransformerBase;
    var charsLayouter:TextLayouter;
    var bytes = new DynamicBytes(512);
    var attrs:T;
    var otherAttributesToFill:AttributeFiller;

    var posWriter:AttributeWriters ;
    var uvWriter:AttributeWriters ;
    var dpiWriter:AttributeWriters ;

    public function new(attrs:T, layouter, tr, forFill:AttributeFiller = null) {
        this.attrs = attrs;
        this.otherAttributesToFill = forFill;
        this.transformer = tr;
        transformer.changed.listen(setDirty);
        charsLayouter = layouter;

        posWriter = attrs.getWriter(AttribAliases.NAME_POSITION);
        uvWriter = attrs.getWriter(AttribAliases.NAME_UV_0);
    }

    inline function setChar(at:Int, rec:TileRecord) {
        var vertOfs = at * 4;
        for (i in 0...4) {
            setVert(rec, horizontal, i, vertOfs);
            setVert(rec, vertical, i, vertOfs);
        }
    }

    inline function setVert(rec:TileRecord, a:Axis2D, vert:Int, vertOfs) {
        var targ = bytes.bytes;
        posWriter[a].setValue(targ, vertOfs + vert, getVertPos(rec, a, vert));
        uvWriter[a].setValue(targ, vertOfs + vert, rec.tile.getUV(vert, a));
    }

    inline function getVertPos(rec:TileRecord, a:Axis2D, vert:Int) {
        var vo = 0.;
        if (a == vertical)
            vo = charsLayouter.calculateVertOffset();
        var locPos = -vo + rec.pos[a] + rec.scale * rec.tile.getLocalPosOffset(vert, a);
        return transformer.transformValue(a, locPos);
    }


    public function setText(s:String) {
        value = s;
        setDirty();
    }

    var dirty = true;

    public function setDirty() {
        dirty = true;
    }

    function fillBuffer() {
        charsLayouter.setText(value);
        var tiles = charsLayouter.getTiles();
        efficientLen = tiles.length;
        if (indices == null || indices.length < efficientLen * 6)
            indices = IndexCollection.forQuads(efficientLen);
        bytes.grantCapacity(4 * efficientLen * attrs.stride);
        for (i in 0...efficientLen)
            setChar(i, tiles[i]);
        if (otherAttributesToFill != null) {
            otherAttributesToFill.write(bytes.bytes, 0);
        }
        dirty = false;
    }

    public function render(targets:RenderTarget<T>):Void {
        if (dirty) fillBuffer();
        targets.blitIndices(indices, efficientLen * 6);
        targets.blitVerts(bytes.bytes, efficientLen * 4);
    }
}


