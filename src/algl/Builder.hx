package algl;
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
            case sfr: new FixedSize(value * 2); //todo /2 its fixed size in units of the parent
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
    public function new(s:Stage) {
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

    override function reset() {
        for (k in Axis2D)
            factories[k].reset();
    }
}

/**
* Draft for further builder generalization.
**/
class PlaceholderBuilderBase<T:AxisFactory> {
    var factories:AVector2D<T>;
    var keepStateAfterBuild = false;

    public function b():Placeholder2D {
        var entity = new Entity();
        var axisStates = AVConstructor.factoryCreate(Axis2D, a -> factories[a].create());

        var w = new Placeholder2D(axisStates);
        entity.addComponent(w);
        if (!keepStateAfterBuild)
            reset();
        return w;
    }

    function reset() {}
}

interface AxisFactory {
    function create():AxisState;
}