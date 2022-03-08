package bindings;
//typedef StringMap =
//#if python
//PyStringMap
//#else
//haxe.ds.StringMap
//#end
//;
@:keep
class StringMap {
    var m = new haxe.ds.StringMap<Dynamic>();
    public function new(){}

    public function set(k, v) {
        m.set(k,v);
    }

    public function get(k){
        return m.get(k);
    }

    public function toMap() {
        return m;
    }
}
