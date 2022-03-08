package utils;
import bindings.ArrayBufferView;
import bindings.ArrayViewBase;
import haxe.io.Bytes;
class DynamicBytes {
    public var bytes(default, null):Bytes;
    var size:Int;
    var view:ArrayViewBase;

    @:access(lime.utils.ArrayBufferView)
    public function new(size) {
        this.size = size;
        #if !js
        view = new ArrayBufferView(null, None);
        #end
        this.bytes = create(size);
    }

    #if !js
    #if lime
    @:access(lime.utils.ArrayBufferView)
    #elseif nme
    @:access(nme.utils.ArrayBufferView)
    #end
    #end
    inline function create(size) {
        var b = Bytes.alloc(size);
        #if js
        view = new js.lib.Uint8Array(b.getData());
        #else
        view.initBuffer(b);
        #end
        return b;
    }

    var step = 16;

    inline public function blit(pos:Int, src:Bytes, srcpos:Int, len:Int):Void {
        grantCapacity(pos + len);
        bytes.blit(pos, src, srcpos, len);
    }

    public inline function grantCapacity(required) {
        if (required > size) {
            var newSize = required + step;
            var b = create(newSize);
            b.blit(0, bytes, 0, size);
            size = newSize;
            bytes = b;
        }
    }

    public function getView():ArrayViewBase {
        return view;
    }
}

