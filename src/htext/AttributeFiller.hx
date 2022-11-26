package htext;
import haxe.io.Bytes;
interface AttributeFiller {
    function write(target:Bytes, startVert:Int):Void;
}
