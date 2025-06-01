package backends.openfl;

import al.openfl.display.DrawcallDataProvider;
import al.openfl.display.FlashDisplayRoot;
import ec.CtxWatcher;
import ec.Entity;
import ecbind.RenderableBinder;
import gl.AttribSet;
import gl.GLNode;
import gl.OflGLNodeAdapter;
import gl.RenderingPipeline;
import gl.aspects.AlphaBlendingAspect;

class DrawcallUtils {
    public static function createContainer(pipeline:RenderingPipeline, e:Entity, descr):Entity {
        RenderableBinder.getOrCreate(e); // to prevent
        var node = pipeline.createContainer(descr);
        node.addAspect(new AlphaBlendingAspect());
        bindLayer(e, node);
        var adapter = new OflGLNodeAdapter();
        adapter.addNode(node);
        DrawcallDataProvider.get(e).addView(adapter);
        new CtxWatcher(FlashDisplayRoot, e);
        return e;
    }

    static function bindLayer(e, glnode:GLNode) {
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
