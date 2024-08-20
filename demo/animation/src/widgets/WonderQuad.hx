package widgets;
import fui.graphics.BarWidget;
import a2d.Stage;
import graphics.ShapesColorAssigner;
import al.al2d.Placeholder2D;
import al.animation.Animation.Animatable;
import al.animation.Animation.AnimationPlaceholder;
import al.animation.AnimationTreeBuilder;
import gl.sets.ColorSet;
import graphics.shapes.Bar;
class WonderQuad extends BarWidget<ColorSet>  implements Animatable {
    var tree:AnimationPlaceholder;
    var text:String;
    @:once var stage:Stage;
    public function new(w:Placeholder2D, c ){
        var elements = [
            new BarContainer(Portion(new BarAxisSlot ({start:0., end:1.}, null)), Portion(new BarAxisSlot ({start:0., end:1.}, null)) ),
        ];

        super(ColorSet.instance, w, elements);
        var colors = new ShapesColorAssigner(ColorSet.instance, c, getBuffer());
//        w.entity.addComponentByName(Entity.getComponentId(ClickTarget), this);
//        new CtxWatcher(ClickInputBinder, w.entity);
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
        tree.bindDeep([0, 0], BarAnimationUtils.directUnfold(elements[0], Axis2D.vertical));
//        tree.bindDeep([0,1], BarAnimationUtils.directUnfold(elements[0]));
    }



    public function setTime(t:Float):Void {
        if (!_inited)
            return;
        tree.setTime(t);
//        for (a in Axis2D) {
//            var axis = w.axisStates[a];
//            axis.apply(axis.getPos(), axis.getSize());
//        }
//        transformer.changed.dispatch();
//        fluidTransform.reapplyAll();
    }
}
