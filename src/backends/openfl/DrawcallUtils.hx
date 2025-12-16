package backends.openfl;

import ecbind.RenderableBinder;
import gl.AttribSet;
import gl.GLNode;

class DrawcallUtils {
    /** 
        Registers all drawcalls provided by `glnode` as a `CtxBinder`. All `Renderable` in the descendant hierarchy of `e` 
        would be collected and rendered by these drawcalls until other descending CtxBinder.
    **/
    public static function bindLayer(e, glnode:GLNode) {
        var binder = RenderableBinder.getOrCreate(e);
        if (Std.isOfType(glnode, ContainerGLNode)) {
            var c = cast(glnode, ContainerGLNode);
            for (ch in c.children)
                bindLayer(e, ch);
        }
        if (Std.isOfType(glnode, ShadedGLNode)) {
            var gldo:ShadedGLNode<AttribSet> = cast glnode;
            binder.bindLayer(e, gldo.set, glnode.name, gldo);
        }
    }
}
