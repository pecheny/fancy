package fu.ui.scroll;

import al.core.ResizableWidget;
import al.core.WidgetContainer;
import macros.AVConstructor;
import Axis2D;
import utils.Mathu;
import a2d.Placeholder2D;
import a2d.Widget2DContainer;
import al.core.AxisApplier;
import a2d.Widget;
import ec.Signal;

// provides content size, store ofset, apply offset
interface Scrollable {
    function setOffset(a:Axis2D, val:Float):Float;
    function getOffset(a:Axis2D):Float;
}

class ScrollableContent extends Widget implements Scrollable {
    var axis:AVector2D<ScrollableAxisState> = AVConstructor.create(null, null);

    public function new(placeholder:Placeholder2D) {
        super(placeholder);
    }

    public function setOffset(a:Axis2D, val:Float) {
        if (axis[a] != null) {
            var r = axis[a].setOffset(val);
            var pha = ph.axisStates[a];
            axis[a].apply(pha.getPos(), pha.getSize());
            return r;
        }
        return 0;
    }

    public function getOffset(a:Axis2D) {
        if (axis[a] != null) {
            return axis[a].offset;
        }
        return 0;
    }

    public function getContentSize(a:Axis2D) {
        return 0.;
    }
}

class W2CScrollableContent extends ScrollableContent implements ContentSizeProvider<Axis2D> {
    var w2c:ResizableWidget2D;

    public var contentSizeChanged(default, null):Signal<Axis2D->Void>;

    public function new(content:ResizableWidget2D, placeholder:Placeholder2D) {
        super(placeholder);
        w2c = content;
        contentSizeChanged = w2c.contentSizeChanged;
        var c = content;
        placeholder.entity.addChild(content.entity);
        for (a in Axis2D) {
            var offsetAxis = new ScrollableAxisState(c.ph.axisStates[a], a, this);
            axis[a] = offsetAxis;
            ph.axisStates[a].addSibling(offsetAxis);
        }
    }

    public override function getContentSize(a:Axis2D):Float {
        return Math.max(w2c.getContentSize(a), ph.axisStates[a].getSize());
    }
}

class W2DScrollableContent extends ScrollableContent implements ContentSizeProvider<Axis2D> {
    var contentSize:AVector2D<Float> = AVConstructor.create(0, 0);

    public var contentSizeChanged(default, null) = new Signal<Axis2D->Void>();

    public function new(content:Placeholder2D, placeholder:Placeholder2D) {
        super(placeholder);
        var c = content;
        ph.entity.addChild(content.entity);
        for (a in Axis2D) {
            var fixed = c.axisStates[a].size.getFixed();
            if (fixed > 0) {
                var offsetAxis = new ScrollableAxisState(c.axisStates[a], a, this);
                contentSize[a] = fixed;
                axis[a] = offsetAxis;
                ph.axisStates[a].addSibling(offsetAxis);
            } else {
                ph.axisStates[a].addSibling(c.axisStates[a]);
            }
        }
    }

    public override function getContentSize(a:Axis2D):Float {
        // todo check if correct
        if (contentSize[a] == 0)
            return ph.axisStates[a].getSize();
        return contentSize[a];
    }
}

class ScrollableAxisState implements AxisApplier {
    public var visibleSize:Float = 0;
    public var offset(default, null):Float = 0;

    var contentSize:ContentSizeProvider<Axis2D>;
    var target:AxisApplier;
    var axis:Axis2D;
    var maxOffset:Float = 0;
    var lastPos:Float = 0;
    var lastSize:Float = 0;

    public function new(t, a, csp) {
        target = t;
        contentSize = csp;
        contentSize.contentSizeChanged.listen(refresh);
        axis = a;
    }

    public function setOffset(val:Float) {
        return offset = Mathu.clamp(val, -maxOffset, 0);
    }

    function refresh(a) {
        if (a != axis)
            return;
        apply(lastPos, lastSize);
    }

    public function apply(pos:Float, size:Float):Void {
        lastPos = pos;
        lastSize = size;
        visibleSize = size;
        var cs = contentSize.getContentSize(axis);
        maxOffset = Math.max(cs - visibleSize, 0);
        target.apply(pos + offset, cs);
    }
}
