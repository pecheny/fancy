package fu.ui.scroll;
import fu.graphics.ColouredQuad;
import fu.ui.ButtonBase.ClickViewProcessor;
import fu.graphics.ShapeWidget;
import a2d.AspectRatio;
import a2d.Placeholder2D;
import Axis2D;
import gl.sets.ColorSet;
import graphics.shapes.Bar.BarContainer;
import graphics.shapes.QuadGraphicElement;
import graphics.shapes.RectWeights;
import graphics.ShapesColorAssigner;
import utils.Mathu;
class FlatScrollbar extends ShapeWidget<ColorSet> implements WidgetScrollbar {
    var handler:QuadGraphicElement<ColorSet>;
    var axis:Axis2D;
    var handlerSize:Float = 0.5;
    var hanlderPos:Float = 0;
    var bar:BarContainer;

    public function new(w:Placeholder2D, aspectRatio:AspectRatio, axis:Axis2D) {
        super(ColorSet.instance, w);
        onShapesDone.listen(caclWeights);
        this.axis = axis;
        handler = new QuadGraphicElement(ColorSet.instance);
        addChild(handler);
        var colors = new ShapesColorAssigner(attrs, 0xffffff, getBuffer());
        var viewProc:ClickViewProcessor = w.entity.getComponent(ClickViewProcessor);
        if (viewProc != null) {
            viewProc.addHandler(new InteractiveColors(colors.setColor).viewHandler);
            viewProc.addHandler(new InteractiveTransform(w).viewHandler);
        }
    }

    public function setHandlerSize(v:Float):Void {
        handlerSize = Mathu.clamp(v, 0, 1);
        caclWeights();
    }

    public function setHandlerPos(v:Float):Void {
        hanlderPos = Mathu.clamp(v, 0, 1);
        caclWeights();
    }

    function caclWeights() {
        var trgWg = handler.weights[axis];
        var srcWg = RectWeights.weights[axis];
        var startPos = (1 - handlerSize) * hanlderPos;
        for (i in 0...trgWg.length) {
            trgWg[i] = startPos + handlerSize * srcWg[i];
        }
    }
}
