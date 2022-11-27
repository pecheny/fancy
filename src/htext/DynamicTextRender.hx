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
import transform.TransformerBase;
import utils.DynamicBytes;

/**
* Version of TextRender with ability to override setChar() for using with animation or custom properties.
**/
class DynamicTextRender<T:AttribSet> implements ITextRender<T> {
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

    public function new(attrs:T, layouter, tr, forFill:AttributeFiller) {
        this.attrs = attrs;
        this.otherAttributesToFill = forFill;
        this.transformer = tr;
        transformer.changed.listen(setDirty);
        charsLayouter = layouter;

        posWriter = attrs.getWriter(AttribAliases.NAME_POSITION);
        uvWriter = attrs.getWriter(AttribAliases.NAME_UV_0);
    }

    dynamic function setChar(at:Int, rec:TileRecord) {
        for (i in 0...4) {
            _setVertDef(rec, horizontal, i, at);
            _setVertDef(rec, vertical, i, at);
        }
    }

    inline function _setVertDef(rec:TileRecord, a:Axis2D, vert:Int, at){
        var targ = bytes.bytes;
        var vertOfs = at * 4;
        posWriter[a].setValue(targ, vertOfs + vert, _getVertPosDef(rec, a, vert, at));
        uvWriter[a].setValue(targ, vertOfs + vert, rec.tile.getUV(vert, a));
    }

    inline function _getVertPosDef(rec:TileRecord, a:Axis2D, vert:Int, at:Int) {
        var locPos = rec.pos[a] + rec.scale * rec.tile.getLocalPosOffset(vert, a);
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
