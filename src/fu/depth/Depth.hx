package fu.depth;

import al.core.AxisApplier;
import al.core.AxisState;
import al.core.Placeholder.PlainPlaceholder;
import al.core.WidgetContainer;
import al.layouts.PortionLayout;
import al.layouts.data.LayoutData.FractionSize;
import al.layouts.data.LayoutData.Position;
import ec.CtxWatcher.CtxBinder;
import ec.CtxWatcher;
import ec.Entity;
import macros.AVConstructor;

@:build(macros.BuildMacro.buildAxes())
@:enum abstract DepthAxis(Axis<DepthAxis>) to Axis<DepthAxis> to Int {
    var depth = 0;
}

typedef DepthPh = PlainPlaceholder<DepthAxis>;
typedef DepthRangeContainer = WidgetContainer<DepthAxis, DepthPh>;

class Depth {
    public static function configureContainer(e:Entity, zindex = 0) {
        al.prop.DepthComponent.getOrCreate(e);
        var dc = DepthRangeComponent.getOrCreate(e, 1);
        var zi = ZIndexComponent.getOrCreate(e);
        zi.value = zindex;
        var ph = new DepthPh(AVConstructor.create(DepthAxis, new AxisState(new Position(), new FractionSize(1))));
        ph.axisStates[depth].addSibling(new DepthAxisApplier(dc));
        e.addComponent(ph);
        var c = new DepthRangeContainer(ph, 1);
        c.setLayout(depth, PortionLayout.instance);
        c.refreshOnChildrenChanged = true;
        e.addComponent(c);
        e.addComponent(new DepthBinder(c));
        new CtxWatcher(DepthBinder, e, true);

        ec.DebugInit.initCheck.listen((_:Entity) -> {
            trace(e.getPath(), c.getChildren().map(ph -> ph.entity.name + " " + ph.axisStates[depth].getPos() + " " + ph.axisStates[depth].getSize()),
                '[${dc.value}, ${dc.maxValue}]');
        });
    }
}

class DepthAxisApplier implements AxisApplier {
    var target:DepthRangeComponent;

    public function new(target) {
        this.target = target;
    }

    public function apply(pos:Float, size:Float) {
        @:bypassAccessor target.value = pos;
        target.maxValue = pos + size;
    }
}

class DepthBinder implements CtxBinder {
    var container:DepthRangeContainer;

    public function new(container) {
        this.container = container;
    }

    public function bind(e:Entity) {
        var ph = e.getComponent(DepthPh);
        if (ph == null)
            return;
        container.addChild(ph);
        var zi = ph.entity.getComponent(ZIndexComponent);
        if (zi == null) {
            container.refresh();
            return;
        }
        var children = container.getChildren().copy();
        for (ch in children)
            container.removeChild(ch);

        children.sort((d1:DepthPh, d2:DepthPh) -> {
            var a = d1.entity.getComponent(ZIndexComponent).value ?? 0;
            var b = d2.entity.getComponent(ZIndexComponent).value ?? 0;
            var aNeg = a < 0;
            var bNeg = b < 0;
            if (aNeg != bNeg) {
                return aNeg ? 1 : -1;
            }
            return a - b;
        });

        for (ch in children)
            container.addChild(ch);
    }

    public function unbind(e:Entity) {
        var ph = e.getComponent(DepthPh);
        if (ph == null)
            return;
        container.removeChild(ph);
    }
}
