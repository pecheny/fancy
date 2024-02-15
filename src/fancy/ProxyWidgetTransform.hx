package fancy;

import macros.AVConstructor;
import al.Builder;
import Axis2D;
import al.core.AxisApplier;
import al.al2d.Placeholder2D;
import al.al2d.Widget;

class ProxyWidgetTransform extends Widget {
    public var target(default, null):Placeholder2D;

    var transform:AVector2D<TransformAxisApplier> = AVConstructor.empty();
    @:once var scale:ScaleComponent;

    public function new(ph:Placeholder2D) {
        target = Builder.ph();
        ph.entity.addComponent(target);
        for (a in Axis2D) {
            var ta = new TransformAxisApplier(target.axisStates[a]);
            ph.axisStates[a].addSibling(ta);
            transform[a] = ta;
        }
        super(ph);
    }

    override function get_ph():Placeholder2D {
        return target;
    }

    override function init() {
        super.init();
        scale.onChange.listen(onScale);
        onScale();
    }

    public function setPadding(v:Float) {
        for (a in Axis2D) {
            var aa = transform[a];
            aa.padding = v;
        }
        applyAxis();
    }

    function onScale() {
        var h = ph.axisStates[vertical].getSize();
        var padding = (h - h * scale.value) / 2;
        setPadding(padding);
    }

    function applyAxis() {
        for (a in Axis2D) {
            var aa = super.ph.axisStates[a];
            aa.apply(aa.getPos(), aa.getSize());
        }
    }
}

class TransformAxisApplier implements AxisApplier {
    var target:AxisApplier;

    public var offset:Float = 0;
    public var padding:Float = 0;

    public function new(target) {
        this.target = target;
    }

    public function apply(pos:Float, size:Float) {
        target.apply(offset + padding + pos, size - padding * 2);
    }
}
