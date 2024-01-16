package widgets;
import al.al2d.Placeholder2D;
import ec.Entity;
class Widget implements IWidget {
    var w:Placeholder2D;
    var entity:Entity;

    public function new(w:Placeholder2D) {
        this.w = w;
        this.entity = w.entity;
        watch(w.entity);
    }

    public function widget() {
        return w;
    }

    public var p(get, null):Placeholder2D;
    public function get_p():Placeholder2D {
        return w;
    }
    public var e(get, null):Entity;
    public function get_e(){
        return entity;
    }
}

@:autoBuild(ec.macros.InitMacro.build())
interface IWidget {
    public var p(get, null):Placeholder2D;
    public var e(get, null):Entity;
}