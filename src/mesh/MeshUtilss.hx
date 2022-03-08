package mesh;
import gl.AttribSet;
import data.AttributeDescr;
import data.DataType;
typedef VertexAttribProvider = Int->Int->Dynamic
class MeshUtilss {

    public static function writeInt8Attribute<T:AttribSet>(attrs:AttribSet, bytes:haxe.io.Bytes, attName:String, firstVert:Int, vertCount:Int, provider:VertexAttribProvider) {
        var descr:AttributeDescr = attrs.getDescr(attName);
        if (descr.type != DataType.uint8)
            throw "wrong type";
        var size = AttribSet.getGlSize(descr.type);
        for (v in 0...vertCount) {
            for (c in 0...descr.numComponents) {
                var pos =
                attrs.stride * (firstVert + v)
                + descr.offset
                + c * size;
                bytes.set(pos, provider(v, c));
            }
        }
    }

    public static function writeFloatAttribute<T:AttribSet>(attrs:AttribSet, bytes:haxe.io.Bytes, attName:String, firstVert:Int, vertCount:Int, provider:VertexAttribProvider) {
        var descr:AttributeDescr = attrs.getDescr(attName);
        if (descr.type != DataType.float32)
            throw "wrong type";
        var size = AttribSet.getGlSize(descr.type);
        for (v in 0...vertCount) {
            for (c in 0...descr.numComponents) {
                var pos =
                attrs.stride * (firstVert + v)
                + descr.offset
                + c * size;
                bytes.setFloat(pos, provider(v, c));
            }
        }
    }

}
