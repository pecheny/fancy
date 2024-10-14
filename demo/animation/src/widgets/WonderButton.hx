package widgets;

import graphics.ShapeColors;
import al.animation.Animation.AnimationPlaceholder;
import al.animation.AnimationTreeBuilder;
import fu.graphics.BarWidget;
import fu.graphics.ColouredQuad.InteractiveColors;
import fu.ui.AnimatedLabel;
import fu.ui.ButtonBase;
import gl.AttribSet;
import gl.sets.ColorSet;
import graphics.ShapesBuffer;
import graphics.shapes.Bar;

class WonderButton extends ButtonBase {
    var tree:AnimationPlaceholder;

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

        tree = new AnimationTreeBuilder().build({
            layout: "wholefill",
            children: [
                {
                    layout: "portion",
                    children: [{size: {value: .4}}, {size: {value: 1.}},]
                }
            ]
        });
        tree.bindDeep([0, 0], BarAnimationUtils.directUnfold(elements[1]));
        tree.bindDeep([0, 1], BarAnimationUtils.directUnfold(elements[0]));
        tree.bindDeep([0, 1], lbl.setTime);
    }

    public function setTime(t):Void {
        tree.setTime(t);
    }
}