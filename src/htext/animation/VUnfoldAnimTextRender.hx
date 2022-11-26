package htext.animation;
import Axis2D;
import font.GLGlyphData.TileRecord;
import gl.AttribSet;
class VUnfoldAnimTextRender<T:AttribSet> extends DynamicTextRender<T> {
//    var lastTime = 0.;
    var time = 0.;
    var conv = new SeqTimeConverter(10);

    public function setTime(t:Float):Void {
        time = t;
        dirty = true;
    }

    override function setChar(at:Int, rec:TileRecord) {
        for (i in 0...4) {
            setVert(rec, horizontal, i, at);
            setVert(rec, vertical, i, at);
        }
    }

    inline function setVert(rec:TileRecord, a:Axis2D, vert:Int, at) {
        var targ = bytes.bytes;
        var vertOfs = at * 4;
        posWriter[a].setValue(targ, vertOfs + vert, getVertPos(rec, a, vert, at));
        uvWriter[a].setValue(targ, vertOfs + vert, rec.tile.getUV(vert, a));
    }

    inline function getVertPos(rec:TileRecord, a:Axis2D, vert:Int, at:Int) {
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