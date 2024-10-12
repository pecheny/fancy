package ui;

import a2d.Placeholder2D;
import ec.Component;
import a2d.PlaceholderBuilder2D;
import ec.Entity;
import al.animation.Animation.AnimContainer;
import al.layouts.OffsetLayout;
import a2d.Stage;
import update.Updatable;
import al.animation.AnimationTreeBuilder;
import al.ec.WidgetSwitcher;
import a2d.Widget;
import al.animation.Animation.AnimationPlaceholder;

class Screens implements Updatable {
    var tree:AnimationPlaceholder;
    var time:Float = 0;
    var e1 = (t:Float) -> {
        var a1 = Math.abs((Math.sin(Math.PI * t / 2)));
        return Math.pow(a1, 2);
    }

    var e2 = t -> {
        var a1 = Math.abs((Math.sin(Math.PI * t / 2)));
        return Math.pow(a1, 2);
    }

    var duration = 2.;

    public var switcher:WidgetSwitcher<Axis2D>;

    var prev:Placeholder2D;
    var prevAnim:Animator;
    var current:Placeholder2D;
    var curAnim:Animator;

    public function new(switcher) {
        this.switcher = switcher;
        tree = new AnimationTreeBuilder().build({
            layout: "portion",
            children: [{size: {value: 1.}}, {size: {value: 1.}},]
        });
        tree.bindAnimation(0, t -> {
            if (prevAnim != null)
                prevAnim.setT(1 - t);
        });
        tree.bindAnimation(1, t -> {
            if (curAnim != null)
                curAnim.setT(t);
        });
    }

    public function switchTo(ph:Placeholder2D) {
        time = current != null ? 0 : 0.5;
        prev = current;
        prevAnim = curAnim;
        current = ph;
        curAnim = current.entity.getComponent(Animator);
        switcher.bind(ph);
    }

    public function update(dt:Float):Void {
        if (time == 1 || current == null)
            return;
        time += dt / duration;
        if (time >= 1)
            time = 1;
        tree.setTime(time);
        if (time == 1 && prev != null) {
            switcher.unbind(prev);
            prev = null;
        }
    }
}

@:build(ec.macros.Macros.buildGetOrCreate())
class Animator extends Component {
    var tree:AnimationPlaceholder;
    @:once var animationTreeBuilder:AnimationTreeBuilder;

    override function init() {
        tree = animationTreeBuilder.build({
            layout: OffsetLayout.NAME,
            children: []
        });
        for (ch in channels)
            initAnim(ch);
        channels = null;
    }

    public function setT(t:Float) {
        if (tree == null)
            return;
        tree.setTime(t);
        // for (a in Axis2D) {
        //     var axis = ph.axisStates[a];
        //     axis.apply(axis.getPos(), axis.getSize());
        // }
    }

    var channels:Array<Float->Void> = [];

    public function addAnim(h) {
        if (_inited)
            initAnim(h);
        else
            channels.push(h);
    }

    function initAnim(h) {
        var animContainer = tree.entity.getComponent(AnimContainer);
        var anim = animationTreeBuilder.animationWidget(new Entity(), {});
        animationTreeBuilder.addChild(animContainer, anim);
        anim.animations.channels.push(h);
        animContainer.refresh();
    }
}
