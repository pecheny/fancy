package scroll;
import Axis2D;
import al.al2d.Widget2D;
import crosstarget.Widgetable;
import ec.CtxWatcher;
import graphics.shapes.RectWeights;
import transform.AspectRatio;
class FlatScrollbar extends Widgetable implements WidgetScrollbar {
//    var handler:QuadGraphicElement<ColorSet>;
//    var axis:Axis2D;
//    var handlerSize:Float = 0.5;
//    var hanlderPos:Float = 0;
//    var tr:GFluidTransform;

    public function new(w:Widget2D, aspectRatio:AspectRatio, axis:Axis2D) {
        super(w);
//        this.axis = axis;
//        new CtxBinder(Drawcalls, w.entity);
//        var fluidTransform = new GFluidTransform(aspectRatio);
//        tr = fluidTransform;
//        var e = w.entity;
//        var colorContainer = new GraphicsContainer(ColorSet.instance, e, new RenderDataTarget());
//
//        function fillColor(q:GraphicsElement<ColorSet>, cp) {
//            MeshUtils.writeInt8Attribute(ColorSet.instance, colorContainer.bytes(), AttribAliases.NAME_COLOR_IN, q.pos, q.vertCount(), cp);
//        }
//
//        var bg = fluidTransform.addChild(colorContainer.addGraphic(new QuadGraphicElement(ColorSet.instance)));
//        handler = fluidTransform.addChild(colorContainer.addGraphic(new QuadGraphicElement(ColorSet.instance)));
//
//
//        colorContainer.build();
//
//        for (a in Axis2D.keys) {
//            var applier2:GTransformAxisApplier = cast fluidTransform.getAxisApplier(a);
//            w.axisStates[a].addSibling(applier2);
//        }
//
//        fillColor(bg, (_,_) -> 0x20);
//        fillColor(handler, (_,_)->250);
//        caclWeights();
    }

    public function setHandlerSize(v:Float):Void {
//        handlerSize = Mathu.clamp(v, 0, 1);
//        caclWeights();
    }

    public function setHandlerPos(v:Float):Void {
//        hanlderPos = Mathu.clamp(v, 0, 1);
//        caclWeights();
    }


//    inline function caclWeights() {
//        var trgWg = handler.weights[axis];
//        var srcWg = RectWeights.weights[axis];
//        var startPos = (1 - handlerSize) * hanlderPos;
////        var endPos = startPos + handlerSize;
////        if (axis == vertical)
////        trace('$startPos - $endPos');
//
//        for (i in 0...trgWg.length) {
//            trgWg[i] = startPos + handlerSize * srcWg[i];
//        }
//        tr.reapplyAll();
//    }
}
