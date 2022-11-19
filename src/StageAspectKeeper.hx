package ;
import a2d.Stage;
import macros.AVConstructor;
import Axis2D;
import a2d.AspectRatioProvider;
import openfl.events.Event;
class StageAspectKeeper implements Stage {
    var base:Float;
    public var aspects = AVConstructor.create(Axis2D, 1., 1.);
    public var size = AVConstructor.create(Axis2D, 1, 1);
    public var pos = AVConstructor.create(Axis2D, 0., 0.);

    var width:Float;
    var height:Float;

    public function new(base:Float = 1) {
        this.base = base;
        openfl.Lib.current.stage.addEventListener(Event.RESIZE, onResize);
        onResize(null);
    }

    function onResize(e) {
        var stage = openfl.Lib.current.stage;
        width = stage.stageWidth;
        height = stage.stageHeight;
        size[horizontal] = stage.stageWidth;
        size[vertical] = stage.stageHeight;
        if (width > height) {
            aspects[horizontal] = (base * width / height);
            aspects[vertical] = base;
        } else {
            aspects[horizontal] = base;
            aspects[vertical] = (base * height / width);
        }
    }

    public inline function getFactor(cmp:Axis2D):Float {
        return aspects[cmp];
    }

    public function getFactorsRef():ReadOnlyAVector2D<Float> {
        return aspects;
    }

    public function getWindowSize():ReadOnlyAVector2D<Int> {
        return size;
    }

    public function getValue(a:Axis2D):Float {
        return if (a == horizontal) width else height;
    }
}
