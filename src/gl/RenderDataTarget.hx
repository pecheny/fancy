package gl;
import data.DataType;
import datatools.ExtensibleBytes;
import haxe.io.Bytes;
class RenderDataTarget {
    var extensible = new ExtensibleBytes(64);
    public var pos:Int = 0;

    public function new() {
    }

     inline public function getBytes():Bytes {
        return extensible.bytes;
    }

    public function getView() {
        return extensible.getView();
    }

    public function grantCapacity(s) {
        extensible.grantCapacity(s);
    }

    public inline function setInt32(byteOffset:Int, value:Int) {
        getBytes().setInt32(byteOffset, value);
    }

    public inline function setUint8(byteOffset:Int, value:Int){
        getBytes().set(byteOffset, value);
    }

    public inline function setUint16(byteOffset:Int, value:Int){
    getBytes().setUInt16(byteOffset, value);
    }

    public inline function setFloat32(byteOffset:Int, value:Float){
        getBytes().setFloat(byteOffset, value);
    }


    public inline function setTyped(type:DataType, offset, value:Dynamic) {
        switch type {
            case int32 : setInt32(offset, value);
            case uint8 : setUint8(offset, value);
            case uint16 : setUint16(offset, value);
            case float32 :
                setFloat32(offset, value);
        }
    }

}

