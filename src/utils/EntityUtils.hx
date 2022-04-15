package utils;
import ec.Entity;
class EntityUtils {
    public static function showTree<T>(e:Entity, c:Class<T>, lvl = 0) {
        trace([for (i in 0...lvl) "="].join("") + e.name + " ===" + e.getComponent(c));
        for (ch in e.getChildren())
            showTree(ch, c, lvl + 1);
    }
}
