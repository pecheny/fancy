package ;
import transform.AspectRatioProvider;
import Axis;
import haxe.ds.ReadOnlyArray;
import openfl.events.Event;
class StageAspectKeeper implements AspectRatioProvider {
    var base:Float;
    public var aspects:Array<Float> = [1, 1];
    public var size:Array<Int> = [1, 1];
    public var pos:Array<Float> = [0, 0];

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
        size[0] = stage.stageWidth;
        size[1] = stage.stageHeight;
        if (width > height) {
            aspects[0] = (base * width / height);
            aspects[1] = base;
        } else {
            aspects[0] = base;
            aspects[1] = (base * height / width);
        }
    }

    public inline function getFactor(cmp:Int):Float {
        return aspects[cmp];
    }

    public function getFactorsRef():ReadOnlyArray<Float> {
        return aspects;
    }

    public function getWindowSize():ReadOnlyArray<Int> {
        return size;
    }

    public function getValue(a:Axis2D):Float {
        return if (a == horizontal) width else height;
    }
}
