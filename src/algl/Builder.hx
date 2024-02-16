package algl;

import fancy.ScaleComponent;
import fancy.ProxyWidgetTransform;
import al.core.Placeholder.MultiparentPlaceholder;
import ec.MultiparentEntity;
import al.core.Placeholder.PlainPlaceholder;
import a2d.Stage;
import al.al2d.Placeholder2D;
import al.core.AxisState;
import al.ec.Entity;
import al.layouts.data.LayoutData;
import algl.ScreenMeasureUnit;
import Axis2D;
import macros.AVConstructor;

class GlAxisStateFactory implements AxisFactory {
    public var type:ScreenMeasureUnit;
    public var value:Float;

    var screen:Stage;
    var axis:Axis2D;

    public function new(a, s) {
        this.axis = a;
        this.screen = s;
        reset();
    }

    public function create() {
        var size = switch type {
            case sfr: new FixedSize(value * 2); // todo /2 its fixed size in units of the parent
            case pfr: new FractionSize(value);
            case px: new PixelSize(axis, screen, value);
        }
        return new AxisState(new Position(), size);
    }

    public function reset() {
        type = pfr;
        value = 1;
    }
}

class PlaceholderBuilderGl extends PlaceholderBuilderBase<GlAxisStateFactory> {
    var s:Stage;
    var addLIquid:Bool; // all the time
    var _l:Bool; // once
    var scale:Null<Float>;

    public function new(s:Stage, addLiquid = false) {
        this.s = s;
        this.addLIquid = addLiquid;
        factories = AVConstructor.factoryCreate(a -> new GlAxisStateFactory(a, s));
    }

    public function h(t:ScreenMeasureUnit, v:Float) {
        factories[horizontal].type = t;
        factories[horizontal].value = v;
        return this;
    }

    public function v(t:ScreenMeasureUnit, v:Float) {
        factories[vertical].type = t;
        factories[vertical].value = v;
        return this;
    }

    public function l() {
        _l = true;
        return this;
    }

    override function reset() {
        super.reset();
        _l = false;
        scale = null;
        for (k in Axis2D)
            factories[k].reset();
    }

    public function t(s:Float = 1) {
        scale = s;
        return this;
    }


    override function b(name:String = null):Placeholder2D {
        var _l = this._l;
        var _s = this.scale;
        var w = super.b(name);
        if (_l || addLIquid)
            widgets.utils.Utils.withLiquidTransform(w, s.getAspectRatio());
        if (_s != null) {
            var scale = ScaleComponent.getOrCreate(w.entity);
            scale.value = this.scale;
            var trans = new ProxyWidgetTransform(w);
            w.entity.addComponent(trans);
        }
        return w;
    }
}

/**
 * Draft for further builder generalization.
**/
class PlaceholderBuilderBase<T:AxisFactory> {
    var factories:AVector2D<T>;

    public var keepStateAfterBuild = false;

    public function b(name:String = null):Placeholder2D {
        var axisStates = AVConstructor.factoryCreate(Axis2D, a -> factories[a].create());
        var w:Placeholder2D;
        var e:ec.Entity;

        if (_ctx != null) {
            var entity = new MultiparentEntity(name);
            e = entity;
            entity.addParent(_ctx);
            var mph = new MultiparentPlaceholder(axisStates);
            mph.setEntity(entity);
            w = mph;
            entity.addComponent(w);
        } else {
            var entity = new Entity(name);
            e = entity;
            w = new PlainPlaceholder(axisStates);
        }
        e.addComponentByType(Placeholder2D, w);
        if (!keepStateAfterBuild)
            reset();
        return w;
    }

    var _ctx:Entity;

    public function ctx(e:Entity) {
        _ctx = e;
        return this;
    }

    function reset() {
        _ctx = null;
    }
}

interface AxisFactory {
    function create():AxisState;
}
