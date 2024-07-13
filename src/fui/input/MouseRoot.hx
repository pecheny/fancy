package fui.input;

import a2d.Stage;
import Axis2D;
import a2d.AspectRatio;
import lime.ui.MouseButton;
import shimp.InputSystem;
import widgets.utils.WidgetHitTester.Point;

class MouseRoot {
    var stage:Stage;
    var ar:AspectRatio;
    var wndSize:ReadOnlyAVector2D<Int>;
    var target:InputTarget<Point>;
    var pos = new Point();

    public function new(trg, stage) {
        this.target = trg;
        this.ar = stage.getAspectRatio();
        wndSize = stage.getWindowSize();
        var wnd = lime.app.Application.current.window;
        wnd.onMouseMove.add(onMoved);
        wnd.onMouseDown.add(onStarted);
        wnd.onMouseUp.add(onEnded);
    }

    inline function setPos(x:Float, y:Float) {
        pos.x = 2 * x / wndSize[horizontal] * ar[horizontal];
        pos.y = 2 * y / wndSize[vertical] * ar[vertical];
    }

    function onStarted(x:Float, y:Float, mb:MouseButton) {
        if (mb != LEFT)
            return;
        setPos(x, y);
        target.setPos(pos);
        target.press();
    }

    function onEnded(x:Float, y:Float, mb:MouseButton) {
        if (mb != LEFT)
            return;
        setPos(x, y);
        target.setPos(pos);
        target.release();
    }

    function onMoved(x:Float, y:Float) {
        setPos(x, y);
        target.setPos(pos);
    }
}
