package widgets;
import graphics.ShapesColorAssigner;
import gl.sets.ColorSet;
import graphics.shapes.Bar.BarContainer;
import graphics.shapes.Bar.BarAxisSlot;
import al.animation.Animation.AnimWidget;
import al.animation.AnimationTreeBuilder;
import graphics.shapes.Bar;
class WonderButton extends ButtonBase {
    var tree:AnimWidget;
    public function new(w, h, text, style) {
        super(w, h );

        var elements = [
            new BarContainer(Portion(new BarAxisSlot ({start:0., end:1.}, null)), Portion(new BarAxisSlot ({start:0., end:1.}, null)) ),
            new BarContainer(FixedThikness(new BarAxisSlot ({pos:0., thikness:1.}, null)), Portion(new BarAxisSlot ({start:0., end:1.}, null)))
        ];
        var bg = new BarWidget(ColorSet.instance, w, elements);
        var colors = new ShapesColorAssigner(ColorSet.instance, 0xa09030, bg.getBuffer());

        new Label(w, style).withText(text);

        tree = new AnimationTreeBuilder().build(
            { layout:"wholefill",
                children:[ {
                    layout:"portion",
                    children:[
                        {size:{value:.4 }},
                        {size:{value:1. }},
                    ]
                } ] }
        );
        tree.bindDeep([0,0], BarAnimationUtils.directUnfold(elements[1]));
        tree.bindDeep([0,1], BarAnimationUtils.directUnfold(elements[0]));
    }

    public function setTime(t):Void {
        tree.setTime(t);
    }
}
