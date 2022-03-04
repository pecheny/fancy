package entitygl;
import data.AttribSet;
import ec.CtxBinder.CtxBindable;
import ec.Entity;
import gltools.VertIndDataProvider;
import oglrenderer.GLLayer;
class Drawcalls implements CtxBindable {
    var map = new GLLayersCollection();

    public function new() {}

    public function addLayer<T:AttribSet>(set:T, layer:GLLayer<T>, name = "") {
        var id = getLayerId(set, name);
        if (map.exists(id))
            throw "Already has layer with id " + id;
        map.set(id, layer);
    }

    public function addView<T:AttribSet>(set:T, view:VertIndDataProvider<T>, layerName = "") {
        var id = getLayerId(set, layerName);
        if (map.exists(id))
            map.get(id).addView(view);
        else
            trace("WARN: no gl-layer withid " + id);
    }


    public function bind(e:Entity) {
//        trace("bind");
        var keys = map.keys();
        for (key in keys) {
            var ddp:DrawcallDataProvider<AttribSet> = e.getComponentByName(key);
//            trace(key + " " + ddp);
            if (ddp == null)
                continue;
            var l = map.get(cast key);
            for (v in ddp.views)
                l.addView(v);
        }
    }

    public function unbind(e:Entity) {
//        trace("unbind");
        var keys = map.keys();
        for (key in keys) {
            var ddp:DrawcallDataProvider<AttribSet> = e.getComponentByName(key);
//            trace(key + " " + ddp);
            if (ddp == null)
                continue;
            var l = map.get(cast key);
            for (v in ddp.views)
                l.removeView(v);
        }
    }

    public static function getLayerId<T:AttribSet>(set:T, layerName:String) {
        return new LayerId(set, layerName);
    }
}

abstract LayerId<T:AttribSet>(String) to String {
    public inline function new(set:T, n:String) {
        this = $type(set) + "_" + n;
    }
}
@:forward(keys, exists)
abstract GLLayersCollection(Map<String, GLLayer<AttribSet>>) {
    public function new() {
        this = new Map();
    }

    public inline function get<T:AttribSet>(lId:LayerId<T>):GLLayer<T> {
        return cast this.get(lId);
    }

    public inline function set<T:AttribSet>(lId:LayerId<T>, l:GLLayer<T>) {
        this.set(lId, cast l);
    }
}

