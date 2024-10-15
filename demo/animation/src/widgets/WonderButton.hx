package widgets;

import al.animation.Animation;
import al.animation.AnimationTreeComponent;
import ec.Entity;
import fu.PropStorage;
import fu.graphics.BarWidget;
import fu.graphics.ColouredQuad.InteractiveColors;
import fu.ui.AnimatedLabel;
import fu.ui.ButtonBase;
import gl.sets.ColorSet;
import graphics.ShapeColors;
import graphics.shapes.Bar;

class WonderButton extends ButtonBase implements Channels {
    public var channels(default, null):Array<Float->Void> = [];

    var tree:AnimationTreeComponent;

    public function new(w, h, text, style) {
        super(w, h);

        var elements = [
            new BarContainer(Portion(new BarAxisSlot({start: 0., end: 1.}, null)), Portion(new BarAxisSlot({start: 0., end: 1.}, null))),
            new BarContainer(FixedThikness(new BarAxisSlot({pos: 0., thikness: 1.}, null)), Portion(new BarAxisSlot({start: 0., end: 1.}, null))),
        ];
        var bg = new BarWidget(ColorSet.instance, w, elements);
        var bgcolors = new ShapeColors(ColorSet.instance, bg.getBuffer());
        bg.onShapesDone.listen(() -> bgcolors.initChildren(bg.getChildren()));
        bgcolors.colorize(1, 0x6c6c6c);
        addHandler(new InteractiveColors(bgcolors.getColorizeFun(0)).viewHandler);

        var lbl = new AnimatedLabel(w, style);
        lbl.withText(text);

        WonderKit.configure(entity);
        tree = new AnimationTreeComponent(entity, this);
        channels.push(BarAnimationUtils.directUnfold(elements[1]));
        channels.push(BarAnimationUtils.directUnfold(elements[0]));
        channels.push(lbl.setTime);
    }

    public function setTime(t):Void {
        tree.setTime(t);
    }
}