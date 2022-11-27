package widgets;
import al.al2d.Placeholder2D;
import ec.Entity;
@:autoBuild(ec.macros.InitMacro.build())
class Widget {
    var w:Placeholder2D;
    var entity:Entity;

    public function new(w:Placeholder2D) {
        this.w = w;
        this.entity = w.entity;
        w.entity.onContext.listen(_init);
        _init(w.entity.parent);
    }

    function _init(e:Entity) {}

    public function init() {}

    public function widget() {
        return w;
    }
}
