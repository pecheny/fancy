package utils;
class LazyMap<K:String, T> {
    var map:Map<K, T> = new Map();
    var provider:K -> T;

    public function new(provider) {
        this.provider = provider;
    }

    @:arrayAccess public inline function get(k:K):T {
        if (map.exists(k))
            return map[k];
        var val = provider(k);
        map[k] = val;
        return val;
    }
}

