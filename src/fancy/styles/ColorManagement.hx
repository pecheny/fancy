package fancy.styles;

import ec.Entity;
import ec.CtxWatcher;
import ec.Signal;

class ColorStorage {
    var colors:Map<String, Int> = new Map();

    public var changed:Signal<String->Void> = new Signal();

    public function new() {}

    public function get(alias:String) {
        return colors.get(alias);
    }

    public function reg(alias:String, color:Int) {
        colors.set(alias, color);
        changed.dispatch(alias);
    }
}

class ColorBinder implements CtxBinder {
    var storage:ColorStorage;

    public function new(s) {
        this.storage = s;
    }

    public function bind(e:Entity) {
        var r = e.getComponent(ColorReceiver);
        for(k in r.keys())
            r.setColor(k, storage.get(k));
        // storage.ch
    }

    public function unbind(e:Entity) {}
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

    public function keys() {
        return targets.keys();
    }

    public function setColor(alias, val) {
        if (!targets.exists(alias))
            return;
        for (cd in targets[alias])
            cd.setColor(val);
    }
}

interface Colored {
    function setColor(val:Int):Void;
}

// class ColorCtxWatcher extends CtxWatcher<ColorBinder> {}
