package crosstarget;
import al.al2d.Widget2D;
import ec.Entity;
@:autoBuild(macros.InitMacro.build())
class Widgetable {
    var w:Widget2D;
    var entity:Entity;
    public function new(w:Widget2D) {
        this.w = w;
        this.entity = w.entity;
        w.entity.onContext.listen(_init);
        _init(w.entity.parent);
    }

    function _init(e:Entity){}
    
    public function init(){}

    public function widget() {
        return w;
    }
}
