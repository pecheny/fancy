package widgets;
import macros.AVConstructor;
import transform.LiquidTransformer;
import al.al2d.Placeholder2D;
import gl.sets.ColorSet;
import graphics.shapes.QuadGraphicElement;
import graphics.ShapesColorAssigner;
import shimp.ClicksInputSystem.ClickTargetViewState;
import widgets.ShapeWidget;
import Axis2D;
import widgets.ButtonBase;
class ColouredQuad {

    public static function flatClolorQuad(w:Placeholder2D, color = 0):ShapeWidget<ColorSet> {
        var attrs = ColorSet.instance;
        var shw = new ShapeWidget(attrs, w);
        shw.addChild(new QuadGraphicElement(attrs));
        var colors = new ShapesColorAssigner(attrs, color, shw.getBuffer());
        var viewProc:ClickViewProcessor = w.entity.getComponent(ClickViewProcessor);
        if (viewProc != null) {
            viewProc.addHandler(new InteractiveColors(colors.setColor).viewHandler);
            viewProc.addHandler(new InteractiveTransform(w).viewHandler);
        }
        return shw;
    }
}
class InteractiveColors {
    public static var DEFAULT_COLORS(default, null):AVector<ClickTargetViewState, Int> = AVConstructor.create(
//    Idle =>
        0,
//    Hovered =>
        0xd46e00,
//    Pressed =>
        0xd46e00,
//    PressedOutside =>
        0
    );
    var colors:AVector<ClickTargetViewState, Int>;
    var target:Int -> Void;

    public function new(target, colors = null) {
        this.target = target;
        this.colors = colors == null ? DEFAULT_COLORS : colors;
    }

    function setColor(c:Int) {
        target(c);
    }

    public function viewHandler(st:ClickTargetViewState):Void {
        setColor(colors[st]);
    }
}

class InteractiveTransform extends Widget {
    @:once var transformer:LiquidTransformer;
    var state:ClickTargetViewState = Idle;

    public function new(w:Placeholder2D) {
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

}
