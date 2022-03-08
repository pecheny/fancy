package data;
import utils.DynamicBytes;
import haxe.io.Bytes;
import haxe.io.UInt16Array;
abstract IndexCollection(Bytes) from Bytes to Bytes {
    public static inline var ELEMENT_SIZE = 2;

    public function new(size) {
        this = Bytes.alloc(ELEMENT_SIZE * size);
    }

    @:arrayAccess
    public inline function get(i) {
        return this.getUInt16(i * ELEMENT_SIZE);
    }

    @:arrayAccess
    public inline function set(i, val) {
        return this.setUInt16(i * ELEMENT_SIZE, val);
    }

    public var length(get, never):Int;

    inline function get_length():Int {
        return Std.int(this.length / ELEMENT_SIZE);
    }

    public static function forQuads(count) {
        var ic = new IndexCollection(count * 6);
        for (i in 0...count) {
            var j = i * 6;
            ic[j] = i * 4;
            ic[j + 1] = i * 4 + 1;
            ic[j + 2] = i * 4 + 2;
            ic[j + 3] = i * 4 ;
            ic[j + 4] = i * 4 + 3;
            ic[j + 5] = i * 4 + 2;
        }
        return ic;
    }

    public static function forQuadsOdd(count) {
        var ic = new IndexCollection(count * 6);
        for (i in 0...count) {
            var j = i * 6;
            ic[j] = i * 4;
            ic[j + 1] = i * 4 + 1;
            ic[j + 2] = i * 4 + 3;
            ic[j + 3] = i * 4 ;
            ic[j + 4] = i * 4 + 3;
            ic[j + 5] = i * 4 + 2;
        }
        return ic;
    }

    public static function qGrid(w, h) {
        var qCount = (w-1) * (h-1);
        var triCount = qCount * 2;
        var ic = new IndexCollection(triCount * 3);
        var idx = 0;

        for (line in 0...h - 1) {
            for (q in 0...w - 1) {
                ic[idx++] = line * w + q;
                ic[idx++] = line * w + q + 1;
                ic[idx++] = (line + 1) * w + q ;

                ic[idx++] = (line + 1) * w + q ;
                ic[idx++] = line * w + q + 1;
                ic[idx++] = (line + 1) * w + q +1;
            }
        }

        return ic;
    }

    public function toString() {
        return "" + [for (i in 0...length) get(i)];
    }
}

class IndexCollections {
    public static final QUAD = IndexCollection.forQuads(1);
    public static final QUAD_ODD = IndexCollection.forQuadsOdd(1);
}




class IndicesFetcher {

//    todo blit!1111
/**
*   startFrom - offset within target to write to,
*   offset - lenth of prev vert buffer to add on each vert index
**/
    public static inline function gatherIndices(target:DynamicBytes, startFrom:Int, offset, source:Bytes, count) {
        for (i in 0...count) {
            var uInt = source.getUInt16(i * UInt16Array.BYTES_PER_ELEMENT);
            var pos = (i + startFrom ) * UInt16Array.BYTES_PER_ELEMENT;
            target.grantCapacity(pos + UInt16Array.BYTES_PER_ELEMENT);
            target.bytes.setUInt16(pos, uInt + offset);
        }
    }
}
