package algl;
import al.al2d.Widget2D;
import al.core.AxisState;
import al.ec.Entity;
import al.layouts.data.LayoutData;
import algl.WidgetSizeTypeGl;
import Axis2D;
import macros.AVConstructor;

class GlAxisStateFactory implements AxisFactory {
    public var type:WidgetSizeTypeGl;
    public var value:Float;
    var screen:StageAspectKeeper;
    var axis:Axis2D;

    public function new(a, s) {
        this.axis = a;
        this.screen = s;
        reset();
    }

    public function create() {
        var size = switch type {
            case sfr: new FixedSize(value); //todo /2 its fixed size in units of the parent
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
    public function new(s:StageAspectKeeper) {
        factories = AVConstructor.factoryCreate(a -> new GlAxisStateFactory(a, s));
    }

    public function h(t:WidgetSizeTypeGl, v:Float) {
        factories[horizontal].type = t;
        factories[horizontal].value = v;
        return this;
    }

    public function v(t:WidgetSizeTypeGl, v:Float) {
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
    var factories:AxisCollection2D<T>;
    var keepStateAfterBuild = false;

    public function b():Widget2D {
        var entity = new Entity();
        var axisStates = AVConstructor.factoryCreate(Axis2D, a -> factories[a].create());

        var w = new Widget2D(axisStates);
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

//
//class PlaceholderBuilder extends PlaceholderBuilderBase<SimpleAxisFactory> {
//    public function new() {
//        factories = new AxisCollection2D();
//        for (a in Axis2D.keys)
//            factories[a] = new SimpleAxisFactory();
//    }
//
//    public function h(t:SizeType, v:Float) {
//        factories[horizontal].type = t;
//        factories[horizontal].value = v;
//        return this;
//    }
//
//    public function v(t:SizeType, v:Float) {
//        factories[vertical].type = t;
//        factories[vertical].value = v;
//        return this;
//    }
//}
//
//class SimpleAxisFactory implements AxisFactory {
//    public var type:SizeType = portion;
//    public var value:Float;
//
//    public function new() {}
//
//    public function create() {
//        return new AxisState(new Position(), new Size(type, value ));
//    }
//}
//


