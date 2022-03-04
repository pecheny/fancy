package entitygl;
import data.AttribSet;
import ec.Entity;
import ec.ICustomComponentId;
import gltools.VertIndDataProvider;
class DrawcallDataProvider<T:AttribSet> implements ICustomComponentId {
    public var name(default, null):String;
    public var views(default,null):Array<VertIndDataProvider<T>> = [];

    public function new(set:T, name:String = "") {
        this.name = Drawcalls.getLayerId(set, name);
    }

    public function getId():String {
        return name;
    }

    public static function get<T:AttribSet>(attrs:T, entity:Entity, layerId = ""):DrawcallDataProvider<T> {
        var id = Drawcalls.getLayerId(attrs, layerId);
        var drawcallsData = entity.hasComponentWithName(id) ?
        entity.getComponentByName(id) :
        entity.addComponentByName(id, new DrawcallDataProvider(attrs));
        return drawcallsData;
    }
}

