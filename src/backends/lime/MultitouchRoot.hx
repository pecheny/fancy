package backends.lime;

import Axis2D;
import a2d.AspectRatio;
import lime.ui.Touch;
import shimp.MultiInputTarget;
import shimp.Point;


class MultitouchRoot {
    var ar:AspectRatio;
    var target:MultiInputTarget<Point>;
    var pos = new Point();

    public function new(trg, ar) {
        this.target = trg;
        this.ar = ar;
        Touch.onStart.add(onTouchStarted);
        Touch.onEnd.add(onTouchEnded);
        Touch.onMove.add(onTouchMoved);
        Touch.onCancel.add(onTouchCancel);
    }

    inline function setPos(t:Touch) {
        pos.x = 2 * t.x * ar[horizontal];
        pos.y = 2 * t.y * ar[vertical];
    }

    function onTouchStarted(t:Touch) {
        setPos(t);
        target.setPos(t.id, pos);
        target.press(t.id);
    }

    function onTouchEnded(t:Touch) {
        setPos(t);
        target.setPos(t.id, pos);
        target.release(t.id);
    }

    function onTouchMoved(t:Touch) {
        setPos(t);
        target.setPos(t.id, pos);
    }

    function onTouchCancel(t:Touch) {
        setPos(t);
        target.setPos(t.id, pos);
        target.release(t.id);
    }
}
