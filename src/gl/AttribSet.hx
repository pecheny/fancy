package gl;
import haxe.io.Bytes;
import data.ShadersAttrs;
import data.AttributeState;
import data.AttributeDescr;
import bindings.WebGLRenderContext;
import data.DataType;
import gl.ValueWriter;
#if (cpp || js || hl)
import bindings.GLProgram;
#end
import haxe.io.Float32Array;
import haxe.io.Int32Array;
import haxe.io.UInt16Array;
import haxe.io.UInt8Array;
class AttribSet {
    public function new() {}
    public var stride(default, null):Int = 0;
    public var attributes:Array<AttributeDescr> = [];
    var writers:Map<String, AttributeWriters> = new Map();
//    var offset:Int = 0;

    public function addAttribute(name:String, numComponents:Int, type:DataType) {
        var descr = {
            name:name,
            numComponents:numComponents,
            type:type,
            offset:stride,
        }
        writers[name] = createWritersForAttribute(descr);
        stride += numComponents * getGlSize(type);
//        attribPointers[name] = attributes.length;
        attributes.push(descr);
    }

    public function getDescr(name):AttributeDescr {
        for (d in attributes) {
            if (d.name == name)
                return d;
        }
        throw "No such attr " + name;
    }

    public function hasAttr(name) {
        for (d in attributes) {
            if (d.name == name)
                return true;
        }
        return false;
    }



    #if (cpp || js || hl)

    public static inline function getGlSize(type:DataType) {
        return switch type {
            case int32 : Int32Array.BYTES_PER_ELEMENT;
            case uint8 : UInt8Array.BYTES_PER_ELEMENT;
            case uint16 : UInt16Array.BYTES_PER_ELEMENT;
            case float32 : Float32Array.BYTES_PER_ELEMENT;
        }
    }

    public function buildState(gl:WebGLRenderContext, program:GLProgram) {
        var attrs = [];
        for (desc in attributes) {
            var posIdx = gl.getAttribLocation(program, desc.name);
            attrs.push(new AttributeState(posIdx, desc.numComponents, desc.type, desc.name));
        }
        return new ShadersAttrs(attrs);
    }

    public function enableAttributes(gl:WebGLRenderContext, attrsState:ShadersAttrs) {
        var offset = 0;
        var attributes = attrsState.attrs;
        for (i in 0...attributes.length) {
            var descr:AttributeState = attributes[i];
            descr.offset = offset;
            gl.enableVertexAttribArray(descr.idx);
            var normalized = ("colorIn" == descr.name);
            gl.vertexAttribPointer(descr.idx, descr.numComponents, getGlType(descr.type, gl), normalized, stride, offset);
            offset += descr.numComponents * getGlSize(descr.type);
        }
    }

    static inline function getValue(reader:Bytes, type:DataType, offset) {
        return
            switch type {
                case uint8 : reader.get(offset);
                case int32 : reader.getInt32(offset);
                case uint16 : reader.getUInt16(offset);
                case float32 : reader.getFloat(offset);
            }
    }

    public inline function printVertex(data:Bytes, v){
        var r = "";
        for (att in attributes) {
            r += att.name  + ": [";
            var access = writers[att.name];
            for (i in 0...access.length)
                r+= access[i].getValue(data, v) + " ";
            r+="]";
        }
        return r;
    }

    public inline function getGlType(type:DataType, gl:WebGLRenderContext) {
        return switch type {
            case int32 : gl.INT;
            case uint8 : gl.UNSIGNED_BYTE;
            case uint16 : gl.UNSIGNED_SHORT;
            case float32 : gl.FLOAT;
        }
    }
    #end

    public static function createAttribute(name:String, numComponents:Int, type:DataType):AttributeDescr {
        return {
            name:name,
            numComponents:numComponents,
            type:type,
        }
    }

    public function getView(alias:String) {
        for (desc in attributes) {
            if (desc.name == alias)
                return{
                    stride:stride,
                    offset:desc.offset,
                    numComponents:desc.numComponents,
                    type:desc.type
                }
        }
        throw "Wrong! " + alias;
    }

    inline function createWriter( attr:AttributeDescr, comp:Int, stride:Int, offset:Int = 0):IValueWriter {
        switch attr.type {
            case float32 : return new FloatValueWriter(attr, comp, stride, offset);
            case uint8 : return new Uint8ValueWriter(attr, comp, stride, offset);
            case _ : throw "not implemented yet";
        }
    }


    public function getWriter(alias:String):AttributeWriters {
        if (writers.exists(alias))
            return writers[alias];
        for (descr in attributes) {
            if (descr.name == alias) {
                writers[descr.name] = createWritersForAttribute(descr);
                return writers[descr.name];
            }
        }
        throw "wrong attr " + alias;
    }

    inline function createWritersForAttribute(descr:AttributeDescr):AttributeWriters {
        var wrs = [];
        for (i in 0...descr.numComponents) {
            wrs.push(createWriter(descr, i, stride));
        }
        return wrs;
    }

    function createWriters() {
        for (descr in attributes) {
            writers[descr.name] = createWritersForAttribute(descr);
        }
    }
}
