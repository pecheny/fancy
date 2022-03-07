package gl;
import data.IndexCollection;
import haxe.io.Bytes;
import gl.AttribSet;
import gltools.VertDataTarget.RenderDataTarget;
class RenderTargets<T:AttribSet> {
    public var verts(default, null) = new RenderDataTarget();
    public var inds (default, null) = new RenderDataTarget();
    var attrs:T;


    public function new(attrs:T) {
        this.attrs = attrs;
    }


    public inline function writeValue(attrAlias:String, comp:Int, val:Float) {
        verts.grantCapacity((verts.pos + 256) * attrs.stride);
        attrs.getWriter(attrAlias)[comp].setValue(verts.getBytes(), verts.pos, val);
    }

    public function blitVerts(source:Bytes, count:Int, srcPos = 0) {
        verts.grantCapacity((verts.pos + count) * attrs.stride);
        verts.getBytes().blit(verts.pos * attrs.stride, source, srcPos * attrs.stride, count * attrs.stride);
        verts.pos += count;
    }

    public inline function blitIndices(source:Bytes, count:Int, srcPos = 0) {
        inds.grantCapacity((inds.pos + count) * IndexCollection.ELEMENT_SIZE);
        var bytes:IndexCollection = inds.getBytes();
        inds.getBytes().blit(inds.pos * IndexCollection.ELEMENT_SIZE, source, srcPos * IndexCollection.ELEMENT_SIZE, count * IndexCollection.ELEMENT_SIZE);
        for (v in inds.pos...inds.pos + count) {
            bytes[v] += verts.pos;
        }
        inds.pos += count;
    }

    public inline function commitVertices(num:Int = 1) {
        verts.pos += num;
    }

    public inline function flush() {
        verts.pos = 0;
        inds.pos = 0;
    }

    public inline function indsCount() {
        return inds.pos;
    }
}
