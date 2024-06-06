package openfl;

import ecbind.RenderableBinder;
import gl.ShaderRegistry.IShaderRegistry;
import openfl.display.Sprite;
import openfl.display.DisplayObjectContainer;
import gl.GLDisplayObject;
import ec.Entity;
import gl.AttribSet;
typedef GldoFactory<T:AttribSet> = Entity -> Xml -> GLDisplayObject<T>;
class XmlProc {
    var handlers:Map<String, GldoFactory<Dynamic>> = new Map();
    var gldoBuilder:GldoBuilder;


    public function new(gb) {
        this.gldoBuilder = gb;
    }


    public function processNode(e:Entity, node:Xml, ?container:Null<DisplayObjectContainer>):Entity {
        return switch (node.nodeName) {
            case "container" : {
                var c = new Sprite();
                e.addComponent(c);
                if (container != null) container.addChild(c);
                var dc = gldoBuilder.getDrawcalls(e);
                for (child in node.elements()) {
                    processNode(e, child, c);
                }
                e;
            }
            case "drawcall" : {
                var type = node.get("type");
                if (!handlers.exists(type)) {
                    trace ( 'No "$type" drawcall type was registered.');
                    return e;
                }
                var gldo = handlers[type](e, node);
                if (container != null)
                    container.addChild(gldo);
                else {
                    var dc = gldoBuilder.getDrawcalls(e);
                    e.addComponent(gldo);
                }
                e;
            }
            case _ :
                throw "wrong " + node.nodeName;
        }
    }


    public function regHandler(t, h) {
        handlers[t] = h;
    }

}

class GldoBuilder {
    var shaders:IShaderRegistry ;

    public function new(s) {
        this.shaders = s;
    }

    public function getDrawcalls(e:Entity) {
        if (e.hasComponent(RenderableBinder)) return e.getComponent(RenderableBinder);
        var dc = new RenderableBinder();
        e.addComponent(dc);
        return dc;
    }

    public function getGldo(e:Entity, type, aspect, name) {
        var attrs = shaders.getAttributeSet(type);
        var dc = getDrawcalls(e);
        var gldo = dc.findLayer(attrs, name);
        if (gldo != null) return gldo;
        var gldo = new GLDisplayObject(attrs, shaders.getState.bind(attrs, _, type), aspect);
        gldo.name = name;
        var dc = getDrawcalls(e);
        dc.addLayer(attrs, gldo, name);
        return gldo;
    }
}

