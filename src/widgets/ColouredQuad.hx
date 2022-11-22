package widgets;
import transform.LiquidTransformer;
import al.al2d.Widget2D;
import gl.sets.ColorSet;
import graphics.shapes.QuadGraphicElement;
import graphics.ShapesColorAssigner;
import input.core.ClicksInputSystem.ClickTargetViewState;
import widgets.ShapeWidget;
import Axis2D;
import widgets.ButtonBase;
class ColouredQuad  {

    public static function flatClolorQuad(w:Widget2D):ShapeWidget<ColorSet> {
        var attrs = ColorSet.instance;
        var shw = new ShapeWidget(attrs, w);
        shw.addChild(new QuadGraphicElement(attrs));
        var colors = new ShapesColorAssigner(attrs, 0, shw.getBuffer());
        var viewProc:ClickViewProcessor = w.entity.getComponent(ClickViewProcessor);
        if (viewProc!=null) {
            viewProc.addHandler(new InteractiveColors(colors.setColor).viewHandler);
            viewProc.addHandler(new InteractiveTransform(w).viewHandler);
        }
        return shw;
    }
}
class InteractiveColors {
    var colors:Map<ClickTargetViewState, Int>;
    var target:Int->Void;
    public function new(target) {
        this.target = target;
        colors = ClickColorSet.default_set;
    }

    function setColor(c:Int) {
        target(c);
    }

    public function viewHandler(st:ClickTargetViewState):Void {
        setColor(colors[st]);
    }
}

class InteractiveTransform extends Widgetable {
    @:once var transformer:LiquidTransformer;
    var state:ClickTargetViewState = Idle;
    public function new(w:Widget2D) {
        super(w);
    }

    override public function init() {
        viewHandler(state);
    }


    function rewritePos() {
        for (a in Axis2D) {
            var as = w.axisStates[a];
            as.apply(as.getPos(), as.getSize());
        }
    }


    public function viewHandler(st:ClickTargetViewState):Void {
        state = st;
        if (!_inited)
            return;
        switch st {
            case Idle : release();
            case Pressed : press();
            case PressedOutside : press();
            case Hovered : release();
        }
    }



    function press():Void {
        var ox = 0.005 / w.axisStates[horizontal].getSize();
        var oy = 0.005 / w.axisStates[vertical].getSize();
        transformer.setBounds(ox, oy, 1 + ox * 2, 1 + oy * 2);
        rewritePos();
    }

    function release():Void {
        transformer.setBounds(0, 0, 1, 1);
        rewritePos();
    }
}

class ClickColorSet {
    @:isVar public static var default_set(default, null):Map<ClickTargetViewState, Int> = [
        Idle => 0xff0000,
        Hovered => 0xffa0a0,
        Pressed => 0xffa0a0,
        PressedOutside => 0xff0000,
    ];
}
