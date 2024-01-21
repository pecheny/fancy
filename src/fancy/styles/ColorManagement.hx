package fancy.styles;

import haxe.ds.HashMap;
import ec.IComponent;
import ec.Entity;
import ec.CtxWatcher;
import ec.Signal;

class ColorStorage {
    var colors:Map<String, Int> = new Map();

    public var changed:Signal<String->Void> = new Signal();
    // public var contextChanged:Signal<Void->Void> = new Signal();

    public function new() {}

    public function get(alias:String) {
        return colors.get(alias);
    }

    public function reg(alias:String, color:Int) {
        colors.set(alias, color);
        changed.dispatch(alias);
    }
}

class ColorStorageComponent extends ColorStorage implements IComponent implements CtxBinder {
    @:isVar public var entity(get, set):Entity;

    public function get_entity():Entity {
        return entity;
    }

    public function set_entity(value:Entity):Entity {
        if (entity != null)
            throw "Not for rebind";

        new CtxWatcher(ColorStorageComponent, value, true);
        // listen upward storages for color changes ???
        value.addComponent(new ColorBinder(this));
        return this.entity = value;
    }

    public function bind(e:Entity) {
        var child = e.getComponent(ColorStorageComponent);
        changed.listen(child.onParentColorChange);
        // child.contextChanged.dispatch();
    }

    public function unbind(e:Entity) {
        var child = e.getComponent(ColorStorageComponent);
        changed.remove(child.onParentColorChange);
    }

    public function onParentColorChange(alias) {
        if (colors.exists(alias))
            return;
        changed.dispatch(alias);
    }

    inline function paretn() {
        return entity?.parent?.getComponentUpward(ColorStorageComponent);
    }

    override function get(alias:String):Null<Int> {
        var val = super.get(alias);
        if (val != null)
            return val;
        var up = paretn();
        if (up == null)
            return 0;
        return up.get(alias);
    }

    // public function listAvailableColors() {
    //     // quite not optimized, if your code uses color rebinding often, pay attention to implement caching
    //     var myColors = [for (k in colors.keys()) k];
    //     var up = paretn();
    //     if (up == null)
    //         return myColors;
    //     var parentColors = up.listAvailableColors();
    //     for (c in parentColors)
    //         if(!colors.exists(c))
    //             myColors.push(c);
    //     return myColors;
    // }
}

class ColorBinder implements CtxBinder {
    var storage:ColorStorage;

    public function new(s) {
        this.storage = s;
    }

    public function bind(e:Entity) {
        var r = e.getComponent(ColorReceiver);
        r.listen(storage);
    }

    public function unbind(e:Entity) {
        var r = e.getComponent(ColorReceiver);
        r.listen(null);
    }
}

@:forward
abstract AutoArrayMap<TKey, TVal>(Map<TKey, Array<TVal>>) from Map<TKey, Array<TVal>> {
    @:arrayAccess
    public inline function get(k:TKey) {
        if (!this.exists(k)) {
            this.set(k, []);
        }
        return this.get(k);
    }
}

class ColorReceiver {
    var targets:AutoArrayMap<String, Colored> = new Map();

    public function new() {}

    public function addColored(alias:String, cd:Colored) {
        targets[alias].push(cd);
    }

    // public function keys() {
    //     return targets.keys();
    // }

    public function setColor(alias, val) {
        if (!targets.exists(alias))
            return;
        for (cd in targets[alias])
            cd.setColor(val);
    }

    function onColorChanged(alias) {
        setColor(alias, source.get(alias));
    }

    function onCtxChanged() {
        if (source == null)
            return;
        for (k in targets.keys())
            setColor(k, source.get(k));
    }

    var source:ColorStorage;

    public function listen(source:ColorStorage) {
        if (this.source != null) {
            this.source.changed.remove(onColorChanged);
            // this.source.contextChanged.remove(onCtxChanged);
        }
        this.source = source;
        if (this.source != null) {
            // this.source.contextChanged.listen(onCtxChanged);
            this.source.changed.listen(onColorChanged);
            onCtxChanged();
        }
    }
}

interface Colored {
    function setColor(val:Int):Void;
}

