package data;
import data.DataType;
class AttributeState {
    public var numComponents:Int;
    public var idx:Int;
    public var name:String;
    public var type:DataType; // remove, keep in descr only
    public var offset:Int;

    public function new(idx:Int, numComponents:Int, type:DataType, name:String) {
        this.numComponents = numComponents;
        this.idx = idx;
        this.name = name;
        this.type = type;
    }
}
