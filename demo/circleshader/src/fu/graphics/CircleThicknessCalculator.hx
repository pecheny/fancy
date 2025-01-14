package fu.graphics;
import Axis2D;
import SquareShape;
import a2d.Placeholder2D;
import a2d.transform.WidgetToScreenRatio;
import al.core.AxisApplier;
import gl.sets.CircleSet;
import haxe.io.Bytes;


/**
 * Calclulates r attribute values for shape assuming the UVs are normal in Placeholder's normal space.
**/
class CircleThicknessCalculator implements AxisApplier {
    var ph:Placeholder2D;
    var steps:WidgetToScreenRatio;
    var rads:RadiusAtt<CircleSet>;
    var buffer:Bytes;

    public var thikness:Float = 1.;

    public function new(ph, steps, rads, b) {
        this.ph = ph;
        this.rads = rads;
        this.steps = steps;
        this.buffer = b;
        ph.axisStates[vertical].addSibling(this);
    }

    public function apply(pos:Float, size:Float) {
        calculateRadius();
    }

    public function calculateRadius() {
        rads.r2 = 1;
        var w = ph.axisStates[horizontal].getSize();
        var h = ph.axisStates[vertical].getSize();
        var dir = w < h ? horizontal : vertical;
        var r = 1 - 2 * steps.getRatio()[dir]; // * (ph.axisStates[dir].getSize() * thikness);
        rads.r1 = r * r;
        rads.writePostions(buffer, 0, null);
    }
}
