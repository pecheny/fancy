package graphics.shapes;
import data.IndexCollection;
import gl.ValueWriter.AttributeWriters;
import haxe.io.Bytes;
interface Shape {
    public function writePostions(target:Bytes, writer:AttributeWriters, vertOffset:Int = 0):Void;

    public function getIndices():IndexCollection;

    public function getVertsCount():Int;
}
