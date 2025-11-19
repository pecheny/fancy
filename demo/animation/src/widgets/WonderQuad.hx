package widgets;

import ec.Entity;
import al.animation.AnimationTree.Channels;
import al.animation.AnimationTree.AnimationTreeProp;
import fu.graphics.BarWidget;
import a2d.Stage;
import graphics.ShapesColorAssigner;
import a2d.Placeholder2D;
import al.animation.Animation.Animatable;
import al.animation.Animation.AnimationPlaceholder;
import al.animation.AnimationTreeBuilder;
import gl.sets.ColorSet;
import graphics.shapes.Bar;

class WonderQuad extends BarWidget<ColorSet> implements Channels {
    var tree:AnimationPlaceholder;
    var text:String;
    @:once var stage:Stage;

    public var channels(default, null):Array<Float->Void>;

    public function new(w:Placeholder2D, c) {
        var elements = [
            new BarContainer(Portion(new BarAxisSlot({start: 0., end: 1.}, null)), Portion(new BarAxisSlot({start: 0., end: 1.}, null))),
        ];

        super(ColorSet.instance, w, elements);
        var colors = new ShapesColorAssigner(ColorSet.instance, c, getBuffer());
        tree = AnimationTreeBuilder.animationWidget(new Entity("wq"), {size: {value: 1.}});
        // tree = new AnimationTreeBuilder().build({
        //     layout: "portion",
        //     children: [
        //         {
        //             layout: "portion",
        //             children: [{size: {value: .4}}, {size: {value: 1.}},]
        //         }
        //     ]
        // });
        // tree.bindDeep([0, 0], BarAnimationUtils.directUnfold(elements[0], Axis2D.vertical));
        setBgT = BarAnimationUtils.directUnfold(elements[0], Axis2D.vertical);
        tree.channels.push(setTime);
        //        tree.bindDeep([0,1], BarAnimationUtils.directUnfold(elements[0]));
        var prop = AnimationTreeProp.getOrCreate(entity);
        prop.value = tree;
    }

    var setBgT:Float->Void;

    function setTime(t) {
        // trace(t);
        setBgT(t);
    }
}
