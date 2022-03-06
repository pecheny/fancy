package gl;
import data.AttribSet;
import data.AttributeDescr;
import data.DataType;
import datatools.ByteDataWriter;
import haxe.io.Bytes;
class FloatValueWriter implements IValueWriter {
    var stride:Int;
    var offset:Int;
    var type:DataType;

    public function new( attr:AttributeDescr, comp:Int, stride:Int, offset:Int = 0) {
        if (attr.type != DataType.float32)
            throw "Wrong writer for type " + attr.type;

        var compOffset = attr.offset + AttribSet.getGlSize(attr.type) * comp;
        this.offset = compOffset + offset;
        this.stride = stride;
        this.type = attr.type;
    }

    // todo write macro typed set for dataWriter
    public function setValue(target:Bytes, vertIdx:Int, value:Float) {
        target.setFloat(vertIdx * stride + offset, value);
    }

    public function getValue(target:Bytes, vertIdx:Int) {
        var o = vertIdx * stride + offset;
        return target.getFloat(o);
    }
}

class Uint8ValueWriter implements IValueWriter {
    var stride:Int;
    var offset:Int;
    var type:DataType;

    public function new(attr:AttributeDescr, comp:Int, stride:Int, offset:Int = 0) {
        if (attr.type != DataType.uint8)
            throw "Wrong writer for type " + attr.type;
        var compOffset = attr.offset + AttribSet.getGlSize(attr.type) * comp;
        this.offset = compOffset + offset;
        this.stride = stride;
        this.type = attr.type;
    }

    // todo write macro typed set for dataWriter
    public function setValue(target:Bytes, vertIdx:Int, value:Float) {
        target.set(vertIdx * stride + offset, cast value);
    }

    public function getValue(target:Bytes, vertIdx:Int) :Float {
        var o = vertIdx * stride + offset;
        return target.get(o);
    }
}


typedef AttributeWriters = Array<IValueWriter>;
interface IValueWriter {
    public function setValue(target:Bytes, vertIdx:Int, value:Float):Void;
    public function getValue(target:Bytes, vertIdx:Int):Float;
}
class ValueWriter {

    public static function create( attr:AttributeDescr, comp:Int, stride:Int, offset:Int = 0):IValueWriter {
        switch attr.type {
            case float32 : return new FloatValueWriter(attr, comp, stride, offset);
            case uint8 : return new Uint8ValueWriter(attr, comp, stride, offset);
            case _ : throw "not implemented yet";
        }
    }
}


class TransformValueWriter extends FloatValueWriter {
    var transform:Float -> Float;

    public function new(target:ByteDataWriter, attr:AttributeDescr, comp:Int, stride:Int, offset:Int = 0) {
        super( attr, comp, stride, offset);
        transform = passthrough;
    }

    function passthrough(val) return val;

    public function replaceTransform(newTransform) this.transform = newTransform;

    public function addTransformNode(t) {
        this.transform = (v) -> t(this.transform(v));
    }

    override public function setValue(target, vertIdx:Int, value:Float) {
        super.setValue(target, vertIdx, transform(value));
    }
}

