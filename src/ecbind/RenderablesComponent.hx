package ecbind;
import ec.Entity;
import ec.ICustomComponentId;
import gl.AttribSet;
import gl.Renderable;
class RenderablesComponent<T:AttribSet> implements ICustomComponentId {
    public var name(default, null):String;
    public var views(default,null):Array<Renderable<T>> = [];

    public function new(set:T, name:String = "") {
        this.name = RenderableBinder.getLayerId(set, name);
    }

    public function getId():String {
        return name;
    }

    public static function get<T:AttribSet>(attrs:T, entity:Entity, layerId = ""):RenderablesComponent<T> {
        var id = RenderableBinder.getLayerId(attrs, layerId);
        var drawcallsData = entity.hasComponentWithName(id) ?
        entity.getComponentByName(id) :
        entity.addComponentByName(id, new RenderablesComponent(attrs));
        return drawcallsData;
    }
}

