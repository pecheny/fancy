package widgets.utils;
import al.al2d.Placeholder2D;
import Axis2D;
import shimp.InputSystem.HitTester;
import shimp.IPos;
import macros.AVConstructor;
class WidgetHitTester implements HitTester<Point> {
    var w:Placeholder2D;

    public function new(w) {
        this.w = w;
    }

    public function isUnder(pos:Point):Bool {
        for (a in Axis2D) {
            var axis = w.axisStates[a];
            var val = @:privateAccess pos.vec[a];
            if (val < axis.getPos())
                return false;
            if (val > (axis.getPos() + axis.getSize()))
                return false;
        }
        return true;
    }
}

class Point implements IPos<Point> {
   var vec:AVector2D<Float> = AVConstructor.create(0., 0.);
    public var x(get, set):Float;
    public var y(get, set):Float;
    public function new(){}

    public function equals(other:Point):Bool {
        return x == other.x && y == other.y;
    }

    public function setValue(other:Point):Void {
        x = other.x;
        y = other.y;
    }

    function get_x():Float {
        return vec[horizontal];
    }

    function set_x(value:Float):Float {
        return vec[horizontal] = value;
    }
    function get_y():Float {
        return vec[vertical];
    }

    function set_y(value:Float):Float {
        return vec[vertical] = value;
    }
}
