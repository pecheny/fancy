
package backends.openfl;

import ec.Entity;
import gl.AttribSet;
import gl.GLNode;
import gl.OflGLNodeAdapter;
import gl.aspects.AlphaBlendingAspect;
import ecbind.RenderableBinder;
import gl.RenderingPipeline;

class DrawcallUtils {
    
	public static function createContainer(pipeline:RenderingPipeline,e:Entity, descr):Entity {
		RenderableBinder.getOrCreate(e); // to prevent
		var node = pipeline.createContainer(descr);
		node.addAspect(new AlphaBlendingAspect());
		bindLayer(e, node);
		var adapter = new OflGLNodeAdapter();
		adapter.addNode(node);
        e.addComponent(adapter);
		openfl.Lib.current.stage.addChild(adapter);
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