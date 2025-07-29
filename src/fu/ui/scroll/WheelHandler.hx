package fu.ui.scroll;

import shimp.Point;
import shimp.InputSystem.InputSystemTarget;
import fu.ui.scroll.ScrollableContent.Scrollable;
import a2d.Widget;

class WheelHandler extends Widget {
    @:once var scrollable:Scrollable;
    @:once var input:InputSystemTarget<Point>;
    var sinput:ScrollboxInput = null;
    var direction:Axis2D;

    public function new(ph, direction) {
        super(ph);
        this.direction = direction;
    }

    override function init() {
        if (Std.isOfType(input, ScrollboxInput))
            sinput = cast input;
        if (sinput != null)
            openfl.Lib.current.stage.addEventListener(openfl.events.MouseEvent.MOUSE_WHEEL, onWheel);
    }

    function onWheel(e:openfl.events.MouseEvent) {
        if (sinput != null && @:privateAccess sinput.enabled)
            scrollable.setOffset(direction, scrollable.getOffset(direction) + e.delta * 0.1);
    }
}
