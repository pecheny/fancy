package htext.animation;
import data.IndexCollection;
import Axis2D;
import font.GLGlyphData.TileRecord;
import gl.AttribSet;
class VUnfoldAnimTextRender<T:AttribSet> extends TextRender<T> {
//    var lastTime = 0.;
    var time = 0.;
    var conv = new SeqTimeConverter(10);

    public function setTime(t:Float):Void {
        time = t;
        dirty = full;
    }
    
    override function fillBuffer() {
        charsLayouter.setText(value);
        var tiles = charsLayouter.getTiles();
        efficientLen = tiles.length;
        if (TextRender.indices == null || TextRender.indices.length < efficientLen * 6)
            TextRender.indices = IndexCollection.forQuads(efficientLen);
        bytes.grantCapacity(4 * efficientLen * attrs.stride);
        positions.resize(tiles.length * 4 * 2);
        for (i in 0...efficientLen)
            _setChar(i, tiles[i]);
        if (otherAttributesToFill != null) {
            otherAttributesToFill.write(bytes.bytes, 0);
        }
        dirty = transform;
    }

    function _setChar(at:Int, rec:TileRecord) {
        for (i in 0...4) {
            _setVert(rec, horizontal, i, at);
            _setVert(rec, vertical, i, at);
        }
    }

    function _setVert(rec:TileRecord, a:Axis2D, vert:Int, at) {
        var targ = bytes.bytes;
        var vertOfs = at * 4;
        posWriter[a].setValue(targ, vertOfs + vert, getVertPosAt(rec, a, vert, at));
        uvWriter[a].setValue(targ, vertOfs + vert, rec.tile.getUV(vert, a));
    }

    function getVertPosAt(rec:TileRecord, a:Axis2D, vert:Int, at:Int) {
        var lt = conv.getLocalTime(at, time);
        if (lt == 0)
            return 0.;
        var locPos = rec.pos[a] + rec.scale * rec.tile.getLocalPosOffset(vert, a);
        if (a == vertical) {
            var offst = 1 - lt;
            locPos += offst * rec.scale * 0.1;
        }
        return transformer.transformValue(a, locPos);
    }
}