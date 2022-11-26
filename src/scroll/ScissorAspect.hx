package scroll;
import al.al2d.Placeholder2D;
import al.core.AxisApplier;
import Axis2D;
import gl.aspects.RenderingAspect;
import gl.GLDisplayObject.GLState;
import a2d.AspectRatio;
typedef  DisplayObject = {x:Float, y:Float, width:Float, height:Float }
class DOVerticalApplier implements AxisApplier {
    var target:DisplayObject;

    public function new(t) this.target = t;


    public function apply(pos:Float, size:Float):Void {
        target.y = pos;
        target.height = size;
    }
}
class DOHorizontalApplier implements AxisApplier {
    var target:DisplayObject;

    public function new(t) this.target = t;


    public function apply(pos:Float, size:Float):Void {
        target.x = pos;
        target.width = size;
    }
}
class DOVerticalPosApplier implements AxisApplier {
    var target:DisplayObject;

    public function new(t) this.target = t;


    public function apply(pos:Float, size:Float):Void {
        target.y = pos;
    }
}
class DOHorizontalPosApplier implements AxisApplier {
    var target:DisplayObject;

    public function new(t) this.target = t;


    public function apply(pos:Float, size:Float):Void {
        target.x = pos;
    }
}

class ScissorAspect implements RenderingAspect {
    var stg:openfl.display.Stage;
    var ar:AspectRatio;

    public var x:Float = 0;
    public var y:Float = 0;
    public var width:Float = 2;
    public var height:Float = 2;

    public function new(w:Placeholder2D, ar) {
        this.ar = ar;
        stg = openfl.Lib.current.stage;
        w.axisStates[Axis2D.horizontal].addSibling(new DOHorizontalApplier(this));
        w.axisStates[Axis2D.vertical].addSibling(new DOVerticalApplier(this));
    }

    public function bind(state:GLState<Dynamic>):Void {
        var x = Std.int(this.x / ar[horizontal] * stg.stageWidth / 2);
        var y = Std.int(this.y / ar[vertical] * stg.stageHeight / 2);
        var width = Std.int(this.width  / ar[horizontal]* stg.stageWidth / 2);
        var height = Std.int(this.height / ar[vertical] * stg.stageHeight / 2);
        state.gl.scissor(x, y, width, height);
    }

    public function unbind(state:GLState<Dynamic>):Void {
        state.gl.scissor(0, 0, stg.stageWidth, stg.stageHeight);
    }
}

