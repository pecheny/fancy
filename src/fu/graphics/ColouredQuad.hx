package fu.graphics;

import Axis2D;
import al.al2d.Placeholder2D;
import al.al2d.Widget;
import fu.ui.ButtonBase.ClickViewProcessor;
import gl.sets.ColorSet;
import graphics.ShapesBuffer;
import graphics.ShapesColorAssigner;
import graphics.shapes.QuadGraphicElement;
import macros.AVConstructor;
import shimp.ClicksInputSystem.ClickTargetViewState;
import transform.LiquidTransformer;

class ColouredQuad {
    public static function flatClolorQuad(w:Placeholder2D, color = 0):ShapeWidget<ColorSet> {
        var attrs = ColorSet.instance;
        var shw = new ShapeWidget(attrs, w, true);
        shw.addChild(new QuadGraphicElement(attrs));
        var colors = new ShapesColorAssigner(attrs, color, shw.getBuffer());
        var viewProc:ClickViewProcessor = w.entity.getComponent(ClickViewProcessor);
        if (viewProc != null) {
            viewProc.addHandler(new InteractiveColors(colors.setColor).viewHandler);
            viewProc.addHandler(new InteractiveTransform(w).viewHandler);
        }
        shw.manInit();
        return shw;
    }

    public static function flatClolorToggleQuad(w:Placeholder2D, color = 0):ShapeWidget<ColorSet> {
        var attrs = ColorSet.instance;
        var shw = new ShapeWidget(attrs, w, true);
        shw.addChild(new QuadGraphicElement(attrs));
        var viewProc:ClickViewProcessor = w.entity.getComponent(ClickViewProcessor);
        if (viewProc != null) {
            var colorToggle = new ColorToggle(shw.getBuffer());
            colorToggle.withColors(false, InteractiveColors.INACTIVE_COLORS);
            w.entity.addComponent(colorToggle);
            viewProc.addHandler(colorToggle.viewHandler);
            viewProc.addHandler(new InteractiveTransform(w).viewHandler);
        }
        shw.manInit();
        return shw;
    }
}

class InteractiveColors {
    public static var INACTIVE_COLORS(default, null):AVector<shimp.ClicksInputSystem.ClickTargetViewState, Int> = AVConstructor.create( //    Idle =>
        0x40000000, //    Hovered =>
        0x40d46e00, //    Pressed =>
        0x40d46e00, //    PressedOutside =>
        0x40000000);
    public static var DEFAULT_COLORS(default, null):AVector<ClickTargetViewState, Int> = AVConstructor.create( //    Idle =>
        0xff000000, //    Hovered =>
        0xffd46e00, //    Pressed =>
        0xFFd46e00, //    PressedOutside =>
        0xff000000);

    var colors:AVector<ClickTargetViewState, Int>;
    var target:Int->Void;

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
            var as = ph.axisStates[a];
            as.apply(as.getPos(), as.getSize());
        }
    }

    public function viewHandler(st:ClickTargetViewState):Void {
        state = st;
        if (!_inited)
            return;
        switch st {
            case Idle:
                release();
            case Pressed:
                press();
            case PressedOutside:
                press();
            case Hovered:
                release();
        }
    }

    function press():Void {
        var ox = 0.005 / ph.axisStates[horizontal].getSize();
        var oy = 0.005 / ph.axisStates[vertical].getSize();
        transformer.setBounds(ox, oy, 1 + ox * 2, 1 + oy * 2);
        rewritePos();
    }

    function release():Void {
        transformer.setBounds(0, 0, 1, 1);
        rewritePos();
    }
}

class ColorToggle {
    var active:Bool;
    var activeColors:InteractiveColors;
    var inactiveColors:InteractiveColors;
    var st:ClickTargetViewState;

    public function new(buff:ShapesBuffer<ColorSet>) {
        var colors = new ShapesColorAssigner(ColorSet.instance, 0, buff);
        inactiveColors = new InteractiveColors(colors.setColor);
        activeColors = new InteractiveColors(colors.setColor);
    }

    public function setActive(v) {
        active = v;
        viewHandler(st);
    }

    inline function getIc(v:Bool):InteractiveColors {
        return if (v) activeColors else inactiveColors;
    }

    public function withColors(forActive:Bool, colors) {
        @:privateAccess getIc(forActive).colors = colors;
        return this;
    }

    public function viewHandler(st:shimp.ClicksInputSystem.ClickTargetViewState):Void {
        this.st = st;
        getIc(active).viewHandler(st);
    }
}

