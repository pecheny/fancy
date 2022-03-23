package text;
import al.al2d.Axis2D;
import al.al2d.Widget2D.AxisCollection2D;
import data.aliases.AttribAliases;
import data.IndexCollection;
import font.GLGlyphData.TileRecord;
import font.GLGlyphData;
import gl.AttribSet;
import gl.Renderable;
import gl.RenderTargets;
import gl.sets.MSDFSet;
import gl.ValueWriter.AttributeWriters;
import gl.ValueWriter;
import transform.TransformerBase;
import utils.DynamicBytes;
import text.TextLayouter;


class TextRender<T:AttribSet> implements Renderable<T> {
    static var indices:IndexCollection;
    var value = "";
    var efficientLen = 0;
    var charPos:AxisCollection2D<Float> = new AxisCollection2D();
    var transformer:TransformerBase;
    var stageHeight = 1;
    var charsLayouter:TextLayouter;
    var bytes = new DynamicBytes(512);
    var attrs:T;

    var posWriter:AttributeWriters ;
    var uvWriter:AttributeWriters ;
    var dpiWriter:AttributeWriters ;

    public function new(attrs:T, layouter, tr) {
        this.attrs = attrs;
        this.transformer = tr;
        charsLayouter = layouter;
        for (a in Axis2D.keys) {
            charPos[a] = 0;
        }
        posWriter = attrs.getWriter(AttribAliases.NAME_POSITION);
        uvWriter = attrs.getWriter(AttribAliases.NAME_UV_0);
        dpiWriter = attrs.getWriter(MSDFSet.NAME_DPI);
    }

    inline function setChar(at:Int, rec:TileRecord) {
        var glyph:GLGlyphData = rec.tile;
        var vertOfs = at * 4;
        var targ = bytes.bytes;
        var vertexOffset = 0;
        charPos[horizontal] = rec.x;
        charPos[vertical] = rec.y;
        for (i in 0...4) {
            posWriter[horizontal].setValue(targ, vertOfs + i, transformer.transformValue(horizontal, (charPos[horizontal] + rec.scale * glyph.getLocalPosOffset(i, 0))));
            posWriter[vertical].setValue(targ, vertOfs + i, transformer.transformValue(vertical, (charPos[vertical] + rec.scale * ( glyph.getLocalPosOffset(i, 1) ) )));
            uvWriter[horizontal].setValue(targ, vertOfs + i, glyph.getUV(i, 0));
            uvWriter[vertical].setValue(targ, vertOfs + i, glyph.getUV(i, 1));
        }
        var sssize = Math.abs(posWriter[vertical].getValue(targ, vertOfs + 1) - posWriter[vertical].getValue(targ, vertOfs));
        var screenDy = sssize * stageHeight / 2;// gl screen space (?)
        var smoothness = calculateGradientSize(rec, screenDy);
        for (i in 0...4) {
            dpiWriter[0].setValue(targ, vertOfs + i, smoothness);
        }
    }

    inline function calculateGradientSize(tile:TileRecord, screenDy:Float) {
        var gy = tile.tile.getLocalPosOffset(0, 1) - tile.tile.getLocalPosOffset(1, 1);
        return (tile.dfSize * screenDy) / gy;
    }

    public function setText(s:String) {
        stageHeight = openfl.Lib.current.stage.stageHeight ;
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
        if (indices == null || indices.length < efficientLen * 4)
            indices = IndexCollection.forQuads(efficientLen);
        bytes.grantCapacity(4 * efficientLen * attrs.stride);
        for (i in 0...efficientLen)
            setChar(i, tiles[i]);
    }

    public function render(targets:RenderTargets<T>):Void {
        if (dirty) fillBuffer();
        targets.blitIndices(indices, efficientLen * 6);
        targets.blitVerts(bytes.bytes, efficientLen * 4);
    }

}
