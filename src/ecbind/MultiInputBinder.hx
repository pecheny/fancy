package ecbind;

import ec.CtxWatcher.CtxBinder;
import ec.Entity;
import shimp.MultiInputTarget;
import widgets.utils.WidgetHitTester.Point;

/**
    Combines mouse and touch input events for MultiInput targets.
    0 id is reserved for mouse, touch events pass with offset.
**/
class MultiInputBinder implements CtxBinder implements MultiInputTarget<Point> {
    var children:Array<MultiInputTarget<Point>> = [];

    public function new() {}

    public function setPos(id:Int, pos:Point):Void {
        for (ch in children)
            ch.setPos(id + 1, pos);
    }

    public function press(id:Int):Void {
        for (ch in children)
            ch.press(id + 1);
    }

    public function release(id:Int):Void {
        for (ch in children)
            ch.release(id + 1);
    }

    public function bind(e:Entity):Void {
        var ch = e.getComponent(MultiInputTarget);
        if (ch != null) {
            children.push(ch);
        }
    }

    public function unbind(e:Entity):Void {
        var ch = e.getComponent(MultiInputTarget);
        if (ch != null) {
            children.remove(ch);
        }
    }
}
