package fu;

import ec.Entity;
import ec.IComponent;

typedef ClassMap<V> = haxe.ds.ObjectMap<Dynamic, V>;
interface PropStorage<T> {
    public function get(name:String):T;
    public function set(name:String, val:T):Void;
}

class DummyProps<T> implements PropStorage<T> {
    var map:Map<String, T> = new Map();

    public function get(name:String):T {
        return map.get(name);
    }

    public function set(k, v:T) {
        map.set(k, v);
    }

    public function new() {}
}

class MultiPropStorage implements IComponent {
    var strings:Map<String, String> = new Map();
    var ints:Map<String, Int> = new Map();
    var insts:ClassMap<Dynamic> = new ClassMap();

    public function new() {}

    public function setInstance<T>(k:Class<T>, val:T) {
        insts.set(k, val);
    }

    public function getInstance<T>(k:Class<T>):T {
        return insts.get(k) ?? parent()?.getInstance(k);
    }

    public function setString(k:String, val:String) {
        strings.set(k, val);
    }

    public function getString(k:String):String {
        return strings.get(k) ?? parent()?.getString(k);
    }

    public function setInt(k:String, val:Int) {
        ints.set(k, val);
    }

    public function getInt(k:String):Int {
        return ints.get(k) ?? parent()?.getInt(k);
    }

    @:isVar public var entity(get, set):Entity;

    function get_entity()
        return entity;

    function set_entity(value:Entity)
        return entity = value;

    inline function parent() {
        return entity?.parent?.getComponentUpward(MultiPropStorage);
    }
}

class CascadeProps<T> extends DummyProps<T> implements IComponent {
    var name:String;
    var defaultVal:T;

    @:isVar public var entity(get, set):Entity;

    public function new(defaultVal:T, name:String = "") {
        super();
        this.name = name;
        this.defaultVal = defaultVal;
    }

    inline function parent() {
        return entity?.parent?.getComponentUpward(PropStorage);
    }

    override function get(alias:String) {
        var val = super.get(alias);
        if (val != null)
            return val;
        var up = parent();
        if (up == null)
            return defaultVal;
        return up.get(alias);
    }

    function get_entity():Entity {
        return entity;
    }

    function set_entity(value:Entity):Entity {
        return entity = value;
    }
}

// class PropsAccess<T> {
//     var p:PropStorage<T>;
//     function new() {}
//     public static function getOrCreateStr<T>(e:Entity):PropsAccess<T> {
//         var pa = new PropsAccess<T>();
//         pa.p = null;
//         pa.p = e.getComponent(PropStorage);
//         if (pa.p != null)
//             return pa;
//         pa.p = new CascadeProps<T>(null, e.name + "-props");
//         e.addComponentByType(PropStorage, pa.p);
//         return pa;
//     }
//     public function with(name, val:T) {
//         p.set(name, val);
//         return this;
//     }
// }
